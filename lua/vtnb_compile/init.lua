-- local RunOnAllFileTypes = not (vim.g.VTSRunOnAllFileTypes==nil)
local M = {}




local function readFileIntoTable(filename)
    local lines = {}
    local file = io.open(filename, "r")
    
    if not file then
        return nil, "Could not open file: " .. filename
    end
    
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()
    return lines
end



local function extract_text_blocks(input_table)
	local output_table = {}
	local inside_vtnb = false
	local inside_begin_end = false
	local code_count = 0

	for _, line in ipairs(input_table) do
		-- Check for vtnb start/end markers
		if string.find(line, "%%%%%% vtnb start %%%%%%") then
			inside_vtnb = true
		elseif string.find(line, "%%%%%% vtnb end %%%%%%") then
			inside_vtnb = false
		end

		-- Check for \begin and \end markers only within vtnb blocks
		if inside_vtnb then
			if string.find(line, "\\begin") then
				code_count = code_count + 1
				inside_begin_end = true
			elseif string.find(line, "\\end") then
				inside_begin_end = false
				table.insert(output_table, "print('VTNB END OF CODEBLOCK " .. code_count .. "')")
			elseif inside_begin_end then
				table.insert(output_table, line)
			end
		end
	end

	return output_table
end


local function output_locations(input_table)
	local block_indices = {}
	local start_index = nil
	local end_index = nil

	for i, line in ipairs(input_table) do
		if string.find(line, "%%%%%% vtnb start output %%%%%%") then
			start_index = i
		elseif string.find(line, "%%%%%% vtnb end output %%%%%%") then
			end_index = i
			if start_index and end_index then
				table.insert(block_indices, {start_index, end_index})
				start_index = nil -- Reset for the next block
				end_index = nil
			end
		end
	end

	return block_indices
end

function isFileEmptyOrWhitespace(filename)
    local file = io.open(filename, "r")
    if not file then
        return false, "Unable to open file"
    end

    local content = file:read("*a")  -- Read the entire file content
    file:close()

    -- Check if content is nil or empty, or if it contains only whitespace
    return (not content or content:match("^%s*$") ~= nil)
end

function tableLen(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end


function reverseTable(t)
    local i = 1
    local j = #t
    while i < j do
        t[i], t[j] = t[j], t[i]
        i = i + 1
        j = j - 1
    end
	return t
end


local function comment_out_show(python_code_table)
	local plt_alias = nil
	local figure_count = 0

	-- Find the alias for matplotlib.pyplot (if any)
	for _, line in ipairs(python_code_table) do
		local match = string.match(line, "^import%s+matplotlib.pyplot%s+as%s+(%w+)$")
		if match then
			plt_alias = match
			break
		end
	end

	-- Comment out lines with plt.show() or its alias
	for i, line in ipairs(python_code_table) do
		local show_call = plt_alias and string.format("%s.show()", plt_alias) or "matplotlib.pyplot.show()"
		if string.find(line, show_call) then
			figure_count = figure_count + 1
			filename = ".figure-" .. figure_count
			save_command = plt_alias .. ".savefig('" .. filename .. ".png'); print('VTNB FIGURE-" .. figure_count .. "') "
			python_code_table[i] = save_command .. "# " .. line -- Comment out the line
		end
	end

	return python_code_table
end

local function writeTableToFile(filename, table)
    -- Open the file in write mode
    local file = io.open(filename, "w")
    
    -- Check if file was opened successfully
    if not file then
        print("Error: Unable to open file " .. filename)
        return
    end
    
	file:write("")
    -- Iterate over the table and write each string to the file
    for _, str in ipairs(table) do
        file:write(str .. "\n")  -- Write string followed by a newline
    end
    
    -- Close the file
    file:close()
    
    -- print("Data successfully written to " .. filename)
end

function run_python_script(script_path)
    -- Create a temporary file for stderr
    local tmpfile = "/tmp/stderr_output.txt"

    -- Run Python, redirect stdout and stderr separately
    local handle = io.popen("python3 " .. script_path .. " 2>" .. tmpfile)
    local stdout_output = handle:read("*a")
    handle:close()

    -- Read the stderr output from the temporary file
    local stderr_file = io.open(tmpfile, "r")
    local stderr_output = stderr_file:read("*a")
    stderr_file:close()

    -- Remove the temporary file after use
    os.remove(tmpfile)

    -- Return result based on whether stderr has any content
    if stderr_output ~= "" then
        return {false, stderr_output} -- Error occurred, return false and the error message
    else
        -- Split the stdout output into a table
        local result_table = {}
        for line in stdout_output:gmatch("[^\r\n]+") do
            table.insert(result_table, line)
        end

        return result_table -- No error, return the standard output
    end
end


local function split_and_write_blocks(input_table, output_base_filename)
	local current_block = {}
	local file_counter = 1

	for _, line in ipairs(input_table) do
		if string.sub(line, 1, 21) == "VTNB END OF CODEBLOCK" then
			-- Write the current block to a file (if not empty)
			if true then -- formerly if #current_block > 0 then
				local filename = string.format("%s_%d.txt", output_base_filename, file_counter)
				local file = io.open(filename, "w")
				if file then
					file:write(table.concat(current_block, "\n"))
					file:close()
					file_counter = file_counter + 1
				else
					print("Error opening file:", filename) 
				end
			end
			current_block = {} -- Start a new block
		elseif not string.find(line, "ESCAPED") then 
			-- Add the line to the current block (unless it contains "ESCAPED")
			table.insert(current_block, line)
		end
	end

	-- Write the last block (if any)
	if #current_block > 0 then
		local filename = string.format("%s_%d.txt", output_base_filename, file_counter)
		local file = io.open(filename, "w")
		if file then
			file:write(table.concat(current_block, "\n"))
			file:close()
		else
			print("Error opening file:", filename)
		end
	end
end

local function intercept_figures_in_out(file_name)
	file_table = readFileIntoTable(file_name)
	intercepted_file_table = {}
	figure_table = {}
	for _, line in ipairs(file_table) do
		if line:sub(1,12)  == "VTNB FIGURE-" then
			table.insert(figure_table, line:sub(13) )
		else
			table.insert(intercepted_file_table, line)
		end -- end if
	end -- end for

	writeTableToFile(file_name, intercepted_file_table)
	return (figure_table)
end

local function add_outputs(input_table, bufnr) -- this messes with lines.
	local output_table = {}
	local inside_vtnb = false
	local inside_begin_end = false
	local code_count = 0
	line_num = 1

	for _, line in ipairs(input_table) do
		-- Check for vtnb start/end markers
		if string.find(line, "%%%%%% vtnb start %%%%%%") then
			inside_vtnb = true
			code_count = code_count + 1
		elseif string.find(line, "%%%%%% vtnb end %%%%%%") then
			if not inside_vtnb then
				error("the document is screwed up. end without a start")
			end
			
			inside_vtnb = false
			file_name = ".vtnb_out_" .. code_count .. ".txt"
			table_to_add = {"%%% vtnb end %%%", "%%% vtnb start output %%%"}


			

			figure_table = intercept_figures_in_out(file_name)

			if not isFileEmptyOrWhitespace(file_name) then
				table.insert(table_to_add, "	\\lstinputlisting[frame=tlbr, style=out]{" .. file_name .. "}")
			end

			for _, idx in ipairs(figure_table) do
				figure_code = "\\begin{figure}[H] \\begin{center} \\includegraphics[width=\\textwidth]{.figure-".. idx .. ".png} \\end{center} \\caption{}\\label{visina8} \\end{figure}"
				table.insert(table_to_add, figure_code)
			end

			table.insert(table_to_add,  "%%% vtnb end output %%%" )
			print(line_num)
			vim.api.nvim_buf_set_lines(bufnr, line_num - 1, line_num, false, table_to_add) 
			line_num = line_num + (tableLen(table_to_add) - 1) -- account for us moving the table

		end
		line_num = line_num + 1
	end

	return output_table
end

function M.compile()
	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- Get all lines of the buffer as a list of strings
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	code = extract_text_blocks(lines)
	code = comment_out_show(code)
	writeTableToFile(".buggs.py", code)
	out = run_python_script(".buggs.py")
	if not (type(out[1]) == "boolean") then -- errors return a table: {false, "error_message"}
		split_and_write_blocks(out, ".vtnb_out")


		-- this stuff messes with lines
		local indices_to_delete = output_locations(lines)
		if indices_to_delete then
			-- Sort the indices in descending order to avoid shifting issues
			indices_to_delete = reverseTable(indices_to_delete)

			local buf = vim.api.nvim_get_current_buf()

			for _, idx in ipairs(indices_to_delete) do
			  -- Lua indices start from 1, so adjust the index to Vim's 0-based indexing
			  vim.api.nvim_buf_set_lines(buf, idx[1] -1 , idx[2], false, {}) 
			end
		end
		lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) -- we reread our lines since we've messed with them

		print()
		add_outputs(lines, bufnr) -- this messes with lines
		vim.cmd("write")
		vim.cmd("VimtexCompileSS")
		vim.cmd("redraw")
	else
		print(out[2])
	end
end

return M
