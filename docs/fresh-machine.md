
# Fresh-machine setup

## Manual Windows installation

Install manually under Windows:

* Git for Windows, and jot down the path (CMD: where git)
* WezTerm
* MSYS2
* Neovim, if a separate Windows installation is wanted (why?)
* DotNet, and jot down the path (CMD: where dotnet).

## Update MSYS2

From an MSYS2 terminal:

```bash
pacman -Suy
```

If MSYS2 requests that all terminals be closed, close them, reopen UCRT64 and run:

```bash
pacman -Suy
```

Repeat until the system is fully updated. Standard stuff.

## Continue setup

From the repository root in UCRT64:

```bash
./setup/install-ucrt64.sh
./setup/verify.sh
./setup/deploy-config.sh
```

## Windows tools from UCRT64

UCRT64 keeps its own Unix home (`HOME=/home/<user>`), while Windows-native
tools use `%USERPROFILE%`. Keep these homes separate.

Git for Windows is authoritative. Point it explicitly at the Windows global
config from `~/.bashrc`:

```bash
export GIT_CONFIG_GLOBAL="$(cygpath -m "$USERPROFILE")/.gitconfig"
```

The Windows .NET SDK is also authoritative. If dotnet is not visible from
UCRT64, add:

```bash
export PATH="/c/Program Files/dotnet:$PATH"
```

Verify the shell before setup:

```bash
echo "$MSYSTEM"       # UCRT64
echo "$MINGW_PREFIX"  # /ucrt64
type -a git           # should resolve to Git for Windows
dotnet --version      # should resolve to C:\Program Files\dotnet
```

Git identity uses the work identity by default on work machine. 
Personal repositories below C:\git_misc\ use a conditional include with .gitconfig-personal.
user.useConfigOnly=true prevents Git from silently inventing an identity.

## Starship

Starship is owned by MSYS2 and config lives in `~/.config/starship.toml`.

In order to point Starship to correct config instead of the Windows-owned one in
`$USERPROFILE/.config`, do:

```bash
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
```
This is already added to `~/.bashrc`.

## Rg

Rg is using Windows side config in `$USERPROFILE/.config`.
