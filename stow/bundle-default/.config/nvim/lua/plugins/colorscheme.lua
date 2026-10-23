return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
    },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local art = vim.fn.stdpath("config") .. "/assets/unlab.txt"

      -- width in cells of the widest art line, read once; chafa picks it from the
      -- source aspect and it changes with every new asset
      local art_width ---@type number?
      local function width()
        art_width = art_width or 0
        if art_width == 0 then
          for _, line in ipairs(vim.fn.readfile(art)) do
            line = line:gsub("\27%[[%d;?]*[ -/]*[@-~]", "")
            art_width = math.max(art_width, vim.fn.strdisplaywidth(line))
          end
        end
        return art_width
      end
      opts.dashboard.sections = {
        -- ⬇️ New: art on top of the keys, left pane
        {
          pane = 1,
          align = "center",
          header = require("config.header"),
          padding = 1,
        },
        { section = "keys", gap = 1, padding = 1, pane = 1 },
        { section = "startup", pane = 1 },
        -- The art is a floating window sized to the 30-line file. If the dashboard window
        -- is shorter than the art, the float spills over a split below it (e.g. the
        -- bottom terminal) and paints on top of it, so skip it when it wouldn't fit.
        function(self)
          local size = self:size()
          local gap = self.opts.pane_gap
          local panes = math.floor((size.width + gap) / (self.opts.width + gap))
          local need = panes >= 2 and 31 or 59 -- single pane puts the art below the keys
          local cells = width()
          -- a line wider than the float wraps onto the next row, so every other row
          -- would look skipped; skip the art instead
          if size.height < need or cells > self.opts.width then
            return {}
          end
          return {
            pane = 2,
            section = "terminal",
            cmd = "cat " .. art,
            height = 30,
            -- centre the float in its pane like the header/keys block
            indent = math.max(0, math.floor((self.opts.width - cells) / 2)),
            width = cells,
            padding = 1,
            pty = false,
            -- snacks appends `; sleep .1` on Linux, so a failed `cat` still exits 0 and the
            -- error gets cached. Keep the ttl short: it self-heals a bad read and avoids
            -- spawning a job on every resize (1/min instead of per re-render).
            ttl = 60,
          }
        end,
      }
    end,
  },
}
