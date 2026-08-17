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

See [docs/fresh-machine.md](docs/fresh-machine.md).

In short:

1. Manually install Windows prerequisites.
2. Fully update MSYS2.
3. Run `setup/install-ucrt64.sh`.
4. Run `setup/deploy-config.sh`.
5. Open a new UCRT64 terminal.
6. Run `setup/verify.sh`.
7. Optional: Register Neovim context-menu in `windows/integration`.
