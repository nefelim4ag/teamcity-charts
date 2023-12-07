---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}
spec:
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-headless
spec:
  type: ClusterIP
  clusterIP: None
  publishNotReadyAddresses: false
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server

{{- range $index, $value := $.Values.teamcity.nodes }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-direct-{{ $index }}
  annotations:
    {{- if and ($value.env) ($value.env.NODE_ID) }}
    node-id: "{{ $value.env.NODE_ID }}"
    {{- else }}
    node-id: "{{ $.Release.Name }}-{{ $index }}"
    {{- end }}
spec:
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server
    statefulset.kubernetes.io/pod-name: {{ $.Release.Name }}-{{ $index }}
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-direct-h{{ $index }}
  annotations:
    {{- if and ($value.env) ($value.env.NODE_ID) }}
    node-id: "{{ $value.env.NODE_ID }}"
    {{- else }}
    node-id: "{{ $.Release.Name }}-{{ $index }}"
    {{- end }}
spec:
  clusterIP: None
  publishNotReadyAddresses: true
  ports:
    - name: http
      protocol: TCP
      port: 8111
      targetPort: http
  selector:
    app: {{ $.Release.Name }}
    component: server
    statefulset.kubernetes.io/pod-name: {{ $.Release.Name }}-{{ $index }}
  type: ClusterIP
{{- end }}
