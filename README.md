[![Build Status](https://travis-ci.org/venekamp/nowfap-portal.svg?branch=travis-ci)](https://travis-ci.org/venekamp/nowfap-portal)

NowFap -  NOn Web Federated Authentication Portal
======

Nowfap provides support for federated access to distributed resources, i.e.
aceess to resources based on an identity that is provided by a third party. It
uses Ansible to provision a machine or VM. COmanage is used as the main
component to provide the federated access. There are a number of supporting
roles that are needed to complete the needed functionality. The roles together
with the playbook result in a portal environment in which groups, called
collaborative organisations, are managed. One of the aims of nowfap is to
enable federated access to command line tools, i.e. non-web access.  Since
those tool generally support PAM and LDAP, LDAP is another important building
block in accomplishing this goal.

# Table of Contents

<!-- vim-markdown-toc GFM -->
* [Dependencies](#dependencies)
    * [Other dependencies](#other-dependencies)
* [Metadata: how trust is built](#metadata-how-trust-is-built)
    * [Registering an SP with an IdP](#registering-an-sp-with-an-idp)
    * [Where is my metadata?](#where-is-my-metadata)
* [Provisioning a machine or VM](#provisioning-a-machine-or-vm)
    * [Example inventory](#example-inventory)
    * [Example of group_vars](#example-of-group_vars)
* [Roles](#roles)
* [Certificates](#certificates)
    * [Supported certificate types](#supported-certificate-types)
* [Configuring mod_mellon](#configuring-mod_mellon)
* [Creating and Provisioning VMs with Vagrant](#creating-and-provisioning-vms-with-vagrant)
    * [Vagrant configuration](#vagrant-configuration)
    * [Final Steps](#final-steps)

<!-- vim-markdown-toc -->

# Dependencies
In order to successfully provision your VMs, a number of dependencies need to
be met. You are strongly advised to use the same versions.

| Dependency       | Version | Remarks |
|------------------|---------|---------|
| **Ubuntu**       | 16.04   | The Ansible playbook has been created with Ubuntu 16.04 in mind. Later versions of Ubuntu might work, but have not been tested. |
| **Ansible**      | 2.4.0.0 | Some roles make use of Ansible features that are introduced in Ansible 2.4. Any later version will probably work. |
| **Python**       | 3.6.2   | The playbook, nor the roles have a dependency on Python. If you want to create your own CA, create and sign certificates, nowfap included a tool for that. This tool is created in Python. |
| **Vagrant**      | 1.9.2   | Vagrant is used for creating and provisioning local VMs. |
| **VirtualBox**   | 5.1.22  | VirtualBox is used for creating local VMs |
| **Zerotier-One** | 1.2.4   | Zerotier-One can be used to create VPN if needed. |

## Other dependencies
Other dependencies, like *Apache*, *MyQSL*, etc. are taken from the Ubuntu
16.04 default installation. Just use the versions provided by the Ubuntu
16.04 distribution.

# Metadata: how trust is built
Trust between IdP and SP is build on the exchange of metadata. Each
party has generated metadata. In it are attributes like description of
the service and contact information. The metadata is signed. During
provisioning of a VM, two things happen with regard to metadata:
1. Import the metadata from the IdP and thereby trusting it;
2. Generate the SP metadata such that an IdP can build its trust of this
   SP.

## Registering an SP with an IdP
Once the provisioning has been successfully completed, the COmanage
portal trusts the configured IdP, as the metadata has been imported.
However, the IdP does not have the portal metadata yet. It should be
delivered in a secure manner to the IdP. Once delivered the IdP must
make the decision to accept the SP or not.

**Note:**
Getting the SP registered at the IdP side is _not_ part of the
provisioning. _It should be done as a separate step afterwards._

## Where is my metadata?
There are two places where you can find the SP metadata. Depending
on what your IdP supports, you can either use:
1. a URL: https://portal.example.com/registry/auth/sp/metadata
2. or a file you'll find on the portal VM:
   `/etc/apache2/mellon/sp-metadata.xml`

# Provisioning a machine or VM
Provisioning of a VM is typically realized thusly:
```bash
ansible-playbook -i <local_inventory> comanage.yml
```

You are expected to provide your own inventory file as stated in the
above line. An example inventory file is provided in the repository as
well as a `group_vars` directory with role variables in it. This way,
you are able to create your own configuration. See the
[inventories/example](inventories/example) directory. With the example
inventory, the above command will become:

```bash
ansible-playbook -i inventories/example/hosts comanage.yml
```

**Note:** Remember to register the metadata with your IdP.

## Example inventory
The below inventory specifies the different hosts that need to be
provisioned in order to get a working system. There are four major
parts:

1. the portal itself;
2. an LDAP server;
3. LDAP management (this component is not necessary, but can be
   convenient to have);
4. SSH daemon capable of accessing the LDAP server for SSH key
   retrieval.

A typical host file would look like:
```ini
[portal]
portal.example.org  ansible_user=ansible

[ldap-group:children]
ldap-server
phpldapadmin
ssh-access

[ldap-server]
ldap.example.org ansible_user=ansible

[phpldapadmin]
portal.example.org  ansible_user=ansible

[ssh-access]
ssh.example.org ansible_user=ansible
```

**Note:**
In the above host file, you'll see that the `ansible_user` is set to
`ansible`. Depending on how you have configured your VM, the
`ansible_user` could be different.

## Example of group_vars
Ansible variables for roles can be placed inside a `group_vars`
directory. This directory must be placed in the same directory where the
inventory host file lives. Thus in the example case:
[`inventories/example/group_vars`](inventories/example/group_vars).
Inside this directory you will find a number of files. These correspond
with the hosts defined in your host file and list the variables for that
host. You will also find a `all.yml` and the variables in it apply to
all hosts.

1. **all.yml**
   ```yaml
   ---

   domain_name: example.org
   remote_user: ubuntu
   data_dir: data
   ```
2. **portal.yml**
   ```yaml
   ---

   hostname: portal
   certificate_ca: provided
   sp_fqdn: {{ hostname }}.{{ domain_name }}
   sp_protocol: https://
   sp_path: /registry/auth/sp
   given_name: John
   surname: Doe
   email_contact: john.doe@example.org
   organisation: Nameless Inc.
   service_description: Demonstration Service for Nameless Inc.
   service_display_name: Demo Service
   comanage_version: 3.0.0
   comanage_admin_given_name: John
   comanage_admin_family_name: Doe
   comanage_admin_username: john.doe@example.org
   ```
3. **ldap-group.yml**
   ```yaml
   ---

   hostname: ldap
   ldap_admin: admin
   ldap_fqdn: {{ hostname }}.{{ domain_name }}
   ldap_basedn: dc=example,dc=org
   organisation: Nameless Inc.
   ```
4. **ldap-server.yml**
   ```yaml
   ---

   certificate_ca: provided
   ldap_admin_passwd: Please-change-me!
   ldap_rootdn: cn={{ ldap_admin }},{{ ldap_basedn }}
   ```

Please note that in the above hosts and group_vars files, private IP
addresses were used as well as unsecure passwords and other dummy
strings for certificates and host name.

# Roles
The below listed roles are provided. More information on each role can be
obtained within the roles. This information includes role variables.

| Role                                         | Description                                                                          |
| :--------------------------------------------| :------------------------------------------------------------------------------------|
| [apache](roles/apache/README.md)             | The portal is build with Apache.                                                     |
| [auth_mellon](roles/auth_mellon/README.md)   | Install and configure an Apache module for external SAML Authentication.             |
| [certificate](roles/certificates/README.md)  | Obtain or create a self signed certificate and install it.                           |
| [comanage](roles/comanage/README.md)         | COmanage provides a portal in which the use case are implemented.                    |
| [common](roles/common/README.md)             | A number of command task, like package installation.                                 |
| [ldap](roles/ldap/README.md)                 | LDAP is used to store attributes (ASP, OTP, SSH Pub key, etc) collected by COmanage. |
| [mysql](roles/mysql/README.md)               | The framework requires a database.                                                   |
| [php](roles/php/README.md)                   | Php 5.6 is necessary for the underlying framework.                                   |
| [phpldapadmin](roles/phpldapadmin/README.md) | Web interface to an LDAP instance.                                                   |
| [sshd](roles/sshd/README.md)                 | Setting up an SSH daemon that is able to retrieve SSH keys from an LDAP instance.    |
| [surfconext](role/surfconext/README.md)      | Necessary metadata is fetched and verified in order to make the SAML flow work.      |

# Certificates
You typically need self signed certificates when you are deploying local
virtual machine. Usually, the configured network will be a NAT one and
thus the machines are typically not accessible from the outside. When
deploying to VMs that are reachable from the outside, you can use a
trusted certificate from Let's Encrypt.

## Supported certificate types
The certificate role support three different certificate types:
1. Let's Encrypt
2. Provided certificates
3. Self signed certificates

See also [certificate](roles/certificates/README.md) for more
information and description on how to select each of the above mentioned
types.

# Configuring mod_mellon
In order for mod_mellon to do the right thing, it needs to know a few
things first. This need to be one for each host, as these values are
unique to each one. Further information on configuring mod_mellon and
role variables can be found at: [auth_mellon](roles/auth_mellon/README.md)

# Creating and Provisioning VMs with Vagrant
Vagrant can be used to quickly set up a number of VMs on your local
machine. A private network (192.168.64.0/8) is created. The domain name
is set to: `example.org`. Within this domain, Vagrant will create the
following hosts:

| Hostname | FQDN               | IP address    | Assigned Memory |
| :------- | :----------------- | :------------ | :-------------- |
| portal   | portal.example.org | 192.168.64.10 | 1GB             |
| ldap     | ldap.example.org   | 192.168.64.11 | 512MB           |
| ssh      | ssh.example.org    | 192.168.64.12 | 512MB           |

## Vagrant configuration
At the top of the Vagrantfile, you'll find a number of variables, which
you are free to change. Some of which should be changed. In the table
below, you'll find the names of these variables and a short description.

| Variable            | Change | Default value               | Description                                                                                                  |
| :------------------ | :----- | :-------------------------- | :----------------------------------------------------------------------------------------------------------- |
| comanage_version    |        | "3.0.0"                     | Which version to install                                                                                     |
| hostname_ports      |        | "portal"                    | hostname of the portal machine. There is no real need for changing it                                        |
| hostname_ldap       |        | "ldap"                      | hostname of the ldap machine. There is no real need for changing it                                          |
| hostname_ssh        |        | "ssh"                       | hostname of the ssh machine. There is no real need for changing it                                           |
| start_ip_address    |        | IPAddr.new('192.168.64.10') | Start IP address. The first VM gets assigned this address, the next ones get successor addresses             |
| domain_name         | Y      | "example.org"               | The domain name part. This really should be changed, as the EntityID is based on this and needs to be unique |
| given_name          | Y      | "John"                      | Your given name. The IdP likes to have a real name                                                           |
| surname             | Y      | "Doe"                       | Your surname. The IdP likes to have a real name                                                              |
| email               | Y      | "john.doe@example.org"      | Your email address. The IdP really like to be able to contact you in case there are issues                   |
| country             |        | "NL"                        | Country code                                                                                                 |
| state               |        | "North-Holland"             | State or Province                                                                                            |
| locality            |        | "Amsterdam"                 | Locality or city                                                                                             |
| organisation        |        | "Example.org Ltd."          | Organisation name                                                                                            |
| organisation_unit   |        | "IT"                        | Department                                                                                                   |
| ssl_cert_days_valid |        | 365                         | Number of days you want the certificate to remain valid                                                      |
| ldap_admin          |        | "admin"                     | The admin name for LDAP                                                                                      |
| ldap_passwd         | Y      | "Please-change-me!"         | The password for the LDAP admin user                                                                         |

In the above table, you'll see a number of variables being marked as
'change'. Although the variables can be left at their default values --
you will get a valid installation -- you are strongly encouraged to
change them. Your IdP for example, expects you to provide real values.
For building trust it is best to give your real name and the IdP really
wants a real contact. That includes a valid email address. _Why not do it
now the way you are supposed to do it when doing it in real life?_ An
IdP needs those when there are issues and it needs to contact you.

The 'county', 'state', 'locality', 'organisation' and
'organisation_unit' are used for the generation of a self signed
certificate. You can leave them at their default values, but if you do
change them, your certificate will look much nicer.

Finally, you probably would want to change the 'ldap_passwd'. It always
good practice to change any given default passwords.

## Final Steps
During the provisioning, metadata has been created on the portal
machine and needs to be registered with an IdP first.
See also: [Registering an SP with an IdP](#registering-an-sp-with-an-idp)
Once the metadata has been registered, you should have a working setup.
