{{- define "base-service.labels" -}}
app:{{.Values.appname}}
environment: {{.Values.environment}}
{{- end}}

{{- define "base-service.selectorLabels" -}}
app:{{.Values.appname}}
{{- end}}
