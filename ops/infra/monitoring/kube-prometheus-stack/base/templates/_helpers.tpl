{{/*
kube-prometheus-stack helpers
*/}}
{{- define "kube-prometheus-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kube-prometheus-stack.fullname" -}}
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

{{- define "kube-prometheus-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kube-prometheus-stack.labels" -}}
helm.sh/chart: {{ include "kube-prometheus-stack.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: kube-prometheus-stack
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{- end }}

{{/* Prometheus Operator */}}
{{- define "kube-prometheus-stack.operator.name" -}}
{{- printf "%s-operator" (include "kube-prometheus-stack.fullname" .) }}
{{- end }}

{{- define "kube-prometheus-stack.operator.serviceAccountName" -}}
{{- if .Values.prometheusOperator.serviceAccount.create }}
{{- default (include "kube-prometheus-stack.operator.name" .) .Values.prometheusOperator.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.prometheusOperator.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Prometheus */}}
{{- define "kube-prometheus-stack.prometheus.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount.create }}
{{- default (printf "%s-prometheus" (include "kube-prometheus-stack.fullname" .)) .Values.prometheus.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.prometheus.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Alertmanager */}}
{{- define "kube-prometheus-stack.alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create }}
{{- default (printf "%s-alertmanager" (include "kube-prometheus-stack.fullname" .)) .Values.alertmanager.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.alertmanager.serviceAccount.name }}
{{- end }}
{{- end }}
