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

- **Client and Server Machines**: This works best if you run the playbooks, for example, on your laptop against a remote server. Running the playbooks directly on the remote server might break the execution if the server needs to reboot when upgrading packages with apt.
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

The following steps should be executed in your client machine (aka your laptop):
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
3. Adapt the [inventory](inventory/inventory.yml) file based on your environment.  
   Description of the variables can be found in the [table below](#configuration-variables).

4. Execute the playbook:
   ```bash
   ansible-playbook -i inventory/inventory.yml install.yml
   ```

## Configuration Variables

| Variable                    | Requirement                    | Description                                       | Default Value              |
|-----------------------------|--------------------------------|---------------------------------------------------|----------------------------|
| `domain`                    | Required                       | Internet domain for your server.                | example.com                |
| `email`                     | Required                       | Email address for Let's Encrypt certificates.   | user@example.com           |
| `timezone`                  | Required                       | Timezone.                                        | Europe/Amsterdam           |
| `data_path`                 | Required                       | Path to persistent storage for configs, DBs, and logs (e.g., /mediabox). | /mediabox |
| `media_path`                | Required                       | Path to media storage.                           | /media/storage            |
| `install_adguard_home`      | Required                       | Set to `true` to install Adguard Home.          | true                      |
| `adguard_home_username`     | Required (if install_adguard_home=true)  | Adguard Home username.             | myusername                |
| `adguard_home_password`     | Required (if install_adguard_home=true)  | Adguard Home password.             | mysecretpassword           |
| `adguard_home_rewrites`   | Required (if install_adguard_home=true)  | DNS resolution. | |
| `install_cloudflared`       | Required                       | Set to `true` to install Cloudflared.           | true                      |
| `cloudflare_api_token`      | Required (if install_cloudflared=true)                      | Cloudflare API token.                            | YOUR_CLOUDFLARE_API_TOKEN |
| `cloudflare_tunnel_name`    | Required (if install_cloudflared=true)                      | Name of the Cloudflared tunnel.                 | my-tunnel                 |
| `cloudflare_tunnel_dns_list`| Required (if install_cloudflared=true)                      | List of services deployed on k3s to expose to the internet. | [ {"name": "service1", "port": 8080}, {"name": "service2", "port": 9000} ] |
| `cloudflared_pem`           | Required (if install_cloudflared=true)                      | Cloudflared PEM file content.                   | -----BEGIN CERTIFICATE-----\n...  |
| `tailscale_auth_key`        | Required                       | Tailscale authentication key.                   | my-tailscale-auth-key     |
| `zigbee_adapter_path`       | Required                       | Specify the connection to the Zigbee adapter.  | /dev/ttyUSB0              |
| `enable_services`           | Required                       | List of services to enable.                     | [ "duplicati", "mqtt", "homeassistant" ] |


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


