local M = {}
local P = function(v)
	print(vim.inspect(v))
	return v
end

local find_mapping = function(maps, lhs)
	for _, value in ipairs(maps) do
		-- P(value)
		if value.lhs == lhs then
			return value
		end
	end
end

M._stack = {}

M.push = function(name, mode, mappings)
	local maps = vim.api.nvim_get_keymap(mode)

	local existing_maps = {}

	for lhs, rhs in pairs(mappings) do
		local existing = find_mapping(maps, lhs)

		if existing then
			existing_maps[lhs] = existing
		end
	end

	M._stack[name] = {
		mode = mode,
		existing = existing_maps,
		mappings = mappings,
	}

	P(M._stack)
	-- for lhs, rhs in pairs(mappings) do
	-- 	vim.keymap.set(mode, lhs, rhs)
	-- end
end

M.pop = function(name)
	local state = M._stack[name]
	M._stack[name] = nil

	for lhs, rhs in pairs(state.mappings) do
		if state.existing[lhs] then
			-- Handle existing mappings
			local og_mappings = state.existing[lhs]
			vim.keymap.set(state.mode, lhs, og_mappings.rhs)
		else
			-- Handle mapping that didn't exist before
			vim.keymap.del(state.mode, lhs)
		end
	end
end

M.push("debug_mode", "n", {
	[" st"] = "echo 'Hello'",
	["<leader>sz"] = "echo 'Goodbye",
	[" Y"] = "echo 'Gopy'",
})

return M
