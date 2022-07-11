# frozen_string_literal: true

class Files
  def initialize(path: '.', pattern: '*', flags: 0)
    Dir.chdir(path)
    @files = Dir.glob(pattern, flags)
  end

  def sort
    @files = @files.sort
  end

  def reverse
    @files = @files.reverse
  end

  def molding(column_number)
    # 出力用の雛形(２次元配列)を作成
    row_number = (@files.size.to_f / column_number).ceil
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
