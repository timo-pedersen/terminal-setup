# terminal-setup

Reproducible terminal environment for Windows 11.

## Environment

- WezTerm
- MSYS2 UCRT64
- Bash
- Windows Git
- Windows .NET SDK
- Neovim executable only; Neovim configuration lives in a separate repository

## Setup

1. Manually install Git for Windows, WezTerm and MSYS2.
2. Fully update MSYS2.
3. Run `setup/install-ucrt64.sh`.
4. Run `setup/deploy-config.sh`.
5. Run `setup/verify.sh`.

