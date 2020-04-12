resource "google_compute_network" "mc-network" {
  name                    = "mc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mc-subnet" {
  name          = "mc-subnet"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.mc-network.self_link
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.mc-network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mc-server"]
}

resource "google_compute_firewall" "allow-mc-connection" {
  name    = "allow-mc-connection"
  network = google_compute_network.mc-network.name

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mc-server"]
}
