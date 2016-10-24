Generic
=======

This role describes a generic server in the VOPaaS environment.

Requirements
------------

This playbook's role has been tested in Debian 8, which is the distribution used within VOPaaS.

Role Variables
--------------

Within the variables the vile vars/users.yml contains all the users (with ssh and yubico keys) to be added to the system.

Dependencies
------------

No dependency required.

Example Playbook
----------------

This role can be used as follows:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

TBD

Author Information
------------------

Andrea Biancini <andrea.biancini@garr.it>
Simone Visconti <simone.visconti@garr.it>
