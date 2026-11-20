#!/bin/bash
# Upload already-generated thumbnail JPGs to Airtable via the n8n webhook.
# Usage: airtable_upload.sh /path/to/thumbnails/a.jpg [/path/to/b.jpg ...]
#
# Mirrors /Users/Shared/airtable_uploader.sh (used by the "Upload to Airtable"
# Shortcut for stills): same webhook, same form fields, same log file. The job
# code comes from the nearest parent folder named like 12345_Something.

WEBHOOK="https://urbanstudionyc.app.n8n.cloud/webhook/airtable-thumb-upload"
LOG_FILE="${HOME}/.airtable-thumbnails.log"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
  printf '%s\n' "$1"
}
notify() {
  /usr/bin/osascript -e "display notification \"$1\" with title \"Airtable Thumbs\"" 2>/dev/null || true
  log "NOTIFY: $1"
}

find_job() {
  local p="$1" bn
  while [[ "$p" != "/" && -n "$p" ]]; do
    bn="$(basename "$p")"
    if [[ "$bn" =~ ^([0-9]{5})_.+ ]]; then
      printf '%s|%s\n' "${BASH_REMATCH[1]}" "$bn"
      return 0
    fi
    p="$(dirname "$p")"
  done
  return 1
}

TOTAL=0; OK=0; FAIL=0; FAILED=""; LAST_JOB=""
RESP="$(mktemp -t airtable_upload)"

log "=== Video thumbnail upload started (${#} file(s)) ==="

for jpg in "$@"; do
  TOTAL=$((TOTAL+1))
  name="$(basename "$jpg")"
  if [[ ! -f "$jpg" ]]; then
    log "ERROR: thumbnail missing: $jpg"
    FAIL=$((FAIL+1)); FAILED="$FAILED $name(missing)"; continue
  fi
  if ! jf="$(find_job "$(dirname "$jpg")")"; then
    log "No job folder match for $jpg; not uploaded"
    FAIL=$((FAIL+1)); FAILED="$FAILED $name(no-job)"; continue
  fi
  JOB_CODE="${jf%%|*}"; JOB_FOLDER="${jf#*|}"; LAST_JOB="$JOB_CODE"
  log "POST $name -> job $JOB_CODE ($JOB_FOLDER)"

  code="$(curl -sS -o "$RESP" -w '%{http_code}' --retry 2 --retry-delay 1 \
    -F "file=@${jpg};type=image/jpeg" \
    -F "job_code=${JOB_CODE}" \
    -F "job_folder=${JOB_FOLDER}" \
    -F "filename=${name}" \
    -F "job_code_num=${JOB_CODE}" \
    -F "job_folder_escaped=${JOB_FOLDER//\"/\\\"}" \
    "$WEBHOOK" 2>>"$LOG_FILE")" || code="000"

  log "Webhook HTTP $code: $(head -c 500 "$RESP")"
  # Space uploads out: each n8n run makes several Airtable calls, and Airtable
  # rate-limits a base at ~5 requests/second (HTTP 429).
  sleep 2
  if [[ "$code" == 2?? ]]; then
    OK=$((OK+1))
  else
    FAIL=$((FAIL+1)); FAILED="$FAILED $name(HTTP $code)"
  fi
done
rm -f "$RESP"

log "=== Video thumbnail upload complete: ${OK}/${TOTAL} uploaded, ${FAIL} failed ==="
if (( TOTAL == 0 )); then
  :
elif (( FAIL == 0 )); then
  notify "✅ All ${OK} video thumbnails uploaded to Airtable → job ${LAST_JOB}"
else
  log "Failed:$FAILED"
  notify "⚠️ ${OK}/${TOTAL} video thumbnails uploaded — ${FAIL} failed. See ~/.airtable-thumbnails.log"
fi
(( FAIL == 0 ))
