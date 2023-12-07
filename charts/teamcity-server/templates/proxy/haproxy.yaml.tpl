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
        config-sha: {{ include (print $.Template.BasePath "/proxy/configmap.yaml.tpl") . | sha1sum }}
      labels:
        app: {{ $.Release.Name }}-proxy
        component: proxy
    spec:
      containers:
      - name: haproxy
        image: {{ $.Values.proxy.image.repository }}:{{ $.Values.proxy.image.tag }}
        imagePullPolicy: {{ $.Values.proxy.image.pullPolicy }}
        lifecycle:
          preStop:
            exec:
              command:
                - sh
                - -c
                - sleep 10; kill -s SIGUSR1 1
        startupProbe: {{ $.Values.proxy.startupProbe | toJson }}
        livenessProbe: {{ $.Values.proxy.livenessProbe | toJson }}
        ports:
        - name: http
          containerPort: 80
        - name: stats
          containerPort: 8080
        resources: {{ $.Values.proxy.resources | toJson }}
        volumeMounts:
          - name: haproxy-config
            mountPath: /usr/local/etc/haproxy
      volumes:
      - name: haproxy-config
        configMap:
          name: {{ $.Release.Name }}-haproxy-cfg
          defaultMode: 420
          optional: false
      securityContext:
        sysctls:
        - name: net.ipv4.ip_unprivileged_port_start
          value: "1"
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
