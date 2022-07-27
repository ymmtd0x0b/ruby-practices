# frozen_string_literal: true

require_relative '../file/file_stat'

class LsLong
  BLOCK_SIZE = { Byte: 512, KB: 1024 }.freeze # 1ブロック当たりの単位サイズ
  JUSTIFY_COLMUNS = %i[nlink user group size].freeze

  def initialize(files)
    @files = files
  end

  def run
    fstats = @files.map { |file| FileStat.new(file) }

    block_total = fstats.map(&:blocks).sum
    total = "合計 #{convert_unit(block_total, unit: :KB)}"

    max_chars = JUSTIFY_COLMUNS.map do |col|
      [col, fstats.map { |fstat| fstat.send(col).length }.max]
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
