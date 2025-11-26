# 배포 가이드

이 문서는 Tech Hub 애플리케이션을 Kubernetes 클러스터에 배포하는 상세한 가이드입니다.

## 배포 전 체크리스트

- [ ] Kubernetes 클러스터 접근 가능
- [ ] ArgoCD 설치 완료
- [ ] GitHub 저장소에 코드 푸시
- [ ] Ingress Controller 설치 (NGINX Ingress 권장)
- [ ] DNS 레코드 설정 (선택사항)

## 1단계: 저장소 설정

### GitHub 저장소 생성 및 푸시

```bash
# 현재 디렉토리를 Git 저장소로 초기화 (이미 되어있지 않은 경우)
git init

# 모든 파일 추가
git add .

# 커밋
git commit -m "Initial commit: ArgoCD GitOps setup with blog and board"

# 원격 저장소 추가 (YOUR_ORG와 YOUR_REPO를 실제 값으로 변경)
git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git

# 푸시
git push -u origin main
```

### ArgoCD Application 매니페스트 업데이트

`argocd/application-dev.yaml`과 `argocd/application-prod.yaml` 파일의 `repoURL`을 업데이트하세요:

```yaml
source:
  repoURL: https://github.com/YOUR_ORG/YOUR_REPO
```

## 2단계: ArgoCD 설치 및 설정

### ArgoCD 설치

```bash
# ArgoCD 네임스페이스 생성
kubectl create namespace argocd

# ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 설치 확인
kubectl get pods -n argocd
```

### ArgoCD CLI 설치

**macOS:**
```bash
brew install argocd
```

**Linux:**
```bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

**Windows:**
```powershell
# Chocolatey 사용
choco install argocd-cli

# 또는 직접 다운로드
# https://github.com/argoproj/argo-cd/releases
```

### ArgoCD 접속

```bash
# 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 초기 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# CLI 로그인
argocd login localhost:8080
```

브라우저에서 `https://localhost:8080` 접속
- **Username**: admin
- **Password**: 위에서 확인한 비밀번호

## 3단계: Ingress Controller 설치 (선택사항)

```bash
# NGINX Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# 설치 확인
kubectl get pods -n ingress-nginx
```

## 4단계: Dev 환경 배포

### ArgoCD Application 생성

```bash
# Application 생성
kubectl apply -f argocd/application-dev.yaml

# 상태 확인
argocd app get blog-board-dev

# ArgoCD UI에서도 확인 가능
```

### 동기화

자동 동기화가 활성화되어 있지만, 수동으로 동기화할 수도 있습니다:

```bash
# 동기화
argocd app sync blog-board-dev

# 동기화 상태 확인
argocd app wait blog-board-dev
```

### 배포 확인

```bash
# 리소스 확인
kubectl get all -n blog-app-dev

# Pod 상태 확인
kubectl get pods -n blog-app-dev

# 로그 확인
kubectl logs -n blog-app-dev -l app=blog-board
```

### 로컬에서 테스트

```bash
# 포트 포워딩
kubectl port-forward -n blog-app-dev svc/dev-blog-board-service 8081:80

# 브라우저에서 접속
open http://localhost:8081
```

## 5단계: Production 환경 배포

### DNS 설정

Production 배포 전에 DNS 레코드를 설정하세요:

```
blog.example.com  A  <Ingress-LoadBalancer-IP>
```

Ingress LoadBalancer IP 확인:
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

### Let's Encrypt 설정 (HTTPS)

cert-manager 설치:

```bash
# cert-manager 설치
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# ClusterIssuer 생성
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # 실제 이메일로 변경
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Production Application 배포

```bash
# Application 생성
kubectl apply -f argocd/application-prod.yaml

# 상태 확인
argocd app get blog-board-prod

# 수동 동기화 (Production은 자동 동기화가 비활성화됨)
argocd app sync blog-board-prod

# 배포 완료 대기
argocd app wait blog-board-prod
```

### 배포 확인

```bash
# 리소스 확인
kubectl get all -n blog-app-prod

# Ingress 확인
kubectl get ingress -n blog-app-prod

# 인증서 확인
kubectl get certificate -n blog-app-prod

# 브라우저에서 접속
open https://blog.example.com
```

## 6단계: 모니터링 설정

### ArgoCD에서 모니터링

ArgoCD UI에서 다음을 확인할 수 있습니다:
- 애플리케이션 상태 (Healthy, Progressing, Degraded)
- 동기화 상태 (Synced, OutOfSync)
- 리소스 상태
- 배포 히스토리

### Kubernetes 대시보드 (선택사항)

```bash
# Kubernetes Dashboard 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# 토큰 생성
kubectl -n kubernetes-dashboard create token admin-user

# 포트 포워딩
kubectl proxy

# 브라우저 접속
open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## 업데이트 및 롤백

### 컨텐츠 업데이트

```bash
# HTML, CSS, JS 파일 수정
vim k8s/overlays/dev/index.html

# Git에 커밋 및 푸시
git add .
git commit -m "Update homepage content"
git push

# ArgoCD가 자동으로 동기화 (Dev 환경)
# Production은 수동 동기화 필요
argocd app sync blog-board-prod
```

### 롤백

```bash
# 히스토리 확인
argocd app history blog-board-dev

# 이전 버전으로 롤백
argocd app rollback blog-board-dev

# 특정 리비전으로 롤백
argocd app rollback blog-board-dev 3
```

## 문제 해결

### Pod가 Pending 상태

```bash
# Pod 상세 정보 확인
kubectl describe pod <pod-name> -n blog-app-dev

# 리소스 부족 확인
kubectl top nodes
```

### ConfigMap이 업데이트되지 않음

ConfigMap은 이름이 해시로 생성되므로 내용이 변경되면 새로운 ConfigMap이 생성됩니다.

```bash
# ConfigMap 확인
kubectl get configmap -n blog-app-dev

# Pod 재시작
kubectl rollout restart deployment/dev-blog-board-app -n blog-app-dev
```

### Ingress 접속 불가

```bash
# Ingress 상태 확인
kubectl describe ingress -n blog-app-dev

# Ingress Controller 로그
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=100
```

### 인증서 발급 실패

```bash
# CertificateRequest 확인
kubectl get certificaterequest -n blog-app-prod

# cert-manager 로그 확인
kubectl logs -n cert-manager -l app=cert-manager
```

## 정리

### Dev 환경 삭제

```bash
argocd app delete blog-board-dev
```

### Production 환경 삭제

```bash
argocd app delete blog-board-prod
```

### ArgoCD 삭제

```bash
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

## 다음 단계

- [ ] Prometheus/Grafana로 모니터링 추가
- [ ] Horizontal Pod Autoscaler 설정
- [ ] 백업 전략 수립
- [ ] CI/CD 파이프라인 통합 (GitHub Actions)
- [ ] 다중 클러스터 배포

## 참고 자료

- [ArgoCD 공식 문서](https://argo-cd.readthedocs.io/)
- [Kustomize 가이드](https://kustomize.io/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
