
require_relative "../lib/readxlsx"

book = Readxlsx::Book.new "examples/01-basic.xlsx"

book.sheets.each_with_index do |sheet, index|
	rows = sheet.rows(:remove_empty_col => true, :remove_empty_row => true)
	puts "sheet Index #{index}, row count #{rows.length} :"
	pp rows
end

