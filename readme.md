# ryzenadj-ppd-bridge

Bridges `power-profiles-daemon` profile switches to `ryzenadj` power limits on AMD laptops. Built and tested on a ThinkPad T14s Gen 2a with a Ryzen 7 5850U.

Run `powerprofilesctl set balanced`, or flip the toggle in your DE, and your STAPM, fast/slow limit and tctl settings get re-applied with it. No `sudo ryzenadj` by hand anymore.

## The problem it solves

`power-profiles-daemon` has no hook for running something on a profile change. This daemon watches the D-Bus `PropertiesChanged` signal instead, reads the new `ActiveProfile`, and fires off the matching `ryzenadj` command.

The symptom it was written for: a 5850U under sustained load sinking to its 1.9 GHz base clock because the STAPM budget ran dry.

## What it does

- Three profiles, `power-saver`, `balanced` and `performance`, each with its own `ryzenadj` argument set.
- Lives in `/etc/ryzenadj-ppd.conf`, so changing limits does not need a rebuild.
- `--once` runs a single pass and exits, for testing without the daemon.
- The systemd unit is locked down: no new privileges, strict filesystem paths, minimal capability set.
- Ships sane defaults for three T14s Gen 2a use cases.

## Requirements

- Linux with `power-profiles-daemon`. TLP does not work here, see the warning below.
- `ryzenadj` on PATH, expected at `/usr/bin/ryzenadj`.
- systemd and dbus.
- An AMD CPU that both `ryzenadj` and `amd-pstate` support.

## Install

Arch, CachyOS, Manjaro:

```bash
yay -S ryzenadj-ppd-bridge
```

From the release tarball:

```bash
tar -xzf ryzenadj-ppd-bridge-*.tar.gz
cd ryzenadj-ppd-bridge-*
sudo ./scripts/install.sh
```

From source:

```bash
git clone https://github.com/YOURUSER/ryzenadj-ppd-bridge
cd ryzenadj-ppd-bridge
sudo make install
```

## Configure

Edit `/etc/ryzenadj-ppd.conf`:

```bash
POWER_SAVER_ARGS="--stapm-limit=15000 --fast-limit=20000 --slow-limit=15000 --tctl-temp=80"
BALANCED_ARGS="--stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=85"
PERFORMANCE_ARGS="--stapm-limit=30000 --fast-limit=35000 --slow-limit=30000 --tctl-temp=90"
```

Then:

```bash
sudo systemctl restart ryzenadj-ppd.service
```

## Enable

```bash
sudo systemctl enable --now ryzenadj-ppd.service
```

Watch it work:

```bash
journalctl -u ryzenadj-ppd.service -f
# other terminal:
powerprofilesctl set performance
```

The log should show the new profile and the `ryzenadj` command it ran.

## Testing without the service

```bash
sudo /usr/local/bin/ryzenadj-ppd-bridge --once
```

## Uninstall

```bash
sudo ./scripts/uninstall.sh
# or from a checkout:
sudo make uninstall
```

`/etc/ryzenadj-ppd.conf` survives an uninstall.

## Not compatible with TLP

`power-profiles-daemon` and TLP both own power management and will fight. Pick one. On TLP, drop PPD and use its `RUNTIME_PM_*` and `CPU_*` variables instead.

## The 25 W firmware ceiling on the 5850U

Some 5850U laptops clamp STAPM at 25 W in firmware no matter what `ryzenadj` asks for. If `--stapm-limit` above 25000 changes nothing, push sustained power through `--slow-limit` instead.

## Development

```bash
make lint      # shellcheck + shfmt
make test      # smoke tests, no root needed
make package   # builds dist/*.tar.gz
```

## License

MIT, see [LICENSE](LICENSE).
