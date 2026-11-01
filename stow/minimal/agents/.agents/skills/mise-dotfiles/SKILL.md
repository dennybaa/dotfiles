---
name: mise-dotfiles
description: >
  Install, pin, bump or remove a host-level package/tool with mise so it lands in this dotfiles repo: `mise
  use -g` writing the stow-managed ~/.config/mise/config.toml or a conf.d/*.toml bundle fragment, plus where
  a tool belongs in the first place (mise [tools] vs a Nix bundle vs apt via mise bootstrap vs provision.toml
  [deb]). Covers backend install syntax (github:/packslip:/aqua:/cargo:/go:/npm:/pypi:/gem:/dotnet:/http:/
  s3:/vfox:), picking the safest backend, upgrading (`mise up` vs `--bump` vs `mise outdated`, prune
  grace period, why a `latest` upgrade leaves no git diff), and install failures: unknown backend, no
  matching version, no matching asset, cosign/SLSA/attestation error, trust prompt, tool not on PATH. Use
  for "add mise package", "install X globally / system-wide", "put it in dotfiles", "should this be Nix or
  mise", "upgrade / bump a tool", "mise upgrade does nothing", "mise install fails".
  Not for a project's own mise.toml [tools], mise tasks, [env], hooks/hk, or auditing an existing setup.
license: MIT
metadata:
  repo: dennybaa/dotfiles
---

# mise-dotfiles

Adding, bumping or removing one package on **this host**, through the mise config that this
repo stows. The config is the deliverable: `mise use -g` writes
`~/.config/mise/config.toml`, which is a symlink into `stow/minimal/mise/`, so the change
is a git change.

## Rules — all of them are load-bearing

1. **Always `mise use -g`.** Never bare `mise use`. It picks the *nearest* config: run
   inside the dotfiles repo it edits the repo's own `mise.toml` (tasks, `fnox`) instead of
   the global one, and anywhere else it creates a stray `./mise.toml`. Where the four
   targets are: [below](#config-layout--dotfiles).
2. **Backend goes in the KEY, version in the value.** `"github:owner/repo" = "1.4"`.
   `owner/repo = "github:1.4"` is a parse error that breaks the whole file.
3. **Registry shorthand first.** `mise registry <tool>` shows what the short name resolves
   to. `ripgrep = "15"` beats `"github:BurntSushi/ripgrep" = "15"` — the registry entry
   already names the safest backend and the options the tool needs.
4. **Prefer a pin over `latest`.** `>= 1.0` → the major (`rg = "15"`); `0.x` → the minor
   (`ruff = "0.15"`), because 0.x breaks on minor bumps; exact when a tool's minor releases
   break. The existing `config.toml` floats most CLIs on `latest` — match the neighbours in
   the file you are editing instead of rewriting them in the same commit.
5. **One source per tool.** `which -a <tool>` first. Shims beat the nix profile, which beats
   `/usr/bin`; a second source for the same binary shadows silently rather than conflicting.
6. **Read the file back.** After writing, `git -C ~/dotfiles diff` — a tool that landed in
   the wrong file, or in the wrong bundle fragment, is the usual mistake.
7. **Prove it.** `mise install <spec> && mise which <tool>` — `mise use -g` installs, but a
   `[settings] disable_backends` entry or a missing runtime for a language backend only
   shows up at install time. Deploy with `mise run stow minimal`.

## Config layout — `~/dotfiles`

`~/.config/mise/config.toml` is a symlink into `stow/minimal/mise/`, so every `-g` write
is a git change in the dotfiles repo. Four targets:

| Target | Scope | Written by |
|---|---|---|
| `config.toml` | every host, every directory | `mise use -g …` (through the symlink) |
| `conf.d/{code,kube,desktop-packages}.toml` (desktop) | hosts that stow the `desktop` composition | `mise use -p <that file> …`, or by hand |
| `~/.config/mise/config.local.toml` | this host only, never versioned | `mise use -p ~/.config/mise/config.local.toml …` |
| `~/dotfiles/mise.toml` | the repo **as a project** (its own tasks) | bare `mise use` inside the repo — almost never what you want |

Desktop-only tools (kubectl, k9s, rust, node) belong in a fragment; anything needed to
bootstrap or repair a host belongs in `config.toml`. A duplicate key resolves silently,
later file winning. No secrets in these files: tokens come from gopass via fnox, or from
`templates/github_tokens.toml` rendered `0600` by `mise dot apply`. Deploy with
`mise run stow minimal` — `.stowrc` (`--no-folding`) is only read from the repo root,
which that task pins.

## Upgrading

| Command | Effect |
|---|---|
| `mise up -n` | preview only — never upgrade blind |
| `mise up` | newest **inside** the request; a `latest` entry leaves **no git diff** |
| `mise up --bump` | past the request **and rewrites the config** — that diff is the deliverable, and on a `0.x` tool it is a deliberate review |

Scope it with `<tool>` (omitting it also upgrades `config.local.toml`). `mise outdated -b`
shows what a bump would write. The old version lingers until `upgrade.prune_after` (24h here,
`--prune`/`--no-prune` override it; `mise ls --prunable` lists them), and a version change
needs no re-stow — the config is already a symlink into the repo. No lockfile here, so the
backend's install-time verification is the only gate. The other two layers are not `mise up`:
`mise bootstrap packages upgrade`, `mise run nix <profile> --update`.

## Where a tool belongs

mise `[tools]` only. Anything else — nixpkgs, apt/Flathub, a `.deb` URL — is routed by
`~/dotfiles/AGENTS.md`.

## References

| File | Read it when |
|---|---|
| [backends.md](references/backends.md) | You know the tool, not the backend: install syntax and options per backend, and their safety ranking. |
| [failures.md](references/failures.md) | The install failed, or the tool is installed but not found on `PATH`. |

## Scope

Out of scope on purpose: pin policy for project configs, `mise.lock`, tasks, `[env]`,
hooks/`hk`, CI, and auditing an existing setup. Those belong to the project that owns the
`mise.toml` in question. This skill only writes host-level entries, upgrades them, and
diagnoses installs.
