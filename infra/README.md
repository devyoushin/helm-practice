# 인프라 차트 관리 전략

실무에서 CNCF/써드파티 Helm 차트를 관리하는 방법을 정리합니다.
`helmfile`을 사용해 여러 차트를 선언적으로 한꺼번에 관리합니다.

---

## 디렉토리 구조

```
infra/
├── helmfile.yaml                  # 전체 스택 오케스트레이션
├── helmfile.d/                    # 레이어별 분리 (선택적)
│   ├── 00-cert-manager.yaml
│   ├── 10-ingress-nginx.yaml
│   ├── 20-istio.yaml
│   ├── 30-karpenter.yaml
│   └── 40-monitoring.yaml
├── karpenter/
│   ├── values.yaml                # 공통 base values
│   └── values-prod.yaml          # prod 오버라이드
├── istio/
│   ├── base/values.yaml
│   ├── istiod/values.yaml
│   └── gateway/values.yaml
├── monitoring/
│   └── kube-prometheus-stack/
│       ├── values.yaml
│       └── values-prod.yaml
├── cert-manager/
│   └── values.yaml
├── external-dns/
│   └── values.yaml
└── ingress-nginx/
    ├── values.yaml
    └── values-prod.yaml
```

---

## 핵심 원칙

### 1. 업스트림 차트는 절대 fork 하지 않는다
- `values.yaml`만으로 커스터마이즈
- chart version을 helmfile에 명시적으로 고정
- `helm dependency update` 대신 OCI registry 또는 공식 repo 사용

### 2. 레이어 순서 보장
인프라 컴포넌트 간 의존성이 있으므로 배포 순서가 중요합니다.

```
Layer 0: cert-manager          ← CRD 먼저
Layer 1: ingress-nginx         ← 네트워크 진입점
Layer 2: external-dns          ← DNS 자동화
Layer 3: karpenter             ← 노드 오토스케일링
Layer 4: istio (base → istiod → gateway)
Layer 5: monitoring            ← 관찰가능성
```

### 3. 환경 분리 전략
```bash
# dev 배포
helmfile -e dev sync

# prod 배포 (diff 먼저 확인)
helmfile -e prod diff
helmfile -e prod sync
```

---

## helmfile 사용법

```bash
# 설치
brew install helmfile

# 전체 스택 확인
helmfile list

# 특정 레이블만 배포
helmfile -l app=monitoring sync

# dry-run
helmfile template

# 변경사항 미리 보기 (helm-diff 필요)
helmfile diff

# 전체 배포
helmfile sync

# 순서 보장 배포 (--concurrency 1)
helmfile sync --concurrency 1
```

---

## 버전 업그레이드 절차

```bash
# 1. 차트 릴리즈 노트 확인
helm show chart <repo>/<chart> --version <new-version>

# 2. values 변경사항 확인
helm show values <repo>/<chart> --version <new-version> > /tmp/new-values.yaml
diff values.yaml /tmp/new-values.yaml

# 3. helmfile에서 버전 변경 후 diff
helmfile diff -e prod

# 4. 스테이징 먼저 배포
helmfile -e staging sync -l app=<chart>

# 5. 검증 후 prod 배포
helmfile -e prod sync -l app=<chart>
```
