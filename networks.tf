# Make private network

resource "yandex_vpc_network" "course-network" {
  name = "course-network"
}

# Make external and internal networks

resource "yandex_vpc_subnet" "external-subnet" {
  name           = "external-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.course-network.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_subnet" "internal-subnet-1" {
  name           = "internal-subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.course-network.id
  v4_cidr_blocks = ["10.20.0.0/24"]
  route_table_id = yandex_vpc_route_table.instance-route.id
}


resource "yandex_vpc_subnet" "internal-subnet-2" {
  name           = "internal-subnet-2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.course-network.id
  v4_cidr_blocks = ["10.30.0.0/24"]
  route_table_id = yandex_vpc_route_table.instance-route.id
}


# Make group bastion-external-security

resource "yandex_vpc_security_group" "bastion-external-security" {
  name        = "bastion-external-security"
  description = "Public Group Bastion"
  network_id  = yandex_vpc_network.course-network.id

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

# Make NAT gateway

resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id = local.folder_id
  name = "course-gateway"
  shared_egress_gateway {}
}

# Make Routing

resource "yandex_vpc_route_table" "instance-route" {
  name       = "instance-route"
  network_id = yandex_vpc_network.course-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

