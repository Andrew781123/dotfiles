local status, commentstring = pcall(require, "ts_context_commentstring")
if not status then
	print("Cannot load ts_context_commentstring")
	return
end

commentstring.setup()
