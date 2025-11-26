# Tech Hub - 게시판 & 블로그 플랫폼

ArgoCD와 Kustomize를 활용한 GitOps 기반 Kubernetes 배포 프로젝트

## 프로젝트 개요

Tech Hub는 기술 커뮤니티를 위한 게시판과 블로그 플랫폼입니다. GitOps 방식으로 Kubernetes에 배포되며, 환경별로 다른 설정을 Kustomize로 관리합니다.

### 주요 기능

- **게시판**: 질문, 토론, 팁, 뉴스 카테고리로 구성된 커뮤니티 게시판
- **블로그**: 기술 아티클과 개발 경험을 공유하는 블로그
- **반응형 디자인**: 모바일, 태블릿, 데스크톱 지원
- **GitOps 배포**: ArgoCD를 통한 자동화된 배포

## 프로젝트 구조

```
.
├── argocd/
│   ├── application-dev.yaml      # Dev 환경 ArgoCD Application
│   └── application-prod.yaml     # Prod 환경 ArgoCD Application
├── k8s/
│   ├── base/                     # 기본 Kubernetes 매니페스트
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── overlays/
│       ├── dev/                  # Dev 환경 오버레이
│       │   ├── kustomization.yaml
│       │   ├── deployment-patch.yaml
│       │   ├── ingress-patch.yaml
│       │   ├── nginx.conf
│       │   ├── index.html
│       │   ├── board.html
│       │   ├── blog.html
│       │   ├── post.html
│       │   ├── styles.css
│       │   └── script.js
│       └── prod/                 # Prod 환경 오버레이
│           └── (동일한 구조)
└── README.md
```

## 시작하기

### 사전 요구사항

- Kubernetes 클러스터 (v1.20 이상)
- ArgoCD 설치
- kubectl CLI
- (선택) kustomize CLI

### ArgoCD 설치

```bash
# ArgoCD 네임스페이스 생성
kubectl create namespace argocd

# ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD CLI 설치 (macOS)
brew install argocd

# ArgoCD CLI 설치 (Linux)
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# 초기 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 애플리케이션 배포

#### 1. GitHub 저장소 설정

`argocd/application-dev.yaml`과 `argocd/application-prod.yaml` 파일에서 GitHub 저장소 URL을 수정하세요:

```yaml
source:
  repoURL: https://github.com/YOUR_ORG/YOUR_REPO  # 실제 저장소 URL로 변경
```

#### 2. Dev 환경 배포

```bash
# ArgoCD Application 생성
kubectl apply -f argocd/application-dev.yaml

# 배포 상태 확인
argocd app get blog-board-dev

# 동기화 (자동 동기화가 활성화되어 있지 않은 경우)
argocd app sync blog-board-dev
```

#### 3. Production 환경 배포

```bash
# Production Application 생성
kubectl apply -f argocd/application-prod.yaml

# 배포 상태 확인
argocd app get blog-board-prod

# 수동 동기화
argocd app sync blog-board-prod
```

### Kustomize로 직접 배포 (ArgoCD 없이)

```bash
# Dev 환경
kubectl apply -k k8s/overlays/dev

# Prod 환경
kubectl apply -k k8s/overlays/prod
```

## 환경별 설정

### Dev 환경
- **네임스페이스**: `blog-app-dev`
- **Replicas**: 1
- **리소스**: CPU 50m-100m, Memory 64Mi-128Mi
- **도메인**: `dev.blog.example.com`
- **자동 동기화**: 활성화

### Production 환경
- **네임스페이스**: `blog-app-prod`
- **Replicas**: 3
- **리소스**: CPU 200m-500m, Memory 256Mi-512Mi
- **도메인**: `blog.example.com`
- **자동 동기화**: 비활성화 (수동 승인)
- **TLS/SSL**: Let's Encrypt 인증서

## 주요 페이지

### 1. 홈페이지 (`index.html`)
- 플랫폼 소개
- 주요 기능 안내
- 최근 게시글 미리보기

### 2. 게시판 (`board.html`)
- 카테고리별 필터링 (질문, 토론, 팁, 뉴스)
- 검색 기능
- 페이지네이션
- 댓글 수, 조회수, 좋아요 표시

### 3. 블로그 (`blog.html`)
- 카테고리별 분류
- 태그 클라우드
- 최근 댓글
- 작성자 정보

### 4. 게시글 상세 (`post.html`)
- 목차 자동 생성
- 코드 블록 복사 기능
- 공유 기능
- 관련 글 추천
- 댓글 시스템

## 기술 스택

- **Container**: Docker, Nginx Alpine
- **Orchestration**: Kubernetes
- **GitOps**: ArgoCD
- **Configuration**: Kustomize
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Design**: Modern CSS Grid & Flexbox

## 모니터링 및 관리

### ArgoCD UI 접속

```bash
# 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 브라우저에서 접속
open https://localhost:8080
```

### 로그 확인

```bash
# Dev 환경 로그
kubectl logs -n blog-app-dev -l app=blog-board --tail=100 -f

# Prod 환경 로그
kubectl logs -n blog-app-prod -l app=blog-board --tail=100 -f
```

### 리소스 확인

```bash
# Dev 환경
kubectl get all -n blog-app-dev

# Prod 환경
kubectl get all -n blog-app-prod
```

## 커스터마이징

### 도메인 변경

`k8s/overlays/dev/ingress-patch.yaml` 및 `k8s/overlays/prod/ingress-patch.yaml`에서 호스트 이름을 수정하세요:

```yaml
spec:
  rules:
  - host: your-domain.com  # 원하는 도메인으로 변경
```

### 리소스 조정

각 환경의 `deployment-patch.yaml`에서 CPU와 메모리 설정을 조정할 수 있습니다:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 컨텐츠 수정

HTML, CSS, JavaScript 파일은 `k8s/overlays/{env}/` 디렉토리에 있습니다. 파일을 수정하고 Git에 커밋하면 ArgoCD가 자동으로 배포합니다.

## 롤백

### ArgoCD를 통한 롤백

```bash
# 이전 버전으로 롤백
argocd app rollback blog-board-dev

# 특정 리비전으로 롤백
argocd app rollback blog-board-dev 3
```

### kubectl을 통한 롤백

```bash
# Deployment 롤백
kubectl rollout undo deployment/dev-blog-board-app -n blog-app-dev

# 롤백 상태 확인
kubectl rollout status deployment/dev-blog-board-app -n blog-app-dev
```

## 트러블슈팅

### Pod가 시작하지 않는 경우

```bash
# Pod 상태 확인
kubectl get pods -n blog-app-dev

# Pod 이벤트 확인
kubectl describe pod <pod-name> -n blog-app-dev

# Pod 로그 확인
kubectl logs <pod-name> -n blog-app-dev
```

### ArgoCD 동기화 실패

```bash
# Application 상태 확인
argocd app get blog-board-dev

# 동기화 재시도
argocd app sync blog-board-dev --force
```

### Ingress 접속 불가

```bash
# Ingress 상태 확인
kubectl get ingress -n blog-app-dev

# Ingress Controller 로그 확인
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## 보안 고려사항

- Production 환경에서는 HTTPS 필수 (Let's Encrypt)
- NGINX 보안 헤더 설정 적용
- 리소스 제한(limits) 설정
- 네임스페이스 격리
- RBAC 설정 권장

## 라이선스

MIT License

## 기여

이슈와 풀 리퀘스트를 환영합니다!

## 문의

프로젝트 관련 문의사항은 이슈로 등록해주세요.
