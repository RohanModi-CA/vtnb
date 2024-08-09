local killfrac_typed = false

vim.api.nvim_create_autocmd("CursorMovedI", {
  buffer = 0, -- Current buffer
  callback = function()
    local line_number = vim.api.nvim_win_get_cursor(0)[1]
    local col_number = vim.api.nvim_win_get_cursor(0)[2]
    local current_line = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
    local last_word = current_line:sub(1, col_number):match("%w+$")
    if string.sub(last_word, -8) == "KILLFRAC" and not killfrac_typed then
      killfrac_typed = true
      print("True")
	  require('killfrac').killFrac(current_line, line_number)
    else
      killfrac_typed = false
	  print("false")
    end
  end,
  desc = "Call killFrac efficiently if last word is KILLFRAC"
})
