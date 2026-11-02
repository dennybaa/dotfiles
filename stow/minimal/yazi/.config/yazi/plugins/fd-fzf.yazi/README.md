# fd-fzf.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin to jump to directories using [fd](https://github.com/sharkdp/fd) and [fzf](https://github.com/junegunn/fzf).

## Requirements

- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [eza](https://github.com/eza-community/eza) (optional, required for `preview` and `hidden_preview` presets)

## Installation

```sh
ya pkg add masaki39/fd-fzf
```

## Update

```sh
ya pkg upgrade masaki39/fd-fzf
```

## Configuration

Add keybindings in `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = ["s", "z"]
run = "plugin fd-fzf"
desc = "Jump to directory"

[[mgr.prepend_keymap]]
on = ["s", "Z"]
run = "plugin fd-fzf hidden"
desc = "Jump to directory (hidden)"

[[mgr.prepend_keymap]]
on = ["s", "p"]
run = "plugin fd-fzf preview"
desc = "Jump to directory (preview)"
```

## Customization

The plugin has built-in presets that can be selected by passing a preset name as an argument:

| Preset | Command |
|--------|---------|
| `default` | `fd --type d \| fzf` |
| `hidden` | `fd --type d --hidden \| fzf` |
| `preview` | `fd --type d \| fzf --preview 'eza ...'` |
| `hidden_preview` | `fd --type d --hidden \| fzf --preview 'eza ...'` |

To add custom presets, edit the `presets` table in `main.lua`:

```lua
local presets = {
    default = "fd --type d | fzf",
    hidden  = "fd --type d --hidden | fzf",
    preview = "fd --type d | fzf --preview 'eza --tree --color=always --icons --level=2 {}'",
    -- Add your own presets here:
    shallow = "fd --type d --max-depth 3 | fzf",
}
```

## License

MIT
