{{- define "ki-selfhost-operator.labels" -}}
app.kubernetes.io/name: {{ include "ki-selfhost-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ki-selfhost-operator.serviceAccountName" -}}
{{ .Values.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- end }}

{{- define "ki-selfhost-operator.name" -}}
ki-selfhost-operator
{{- end }}
