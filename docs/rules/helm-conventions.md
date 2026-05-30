# Helm 코드 표준 관행

## Chart.yaml 필수 필드

```yaml
apiVersion: v2
name: my-app
description: 앱 설명 (한국어)
type: application
version: 0.1.0        # 차트 버전 (SemVer)
appVersion: "1.0.0"   # 애플리케이션 버전
```

## values.yaml 패턴

```yaml
# 이미지 설정
image:
  repository: nginx     # 레지스트리/이미지명
  tag: "1.21"           # appVersion 참조 권장
  pullPolicy: IfNotPresent

# 서비스 설정
service:
  type: ClusterIP       # LoadBalancer 지양 (인그레스 사용)
  port: 80

# 리소스 제한 (항상 포함)
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

# 보안 컨텍스트
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

## _helpers.tpl 필수 헬퍼

```go
{{- define "chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
```

## 배포 원칙

```bash
# prod 배포 시 --atomic 필수
helm upgrade <release> ./chart \
  --install \
  --atomic \           # 실패 시 자동 롤백
  --timeout 5m \
  -f values-prod.yaml

# 변경 전 diff 확인
helm diff upgrade <release> ./chart -f values.yaml
```

## 절대 하지 말 것
- `image.tag: latest` values 기본값 설정
- 시크릿을 values.yaml에 평문 저장
- prod에서 `--force` 옵션 사용 (데이터 손실 위험)
