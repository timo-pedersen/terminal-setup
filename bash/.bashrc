# Environment shared by interactive and non-interactive Bash.

if [[ "${MSYSTEM:-}" == "UCRT64" ]]; then
    # Windows Git is authoritative.
    export PATH="/c/Program Files/Git/cmd:$PATH"
    export GIT_CONFIG_GLOBAL="$(cygpath -m "$USERPROFILE")/.gitconfig"

    # Windows .NET SDK is authoritative.
    export PATH="/c/Program Files/dotnet:$PATH"

    # ripgrep uses the Windows-side shared config.
    export RIPGREP_CONFIG_PATH="$(cygpath -m "$USERPROFILE")/.config/.ripgreprc"

    # Starship config file owned by MSYS2, not Windows
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
fi

# Everything below is interactive-only.
[[ "$-" != *i* ]] && return

# Basic GNU colors.
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -aF --color=auto'

alias less='less -r'

# Gives tabtitle in mintty
tabtitle() {
  local t="${MSYSTEM:0:1}"                    # U for UCRT64, M for MINGW64
  local d="${PWD##*/}"                        # last path component
  printf '\e]0;%s ../%s\a' "$t" "$d"
}
PROMPT_COMMAND="tabtitle${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# fzf key bindings and completion.
eval "$(fzf --bash)"

# Prompt.
eval "$(starship init bash)"




