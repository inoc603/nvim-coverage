local M = {}

local config = require("coverage.config")

local highlight = function(group, color)
	local args = {
		color.style and "gui=" .. color.style or "gui=NONE",
		color.fg and "guifg=" .. color.fg or "guifg=NONE",
		color.bg and "guibg=" .. color.bg or "guibg=NONE",
		color.sp and "guisp=" .. color.sp or "",
		-- color.cterm and "cterm=" .. color.cterm or "cterm=NONE",
		color.ctermfg and "ctermfg=" .. color.ctermfg or "ctermfg=NONE",
		-- color.ctermbg and "ctermbg=" .. color.ctermbg or "ctermbg=NONE",
	}

	local hl = "highlight " .. group .. " " .. table.concat(args, " ")
	vim.cmd(hl)
	if color.link then
		vim.cmd("highlight! link " .. group .. " " .. color.link)
	end
end

local create_highlight_groups = function()
	highlight("CoverageCovered", config.opts.highlights.covered)
	highlight("CoverageUncovered", config.opts.highlights.uncovered)
	highlight("CoverageSummaryBorder", config.opts.highlights.summary_border)
	highlight("CoverageSummaryNormal", config.opts.highlights.summary_normal)
	highlight("CoverageSummaryCursorLine", config.opts.highlights.summary_cursor_line)
	highlight("CoverageSummaryPass", config.opts.highlights.summary_pass)
	highlight("CoverageSummaryFail", config.opts.highlights.summary_fail)
	highlight("CoverageSummaryHeader", config.opts.highlights.summary_header)
end

-- Creates default highlight groups.
M.setup = function()
	create_highlight_groups()
end

return M
