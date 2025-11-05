
# adds apt sources.d file
# $1 - deb line, $2 - sources.d/<filename> and $3 key url optional
#
# apt_sources_add \
#     "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
#     warpdotdev.list \
#     https://releases.warp.dev/linux/keys/warp.asc

apt_sources_add () {
  local deb_line="$1" file="$2" key_url="$3" signed_by
  signed_by=$(echo "$deb_line" | sed -E 's/.*\[.*signed-by=([^ \]*).*\].*/\1/')

  if [ -n "$signed_by" ] && [ -f "$signed_by" ]; then
    # checked that the key exists, so skip the key download
    :
  elif [ -n "$signed_by" ]; then
    # create key
    if [ -z "$key_url" ]; then
      >&2 echo "Provide key URL, for ${signed_by} (not found)!"
    else
      sudo -i true
      echo "Fetching ${key_url} ..."
      wget -qO- "$key_url" | sudo gpg --dearmor -o "$signed_by"
    fi
  fi

  aptf="/etc/apt/sources.list.d/$file"
  if ( ! cat "$aptf" | grep -qF "$deb_line"  >& /dev/null ); then
    # update sources.d file
    sudo -i true
    if [ -f  "$aptf" ]; then
      sudo cp -v "$aptf" "${aptf}-$(date +%y%m%d%H%M%S).bak"
    fi   
    echo "$deb_line" | sudo tee "$aptf" > /dev/null
  fi
}
