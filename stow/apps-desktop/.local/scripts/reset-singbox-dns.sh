#!/usr/bin/env bash
set -e
# Only proceed if Happ operates in sing-box tun mode
if (! pgrep sing-box >/dev/null 2>&1); then
  exit 0
fi

# check interface and DNS host are set
: ${IFACE:?must be set}

# check command exists
command -v resolvectl 1>/dev/null 2>&1 || {
  echo >&2 'resolvectl not found.' && exit 1
}

# Wait for DNS to be set on the interface (wait for Sing-Box to connect)
while ! resolvectl dns $IFACE 2>/dev/null | grep -qoP '(\d+\.){3}\d+'; do
  sleep 3
done
resolvectl dns "$IFACE" ""
