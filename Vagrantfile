# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'
require 'securerandom'

#  Please change the below values to something that makes sence to you.
comanage_version    = "develop"

machinesNames       = Array["portal", "ldap", "ssh"]
domain              = "example.org"
fqdn_name           = "#{machinesNames[0]}.#{domain}"
ldap_fqdn_name      = "#{machinesNames[1]}.#{domain}"
given_name          = "John"
surname             = "Doe"
email               = "john.doe@example.org"
organisation        = "Example.org Ltd."
subject             = "/C=NL/ST=North-Holland/L=Amsterdam/O=IT/CN=#{fqdn_name}"
ssl_cert_days_valid = 365

ip_address          = IPAddr.new('192.168.64.10')
machineIP           = Hash.new

ldap_admin          = "admin"
ldap_passwd         = "Please-change-me!"

#  Contruct the ldap_basedn based on the domain variable.
ldap_basedn = ""
domainComponents = domain.split('.')
domainComponents.each_with_index do |dc, index|
    ldap_basedn = ldap_basedn + "dc=#{dc}"
    if index != (domainComponents.length - 1)
        ldap_basedn = ldap_basedn + ","
    end
end

#  Determine IP addresses to the VMs.
machinesNames.each { |machineName|
    machineIP.store(machineName, ip_address.to_s)
    ip_address = ip_address.succ
}

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/xenial64"
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    config.vm.define "#{machinesNames[0]}" do |portal|
        portal.vm.provider "virtualbox" do |vbox|
            vbox.memory = 1024
            vbox.name = "portal"
        end
        portal.vm.network "private_network", ip: "#{machineIP["portal"]}"
        portal.vm.hostname = "portal.#{domain}"
   end

    config.vm.define "#{machinesNames[1]}" do |ldap|
        ldap.vm.provider "virtualbox" do |vbox|
            vbox.memory = "512"
            vbox.name = "ldap"
        end
        ldap.vm.network "private_network", ip: "#{machineIP["ldap"]}"
        ldap.vm.hostname = "ldap.#{domain}"
   end

    config.vm.define "#{machinesNames[2]}" do |ssh|
        ssh.vm.provider "virtualbox" do |vbox|
            vbox.memory = "512"
            vbox.name = "ssh"
        end
        ssh.vm.network "private_network", ip: "#{machineIP["ssh"]}"
        ssh.vm.hostname = "ssh.#{domain}"
    end

    config.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "comanage.yml"
#        ansible.verbose = true
#        ansible.install = true
#        ansible.install_mode = "pip"
#        ansible.version = "2.2.1.0"

        ansible.host_vars = {
            "#{machinesNames[0]}" => {
                "ansible_user" => "ubuntu"
            },
            "#{machinesNames[1]}" => {
                "ansible_user" => "ubuntu"
            },
            "#{machinesNames[2]}" => {
                "ansible_user" => "ubuntu"
            }
        }

        ansible.groups = {
            "all" => ["#{machinesNames[0]}", "#{machinesNames[1]}", "#{machinesNames[2]}"],
            "comanage-portal" => ["#{machinesNames[0]}"],
            "ldap-server" => ["#{machinesNames[1]}"],
            "ssh-access" => ["#{machinesNames[2]}"],
            "phpldapadmin" => ["#{machinesNames[0]}"],

            "all:vars" => {
                "ldap_server" => "#{ldap_fqdn_name}",
                "organisation" => "#{organisation}",
                "ldap_admin" => "#{ldap_admin}",
                "ldap_admin_passwd" => "#{ldap_passwd}",
                "ldap_basedn" => "#{ldap_basedn}",
                "ldap_rootdn" => "cn=#{ldap_admin},#{ldap_basedn}"
            },
            "comanage-portal:vars" => {
                "certificate" => "/etc/ssl/certs/#{fqdn_name}.pem",
                "certificate_key" => "/etc/ssl/private/#{fqdn_name}.key",
                "sp_hostname" => "#{fqdn_name}",
                "sp_protocol" => "https://",
                "sp_path" => "/registry/auth/sp",
                "sp_random_part" => SecureRandom.uuid,
                "comanage_version" => "#{comanage_version}",
                "given_name" => "#{given_name}",
                "surname" => "#{surname}",
                "email_contact" => "#{email}",
                "organisation" => "#{organisation}",
                "subject" => "#{subject}",
                "cert_days_valid" => "#{ssl_cert_days_valid}",
                "cert_key_dest" => "/etc/ssl/private/#{fqdn_name}.key",
                "cert_dest" => "/etc/ssl/certs/#{fqdn_name}.pem"
            },
        }
    end
end
