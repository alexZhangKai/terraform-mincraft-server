resource "google_compute_instance" "mc-server" {
  project      = var.project_id
  name         = "tf-mc-server"
  machine_type = "e2-standard-2"
  zone         = var.default_zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20200317"
      size  = 10
      type  = "pd-ssd"
    }
  }

  attached_disk {
    source      = google_compute_disk.mc-data.self_link
    device_name = "mc-data"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.mc-server-static.address
    }
  }

  tags = ["mc-server"]

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<SCRIPT
  if [ ! -d /home/minecraft ]; then
    echo "installing minecraft server"
    sudo apt-get update -y
    sudo apt-get install -y \
      screen \
      default-jre-headless
    sudo mkdir -p /home/minecraft
    sudo mkfs.ext4 -F -E \ 
      lazy_itable_init=0, \
      lazy_journal_init=0, \
      discard /dev/disk/by-id/google-mc-data
    sudo mount -o discard, \
      defaults /dev/disk/by-id/google-mc-data /home/minecraft
    cd /home/minecraft
    sudo su
    wget https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar
    screen -d -m -S mcs java -Xms1G -Xmx3G -d64 -jar server.jar nogui
    while [ ! -f eula.txt ]; do sleep 1; done
    sed -i.bak "s/false/true/g" eula.txt
    screen -d -m -S mcs java -Xms1G -Xmx3G -d64 -jar server.jar nogui
    echo "minecraft server is now running"
  else 
    echo "restarting minecraft server"
    sudo mount /dev/disk/by-id/google-minecraft-disk /home/minecraft
    cd /home/minecraft
    screen -d -m -S mcs java -Xms1G -Xmx3G -d64 -jar server.jar nogui
  fi
  SCRIPT

  metadata = {
    shutdown-script = <<SCRIPT
    sudo su
    screen -r mcs -X stuff '/save-all\n/save-off\n'
    /usr/bin/gsutil cp -R /home/minecraft/world ${google_storage_bucket.mc-world-backup.url}/$(date "+%Y%m%d-%H%M%S")-world
    SCRIPT
  }
}

resource "google_compute_disk" "mc-data" {
  name                      = "tf-mc-data"
  type                      = "pd-ssd"
  zone                      = var.default_zone
  physical_block_size_bytes = 4096
}

resource "google_compute_address" "mc-server-static" {
  name   = "mc-server-static"
  region = var.default_region
}

resource "google_storage_bucket" "mc-world-backup" {
  name          = "mc-world-backup-asslex"
  location      = "EU"
  force_destroy = false
}
