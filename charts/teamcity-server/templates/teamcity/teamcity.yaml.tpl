---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $.Release.Name }}
spec:
  replicas: {{ len $.Values.teamcity.nodes }}
  serviceName: {{ $.Release.Name }}-headless
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: {{ $.Release.Name }}
      component: server
  template:
    metadata:
      labels:
        app: {{ $.Release.Name }}
        component: server
    spec:
      containers:
      - name: {{ $.Release.Name }}
        image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
        imagePullPolicy: {{ $.Values.image.pullPolicy }}
        command:
        - /run-services-wrp.sh
        env:
        {{- with $.Values.teamcity.env }}
        {{- range $key, $value := . }}
        - name: {{ $key }}
        {{- if kindIs "string" $value }}
          value: {{ tpl ($value) $ }}
        {{- else }}
          {{- tpl (toYaml $value) $ | nindent 10 }}
        {{- end }}
        {{- end }}
        {{- end }}
        startupProbe: {{ $.Values.teamcity.startupProbe | toJson }}
        ports: {{ $.Values.teamcity.ports | toJson}}
        resources: {{ $.Values.teamcity.resources | toJson }}
        volumeMounts:
        - mountPath: /data/teamcity_server/datadir
          name: teamcity-server-data
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
        - mountPath: /run-services-wrp.sh
          name: {{ $.Release.Name }}-startup-wrp
          subPath: run-services-wrp.sh
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
        - mountPath: /opt/teamcity/{{ $volume }}
          name: {{ $volume | lower | replace "/" "-" | trimSuffix "-" }}
{{- end }}
{{- end }}
        - mountPath: /home/tcuser
          name: home-tcuser
      volumes:
      - name: {{ $.Release.Name }}-opt-conf
        configMap:
          defaultMode: 0644
          name: {{ $.Release.Name }}-opt-conf
          optional: false
      - name: {{ $.Release.Name }}-datadir-config
        configMap:
          defaultMode: 0644
          name: {{ $.Release.Name }}-datadir-config
          optional: false
      - name: {{ $.Release.Name }}-startup-wrp
        configMap:
          defaultMode: 0755
          name: {{ $.Release.Name }}-startup-wrp
          optional: false
      - name: teamcity-server-data
        persistentVolumeClaim:
          claimName: {{ $.Values.pvc.name }}
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if not $v_values.enabled }}
      - emptyDir: {}
        name: {{ $volume | lower | replace "/" "-" | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}
      - emptyDir: {}
        name: home-tcuser
      imagePullSecrets: {{ $.Values.image.imagePullSecrets | toJson }}
      affinity: {{ $.Values.teamcity.affinity | toJson }}
      {{- with $.Values.teamcity.topologySpreadConstraints }}
      topologySpreadConstraints:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $.Values.teamcity.affinity }}
      affinity:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
      {{- with $.Values.teamcity.tolerations }}
      tolerations:
        {{- tpl (toYaml .) $ | nindent 8 }}
      {{- end }}
  volumeClaimTemplates:
{{- with $.Values.ephemeral }}
{{- range $volume, $v_values := . }}
{{- if $v_values.enabled }}
  - metadata:
      name: {{ $volume | lower | replace "/" "-" | trimSuffix "-" }}
      annotations: {{ $v_values.annotations | toJson }}
    spec:
      storageClassName: {{ $v_values.storageClassName }}
      accessModes: {{ $v_values.accessModes | toJson }}
      resources: {{ $v_values.resources | toJson }}
      volumeMode: Filesystem
{{- end }}
{{- end }}
{{- end }}
