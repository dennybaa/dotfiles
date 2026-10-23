local M = {}

local presets = {
	default        = "fd --type d | fzf",
	hidden         = "fd --type d --hidden | fzf",
	hidden_nogit   = "fd --type d --hidden --exclude .git | fzf",
	preview        = "fd --type d | fzf --preview 'eza --tree --color=always --icons --level=2 {}'",
	hidden_preview = "fd --type d --hidden | fzf --preview 'eza --tree --color=always --icons --level=2 {}'",
}

local state = ya.sync(function()
	return cx.active.current.cwd
end)

function M:entry(job)
	local cwd = state()
	local name = job.args[1] or "default"
	local cmd = presets[name] or presets["default"]

	local permit = ui.hide()
	local child, spawn_err = Command("sh")
		:arg("-c")
		:arg(cmd)
		:cwd(tostring(cwd))
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		permit:drop()
		ya.notify({ title = "fd-fzf.yazi", content = "Failed: " .. tostring(spawn_err), level = "error", timeout = 3 })
		return
	end

	local output, err = child:wait_with_output()
	permit:drop()

	if not output then
		ya.notify({ title = "fd-fzf.yazi", content = tostring(err), level = "error", timeout = 3 })
		return
	end
	if not output.status.success then
		return
	end

	local selected = output.stdout:gsub("\n$", "")
	if selected ~= "" then
		ya.emit("cd", { cwd:join(selected), raw = true })
	end
end

return M
