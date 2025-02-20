local M = {}
local usrcmd = vim.api.nvim_create_user_command

function run(cmd, name)
	-- Open a new split at the bottom
	vim.cmd("botright 10split") -- Open a split with height of 10 lines
	vim.cmd("enew") -- Create a new empty buffer
	vim.bo.buftype = "nofile" -- Make it a temporary buffer
	vim.bo.bufhidden = "wipe" -- Auto-remove buffer when closed
	vim.bo.swapfile = false -- No swap file
	vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })

	vim.api.nvim_buf_set_name(0, name)

	local buf = vim.api.nvim_get_current_buf()

	-- Initial header
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "$ " .. cmd, "" })

	-- Run command asynchronously
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)

	local handle
	handle = vim.loop.spawn("sh", {
		args = { "-c", cmd }, -- Run the command in a shell
		stdio = { nil, stdout, stderr },
	}, function(code, _)
		stdout:close()
		stderr:close()
		handle:close()
		vim.schedule(function()
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "[Exit code " .. code .. "]" })
		end)
	end)
	-- Read data streams
	vim.loop.read_start(stdout, function(err, data)
		assert(not err, err)
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(
					buf,
					-1,
					-1,
					false,
					vim.tbl_filter(function(l)
						return l ~= ""
					end, vim.split(data, "\n"))
				)
			end)
		end
	end)
	vim.loop.read_start(stderr, function(err, data)
		assert(not err, err)
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(data, "\n"))
			end)
		end
	end)
	vim.bo[buf].readonly = true
end

M.setup = function(cfg)
	cfg = cfg or { build = "", run = "" }
	usrcmd("Build", function()
		run(cfg.build, "[build.nvim] > build")
	end, {})
	usrcmd("Run", function()
		run(cfg.run, "[build.nvim] > run")
	end, {})
end

return M
