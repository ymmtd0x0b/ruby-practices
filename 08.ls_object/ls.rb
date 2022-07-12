# frozen_string_literal: true

require 'optparse'

class Ls
  attr_reader :lines

  def initialize(argv)
    opt_parse(argv)
    @lines = run
  end

  def opt_parse(argv)
    opt = OptionParser.new

    opt.on('-l') { |v| @long_format = v }
    opt.on('-r') { |v| @reverse = v }
    opt.on('-a') { |v| @dot_match = v }
    opt.parse!(argv)
  end

  def run
    params = { path: Dir.home, pattern: '*', flags: 0 }

    # ファイルの取得
    params[:flags] = File::FNM_DOTMATCH if @dot_match
    Dir.chdir(params[:path])
    @files = Dir.glob(params[:pattern], params[:flags])

    # ファイルのソート
    @reverse ? @files.reverse : @files.sort

    # 出力用の成形
    molding
  end
end
