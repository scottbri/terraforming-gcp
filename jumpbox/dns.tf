resource "google_dns_record_set" "jumpbox-dns" {
  count = "${var.count}"

  name = "jumpbox.${var.env_name}.${var.dns_suffix}."
  type = "A"
  ttl  = 300

  managed_zone = "${var.pcf_managed_zone_name}"
  rrdatas      = ["${google_compute_instance.jumpbox.network_interface.0.access_config.0.assigned_nat_ip}"]
}
