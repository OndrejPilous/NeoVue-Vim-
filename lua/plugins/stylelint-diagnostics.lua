local Job = require('plenary.job')
local api = vim.api

-- Helper function to split text into lines
local function split_lines(text)
	local lines = {}
	for line in text:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

-- Function to parse stylelint output into diagnostic items
local function parse_stylelint_output(output_lines)
	local diagnostics = {}

	-- Process each line of the output
	for _, line in ipairs(output_lines) do
		-- Adjust this pattern based on actual stylelint output
		local path, lnum, col, severity, message = line:match("^(.-): line (%d+), col (%d+), (%w+) %- (.+)$")

		if path and lnum and col and severity and message then
			-- Add the diagnostic item
			table.insert(diagnostics, {
				lnum = tonumber(lnum) - 1, -- Convert to 0-based index
				col = tonumber(col) - 1, -- Convert to 0-based index
				severity = severity:lower() == "error" and vim.diagnostic.severity.ERROR or
				    vim.diagnostic.severity.WARN,
				message = message,
				source = "stylelint",
			})
		end
	end

	return diagnostics
end

-- Function to report diagnostics using Neovim's built-in API
local function report_diagnostics(bufnr, diagnostics)
	-- Create a namespace for stylelint diagnostics
	local ns = vim.api.nvim_create_namespace("stylelint_namespace")

	-- Clear previous diagnostics in this namespace
	vim.diagnostic.reset(ns, bufnr)

	-- Set new diagnostics in this namespace
	vim.diagnostic.set(ns, bufnr, diagnostics)

	-- Debug output
	print("Diagnostics set for buffer:", bufnr)
end

-- Run Stylelint on the current file
local function run_stylelint()
	local current_file = api.nvim_buf_get_name(0)
	local bufnr = api.nvim_get_current_buf() -- Get the buffer number outside of the callback

	-- Ensure the file path is correct
	if current_file == "" then
		print("No file detected")
		return
	end

	-- Run stylelint using plenary job
	Job:new({
		command = "stylelint",
		args = { "--formatter", "compact", current_file },
		on_start = function()
		end,
		on_exit = function(j, return_val)
			local result = j:result()
			local stderr_result = j:stderr_result()

			-- Convert result and stderr_result to tables of lines
			local result_lines = split_lines(table.concat(result, "\n"))
			local stderr_lines = split_lines(table.concat(stderr_result, "\n"))

			-- Handle linting output from stdout or stderr (whichever has the diagnostics)
			if #result_lines > 0 then
				-- Parse the result lines into diagnostics
				local diagnostics = parse_stylelint_output(result_lines)

				vim.schedule(function()
					report_diagnostics(bufnr, diagnostics) -- Report using Neovim's diagnostic API
				end)
			elseif #stderr_lines > 0 then
				-- Parse stderr lines into diagnostics (Stylelint treats some issues as stderr)
				local diagnostics = parse_stylelint_output(stderr_lines)

				vim.schedule(function()
					report_diagnostics(bufnr, diagnostics) -- Report using Neovim's diagnostic API
				end)
			else
				-- No linting issues and no errors
				vim.schedule(function()
				end)
			end
		end,
		on_stderr = function(j, err_data)
			-- Debug print to confirm on_stderr is being triggered
			print("Error running stylelint:", vim.inspect(err_data))
		end,
	}):start()
end

return {
	setup = function()
		vim.api.nvim_create_user_command('StylelintCurrentFileDiagnostics', run_stylelint, { nargs = 0 })
	end
}
