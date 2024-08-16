# make backup

resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"

  schedule_policy {
    expression = "0 1 * * *"
  }

  snapshot_count = 7
  snapshot_spec {
      description = "Daily snapshot"
 }

  retention_period = "168h"

  disk_ids = ["fhm9ebnd17bu69h7br8o", 
             "fhmkacto8aib5nj2ogp7"]
}

