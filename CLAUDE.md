# helm-practice — 프로젝트 가이드

## 디렉토리 구조

```
helm-practice/
├── CLAUDE.md                  # 이 파일 (자동 로드)
├── .claude/
│   ├── settings.json
│   └── commands/              # /new-doc, /new-runbook, /review-doc, /add-troubleshooting, /search-kb
├── agents/                    # doc-writer, chart-designer, values-advisor, troubleshooter
├── templates/                 # service-doc, runbook, incident-report
├── rules/                     # doc-writing, helm-conventions, security-checklist, monitoring
├── charts/                    # 실습용 Helm 차트
├── infra/                     # CNCF/플랫폼 차트 (helmfile 기반)
│   ├── helmfile.yaml          # 전체 스택 오케스트레이션
│   ├── karpenter/             # 노드 오토스케일링
│   ├── istio/                 # 서비스 메시 (base/istiod/gateway)
│   ├── monitoring/            # kube-prometheus-stack
│   ├── cert-manager/          # TLS 인증서 자동화
│   ├── external-dns/          # DNS 자동화
│   └── ingress-nginx/         # Ingress 컨트롤러
├── apps/                      # 애플리케이션 차트 (helmfile 기반)
│   ├── helmfile.yaml          # 앱 스택 오케스트레이션
│   ├── environments/          # 환경별 공통값 (dev/staging/prod)
│   └── services/              # 서비스별 차트
│       ├── api-server/        # REST API 서버 (완성형 예시)
│       └── worker/            # 비동기 워커 (KEDA 연동)
└── *-guide.md                 # 주제별 가이드 문서
```

---

## 커스텀 슬래시 명령어

| 명령어 | 설명 | 사용 예시 |
|--------|------|---------|
| `/new-doc` | 새 가이드 문서 생성 | `/new-doc subchart-communication` |
| `/new-runbook` | 새 런북 생성 | `/new-runbook 프로덕션 차트 업그레이드` |
| `/review-doc` | 차트/문서 검토 | `/review-doc charts/my-app/values.yaml` |
| `/add-troubleshooting` | 트러블슈팅 케이스 추가 | `/add-troubleshooting upgrade 후 CrashLoopBackOff` |
| `/search-kb` | 지식베이스 검색 | `/search-kb Helm 훅 실행 순서` |

---

## 가이드 문서 목록

| 문서 | 주제 |
|------|------|
| `install.md` | Helm 설치 및 기본 사용법 |
| `chart-structure-guide.md` | 차트 구조 상세 |
| `values-template-guide.md` | values.yaml 및 템플릿 작성 |
| `dependencies-guide.md` | 의존성 관리 (Chart.lock) |
| `hooks-guide.md` | 훅(pre-install, post-upgrade 등) |
| `lifecycle-guide.md` | 릴리즈 라이프사이클 |
| `repository-guide.md` | Helm 레포지토리 관리 |
| `tips-guide.md` | 실전 팁 및 트러블슈팅 |
| `first-chart-practice.md` | 첫 차트 만들기 실습 |

---

## 핵심 명령어

```bash
# 차트 검증
helm lint ./chart
helm template test ./chart -f values.yaml

# 변경 사항 사전 확인 (helm-diff 플러그인)
helm diff upgrade <release> ./chart -f values.yaml

# prod 배포 (--atomic 필수)
helm upgrade <release> ./chart --install --atomic --timeout 5m -f values-prod.yaml

# 롤백
helm rollback <release> <revision> -n <namespace>
```
