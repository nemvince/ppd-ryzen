# Changelog

All notable changes to this project are documented here.
This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-01

### Added
- Initial release.
- `ryzenadj-ppd` daemon that mirrors power-profiles-daemon
  profile changes onto ryzenadj power limits.
- `--once`, `--version`, and `--help` CLI flags.
- Configurable limits via `/etc/ryzenadj-ppd.conf`.
- systemd unit `ryzenadj-ppd.service` with hardening.
- `install.sh`, `uninstall.sh`, `build-package.sh` scripts.
- `Makefile` with `install`, `uninstall`, `package`, `test`, `lint`.
- GitHub Actions CI (shellcheck, shfmt, smoke tests, tarball).
- Tag-driven release workflow.
- PKGBUILD for Arch/AUR.
