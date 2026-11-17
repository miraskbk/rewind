local M = {}
local DATA_FILE = vim.fn.stdpath("data") .. "/rewind.json"

local function get_open_files()
	local files = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and name ~= "" then
			table.insert(files, name)
		end
	end
	return files
end

local function load()
	if vim.fn.filereadable(DATA_FILE) == 0 then
		return {}
	end

	local content = vim.fn.readfile(DATA_FILE)[1]
	local ok, decoded = pcall(vim.json.decode, content)

	if not ok or type(decoded) ~= "table" then
		vim.notify("rewind: file corrupted", vim.log.levels.WARN)
		return {}
	end
	return decoded
end

local function save()
	local data = load()
	data[vim.fn.getcwd()] = get_open_files()

	local table_json = vim.json.encode(data)
	vim.fn.writefile({ table_json }, DATA_FILE)
end

function M.setup()
	local group = vim.api.nvim_create_augroup("rewind", { clear = true })

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = save,
	})
end
return M
