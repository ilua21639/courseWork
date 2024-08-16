terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.123.0"
    }
  }
}

locals {
    folder_id = "b1g86pqno23gnm0avq65"
    cloud_id = "b1g86pqno23gnm0avq65"
}

provider "yandex" {
    cloud_id = local.cloud_id
    folder_id = local.folder_id
    service_account_key_file = "/home/ilua/cloud-terraform/key.json"
}

