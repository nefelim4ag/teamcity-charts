{{- if $.Values.serviceAccount.enabled }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $.Release.Name }}
  annotations: {{ $.Values.serviceAccount.annotations | toJson }}
{{- end }}
