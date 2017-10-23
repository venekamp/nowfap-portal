# Ansible role:

## Operating Systems compatibility
The xxx role has been tested with the following Operating Systems:

- Ubuntu 16.04 (xenial)

## Requirements
This role is part of a bigger ensemble. Most notably the
[common](https://github.com/venekamp/nowfap-portal/tree/master/roles/common "Role: common")
role.

## Role Variables
| Variable    | Description                                            | Default value      |
|-------------|--------------------------------------------------------|--------------------|
| sp_protocol | Protocol to be used                                    | https://           |
| sp_fqdn     | Fully Qualified Domain Name of the host where mod_mellon is being used        | portal.example.org |
| sp_path     | Path that follows the host name to create the full URI | 'registry/auth/sp' |

```
modules:
```

```
conf:
```

```
disable_modules
```

```
restart
```

```
apache_enable_conf
```

### Default values
No Default values have been defined for this role.

## Dependencies

## Example Playbook

