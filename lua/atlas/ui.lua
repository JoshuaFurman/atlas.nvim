local M = {}

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

	-- Tree-drawing characters
	local branch = "├── "
	local last_branch = "└── "
	local vertical = "│   "
	local blank = "    "

	--- Check if entry at index `idx` is the last sibling at its level.
	--- Scans forward: returns true if no subsequent entry shares the same
	--- level before we leave the parent scope (an entry at level <= level-1).
	---@param idx integer
	---@return boolean
	local function is_last_sibling(idx)
		local lvl = entries[idx].level
		for j = idx + 1, #entries do
			if entries[j].level == lvl then
				return false -- found another sibling
			end
			if entries[j].level < lvl then
				return true -- left parent scope, no more siblings
			end
		end
		return true -- reached end of list
	end

	--- For a given entry at index `idx`, determine whether an ancestor at
	--- depth `depth` still has remaining siblings below. This controls
	--- whether we draw "│   " (continuation) or "    " (blank) at that
	--- depth column.
	---@param idx integer
	---@param depth integer
	---@return boolean
	local function ancestor_has_more(idx, depth)
		for j = idx + 1, #entries do
			if entries[j].level == depth then
				return true -- found a later entry at this ancestor depth
			end
			if entries[j].level < depth then
				return false -- left the ancestor's scope
			end
		end
		return false
	end

	for i, entry in ipairs(entries) do
		if entry.level == 1 then
			-- Root-level headers: no tree prefix
			table.insert(lines, entry.text)
		else
			local prefix = ""
			-- Build prefix for ancestor depths (2 .. entry.level - 1)
			for d = 2, entry.level - 1 do
				if ancestor_has_more(i, d) then
					prefix = prefix .. vertical
				else
					prefix = prefix .. blank
				end
			end
			-- Append branch connector at the entry's own depth
			if is_last_sibling(i) then
				prefix = prefix .. last_branch
			else
				prefix = prefix .. branch
			end
			table.insert(lines, prefix .. entry.text)
		end
		mapping[i] = entry.line
	end

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Calculate dimensions (60% width, adaptive height)
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create floating window with border and title
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Atlas ",
		title_pos = "center",
	}
	local win_id = vim.api.nvim_open_win(buf, true, opts)

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
