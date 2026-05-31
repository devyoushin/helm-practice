# helm-practice

A hands-on repository for learning Helm on Kubernetes.
- **Environment**: EKS / Helm 3.x
- **Charts**: my-app (기본 실습), production-app (실전 패턴)

---

## 어디서 시작할까

- 문서 지도: `docs/README.md`
- 첫 문서: `docs/install.md`
- 운영 보조 자료: `ops/README.md`
- AI 작업 지침: `CLAUDE.md`

## 구조

| 경로 | 내용 |
|------|------|
| `docs/` | 설치, chart 구조, values, lifecycle, hooks, dependency 문서 |
| `ops/` | Helm chart, 애플리케이션 helmfile, 인프라 helmfile 자산 |
| `CLAUDE.md` | 이 레포에서 Claude가 참고할 작업 지침 |

---

## Learning Path

```
1. Installation    → docs/install.md
2. Core Concepts   → docs/chart-structure-guide.md, docs/values-template-guide.md, docs/repository-guide.md
3. Advanced
   ├── Lifecycle     → docs/lifecycle-guide.md
   ├── Hooks         → docs/hooks-guide.md
   └── Dependencies  → docs/dependencies-guide.md
4. Hands-on
   ├── Basic         → docs/first-chart-practice.md
   └── Production    → ops/charts/production-app/ (HPA, PDB, Secret, Probe, 환경별 values)
5. Tips            → docs/tips-guide.md
```

---

## Documents

### Installation
| File | Description |
|------|-------------|
| [install.md](./docs/install.md) | Helm 설치 및 기본 환경 설정 |

### Core Concepts
| File | Description |
|------|-------------|
| [chart-structure-guide.md](./docs/chart-structure-guide.md) | Chart 디렉토리 구조와 각 파일 역할 |
| [values-template-guide.md](./docs/values-template-guide.md) | values.yaml과 Go 템플릿 문법 |
| [repository-guide.md](./docs/repository-guide.md) | Chart Repository 추가·검색·관리 |

### Advanced
| File | Description |
|------|-------------|
| [lifecycle-guide.md](./docs/lifecycle-guide.md) | Install / Upgrade / Rollback 라이프사이클 |
| [hooks-guide.md](./docs/hooks-guide.md) | Helm Hooks — pre/post install, test |
| [dependencies-guide.md](./docs/dependencies-guide.md) | Chart 의존성(Subchart) 관리 |

### Hands-on
| File | Description |
|------|-------------|
| [first-chart-practice.md](./docs/first-chart-practice.md) | 커스텀 Chart 처음부터 만들고 배포하는 실습 |
| [ops/charts/production-app/](./ops/charts/production-app/) | HPA·PDB·Secret·Probe·환경별 values 포함 실전 Chart |

### Tips
| File | Description |
|------|-------------|
| [tips-guide.md](./docs/tips-guide.md) | 실전 운영에서 유용한 팁 15가지 (Secret 관리, 무중단 배포, 디버깅 등) |

---

## 상세 구조

```
ops/charts/
├── my-app/                     # 기본 실습 Chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
└── production-app/             # 실전 패턴 Chart
    ├── Chart.yaml
    ├── values.yaml             # 공통 기본값
    ├── values-dev.yaml         # dev 오버라이드
    ├── values-staging.yaml     # staging 오버라이드
    ├── values-prod.yaml        # production 오버라이드
    └── templates/
        ├── _helpers.tpl
        ├── deployment.yaml     # checksum 어노테이션, securityContext 포함
        ├── service.yaml
        ├── ingress.yaml
        ├── configmap.yaml      # 앱 설정값 (비민감)
        ├── secret.yaml         # 민감 정보 (b64enc)
        ├── serviceaccount.yaml
        ├── hpa.yaml            # HorizontalPodAutoscaler
        ├── pdb.yaml            # PodDisruptionBudget
        └── NOTES.txt           # 배포 후 안내 메시지
```

---

## Key Concept Summary

**Chart + Values + Templates** 가 Helm의 핵심입니다.

```
helm install <release-name> <chart-path> --values values.yaml
        │
        ▼
[Chart.yaml]        → 이 Chart가 무엇인지 정의 (이름, 버전)
        │
        ▼
[values.yaml]       → 사용자 설정값 주입 (image, replicas, port ...)
        │
        ▼
[templates/*.yaml]  → Go 템플릿으로 values를 참조해 최종 K8s 매니페스트 생성
        │
        ▼
kubectl apply (Helm이 내부적으로 처리)
```

> `helm template` 명령어로 렌더링된 최종 YAML을 미리 확인할 수 있습니다.
