local json = require("dkjson")


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



-- Function to extract cell data and format as tuples
local function extract_cell_data(notebook_json)
  local cell_tuples = {}
  for _, cell in ipairs(notebook_json.cells) do
    local cell_type = cell.cell_type
    local content = table.concat(cell.source, "\n") -- Join source lines with newlines

    if cell_type == "markdown" then
      cell_type = "text"  -- Replace "markdown" with "text"
    end

    table.insert(cell_tuples, {cell_type, content})
  end
  return cell_tuples
end

-- Assuming 'notebook_json' holds the decoded JSON data
-- (replace with your actual JSON loading logic)

-- Example usage:
local notebook_file = io.open("nb.ipynb", "r") 
local notebook_json = json.decode(notebook_file:read("*all"))
notebook_file:close()

local cell_data = extract_cell_data(notebook_json)


file_table = {"\\documentclass[12pt]{article}\\input{/home/thinkpad/Documents/FileFolder/setup/preamble.tex}\n\\begin{document}\n%%%%%%%%%%%%%%%%%%%%%%%% START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%"}
for _, tuple in ipairs(cell_data) do
	block_to_add = tuple[2]
	if tuple[1] == "code" then
		block_to_add = "\n%%% vtnb start %%%\n\\begin{lstlisting}[frame=shadowbox]\n" .. tuple[2] .. "\n\\end{lstlisting}\n%%% vtnb end %%%\n"
	elseif tuple[1] == "text" then
		block_to_add = "\n".. tuple[2] .."\n"
	else
		error("bad file")
	end
	table.insert(file_table, block_to_add)
end

table.insert(file_table,"%%%%%%%%%%%%%%%%%%%%%%%%  END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\\end{document}")
writeTableToFile("buggs.tex", file_table)



--[[
-- Print the formatted table of tuples
for _, tuple in ipairs(cell_data) do
  print("(" .. tuple[1] .. ", " .. tuple[2] .. ")")
end 
]]
