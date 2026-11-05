-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Viewer command line, file path is appended shell-escaped (set before VeryLazy):
vim.g.mdfried_command = "tuios split-window vertical -- mdfried"
local md_cmd = vim.g.mdfried_command or "mdfried"
local md_bin = md_cmd:match("^%S+")

if md_bin and vim.fn.executable(md_bin) == 1 then
  local function readme(dir)
    for _, name in ipairs({ "README.md", "readme.md" }) do
      local path = dir .. "/" .. name
      if vim.fn.filereadable(path) == 1 then
        return path
      end
    end
  end

  --- Markdown file to preview: the focused explorer's selection (or its README),
  --- else the buffer's own file.
  ---@return string? file, boolean from_explorer
  local function md_file()
    if type(Snacks) == "table" and Snacks.picker then
      for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
        if picker:is_focused() then
          local item = picker:current()
          local file = item and item.file
          if file then
            if item.dir then
              file = readme(file)
            elseif not file:lower():match("%.md$") then
              file = readme(vim.fs.dirname(file))
            end
            if file then
              return file, true
            end
          end
        end
      end
    end
    local name = vim.api.nvim_buf_get_name(0)
    if name ~= "" and name:lower():match("%.md$") then
      return name, false
    end
  end

  -- Focus the window already showing the file, else edit it in the first
  -- non-picker window (a dashboard/terminal pane is replaced), splitting only
  -- when the explorer is the only window.
  local function open_md(file)
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
      if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == file then
        return vim.api.nvim_set_current_win(win)
      end
    end
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "" or vim.bo[buf].filetype:sub(1, 13) ~= "snacks_picker" then
        vim.api.nvim_set_current_win(win)
        return vim.cmd("edit " .. vim.fn.fnameescape(file))
      end
    end
    vim.cmd("split " .. vim.fn.fnameescape(file))
  end

  vim.keymap.set("n", "<leader>uM", function()
    local file, from_explorer = md_file()
    if not file then
      return
    end
    if from_explorer then
      open_md(file)
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      return
    end
    -- :! reads the file on disk, not the buffer
    if vim.bo.modified then
      vim.cmd.write()
      vim.notify("mdfried: saved " .. vim.fn.fnamemodify(file, ":~:."), vim.log.levels.INFO)
    end
    if md_bin == "tuios" then
      -- tuios holds split-window's reply up to 10s when the spawn came from a
      -- zoomed pane (verb_layout.go splitDone/splitSettled), so run detached
      vim.cmd("!" .. md_cmd .. " " .. vim.fn.shellescape(file) .. " >/dev/null 2>&1 &")
    else
      vim.cmd("!" .. md_cmd .. " " .. vim.fn.shellescape(file))
      if vim.v.shell_error ~= 0 then
        vim.notify("mdfried: exited with " .. vim.v.shell_error, vim.log.levels.ERROR)
      end
    end
  end, { desc = "Markdown viewer (mdfried)" })
end
