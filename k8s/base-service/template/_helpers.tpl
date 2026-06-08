{{- define "base-service.labels" -}}
app:{{.Values.appname}}
environment: {{.Values.environment}}
{{-end}}
