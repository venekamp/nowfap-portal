#!/bin/sh

LOG_FILE=/root/authorized_key.log

log() {
    echo "$(date '+%b %d %H:%M:%S') $1" >> $LOG_FILE
}

#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJeoI8QvBFw11XBEosvtcZPWUJBM7l4bstXI93wZU1mLg6NcfH0CeJKIW/rsB/R3xpsD5h2eUTo7W0IG3MY4fuKG0ABIE/M1h9vomPbBD53riA+Kmseje7022N2fzDGsi6+qm2FeGIc+hHjp1fnSNbFOo1X2d7DFEoQwQn6nFJhttwLr3jJ7Afp/jtKfg7d2QF0s8IiLlBJlfplLImLGV6RXxtpuz1W1SVDLFbgtxcAwpoSzx5FHPReFafz0lylZAC6swrE4cv0PBDfaNSLRQ/RU+g73IDl6uSq/ntRpI+7CgwspAVVyf/m0fCqPms2JzOMbME3fotywrZIk/XR/lZ gerben@mlt0067.wp.surfsara.nl"

LDAP_SERVER=ldap://172.29.191.100
LDAP_ADMIN='cn=admin,dc=portal,dc=example,dc=org'
USER_DN='mail=venekamp@gmail.com,ou=people,dc=portal,dc=example,dc=org'

log $LDAP_SERVER
log $LDAP_ADMIN
log $USER_DN

ldapsearch -o ldif-wrap=no -LLL -H $LDAP_SERVER -w 'grT%fk_0vQ]' -D $LDAP_ADMIN -b $USER_DN sshPublicKey | grep sshPublicKey | awk '{ print $2, $3 }'
