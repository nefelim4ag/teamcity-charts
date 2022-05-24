{{- if gt (int .Values.proxy.replicas) 1 }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ $.Release.Name }}-proxy
  labels:
    app: {{ $.Release.Name }}-proxy
    component: proxy
spec:
  selector:
    matchLabels:
      app: {{ $.Release.Name }}-proxy
      component: proxy
  minAvailable: 1
{{- end }}
