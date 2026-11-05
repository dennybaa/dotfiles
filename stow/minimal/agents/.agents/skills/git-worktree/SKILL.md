---
name: git-worktree
description: Use when the user asks to clone a repo, create one from scratch, or branch off without disturbing the current checkout — "make a worktree", "clone X", "new repo for this", "do it in parallel"; to create worktrees use `wt`.
---

# Worktrees

This skill owns the bare-repo layout, worktree detection and the handover to
`wt`.

    repo/.git       all git data, no working tree
    repo/main       branch main
    repo/feat       branch feat

`worktree-path` in `~/.config/worktrunk/config.toml` decides where a worktree
lands: never pass a path to `wt switch`, never edit that file. The layout
lives in the user config only, so never add a project `.config/wt.toml`.

`wt` missing → say so and stop. `git worktree add` is not a substitute: every
worktree folder otherwise comes from `wt` and the template. The conversion below
is the single exception, and it names folders the way the template would.

## Which flow

The script below, run from inside a directory, says whether there is a repo here
and, if so, whether it is bare. Those two answers pick the row in the table.

```sh
# empty → no repo
common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || common=""
bare=$(if [ -n "$common" ]; then git -C "$common" rev-parse --is-bare-repository; fi)
```

| `$common` | `$bare` | Flow |
| --- | --- | --- |
| empty | — | New repo |
| set | `false` | Ordinary clone: work in place |
| ends in `/.git` | `true` | Worktree-shaped: feature request, spawned session |
| any other name | `true` | Bare repo at the top: `wt` works, worktrees land beside `$common` |

`$bare=false` means a working tree is checked out somewhere: work there; the
shape of `$common` does not matter. When `$common` ends in `/.git` and
`$bare=true`, `cd "$common/.."` before running anything else: that parent is
`<repo>`, and every command below assumes you are there.

A bare clone made at `<dir>` itself (`git clone --bare <url> <dir>`, so no
`<dir>/.git`) still accepts `wt switch`, but its worktree lands outside `<dir>`
as `<dir>/../<branch>` — say so, and offer to re-clone into `<dir>/.git`.

## New repo, or a clone

A fresh clone is built in this shape, so there is nothing to convert.

```sh
git clone --bare -- <url> <dir>/.git
git -C <dir>/.git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git -C <dir>/.git fetch origin
cd <dir> && wt switch "$(git -C .git symbolic-ref --short HEAD)"
```

The refspec is what makes remote branches visible; a bare clone sets none.

```sh
git init --bare -b main <dir>/.git
cd <dir> && wt switch --create main
```

`wt switch --create` makes the first branch and worktree. Either way, work ends
in a worktree, never in `<dir>`.

## Ordinary clone: work in place

Work in the checkout itself; do not add a worktree beside `<repo>`.

## Conversion (only when the user asks)

Ask before converting a dirty tree — anything besides `!!` in
`git status --porcelain --ignored` — because those changes go into a stash.

```sh
cd <repo>
sanitize() { printf '%s' "$1" | sed 's|/|-|g'; }   # wt's branch name sanitizing: '/' -> '-'
dirty=$(git status --porcelain --ignored)          # !! lines = what is ignored; also the stash guard
cur=$(git rev-parse --abbrev-ref HEAD)
[ "$cur" = HEAD ] && { echo "detached HEAD — check out a branch first" >&2; exit 1; }
if [ -n "$dirty" ]; then git stash push -a -m "worktree conversion"; fi
dir=$(sanitize "$cur")
git config core.bare true
git --git-dir=.git worktree add "$dir" "$cur" || exit 1   # no delete until $dir exists
find . -mindepth 1 -maxdepth 1 ! -name .git ! -name "$dir" -exec rm -rf {} +
git --git-dir=.git worktree add "$(sanitize feat)" feat    # repeat per remaining branch
if [ -n "$dirty" ]; then git -C "$dir" stash pop --index; fi   # unguarded pop restores an older stash
```

`git stash push -a` is how the working state survives: it packs modified, staged
and untracked files plus ignored directories into one stash entry in the shared
`.git`, and `stash pop --index` puts it back in `$dir`, with what was staged
still staged. That is why nothing is copied by hand.

Two things the script does not handle. A nested repository (a vendored clone) is
never stashed — git prints an `Ignoring path …` line for it, and the `find`
delete then removes it, so move it into `$dir` first. Ignored files are stored
as git objects, so a large build cache or dependency tree makes the stash slow
and puts a second copy inside `.git/objects` until gc: reinstall it in `$dir`
instead, and let `wt step copy-ignored` fill later worktrees.

## Feature request, or a session spawn

In a worktree-shaped repo, the branch gets its own folder before the first edit
— not a branch in the current checkout, which takes that checkout away from
whatever else uses it.

```sh
cd <repo> && wt switch --create <branch>
wt switch --create <branch> --no-cd   # spawned session
```

`wt` prints the path but cannot change directory; `cd` there yourself. Add
`--base <ref>` to fork from anything but the default branch. A spawned session
runs the `--no-cd` form: the spawner creates the worktree and hands the path
over, so a session never converts in order to spawn.

## Verify, then clean up

```sh
git --git-dir=.git worktree list
wt list
```

`wt remove <branch>` drops a worktree and deletes the branch when it is merged;
hand-deleted directories leave stale entries, so run
`git --git-dir=<repo>/.git worktree prune`.

## Related

- `worktrunk` skill, shipped with wt — commands, hooks, config.
- Vault: `Tools/Worktrunk bare-repo layout, explained.md` — why the template
  is `/../`, why project config is ignored, the original conversion notes.
