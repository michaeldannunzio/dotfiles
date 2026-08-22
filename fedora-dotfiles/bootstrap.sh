#!/usr/bin/env bash
# fedora-dotfiles bootstrap
#
# Usage:
#   ./bootstrap.sh                 run every stage
#   ./bootstrap.sh 20 50           run only the stages that start with 20 and 50
#   ./bootstrap.sh --list          show the stages
#   DRY_RUN=1 ./bootstrap.sh       show what would run, change nothing
#
# The script is safe to run more than once. Each stage checks before it acts.
set -uo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT
. "$DOTFILES_ROOT/lib/common.sh"

STAGES=("$DOTFILES_ROOT"/install/[0-9]*.sh)

if [ "${1:-}" = "--list" ]; then
  printf 'Stages:\n'
  for s in "${STAGES[@]}"; do printf '  %s\n' "$(basename "$s")"; done
  exit 0
fi

if [ "$(id -u)" -eq 0 ]; then
  fail "Do not run this as root. It uses sudo only where it must."
  exit 1
fi

if ! grep -qi 'fedora' /etc/os-release 2>/dev/null; then
  warn "This does not look like Fedora. Continuing anyway."
fi

: > "$MISSING_LOG"
[ "${DRY_RUN:-0}" = "1" ] || prime_sudo

run_stage() {
  local script="$1" name; name="$(basename "$script")"
  printf '\n'
  info "STAGE $name"
  if [ "${DRY_RUN:-0}" = "1" ]; then
    warn "dry run, skipping"
    return 0
  fi
  bash "$script" || warn "$name reported errors, continuing"
}

if [ "$#" -gt 0 ]; then
  for want in "$@"; do
    for s in "${STAGES[@]}"; do
      case "$(basename "$s")" in "$want"*) run_stage "$s" ;; esac
    done
  done
else
  for s in "${STAGES[@]}"; do run_stage "$s"; done
fi

printf '\n'
if [ -s "$MISSING_LOG" ]; then
  warn "Some packages were skipped. Full list:"
  printf '\n'
  column -t -s "$(printf '\t')" "$MISSING_LOG" 2>/dev/null || cat "$MISSING_LOG"
  printf '\n'
  info "Log path: $MISSING_LOG"
  info "Fix a name in packages/*.txt, then run ./bootstrap.sh again."
else
  ok "Every package installed."
fi

printf '\n'
ok "Bootstrap finished. Log out and back in to pick up the new shell and PATH."
