#!/usr/bin/env bash

#  The input arguments of the original scripts have been changed. The script
#  now accepts -d and -n as optional arguments.
#   -d specifies a directory where to store the resulting files.
#   -n tells not to generate new a new key and cert in case the key already
#      exists. Default behaviour is to always generate a new key and cert pair.

set -e

PROG="$(basename "$0")"

printUsage() {
    echo "Usage: $PROG [-d output directory] [-n do not generate new key] ENTITY-ID ENDPOINT-URL GIVEN_NAME SURNAME EMAIL_CONTACT ORGANISATION ORGANISATION_URL"
    echo ""
    echo "Example:"
    echo "  $PROG urn:someservice https://sp.example.org/mellon"
    echo ""
}

#  Always generate a new key and cert file, unless told otherwise.
generate_key="yes"
output_dir=""

if [ "$#" -lt 2 ]; then
    printUsage
    exit 1
fi

args=$(getopt d:n $*)

if [ "$?" != 0 ]
then
    printUsage
    exit 2
fi

set -- $args
for arg; do
    case "$arg" in
        -d)
            #  What is the directory where the files must be written to.
            output_dir="$2"
            shift
            ;;
        -n)
            #  Do not generate a new key and cert pair, unless key does not exists.
            generate_key="no"
            shift
            ;;
        --)
            shift
            break
            ;;
    esac
done

shift

ENTITYID="$1"
if [ -z "$ENTITYID" ]; then
    echo "$PROG: An entity ID is required." >&2
    exit 1
fi

BASEURL="$2"
if [ -z "$BASEURL" ]; then
    echo "$PROG: The URL to the MellonEndpointPath is required." >&2
    exit 1
fi

GIVEN_NAME=$3
if [ -z "$GIVEN_NAME" ]; then
    echo "$PROG: The given name must be speciied." >&2
    exit 1
fi

SURNAME=$4
if [ -z "$SURNAME" ]; then
    echo "$PROG: The surname must be specified." >&2
    exit 1
fi

EMAIL_CONTACT=$5
if [ -z "$EMAIL_CONTACT" ]; then
    echo "$PROG: The email contact must be specified." >&2
    exit 1
fi

ORGANISATION=$6
if [ -z "$ORGANISATION" ]; then
    echo "$PROG: The organisation is required." >&2
    exit 1
fi

ORGANISATION_URL=$7
if [ -z "$ORGANISATION_URL" ]; then
    echo "$PROG: The organisation URL is required." >&2
    exit 1
fi

if ! echo "$BASEURL" | grep -q '^https\?://'; then
    echo "$PROG: The URL must start with \"http://\" or \"https://\"." >&2
    exit 1
fi

if [ ! -e "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

HOST="$(echo "$BASEURL" | sed 's#^[a-z]*://\([^/]*\).*#\1#')"
BASEURL="$(echo "$BASEURL" | sed 's#/$##')"

HOST_ENTITYID=$(echo "$ENTITYID" | sed 's/\(http[s]\?:\/\/\)\([^\/]*\)\/.*/\2/')

OUTFILE="$output_dir/$(echo "$HOST_ENTITYID" | sed 's/[^0-9A-Za-z.-]/_/g' | sed 's/__*/_/g')"
echo "Output files:"
echo "Private key:               $OUTFILE.key"
echo "Certificate:               $OUTFILE.cert"
echo "Metadata:                  $OUTFILE.xml"
echo "Host:                      $HOST"
echo
echo "Endpoints:"
echo "SingleLogoutService:       $BASEURL/logout"
echo "AssertionConsumerService:  $BASEURL/postResponse"
echo "Give name:                 $GIVEN_NAME"
echo "Surname:                   $SURNAME"
echo "Organisation:              $ORGANISATION"
echo "Organisation URL:          $ORGANISATION_URL"
echo

# No files should not be readable by the rest of the world.
umask 0077

# Only generate a new file when really wanted, or when key file doen not
# exist yet.
if [ "x$generate_key" == "xyes" ] || [ ! -e "$OUTFILE.key" ]; then
    TEMPLATEFILE="$(mktemp -t mellon_create_sp.XXXXXXXXXX)"

    cat >"$TEMPLATEFILE" <<EOF
RANDFILE           = /dev/urandom
[req]
default_bits       = 2048
default_keyfile    = privkey.pem
distinguished_name = req_distinguished_name
prompt             = no
policy             = policy_anything
[req_distinguished_name]
commonName         = $HOST
EOF

    openssl req -utf8 -batch -config "$TEMPLATEFILE" -new -x509 -days 3652 -nodes -out "$OUTFILE.cert" -keyout "$OUTFILE.key" 2>/dev/null

    rm -f "$TEMPLATEFILE"
fi

CERT="$(grep -v '^-----' "$OUTFILE.cert")"

cat >"$OUTFILE.xml" <<EOF
<?xml version="1.0"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                     xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
                     entityID="https://$(hostname -f)/registry/auth/sp/metadata">
  <md:SPSSODescriptor AuthnRequestsSigned="true"
                      WantAssertionsSigned="true"
                      protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <md:Extensions>
      <mdui:UIInfo>
        <mdui:DisplayName xml:lang="en">COmanage DEMO - $GIVEN_NAME $SURNAME</mdui:DisplayName>
        <mdui:Description xml:lang="en">
          This is a demo instance for the COmanage hackathon.
        </mdui:Description>
      </mdui:UIInfo>
    </md:Extensions>
    <md:KeyDescriptor use="signing">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:X509Data>
          <ds:X509Certificate>$CERT</ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </md:KeyDescriptor>
   <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat>
    <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://192.168.50.4/registry/auth/sp/postResponse" index="1"/>
  </md:SPSSODescriptor>
  <md:Organization>
    <md:OrganizationName xml:lang="en-US">$ORGANISATION</md:OrganizationName>
    <md:OrganizationDisplayName xml:lang="en-US">$ORGANISATION</md:OrganizationDisplayName>
    <md:OrganizationURL xml:lang="en-US">$ORGANISATION_URL</md:OrganizationURL>
  </md:Organization>
  <md:ContactPerson contactType="technical">
    <md:GivenName>$GIVEN_NAME</md:GivenName>
    <md:SurName>$SURNAME</md:SurName>
    <md:EmailAddress>$EMAIL_CONTACT</md:EmailAddress>
  </md:ContactPerson>
</md:EntityDescriptor>
EOF

umask 0777
chmod go+r "$OUTFILE.xml"
chmod go+r "$OUTFILE.cert"
