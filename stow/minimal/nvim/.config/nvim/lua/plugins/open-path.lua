-- Open a file or directory path from the system clipboard (`+` register).
-- Directory -> `tcd` there (tab-local) and open/focus the Snacks explorer.
-- File      -> edit the file directly.
-- The explorer follows the cd via its DirChanged handler; `:tcd -` goes back.
-- Pairs with tmux's `set-clipboard on`: copy a path in a pane, then <leader>fO.

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fO",
        function()
          local raw = vim.trim(vim.fn.getreg("+"))
          if raw == "" then
            return vim.notify("Clipboard is empty", vim.log.levels.WARN)
          end

          -- Build candidates from the raw value: itself, each line, an unwrapped
          -- form (surrounding quotes / brackets / commas) and a `:line:col`-stripped
          -- form. Raw comes first so a real path is never mangled; the first
          -- candidate that exists on disk wins.
          local function unwrap(s)
            return (s:gsub('^[%s"\'`%[%(%{<]+', ""):gsub('[%s"\'`%]%)%}>%,;]+$', ""))
          end

          local seen, cands = {}, {}
          local function add(s)
            s = vim.trim(s)
            if s ~= "" and not seen[s] then
              seen[s] = true
              cands[#cands + 1] = s
            end
          end

          add(raw)
          for line in raw:gmatch("[^\r\n]+") do
            add(line)
          end
          for _, s in ipairs(vim.deepcopy(cands)) do
            add(unwrap(s))
          end
          for _, s in ipairs(vim.deepcopy(cands)) do
            add((s:gsub(":%d+:%d+$", ""):gsub(":%d+$", "")))
          end

          local path
          for _, cand in ipairs(cands) do
            local p = cand:match("^file://") and vim.uri_to_fname(cand) or vim.fn.expand(cand)
            if vim.fn.isdirectory(p) == 1 or vim.fn.filereadable(p) == 1 then
              path = p
              break
            end
          end
          if not path then
            return vim.notify("Not a readable path: " .. raw, vim.log.levels.WARN)
          end

          if vim.fn.isdirectory(path) == 1 then
            -- cwd follows the navigation; the explorer re-roots itself on DirChanged
            vim.cmd.tcd({ args = { path } })
            local explorer = require("snacks").picker.get({ source = "explorer" })[1]
            if explorer then
              explorer:focus()
            else
              require("snacks").explorer({ cwd = path })
            end
          else
            vim.cmd.edit({ args = { path } })
          end        end,
        desc = "Open path from clipboard",
      },
    },
  },
}
