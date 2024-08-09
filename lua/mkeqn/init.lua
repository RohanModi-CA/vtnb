-- local RunOnAllFileTypes = not (vim.g.VTSRunOnAllFileTypes==nil)
local M = {}

--[[
if RunOnAllFileTypes then
	vim.api.nvim_create_autocmd({"TextChangedI"},{
		callback = function()
			llvp.process_current_line()
		end,
	})
else
	vim.api.nvim_create_autocmd({"TextChangedI"},{
		pattern = "*.tex",
		callback = function()
			llvp.process_current_line()
		end,
	})
end
]]

local function regexMakeEqn(input)
    -- Remove leading and trailing whitespace
    local trimmedInput = input:match("^%s*(.-)%s*$")
    -- Check if the string starts with "\[" and ends with "\]"
    if trimmedInput:match("^\\%[%s*(.-)%s*\\%]$") then
        local modifiedString = trimmedInput:gsub("^\\%[%s*", "\\begin{equation}   "):gsub("%s*\\%]$", "   \\end{equation}")
        return(modifiedString)
    elseif trimmedInput:match("^%$%$%s*(.-)%s*%$%$") then
        local modifiedString = trimmedInput:gsub("^%$%$%s*", "\\begin{equation}   "):gsub("%s*%$%$", "   \\end{equation}")
        return(modifiedString)
    else
		error("no math mode delimiters ($$ $$) or (\\[ \\]) found")
    end
end


local function regexKillEqn(input)
    -- Remove leading and trailing whitespace
    local trimmedInput = input:match("^%s*(.-)%s*$")
    -- Check if the string starts with "\[" and ends with "\]"
    if trimmedInput:match("^\\begin{%s*equation%s*}(.-)%s*\\end{%s*equation%s*}$") then
        local modifiedString = trimmedInput:gsub("^\\begin{%s*equation%s*}", "\\[     "):gsub("\\end{%s*equation%s*}$", "     \\]")
        return(modifiedString)
   else
		error("no equations found! (must be enclosed within a \\begin{equation} and \\end{equation})")
    end
end





function M.mkeqn(number)
	
	number = tonumber(number)
	-- local line = vim.fn.getline(".")
	local line = vim.api.nvim_buf_get_lines(0, number -1, number, false)[1]
	local comments = ""

	local hasComment = string.find(line,"%%")
	if (hasComment) then
		comments = "   " .. string.sub(line, hasComment, -1)
		line = string.sub(line, 1, hasComment -1)
	end

	line = regexMakeEqn(line) .. comments 

	-- * `false`: This argument controls strict indexing; `false` means out-of-bounds indices are clamped.
	line_table = {}
	table.insert(line_table, line)
	vim.api.nvim_buf_set_lines(0, number-1, number, false, line_table) 

end


function M.killeqn(number)
	
	number = tonumber(number)
	-- local line = vim.fn.getline(".")
	local line = vim.api.nvim_buf_get_lines(0, number -1, number, false)[1]
	local comments = ""

	local hasComment = string.find(line,"%%")
	if (hasComment) then
		comments = "   " .. string.sub(line, hasComment, -1)
		line = string.sub(line, 1, hasComment -1)
	end

	line = regexKillEqn(line) .. comments 

	-- * `false`: This argument controls strict indexing; `false` means out-of-bounds indices are clamped.
	line_table = {}
	table.insert(line_table, line)
	vim.api.nvim_buf_set_lines(0, number-1, number, false, line_table) 

end


return M
