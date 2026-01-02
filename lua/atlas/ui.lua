local M = {}
local has_plenary, float = pcall(require, "plenary.window.float")

---@class AtlasEntry
---@field line integer
---@field level integer
---@field text string

---@param entries AtlasEntry[]
---@param source_win integer
function M.show(entries, source_win)
	if #entries == 0 then
		vim.notify("No headers found.", vim.log.levels.WARN)
		return
	end

	-- Create content for the TOC window
	local lines = {}
	local mapping = {}

	for i, entry in ipairs(entries) do
		local indent = string.rep("  ", entry.level - 1)
		table.insert(lines, indent .. entry.text)
		mapping[i] = entry.line
	end

	local win_id
	local buf

	if has_plenary then
		local res = float.percentage_range_window(0.5, 0.6, {}, {
			title = " Atlas ",
			border = "rounded",
		})
		win_id = res.win_id
		buf = res.bufnr
	else
		-- Simple fallback if plenary is missing
		buf = vim.api.nvim_create_buf(false, true)
		local width = math.floor(vim.o.columns * 0.6)
		local height = math.min(#lines, 20)
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)

		local opts = {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
		}
		win_id = vim.api.nvim_open_win(buf, true, opts)
	end

	-- Populate the buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "atlas"
	vim.bo[buf].bufhidden = "wipe"

	-- Set highlights (link to standard ones for NVChad compatibility)
	-- NVChad usually sets NormalFloat and FloatBorder.
	vim.wo[win_id].cursorline = true

	-- Keymaps
	local function close()
		if vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_win_close(win_id, true)
		end
	end

	local function jump()
		local cursor = vim.api.nvim_win_get_cursor(win_id)
		local row = cursor[1]
		local target_line = mapping[row]

		close()

		if vim.api.nvim_win_is_valid(source_win) then
			vim.api.nvim_set_current_win(source_win)
			vim.api.nvim_win_set_cursor(source_win, { target_line, 0 })
			-- Optional: Center the view
			vim.cmd("normal! zz")
		end
	end

	local opts = { noremap = true, silent = true, buffer = buf }
	vim.keymap.set("n", "q", close, opts)
	vim.keymap.set("n", "<Esc>", close, opts)
	vim.keymap.set("n", "<CR>", jump, opts)
end

return M
