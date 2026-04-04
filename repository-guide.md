# Chart Repository 관리 가이드

## Repository란?
Helm Chart를 호스팅하는 HTTP 서버입니다. `index.yaml`과 패키징된 Chart(`.tgz`)로 구성됩니다.

---

## 1. Repository 관리

```bash
# 추가
helm repo add bitnami https://charts.bitnami.com/bitnami

# 목록 확인
helm repo list

# 캐시 갱신 (새 Chart 버전 반영)
helm repo update

# 삭제
helm repo remove bitnami
```

---

## 2. Chart 검색

```bash
# 로컬 캐시에서 검색
helm search repo nginx

# ArtifactHub(공개 레지스트리)에서 검색
helm search hub nginx

# 특정 버전 포함 전체 목록
helm search repo bitnami/nginx --versions
```

---

## 3. Chart 정보 확인

```bash
# Chart 기본 정보 및 README
helm show chart bitnami/nginx
helm show readme bitnami/nginx

# 기본 values.yaml 확인
helm show values bitnami/nginx

# 모든 정보 출력
helm show all bitnami/nginx
```

---

## 4. Chart 다운로드

```bash
# 현재 디렉토리에 .tgz 다운로드
helm pull bitnami/nginx

# 특정 버전
helm pull bitnami/nginx --version 15.1.0

# 압축 해제하여 디렉토리로
helm pull bitnami/nginx --untar

# 특정 경로로
helm pull bitnami/nginx --untar --untardir ./charts
```

---

## 5. OCI Registry (ECR, GHCR 등)

Helm 3.8부터 OCI(Docker Registry 프로토콜)를 공식 지원합니다.

### AWS ECR 사용 예시
```bash
# ECR 로그인 (Helm OCI 인증)
aws ecr get-login-password --region ap-northeast-2 | \
  helm registry login \
  --username AWS \
  --password-stdin \
  123456789012.dkr.ecr.ap-northeast-2.amazonaws.com

# Chart 패키징
helm package charts/my-app

# ECR에 Push
helm push my-app-0.1.0.tgz oci://123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/helm-charts

# ECR에서 설치
helm install my-release oci://123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/helm-charts/my-app --version 0.1.0
```

### GitHub Container Registry 사용 예시
```bash
# 로그인
echo $GITHUB_TOKEN | helm registry login ghcr.io --username $GITHUB_USER --password-stdin

# Push
helm push my-app-0.1.0.tgz oci://ghcr.io/my-org/helm-charts
```

---

## 6. 나만의 Chart 패키징

```bash
# Chart 문법 검사
helm lint charts/my-app

# .tgz 파일로 패키징
helm package charts/my-app

# 버전 지정
helm package charts/my-app --version 1.0.0 --app-version "2.0.0"
```

---

## 7. 자주 쓰는 공개 Repository

| 이름 | URL | 주요 Chart |
|------|-----|------------|
| Bitnami | https://charts.bitnami.com/bitnami | nginx, postgresql, redis, kafka |
| ingress-nginx | https://kubernetes.github.io/ingress-nginx | ingress-nginx |
| Jetstack | https://charts.jetstack.io | cert-manager |
| prometheus-community | https://prometheus-community.github.io/helm-charts | kube-prometheus-stack |
| Grafana | https://grafana.github.io/helm-charts | grafana, loki, tempo |
| EKS | https://aws.github.io/eks-charts | aws-load-balancer-controller, karpenter |
| Istio | https://istio-release.storage.googleapis.com/charts | base, istiod, gateway |
