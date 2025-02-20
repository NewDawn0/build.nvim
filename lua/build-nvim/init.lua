--- @class BuildNvim
--- A module for running shell commands inside a new Neovim buffer.
local M = {}

local usrcmd = vim.api.nvim_create_user_command

--- @class BuildNvimConfig
--- @field build string The shell command to build the project.
--- @field run string The shell command to run the project.

--- Default configuration
local config = {
	build = "",
	run = "",
}

--- Runs a shell command inside a temporary buffer.
--- @param cmd string The shell command to execute.
--- @param name string The name of the buffer.
local function run(cmd, name)
	if cmd == "" then
		vim.api.nvim_err_writeln("[build.nvim] No command set for " .. name)
		return
	end

	-- Create a new bottom-right split with a buffer
	vim.cmd("botright 10split")
	vim.cmd("enew")

	-- Configure buffer options
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_name(0, name)

	-- Get buffer ID
	local buf = vim.api.nvim_get_current_buf()

	-- Initialize buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "$ " .. cmd, "" })

	-- Create pipes for stdout and stderr
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	-- Spawn shell process
	local handle
	handle = vim.loop.spawn("sh", {
		args = { "-c", cmd },
		stdio = { nil, stdout, stderr },
	}, function(code, _)
		-- Close pipes and handle after execution
		stdout:close()
		stderr:close()
		handle:close()

		-- Display exit code in buffer
		vim.schedule(function()
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "[Exit code " .. code .. "]" })
		end)
	end)

	-- Read and append stdout output to buffer
	vim.loop.read_start(stdout, function(err, data)
		assert(not err, err)
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(
					buf,
					-1,
					-1,
					false,
					vim.tbl_filter(function(line)
						return line ~= ""
					end, vim.split(data, "\n"))
				)
			end)
		end
	end)

	-- Read and append stderr output to buffer
	vim.loop.read_start(stderr, function(err, data)
		assert(not err, err)
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(data, "\n"))
			end)
		end
	end)

	-- Set buffer to read-only mode
	vim.bo[buf].readonly = true
end

--- Sets up the `:Build` command with subcommands.
--- @param cfg BuildNvimConfig? Optional configuration table.
M.setup = function(cfg)
	config = vim.tbl_extend("force", config, cfg or {})

	usrcmd("Build", function(args)
		local subcommand = args.fargs[1]
		local command_value = table.concat(vim.list_slice(args.fargs, 2), " ")

		if subcommand == "build" then
			run(config.build, "[build.nvim] > build")
		elseif subcommand == "run" then
			run(config.run, "[build.nvim] > run")
		elseif subcommand == "setbuild" then
			if command_value == "" then
				vim.api.nvim_err_writeln("[build.nvim] Please provide a new build command.")
			else
				config.build = command_value
				vim.notify("[build.nvim] Build command set to: " .. config.build)
			end
		elseif subcommand == "setrun" then
			if command_value == "" then
				vim.api.nvim_err_writeln("[build.nvim] Please provide a new run command.")
			else
				config.run = command_value
				vim.notify("[build.nvim] Run command set to: " .. config.run)
			end
		else
			vim.api.nvim_err_writeln("[build.nvim] Unknown subcommand: " .. (subcommand or ""))
		end
	end, {
		nargs = "+",
		complete = function(_, _, _)
			return { "build", "run", "setbuild", "setrun" }
		end,
	})
end

return M
