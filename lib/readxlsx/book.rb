# frozen_string_literal: true

require 'zip/filesystem'
require 'nokogiri'
require_relative "utils"

module Readxlsx
  class Readxlsx::Book
    include Readxlsx::Utils

    attr_reader :zipfile,
      :arr_sharedstring,
      :sheets,
      :arr_sheet_id,
      :arr_xf_id,
      :format_code

    SHAREDSTRINGS_PATH = 'xl/sharedStrings.xml'
    WORKBOOK_PATH = 'xl/workbook.xml'
    STYLES_PATH = 'xl/styles.xml'

    # -----------------------------------------
    # initialize
    def initialize(path, options = {})
      @arr_sharedstring = []
      @sheets = []
      @arr_sheet_id = []
      @arr_xf_id = []
      @format_code = {}

      unless File.exist?(path)
        log_error "File not exist: " + path
        return
      end

      @zipfile = Zip::File.open(path)

      [SHAREDSTRINGS_PATH, WORKBOOK_PATH, STYLES_PATH].each do |file|
        unless @zipfile.file.exist?(file)
          log_error "File not found inside the ZIP: " + file
          return
        end
      end

      sharedStrings = @zipfile.file.read(SHAREDSTRINGS_PATH)
      xmlShared = Nokogiri::XML::Document.parse sharedStrings
      node_selector = "si"
      text_selector = ">t"
      xmlShared.css(node_selector).each do |si|
        @arr_sharedstring << si.css(text_selector).first.text
      end

      workbook = @zipfile.file.read(WORKBOOK_PATH)
      xmlWorkbook = Nokogiri::XML::Document.parse workbook
      node_selector = "sheet"
      xmlWorkbook.css(node_selector).each do |sheet|
        @arr_sheet_id << sheet.attr('sheetId')
      end

      styles = @zipfile.file.read(STYLES_PATH)
      xmlStyles = Nokogiri::XML::Document.parse styles
      node_selector = "cellXfs"
      xf_selector = "xf"
      cellXfs = xmlStyles.css(node_selector)
      cellXfs.css(xf_selector).each do |xf|
        @arr_xf_id << xf.attr('numFmtId').to_i
      end

      node_selector = "numFmts"
      numFmts = xmlStyles.css(node_selector)
      numFmts.css("numFmt").each do |numfmt|
        numFmtId = numfmt.attr('numFmtId')
        formatCode = numfmt.attr('formatCode')
        code = formatCode.gsub('-','_').gsub('/','_').gsub('.','_')
        isdate = code.include?("m_d") || code.include?("d_m")
        istime = code.include?("h:m")
        datemode = nil
        if isdate || istime 
          if isdate && istime 
            datemode = :datetime
          elsif isdate
            datemode = :date
          else 
            datemode = :time
          end
        end
        @format_code[numFmtId] = [formatCode, datemode]
      end

      @arr_sheet_id.each do |sheet_id|
        @sheets << Sheet.new(self, sheet_id)
      end
    end

    # -----------------------------------------
    # sheet
    def sheet(id)
      if id < 0 
        log_error "index is incorrect: " + id.to_s
        return 
      end
      unless id < @sheets.length
        log_error "sheet #{id} not found"
        return
      end
      @sheets[id]
    end

  end
end

