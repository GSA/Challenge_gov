#!/bin/sh

# Despite the temptation to use #!/bin/bash, we want to keep this file as as
# POSIX sh-compatible as possible. This is to facilitate testing the .profile
# under Alpine, which doesn't have /bin/bash, but does have ash (which is itself
# a flavor of busybox).
ENABLE_ASH_BASH_COMPAT=1

set -e

# Ensure there's only one entry per line, and leave no whitespace
PROXY_DENY=$(  echo -n "$PROXY_DENY"  | sed 's/^\S/ &/' | sed 's/\ /\n/g' | sed '/^\s*$/d' )
PROXY_ALLOW=$( echo -n "$PROXY_ALLOW" | sed 's/^\S/ &/' | sed 's/\ /\n/g' | sed '/^\s*$/d' )

# Append to the appropriate files
echo -n "$PROXY_DENY"  > deny.acl
echo -n "$PROXY_ALLOW" > allow.acl

# Newline Terminate Non-Empty File If Not Already aka ntnefina
# https://stackoverflow.com/a/10082466/17138235
#
# It's unclear if this works properly under Alpine because it uses ANSI-C
# quoting; that needs more testiing. However, if caddy complains about a blank
# in the file, you know why!
ntnefina() {
    if [ -s "$1" ] && [ "$(tail -c1 "$1"; echo x)" != $'\nx' ]; then
        echo "" >> "$1"
    fi
}

ntnefina deny.acl
ntnefina allow.acl

# Make it easy to run curl tests on ourselves
https_proxy="https://$PROXY_USERNAME:$PROXY_PASSWORD@$(echo "$VCAP_APPLICATION" |  jq .application_uris[0] | sed 's/"//g'):61443"
export https_proxy

# Make open ports configurable via the PROXY_PORTS environment variable.
# For example "80 443 22 61443". Default to 443 only.
if [ -z "${PROXY_PORTS}" ]; then
  PROXY_PORTS="443"
fi
export PROXY_PORTS

echo
echo
echo "The proxy connection URL is:"
echo "  $https_proxy"
