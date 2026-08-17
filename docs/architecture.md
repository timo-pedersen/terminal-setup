# Architecture

## Primary environment

Windows 11
└── WezTerm
    └── MSYS2 UCRT64
        └── Bash

UCRT64 is the normal interactive shell environment. Git Bash remains available
as a secondary launcher but is not the primary environment.

Ownership boundaries

### Windows owns
- WezTerm
- Git for Windows
- .NET SDK
- Windows fonts
- GUI applications
- shared ripgrep configuration

### MSYS2 UCRT64 owns
- Bash
- Unix command-line tools
- UCRT64-native applications
- Starship
- terminal configuration deployment

Neovim configuration is maintained in a separate repository. This repository
only installs the UCRT64 Neovim executable.

## Home directories

Keep the two home roots separate:

MSYS2:   /home/<user>
Windows: %USERPROFILE%

Do not try to make MSYS2 HOME equal the Windows user profile.

Bridge Windows-native tools explicitly where required.

## Windows tools used from UCRT64

Git for Windows is authoritative:

```bash
export PATH="/c/Program Files/Git/cmd:$PATH"
export GIT_CONFIG_GLOBAL="$(cygpath -m "$USERPROFILE")/.gitconfig"
```

The Windows .NET SDK is authoritative:

```bash
export PATH="/c/Program Files/dotnet:$PATH"
```

Do not install separate MSYS2 versions of Git or .NET for the primary workflow.

## Configuration ownership

Repository                     Deployed to

bash/bashrc                  -> ~/.bashrc
bash/bash_profile            -> ~/.bash_profile
starship/starship.toml       -> ~/.config/starship.toml
ripgrep/ripgreprc            -> %USERPROFILE%/.config/.ripgreprc
wezterm/wezterm.lua          -> %USERPROFILE%/.wezterm.lua

Starship is UCRT64-specific, so its configuration lives under the MSYS2 home.

ripgrep is used from both Windows CMD and UCRT64, so both installations share
the Windows-side configuration.

WezTerm is Windows-owned, so its live configuration stays under
%USERPROFILE%.

setup/deploy-config.sh owns deployment and backs up an existing destination
before replacing it.


