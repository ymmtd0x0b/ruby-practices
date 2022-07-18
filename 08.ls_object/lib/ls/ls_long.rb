# frozen_string_literal: true

require_relative './ls'
require_relative '../file_stat'

class LsLong < Ls
  DEFAULT_BLOCK_SIZE = 512
  ALIGHN_TARGET = %i[nlink user group size].freeze

  def initialize(params)
    super(**params)
  end

  def run
    files = @paths.map { |path| FileStat.new(path) }

    max_chars = ALIGHN_TARGET.map do |key|
      [key, files.map { |file| file.stat[key].length }.max]
    end.to_h

    total = files.map { |file| file.stat[:blocks] }.sum
    body = files.map { |file| file.format_stat(max_chars) }

    ["合計 #{unit_conversion(total)}", *body].join("\n")
  end

  private

  def unit_conversion(total)
    # 作業者の環境では1KB表示なので単位変換を行う
    total >> (1024.bit_length - DEFAULT_BLOCK_SIZE.bit_length)
  end
end
