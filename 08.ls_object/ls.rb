# frozen_string_literal: true

require 'optparse'

class Ls
  class << self
    def run(argv)
      opt_parse(argv)

      puts short_ls
    end

    private

    def opt_parse(argv)
      opt = OptionParser.new

      opt.on('-l') { |v| @long_format = v }
      opt.on('-r') { |v| @reverse = v }
      opt.on('-a') { |v| @dot_match = v }
      opt.parse!(argv)
    end

    def short_ls
      # ファイルの取得
      pattern = '*'
      params =  @dot_match ? [pattern, File::FNM_DOTMATCH] : [pattern]
      Dir.chdir('/home/ymmtd0x0b/')
      files = Dir.glob(*params)

      # ファイルのソート
      sort_files = @reverse ? files.reverse : files.sort

      # 転置用の２次元配列を作成
      add_count = 3 - sort_files.count % 3
      expantion_files = sort_files.concat(Array.new(add_count, ''))

      # 各行の文字揃えを行う
      rows_count = expantion_files.size / 3
      max_files_name_in_rows = expantion_files.each_slice(rows_count).map { |row| row.max_by(&:length).size }

      # 転置
      tmp = expantion_files.each_slice(rows_count).to_a.transpose
      tmp.map do |row|
        row.map.with_index { |file, idx| file.ljust(max_files_name_in_rows[idx]) }.join('  ')
      end.join("\n")
    end
  end
end
