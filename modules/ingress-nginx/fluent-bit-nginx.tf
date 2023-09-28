
data "template_file" "fluentbit" {
  template = <<EOF

nameOverride: fluentbit-ingress-nginx
kind: Deployment
replicaCount: 3

envFrom:
- secretRef:
    name: fluent-bit-nginx

extraPorts:
  - port: 24224
    containerPort: 24224
    protocol: TCP
    name: tcp

resources:
  requests:
    cpu: 10m
    memory: 64Mi
    
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/instance: fluentbit-ingress-nginx
          topologyKey: kubernetes.io/hostname  


hostAliases:
  - ip: "${var.traefik_svc_clusertip}"
    hostnames:
    - "ch-logs.ch-logs.${var.cluster_name}.internal.galaxykube.com"

config:
  service: |
    [SERVICE]
        Flush             5
        Daemon            Off
        Log_Level         info
        HTTP_Server       On
        HTTP_Listen       0.0.0.0
        HTTP_Port         {{ .Values.metricsPort }}
        Health_Check      On
        Parsers_File      /fluent-bit/etc/conf/custom_parsers.conf


  inputs: |
    [INPUT]
        Name              forward
        Listen            0.0.0.0
        Port              24224
        Buffer_Chunk_Size 1M
        Buffer_Max_Size   6M
        Tag               ingress-nginx

  filters: |
    [FILTER]
        Name                parser
        Match               ingress-nginx
        Key_Name            log
        Parser              ingress_nginx_parser
        Preserve_Key        False
        Reserve_Data        True

    [FILTER]
        Name                rewrite_tag
        Match               ingress-nginx
        Rule                $status ^(.+)$  ingress-nginx.http false

    #drop unecessary fields 
    [FILTER]
        Name                modify
        Match               *
        Remove              pod
    [FILTER]
        Name                modify
        Match               *
        Remove              container
    [FILTER]
        Name                modify
        Match               *
        Remove              time
    [FILTER]
        Name                modify
        Match               *
        Remove              app
    [FILTER]
        Name                modify
        Match               *
        Remove              namespace

    [FILTER]
        Name                modify
        Match               ingress-nginx.http
        Remove              time_local
    [FILTER]
        Name                modify
        Match               ingress-nginx.http
        Remove              req_id

    #set int default value for upstream_response_length_bytes 
    [FILTER]
        Name                modify
        Match               ingress-nginx.http
        Condition           Key_value_equals upstream_response_length_bytes -
        Set                 upstream_response_length_bytes 0
    #set int default value for upstream_status 
    [FILTER]
        Name                modify
        Match               ingress-nginx.http
        Condition           Key_value_equals upstream_status -
        Set                 upstream_status 0


    #rename log to message
    [FILTER]
        Name                modify
        Match               ingress-nginx
        Rename              log message

    #set log_type=HTTP_REQUEST when it comes to http logs
    [FILTER]
        Name                modify
        Match               ingress-nginx.http
        Add                 log_type HTTP_REQUEST

    #rename _p to logtag to maintain table schema
    [FILTER]
        Name                modify
        Match               *
        Rename              _p logtag

  outputs: |
    #[OUTPUT]
    #    Name              stdout
    #    Match             *

    [OUTPUT]
        name              http
        match             *
        host              ch-logs.ch-logs.${var.cluster_name}.internal.galaxykube.com
        tls               off
        port              80
        http_user         fluentbit
        #double $ to escape both terraform and helm templates
        http_passwd       $$${FLUENTBIT_CH_PASSWORD}
        URI               /?query=INSERT+INTO+logs.ingress_nginx+FORMAT+JSONEachRow
        format            json_stream
        json_date_key     date
        json_date_format  java_sql_timestamp

  customParsers: |
    [PARSER]
        # https://rubular.com/r/M5msGeKfGrYnAW
        Name        ingress_nginx_parser
        Format      regex
        Regex       ^\[(?<time_local>[^\]]*)\] (?<remote_addr_ipv6>[^ ]*) (?<host>[^ ]*) "(?<method>[^ ]*) (?<path>[^ ]*) (?<version>[^ ]*) (?<status>[^ ]*) (?<request_time_sec>[^ ]*) (?<request_length_bytes>[^ ]*)" (?<http_referer>[^ ]*) (?<http_user_agent>[^"]*) (?<body_bytes_sent>[^ ]*) \[(?<ingress_name>[^\]]*)\] \[(?<proxy_upstream_name>[^\]]*)\] (?<upstream_response_length_bytes>[^ ]*) (?<upstream_response_time_sec>[^ ]*) (?<upstream_status>[^ ]*) (?<req_id>[^ ]*)$

        
EOF

}


resource "helm_release" "fluentbit" {
  name       = "fluentbit-ingress-nginx"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.43.0"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  # Default values
  # https://github.com/fluent/helm-charts/blob/fluent-bit-0.43.0/charts/fluent-bit/values.yaml
  values      = [data.template_file.fluentbit.rendered]
  max_history = 10


}
