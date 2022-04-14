data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = "bucket-backend1"
    prefix = "terraform/state/globalvpc"
  }
}
# output "vpc" {
#   value = data.terraform_remote_state.vpc.outputs.vpc_name
# }

resource "google_compute_target_pool" "target_pool" {
  region = var.asg["region"]
  name   = var.asg["target-pool-name"]
}

resource "google_compute_autoscaler" "asg" {
  zone = var.asg["zone"]
  name = var.asg["autoscaler"]
  target = google_compute_instance_group_manager.group_manager.id
  autoscaling_policy {
    max_replicas    = var.asg["max_replicas"]
    min_replicas    = var.asg["min_replicas"]
    cooldown_period = var.asg["cooldown_period"]
    cpu_utilization {
      target = var.asg["target"]
    }
  }
}
resource "google_compute_instance_group_manager" "group_manager" {
  zone = var.asg["zone"]
  name = var.asg["instance_group_manager_name"]
  version {
    instance_template = google_compute_instance_template.launch_template.id
    name              = "primary"
  }
  target_pools       = [google_compute_target_pool.target_pool.self_link]
  base_instance_name = var.asg["base_instance_name"]
}



