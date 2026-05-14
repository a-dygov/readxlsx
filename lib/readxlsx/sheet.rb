# frozen_string_literal: true

require_relative "utils"

module Readxlsx
  class Readxlsx::Sheet
    include Readxlsx::Utils

    attr_reader :book,
      :sheet_id,
      :data

    # -----------------------------------------
    # initialize
    def initialize(book, sheet_id)
      @book = book
      @sheet_id = sheet_id
      @cols_empty = []
      @rows_empty = []
      parse
    end

    # -----------------------------------------
    # parse
    def parse
      path = "xl/worksheets/sheet#{@sheet_id}.xml"

      wsheet = @book.zipfile.file.read(path)
      xml = Nokogiri::XML::Document.parse wsheet
      row_selector = "row"
      cell_selector = "c"
      text_selector = ">v"
      @data = []
      @cols_empty = []
      xml.css(row_selector).each do |row|
        cells = []
        v_count = 0
        row.css(cell_selector).each_with_index do |cell, i|
          ind = i
          @cols_empty.insert(ind, 0) if @cols_empty[ind].nil?

          attr_r = cell.attr('r')
          col_ind = excel_col_to_index(attr_r)
          if cells.length < col_ind 
            (cells.length..col_ind-1).each do |x| 
              ind += 1
              @cols_empty.insert(ind, 0) if @cols_empty[ind].nil?
              cells << ''
            end
          end

          attr_t = cell.attr('t')
          attr_s = cell.attr('s')

          nodes = cell.css(text_selector)
          unless nodes.length > 0
            cells << ''
            next
          end

          v = nodes.first.text
          if attr_t == 's'
            v = @book.arr_sharedstring[v.to_i]
          end
    
          numFmtId = @book.arr_xf_id[attr_s.to_i]
          numFmtId_s = @book.format_code[numFmtId.to_s]
          if numFmtId_s 
            datemode = numFmtId_s[1]
            if datemode 
              v = formate_date(datemode, v) 
            end 
          end

          unless v.strip == '' 
            @cols_empty[ind] += 1
            v_count += 1 
          end
          cells << v
        end

        @rows_empty << v_count
        @data << cells
      end
    end

    # -----------------------------------------
    # rows
    def rows(options = {})
      remove_empty_col = options.fetch(:remove_empty_col, false)
      remove_empty_row = options.fetch(:remove_empty_row, false)
      data2 = @data

      # -- remove_empty_col --
      if remove_empty_col 
        data2 = data2.map { |row| 
          row2 = row.select.with_index { |cell, ind|
            @cols_empty[ind] > 0
          }
        }
      end

      # -- remove_empty_row --
      if remove_empty_row
        data2 = data2.select.with_index { |row, ind| 
          @rows_empty[ind] > 0
        }
      end

      data2
    end

  end
end

