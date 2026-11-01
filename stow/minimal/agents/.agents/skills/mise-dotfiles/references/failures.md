# Install failures, symptom by symptom

First three commands, always: `mise doctor`, `mise which <tool>`, `mise config ls`
(which files mise actually loaded, in precedence order).

| Symptom | Real cause | Fix |
|---|---|---|
| `unknown tool` / no versions found | Wrong name, or the backend prefix was left off | `mise registry <tool>` for the short name; `mise ls-remote github:owner/repo` to see what versions the backend reports |
| `no matching asset` / `no asset found` | Wrong repo, asset published only for another platform, or autodetection lost to a decoy file | The error lists the release's assets. Narrow with `matching`, or name it with `asset_pattern` |
| `no versions found` but releases exist | Tags are not `v1.2.3` | `version_prefix = "release-"`, or `version_regex`; also `prerelease = true` if every release is a pre-release |
| `checksum mismatch` | Upstream re-uploaded an asset, or your hand-pinned `checksum` is stale | Drop the `checksum` option and let the lockfile record it; if it recurs, treat it as a supply-chain signal and stop |
| attestation / `cosign` / `SLSA` verification error | GitHub's attestation service or trusted root, or a workflow rename invalidating `slsa_signer_identity` | Temporary: `github_attestations = false` **for that tool only**, and say so. Durable: fix the signer identity to the current workflow ref |
| `option X is not used by the <backend> backend` | Typo, or that option belongs to another backend | Good error — it names the typo. Options live in [backends.md](backends.md) |
| `backend X is disabled` | `[settings] disable_backends` (`asdf` here) | Pick a verified backend. Only relax the list for a tool that ships nowhere else, and note why |
| Config edits do nothing / `[settings]` ignored | Config is not trusted. Only the **global** and system configs are exempt; an untrusted project file loads `min_version` + plain `[tools]`/`[tasks]` and drops the rest silently | `mise trust <file>` (`mise trust --show` lists status), `mise doctor` reports it. The stow-managed global config never needs this |
| Prompt: "do you trust this config?" in a non-interactive shell | Trust is per-file and needs one interactive `mise trust` | Run it once in a terminal; don't try to answer it from a script |
| Tool installs, `command not found` | Not on `PATH`: shell not activated, shims missing for non-interactive shells, or the wrong source wins | `mise which <tool>` then `which -a <tool>`. Shims beat the nix profile, which beats `/usr/bin` — a second install shadows silently |
| Same tool, different versions in different dirs | A project `mise.toml` overrides the global one | `mise config ls` shows which file supplied it. Host-wide tools belong in `-g` only |
| Entry landed in `~/dotfiles/mise.toml` | Bare `mise use` inside the repo edits *that* file (the repo's own project config) | `git -C ~/dotfiles diff`, revert it, redo with `mise use -g` |
| Language backend fails (`npm:`/`pypi:`/`go:`/`cargo:`) | Its runtime is not installed, or no checksums exist to verify against | `mise install node` (etc.) first. These backends verify nothing, so prefer a release backend when one exists |
| `403` / rate limited on `github:` | No token, or the gh CLI token is exhausted | `[settings] github.gh_cli_tokens = true`, `github.use_git_credentials = true`; `GH_TOKEN`/`GITHUB_TOKEN` in CI |
| `mise install` hangs on a prompt in CI | Interactive confirmation | `-y`/`--yes`, and `MISE_YES=1` for the whole environment |

## Reading the actual state

```bash
mise ls                      # installed versions
mise current <tool>          # what is active right now
mise where <tool>            # install dir, or the git/source it came from
mise registry <tool>         # short name → backends, in preferred order
mise backends ls             # backends this binary supports
mise ls-remote <spec>        # versions the backend can see
mise config ls               # config files loaded, in precedence order
```

When a version "isn't being picked up", it is almost always `mise config ls`: a project
`mise.toml` higher in the tree wins over the global config, and idiomatic files
(`.nvmrc`, `.python-version`) are ignored unless enabled per tool.
