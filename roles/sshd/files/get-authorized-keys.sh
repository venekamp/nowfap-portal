#!/bin/sh

LOG_FILE=/root/authorized_key.log

log() {
    echo "$(date '+%b %d %H:%M:%S') $1" >> $LOG_FILE
}

LDAP_SERVER=ldap://172.29.191.100
LDAP_ADMIN='cn=admin,dc=portal,dc=example,dc=org'
USER_DN='mail=venekamp@gmail.com,ou=people,dc=portal,dc=example,dc=org'

log $LDAP_SERVER
log $LDAP_ADMIN
log $USER_DN

ldapsearch -o ldif-wrap=no -LLL -H $LDAP_SERVER -w 'grT%fk_0vQ]' -D $LDAP_ADMIN -b $USER_DN sshPublicKey | grep sshPublicKey | awk '{ print $2, $3 }'
