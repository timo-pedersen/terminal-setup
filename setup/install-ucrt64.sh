#!/usr/bin/env bash

set -euo pipefail

if [[ "${MSYSTEM:-}" != "UCRT64" ]]; then
    printf 'ERROR: This script must run from an MSYS2 UCRT64 shell.\n' >&2
    printf 'Current MSYSTEM: %s\n' "${MSYSTEM:-<unset>}" >&2
    exit 1
fi

if [[ "${MINGW_PREFIX:-}" != "/ucrt64" ]]; then
    printf 'ERROR: Expected MINGW_PREFIX=/ucrt64, got: %s\n' \
        "${MINGW_PREFIX:-<unset>}" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

msys_manifest="$repo_root/packages/msys.txt"
ucrt64_manifest="$repo_root/packages/ucrt64.txt"

read_manifest() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        printf 'ERROR: Package manifest not found: %s\n' "$file" >&2
        exit 1
    fi

    awk '
        {
            sub(/\r$/, "")
            sub(/[[:space:]]*#.*/, "")
            gsub(/^[[:space:]]+|[[:space:]]+$/, "")
            if (length > 0)
                print
        }
    ' "$file"
}

mapfile -t msys_packages < <(read_manifest "$msys_manifest")
mapfile -t ucrt64_packages < <(read_manifest "$ucrt64_manifest")

printf '\nMSYS2 must be fully updated before installing these packages.\n'
printf 'Run pacman -Suy manually first, restarting MSYS2 and repeating if requested.\n\n'

printf 'MSYS packages:\n'
printf '  %s\n' "${msys_packages[@]}"

printf '\nUCRT64 packages:\n'
printf '  %s\n' "${ucrt64_packages[@]}"

printf '\nInstalling MSYS packages...\n'
pacman -S --needed "${msys_packages[@]}"

printf '\nInstalling UCRT64 packages...\n'
pacman -S --needed "${ucrt64_packages[@]}"

printf '\nPackage installation complete.\n'
printf 'Next: %s/setup/verify.sh\n' "$repo_root"


