-- local RunOnAllFileTypes = not (vim.g.VTSRunOnAllFileTypes==nil)
local M = {}

local function getNumeratorAndEnd(rest)
	rest = rest:gsub("KILLFRAC", "")
	current_index = 0
	count = 0
	old_count = 0
	is1or2 = 0
	start1 = -1
	start2 = -1
	end1 = -1 -- includes the bracket
	end2 = -1

	for c in rest:gmatch(".") do
	  
		current_index = current_index + 1
		old_count = count
		
		if c == '{' then
		  count = count + 1 
		end
		if c  == '}' then
		  count = count - 1
		end
		
		if count == 1 and old_count == 0 then
		  is1or2 = is1or2 + 1
		  
		  if is1or2 == 1 then
			start1 = current_index
		  elseif is1or2 == 2 then
			start2 = current_index
		  end
		end


		if count == 0 and old_count == 1 then
		  if is1or2 == 1 then
			end1 = current_index
		  elseif is1or2 == 2 then
			end2 = current_index
			break
		  end
		end
	  -- print(end2)
	end



	numerator = (string.sub(rest, start1 + 1, end1 - 1))

	if end2 == -1 then
	  rest = numerator .. "  " .. string.sub(rest, end1 + 1)
	elseif end2 ~= -1 then
	  rest = numerator .. "  " .. string.sub(rest, end2 + 1)
	end

	return rest
end


function M.killFrac(input, line_number)
	
	print("reached KF")
	-- no not found error handling necessary since this being run means there is definitely a KILLFRAC

	indexOfKILLFRAC = string.find(input,"KILLFRAC")

	reversedIndex = string.find((string.reverse(string.sub(input, 1, indexOfKILLFRAC - 1))), "carf\\" )
	
	if reversedIndex == -1 or reversedIndex == nil then
		print("Couldn't find a \\frac tag")
		return nil

	end

	indexOfFrac = string.len(string.sub(input, 1, indexOfKILLFRAC - 1)) + 2 - reversedIndex -5
	everythingBefore = string.sub(input, 0, indexOfFrac -1)
	everythingAfter = getNumeratorAndEnd(string.sub(input, indexOfFrac + 5))
	line = everythingBefore .. "  " .. everythingAfter

	line_table = {}
	table.insert(line_table, line)

	vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, line_table)

end


return M
