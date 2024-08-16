local Job = require('plenary.job')
local api = vim.api
local util = require('vim.lsp.util')

-- Helper function to split text into lines
local function split_lines(text)
	local lines = {}
	for line in text:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

-- Create a floating window with formatted output
local function create_float_win(contents)
	local buf = api.nvim_create_buf(false, true)

	-- Ensure contents is a table of lines
	if type(contents) == "string" then
		contents = split_lines(contents)
	end

	-- Sanitize lines to ensure no newlines within each line
	local sanitized_contents = {}
	for _, line in ipairs(contents) do
		if type(line) == "string" then
			-- Ensure that the line does not contain newlines
			line = line:gsub("\n", " ")
			table.insert(sanitized_contents, line)
		end
	end

	-- Set lines to the buffer
	api.nvim_buf_set_lines(buf, 0, -1, false, sanitized_contents)

	-- Define highlight groups for error and warning
	vim.cmd('highlight Error guifg=#FF0000 gui=bold')
	vim.cmd('highlight Warning guifg=#FFA500 gui=bold')
	vim.cmd('highlight Title guifg=#F28FAD gui=bold')
	vim.cmd('highlight NormalFloat guibg=#1e1e2e')
	vim.cmd('highlight FloatBorder guifg=#F28FAD')

	-- Define extmark highlights
	local ns_id = api.nvim_create_namespace('stylelint')

	local function highlight_line(buf, line, col_start, col_end, hl_group)
		api.nvim_buf_set_extmark(buf, ns_id, line, col_start, {
			end_col = col_end,
			hl_group = hl_group,
		})
	end

	-- Apply highlights
	local function apply_highlights()
		for i, line in ipairs(sanitized_contents) do
			if line:match("✖") then
				highlight_line(buf, i - 1, 0, #line, 'Error')
			elseif line:match("⚠️") then
				highlight_line(buf, i - 1, 0, #line, 'Warning')
			elseif line:match("Stylelint Report") or line:match("=") then
				highlight_line(buf, i - 1, 0, #line, 'Title')
			end
		end
	end

	apply_highlights()

	-- Determine window dimensions based on content
	local win_height = math.min(#sanitized_contents + 2, 20) -- Limit height to avoid overly large windows
	local win_width = math.max(40,
		math.max(unpack(vim.tbl_map(function(line) return #line end, sanitized_contents))) + 2)
	local row = math.floor((vim.o.lines - win_height) / 2)
	local col = math.floor((vim.o.columns - win_width) / 2)

	-- Floating window options
	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = "rounded",
	}

	-- Open the floating window
	local win = api.nvim_open_win(buf, true, opts)

	-- Enable scroll support in the floating window
	api.nvim_win_set_option(win, 'scrolloff', 0)
	api.nvim_win_set_option(win, 'sidescroll', 1)

	-- Set keymaps for buffer
	api.nvim_buf_set_keymap(buf, 'n', 'q', '<Cmd>bd!<CR>', { noremap = true, silent = true })

	-- Set UI highlights
	api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal,FloatBorder:FloatBorder')

	-- Set the window as the current one
	api.nvim_set_current_win(win)
end

-- Run Stylelint on the current file
local function run_stylelint()
	local current_file = vim.api.nvim_buf_get_name(0)

	-- Ensure the file path is correct
	if current_file == "" then
		print("No file detected")
		return
	end

	Job:new({
		command = "stylelint",
		args = { current_file },
		on_exit = function(j, return_val)
			local result = j:result()
			local stderr_result = j:stderr_result()

			-- Convert result and stderr_result to tables of lines
			local result_lines = vim.tbl_isempty(result) and {} or split_lines(table.concat(result, "\n"))
			local stderr_lines = vim.tbl_isempty(stderr_result) and {} or
			split_lines(table.concat(stderr_result, "\n"))

			if return_val == 0 then
				if #result_lines == 0 then
					vim.schedule(function()
						create_float_win({
							"No issues found, but no output was returned from Stylelint." })
					end)
				else
					vim.schedule(function()
						create_float_win(result_lines)
					end)
				end
			else
				if #stderr_lines > 0 then
					vim.schedule(function()
						create_float_win({
							"Stylelint encountered an error:",
							string.rep("=", 30),
							table.concat(stderr_lines, "\n")
						})
					end)
				else
					vim.schedule(function()
						create_float_win({
							"Stylelint failed with no stderr output.",
							"Possible reasons:",
							"1. The file type may not be supported.",
							"2. Stylelint configuration may be missing.",
							"3. The file might be empty or ignored."
						})
					end)
				end
			end
		end,
		on_stderr = function(j, err_data)
			-- Log stderr data for debugging
			print("Error running stylelint (stderr):", vim.inspect(err_data))
		end,
	}):start()
end

return {
	setup = function()
		vim.api.nvim_create_user_command('StylelintCurrentFile', run_stylelint, { nargs = 0 })
	end
}
