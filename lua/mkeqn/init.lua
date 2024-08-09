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
        -- Replace start with "EE" and end with "FF"
        local modifiedString = trimmedInput:gsub("^\\%[%s*", "\\begin{equation}   "):gsub("%s*\\%]$", "   \\end{equation}")
        print(modifiedString)
    elseif trimmedInput:match("^%$%$%s*(.-)%s*%$%$") then
        -- Replace start with "EE" and end with "FF"
        local modifiedString = trimmedInput:gsub("^%$%$%s*", "\\begin{equation}   "):gsub("%s*%$%$", "   \\end{equation}")
        print(modifiedString)
    else
        print("not found")
    end
end

function M.mkeqn(number)
	
	-- local line = vim.fn.getline(".")
	local line = vim.api.nvim_buf_get_lines(0, number -1, number, false)[1]
	local comments = ""

	local hasComment = string.find(line,"%%")
	if (hasComment) then
		comments = "   " .. string.sub(line, hasComment, -1)
		line = string.sub(line, 1, hasComment -1)
	end

	line = regexMakeEqn(line) + comments 

	-- * `false`: This argument controls strict indexing; `false` means out-of-bounds indices are clamped.
	vim.api.nvim_buf_set_lines(0, number-1, number, false, line) 

end

return M
