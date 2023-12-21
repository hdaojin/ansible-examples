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

- Install necessary packages for system configuration
- Replace apt source to "YOUR_MIRROR" in `files/apt.sources.list`
- Set hostname with `hostname` variable in inventory file
- Set timezone with `timezone` variable in inventory file




## Usage

```bash
ansible-playbook -i inventories/development-inventory.yml ansible-initialization.yml -k -K
```

```bash
ansible-playbook -i inventories/development-inventory.yml system-initialization.yml -K
```