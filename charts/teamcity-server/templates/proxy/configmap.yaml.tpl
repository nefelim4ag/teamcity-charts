---
kind: ConfigMap
apiVersion: v1
metadata:
  name: {{ $.Release.Name }}-nginx-conf
data:
  default.conf: |
    {{- range $key_out, $value_out := $.Values.teamcity.nodes }}
    upstream {{ $value_out.env.NODE_ID }} {
      {{- range $key_in, $value_in := $.Values.teamcity.nodes }}
      {{- if eq $value_out.env.NODE_ID $value_in.env.NODE_ID }}
      server {{ $.Release.Name }}-{{ $key_in }}.{{ $.Release.Name }}-headless:8111 max_fails=1;
      {{- else }}
      server {{ $.Release.Name }}-{{ $key_in }}.{{ $.Release.Name }}-headless:8111 backup;
      {{- end }}
      {{- end }}
    }
    {{- end }}

    upstream web_requests {
      {{- range $key, $value := $.Values.teamcity.nodes }}
      {{- if eq $value.env.NODE_ID $.Values.proxy.main_node_id }}
      server {{ $.Release.Name }}-{{ $key }}.{{ $.Release.Name }}-headless:8111 max_fails=1;
      {{- else }}
      server {{ $.Release.Name }}-{{ $key }}.{{ $.Release.Name }}-headless:8111 backup;
      {{- end }}
      {{- end }}
    }

    map $http_cookie $backend_cookie {
        default "{{ $.Values.proxy.main_node_id }}";
        "~*X-TeamCity-Node-Id-Cookie=(?<node_name>[^;]+)" $node_name;
    }

    map $http_user_agent $is_agent {
        default @users;
        "~*TeamCity Agent*" @agents;
    }

    map $http_upgrade $connection_upgrade { # WebSocket support
      default upgrade;
      '' '';
    }

    proxy_read_timeout     1200;
    proxy_connect_timeout  240;
    client_max_body_size   0;    # maximum size of an HTTP request. 0 allows uploading large artifacts to TeamCity

    server {
      listen 80;

      set_real_ip_from 0.0.0.0/0;

      location / {
        try_files /dev/null $is_agent;
      }

      location @agents {
        proxy_pass http://$backend_cookie;
        proxy_next_upstream error timeout http_503 non_idempotent;
        proxy_intercept_errors on;
        proxy_pass_request_body on;
        proxy_set_header Host $host:$server_port;
        proxy_redirect off;
        proxy_set_header X-TeamCity-Proxy "type=nginx; version={{ $.Chart.AppVersion }}";
        proxy_set_header X-Forwarded-Host $http_host; # necessary for proper absolute redirects and TeamCity CSRF check
        # Use value from Ingress Nginx
        # proxy_set_header X-Forwarded-Proto $scheme;
        # proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Upgrade $http_upgrade; # WebSocket support
        proxy_set_header Connection $connection_upgrade; # WebSocket support
      }

      location @users {
        proxy_pass http://web_requests;
        proxy_next_upstream error timeout http_503 non_idempotent;
        proxy_intercept_errors on;
        proxy_pass_request_body on;
        proxy_set_header Host $host:$server_port;
        proxy_redirect off;
        proxy_set_header X-TeamCity-Proxy "type=nginx; version={{ $.Chart.AppVersion }}";
        proxy_set_header X-Forwarded-Host $http_host; # necessary for proper absolute redirects and TeamCity CSRF check
        # Use value from Ingress Nginx
        # proxy_set_header X-Forwarded-Proto $scheme;
        # proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Upgrade $http_upgrade; # WebSocket support
        proxy_set_header Connection $connection_upgrade; # WebSocket support
      }
    }
