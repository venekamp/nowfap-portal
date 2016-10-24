NowFap -  NOn Web Federated Authentication Portal 
======

This project deploys COmanage using Ansible as a portal to handle various non-web SSO scenarios



Ansible playbooks and roles to install COmanage virtual machine.

This codebase contains all the roles/playbooks and templates to configure comanage VMs.
The target Linux distribution for COmanage server is Ubuntu Server 16.04

Machines are provisioned as follows:

```
ansible-playbook -i inventories/inventory.comanage --become --become-user=root --become-method=sudo playbook.yml
```
