#!/usr/bin/env bash

set -euo pipefail

if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    printf 'Error: run this inside the cloned terminal-setup Git repository.\n' >&2
    exit 1
fi

cd "$repo_root"

write_if_missing() {
    local path="$1"

    mkdir -p "$(dirname "$path")"

    if [[ -e "$path" ]]; then
        printf 'Keeping existing file: %s\n' "$path"
        cat >/dev/null
        return
    fi

    printf 'Creating: %s\n' "$path"
    cat >"$path"
}

directories=(
    bash
    docs
    fd
    fzf
    git
    packages
    ripgrep
    setup
    starship
    wezterm
)

for directory in "${directories[@]}"; do
    mkdir -p "$directory"
done

write_if_missing README.md <<'EOF'
# terminal-setup

Reproducible terminal environment for Windows 11.

## Intended environment

- WezTerm
- MSYS2 UCRT64
- Bash
- Windows Git
- Windows .NET SDK
- Neovim executable only; Neovim configuration belongs in a separate repository

## Setup stages

1. Manually install or update Windows applications.
2. Manually fully update MSYS2.
3. Run `setup/install-ucrt64.sh`.
4. Run `setup/deploy-config.sh`.
5. Run `setup/verify.sh`.
EOF

write_if_missing docs/architecture.md <<'EOF'
# Architecture

## Environment

The primary terminal environment is:

```text
Windows 11
└── WezTerm
    └── MSYS2 UCRT64
        └── Bash
