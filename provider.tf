provider "google" {
    project = "cgguspojxpcrvvzf"
#   project = data.terraform_remote_state.vpc.outputs.project_id
  region  = var.asg["region"]
}