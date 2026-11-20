# AGENTS.md

Dotfiles and workstation provisioning for Debian and Ubuntu hosts. This file is for agents
changing the repository; [`README.md`](README.md) is the guide for whoever runs it.

## The three stages

Bootstrap needs nothing from the repository, deploy is the same on every host, and provision is
where a host becomes itself. Each stage is a mise task, and the task in `mise.toml` is the
authority on what it runs.

1. **Bootstrap** — `bootstrap.sh` installs Nix, adds the `nix/bootstrap` profile (which ships
   mise), and seeds `~/.config/mise/config.local.toml`.
2. **Deploy** — `mise run deploy` stows the `minimal` bundle and renders the templates
   (`mise dot apply`). It needs the `github_token` secret.
3. **Provision** — `mise run provision:minimal` or `mise run provision:desktop` builds the Nix
   profile, stows the host's bundle, and applies `mise bootstrap packages`.

## Layout

**`stow/<bundle>/<pkg>/`** — the stow packages, grouped by bundle, their contents mirroring
`$HOME`. The packages a bundle carries are listed in `provision.toml` under `[stow.<bundle>]`.

**`nix/<profile>/`** — one flake per profile, named after its directory (`bootstrap`,
`minimal` and `desktop` today). The package lists they share live in `nix/bundles.nix`.

**`mise-tasks/<prefix>/<name>`** — one mise task per file, the path becoming the task name, so
`mise-tasks/hooks/stow/minimal/podman/systemd-units` is
`hooks:stow:minimal:podman:systemd-units`.

**`mise.toml`** — the repository's own mise config: top-level tasks such as `deploy`,
`provision:*` and `stow`, plus the templates `mise dot apply` renders.

**`provision.toml`** — what package managers do not cover, such as a `.deb` published only at
a URL, default MIME associations or the stow plan. Each table opens with a comment saying what
it holds.

**`stow/desktop/agents/.config/skiletto/skiletto.toml`** — the agent skills this repository
declares; `skiletto sync -g` restores them from the tracked `skiletto.lock` into
`~/.agents/skills`.

## Rules that break things if ignored

- **Stow runs from the repository root.** Stow reads `.stowrc` only from the current directory
  or `$HOME`, and it sets `--no-folding`, which several packages need because they write into
  the same target directories. Use `mise run stow <bundle>`: it pins the directory and runs the
  hooks in `mise-tasks/hooks/stow/<bundle>/<pkg|_bundle>/`.
- **Two packages must never link the same file.** Stow aborts the whole run when a target is
  already another package's. Paths are what count, not package names: `minimal/mise` and
  `desktop/mise` coexist because no single file appears in both. `desktop` inherits `minimal`,
  so replacing a package means inheriting with `exclude_packages = ["<pkg>"]` and declaring
  your own copy, and `stow:apply` unstows the excluded one first. `mise run stow:show <bundle>`
  prints the expansion, and collisions are checked against a temporary target before anything
  is written.
- **Never commit machine-local or secret files**, such as `~/.config/mise/config.local.toml`,
  `fnox.local.toml` or `nix/desktop/flake.nix`; those are gitignored. Secrets come from gopass
  through fnox: never print one or write it to disk.
- **Do not hand-edit `flake.lock`.** `mise run nix <profile> --update` refreshes it with the
  profile.
- **Never use `~` or absolute paths inside a stow package.** The tree under
  `stow/<bundle>/<pkg>/` is symlinked verbatim, so such a path does not resolve on the target
  host.

## Where a package goes

apt is the right source for the standard OS utilities it already ships well, such as `curl`,
`nmap` or `tcpdump`, where the distro's version is exactly what you want. It is also the only
source that installs system-wide, which is what root and system services need — user services
run in your session and are served as well by nix or mise. When the tool is not a standard
utility (`ptcpdump`), or a fresher version is wanted than Debian or Ubuntu carry (a newer
`git`), the user-level sources take over: nix and mise install into your own profile and leave
the system untouched. Of the two, a nix package arrives complete with its dependencies and
system libraries, while a mise tool is a single build against a conservative glibc baseline
that expects the host to have the rest.

1. **nixpkgs** — the fresh, complete package, per user. Use it when the distro does not carry
   the tool or its version lags, and the tool needs its dependencies. Add it to a list in
   `nix/bundles.nix` (`latest.` is unstable, `pkgs.` the current stable release) and run
   `mise run nix <profile> --update`. Extend a bundle that both flakes compose rather than
   duplicating a list per profile: the `paths` in each flake name the bundles a profile gets.
   If nixpkgs would have to build the tool from source, prefer mise (3), which leaves nothing
   to maintain.
2. **apt repo or Flathub** — the standard OS utilities, at the distro's version, plus anything
   root or a system service must find, such as `uidmap`'s setuid helpers or a system daemon —
   only apt provides that. Flatpak only when nothing else carries the app. Packages every host
   shares are declared in the root `~/.config/mise/config.toml`; desktop-only packages and the
   apt sources they need live in
   `stow/desktop/mise/.config/mise/conf.d/desktop-packages.toml`, whose
   `[bootstrap.apt.sources]` tables are hand-edited. Both are applied by
   `mise bootstrap packages apply`, and anything apt is to own goes through it, so that
   `status`, `upgrade` and `prune` keep working; never install by hand.
   `mise bootstrap packages use -n -g apt:foo` dry-runs a new package for the root config, then
   repeat without `-n`.
3. **mise** — where the owner wants the tools they run, fresh and upgrading on their own with
   `mise up`: no flake bump, no profile rebuild. Default to it for a single CLI or runtime, and
   take a source or version the owner names as given rather than re-arguing it. `[tools]` lives
   in the root `~/.config/mise/config.toml`, or in any `~/.config/mise/conf.d/*.toml` that
   mise loads beside it; here the root file is stowed from `minimal` and the fragments from
   `desktop`. Write a fragment with `mise-add -f <fragment> <tool>`, which targets the copy in
   this repository. `-f` is a fragment name that already exists in the bundle's `conf.d/`, or
   the path of an existing `.toml` file; the bundle itself is detected from the nix profile
   (`nix/<bundle>`), so pass `-b <bundle>` to target a different one. The tool argument passes
   through whole, so it carries its source:
   `mise-add -f <fragment> mytool github:owner/other`. Write the root file with
   `cd ~ && mise use -g <tool>`.
4. **direct URL** — a `.deb` only published on a release page, which no apt index carries.
   Declare it under `[deb]` in `provision.toml` as `label = url`, and upgrade it by bumping the
   URL. `mise run pkg:deb` (part of `provision:desktop`, needs sudo) fetches it into
   `.cache/debs/` and hands it to `apt-get install`, which owns it afterwards: `apt remove`
   works, and a re-run skips a version already installed.

`mise use` and `mise bootstrap packages use` both take `-n`, which prints the change and
writes nothing: run with `-n` first, then repeat without it.

`~/.config/mise/config.toml` is a symlink into this repository, which is why a `-g` write
lands here, while a bare `mise use` from the root edits the repository's own `mise.toml`.
Packages for this host alone go in `~/.config/mise/config.local.toml`, which is never
versioned. Sources do not conflict loudly; they shadow, with mise shims winning over the nix
profile and the nix profile over `/usr/bin`, so run `which -a <tool>` before you add a second
source for a tool.

## Task and script conventions

- Shell tasks start with `#!/usr/bin/env bash`, set `set -eo pipefail`, and carry
  `#MISE description="..."`, plus `#USAGE` when they take arguments. Nushell helpers start
  with `#!/usr/bin/env nu`.
- Prefer extending an existing task; `mise-tasks/glob` already dispatches `<prefix>:<name>`
  groups.
- Yazi plugins are vendored git subtrees: update them with `make update-yazi-plugins`, never
  by editing them. Neovim is LazyVim, with plugin pins in `lazy-lock.json`.
- Commits follow the existing conventional style: `feat:`, `fix:`, `chore:`.

## Formatting

Write files in the shape their formatter produces, so that saving changes nothing, and never
format by hand around a formatter.

TOML goes to tombi (mise, `~/.config/tombi/config.toml`): a trailing comma keeps an array
vertical with one value per line, without it the array folds onto one line, and tombi never
emits a row of several values. Lua, shell and Nix take LazyVim's defaults (stylua, shfmt,
nixfmt), and mason installs the first two under `$XDG_DATA_HOME/nvim/mason/bin`, so on a host
without them a save does nothing rather than fail. JSON goes through `jsonls`, and Markdown
has none, prettier being absent. Only the TOML entry is configured here, in
`stow/minimal/nvim/.config/nvim/lua/plugins/formatting.lua`, and `:ConformInfo` prints what
nvim resolves for a file.

## Writing style and comments

This file and the other documentation here are read by people as well as by agents, so write
full sentences: one idea each, a verb in each, no dropped subjects and no arrows standing in
for words. Name the file, task or flag you mean, and explain a flag where it first appears.
Brevity comes from leaving facts out, never from leaving words out. Name a set exhaustively
only where code enforces it; otherwise illustrate it with "such as".

A comment carries only what the file cannot: why a choice was made, a limit, a workaround, a
non-obvious ordering. One or two short lines. Never restate the line below it, announce what
follows, or explain what the code or the schema already shows — if it only answers "what is
this?", delete it. Re-read every comment you touch; when the code goes, its comment goes with
it, and never carry a path, a version or a flag forward unchecked. A note kept for later is
the one exemption and says so (`[flatpak]` in `provision.toml`); a block describing a table
that no longer exists is dangling, not a note.

In files a person edits by hand (`provision.toml`, `conf.d/*.toml`, templates) the rule flips
for section headers: one leading comment saying what the section does and the shape of the
data typed into it, never how the task implements it.

## Before you call a change done

```shell
mise tasks                      # task files still parse and are discoverable
bash -n <changed-script>
# nu has no exit-code lint; --ide-check is the LSP parser and always exits 0:
nu --ide-check 10 <changed.nu> | grep -q '"severity":"Error"' && echo FAIL
stow -n -v <pkg>                # dry-run the link plan (from the repo root)
mise run check                  # tools declared twice; notifies, never fails
mise bootstrap packages apply --dry-run
```

Anything touching `bootstrap.sh` or `provision:*` must be re-run end-to-end on a clean host,
or at minimum verified to be idempotent in the paths it writes.
