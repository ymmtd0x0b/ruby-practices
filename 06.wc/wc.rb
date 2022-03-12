# 仕様

# 引数と標準入力が同時に渡された場合は引数アリが優先される

#  - 引数：まずファイルを開けるか試みる
#         ➜ ファイルが無ければそのまま終了

#  - 標準入力：常に文字列(ファイルを開いた状態)として処理する

def main
  contents = ARGV.empty? ? STDIN.readlines : File.readlines(ARGV[0])
  wc(contents)
end

def wc(contents)
  lines = contents.count
  words = contents.join.split(nil).count
  size = contents.join.bytesize
  printf("%2s%3s %s %s\n", lines, words, size, ARGV[0])
end

main
