새 Helm 가이드 문서를 생성합니다.

**사용법**: `/new-doc <주제명>`

**예시**: `/new-doc subchart-communication`

주제 분류:
- 차트 구조: chart-structure, templates, helpers
- 값 관리: values, overrides, schema
- 고급 기능: hooks, dependencies, library-charts
- 운영: repository, lifecycle, oci-registry

`<주제명>-guide.md` 생성 시 포함 내용:
- `helm lint` / `helm template` 검증 예시
- 실제 동작 가능한 템플릿/values 코드
- `charts/` 디렉토리의 실습 예시 연계
- 트러블슈팅 섹션
