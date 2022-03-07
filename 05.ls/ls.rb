# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMNS = 3
PERMISSIONS = { r: 4, w: 2, x: 1 }.freeze
BLOCK_SIZE = 1024

def main
  files = self.files
  puts files
end

def files
  options = ARGV.getopts('arl')
  hidden_files_flag = options['a'] ? File::FNM_DOTMATCH : 0
  files = Dir.glob('*', hidden_files_flag)
  files = options['r'] ? files.reverse : files
  options['l'] ? details(files) : summaries(files)
end

def details(files)
  digits = self.digits(files) # ユーザー名, グループ名, ファイルサイズで桁合わせを行う前準備
  sum_files_size = 0
  files_status =
    files.map do |file_name|
      file = File.lstat(file_name)
      sum_files_size += file.size
      [
        type(file) + permission(file),
        file.nlink,
        Etc.getpwuid(file.uid).name.rjust(digits[0]),
        Etc.getgrgid(file.gid).name.rjust(digits[1]),
        file.size.to_s.rjust(digits[2]),
        file.mtime.strftime('%_m月 %_d %H:%M'),
        format_file_name(file.ftype, file_name)
      ].join(' ')
    end
  sum_block_size = "合計 #{sum_files_size / BLOCK_SIZE}\n"
  sum_block_size + files_status.join("\n")
end

def digits(files)
  users = []
  groups = []
  files_size = []
  files.each do |file_name|
    file = File.lstat(file_name)
    users << Etc.getpwuid(file.uid).name
    groups << Etc.getgrgid(file.gid).name
    files_size << file.size.to_s
  end
  max_characters([users, groups, files_size])
end

def type(file)
  if %w[directory link].include?(file.ftype)
    file.ftype[0]
  else
    '-'
  end
end

def permission(file)
  authories = file.mode.to_s(8).chars.map(&:to_i)[-3..]
  authories.map do |authory|
    PERMISSIONS.map do |permission|
      if authory >= permission[1]
        authory -= permission[1]
        permission[0].to_s
      else
        '-'
      end
    end
  end.join
end

def format_file_name(type, name)
  if type == 'link'
    "#{name} -> #{File.readlink("./#{name}")}"
  else
    name
  end
end

def summaries(files)
  files = add_elements(files) # 後の処理で転置(transposeメソッド)出来るように空の要素を増やす
  transpose(files)
end

def add_elements(files)
  mod = files.count % COLUMNS
  (COLUMNS - mod).times { files << '' } unless mod.zero?
  files
end

def transpose(files)
  files_arrays = files.each_slice(rows(files)) # ROWS * COLUMNS の疑似行列(2次元配列)を作成
  file_name_align(files_arrays).transpose.map { |row| row.join('  ') }.join("\n")
end

def rows(files)
  files.count / COLUMNS
end

def file_name_align(files_arrays)
  digits = max_characters(files_arrays) # 各列の最長ファイル名を固定幅として取得
  files_arrays.map.with_index do |row, index|
    row.map { |file_name| file_name.ljust(digits[index]) }
  end
end

# 配列の<行>は転置後に<列>となるためメソッド名をcolumnsとしている
def max_characters(files_arrays)
  files_arrays.map { |column| column.max_by(&:length).length }
end

main
