local status, dressing = pcall(require, "stevearc/dressing.nvim")
if not status then
	return
end

dressing.setup()
