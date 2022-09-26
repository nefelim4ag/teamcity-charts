{{- range $key, $value := .Values.teamcity }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $.Release.Name }}-{{ $key }}
spec:
  replicas: {{ $value.replicas}}
  selector:
    matchLabels:
      app: {{ $.Release.Name }}
      component: {{ $key }}
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: {{ $.Release.Name }}
        component: {{ $key }}
    spec:
      containers:
      - name: {{ $.Release.Name }}-{{ $key }}
        image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
        imagePullPolicy: {{ $.Values.image.pullPolicy }}
        env:
        {{- with $value.env }}
        {{- range $key, $value := . }}
        - name: {{ $key }}
        {{- if kindIs "string" $value }}
          value: {{ tpl ($value) $ }}
        {{- else }}
          {{- tpl (toYaml $value) $ | nindent 10 }}
        {{- end }}
        {{- end }}
        {{- end }}
        startupProbe:
          httpGet:
            path: /login.html
            port: 8111
            scheme: HTTP
          failureThreshold: 120
          periodSeconds: 5
        ports:
        - containerPort: 8111
          name: http
          protocol: TCP
        resources: {{ $value.resources | toJson }}
        volumeMounts:
        {{- range $key, $value := $.Values.configMap.datadirConfig }}
        - name: {{ $.Release.Name }}-datadir-config
          mountPath: /data/teamcity_server/datadir/config/{{ $key }}
          subPath: {{ $key }}
        {{- end }}
        {{- range $key, $value := $.Values.configMap.optConf }}
        - mountPath: /opt/teamcity/conf/{{ $key }}
          name: {{ $.Release.Name }}-opt-conf
          subPath: {{ $key }}
        {{- end }}
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if $v_values.enabled }}
        - mountPath: /opt/teamcity/{{ $volume }}
          name: {{ $.Release.Name }}-{{ $key }}-{{ $volume }}
{{- end }}
{{- end }}
{{- end }}
        - mountPath: /data/teamcity_server/datadir
          name: teamcity-server-data
{{- if $.Values.ephemeral.cache.enabled }}
        - mountPath: /var/cache/teamcity
          name: {{ $.Release.Name }}-{{ $key }}-cache
{{- else }}
        - mountPath: /var/cache/teamcity
          name: cache-volume
{{- end }}
        - mountPath: /home/tcuser
          name: home
      volumes:
      - name: {{ $.Release.Name }}-opt-conf
        configMap:
          defaultMode: 420
          name: {{ $.Release.Name }}-opt-conf
          optional: false
      - name: {{ $.Release.Name }}-datadir-config
        configMap:
          defaultMode: 420
          name: {{ $.Release.Name }}-datadir-config
          optional: false
      - name: teamcity-server-data
        persistentVolumeClaim:
          claimName: {{ $.Values.pvc.name }}
{{- if not $.Values.ephemeral.cache.enabled }}
      - emptyDir: {}
        name: cache-volume
{{- end }}
      - emptyDir: {}
        name: home
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if $v_values.enabled }}
      - name: {{ $.Release.Name }}-{{ $key }}-{{ $volume }}
        persistentVolumeClaim:
          claimName: {{ $.Release.Name }}-{{ $key }}-{{ $volume }}
{{- end }}
{{- end }}
{{- end }}
      affinity: {{ $value.affinity | toJson }}
      imagePullSecrets: {{ $.Values.image.imagePullSecrets | toJson }}
      {{- with $value.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $value.affinity }}
      affinity:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $value.tolerations }}
      tolerations:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
{{- end }}
