{{- define "cert-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cert-manager.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "cert-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cert-manager.labels" -}}
helm.sh/chart: {{ include "cert-manager.chart" . }}
{{ include "cert-manager.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "cert-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cert-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: controller
{{- end }}

{{- define "cert-manager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cert-manager.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Webhook helpers */}}
{{- define "webhook.fullname" -}}
{{- printf "%s-webhook" (include "cert-manager.fullname" .) }}
{{- end }}

{{- define "webhook.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cert-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: webhook
{{- end }}

{{- define "cainjector.fullname" -}}
{{- printf "%s-cainjector" (include "cert-manager.fullname" .) }}
{{- end }}

{{- define "cainjector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cert-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: cainjector
{{- end }}
