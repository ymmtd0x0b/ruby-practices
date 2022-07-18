# frozen_string_literal: true

require_relative './ls'

class LsShort < Ls
  FIXED_COLMUNS = 3

  def initialize(params)
    super(**params)
  end

  def run
    files = @paths.map { |path| File.basename(path) }

    row_number = (files.size.to_f / FIXED_COLMUNS).ceil

    table =
      files.each_slice(row_number).map do |row_files|
        col_width = row_files.map(&:length).max
        row_files.map { |file| file.ljust(col_width) }
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
