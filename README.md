# HomeServeMate

## Overview

HomeServeMate is a comprehensive home server automation solution designed to simplify the deployment and management of various essential services within your home network.
With HomeServeMate, you can effortlessly transform your home server into a versatile hub for media streaming, local DNS management, ad blocking, and home automation. 
This project empowers you to enjoy your digital content, secure your network, enhance your browsing experience, and automate tasks throughout your smart home, all with an emphasis on customization and ease of use.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Features

- Media Streaming: Easily set up and manage media streaming services for your home server.
- Local DNS: Configure a local DNS server to manage your home network.
- Ad Blocking: Block ads at the DNS level to enhance your browsing experience.
- Home Automation: Automate tasks and manage smart home devices through this server.

## Prerequisites

Before you get started with this automation tool, make sure you have the following prerequisites:

- Client and server machines. This works best if you run the playbooks, for example, on your laptop against a remote server. Running the playbooks directly on the remote server might break the execution if the server needs to reboot when upgrading packages with apt.
- Client: (aka your laptop)
  - You need to have ansible installed. Check how to install it [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pipx)
  - Ensure the client can SSH to the server without password. This can be done by executing the following commands on your laptop if you are using MacOS or Linux:
    ```bash
    ssh-keygen
    ssh-copy-id username@remote_server
    ```
- Server:
  - OS: Ubuntu 22.04.3 LTS
  - Ensure that the SSH user does not require root password:
    ```bash
    echo 'YOUR_SSH_USERNAME ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/YOUR_SSH_USERNAME
    ```
- [Cloudflare account](https://dash.cloudflare.com/sign-up) In case you want to expose your services to the internet (optional)
- [Tailscale auth key](https://tailscale.com/kb/1085/auth-keys/#step-1-generate-an-auth-key) In case you want to deploy Tailscale

## Deploy HomeServeMate

To deploy and configure HomeServeMate using this automation tool, follow these steps:
1. Clone this repository to your server:
   ```bash
   git clone https://github.com/miguelcastilho/HomeServeMate.git
   ```
2. Change to project directory:
   ```bash
   cd HomeServeMate
   ```
2. Install ansible requirements:
   ```bash
   ansible-galaxy install -r requirements.yml
   ```
3. Create your own inventory file based on the [sample inventory](inventory/inventory.yml.example)

4. Execute the playbook:
   ```bash
   ansible-playbook -i inventory/<YOUR_INVENTORY>.yml install.yml
   ```

## Contributing
If you'd like to contribute to this project, please follow these steps:

1. Fork the repository.

2. Create a new branch for your feature or bug fix:

  ```bash
  git checkout -b feature/your-feature
  ```

3. Make your changes and commit them.

4. Push your changes to your fork:

  ```bash
    git push origin feature/your-feature
  ```

5. Create a pull request from your fork to this repository.

6. Wait for your changes to be reviewed and merged.


