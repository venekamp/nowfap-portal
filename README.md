NowFap -  NOn Web Federated Authentication Portal 
======

This project deploys COmanage using Ansible as a portal to handle
various non-web SSO scenarios. The portal needs an IdP for external
authentication. The IdP must adhere to the SAML 2.0 Web-SSO profile. The
EPPN is used to identify remote users and thus must be included in the
SAML repsonse.

### Ansible playbooks and roles to install COmanage virtual machine.

This codebase contains all the roles/playbooks and templates to
configure a COmanage VMs.  The target Linux distribution for COmanage
server is Ubuntu Server 16.04

Machines are provisioned as follows:

```
ansible-playbook -i inventories/inventory.comanage --become --become-user=root --become-method=sudo playbook.yml
```

You will need to update the `inventory/inventory.comanage` config file
with your own settings.
