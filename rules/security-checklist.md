# 보안 체크리스트 — helm-practice

## 차트 보안
- [ ] `image.tag: latest` 기본값 금지 — 명시적 버전 사용
- [ ] `securityContext.runAsNonRoot: true` 기본값 설정
- [ ] `securityContext.readOnlyRootFilesystem: true` 고려
- [ ] `capabilities.drop: [ALL]` 설정

## 시크릿 관리
- [ ] values.yaml에 평문 시크릿 금지
- [ ] External Secrets Operator 또는 Sealed Secrets 사용
- [ ] `helm secrets` 플러그인으로 values 암호화

## RBAC
- [ ] ServiceAccount 명시적 생성 (`serviceAccount.create: true`)
- [ ] 최소 권한 ClusterRole/Role 바인딩

## 이미지 보안
- [ ] imagePullSecrets 설정 (프라이빗 레지스트리)
- [ ] 이미지 다이제스트 고정 (`sha256:...`) — prod 권장

## 네트워크
- [ ] `service.type: LoadBalancer` 직접 노출 지양
- [ ] Ingress + TLS 설정 (`ingress.tls` 블록)
- [ ] NetworkPolicy 템플릿 포함 고려
