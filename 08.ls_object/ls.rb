# frozen_string_literal: true

class Ls
  def initialize(dot_match: false, reverse: false)
    params = dot_match ? ['*', File::FNM_DOTMATCH] : ['*']

    @files = Dir.glob(*params)

    @files = @files.reverse if reverse
  end

  def run
    # ダックタイプ用のインターフェース
    # このメソッドに各オプション毎のアルゴリズムを実装
  end
end
