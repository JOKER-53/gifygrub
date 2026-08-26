# Contributing to gifygrub

Thanks for wanting to contribute! This project follows a simple 3-branch model — please read this before opening a PR.

## Branch model

| Branch | Purpose |
|---|---|
| `main` | Stable, working code only. Protected — merges only via reviewed PR. |
| `Development` | Active work and testing happens here. **Branch your feature branches off this.** |
| `Docs` | Documentation only. No application code. |

### Workflow

1. Fork the repo
2. Branch off `Development`: `git checkout -b feature/my-change Development`
3. Make your change, test it locally on a real GRUB2 install (a VM is fine — **do not test destructive install steps on your only machine**)
4. Open a PR **into `Development`**, not `main`
5. Once a set of changes on `Development` is stable and tested, a maintainer merges `Development` → `main`

Documentation-only changes (README, wiki content, comments-as-docs) should target the `Docs` branch instead.

## Code style

- Keep the CLI dependency-light — avoid adding new external dependencies without discussion in an issue first
- Match existing shell/Python style in the file you're editing
- Any change touching the install step (`/boot/grub/` writes) needs a clear description of what was tested and how

## Reporting bugs / requesting features

Use the issue templates:
- [Bug report](.github/ISSUE_TEMPLATE/bugreport.md)
- Feature requests: open a normal issue describing the use case

## Pull requests

Use the [PR template](.github/PULL_REQUEST.md) — it's auto-applied when you open a PR.

## Code of conduct

Be respectful. This is a community tool for the Linux customization / r/unixporn crowd — keep discussion constructive.
