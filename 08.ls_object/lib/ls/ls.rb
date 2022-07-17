# frozen_string_literal: true

# テンプレート
class Ls
  def initialize(dot_match: false, reverse: false)
    params = dot_match ? ['*', File::FNM_DOTMATCH] : ['*']

    @paths = Dir.glob(*params, base: Dir.pwd)

    @paths = @paths.reverse if reverse
  end

  def run
    # ダックタイプ用のインターフェース
    # このメソッドに各オプション毎のアルゴリズムを実装
  end
end
