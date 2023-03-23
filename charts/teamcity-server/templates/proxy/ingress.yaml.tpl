---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $.Release.Name }}-proxy
  annotations:
{{ $.Values.proxy.ingress.annotations | toYaml | indent 4 }}
spec:
  ingressClassName: {{ $.Values.proxy.ingress.ingressClassName }}
  tls:
  - secretName: "{{ $.Release.Name}}-proxy-tls"
    hosts:
    {{- range $key := $.Values.proxy.ingress.hosts }}
    - {{ tpl $key $ }}
    {{- end }}
  rules:
  {{- range $key := $.Values.proxy.ingress.hosts }}
  - host: {{ tpl $key $ }}
    http:
      paths:
        - pathType: ImplementationSpecific
          backend:
            service:
              name: {{ $.Release.Name }}-proxy
              port:
                name: http
  {{- end }}
