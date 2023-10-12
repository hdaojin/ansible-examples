# Ansible Modules

collecting ansible commonly used modules.

## Setting up the system environment

These modules are used for setting up the system environment.

### hostname

```yaml
- name: Set hostname
  ansible.builtin.hostname:
    name: "{{ hostname }}"
    use: debian
```

### timezone

```yaml
- name: Set timezone
  ansible.general.timezone:
    name: Asia/Shanghai
```

### locale

```yaml
- name: Set locale
  ansible.posix.locale_gen:
    name: zh_CN.UTF-8
    state: present
```

### apt

```yaml
- name: install packages
  ansible.builtin.apt:
    update_cache: False
    pkg:
      - vim
      - bash-completion
      - curl
      - wget
```

## Mofiying configure files

These modules are used for modifying files.

### lineinfile

```yaml
- name: change a single line in a file only.
  ansible.builtin.lineinfile:
    path: /etc/hosts
    regexp: '^127\.0\.1\.1'
    line: 127.0.1.1  "{{ hostname }}"
```

### replace

```yaml
- name: replace all instances of a pattern within a file.
  ansible.builtin.replace:
    path: /etc/apache2/sites-aviailable/000-default.conf
    after: '<VirtualHost *:80>'
    regexp: '^(.+)$'
    replace: '# \1'
```

### blockinfile

```yaml
 - name: insert/update/remove a block of multi-line text surrounded by customizable marker lines.
   ansible.builtin.blockinfile:
     path: /etc/ssh/sshd_config
     block: |   
        PermitRootLogin no
        AllowUsers demo
```

### copy
  
```yaml
- name: copy a file to a remote location
  ansible.builtin.copy:
    src: files/sshd_config
    dest: /etc/ssh/sshd_config
```

### template

```yaml
- name: template a file to a remote location
  ansible.builtin.template:
    src: templates/sshd_config.j2
    dest: /etc/ssh/sshd_config
```

## execute commands or scripts

These modules are used for executing commands or scripts on remote hosts.

### command

```yaml
- name: run a command on remote hosts.
  ansible.builtin.command:
    cmd: echo "hello world"
```

### shell

```yaml
- name: run a command on remote hosts.
  ansible.builtin.shell:
    cmd: echo "hello world"
```

### script

```yaml
# This module does not require python on the remote system, much like the ansible.builtin.raw module.
- name: run a local script on a remote node after transferring it
  ansible.builtin.script:
    script: /usr/local/bin/myscript.py
```

### raw

```yaml
- name: run a raw command
  ansible.builtin.raw:
    cmd: echo "hello world"
```
