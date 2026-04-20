새 Helm 운영 런북을 생성합니다.

**사용법**: `/new-runbook <작업명>`

**예시**: `/new-runbook 프로덕션 차트 업그레이드`

작업 유형:
- `차트 배포`: 신규 릴리즈 설치
- `업그레이드`: helm upgrade --atomic
- `롤백`: helm rollback
- `의존성 관리`: helm dependency update

런북 포함 내용:
- 사전 체크리스트 (helm list, 현재 버전 확인)
- helm diff로 변경 사항 사전 확인
- 단계별 helm 명령어
- 롤백 절차 (helm rollback <release> <revision>)
- 배포 확인 명령어
