FROM f0rc3/barcodebuddy:latest

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Barcode Buddy for Grocy" \
    io.hass.description="Barcode system for Grocy" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION}

RUN apk add --no-cache jq

# The upstream image ships /data as a symlink to /config. Bind-mounting onto a
# symlinked destination is unreliable in Docker (sometimes it shadows the
# link, sometimes it silently doesn't), which made HA's automatic per-addon
# /data mount and our own /config mount race unpredictably. Make /data a
# real, independent directory so both mounts are unambiguous.
RUN rm -f /data && mkdir -p /data

# BarcodeBuddy's env-var override mechanism (loadConfig() in
# configProcessing.inc.php) does `settype($result, gettype($originalVar))`.
# For a const that defaults to null, gettype() returns "NULL", and
# settype($x, "NULL") always yields null - so BBUDDY_EXTERNAL_GROCY_URL can
# never actually take effect against the stock default. Change the default
# to an empty string so gettype() is "string" instead.
RUN sed -i 's/const EXTERNAL_GROCY_URL[[:space:]]*=[[:space:]]*null;/const EXTERNAL_GROCY_URL = "";/' /app/bbuddy/config-dist.php

# sanitizeString() runs product names through FILTER_SANITIZE_FULL_SPECIAL_CHARS,
# which turns "Süßer Senf" into "S&uuml;&szlig;er Senf". The "Create Product"
# link then only calls htmlspecialchars_decode() (undoes &amp;/&lt;/&gt;/&quot;/&#039;
# only) instead of html_entity_decode() (undoes named entities like &uuml;
# too), so those entities are still there when the name is sent to Grocy.
RUN sed -i 's/htmlspecialchars_decode(\$item\[.name.\], ENT_QUOTES)/html_entity_decode($item["name"], ENT_QUOTES)/' /app/bbuddy/index.php

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Setting ENTRYPOINT resets an inherited CMD to empty, so it must be
# redeclared here or run.sh's "exec $@" has nothing to run.
ENTRYPOINT ["/run.sh"]
CMD ["/app/supervisor"]

