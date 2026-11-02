# Backends: where the binary actually comes from

A backend is named in the tool's **key**, never the value:

```toml
[tools]
"github:koalaman/shellcheck" = "0.11"    # backend:key = version
```

Check what the installed mise supports: `mise backends ls`. Check what a short name
resolves to before reaching for an explicit backend: `mise registry <tool>`.

## Safety ranking — prefer the highest that has the tool

| Backend | Verification | Use for |
|---|---|---|
| `packslip:` | publisher-signed release manifest (Sigstore, transparency log); signer pinned on first install | tools the registry already ships this way — `hk`, `usage`, `fnox`, `pitchfork`, `aube`, `helmfile`, `timoni`, `dagu`, `worktrunk` |
| `core` | mise-built runtimes | `node`, `python`, `go`, `ruby`, `erlang`, `java`, `bun`, `deno`, … |
| `aqua:` | checksums + cosign + SLSA + attestations, no plugin code | everything else that is in the aqua registry |
| `github:` / `gitlab:` / `forgejo:` | GitHub-reported digest or checksum file in the release; artifact attestations on public GitHub; optional SLSA | release binaries not in aqua |
| `http:` / `s3:` | only the checksum you pin yourself | archives you host |
| `cargo:` `go:` `npm:` `pypi:` `gem:` `dotnet:` `conda:` `spm:` | **none** — no checksums, no provenance, and the toolchain must be installed | a tool that ships nowhere else |
| `vfox:` | plugin code; attestations only if the plugin opts in | tool that only exists as a plugin |
| `asdf:` | plugin code, no checksums, no Windows | never on this host (`disable_backends = ["asdf"]`) |

`ubi:` is deprecated — it was replaced by `github:`.

## github:owner/repo — prebuilt release assets

Use when the tool publishes binaries on GitHub releases and there is no registry shorthand.

```bash
mise use -g github:owner/repo              # writes ~/.config/mise/config.toml (stow → repo)
mise ls-remote github:owner/repo           # versions = release tags without the leading `v`
mise use -g github:owner/repo@1.4.1
```

```toml
[tools]
"github:koalaman/shellcheck" = "0.11"
"github:oxc-project/oxc" = { version = "apps_v1.69.0", matching = "oxlint", rename_exe = "oxlint" }
```

Autodetection already scores OS, arch, libc (glibc/musl), archive format, and penalises
debug/test/checksum assets and macOS `.app` bundles. Only reach for options when it picks
wrong — the failure names the assets it saw:

| Option | For |
|---|---|
| `asset_pattern = "gh_*_linux_amd64.tar.gz"` | name the asset outright; replaces autodetection, so it stops being cross-platform |
| `matching = "oxlint"` / `matching_regex = "^oxlint-"` | narrow candidates, keep autodetection |
| `no_app = true` | skip a macOS `.app` bundle in favour of a CLI archive |
| `format`, `strip_components`, `bin_path`, `bin`, `rename_exe`, `filter_bins` | the archive unpacks to something mise cannot find a binary in |
| `version_prefix`, `version_regex`, `prerelease`, `version_order` | tag is not `v1.2.3`, or releases are not versions of the tool |
| `checksum = "sha256:…"`, `size` | pin one artifact by hand (lockfile normally records it) |
| `slsa_signer_identity` + `slsa_signer_issuer` | verify SLSA provenance; needs the exact workflow ref in the certificate |
| `github_attestations = false` | temporary workaround only — prefer fixing the cause |
| `api_url` | GitHub Enterprise Server (attestations are not checked there) |

Private repos and rate limits are a `[settings]` problem: `github.gh_cli_tokens`,
`github.use_git_credentials` (mise tries gh first, falls back to git credentials, fails
open). In CI a plain `GITHUB_TOKEN` also works.

## packslip

`packslip:github.com/owner/repo`, or `packslip:owner/repo` for GitHub. mise verifies the
vendor's signing workflow and every artifact digest; `workflow = [...]` pins the signer.
Almost always reached through a registry short name rather than written by hand — when the
registry offers it, the short name is what you write.

## aqua:owner/repo

The default choice for a tool in the aqua registry: checksums, cosign, SLSA and
attestations, and no plugin code runs. `libc = "musl"` where a static variant exists.

```toml
[tools]
"aqua:sharkdp/fd" = "10"
```

## http / s3 — you host it, you verify it

```toml
[tools."http:mytool"]
version = "1.0.0"
url = "https://example.com/mytool-{{ version }}-{{ os() }}-{{ arch() }}.tar.gz"
checksum = "sha256:…"                       # no checksum ⇒ no verification at all
headers = ["Authorization: Bearer …"]       # http only

[tools."s3:mytool"]
version = "1.0.0"
url = "s3://bucket/mytool-{{ version }}.tar.gz"
```

`s3:` uses the AWS credential chain. Template functions are Tera: `{{ version }}`,
`{{ os() }}`, `{{ arch() }}`.

## Language backends — last resort, and they need their runtime

No checksums, no provenance, and mise has to install the language first (`npm:` needs
`node`, `pypi:` builds on mise's Python, `go:` needs `go`, `cargo:` needs rust and can use
`cargo-binstall`).

```toml
[tools]
"cargo:ripgrep" = "15"                     # crates.io
"go:github.com/golangci/golangci-lint/cmd/golangci-lint" = "2"
"npm:prettier" = "3"
"pypi:ruff" = "0.15"                       # `pipx:` is the same tool, older name
"gem:rubocop" = "1"
"dotnet:dotnet-ef" = "9"
"conda:ffmpeg" = "7"
"spm:owner/repo" = "1"                     # needs Swift
```

`npm:` also takes a git spec: `"npm:github:owner/repo@ref"`.

## vfox / spinel

`vfox:owner/plugin` — Lua plugin, runs code, no automatic checksums; attestations only if
the plugin opts in. `spinel:owner/repo` — experimental, needs `experimental = true` and the
`spinel` compiler. Both are below aqua in trust; use only when nothing else ships the tool.

## Options that every backend accepts

`os`, `depends`, `install_env`, `postinstall`, `lazy` — in the table form:
`tool = { version = "1", lazy = true }`. A misspelled option fails the install with
`option … is not used by the <backend> backend`, which is a good error: it names the typo.
