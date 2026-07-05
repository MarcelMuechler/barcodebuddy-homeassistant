# BarcodeBuddy Homeassistant Docker Image


![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg


This is the docker repo optimized for Home Assistant of [BarcodeBuddy](https://github.com/Forceu/barcodebuddy).

This is a fork of [Forceu/barcodebuddy-homeassistant](https://github.com/Forceu/barcodebuddy-homeassistant) that fixes two long-standing issues:

- **Config was lost on every restart/update** ([upstream #4](https://github.com/Forceu/barcodebuddy-homeassistant/issues/4)): the add-on mapped Home Assistant's own `config` directory onto the container's `/config` path, which is where BarcodeBuddy actually stores its database and settings. Fixed by switching to the `addon_config` map type, which gives the add-on its own persistent, add-on-private folder at that same container path.
- **Couldn't connect to a Grocy add-on running behind Ingress** ([upstream discussion #223](https://github.com/Forceu/barcodebuddy/discussions/223)): BarcodeBuddy's setup wizard wants a plain `IP:port/api/` URL, which Ingress doesn't provide. This fork adds `grocy_api_url` / `grocy_api_key` options that are passed straight into BarcodeBuddy via its `BBUDDY_OVERRIDDEN_USER_CONFIG` environment variable at startup, skipping the wizard entirely. The other add-on options (`require_api_key`, `disable_auth`, `debug`, `curl_allow_insecure_ssl_*`) are now also actually wired up (previously they were declared but never applied).

### Install Home Assistant

![](images/add-repo-url.png?raw=true)
1. Click context menu in addon section
2. Add custom repo url and point to this repo: `https://github.com/MarcelMuechler/barcodebuddy-homeassistant`

### Configuration

Set `grocy_api_url` and `grocy_api_key` in the add-on's Configuration tab. For the URL, use Grocy's **internal container IP and Ingress port** (not the default 80/443 — Grocy's own Ingress-enabled web server listens on the Supervisor-assigned Ingress port, e.g.:

```
http://172.30.33.2:8099/api/
```

Find the container IP via the Grocy add-on's info page in Supervisor (or `ha_get_addon`/the REST API) and the Ingress port via the same (`ingress_port` field). Both add-ons sit on Supervisor's internal Docker network, so no host port needs to be exposed for this to work.

If you use the "Create Product" / "Create recipe" etc. links from BarcodeBuddy, also set `grocy_external_url` to a URL your **browser** can reach (the internal container IP is only reachable from other add-ons, not from your phone/PC) — e.g. Grocy's directly-mapped host port:

```
https://192.168.1.x:8080/
```

(map Grocy's `80/tcp` to a host port in its own add-on's Network tab first).

## Contributors
<a href="https://github.com/forceu/barcodebuddy-homeassistant/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=forceu/barcodebuddy-homeassistant" />
</a>

## License
The MIT License (MIT)

Based on: https://github.com/linuxserver/docker-grocy

## Donations

As with all Free software, the power is less in the finances and more in the collective efforts. I really appreciate every pull request and bug report offered up by BarcodeBuddy's users, so please keep that stuff coming. If however, you're not one for coding/design/documentation, and would like to contribute financially, you can do so with the link below. Every help is very much appreciated!

[![paypal](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=donate@bulling.mobi&lc=US&item_name=BarcodeBuddy&no_note=0&cn=&currency_code=EUR&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted) [![LiberaPay](https://img.shields.io/badge/Donate-LiberaPay-green.svg)](https://liberapay.com/MBulling/donate)
