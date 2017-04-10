NowFap -  NOn Web Federated Authentication Portal
======

This project deploys COmanage using Ansible as a portal to handle
various non-web SSO scenarios. The portal needs an IdP for external
authentication. The IdP must adhere to the SAML 2.0 Web-SSO profile. The
EPPN is used to identify remote users and thus must be included in the
SAML response.

# Ansible playbooks and roles to install COmanage virtual machine.

This codebase contains all the roles/playbooks and templates to
configure a COmanage VMs.  The target Linux distribution for COmanage
server is Ubuntu Server 16.04

Machines are provisioned as follows:

```
ansible-playbook -i <local_inventory> comanage.yml
```

You are expected to provide your own inventory file as stated in the
above line. We will provide an example inventory file, so that you are
able to create your own. In the repository you'll find and example
inventory. See the `inventory` directory. The with this example
inventory, the above command will become:

```
ansible-playbook -i inventory/example/hosts comanage.yml
```

## Example inventory
The below inventory specifies the different hosts that need to be
provisioned in order to get a working system. There are four major
parts:

1. the portal itself;
2. an LDAP server;
3. SSH daemon capable of accessing the LDAP server for SSH key
   retrieval;
4. LDAP management (this component is not necessary, but can be
   convenient to have).

A typical host file would look like:
```
[portal]
portal.example.org  ansible_user=ansible

[ldap:children]
ldap-server
ssh-access

[ldap-server]
ldap.example.org ansible_user=ansible

[ssh-access]
ssh.example.org ansible_user=ansible

[phpldapadmin]
portal.example.org  ansible_user=ansible
```
The `ldap-server` and `ssh-access` hosts are placed in the same group,
as they share the IP address of the LDAP server.

Together with the above hosts file, `group_vars` are created as well.
Below an example of the group variables is given:

### Example of group_vars
Inside the `group_vars` directory a number of group files can be found:

1. **portal.yml**
   ```
   ---

   certificate: /etc/ssl/certs/portal.example.org.pem
   certificate_key: /etc/ssl/private/portal.examaple.org.key

   sp_hostname: portal.example.org
   ```
2. **ldap.yml**
   ```
   ---

   ldap_server: ldap://ldap.example.org
   ```
3. **ldap-server.yml**
   ```
   ---

   ldap_admin: admin
   ldap_admin_passwd: BigSecret
   ldap_basedn: dc=ldap,dc=example,dc=org
   ldap_rootdn: "cn={{ ldap_admin }},{{ ldap_basedn }}"

   organisation: Example
   ```
4. **ssh-access.yml**
   ```
   ---

   ldap_admin_passwd: BigSecret
   ldap_basedn: dc=ldap,dc=example,dc=org
   ```

Please note that in the above hosts and group_vars files examples,
private IP addresses were used as well as unsecure password and other
dummy strings for certificates and host name.

# Roles
The playbook executes the following roles:

| Role       | Description |
| ---------- | ----------- |
apache       | The portal is build with Apache. |
auth_mellon  | Install and configure an Apache module for external SAML Authentication. |
certificate  | Obtain or create a self signed certificate and install it. |
comanage     | COmanage provides a portal in which the use case are implemented. |
common       | A number of command task, like package installation. |
ldap         | LDAP is used to store attributes (ASP, OTP, SSH Pub key, etc) collected by COmanage. |
mysql        | The framework requires a database. |
php          | Php 5.6 is necessary for the underlying framework. |
phpldapadmin | Web interface to an LDAP instance. |
sshd         | Setting up an SSH daemon that is able to retrieve SSH keys from an LDAP instance. |
surfconext   | Necessary metadata is fetched and verified in order to make the SAML flow work. |

# Certificates
You typically need self signed certificates when you are deploying local
virtual machine. Usually, the configured network will be a NAT one and thus
the machines are typically not accessible from the outside. When deploying to
VMs that are reachable from the outside, you can use a trusted certificate
from Let's Encrypt.

The `certificate` role can either obtain a certificate through Let's Encrypt,
or create a self signed one. The certificate role tries to determine if the
supplied sp_hostname is resolvable. If it is, Let's Encrypt is used to
generate a valid certificate. If not, a self signed certificate is generated
instead.

## Certificate and key location
The name of the certificate is determined from the host and domain names.
However, the path to where the certificate and it private key can be found
must be specified. There are two variables that take care of this:
- certificate_path
- certificate_key_path

| Variable | Default value |
| -------- | ------------- |
| certificate_path     | /etc/ssl/cert/    |
| certificate_key_path | /etc/ssl/private/ |

## Do not forget to specify parameters for mod_mellon
In order for mod_mellon to do the right thing, it needs to know a few
things first. You need to do this for each host, as these values are
unique to each one. Well, at least the sp_hostname is. So, please define
the following in your `portal.yml` group vars file:

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| sp_protocol | Protocol to be used | https:// |
| sp_hostname | Name of the host where mod_mellon is being used | portal.example.org |
| sp_path     | Path that follows the host name to create the full URI | 'registry/auth/sp' |
