#!/bin/bash

# Variables
SERVER_IP="192.168.1.99"
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMAGE_NAME="noble-server-cloudimg-amd64.img"
VM_ID=9000

ssh root@$SERVER_IP << EOF
    set -e  # Exit immediately if a command exits with a non-zero status

    # Cleanup old image and VM
    rm -f $IMAGE_NAME
    qm destroy $VM_ID || true  # Ignore error if VM doesn't exist

    # Download new image
    wget $IMAGE_URL

    # Update package manager and install guestfs-tools
    apt update && apt install -y guestfs-tools

    # Customize the image
    virt-customize -a $IMAGE_NAME --install qemu-guest-agent \
      --run-command 'systemctl start qemu-guest-agent.service && systemctl enable qemu-guest-agent.service'
    virt-customize -a $IMAGE_NAME --truncate /etc/machine-id

    # Create and configure the VM
    qm create $VM_ID --name ubuntu-noble-server-cloud --memory 2048 --core 1 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
    qm importdisk $VM_ID $IMAGE_NAME local-lvm
    qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$VM_ID-disk-0
    qm set $VM_ID --ide2 local-lvm:cloudinit
    qm set $VM_ID --boot c --bootdisk scsi0
    qm set $VM_ID --serial0 socket --vga serial0
    qm set $VM_ID --agent enabled=1
    qm template $VM_ID

    # Cleanup
    rm -f $IMAGE_NAME
EOF