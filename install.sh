#!/usr/bin/env bash
#
# cc-alias installer
# Adds (or removes) a `cc` shell alias for `claude --dangerously-skip-permissions`.
#
# Usage: install.sh [--uninstall] [-h|--help]

set -euo pipefail

ALIAS_NAME="cc"
ALIAS_CMD="claude --dangerously-skip-permissions"
MARK_BEGIN="# >>> cc-alias >>>"
MARK_END="# <<< cc-alias <<<"

usage() {
  cat <<EOF
Usage: ${0##*/} [--uninstall] [-h|--help]

Adds the alias '${ALIAS_NAME}' ('${ALIAS_CMD}') to your shell config file.

Options:
  --uninstall   Remove the alias block added by this script
  -h, --help    Show this help
EOF
}

# Detect shell config file
detect_rc() {
  case "$(basename "${SHELL:-}")" in
    zsh) echo "$HOME/.zshrc" ;;
    bash)
      if [ -f "$HOME/.bash_profile" ]; then
        echo "$HOME/.bash_profile"
      else
        echo "$HOME/.bashrc"
      fi
      ;;
    *) echo "$HOME/.profile" ;;
  esac
}

install_alias() {
  local rc="$1"

  # Skip if the alias is already defined (by us or by hand)
  if grep -Eq "^[[:space:]]*alias[[:space:]]+${ALIAS_NAME}=" "$rc" 2>/dev/null; then
    echo "Alias '$ALIAS_NAME' already present in $rc"
    return 0
  fi

  # Warn if the name shadows an existing command
  local existing
  if existing="$(command -v "$ALIAS_NAME" 2>/dev/null)"; then
    echo "Note: '$ALIAS_NAME' already exists ($existing). The alias will shadow it in interactive shells."
  fi

  {
    echo
    echo "$MARK_BEGIN"
    echo "alias $ALIAS_NAME='$ALIAS_CMD'"
    echo "$MARK_END"
  } >>"$rc"

  echo "Alias '$ALIAS_NAME' added to $rc. Run: source \"$rc\""
  echo "Warning: this flag disables all permission prompts in Claude Code."
}

uninstall_alias() {
  local rc="$1"

  if ! grep -Fxq "$MARK_BEGIN" "$rc" 2>/dev/null; then
    echo "No cc-alias block found in $rc; nothing to remove."
    return 0
  fi

  # Delete the marked block. Write to a temp file, then copy back with `cat`
  # so symlinks and file permissions are preserved (and `sed -i` portability
  # differences between GNU and BSD/macOS are avoided).
  local tmp
  tmp="$(mktemp)"
  sed "/^${MARK_BEGIN//\//\\/}\$/,/^${MARK_END//\//\\/}\$/d" "$rc" >"$tmp"
  cat "$tmp" >"$rc"
  rm -f "$tmp"

  echo "Alias '$ALIAS_NAME' removed from $rc. Open a new shell (or run: unalias $ALIAS_NAME)."
}

main() {
  local rc action="install"

  case "${1:-}" in
    "") ;;
    --uninstall) action="uninstall" ;;
    -h | --help)
      usage
      return 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      return 2
      ;;
  esac

  rc="$(detect_rc)"
  if [ "$action" = "install" ]; then
    install_alias "$rc"
  else
    uninstall_alias "$rc"
  fi
}

main "$@"
