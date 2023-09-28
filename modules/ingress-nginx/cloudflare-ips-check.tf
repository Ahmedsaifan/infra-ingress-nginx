

resource "kubernetes_config_map" "cloudflare_script" {
  count = var.ign_run_cloudflare_ips_check ? 1 : 0

  metadata {
    name = "cloudflare-ips-check"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  data = {
    "script.py" = <<EOF

from urllib import request
from urllib.request import Request, urlopen

request_site = Request("https://www.cloudflare.com/ips-v4", headers={"User-Agent": "Mozilla/5.0"})

cloudflare_ips = urlopen(request_site).read().decode().strip().split("\n")

expected_ip_ranges = ["${join("\", \"", local.cloudflare_expected_ips)}"]

missing_ips = set(cloudflare_ips) - set(expected_ip_ranges)
extra_ips = set(expected_ip_ranges) - set(cloudflare_ips)

if missing_ips:
    print("The following Cloudflare IPs are missing from the expected IP ranges:")
    for ip in missing_ips:
        print(ip)
    print()
if extra_ips:
    print("The following IPs are not in the Cloudflare IP list:")
    for ip in extra_ips:
        print(ip)
    print()

if missing_ips or extra_ips:
    exit(1)
else:
    print("All Cloudflare IPs are included in the expected IP ranges, and all expected IP ranges are included in the Cloudflare IP list.")
    exit(0)

EOF


  }
}










resource "kubernetes_cron_job_v1" "cloudflare_cron" {
  count = var.ign_run_cloudflare_ips_check ? 1 : 0
  
  metadata {
    name = "cloudflare-ips-check"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = merge(var.shared_k8s_tags, {})
  }

  spec {
    schedule = "0 * * * *"
    successful_jobs_history_limit = 2
    failed_jobs_history_limit     = 2
    concurrency_policy = "Allow"


    job_template {
      metadata {}

      spec {
        template {
          metadata {}
          spec {

            container {
              name  = "cloudflare-ips-check"
              image = "python:3.9-alpine"

              command = ["python", "/app/script.py"]

              volume_mount {
                name      = "script-volume"
                mount_path = "/app"
              }
            }

            restart_policy = "OnFailure"

            volume {
              name = "script-volume"

              config_map {
                name = "cloudflare-ips-check"
              }
            }
          }
        }
      }
    }
  }
}