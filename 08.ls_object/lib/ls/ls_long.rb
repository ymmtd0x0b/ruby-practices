# frozen_string_literal: true

require_relative './ls'
require_relative '../file/file_stat'

class LsLong < Ls
  BLOCK_SIZE = 1024
  ALIGHN_TARGET = %i[nlink user group size].freeze

  def initialize(params)
    super(**params)
  end

  def run
    files = @paths.map { |path| FileStat.new(path) }

    max_chars = ALIGHN_TARGET.map do |key|
      [key, files.map { |file| file.stat[key].length }.max]
    end.to_h

    total = files.map { |file| file.stat[:size].to_i }.sum / BLOCK_SIZE
    body = files.map { |file| file.format_stat(max_chars) }

    ["合計 #{total}", *body].join("\n")
  end
end
