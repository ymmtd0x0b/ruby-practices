# frozen_string_literal: true

require_relative './ls'
require_relative '../file_stat'

class LsLong < Ls
  BLOCK_SIZE = { Byte: 512, KB: 1024 }.freeze # 1ブロック当たりの単位サイズ
  JUSTIFY_ATTRIBUTES = %i[nlink user group size].freeze

  def initialize(params)
    super(**params)
  end

  def run
    fstats = @files.map { |file| FileStat.new(file) }

    block_total = fstats.map { |fstat| fstat.attr[:blocks] }.sum
    total = "合計 #{convert_unit(block_total, unit: :KB)}"

    max_chars = JUSTIFY_ATTRIBUTES.map do |key|
      [key, fstats.map { |fstat| fstat.attr[key].length }.max]
    end.to_h
    body = fstats.map { |fstat| fstat.format_stat(max_chars) }

    [total, *body].join("\n")
  end

  private

  # 1ブロック当たりのサイズはデフォルトで512Byteだが
  # 作成者の環境では合計値のみ1024Byte(KB)表示なので変換処理を行う
  def convert_unit(total, unit: :KB)
    base_bit_size       = BLOCK_SIZE[:Byte].bit_length
    conversion_bit_size = BLOCK_SIZE[unit].bit_length

    total >> (conversion_bit_size - base_bit_size)
  end
end
