
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

