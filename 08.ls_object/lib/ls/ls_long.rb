# frozen_string_literal: true

require_relative './ls'
require_relative '../file_stat'

class LsLong < Ls
  BLOCK_SIZE = { Bytes: 512, KB: 1024 }.freeze # 1ブロック当たりの単位サイズ
  ALIGN_ATTRIBUTE = %i[nlink user group size].freeze

  def initialize(params)
    super(**params)
  end

  def run
    files = @paths.map { |path| FileStat.new(path) }

    max_chars = ALIGN_ATTRIBUTE.map do |key|
      [key, files.map { |file| file.attr[key].length }.max]
    end.to_h

    total = files.map { |file| file.attr[:blocks] }.sum(&unit_conversion(:KB))
    body = files.map { |file| file.format_stat(max_chars) }

    ["合計 #{total}", *body].join("\n")
  end

  private

  # 作業者の環境ではKB表示なので変換処理を行う
  def unit_conversion(key)
    lambda do |total|
      base_bit_size    = BLOCK_SIZE[:Bytes].bit_length
      convert_bit_size = BLOCK_SIZE[key].bit_length

      total >> (convert_bit_size - base_bit_size)
    end
  end
end
