# frozen_string_literal: true

COLUMNS = 3

def main
  files = Dir.each_child(Dir.pwd).filter { |file| file.match?(/^[^.]/) }.sort
  (COLUMNS - files.length % COLUMNS).times { files << '' } unless (files.length % COLUMNS).zero? # 後の処理で転置(transposeメソッド)出来るように空の要素を増やす
  puts format_for_print(files)
end

def format_for_print(files)
  files_arrays = files.each_slice(rows(files)) # ROWS * COLUMNS の疑似行列(2次元配列)を作成
  file_names_to_the_same_length(files_arrays).transpose.map { |row| row.join('  ') }.join("\n")
end

def rows(files)
  files.length / COLUMNS
end

def file_names_to_the_same_length(files_arrays)
  digits = max_characters_in_columns(files_arrays) # 各列の最長ファイル名を固定幅として取得
  files_arrays.map.with_index do |row, index|
    row.map { |file_name| file_name.ljust(digits[index]) }
  end
end

# 配列の<行>は転置後に<列>となるためメソッド名をcolumnsとしている
def max_characters_in_columns(files_arrays)
  files_arrays.map { |column| column.max_by(&:length).length }
end

main
