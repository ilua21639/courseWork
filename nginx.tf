# Make group security L7

resource "yandex_vpc_security_group" "balancer-security" {
  name        = "balancer-security"
  description = "Balancer"
  network_id  = "enpceikb5micfu89mqnu"

  ingress {
    protocol       = "ANY"
    description    = "Allow 80"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
 
   ingress {
    protocol       = "TCP"
    description    = "Health"
	predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    description    = "All"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Make nginx-1

resource "yandex_compute_instance" "nginx-1" {
  name = "nginx-1"
  hostname = "nginx-1"
  zone = "ru-central1-a"
  
  resources{
    cores = 2
    core_fraction = 20
    memory = 1
  }

  boot_disk{
    initialize_params {
      image_id = "fhmu96c2ma8brvvnkq1j"
      size = 10
    }
  }
  network_interface {
    subnet_id = "e9bdetfeqjc0o3pmsuk1"
  }
  
  metadata = {
    user-data = "${file("/home/ilua/cloud-terraform/metadata.yml")}"
  }

  allow_stopping_for_update = true

}

# Make nginx-2
resource "yandex_compute_instance" "nginx-2" {
  name = "nginx-2"
  hostname = "nginx-2"
  zone = "ru-central1-b"
  
  resources{
    cores = 2
    core_fraction = 20
    memory = 1
  }

  boot_disk{
    initialize_params {
      image_id = "fhmu96c2ma8brvvnkq1j"
      size = 10
    }
  }
  network_interface {
    subnet_id = "e2l6071nlg6d78ulul3n"
  }
  
  metadata = {
    user-data = "${file("/home/ilua/cloud-terraform/metadata.yml")}"
  }

  allow_stopping_for_update = true

}

# Make target group

resource "yandex_alb_target_group" "target-group" {
  name = "target-group"

  target {
    subnet_id = "e9bdetfeqjc0o3pmsuk1"
    ip_address = yandex_compute_instance.nginx-1.network_interface.0.ip_address
  }

  target {
    subnet_id = "e2l6071nlg6d78ulul3n"
    ip_address = yandex_compute_instance.nginx-2.network_interface.0.ip_address
  }
}

# Make backend group

resource "yandex_alb_backend_group" "backend-group" {
  name                     = "backend-group"
  http_backend {
    name                   = "backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.target-group.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

# Make HTTP router

resource "yandex_alb_http_router" "http-router" {
  name          = "http-router"
  labels        = {
    tf-label    = "http-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "my-virtual-host"
  http_router_id          = yandex_alb_http_router.http-router.id
  route {
    name                  = "way"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.backend-group.id
        timeout           = "60s"
      }
    }
  }
}    

# Make L7 load balancer

resource "yandex_alb_load_balancer" "balancer" {
  name        = "balancer"
  network_id  = "enpceikb5micfu89mqnu"
  security_group_ids = [yandex_vpc_security_group.balancer-security.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "e9bqkjo0h5v7mbmsetcn"
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}

