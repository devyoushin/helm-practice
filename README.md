# helm-practice

A hands-on repository for learning Helm on Kubernetes.
- **Environment**: EKS / Helm 3.x
- **App**: my-app (nginx 기반 커스텀 Chart)

---

## Learning Path

```
1. Installation    → install.md
2. Core Concepts   → chart-structure-guide.md, values-template-guide.md, repository-guide.md
3. Advanced
   ├── Lifecycle     → lifecycle-guide.md
   ├── Hooks         → hooks-guide.md
   └── Dependencies  → dependencies-guide.md
4. Hands-on        → first-chart-practice.md
```

---

## Documents

### Installation
| File | Description |
|------|-------------|
| [install.md](./install.md) | Helm 설치 및 기본 환경 설정 |

### Core Concepts
| File | Description |
|------|-------------|
| [chart-structure-guide.md](./chart-structure-guide.md) | Chart 디렉토리 구조와 각 파일 역할 |
| [values-template-guide.md](./values-template-guide.md) | values.yaml과 Go 템플릿 문법 |
| [repository-guide.md](./repository-guide.md) | Chart Repository 추가·검색·관리 |

### Advanced
| File | Description |
|------|-------------|
| [lifecycle-guide.md](./lifecycle-guide.md) | Install / Upgrade / Rollback 라이프사이클 |
| [hooks-guide.md](./hooks-guide.md) | Helm Hooks — pre/post install, test |
| [dependencies-guide.md](./dependencies-guide.md) | Chart 의존성(Subchart) 관리 |

### Hands-on
| File | Description |
|------|-------------|
| [first-chart-practice.md](./first-chart-practice.md) | 커스텀 Chart 처음부터 만들고 배포하는 실습 |

---

## Manifest Structure

```
charts/my-app/
├── Chart.yaml              # Chart 메타데이터 (이름, 버전, 설명)
├── values.yaml             # 기본값 정의
└── templates/
    ├── _helpers.tpl        # 재사용 가능한 Named Template
    ├── deployment.yaml     # Deployment 리소스
    ├── service.yaml        # Service 리소스
    └── ingress.yaml        # Ingress 리소스 (선택)
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
