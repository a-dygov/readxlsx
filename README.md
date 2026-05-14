# SimpleXLSX
Ruby module parse and retrieve data from MS Excel 2007 files.

## Basic Usage

```Ruby
#examples/01-basic_usage.rb
require_relative "../lib/readxlsx"

book = Readxlsx::Book.new "examples/01-basic.xlsx"

book.sheets.each_with_index do |sheet, index|
	rows = sheet.rows()
	puts "sheet Index #{index}, row count #{rows.length} :"
	pp rows
end


```


```Bash
$ ruby examples/01-basic_usage.rb
```


```Json
sheet Index 0, row count 29 :
[
	["Col-1", "Col-2", "Col-3 (date/time)"],
	["Cell-1-1", "Cell-1-2", "31.12.2000"],
	["", "", ""],
	["Cell-2-1", "Cell-2-2", "31.12.2000"],
	["", "", ""],
	["Cell-3-1", "Cell-3-2", "31.12.2000 12:35:00"],
	["Cell-4-1", "Cell-4-2", "11:45:00"],
	["", "", ""],
	["Cell-5-1", "Cell-5-2", "12-31-2000"],
	["Cell-6-1", "Cell-6-2", ""],
	["Cell-7-1", "Cell-7-2", "   12/31/2000   09:55"],
	[],
	[],
	...
]
```



## Parameters
SimpleXLSX can remove empty rows and columns from the output. 
For this use the **remove_empty_col** and **remove_empty_row** parameters in the **rows** method 
to remove empty columns and rows, respectively.

```Ruby
require_relative "../lib/readxlsx"

book = Readxlsx::Book.new "examples/01-basic.xlsx"

book.sheets.each_with_index do |sheet, index|
	rows = sheet.rows(:remove_empty_col => true, :remove_empty_row => true)
	puts "sheet Index #{index}, row count #{rows.length} :"
	pp rows
end
```

```Json
sheet Index 0, row count 8 :
[
      ["Col-1", "Col-2", "Col-3 (date/time)"],
      ["Cell-1-1", "Cell-1-2", "31.12.2000"],
      ["Cell-2-1", "Cell-2-2", "31.12.2000"],
      ["Cell-3-1", "Cell-3-2", "31.12.2000 12:35:00"],
      ["Cell-4-1", "Cell-4-2", "11:45:00"],
      ["Cell-5-1", "Cell-5-2", "12-31-2000"],
      ["Cell-6-1", "Cell-6-2", ""],
      ["Cell-7-1", "Cell-7-2", "   12/31/2000   09:55"]
]
```

