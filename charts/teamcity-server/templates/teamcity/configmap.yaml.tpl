---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-datadir-config
data:
{{ tpl ($.Values.configMap.datadirConfig | toYaml) $ | indent 4 }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-opt-conf
data:
{{ tpl ($.Values.configMap.optConf | toYaml) $ | indent 4 }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-startup-wrp
data:
  run-services-wrp.sh: |
    #!/bin/bash
    HOSTNAME=$(cat /etc/hostname)
    set -x
{{- range $index, $value := .Values.teamcity.nodes }}
    if [ "$HOSTNAME" == "{{ $.Release.Name }}-{{ $index }}" ]; then
{{- with $value.env }}
{{- range $e, $value := . }}
      export {{ $e }}="{{ tpl ($value) $ }}"
{{- end }}
{{- end }}
      export TEAMCITY_SERVER_OPTS="-Dteamcity.server.nodeId=${NODE_ID} -Dteamcity.server.rootURL=${ROOT_URL} $TEAMCITY_SERVER_OPTS"
      exec /run-services.sh "${@}"
    fi
{{- end }}
