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
    fstats = @files.map { |file| FileStat.new(file) }

    max_chars = ALIGN_ATTRIBUTE.map do |key|
      [key, fstats.map { |fstat| fstat.attr[key].length }.max]
    end.to_h

    total = fstats.map { |fstat| fstat.attr[:blocks] }.sum(&convert_unit(:KB))
    body = fstats.map { |fstat| fstat.format_stat(max_chars) }

    ["合計 #{total}", *body].join("\n")
  end

  private

  # 1ブロック当たりのサイズは512Byteだが
  # 作成者の環境では1024Byte(KB)表示なので変換処理を行う
  def convert_unit(key)
    lambda do |total|
      base_bit_size    = BLOCK_SIZE[:Bytes].bit_length
      convert_bit_size = BLOCK_SIZE[key].bit_length

      total >> (convert_bit_size - base_bit_size)
    end
  end
end
