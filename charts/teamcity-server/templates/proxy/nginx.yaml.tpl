---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $.Release.Name }}-proxy
spec:
  replicas: {{ $.Values.proxy.replicas }}
  selector:
    matchLabels:
      app: {{ $.Release.Name }}-proxy
      component: proxy
  template:
    metadata:
      annotations:
    {{- range $key, $value := $.Values.teamcity.nodes }}
        {{ $.Release.Name }}-{{ $key }}: {{ $value.env.NODE_ID }}
    {{- end }}
      labels:
        app: {{ $.Release.Name }}-proxy
        component: proxy
    spec:
      containers:
      - name: nginx
        image: {{ $.Values.proxy.image.repository }}:{{ $.Values.proxy.image.tag }}
        imagePullPolicy: {{ $.Values.proxy.image.pullPolicy }}
        lifecycle:
          preStop:
            exec:
              command:
                - sh
                - -c
                - sleep 10; exec /usr/sbin/nginx -s quit
        startupProbe: {{ $.Values.proxy.startupProbe | toJson }}
        livenessProbe: {{ $.Values.proxy.livenessProbe | toJson }}
        ports:
        - name: http
          containerPort: 80
        resources: {{ $.Values.proxy.resources | toJson }}
        volumeMounts:
          - name: nginx-config
            mountPath: /etc/nginx/conf.d/default.conf
            subPath: default.conf
      volumes:
      - name: nginx-config
        configMap:
          name: {{ $.Release.Name }}-nginx-conf
          defaultMode: 420
          optional: false
      imagePullSecrets: {{ $.Values.proxy.image.imagePullSecrets | toJson }}
      {{- with $.Values.proxy.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $.Values.proxy.affinity }}
      affinity:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $.Values.proxy.tolerations }}
      tolerations:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
