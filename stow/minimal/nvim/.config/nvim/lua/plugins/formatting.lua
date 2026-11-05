-- TOML: tombi's formatter. Array layout is the author's call via a trailing
-- comma ("magic trailing comma"), so this file stays free of per-array rules.
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { toml = { "tombi" } },
    },
  },
}
