#!/usr/bin/env bash

set -uo pipefail

failures=0
warnings=0

pass() {
    printf '[OK]   %s\n' "$*"
}

warn() {
    printf '[WARN] %s\n' "$*"
    warnings=$((warnings + 1))
}

fail() {
    printf '[FAIL] %s\n' "$*"
    failures=$((failures + 1))
}

section() {
    printf '\n== %s ==\n' "$*"
}

check_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        pass "$command_name -> $(command -v "$command_name")"
    else
        fail "$command_name is not available"
    fi
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"

section "Environment"

if [[ "${MSYSTEM:-}" == "UCRT64" ]]; then
    pass "MSYSTEM=UCRT64"
else
    fail "MSYSTEM=${MSYSTEM:-<unset>} (expected UCRT64)"
fi

if [[ "${MINGW_PREFIX:-}" == "/ucrt64" ]]; then
    pass "MINGW_PREFIX=/ucrt64"
else
    fail "MINGW_PREFIX=${MINGW_PREFIX:-<unset>} (expected /ucrt64)"
fi

printf 'HOME=%s\n' "${HOME:-<unset>}"
printf 'USERPROFILE=%s\n' "${USERPROFILE:-<unset>}"
printf 'GIT_CONFIG_GLOBAL=%s\n' "${GIT_CONFIG_GLOBAL:-<unset>}"

section "Git"

if command -v git >/dev/null 2>&1; then
    git_path="$(command -v git)"
    printf 'git -> %s\n' "$git_path"
    printf 'git version -> %s\n' "$(git --version)"

    printf '\nAll Git executables:\n'
    type -a git || true

    case "$git_path" in
        /usr/*|/ucrt64/*|/mingw64/*|/clang64/*)
            fail "Git appears to be an MSYS2 Git: $git_path"
            ;;
        *)
            pass "Git is not an MSYS2 Git"
            ;;
    esac

    if [[ -n "${GIT_CONFIG_GLOBAL:-}" ]]; then
        global_config_posix="$(cygpath -u "$GIT_CONFIG_GLOBAL" 2>/dev/null || true)"

        if [[ -n "$global_config_posix" && -f "$global_config_posix" ]]; then
            pass "GIT_CONFIG_GLOBAL exists: $GIT_CONFIG_GLOBAL"
        else
            fail "GIT_CONFIG_GLOBAL does not resolve to an existing file"
        fi
    else
        fail "GIT_CONFIG_GLOBAL is not set"
    fi

    use_config_only="$(git config --global --get user.useConfigOnly 2>/dev/null || true)"

    if [[ "$use_config_only" == "true" ]]; then
        pass "Git user.useConfigOnly=true"
    else
        fail "Git user.useConfigOnly is not true"
    fi

    global_email="$(git config --global --show-origin --get user.email 2>/dev/null || true)"

    if [[ -n "$global_email" ]]; then
        pass "Global Git identity: $global_email"
    else
        fail "No global Git email configured"
    fi

    effective_email="$(git config --show-origin --get user.email 2>/dev/null || true)"

    if [[ -n "$effective_email" ]]; then
        printf 'Effective Git identity: %s\n' "$effective_email"
    else
        warn "No effective Git email in the current directory"
    fi
else
    fail "git is not available"
fi

section ".NET"

if command -v dotnet >/dev/null 2>&1; then
    dotnet_path="$(command -v dotnet)"

    printf 'dotnet -> %s\n' "$dotnet_path"

    case "$dotnet_path" in
        /usr/*|/ucrt64/*|/mingw64/*|/clang64/*)
            fail ".NET appears to come from MSYS2: $dotnet_path"
            ;;
        *)
            pass ".NET is provided by Windows"
            ;;
    esac

    printf '\nInstalled .NET SDKs:\n'
    dotnet --list-sdks || fail "dotnet --list-sdks failed"
else
    fail "dotnet is not available"
fi

section "Required commands"

commands=(
    bash
    pacman
    fd
    fzf
    nvim
    node
    npm
    ssh
    rg
    starship
    tmux
    unzip
    zip
)

for command_name in "${commands[@]}"; do
    check_command "$command_name"
done

section "Package manifests"

check_manifest() {
    local manifest="$1"

    while IFS= read -r package; do
        package="${package%$'\r'}"
        package="${package%%#*}"
        package="${package#"${package%%[![:space:]]*}"}"
        package="${package%"${package##*[![:space:]]}"}"

        [[ -z "$package" ]] && continue

        if pacman -Q "$package" >/dev/null 2>&1; then
            pass "$package"
        else
            fail "Package not installed: $package"
        fi
    done <"$manifest"
}

check_manifest "$repo_root/packages/msys.txt"
check_manifest "$repo_root/packages/ucrt64.txt"

section "Optional environment"

for variable in RIPGREP_CONFIG_PATH STARSHIP_CONFIG XDG_CONFIG_HOME; do
    value="${!variable:-}"

    if [[ -n "$value" ]]; then
        printf '%s=%s\n' "$variable" "$value"
    else
        printf '%s=<unset>\n' "$variable"
    fi
done


if command -v wezterm >/dev/null 2>&1; then
    printf 'wezterm -> %s\n' "$(command -v wezterm)"
    wezterm --version || true
else
    printf 'wezterm=<not on UCRT64 PATH; OK when shell is launched by WezTerm>\n'
fi

section "Result"

printf '%d failure(s), %d warning(s)\n' "$failures" "$warnings"

if (( failures > 0 )); then
    exit 1
fi

printf 'Environment verification passed.\n'
