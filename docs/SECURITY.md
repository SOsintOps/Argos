# Security Policy

## Supported Versions

Argos is distributed as a setup script. Only the latest release on the
`master` branch is supported; older tagged versions receive no fixes.

| Version | Supported |
|---------|-----------|
| latest `master` / latest beta | Yes |
| older tags (e.g. 0.5) | No |

## Reporting a Vulnerability

If you find a security issue in the setup script, the launcher scripts, or
the deployed configuration (e.g. the Firefox `policies.json`):

- Preferred: open a private report via the repository **Security** tab on
  GitHub ("Report a vulnerability"), if available.
- Otherwise: open a regular GitHub issue **without** including exploit
  details, and ask for a private contact channel. You can also reach the
  maintainers through [osintops.com](https://osintops.com/).

Please include the affected file, the Ubuntu version, and steps to
reproduce. You should receive an acknowledgement within a reasonable time;
this is a volunteer-maintained project.

## Scope Notes

- `setup.sh` intentionally installs third-party OSINT tools from their
  upstream sources (apt, snap, pipx, GitHub releases). Vulnerabilities in
  those tools should be reported upstream; report here only issues in how
  Argos installs or configures them (e.g. unverified downloads, unsafe
  permissions).
- The script requires `sudo` and is designed for disposable OSINT VMs, not
  hardened production systems.
