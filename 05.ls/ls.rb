# frozen_string_literal: true

COLUMNS = 3

def main
  files = Dir.each_child(Dir.pwd).filter { |file| file.match?(/^[^.]/) }.sort
  (COLUMNS - files.length % COLUMNS).times { files << '' } unless (files.length % COLUMNS).zero? # 後の処理で row * column の行列になるように空の要素を増やす
  puts format_for_print(files)
end

def format_for_print(files)
  files = files.each_slice(rows(files))
  file_names_to_the_same_length(files).transpose.map { |line| line.join('  ') }.join("\n")
end

def rows(files)
  files.length / COLUMNS
end

def file_names_to_the_same_length(files)
  digits = max_characters_in_rows(files)
  files.map.with_index do |row, index|
    row.map { |file_name| file_name.ljust(digits[index]) }
  end
end

def max_characters_in_rows(files)
  files.map { |row| row.max_by(&:length).length }
end

main
