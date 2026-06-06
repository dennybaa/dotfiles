#!/usr/bin/env bash
set -e
# check interface and DNS host are set
: ${IFACE:?must be set}

# check command exists
command -v resolvectl 1>/dev/null 2>&1 || { echo >&2 'resolvectl not found.'; exit 1; }
# wait for DNS to be set on the interface
while ! resolvectl dns $IFACE 2>/dev/null | grep -qoP '(\d+\.){3}\d+'; do
    sleep 3
done
