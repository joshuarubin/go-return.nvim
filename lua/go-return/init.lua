local ts_utils = require("nvim-treesitter.ts_utils")
local luasnip = require("luasnip")

local M = {}

local function go_zero_value(type)
	if type == "error" then
		return "err"
	end

	-- pointers and slices
	local first = type:sub(1, 1)
	if first == "*" or first == "[" or type == "any" or type == "interface{}" then
		return "nil"
	end

	if type == "bool" then
		return "false"
	end

	if type == "string" then
		return '""'
	end

	if
		type == "int"
		or type == "int8"
		or type == "int16"
		or type == "int32"
		or type == "int64"
		or type == "uint"
		or type == "uint8"
		or type == "uint16"
		or type == "uint32"
		or type == "uint64"
		or type == "float32"
		or type == "float64"
		or type == "complex64"
		or type == "complex128"
		or type == "uintptr"
		or type == "byte"
		or type == "rune"
	then
		return "0"
	end

	-- default to nil, works for maps and interfaces
	-- doesn't work for struct types
	return "nil"
end

local function split_go_args(text)
	local args
	if text ~= nil and text:sub(1, 1) == "(" then
		text = text:sub(2, -2)
		args = vim.split(text, ",")
	else
		args = { text }
	end

	for i, arg in pairs(args) do
		local spl = vim.split(arg, " +")
		if table.maxn(spl) > 1 then
			arg = spl[2]
		end
		args[i] = vim.trim(arg)
	end

	return args
end

local function go_return_values(args, parent, user_args)
	local node = ts_utils.get_node_at_cursor()
	while node ~= nil do
		if
			node:type() == "function_declaration"
			or node:type() == "func_literal"
			or node:type() == "method_declaration"
		then
			break
		end
		node = node:parent()
	end

	if node == nil then
		return ""
	end

	local nodes = node:field("result")
	if nodes == nil then
		return ""
	end

	local ret = "return"

	local result = nodes[1]
	if result == nil then
		return ret
	end

	-- text can be a single value like "float64" or "error"
	-- or a list
	local text = vim.treesitter.get_node_text(result, 0)

	local results = split_go_args(text)

	for i, arg in pairs(results) do
		if i ~= 1 then
			ret = ret .. ","
		end
		ret = ret .. " " .. go_zero_value(arg)
	end

	return ret
end

local default_options = {
	name = "ie",
}

M.setup = function(opts)
	opts = opts or {}
	local conf = vim.tbl_deep_extend("force", default_options, opts)
	luasnip.add_snippets("go", {
		luasnip.snippet(conf.name, {
			luasnip.indent_snippet_node(1, {
				luasnip.text_node({ "if err != nil {", "" }),
				luasnip.function_node(go_return_values, {}, {}),
			}, "$PARENT_INDENT\t"),
			luasnip.text_node({ "", "}" }),
		}),
	}, {
		key = "go",
	})
end

return M
