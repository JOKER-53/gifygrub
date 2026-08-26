# Security Policy

## Why security matters here

gifygrub writes to `/boot/grub/` and runs `update-grub`, which affects whether a machine boots at all. A bug or malicious contribution here has a higher blast radius than typical userland software — please report issues responsibly.

## Supported versions

| Branch | Supported |
|---|---|
| `main` | ✅ |
| `Development` | ⚠️ best-effort, unstable by definition |
| `Docs` | N/A (no code) |

## Reporting a vulnerability

**Do not open a public issue for security vulnerabilities.**

Instead:
1. Open a [GitHub Security Advisory](../../security/advisories/new) on this repo (private to maintainers), **or**
2. If that's unavailable, contact the maintainer directly via the profile linked on the [KADHIRAVANEG GitHub profile](https://github.com/KADHIRAVANEG)

Please include:
- A clear description of the vulnerability
- Steps to reproduce
- Potential impact (especially anything that could brick a boot partition or corrupt `/boot/grub/`)
- Suggested fix, if you have one

## What counts as in-scope

- Anything in the frame-extraction, `theme.txt` generation, or install pipeline that could corrupt `/boot/grub/` or leave GRUB unbootable
- Path traversal / injection via crafted GIF filenames or theme names
- Privilege escalation via the install step (which requires root)

## Response

We'll acknowledge reports within a reasonable timeframe and aim to patch confirmed issues on `Development` before merging a fix to `main`.
