// I tested twemproxy because I though there was a connection bottleneck in memcached

/*sidecars:
  - name: twemproxy
    image: eu.gcr.io/galaxy-registry/twemproxy:0.5.0
    imagePullPolicy: Always
    ports:
    - name: tcp
      containerPort: 21211
    volumeMounts:
    - name: twemproxy-config
      mountPath: /etc/nutcracker.conf
      subPath: nutcracker.conf
      

extraVolumes:
  - name: twemproxy-config
    configMap:
      name: twemproxy
      items:
        - key: nutcracker.conf  
          path: nutcracker.conf */

/*resource "kubernetes_config_map" "twemproxy" {
  metadata {
    name = "twemproxy"
    namespace = var.ign_namespace
  }

  data = {
    "nutcracker.conf" = <<EOF
alpha:
  listen: 0.0.0.0:21211
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  server_retry_timeout: 2000
  server_failure_limit: 1
  server_connections: 1000
  tcpkeepalive: false
  backlog: 60000
  client_connections: 60000
  servers:
   - 127.0.0.1:11211:1

EOF
  }

}


resource "kubernetes_service" "twemproxy" {
  metadata {
    name = "twemproxy"
    namespace = var.ign_namespace
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "memcached"
    }
    port {
      port        = 21211
      target_port = 21211
    }

  }
}*/