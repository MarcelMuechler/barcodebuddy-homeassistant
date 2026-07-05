#!/bin/sh

echo "run.sh: contents of /data/:" >&2
ls -la /data/ >&2 2>&1
echo "run.sh: contents of /config/:" >&2
ls -la /config/ >&2 2>&1

OPTIONS=""
for candidate in /data/options.json /config/options.json; do
  if [ -f "$candidate" ]; then
    OPTIONS="$candidate"
    break
  fi
done
echo "run.sh: using options file: ${OPTIONS:-none found}" >&2

get_opt() {
  if [ -n "$OPTIONS" ]; then
    jq -r --arg k "$1" '.[$k] // empty' "$OPTIONS" 2>/dev/null
  fi
}

GROCY_API_URL=$(get_opt grocy_api_url)
GROCY_API_KEY=$(get_opt grocy_api_key)
REQUIRE_API_KEY=$(get_opt require_api_key)
DISABLE_AUTH=$(get_opt disable_auth)
DEBUG=$(get_opt debug)
SSL_CA=$(get_opt curl_allow_insecure_ssl_ca)
SSL_HOST=$(get_opt curl_allow_insecure_ssl_host)

[ -n "$REQUIRE_API_KEY" ] && export BBUDDY_REQUIRE_API_KEY="$REQUIRE_API_KEY"
[ -n "$DISABLE_AUTH" ] && export BBUDDY_DISABLE_AUTHENTICATION="$DISABLE_AUTH"
[ -n "$DEBUG" ] && export BBUDDY_IS_DEBUG="$DEBUG"
[ -n "$SSL_CA" ] && export BBUDDY_CURL_ALLOW_INSECURE_SSL_CA="$SSL_CA"
[ -n "$SSL_HOST" ] && export BBUDDY_CURL_ALLOW_INSECURE_SSL_HOST="$SSL_HOST"

if [ -n "$GROCY_API_URL" ] && [ -n "$GROCY_API_KEY" ]; then
  export BBUDDY_OVERRIDDEN_USER_CONFIG="GROCY_API_URL=${GROCY_API_URL};GROCY_API_KEY=${GROCY_API_KEY}"
fi

exec "$@"
