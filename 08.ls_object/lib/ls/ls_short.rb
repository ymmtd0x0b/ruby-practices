# frozen_string_literal: true

require_relative './ls'

class LsShort < Ls
  FIXED_COLMUNS = 3

  def initialize(params)
    super(**params)
  end

  def run
    row_number = (@paths.size.to_f / FIXED_COLMUNS).ceil

    table =
      @paths.each_slice(row_number).map do |row_paths|
        col_width = row_paths.map(&:length).max
        row_paths.map { |path| File.basename(path).ljust(col_width) }
      end

    transpose(table).map do |row|
      row.join('  ').rstrip
    end.join("\n")
  end

  private

  def transpose(arrays)
    arrays[0].zip(*arrays[1..])
  end
end
