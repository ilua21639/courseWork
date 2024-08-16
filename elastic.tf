# Make security group for elastic

resource "yandex_vpc_security_group" "elastic-security" {
  name        = "elastic-security"
  description = "Public Group elastic"
  network_id  = "enp1divc0jutm0oboukd"

  ingress {
    protocol       = "ANY"
    description    = "Allow 9200"
    v4_cidr_blocks = ["0.0.0.0/0"]
	port           = 9200
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

# Make resource for elasticsearch

resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"
  hostname = "elasticsearch"
  zone = "ru-central1-a"
  
  resources{
    cores = 2
    core_fraction = 20
    memory = 4
  }

  boot_disk{
    initialize_params {
      image_id = "fhmu96c2ma8brvvnkq1j"
      size = 10
    }
  }
  network_interface {
    subnet_id = "e9bdetfeqjc0o3pmsuk1"
	security_group_ids = [yandex_vpc_security_group.elastic-security.id]
  }
  
  metadata = {
    user-data = "${file("/home/ilua/cloud-terraform/metadata.yml")}"
  }

  allow_stopping_for_update = true

}

