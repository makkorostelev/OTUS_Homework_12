
resource "yandex_vpc_address" "custom_addr" {
  name = "exampleAddress"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}


resource "yandex_kubernetes_cluster" "zonal_cluster_resource_name" {
  name        = "name"
  description = "description"

  network_id = yandex_vpc_network.custom_vpc.id

  master {
    version = "1.28"
    zonal {
      zone      = yandex_vpc_subnet.custom_subnet.zone
      subnet_id = yandex_vpc_subnet.custom_subnet.id
    }

    public_ip = true

    security_group_ids = ["${yandex_vpc_security_group.custom_sg.id}"]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }

    master_logging {
      enabled                    = true
      log_group_id               = yandex_logging_group.custom_logging.id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }
  }

  service_account_id      = yandex_iam_service_account.custom_sa.id
  node_service_account_id = yandex_iam_service_account.custom_sa.id

  labels = {
    my_key       = "my_value"
    my_other_key = "my_other_value"
  }

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

}

resource "yandex_kubernetes_node_group" "custom_kubernetes_node_group" {
  cluster_id = yandex_kubernetes_cluster.zonal_cluster_resource_name.id
  name       = "custom-node-group"
  instance_template {
    name                      = "project-{instance.short_id}"
    platform_id               = "standard-v2"
    network_acceleration_type = "standard"
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.custom_subnet.id}"]
    }
    resources {
      memory = 16
      cores  = 8
    }
    boot_disk {
      type = "network-hdd"
      size = 64
    }
    container_runtime {
      type = "containerd"
    }

  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }
}








resource "yandex_vpc_network" "custom_vpc" {
  name = "custom_vpc"

}
resource "yandex_vpc_subnet" "custom_subnet" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.custom_vpc.id
  v4_cidr_blocks = ["10.5.0.0/24"]
  #route_table_id = yandex_vpc_route_table.custom_nat_route_table.id
}



resource "yandex_vpc_security_group" "custom_sg" {
  name        = "WebServer security group"
  description = "My Security group"
  network_id  = yandex_vpc_network.custom_vpc.id

  dynamic "ingress" {
    for_each = ["80", "443", "22", "3306", "33060", "4567", "4444", "4568", "6032", "6033", "9200", "9300", "5601", "9250", "9600", "24224", "9092", "2181", "2888", "3888"]
    content {
      protocol       = "TCP"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = ingress.value
    }
  }

  egress {
    protocol       = "ANY"
    description    = "Outcoming traf"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = -1
  }
}

resource "yandex_logging_group" "custom_logging" {
  name             = "custom-logging"
  retention_period = "5h"
}

resource "yandex_iam_service_account" "custom_sa" {
  folder_id   = var.folder_id_variable
  name        = "sa-k8s-admin"
  description = "this is k8s admin service account"
}

resource "yandex_resourcemanager_folder_iam_member" "custom_sa_permissions" {
  folder_id = var.folder_id_variable
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.custom_sa.id}"
}

resource "terraform_data" "run_ansible" {
  depends_on = [yandex_kubernetes_node_group.custom_kubernetes_node_group]
  provisioner "local-exec" {
    command = <<EOF
    yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.zonal_cluster_resource_name.id} --external --force
    kubectl apply -k ./
    EOF
  }
}
