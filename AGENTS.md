# AGENTS.md

Dotfiles and workstation provisioning for Debian/Ubuntu hosts. This file is for agents
changing the repo; [`README.md`](README.md) is the user-facing setup guide.

## The three stages (do not conflate them)

1. **Bootstrap** — `bootstrap.sh`: installs Nix, mise into `~/.local/bin`, the
   `nix/bootstrap` profile, and seeds `~/.config/mise/config.local.toml`.
2. **Deploy** — `mise run deploy`: stows the `minimal` bundle + applies templated files
   (`mise dot apply`). Needs the `github_token` secret.
3. **Provision** — `mise run provision:minimal|desktop`: Nix profile, stow packages,
   then `mise bootstrap packages`.

## Layout

| Path | Holds |
|---|---|
| `stow/<bundle>/<pkg>/` | Stow bundles and their per-app packages; contents mirror `$HOME` exactly (`.` files included). Which packages a bundle carries is declared in `provision.toml` `[stow.<bundle>]` |
| `nix/<profile>/` | Flake per profile (`bootstrap`, `minimal`, `desktop`); `bundles.nix` shared package lists |
| `mise-tasks/<prefix>/<name>` | One mise task per file; path becomes the task name (`hooks/stow/minimal/podman/systemd-units` → `hooks:stow:minimal:podman:systemd-units`) |
| `mise.toml` | Repo-level tasks (`deploy`, `provision:*`, `stow`) + dotfile templates |
| `provision.toml` | What no package manager can carry, one table per task that applies it: `[deb]` = `label = url` (installed by `pkg:deb` into `.cache/debs/`), `[[skills]]` = agent skills (installed by `pkg:skills`), `[mime]` = default MIME associations (set by the `hooks:stow:desktop:_bundle:mimeapps` hook), `[stow.<bundle>]` = the package list a bundle carries (`packages`, `inherits`) |
| `templates/` | Files rendered into `~/.config/...` by `mise dot apply` |
| `docs/` | Deeper notes (nix, podman) |

## Rules that break things if ignored

- **Stow must run from the repo root.** `.stowrc` is only read from the cwd or `$HOME`,
  and it sets `--no-folding` (several packages write into the same target dirs). Prefer
  `mise run stow <bundle>` over a hand-typed `stow` — it also runs the
  `mise-tasks/hooks/stow/<bundle>/<pkg|_bundle>/` hook tasks.
- **One owner per path, per bundle.** `desktop` inherits `minimal`, so a package that
  exists in both would claim the same target path and stow aborts. To replace a package,
  inherit with `exclude_packages = ["<pkg>"]` and declare the variant — `stow:apply`
  unstows the excluded copy first, since the exclusion only changes the plan, not the
  target (`mise run stow:show <bundle>` prints the expansion). Cross-bundle
  collisions are preflighted into a temp target, so a failed run leaves nothing half-stowed.
- **Never commit machine-local or secret files:** `~/.config/mise/config.local.toml`,
  `fnox.local.toml`, `nix/desktop/flake.nix` (gitignored). Secrets come from gopass via
  fnox; never print or write the token to disk.
- **Do not hand-edit `flake.lock`** — `mise run nix <profile> --update` refreshes it.
- **No `~` or absolute paths inside a stow package**; the tree under `stow/<bundle>/<pkg>/` is
  symlinked verbatim.

## Where a package goes

Two questions, in that order: **is there a registry that carries it?** and, only if not,
**which file do I hand to apt?** 1–3 are registries you point a manager at; 4 is a file,
and apt has no notion of a local one, so its *name* cannot be declared anywhere.

1. **nixpkgs** — prebuilt packages, the fresher, rollbackable alternative to the distro's
   pin: use it when you actually want that version, otherwise stay on apt (2). Add to a
   list in `nix/bundles.nix`
   (`latest.` = unstable, `pkgs.` = stable release), `mise run nix <profile> --update`.
   If nothing prebuilt exists and nixpkgs would compile it, prefer 3 over a derivation to
   maintain. Extend a shared bundle, never duplicate a list per profile:
   `bootstrap`/`cliTools`/`coding`/`netUtils`/`podman` reach minimal *and* desktop;
   `desktop*`/`virt`/`kubernetes`/`codingDesktop`/`gpuDrivers`/`desktopFonts` desktop-only.
2. **apt repo / Flathub** — the distro path: apt when the version does not matter (curl and
   other staples) or nix has no prebuilt of it; Flatpak when no nix/mise package exists or
   the packaging does not matter. `[bootstrap.apt.sources.*]` +
   `[bootstrap.packages]` in `stow/desktop/mise/.config/mise/conf.d/*.toml`,
   `mise bootstrap packages upgrade`. Anything apt must own goes here, so
   `status`/`apply`/`upgrade`/`prune` keep working — never install by hand:
   `mise bootstrap packages use -n -g apt:foo` (every host) or `… use -n -p
   stow/desktop/mise/.config/mise/conf.d/desktop-packages.toml flatpak-user:org.Foo`
   (desktop only), then re-run without `-n`.
3. **mise** — one tool/CLI (`github:`, `cargo:`, `npm:`, `http:`). `[tools]` in
   `~/.config/mise/conf.d/*.toml`, `mise up`. About the registry, not about compiling:
   each tool upgrades on its own, no flake bump or profile rebuild (`cargo:`/`go:` build
   because that registry builds). `cd ~ && mise use -n -g github:owner/repo`, then again
   without `-n`. Preferred over 1 when the alternative is a nix build from source: a
   `github:`/`cargo:` build is cheaper than a derivation to keep alive.
4. **direct URL** — only a file is published and no apt index carries its name: a `.deb`
   on a release page, a vendor download link. `[deb]` in `provision.toml` as `label = url`,
   upgraded by bumping the URL. `mise run pkg:deb` (part of `provision:desktop`; sudo)
   fetches it into `.cache/debs/` and hands it to `apt-get install`, which owns it
   afterwards (`apt remove` works; re-runs skip versions already installed).

`~/.config/mise/config.toml` is a symlink into `stow/minimal/mise/…`, so `-g` writes
land in the repo — while a bare `mise use` from the repo root edits the repo's own
`mise.toml` instead. Host-only packages go in `~/.config/mise/config.local.toml`, which
is never versioned.

Sources don't conflict loudly, they shadow: mise shims beat the nix profile, which beats
`/usr/bin`. Run `which -a <tool>` before adding a second source for one.

## Task and script conventions

- Shell script tasks: `#!/usr/bin/env bash`, `set -eo pipefail`, a
  `#MISE description="..."` header (plus `#USAGE` when they take arguments). New
  nushell helpers: `#!/usr/bin/env nu`.
- Prefer extending an existing task over adding a new one; `mise-tasks/glob` already
  dispatches `<prefix>:<name>` groups.
- Yazi plugins are vendored git subtrees — update with `make update-yazi-plugins`,
  never by editing the plugin files.
- Neovim is a LazyVim setup; plugin pins live in `lazy-lock.json`.
- Commits follow the existing conventional style (`feat:`, `fix:`, `chore:`).

## Before you call a change done

```shell
mise tasks                      # task files still parse and are discoverable
bash -n <changed-script>
# nu has no exit-code lint; --ide-check is the LSP parser and always exits 0:
nu --ide-check 10 <changed.nu> | grep -q '"severity":"Error"' && echo FAIL
stow -n -v <pkg>                # dry-run the link plan (from the repo root)
mise bootstrap packages apply --dry-run
```

Anything touching `bootstrap.sh` or `provision:*` must be re-run end-to-end on a clean
host (or at minimum verified that the paths it writes are idempotent).
