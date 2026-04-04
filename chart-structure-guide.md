# Helm Chart 구조 가이드

## Chart란?
Helm Chart는 Kubernetes 리소스를 패키징한 단위입니다. `helm create` 명령어로 기본 골격을 생성할 수 있습니다.

```bash
helm create my-app
```

---

## 디렉토리 구조

```
my-app/
├── Chart.yaml           # Chart 메타데이터 (필수)
├── values.yaml          # 기본 설정값 (필수)
├── charts/              # 의존 Chart(Subchart)가 위치하는 디렉토리
├── templates/           # K8s 매니페스트 템플릿 디렉토리 (필수)
│   ├── _helpers.tpl     # Named Template 모음 (K8s 리소스로 렌더링되지 않음)
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   └── NOTES.txt        # helm install 후 출력되는 안내문
└── .helmignore          # 패키징 시 제외할 파일 목록 (.gitignore 형식)
```

---

## 1. Chart.yaml

Chart의 메타데이터를 정의합니다. `name`과 `version`은 필수입니다.

```yaml
apiVersion: v2          # Helm 3은 반드시 v2
name: my-app
description: A simple nginx-based application chart
type: application       # application(기본) 또는 library
version: 0.1.0          # Chart 자체 버전 (SemVer)
appVersion: "1.21.0"    # 배포하는 앱의 버전 (참고용)
```

> `version` vs `appVersion`
> - `version`: Chart 템플릿 코드의 버전. 템플릿을 수정하면 올려야 합니다.
> - `appVersion`: 실제 애플리케이션(Docker 이미지 태그 등)의 버전.

---

## 2. values.yaml

템플릿에 주입할 기본값을 정의합니다. 사용자는 `--values` 또는 `--set`으로 이 값을 덮어쓸 수 있습니다.

```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.21.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

---

## 3. templates/_helpers.tpl

`{{- define "..." -}}` 구문으로 재사용 가능한 Named Template을 정의합니다.
`_` 로 시작하는 파일은 K8s 리소스로 렌더링되지 않습니다.

```yaml
{{/* Chart 이름 정의 */}}
{{- define "my-app.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* fullname: release-name + chart-name */}}
{{- define "my-app.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 공통 라벨 */}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
```

---

## 4. templates/NOTES.txt

`helm install` 완료 후 터미널에 출력되는 안내 메시지입니다. 접속 방법이나 다음 단계를 안내하는 데 사용합니다.

```
1. 앱에 접속하려면 아래 명령어를 실행하세요:

  export POD_NAME=$(kubectl get pods -l "app.kubernetes.io/name={{ include "my-app.name" . }}" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward $POD_NAME 8080:80

2. 브라우저에서 http://127.0.0.1:8080 접속
```

---

## 5. .helmignore

Chart 패키징(`helm package`) 시 포함하지 않을 파일을 지정합니다.

```
.git/
*.md
.DS_Store
tests/
```

---

## Chart 검증 명령어

```bash
# 문법 오류 검사
helm lint charts/my-app

# 렌더링 결과 미리보기 (클러스터 미적용)
helm template my-release charts/my-app

# 특정 values 파일 적용해서 렌더링
helm template my-release charts/my-app -f custom-values.yaml

# dry-run (클러스터와 통신하지만 실제 배포 안 함)
helm install my-release charts/my-app --dry-run --debug
```
