# Helm Docs

Helm 학습 문서는 목적별 폴더로 나눠 관리합니다.

## 학습 문서

| 분류 | 문서 | 내용 |
|------|------|------|
| 시작하기 | [install.md](./getting-started/install.md) | Helm 설치와 기본 환경 설정 |
| 시작하기 | [upgrade/](./install/upgrade/) | Helm release 업그레이드 실행 |
| 핵심 개념 | [chart-structure-guide.md](./core/chart-structure-guide.md) | Chart 구조 |
| 핵심 개념 | [values-template-guide.md](./core/values-template-guide.md) | values와 Go template |
| 핵심 개념 | [repository-guide.md](./core/repository-guide.md) | Chart repository 관리 |
| 심화 | [lifecycle-guide.md](./advanced/lifecycle-guide.md) | install, upgrade, rollback |
| 심화 | [hooks-guide.md](./advanced/hooks-guide.md) | Helm hooks |
| 심화 | [dependencies-guide.md](./advanced/dependencies-guide.md) | chart dependency |
| 실습 | [first-chart-practice.md](./hands-on/first-chart-practice.md) | 첫 chart 실습 |
| 운영 | [tips-guide.md](./operations/tips-guide.md) | 운영 팁 |

## 보조 자료

| 폴더 | 내용 |
|------|------|
| `agents/` | AI 에이전트 역할 정의 |
| `rules/` | 문서 작성, Helm 관례, 보안, 모니터링 규칙 |
| `templates/` | 서비스 문서, 런북, 장애 보고서 템플릿 |

처음 읽을 문서는 [getting-started/install.md](./getting-started/install.md)입니다.
업그레이드 실행 절차는 [install/upgrade/](./install/upgrade/)입니다.
