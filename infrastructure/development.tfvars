environment     = "development"
azure_tenant_id = ""

node_machine_type = "n1-standard-4"
node_disk_size    = 100

non_preemptible_nodes_autoscale_min = 1
non_preemptible_nodes_autoscale_max = 2

preemptible_nodes_autoscale_min = 1
preemptible_nodes_autoscale_max = 3

k8s_release_channel = "STABLE"
