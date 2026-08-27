#!/usr/bin/env bash
# gifygrub::install_theme WORKDIR THEME_NAME
#
# Copies the generated theme into /boot/grub/themes/THEME_NAME and runs
# update-grub. Requires root. THEME_NAME is validated by bin/gifygrub before
# this is ever called (alnum/-/_ only) — do not call this directly with an
# unsanitized name.

gifygrub::install_theme() {
    local workdir="$1"
    local theme_name="$2"
    local install_dir="/boot/grub/themes/${theme_name}"

    if [[ "$EUID" -ne 0 ]]; then
        echo "error: installing to /boot/grub/ requires root. Re-run with sudo." >&2
        exit 1
    fi

    if [[ ! -d /boot/grub ]]; then
        echo "error: /boot/grub not found — is GRUB2 installed on this system?" >&2
        exit 1
    fi

    if [[ -d "$install_dir" ]]; then
        echo "    existing theme found at ${install_dir}, backing up to ${install_dir}.bak"
        rm -rf "${install_dir}.bak"
        mv "$install_dir" "${install_dir}.bak"
    fi

    mkdir -p "$install_dir"
    cp -r "$workdir"/* "$install_dir"/

    gifygrub::_set_grub_theme "$install_dir"

    if command -v update-grub &> /dev/null; then
        update-grub
    elif command -v grub-mkconfig &> /dev/null; then
        grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo "warning: could not find update-grub or grub-mkconfig." >&2
        echo "         run your distro's GRUB config regeneration command manually." >&2
    fi
}

gifygrub::_set_grub_theme() {
    local install_dir="$1"
    local grub_default="/etc/default/grub"

    if [[ ! -f "$grub_default" ]]; then
        echo "warning: ${grub_default} not found — set GRUB_THEME manually." >&2
        return
    fi

    cp "$grub_default" "${grub_default}.gifygrub.bak"

    if grep -q '^GRUB_THEME=' "$grub_default"; then
        sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${install_dir}/theme.txt\"|" "$grub_default"
    else
        echo "GRUB_THEME=\"${install_dir}/theme.txt\"" >> "$grub_default"
    fi

    echo "    updated GRUB_THEME in ${grub_default} (backup saved as ${grub_default}.gifygrub.bak)"
}
