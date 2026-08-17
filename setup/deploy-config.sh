#!/usr/bin/env bash

set -euo pipefail

if [[ "${MSYSTEM:-}" != "UCRT64" ]]; then
    printf 'ERROR: Run this script from MSYS2 UCRT64.\n' >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

deploy_file() {
    local source="$1"
    local destination="$2"

    if [[ ! -f "$source" ]]; then
        printf 'ERROR: Source file not found: %s\n' "$source" >&2
        exit 1
    fi

    mkdir -p "$(dirname -- "$destination")"

    if [[ -f "$destination" ]] && cmp -s "$source" "$destination"; then
        printf '[OK]   Already current: %s\n' "$destination"
        return
    fi

    if [[ -f "$destination" ]]; then
        local backup
        backup="${destination}.bak.$(date '+%Y%m%d-%H%M%S')"

        cp -- "$destination" "$backup"
        printf '[BACKUP] %s\n' "$backup"
    fi

    cp -- "$source" "$destination"
    printf '[DEPLOY] %s -> %s\n' "$source" "$destination"
}

deploy_file \
    "$repo_root/wezterm/.wezterm.lua" \
    "$USERPROFILE/.wezterm.lua"

deploy_file \
    "$repo_root/bash/.bashrc" \
    "$HOME/.bashrc"

deploy_file \
    "$repo_root/bash/.bash_profile" \
    "$HOME/.bash_profile"

deploy_file \
    "$repo_root/starship/starship.toml" \
    "$HOME/.config/starship.toml"

deploy_file \
    "$repo_root/ripgrep/.ripgreprc" \
    "$USERPROFILE/.config/.ripgreprc"

# Deploy wrapper local to MSYS2, hard coded path (reachable from Windows at C:\msys64\usr\local\bin\open-with-neovim.cmd). 
# Reason is %USERPROFILE% does not expand correctly in registry.
deploy_file \
    "$repo_root/windows/integration/open-with-neovim.cmd" \
    "/usr/local/bin/open-with-neovim.cmd"

printf '\nConfiguration deployment complete.\n'
