# Make bastion server

resource "yandex_compute_instance" "bastion" {
  name     = "bastion"
  hostname = "bastion"
  zone     = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fhmu96c2ma8brvvnkq1j"
      size     = 10
    }
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.external-subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion-external-security.id]
  }
  
  metadata = {
    user-data = "${file("/home/ilua/cloud-terraform/metadata.yml")}"
  }

}

