# Initialize Linux System using Ansible

These playbooks are used to initialize a Linux system for ansible connection and basic system configuration.  

## Requirements

- Debian 12
- Ansible 2.14

## Features

**ansible-initialization.yml**

- Install necessary packages for ansible connection
- Generate and transfer ssh key for ansible connection
- Add ansible user and grant sudo permission

**system-initialization.yml**

- Replace apt source to "YOUR_MIRROR" in `files/apt.sources.list`
- Upgrade system and install necessary packages for system configuration
- Set `ssh_port`, `hostname`, `locale`, `timezone`, `ntp_servers` that defined in inventory file
- Configure sshd to disable root login and UseDNS
- Configure sshd to only allow specific user(ansible_user) to login
- Enable iptables to block all incoming traffic except ssh(finite) and ping

## Usage

```bash
ansible-playbook -i inventories/development-inventory.yml ansible-initialization.yml -k -K
```

```bash
ansible-playbook -i inventories/development-inventory.yml system-initialization.yml -K
```