# Barcode Buddy for Grocy — Home Assistant Add-on

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

Runs [BarcodeBuddy](https://github.com/Forceu/barcodebuddy) — a barcode scanning
front-end for [Grocy](https://grocy.info/) — as a Home Assistant add-on,
with configuration wired up for Grocy add-ons running behind Supervisor's
Ingress.

This is a maintained fork of
[Forceu/barcodebuddy-homeassistant](https://github.com/Forceu/barcodebuddy-homeassistant),
rebuilt to work reliably as an add-on rather than as a thin, unconfigured
wrapper around the upstream Docker image. See [Compatibility notes](#compatibility-notes)
for what specifically changed and why.

## Features

- Scan barcodes and add/consume/open products in Grocy from a phone,
  browser, or a physical scanner
- Connects to a Grocy add-on running behind Ingress — no need to expose
  Grocy's port to your host network
- Add-on options map directly to BarcodeBuddy's configuration, so it can be
  fully configured without going through the first-run setup wizard
- Configuration persists correctly across add-on restarts and updates

## Installation

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**
2. Open the **⋮** menu (top right) → **Repositories**
3. Add: `https://github.com/MarcelMuechler/barcodebuddy-homeassistant`
4. Install **Barcode Buddy for Grocy** from the store listing

## Configuration

| Option | Type | Description |
|---|---|---|
| `grocy_api_url` | string | Grocy's API URL, reachable from *this* add-on's container. For a Grocy add-on running behind Ingress, use its container IP and Ingress port (not 80/443) — e.g. `http://172.30.33.2:8099/api/`. Find both via the Grocy add-on's info page in Supervisor (`ingress_port` field). |
| `grocy_api_key` | password | A Grocy API key (Grocy → user profile → **Manage API keys**). |
| `grocy_external_url` | string | Optional. A URL *your browser* can reach, used for links like "Create Product" that open Grocy directly. Leave empty to fall back to `grocy_api_url` (usually not browser-reachable if Grocy runs behind Ingress). |
| `require_api_key` | boolean | Require an API key for BarcodeBuddy's own REST API. |
| `disable_auth` | boolean | Disable BarcodeBuddy's user login. |
| `debug` | boolean | Enable verbose logging. |
| `curl_allow_insecure_ssl_ca` | boolean | Accept self-signed/untrusted CA certificates when connecting to Grocy. |
| `curl_allow_insecure_ssl_host` | boolean | Accept a certificate hostname mismatch when connecting to Grocy (common when connecting by internal IP rather than the certificate's hostname). |

Both add-ons sit on Supervisor's internal Docker network by default, so
container-to-container traffic doesn't need any host port exposed. If you
want "Create Product"-style links to open correctly in a browser, map
Grocy's `80/tcp` to a host port in its own add-on's **Network** tab and
point `grocy_external_url` at that.

## Compatibility notes

A few upstream behaviors required a workaround to run reliably as an
add-on; noted here so they're not mistaken for bugs in this fork later:

- **Persistent storage**: the upstream Docker image ships `/data` as a
  symlink to `/config`. Home Assistant's automatic per-add-on `/data` mount
  and this add-on's own `/config` mount both resolve to that same path,
  which raced unpredictably. The image is rebuilt here with `/data` as an
  independent real directory.
- **`EXTERNAL_GROCY_URL`**: BarcodeBuddy's environment-variable config
  override can't set this value away from its default (a `settype()` call
  against a `null`-typed default always yields `null`, regardless of
  input). The default is patched to an empty string so the override takes
  effect.
- **Umlauts/special characters in product names**: the "Create Product"
  link builder decodes HTML entities with `htmlspecialchars_decode()`,
  which doesn't handle named entities like `&uuml;`. Patched to
  `html_entity_decode()`.

## Development

The image is a thin layer on top of `f0rc3/barcodebuddy` — see
[`Dockerfile`](Dockerfile) for the patches applied at build time and
[`run.sh`](run.sh) for how add-on options are translated into BarcodeBuddy's
`BBUDDY_*` environment variables. Bump `version` in `config.yaml` when
changing either, so Supervisor picks up the update.

Contributions and issue reports are welcome.

## License

MIT — see [`LICENSE`](LICENSE).

Based on [Forceu/barcodebuddy-homeassistant](https://github.com/Forceu/barcodebuddy-homeassistant)
and [Forceu/barcodebuddy-docker](https://github.com/Forceu/barcodebuddy-docker).
Consider supporting BarcodeBuddy's original author directly:
[PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=donate@bulling.mobi&lc=US&item_name=BarcodeBuddy&no_note=0&cn=&currency_code=EUR&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted) ·
[LiberaPay](https://liberapay.com/MBulling/donate)
