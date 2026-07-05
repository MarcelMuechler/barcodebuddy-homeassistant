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

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Setting ENTRYPOINT resets an inherited CMD to empty, so it must be
# redeclared here or run.sh's "exec $@" has nothing to run.
ENTRYPOINT ["/run.sh"]
CMD ["/app/supervisor"]

