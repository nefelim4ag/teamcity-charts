{{- range $key_out, $value := .Values.teamcity }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $.Release.Name }}-{{ $key_out }}
  annotations:
{{ $.Values.proxy.ingress.annotations | toYaml | indent 4 }}
spec:
  tls:
  - secretName: "{{ $.Release.Name}}-{{ $key_out }}-tls"
    hosts:
    {{- range $key := $value.ingress.hosts }}
    - {{ tpl $key $ }}
    {{- end }}
  rules:
  {{- range $key := $value.ingress.hosts }}
  - host: {{ tpl $key $ }}
    http:
      paths:
        - pathType: ImplementationSpecific
          backend:
            service:
              name: {{ $.Release.Name }}-{{ $key_out }}
              port:
                name: http
  {{- end }}
{{- end }}
