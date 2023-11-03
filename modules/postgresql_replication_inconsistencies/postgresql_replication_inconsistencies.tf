resource "shoreline_notebook" "postgresql_replication_inconsistencies" {
  name       = "postgresql_replication_inconsistencies"
  data       = file("${path.module}/data/postgresql_replication_inconsistencies.json")
  depends_on = [shoreline_action.invoke_db_connectivity_check,shoreline_action.invoke_replication_reset]
}

resource "shoreline_file" "db_connectivity_check" {
  name             = "db_connectivity_check"
  input_file       = "${path.module}/data/db_connectivity_check.sh"
  md5              = filemd5("${path.module}/data/db_connectivity_check.sh")
  description      = "Network latency or connectivity issues between the primary database and its replicas can cause replication delays, leading to inconsistencies in the data."
  destination_path = "/tmp/db_connectivity_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "replication_reset" {
  name             = "replication_reset"
  input_file       = "${path.module}/data/replication_reset.sh"
  md5              = filemd5("${path.module}/data/replication_reset.sh")
  description      = "If replication inconsistencies persist, consider using a tool like pg_rewind to reset the replicas to match the primary database. This can be a more efficient way to reset the replicas than rebuilding them from scratch."
  destination_path = "/tmp/replication_reset.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_db_connectivity_check" {
  name        = "invoke_db_connectivity_check"
  description = "Network latency or connectivity issues between the primary database and its replicas can cause replication delays, leading to inconsistencies in the data."
  command     = "`chmod +x /tmp/db_connectivity_check.sh && /tmp/db_connectivity_check.sh`"
  params      = ["PRIMARY_DB_ADDRESS","REPLICA_DB_ADDRESS"]
  file_deps   = ["db_connectivity_check"]
  enabled     = true
  depends_on  = [shoreline_file.db_connectivity_check]
}

resource "shoreline_action" "invoke_replication_reset" {
  name        = "invoke_replication_reset"
  description = "If replication inconsistencies persist, consider using a tool like pg_rewind to reset the replicas to match the primary database. This can be a more efficient way to reset the replicas than rebuilding them from scratch."
  command     = "`chmod +x /tmp/replication_reset.sh && /tmp/replication_reset.sh`"
  params      = ["PRIMARY_DB_HOST","POSTGRES_DATA_DIRECTORY","REPLICATION_USER","REPLICA_DB_HOST","PG_REWIND_PATH"]
  file_deps   = ["replication_reset"]
  enabled     = true
  depends_on  = [shoreline_file.replication_reset]
}

