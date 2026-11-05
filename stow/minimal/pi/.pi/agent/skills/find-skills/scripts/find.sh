#!/usr/bin/env bash
#   find.sh <query>
#
# Prints "installs  source  skillId  page". Exit: 0 rows, 3 nothing indexed, 4 query under two
# characters, 5 index unreachable.
set -euo pipefail

# Quoted or not: the words are the query either way.
q="$*"
: "${q:?usage: find.sh <query>}"

# The fields are attacker-controlled text: strip control and bidi characters before printing.
format() {
  jq -r '.skills[] | [(.installs|tostring), .source, .skillId, "https://skills.sh/\(.source)/\(.skillId)"]
    | map(gsub("[\u0000-\u001f\u007f-\u009f\u200b-\u200f\u202a-\u202e\u2066-\u2069]"; "")) | @tsv' || true
}

# One query's rows for display. Ten is enough because the index ranks by relevance.
search() {
  curl -sS --max-time 15 -f "https://skills.sh/api/search?q=$(printf %s "$1" | jq -sRr @uri)&limit=10" | format
}

# One request: the body is the answer, the status trails it. A failed fetch must not be read as an
# empty index, so the status decides the exit code before any row is printed.
resp=$(curl -sS --max-time 15 -w '\n%{http_code}' \
  "https://skills.sh/api/search?q=$(printf %s "$q" | jq -sRr @uri)&limit=10") || resp=$'\n000'
code=${resp##*$'\n'}
case $code in
200) ;;
400)
  echo "query too short: the index needs at least 2 characters" >&2
  exit 4
  ;;
*)
  echo "index unreachable (http $code)" >&2
  exit 5
  ;;
esac
exact=$(printf '%s' "${resp%$'\n'*}" | format)
n=$(printf '%s' "$exact" | grep -c . || true)

# Recover recall: a 2-6-word query is often answered only in part, so drop each word once and retry.
# Nothing ranks those rows, so they are capped and de-duplicated, and the caller labels them weak.
fallback() {
  read -ra t <<<"$q"
  { [ "${#t[@]}" -ge 2 ] && [ "${#t[@]}" -le 6 ]; } || return 0
  d=$(mktemp -d)
  trap 'rm -rf "$d"' EXIT
  for i in "${!t[@]}"; do
    sub=("${t[@]:0:i}" "${t[@]:i+1}")
    w=${sub[*]}
    [ "${#w}" -ge 2 ] || continue
    search "$w" >"$d/$i" &
  done
  wait || true
  files=("$d"/*)
  [ -e "${files[0]:-}" ] || return 0
  awk -F'\t' '!seen[$2"/"$3]++ {print; if (++c==15) exit}' "${files[@]}"
}

# Exact rows are printed first and always survive the de-dupe, so the label belongs right before the
# first row after them: that is what keeps it absent when nothing weaker was found. It is added after
# `column` so one long label does not widen the numbers column.
out=$(
  {
    [ -z "$exact" ] || printf '%s\n' "$exact"
    [ "$n" -ge 10 ] || fallback
  } | awk -F'\t' '!seen[$2"/"$3]++'
)
[ -n "$out" ] || {
  echo "nothing indexed for \"$q\"" >&2
  exit 3
}
printf '%s\n' "$out" | column -t -s $'\t' |
  awk -v n="$n" -v hdr="partial matches (some terms of \"$q\"):" 'NR == n + 1 {print hdr} {print}'
