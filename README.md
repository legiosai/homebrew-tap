# homebrew-tap

The [Homebrew](https://brew.sh) tap for [Legios](https://github.com/legiosai)
tools. macOS and Linux.

```sh
brew install legiosai/tap/quartermaster
```

## What's in here

| | |
|---|---|
| [**quartermaster**](https://github.com/legiosai/quartermaster) | How much quota you have left, in every agent account on the machine: every Claude Code profile, plus Codex and opencode. |

`brew services start quartermaster` keeps the menu bar item (macOS) or the GNOME
indicator (Linux) running, and starts it again at login.

## How it gets updated

Tagging a release in the tool's own repository runs its release workflow, which
rewrites the formula's `url` and `sha256` here with the tarball of that tag.
Only those two lines: the rest of the formula —the description, the
dependency, the service and the test— is written by hand in this repo.
