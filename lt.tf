resource "google_compute_address" "static" {
  name = var.asg["static_name"]
}
# This block of code builds instance template(launch template)
resource "google_compute_instance_template" "launch_template" {
  name                    = var.asg["instance_template_name"]
  machine_type            = var.asg["machine_type"]
  can_ip_forward          = false
  metadata_startup_script = file("userdata.sh") 
# To install & start a web server on the instances
  metadata = {
    ssh-keys = "centos7:${file("~/.ssh/id_rsa.pub")}"
  }
  disk {
    source_image = var.asg["source_image"]
  }
  network_interface {
      network = "vpc"
    # network = data.terraform_remote_state.vpc.outputs.vpc_name
     access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}
# This block of code builds firewall for the instances
resource "google_compute_firewall" "wordpress" {
  name    = var.asg["firewall_name"]
  network = "vpc"
#   network = data.terraform_remote_state.vpc.outputs.vpc_name
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }
#   source_tags   = [var.asg_config["network_tags"]]
  source_ranges = ["0.0.0.0/0"]
}
