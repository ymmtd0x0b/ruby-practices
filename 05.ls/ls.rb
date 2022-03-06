# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMNS = 3

def main
  files = self.files
  files = to_matrix(files) # 後の処理で転置(transposeメソッド)出来るように空の要素を増やして行列の形にする
  puts format_for_print(files)
end

def files
  opt = OptionParser.new
  params = {}
  opt.on('-a') { |value| value }
  opt.on('-r') { |value| value }
  opt.on('-l') { |value| value }
  opt.parse!(ARGV, into: params)
  flag = params.key?(:a) ? File::FNM_DOTMATCH : 0
  files = Dir.glob('*', flag)
  params.key?(:r) ? files.reverse : files
  params.key?(:l) ? l_option(files) : files
end

def l_option(files)
  # p file_type(file.ftype) + permission(664).join
  files.each do |f|
    file = File::Stat.new(f)
    print "#{file_type(file.ftype) + permission(file.mode)} #{file.nlink} #{Etc.getpwuid(file.uid).name} #{Etc.getgrgid(file.gid).name} #{file.size} #{file.mtime.strftime("%_m月 %d %H:%M")} #{f}\n"
  end
  # print files.join("\n")
  exit
end

def file_type(type)
  if ['directory', 'link'].include?(type)
    type[0]
  else '-'
  end
end

def permission(file_mode)
  mode = file_mode.to_s(8)[-3..].to_i
  mode.digits.reverse.map do |digit|
    str = ''
    [4, 2, 1].each do |permission|
      if digit >= 4
        str += 'r'
      elsif digit >= 2
        str += 'w'
      elsif digit >= 1
        str += 'x'
      else
        str += '-'
      end
      digit -= permission
    end
    str
  end.join
end

def to_matrix(files)
  mod = files.count % COLUMNS
  (COLUMNS - mod).times { files << '' } unless mod.zero?
  files
end

def format_for_print(files)
  files_arrays = files.each_slice(rows(files)) # ROWS * COLUMNS の疑似行列(2次元配列)を作成
  file_names_to_the_same_length(files_arrays).transpose.map { |row| row.join('  ') }.join("\n")
end

def rows(files)
  files.count / COLUMNS
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
