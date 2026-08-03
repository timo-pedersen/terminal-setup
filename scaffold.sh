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
````

## Ownership boundaries

Windows owns:

* WezTerm
* Git
* .NET SDK
* Windows fonts
* GUI applications

MSYS2 UCRT64 owns:

* Bash
* Unix command-line tools
* UCRT64-native command-line applications
* Terminal configuration deployment

Neovim configuration is maintained in a separate repository.
EOF

write_if_missing docs/fresh-machine.md <<'EOF'

# Fresh-machine setup

## Manual Windows installation

Install manually:

* Git for Windows
* WezTerm
* MSYS2
* Neovim, when a separate Windows installation is wanted

## Update MSYS2

From an MSYS2 terminal:

```bash
pacman -Suy
```

If MSYS2 requests that all terminals be closed, close them, reopen UCRT64 and run:

```bash
pacman -Suy
```

Repeat until the system is fully updated.

## Continue setup

From the repository root in UCRT64:

```bash
./setup/install-ucrt64.sh
./setup/deploy-config.sh
./setup/verify.sh
```

EOF

write_if_missing packages/msys.txt <<'EOF'

# Packages provided by the MSYS repository.

base-devel
openssh
tmux
unzip
zip
EOF

write_if_missing packages/ucrt64.txt <<'EOF'

# Native UCRT64 packages.

mingw-w64-ucrt-x86_64-fd
mingw-w64-ucrt-x86_64-fzf
mingw-w64-ucrt-x86_64-neovim
mingw-w64-ucrt-x86_64-nodejs
mingw-w64-ucrt-x86_64-ripgrep
mingw-w64-ucrt-x86_64-starship
EOF

write_if_missing setup/install-ucrt64.sh <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

printf '%s\n' 
'TODO: install packages from packages/msys.txt and packages/ucrt64.txt.' 
'MSYS2 must be fully updated manually before running this script.'
EOF

write_if_missing setup/deploy-config.sh <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

printf '%s\n' 
'TODO: deploy configuration files.' 
'Existing destination files must be backed up before replacement.'
EOF

write_if_missing setup/verify.sh <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

printf '%s\n' 
'TODO: verify UCRT64, Windows Git, Windows .NET and installed tools.'
EOF

# Git cannot track empty directories, so retain the future config directories.

for directory in bash fd fzf git ripgrep starship wezterm; do
if [[ ! -e "$directory/.gitkeep" ]]; then
: >"$directory/.gitkeep"
printf 'Creating: %s/.gitkeep\n' "$directory"
fi
done

chmod +x setup/install-ucrt64.sh setup/deploy-config.sh setup/verify.sh

printf '\nRepository scaffold complete.\n\n'
printf 'Review it with:\n'
printf '  git status --short\n'
printf '  find . -maxdepth 2 -type f | sort\n'

