resource "proxmox_virtual_environment_vm" "vanilla_vm" {
  count     = 8
  name      = var.vm_configurations[count.index].name
  vm_id     = var.vm_configurations[count.index].vm_id
  node_name = "VN-PMX2VRND-UP"
  description = "Made By Terraform"
  started      = true
  clone {
    vm_id = "1000"
    full  = true
    retries = "10"
  }

  cpu {
    type  = "kvm64"
    cores = var.vm_configurations[count.index].cores
    sockets = 1
  }

  memory {
    dedicated = var.vm_configurations[count.index].memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  disk {
    interface    = "scsi0"
    size         = var.vm_configurations[count.index].disk_size_gb
    datastore_id = "azril"
  }

  initialization {
    user_account {
      username = "devops"
      keys = [file("~/.ssh/id_rsa.pub")]
    }

    ip_config {
      ipv4 {
        address = "10.254.216.${110 + count.index}/24"
        gateway = "10.254.216.254"
      }
    }

    dns {
      servers = [
        "103.106.82.160",
        "103.106.82.161",
        "1.1.1.1"
        ]
    }
  }
}

resource "null_resource" "wait_for_cloud_init" {
  count = 8
  depends_on = [proxmox_virtual_environment_vm.vanilla_vm]

  connection {
    type     = "ssh"
    user     = "devops"
    host     = "10.254.216.${110 + count.index}"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 5; done",
      "echo 'Cloud-init done!'"
    ]
  }
}

resource "null_resource" "run_ansible_ssh_copy" {
  depends_on = [null_resource.wait_for_cloud_init]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible-ssh-copy/hosts/hosts ./ansible-ssh-copy/main.yaml"
  }
}

resource "null_resource" "run_ansible_haproxy_keepalived" {
  depends_on = [null_resource.run_ansible_ssh_copy]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible-haproxy-keepalived/hosts/hosts ./ansible-haproxy-keepalived/main.yaml -u devops"
  }
}

resource "null_resource" "run_ansible_kubeadm" {
  depends_on = [null_resource.run_ansible_haproxy_keepalived]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./ansible-kubeadm/hosts/hosts ./ansible-kubeadm/main.yaml -u devops"
  }
}
