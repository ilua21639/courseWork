listen {
  port = 4040
  address = "0.0.0.0"
}

consul {
  enable = false
}

namespace "nginx" {
  source_files = [
    "/var/log/nginx/access.log",
    "/var/log/nginx/error.log"
  ]
  format = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" \"$http_x_forwarded_for\""
  
  labels {
    service = "nginx"
  }
  
  histogram_buckets = [.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10]
}

