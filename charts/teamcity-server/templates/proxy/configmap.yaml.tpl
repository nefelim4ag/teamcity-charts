---
kind: ConfigMap
apiVersion: v1
metadata:
  name: {{ $.Release.Name }}-haproxy-cfg
data:
  haproxy.cfg: |
    defaults
        mode http
        timeout connect 240s
        timeout client 1200s
        timeout server 1200s

    frontend stats-in
        bind *:8080

        stats enable
        stats uri /

    frontend http-in
        bind *:80

        default_backend web_endpoint
        option httplog
        log stdout local0  info

        option http-buffer-request
        declare capture request len 40000000
        http-request capture req.body id 0
        capture request header user-agent len 150
        capture request header Host len 15

        capture cookie X-TeamCity-Node-Id-Cookie= len 100

        http-request add-header X-TeamCity-Proxy "type=haproxy; version={{ $.Chart.AppVersion }}"
        http-request set-header X-Forwarded-Host %[req.hdr(Host)]

        acl node_id_cookie_found req.cook(X-TeamCity-Node-Id-Cookie) -m found
        acl browser req.hdr(User-Agent) -m sub Mozilla

        default_backend clients_not_supporting_cookies
        use_backend clients_with_node_id_cookie if node_id_cookie_found
        use_backend clients_supporting_cookies if browser

    backend clients_with_node_id_cookie
        # this backend handles the clients that provided the "X-TeamCity-Node-Id-Cookie" cookie
        # clients that do so are TeamCity agents and browsers handling HTTP requests asking to switch to a specific node
        cookie X-TeamCity-Node-Id-Cookie

        http-request disable-l7-retry if METH_POST METH_PUT METH_DELETE
        retry-on empty-response conn-failure response-timeout 502 503 504
        retries 5

        option httpchk GET /healthCheck/ready

        default-server check fall 6 inter 10000 downinter 5000

        {{- range $index, $value := $.Values.teamcity.nodes }}
        {{- if and ($value.env) ($value.env.NODE_ID) }}
        server {{ $.Release.Name }}-{{ $index }} {{ $.Release.Name }}-direct-{{ $index }}:8111 cookie {{ $value.env.NODE_ID }}
        {{- else }}
        server {{ $.Release.Name }}-{{ $index }} {{ $.Release.Name }}-direct-{{ $index }}:8111 cookie {{ $.Release.Name }}-{{ $index }}
        {{- end }}
        {{- end }}

    backend clients_supporting_cookies
        # this backend is for the browsers without "X-TeamCity-Node-Id-Cookie"
        # these requests will be served in a round-robin manner to a healthy server
        balance roundrobin
        option redispatch
        cookie TCSESSIONID prefix nocache

        http-request disable-l7-retry if METH_POST METH_PUT METH_DELETE

        option httpchk

        http-check connect
        http-check send meth GET uri /healthCheck/preferredNodeStatus
        http-check expect status 200

        default-server check fall 6 inter 10000 downinter 5000 on-marked-down shutdown-sessions

        {{- range $index, $value := $.Values.teamcity.nodes }}
        server {{ $.Release.Name }}-{{ $index }} {{ $.Release.Name }}-direct-{{ $index }}:8111 cookie n1 weight 50
        {{- end }}

    backend clients_not_supporting_cookies
        # for compatibiity reasons requests from non browser clients are always
        # routed to a single node (the first healthy)
        balance first
        option redispatch

        http-request disable-l7-retry if METH_POST METH_PUT METH_DELETE

        option httpchk

        http-check connect
        http-check send meth GET uri /healthCheck/preferredNodeStatus
        http-check expect status 200

        default-server check fall 6 inter 10000 downinter 5000 on-marked-down shutdown-sessions

        {{- range $index, $value := $.Values.teamcity.nodes }}
        server {{ $.Release.Name }}-{{ $index }} {{ $.Release.Name }}-direct-{{ $index }}:8111
        {{- end }}
