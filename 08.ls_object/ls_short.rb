# frozen_string_literal: true

require_relative './ls'

class LsShort < Ls
  FIXED_COLMUNS = 3

  def run
    # 出力用の雛形(２次元配列)を作成
    row_number = (@files.size.to_f / FIXED_COLMUNS).ceil
    files_rows = @files.each_slice(row_number).to_a

    # 各行の文字数を取得
    digits = files_rows.map { |row| row.max_by(&:length).length }

    # 左揃え
    tmp = files_rows.map.with_index do |row, idx|
      row.map { |file| file.ljust(digits[idx]) }
    end

    # 転置&結合
    transpose(tmp).map do |row|
      row.join('  ').rstrip
    end.join("\n")
  end

  private

  def transpose(arrays)
    arrays[0].zip(*arrays[1..])
  end
end
