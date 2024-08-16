# Make Prometheus server

resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"
  hostname = "prometheus"
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

