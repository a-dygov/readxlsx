# frozen_string_literal: true

require 'date'

module Readxlsx
  module Utils

    EXCEL_BASE_DATE = DateTime.new(1899, 12, 30)

    # -----------------------------------------
    # log_error
    def log_error(msg)
      puts msg
    end

    # -----------------------------------------
    # formate_date
    def formate_date(datemode, v)
      date = EXCEL_BASE_DATE + v.to_f
      if datemode == :datetime
        dt_format = "%d.%m.%Y %H:%M:%S"
      elsif datemode == :date
        dt_format = "%d.%m.%Y"
      else
        dt_format = "%H:%M:%S"
      end
      date.strftime(dt_format)
    end

    # -----------------------------------------
    # excel_col_to_index
    def excel_col_to_index(name)
      name.delete("0-9").upcase.chars.inject(0) { |sum, char| sum * 26 + (char.ord - 'A'.ord + 1) } - 1
    end

  end 
end


