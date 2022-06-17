local M = {}

local Path = require("plenary.path")
local log = require("plenary.log")
-- local Path = {
	-- sep = "/",
-- }
local config = require("coverage.config")
local signs = require("coverage.signs")
local util = require("coverage.util")

--- Returns a list of signs to be placed.
-- @param json_data from the generated report
M.sign_list = function(json_data)
	local sign_list = {}
	for fname, cov in pairs(json_data.files) do
		local buffer = vim.fn.bufnr(fname, false)
		if buffer ~= -1 then
			for lnum, covered in pairs(cov.line_coverage) do
				if covered then
					table.insert(sign_list, signs.new_covered(buffer, lnum))
				else
					table.insert(sign_list, signs.new_uncovered(buffer, lnum))
				end
			end
		end
	end
	return sign_list
end

--- Returns a summary report.
M.summary = function(json_data)
	local files = {}
	local totals = {
		statements = json_data.total.total_statements,
		coverage = json_data.total.coverage,
	}
	for fname, cov in pairs(json_data.files) do
		table.insert(files, {
			filename = fname,
			statements = cov.total_statements,
			-- missing = cov.missing_lines,
			coverage = cov.coverage,
		})
	end
	return {
		files = files,
		totals = totals,
	}
end

local sep = (function()
  if jit then
    local os = string.lower(jit.os)
    if os == "linux" or os == "osx" or os == "bsd" then
      return "/"
    else
      return "\\"
    end
  else
    return package.config:sub(1, 1)
  end
end)()

local _split_by_separator = (function()
  local formatted = string.format("([^%s]+)", sep)
  return function(filepath)
    local t = {}
    for str in string.gmatch(filepath, formatted) do
      table.insert(t, str)
    end
    return t
  end
end)()

--- Loads a coverage report.
-- @param callback called with the results of the coverage report
M.load = function(callback)
	-- local go_config = config.opts.lang.go
	local go_config = {
		coverage_file="./cover.out",
	}

	local p = Path:new(go_config.coverage_file)
	if not p:exists() then
		vim.notify("No coverage data file exists.", vim.log.levels.INFO)
		return
	end

	local file = io.open(go_config.coverage_file, 'r')

	local lines = file:lines()

	local profile = {
		total = {
			total_statements = 0,
			covered_statements = 0,
			coverage = 0,
		},
		files = {},
	}

	-- skip the header line
	lines()

	for line in lines do
		local fname, start_line, end_line, num_statements, count = string.match(
			line, 
			"^(.+):(%d+)%.%d*,(%d+)%.%d+ (%d+) (%d+)")
		-- print(fname, path.sep)
		--

		fname = table.concat({ unpack(_split_by_separator(fname), 4) }, sep)

		-- log.info(_split_by_separator(filename))
		-- log.info(unpack(_split_by_separator(filename)))

		if profile.files[fname] == nil then
			profile.files[fname] = {
				total_statements = 0,
				covered_statements = 0,
				line_coverage = {},
				coverage = 0,
			}
		end

		statements = tonumber(num_statements)

		f = profile.files[fname]

		profile.total.total_statements =  profile.total.total_statements + statements
		f.total_statements = f.total_statements + statements

		if tonumber(count) > 0 then
			profile.total.covered_statements = profile.total.covered_statements + statements
			f.covered_statements = f.covered_statements + statements

			for i = tonumber(start_line), tonumber(end_line) do
				f.line_coverage[i] = true
			end
		else
			for i = tonumber(start_line), tonumber(end_line) do
				f.line_coverage[i] = f.line_coverage[i] or false
			end
		end

		f.coverage = (f.covered_statements / f.total_statements) * 100
		profile.total.coverage = (profile.total.covered_statements / profile.total.total_statements) * 100
	end

	-- if profile.total.total_statements > 0 then
		-- profile.total.coverage = (profile.total.covered_statements / profile.total.total_statements) * 100
	-- end

	-- for fname, file in ipairs(profile.files) do
		-- profile.files[fname].coverage = (file.covered_statements / file.total_statements) * 100
	-- end

	callback(profile)
end

return M
