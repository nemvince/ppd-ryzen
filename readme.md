# tuned-ryzenadj

Bridge [tuned](https://github.com/redhat-performance/tuned) /
[power-profiles-daemon](https://gitlab.freedesktop.org/upower/power-profiles-daemon)
profile changes to [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) power limits
on AMD laptops.

Switch between *power-saver*, *balanced*, and *performance* in your desktop
environment's power menu and have your STAPM / PPT / Tctl limits follow along
automatically.

## Why

`power-profiles-daemon` (PPD) on CachyOS and other Arch-based distros is known
to fail on AMD APUs with:

```
Failed to activate CPU driver 'amd_pstate': Error writing
'/sys/devices/system/cpu/cpufreq/policy11/boost': Invalid argument (13)
```

Switching to `tuned` + `tuned-ppd` (PPD compatibility layer) fixes the D-Bus
error. This project adds the next layer: making `ryzenadj` limits follow the
active profile.

## Requirements

- Linux with kernel `amd_pstate` support (5.17+)
- [`ryzenadj`](https://github.com/FlyGoat/RyzenAdj) (AUR: `ryzenadj`)
- `tuned` and `tuned-ppd` (packages: `tuned tuned-ppd` on Arch / CachyOS)
- Root access for installation

Tested on: **ThinkPad T14s Gen 2a**, Ryzen 7 5850U, CachyOS.

## Install

### AUR

```bash
yay -S tuned-ryzenadj
sudo systemctl enable --now tuned tuned-ppd
```

### From source (any distro with `make`)

```bash
git clone https://github.com/<you>/tuned-ryzenadj.git
cd tuned-ryzenadj
sudo ./install.sh
```

The installer will:

1. Copy files into `/usr/lib/ryzenadj-tuned/`, `/etc/tuned/profiles/`, and
   `/etc/tuned/`.
2. Create `/etc/tuned/ryzenadj-limits.conf` from the packaged defaults
   (never overwrites an existing file).
3. Mask `power-profiles-daemon.service` and enable `tuned` + `tuned-ppd`.
4. Reload `tuned-ppd`.

Pass `--destdir <dir>` for packaging. Pass `--no-services` to skip the
systemd handling.

### Manual

```bash
sudo make install
sudo systemctl mask --now power-profiles-daemon.service
sudo systemctl enable --now tuned tuned-ppd
```

## Configuration

Edit **`/etc/tuned/ryzenadj-limits.conf`** to change the limits for each
profile:

```bash
RYZENADJ_POWERSAVE_ARGS="--stapm-limit=15000 --fast-limit=20000 --slow-limit=15000 --tctl-temp=80"
RYZENADJ_BALANCED_ARGS="--stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=85"
RYZENADJ_PERFORMANCE_ARGS="--stapm-limit=30000 --fast-limit=35000 --slow-limit=30000 --tctl-temp=90"
```

Changes take effect on the next profile activation. To re-apply immediately:

```bash
sudo tuned-adm profile ryzenadj-balanced
```

### Mapping PPD names → tuned profiles

`tuned-ppd` reads `/etc/tuned/ppd.conf` for the mapping. The installer drops a
sample in; verify the format against your `tuned-ppd` version if the mapping
doesn't take effect.

```ini
[profiles]
power-saver=ryzenadj-powersave
balanced=ryzenadj-balanced
performance=ryzenadj-performance
```

### Applying profiles

Either of these works:

```bash
# Via PPD compatibility layer
powerprofilesctl set balanced

# Or directly via tuned
sudo tuned-adm profile ryzenadj-performance
```

## Optional: re-apply on resume

The `[script]` plugin runs `apply.sh` only when a profile is *loaded*. If your
limits reset after suspend/resume on your firmware, enable the polling service:

```bash
sudo systemctl enable --now ryzenadj-tuned-poll.service
```

It re-applies the active profile's limits every 15 seconds — cheap, and it
catches any external overwrite.

## Verifying

```bash
# Current profile
tuned-adm active

# Actual limits
sudo ryzenadj --info | grep -Ei 'stapm|ppt|tctl'

# Service logs
journalctl -u tuned -u tuned-ppd -u ryzenadj-tuned-poll -f
```

## Uninstall

```bash
sudo ./uninstall.sh
```

Keeps `/etc/tuned/ryzenadj-limits.conf` unless `--purge` is passed.

## Troubleshooting

**`powerprofilesctl` still errors about `amd_pstate`**
Make sure `power-profiles-daemon.service` is masked:

```bash
systemctl status power-profiles-daemon.service
```

**Profile changes but limits don't**
Check `journalctl -u tuned -f` while switching profiles. If `apply.sh` isn't
running, verify the profile was installed:

```bash
ls /etc/tuned/profiles/ryzenadj-*/
tuned-adm profile_info ryzenadj-balanced
```

**Ryzen 7 5850U clamps at 25W STAPM**
Known firmware behaviour on some Cezanne parts. Use `--slow-limit` instead of
`--stapm-limit` to push sustained power.

## License

MIT — see [LICENSE](LICENSE).
