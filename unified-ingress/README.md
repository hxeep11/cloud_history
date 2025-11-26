# Unified Ingress Configuration

하나의 OCI Load Balancer를 사용하여 여러 서비스를 path 기반으로 라우팅하는 통합 Ingress 구성입니다.

## 아키텍처

```
OCI Load Balancer (168.107.11.85)
  ↓
Ingress Nginx Controller
  ↓
  ├─ /argocd → ArgoCD Server (argocd namespace)
  ├─ /blog   → Blog Board Service (default namespace)
  └─ /       → Nginx Service (nginx namespace)
```

## 구성 요소

### 1. Ingress Controller Service
- **파일**: `ingress-controller-svc.yaml`
- **네임스페이스**: ingress-nginx
- **타입**: LoadBalancer
- **고정 IP**: 168.107.11.85
- **포트**:
  - HTTP: 80 → NodePort 31646
  - HTTPS: 443 → NodePort 31505
- **OCI 설정**:
  - Flexible shape (min: 10, max: 10)
  - Subnet: ocid1.securitylist.oc1.ap-chuncheon-1.aaaaaaaamxqsz4l6grcjmw2yvvhlok2ipfavuighltywf2vyrdl33b7mlmvq

### 2. Path 기반 라우팅

#### ArgoCD Ingress (`/argocd`)
- **파일**: `argocd-ingress.yaml`
- **경로**: `/argocd(/|$)(.*)`
- **백엔드**: argocd-server:443 (HTTPS)
- **네임스페이스**: argocd

#### Blog Board Ingress (`/blog`)
- **파일**: `blog-ingress.yaml`
- **경로**: `/blog(/|$)(.*)`
- **백엔드**: blog-board-service:80
- **네임스페이스**: default

#### Nginx Ingress (`/`)
- **파일**: `nginx-ingress.yaml`
- **경로**: `/` (루트)
- **백엔드**: nginx-service:80
- **네임스페이스**: nginx

### 3. Service 변경사항

#### Nginx Service Patch
- **파일**: `nginx-svc-patch.yaml`
- **변경**: NodePort → ClusterIP
- 이제 Ingress를 통해서만 접근 가능

## 배포 방법

### 사전 요구사항

1. Ingress Nginx Controller가 설치되어 있어야 합니다:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

2. ArgoCD가 설치되어 있어야 합니다.

### 방법 1: 직접 배포

```bash
# Kustomize를 사용한 배포
kubectl apply -k unified-ingress/

# 배포 확인
kubectl get svc -n ingress-nginx
kubectl get ingress -A
```

### 방법 2: ArgoCD를 통한 GitOps 배포

1. Git 저장소 URL 수정:
```bash
# argocd-application.yaml 파일에서 repoURL 수정
vi unified-ingress/argocd-application.yaml
```

2. ArgoCD Application 생성:
```bash
kubectl apply -f unified-ingress/argocd-application.yaml
```

3. ArgoCD UI에서 확인 또는 CLI 사용:
```bash
argocd app get unified-ingress
argocd app sync unified-ingress
```

## 접근 URL

배포 후 다음 경로로 서비스에 접근할 수 있습니다:

- **ArgoCD**: `http://168.107.11.85/argocd`
- **Blog Board**: `http://168.107.11.85/blog`
- **Nginx**: `http://168.107.11.85/`

## 검증

```bash
# Load Balancer 외부 IP 확인
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Ingress 리소스 확인
kubectl get ingress -A

# 각 서비스 테스트
curl http://168.107.11.85/
curl http://168.107.11.85/blog
curl http://168.107.11.85/argocd
```

## 주의사항

1. **ArgoCD 설정**:
   - ArgoCD는 base path `/argocd`를 인식하도록 설정 필요
   - `argocd-cmd-params-cm` ConfigMap에 `server.basehref: /argocd` 추가:
   ```bash
   kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.basehref":"/argocd","server.rootpath":"/argocd"}}'
   kubectl rollout restart deployment argocd-server -n argocd
   ```

2. **기존 LoadBalancer 제거**:
   - 기존 nginx-service의 NodePort를 ClusterIP로 변경
   - 기존 LoadBalancer 타입 서비스 삭제 필요

3. **도메인 설정** (선택사항):
   - 각 Ingress에 `host` 필드를 추가하여 도메인 기반 라우팅 가능
   - 예: `argocd.example.com`, `blog.example.com`

## 트러블슈팅

### Load Balancer가 생성되지 않는 경우
```bash
kubectl describe svc -n ingress-nginx ingress-nginx-controller
```

### Ingress가 작동하지 않는 경우
```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
kubectl describe ingress -A
```

### Path 라우팅이 작동하지 않는 경우
- `rewrite-target` annotation 확인
- 백엔드 서비스가 실행 중인지 확인
- 서비스 포트와 Pod 포트가 일치하는지 확인
