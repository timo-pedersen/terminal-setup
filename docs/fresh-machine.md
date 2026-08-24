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


## Git

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

### Git pager

Git for Windows normally uses its bundled `less`. Inside MSYS2/tmux this
pager does not know the `tmux-256color` terminfo entry.

Use the MSYS2 pager instead:

```bash
git config --global core.pager 'C:/msys64/usr/bin/less.exe -R -+X'
```

N.B: This also magically works in CMD.

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

## Terminal: MSYS2 UCRT64 + mintty

### Why mintty and not WezTerm

Paste latency in MSYS2 bash scales linearly with the number of live MSYS
processes, but **only on console-attached shells** (`cons*` in `ps -ef`).
Shells on an MSYS pty (`pty*` — i.e. mintty) are unaffected.

Measured, identical 500-character paste, same machine:

| MSYS processes | WezTerm (`cons`) | mintty (`pty`) |
|---|---|---|
| 1  | 0.3 s  | — |
| 2  | 2–3 s  | — |
| 3  | 6–7 s  | — |
| 4  | 9 s    | — |
| 6  | 16 s   | — |
| 16 | 35 s   | < 0.5 s |

Not fixable from either end — not `inputrc`, not `send_paste`, not
`MSYS=disable_pcon`, not the MSYSTEM subsystem, not the runtime version.
Git Bash appears fast only because it is a *separate installation* with its
own process table (two entries), not because it is architecturally different.

Practical consequence: use mintty. Ten shells stay fast. Any ConPTY-based
terminal degrades over a working day as tabs accumulate.

### Launcher

`C:\msys64\ucrt64.ini`:

```ini
CHERE_INVOKING=1
```

(Already a line present, just remove the '#')

**This is load-bearing.** Without it, `/etc/profile` runs `cd "$HOME"` at
startup and silently overrides any directory set beforehand — the shortcut's
"Start in", mintty's `--dir`, everything. Symptom is always landing in `~`
regardless of configuration.

Verify with `echo "[$CHERE_INVOKING]"` — must print `[1]`.

Start directory then comes from the shortcut's **Start in** field
(e.g. `C:\git`), or `--dir /c/git` on a direct mintty invocation.
Note: there is no working `Dir=` config-file setting; `--dir` is
command-line only.

### `~/.minttyrc`

```ini
# tabs (virtual tabs = separate windows, geometry-synced)
TabBar=1
SessionGeomSync=2

# mouse: double-click word, triple-click line, right-click paste
CopyOnSelect=yes
RightClickAction=paste
ClicksTargetApp=no
AllowSetSelection=yes

# keys (this unlocks eg shift-ctrl-v for paste automatically)
CtrlShiftShortcuts=yes
KeyFunctions=t:new-tab-cwd;n:new-window-cwd;

# looks
Background=C:\msys64\home\terminal_texture2.jpg
ThemeDark=xterm
Font=0xProto Nerd Font Mono
TabFont=0xProto Nerd Font Mono, 9px
FontHeight=10
FontSmoothing=full
Transparency=low
OpaqueWhenFocused=yes
CursorType=line
Columns=166
Rows=33

# misc
Charset=UTF-8
Locale=en_US
Language=en_US
PgUpDnScroll=no
BellType=0
StatusLine=no
```

`CtrlShiftShortcuts=yes` does two jobs: it enables the built-in
Ctrl+Shift+C/V/N set, *and* it is required for bare-letter `KeyFunctions`
bindings (a letter with no modifier is implicitly Ctrl+Shift).

### Tab titles

In `~/.bashrc` — gives `U ../terminal-setup`, updating on every `cd`:

```bash
tabtitle() {
  local t="${MSYSTEM:0:1}"     # U for UCRT64, M for MINGW64
  local d="${PWD##*/}"
  printf '\e]0;%s ../%s\a' "$t" "$d"
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }tabtitle"
```

nvim leaves the title alone (`set title` is off by default), so tab names
survive editing sessions.

### Gotchas

- Tabs are not real tabs — they are separate top-level windows, hidden and
  shown on switch. Hence the flicker, and hence every new session being
  pulled into one group.
- `Shift+Shift+Alt+F2` (both Shift keys) forces a window outside the tabbar.
  `new-window-cwd` bound to a key is nicer. For permanently separate groups,
  give a second shortcut `-o Class=<name>`.
- Mintty's `A+` modifier means **left Alt only** — right Alt can't be
  distinguished from AltGr on a Nordic layout.
- `Alt+F3` is scrollback search. Useful; don't rebind it.
- Wrong function names in `KeyFunctions` fail silently. Find real ones with
  `grep -ao 'Tab[A-Za-z]*' /usr/bin/mintty.exe | sort -u` (works for any
  option prefix).
