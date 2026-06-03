
{{- define "base-service.fullname" -}}
{{- .Release.Name }}
{{- end}}



{{- define "base-service.labels" -}}
app.kubernetes.io/name: {{.Release.Name}}
app.kubernetes.io/instance: {{.Release.Name}}
app.kubernetes.io/managed-by: {{.Release.Service}}
{{- end}}


{{- define "base-service.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

