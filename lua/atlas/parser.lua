local M = {}

---@class AtlasEntry
---@field line integer The line number (1-based) in the source buffer
---@field level integer The nesting level (number of hashes)
---@field text string The header text

---Parse the buffer to extract Markdown headers
---@param bufnr integer
---@return AtlasEntry[]
function M.parse(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local headers = {}
  local in_code_block = false

  for i, line in ipairs(lines) do
    -- Toggle code block status
    if line:match("^```") then
      in_code_block = not in_code_block
    end

    -- Only check for headers if we are not in a code block
    if not in_code_block then
      local level, text = line:match("^(#+)%s+(.*)$")
      if level and text then
        table.insert(headers, {
          line = i,
          level = #level,
          text = text,
        })
      end
    end
  end

  return headers
end

return M
