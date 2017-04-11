# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'

portal_hostname = "portal"
domain          = "example.org"
fqdn_name       = "#{portal_hostname}.#{domain}"
ip_address      = IPAddr.new('192.168.64.10')
machinesNames   = Array["portal", "ldap", "ssh"]
machines        = Hash.new

#  Determine IP addresses to the VMs.
machinesNames.each { |machineName|
    machines.store(machineName, ip_address.to_s)
    ip_address = ip_address.succ
}

$python2 = <<SCRIPT
apt-get update
apt-get install -y python
SCRIPT

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.box = "ubuntu/xenial64"
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    config.vm.define "portal" do |portal|
        portal.vm.provider "virtualbox" do |vbox|
            vbox.memory = 1024
            vbox.name = "portal"
        end
        portal.vm.network "private_network", ip: "#{machines["portal"]}"
        portal.vm.hostname = "portal.#{domain}"

        portal.vm.provision "shell", inline: $python2

        portal.vm.provision "ansible" do |ansible|
            ansible.playbook = "comanage.yml"

            ansible.groups = {
                "portal" => ["portal"],

                "portal:vars" => {
                    "certificate" => "/etc/ssl/certs/#{fqdn_name}.pem",
                    "certificate_key" => "/etc/ssl/private/#{fqdn_name}.key",
                    "sp_hostname" => "portal.example.org",
                    "sp_protocol" => "https://",
                    "sp_path" => "/registry/auth/sp",
                    "comanage_version" => "develop",
                    "given_name" => "John",
                    "surname" => "Doe",
                    "email_contact" => "john.doe@example.org",
                    "organisation" => "Example.com Ltd.",
                    "subject" => "/C=NL/ST=North-Holland/L=Amsterdam/O=IT/CN=#{fqdn_name}",
                    "cert_days_valid" => "365",
                    "cert_key_dest" => "/etc/ssl/private/#{fqdn_name}.key",
                    "cert_dest" => "/etc/ssl/certs/#{fqdn_name}.pem"
                }
            }
        end
    end

    config.vm.define "ldap" do |ldap|
        ldap.vm.provider "virtualbox" do |vbox|
            vbox.memory = "512"
            vbox.name = "ldap"
        end
        ldap.vm.network "private_network", ip: "192.168.64.11"
        ldap.vm.hostname = "ldap.#{domain}"
    end

    config.vm.define "ssh" do |ssh|
        ssh.vm.provider "virtualbox" do |vbox|
            vbox.memory = "512"
            vbox.name = "ssh"
        end
        ssh.vm.network "private_network", ip: "192.168.64.12"
        ssh.vm.hostname = "ssh.#{domain}"
    end
end
