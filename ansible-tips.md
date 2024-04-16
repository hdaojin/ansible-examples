# Ansible tips and tricks

##　General tips

这些概念适用于所有的Ansible活动和工件。

### Keep it simple

尽可能简单地处理事情。

仅在必要时使用高级功能，并选择最符合您用例的功能。例如，您可能不需要同时使用vars，vars_files，vars_prompt和--extra-vars，同时还使用外部清单文件。

如果某些东西感觉复杂，那么它可能确实如此。花时间寻找更简单的解决方案。

### Use version control

将您的playbooks、roles、inventory和variables文件保存在git或其他版本控制系统中，并在进行更改时向存储库提交带有有意义的注释的提交。版本控制为您提供了一个审计跟踪，描述了您何时以及为什么更改了自动化基础设施的规则。

### Customize the CLI output

您可以使用回调插件([Callback plugins](https://docs.ansible.com/ansible/latest/plugins/callback.html#callback-plugins))更改 Ansible CLI 命令的输出。

## Playbook tips

这些技巧有助于使playbooks和roles更易于阅读、维护和调试。

### Use whitespace

慷慨使用空白，例如，在每个块或任务之前留一行空白，使得playbook易于扫描。

### Always name plays, tasks, and blocks

Play, task和block `- name`是可选的，但非常有用。在其输出中，Ansible向您显示运行的每个命名实体的名称。选择描述每个Play, task和block执行的操作及其原因的名称。

### Always mention the state

对于很多模块, `state`参数是可选的。

不同的模块具有不同的`state`默认设置，一些模块支持多个`state`设置。明确设置状`state：present`或`state：absent`可以使playbooks和roles更清晰。

### Use comments

即使有任务名称和明确的状态，有时候Playbook或role的一部分（或inventory/variable文件）需要更多的解释。添加注释（任何以`#`开头的行）可以帮助其他人（可能也包括您自己将来）理解Play或task（或variable设置）的目的，如何实现以及为什么这样做。

### Use fully qualified collection names

使用完全限定集合名称（FQCN）以避免在搜索每个任务的正确模块或插件时产生歧义。

对于内置模块和插件，请使用 `ansible.builtin` 集合名称作为前缀，例如 `ansible.builtin.copy`。

## Inventory tips

这些提示有助于保持您的inventory井然有序。

### Use dynamic inventory with clouds

使用动态清单([dynamic inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_dynamic_inventory.html#intro-dynamic-inventory))从维护基础架构的云提供商和其他系统检索这些列表，而不是手动更新静态清单文件。对于云资源，您可以使用标记来区分生产和分段环境。

### Group inventory by function

一个系统可以属于多个组。请参见[如何构建您的清单](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#intro-inventory)和[模式：针对主机和组](https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html#intro-patterns)。如果您创建以节点组中的功能命名的组，例如webservers或dbservers，您的playbook可以根据功能定位机器。您可以使用组变量系统分配特定于功能的变量，并设计Ansible角色来处理特定于功能的用例。请参见[角色](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#playbooks-reuse-roles)。

### Separate production and staging inventory

你可以使用单独的清单文件或目录来将生产环境与开发、测试和暂存环境分开。这样，你可以使用 -i 选择你要针对的环境。将所有环境放在一个文件中可能会导致意外情况！例如，清单中使用的所有保险库密码都需要在使用该清单时可用。如果清单包含生产和开发环境，使用该清单的开发人员将能够访问生产秘密。

### Keep vaulted variables safely visible

你应该使用Ansible Vault加密敏感或秘密变量。然而，加密变量名称以及变量值会使得查找值的来源变得困难。为了绕过这个问题，你可以使用ansible-vault encrypt_string单独加密变量，或者添加以下间接层来保持变量名称可访问（例如通过 `grep` ），而不会暴露任何秘密信息：

1. group_vars/下创建一个以组名命名的子目录。
2. 在这个子目录中，创建两个名为 `vars` 和 `vault` 的文件。
3. 在 `vars` 文件中，定义所有需要的变量，包括任何敏感变量。
4. 复制所有的敏感辩变量到 `vault` 文件中, 并在这些变量前面添加 `vault_` 前缀。
5. 将 `vars` 文件中的变量调整为使用 jinja2 语法指向匹配的 `vault_` 变量: `db_password: {{ vault_db_password }}`。
6. 加密 `vault` 文件以保护其内容。
7. 在playbook中使用vars文件中的变量名称。

运行 playbook 时，Ansible 会在未加密文件中查找变量，从加密文件中提取敏感的变量值。 variable 和 vault 文件的数量和名称没有限制。

请注意，在 inventory 中使用此策略仍需要在运行该 inventory 时可用所有 vault 密码（例如，对于ansible-playbook或AWX / Ansible Tower）。

## Execution tricks

这些提示适用于使用Ansible，而不是Ansible工件。

### Try it in staging first

在将更改推出生产之前，在演示环境中进行测试始终是一个好主意。您的环境不需要具有相同的大小，您可以使用组变量来控制这些环境之间的差异。

### Update in batches

使用 `serial` 关键字来控制一次批量更新中同时更新多少台机器。请参阅[控制任务运行位置：委派和本地操作](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_delegation.html#playbooks-delegation)。

### Handling OS and distro differences

组变量文件和 `group_by` 模块共同配合，帮助Ansible在需要不同设置、软件包和工具的不同操作系统和发行版上执行。`group_by` 模块创建一个动态的主机组，以匹配特定的条件。这个组不需要在清单文件中定义。这种方法允许您在不同的操作系统或发行版上执行不同的任务。

例如，以下播放根据操作系统名称将所有系统分类为动态组：

```yaml
- name: Talk to all hosts just so we can learn about them
  hosts: all
  tasks:

    - name: Classify hosts depending on their OS distribution
      ansible.builtin.group_by:
        key: os_{{ ansible_facts['distribution'] }}
```

后续的plays可以将这些组作为 `hosts` 行上的模式使用，如下所示：

```yaml
- hosts: os_CentOS
  gather_facts: False
  tasks:

    # Tasks for CentOS hosts only go in this play.
    - name: Ping my CentOS hosts
      ansible.builtin.ping:
```

您还可以在组变量文件中添加特定于组的设置。在下面的示例中，CentOS机器的asdf值为“42”，而其他机器的值为“10”。您还可以使用组变量文件将角色应用于系统以及设置变量。

```yaml
---
# group_vars/all
asdf: 10

---
# group_vars/os_CentOS
asdf: 42
```

> Note: 
>
> 所有三个名称必须匹配：由 `group_by` 任务创建的名称，随后plays中模式的名称以及组变量文件的名称。

当您只需要操作系统特定变量而不需要任务时，可以在 include_vars 中使用相同的设置：

```yaml
- name: Use include_vars to include OS-specific variables and print them
  hosts: all
  tasks:

    - name: Set OS distribution dependent variables
      ansible.builtin.include_vars: "os_{{ ansible_facts['distribution'] }}.yml"

    - name: Print the variable
      ansible.builtin.debug:
        var: asdf
```

这会从group_vars/os_CentOS.yml文件中提取变量。


### Ansible-lint

使用[ansible-lint](https://docs.ansible.com/ansible-lint/)来检查您的playbooks和roles是否符合最佳实践。这个工具可以帮助您发现潜在的问题，例如不良的命名约定、不必要的变量、不安全的任务等。

```bash
ansible-lint my_playbook.yml
```

```bash
ansible-lint --offline --profile production --write all roles/nginx/tasks/main.yml
```









