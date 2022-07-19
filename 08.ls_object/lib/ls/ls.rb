# frozen_string_literal: true

# テンプレート
class Ls
  def initialize(dot_match: false, reverse: false)
    # path = Dir.pwd

    @files =
      if dot_match
        Dir.entries('.').sort
      else
        Dir.glob('*').sort
      end

    # @paths = files.map { |file| "#{path}/#{file}" }

    @files = @files.reverse if reverse
  end

  def run
    # ダックタイプ用のインターフェース
    # このメソッドに各オプション毎のアルゴリズムを実装
  end
end
