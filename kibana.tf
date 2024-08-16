# make security_group for kibana

resource "yandex_vpc_security_group" "kibana-security" {
  name        = "kibana-security"
  description = "Public Group kibana"
  network_id  = "enpceikb5micfu89mqnu"

  ingress {
    protocol       = "ANY"
    description    = "Allow 5601"
    v4_cidr_blocks = ["0.0.0.0/0"]
	port           = 5601
  }

  ingress {
    protocol       = "ANY"
    description    = "Allow 22"
    v4_cidr_blocks = ["0.0.0.0/0"]
	port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "All"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# Make resource for kibana

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  hostname = "kibana"
  zone = "ru-central1-a"
  
  resources{
    cores = 2
    core_fraction = 20
    memory = 6
  }

  boot_disk{
    initialize_params {
      image_id = "fhmu96c2ma8brvvnkq1j"
      size = 10
    }
  }
  network_interface {
    subnet_id = "e9bqkjo0h5v7mbmsetcn"
	nat = true
	security_group_ids = [yandex_vpc_security_group.kibana-security.id]
  }
  
  metadata = {
    user-data = "${file("/home/ilua/cloud-terraform/metadata.yml")}"
  }
}

