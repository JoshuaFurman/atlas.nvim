local M = {}
local parser = require("atlas.parser")
local ui = require("atlas.ui")

---@class AtlasConfig
---@field check_filetype boolean Check if buffer is markdown (default: true)

local default_config = {
  check_filetype = true,
}

---@param opts? AtlasConfig
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", default_config, opts or {})

  vim.api.nvim_create_user_command("Atlas", function()
    local bufnr = vim.api.nvim_get_current_buf()
    
    if opts.check_filetype then
      local ft = vim.bo[bufnr].filetype
      if ft ~= "markdown" and ft ~= "vimwiki" then
        vim.notify("Atlas is only available for Markdown files.", vim.log.levels.WARN)
        return
      end
    end

    local current_win = vim.api.nvim_get_current_win()
    local entries = parser.parse(bufnr)
    
    if #entries == 0 then
       vim.notify("No headers found.", vim.log.levels.INFO)
       return
    end

    ui.show(entries, current_win)
  end, {
    desc = "Show Table of Contents for current Markdown buffer",
  })
end

return M
