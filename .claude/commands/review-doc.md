Helm 차트 또는 가이드 문서를 검토합니다.

**사용법**: `/review-doc <파일 경로>`

**예시**: `/review-doc charts/my-app/values.yaml`

검토 기준:

**차트 구조**
- [ ] `Chart.yaml`: apiVersion, name, version, appVersion 필수 필드
- [ ] `values.yaml`: 모든 값에 주석으로 설명
- [ ] `templates/_helpers.tpl`: 공통 레이블/이름 헬퍼 정의
- [ ] `NOTES.txt`: 설치 후 안내 메시지

**템플릿 품질**
- [ ] `{{ include "chart.fullname" . }}` 패턴 사용
- [ ] `resources` 필드 values로 오버라이드 가능
- [ ] `securityContext` 기본값 설정
- [ ] `helm lint` 통과 여부

**values.yaml**
- [ ] `image.repository`, `image.tag` 분리
- [ ] `service.type`, `service.port` 설정
- [ ] `ingress.enabled` 선택적 활성화 패턴
