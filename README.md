# cc-alias

A tiny, idempotent installer that adds a `cc` shell alias for
`claude --dangerously-skip-permissions` ([Claude Code](https://claude.com/claude-code)).

> [!WARNING]
> `--dangerously-skip-permissions` disables **all** permission prompts in Claude Code.
> Claude can then run commands and edit files without asking. Only use it in
> environments you trust (e.g. a disposable container or VM, or a repo you can restore).

## Install

```sh
git clone https://github.com/sunflowercosmic/cc-alias.git
cd cc-alias
./install.sh
source ~/.zshrc   # or the file printed by the script
```

The script picks your shell config file automatically:

| Shell | File                                          |
| ----- | --------------------------------------------- |
| zsh   | `~/.zshrc`                                    |
| bash  | `~/.bash_profile` if it exists, else `~/.bashrc` |
| other | `~/.profile`                                  |

It appends this block:

```sh
# >>> cc-alias >>>
alias cc='claude --dangerously-skip-permissions'
# <<< cc-alias <<<
```

Behavior:

- **Idempotent** – does nothing if an `alias cc=` line already exists.
- **Shadow warning** – tells you if `cc` already resolves to another command
  (on macOS and many Linux systems, `cc` is the C compiler).

## Uninstall

```sh
./install.sh --uninstall
```

Removes the block between the `cc-alias` markers (using `sed`) and leaves the rest
of your config untouched. Aliases you added by hand outside the block are not touched.
Then open a new shell, or run `unalias cc`.

## Development

The script is checked with [ShellCheck](https://www.shellcheck.net/):

```sh
shellcheck install.sh
```

## License

[MIT](LICENSE)
