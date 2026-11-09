-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	group = augroup,
	pattern = "*",
	command = "set nopaste",
})

-- Highlight the current line on only the active buffer
local cursorline_group = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
	group = cursorline_group,
	pattern = "*",
	command = "setlocal cursorline",
})
vim.api.nvim_create_autocmd("WinLeave", {
	group = cursorline_group,
	pattern = "*",
	command = "setlocal nocursorline",
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Input source: English in normal mode, restore the previous one when inserting.
-- "0" skips macism's temporary-window workaround, which steals focus and makes the terminal flicker.
if vim.fn.executable("macism") == 1 then
	local english = "com.apple.keylayout.ABC"
	local saved
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = augroup,
		callback = function()
			vim.system({ "macism" }, { text = true }, function(r)
				saved = vim.trim(r.stdout or "")
				if saved ~= "" and saved ~= english then
					vim.system({ "macism", english, "0" })
				end
			end)
		end,
	})
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = augroup,
		callback = function()
			if saved and saved ~= english then
				vim.system({ "macism", saved, "0" })
			end
		end,
	})
end

-- Custom filetypes
vim.filetype.add({
	extension = {
		mjml = "html",
	},
})
