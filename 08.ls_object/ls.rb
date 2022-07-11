# frozen_string_literal: true

require 'optparse'
require_relative './files'

class Ls
  COLUMN_NUMBER = 3

  class << self
    def run(argv)
      opt_parse(argv)

      puts short_ls
    end

    # private

    def opt_parse(argv)
      opt = OptionParser.new

      opt.on('-l') { |v| @long_format = v }
      opt.on('-r') { |v| @reverse = v }
      opt.on('-a') { |v| @dot_match = v }
      opt.parse!(argv)
    end

    def short_ls
      # ファイルの取得
      params = { path: Dir.home, pattern: '*', flags: 0 }
      params[:flags] = File::FNM_DOTMATCH if @dot_match
      files = Files.new(**params)

      # ファイルのソート
      @reverse ? files.reverse : files.sort

      # 出力用の成形
      files.molding(COLUMN_NUMBER)
    end
  end
end
