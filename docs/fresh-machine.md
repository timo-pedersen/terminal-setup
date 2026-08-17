# Fresh-machine setup

## 1. Install Windows prerequisites

Install manually:

- Git for Windows
- WezTerm
- MSYS2
- Windows .NET SDK

Useful checks from ordinary Windows CMD:

```cmd
where git
where dotnet
```

Expected locations are normally similar to:

´C:\Program Files\Git\cmd\git.exe´
´C:\Program Files\dotnet\dotnet.exe´

## 2. Update MSYS2

Open an MSYS2 UCRT64 shell and run:

```
pacman -Suy
```

If MSYS2 asks for all terminals to be closed, close them, reopen UCRT64 and
run pacman -Suy again.

Repeat until fully updated.

3. Install UCRT64 packages

Clone this repository and, from its root:

```bash
./setup/install-ucrt64.sh
```

The script expects:

```bash
MSYSTEM=UCRT64`
MINGW_PREFIX=/ucrt64
```

MSYS2 system upgrades remain manual; the installer does not run pacman -Suy.

## 4. Deploy configuration

Run:
```bash
./setup/deploy-config.sh
```

The repository is the source of truth for managed configuration files.
Existing destination files are backed up before replacement.

Open a new WezTerm/UCRT64 terminal after deployment so the deployed Bash
configuration is loaded normally.

5. Verify

Run:

```bash
./setup/verify.sh
```

A healthy environment should show:

```
MSYSTEM=UCRT64
MINGW_PREFIX=/ucrt64
git -> Git for Windows
dotnet -> C:\Program Files\dotnet
```

and all packages listed in packages/msys.txt and packages/ucrt64.txt
should be installed.

## Troubleshooting

### Git resolves incorrectly

Check:

```bash
type -a git
```

The primary Git should be Git for Windows;
NOT `/usr/bin/git`, `/mingw64/bin/git` or `/ucrt64/bin/git`.

The Bash configuration exposes Git for Windows with:

```bash
export PATH="/c/Program Files/Git/cmd:$PATH"
export GIT_CONFIG_GLOBAL="$(cygpath -m "$USERPROFILE")/.gitconfig"
```

### .NET is missing

If Windows CMD finds dotnet but UCRT64 does not, the Windows SDK directory
must be added to the Bash PATH:

```bash
export PATH="/c/Program Files/dotnet:$PATH"
```

Then:

```bash
dotnet --version
dotnet --list-sdks
```

### Git identity

Git authentication and commit identity are separate.

The Windows global Git configuration supplies the default identity.
On machines that need separate personal and work identities, use conditional
Git includes for the appropriate repository roots.

Set:

``` 
git config --global user.useConfigOnly true
```

to prevent Git from silently inventing an identity.

## Starship configuration

UCRT64 Starship uses:

```
~/.config/starship.toml
```

Bash explicitly selects it:

```bash
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
```

This prevents accidental use of a similarly named Windows-side config.

## ripgrep configuration

ripgrep is used from both Windows and UCRT64.

Both use the shared Windows-side configuration:

```
%USERPROFILE%\.config\.ripgreprc
```

UCRT64 points to it with `RIPGREP_CONFIG_PATH`.

## MSYS2 command-line arguments

MSYS2 performs argument/path conversion when launching Windows programs.
For example, `cmd.exe /c ...` can be surprising from Bash.

Where possible, invoke Windows executables directly, for example:

```
where.exe dotnet
```

rather than going through cmd.exe.

## fzf

fzf shell integration is enabled in Bash.

Useful bindings:

Ctrl-R   fuzzy command history
Ctrl-T   fuzzy file selection
Alt-C    fuzzy directory change


