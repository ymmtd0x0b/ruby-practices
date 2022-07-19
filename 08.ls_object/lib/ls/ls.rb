# frozen_string_literal: true

# テンプレート
class Ls
  def initialize(dot_match: false, reverse: false)
    @files = dot_match ? Dir.entries('.').sort : Dir.glob('*').sort

    @files = @files.reverse if reverse
  end

  def run
    # ダックタイプ用のインターフェース
    # このメソッドに各オプション毎のアルゴリズムを実装
  end
end
