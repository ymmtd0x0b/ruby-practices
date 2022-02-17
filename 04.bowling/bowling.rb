# frozen_string_literal: true

scores = ARGV[0]
scores = scores.split(',')
shots = []
scores.each do |s|
  if s == 'X' # ストライクを点数に変換
    shots << 10
    shots << nil # ストライクが出たフレーム内では２投目が無いのでnilとする
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a # １フレーム = ２投 の配列に変換

point =
  10.times.sum do |index| # １ゲーム = １０フレーム
    frame = frames[index]
    if frame[0] == 10 # ストライクの処理
      if frames[index + 1][0] == 10 # ２連続ストライクの場合
        10 + 10 + frames[index + 2][0]
      else
        10 + frames[index + 1].sum
      end
    elsif frame.sum == 10 # スペアの処理
      10 + frames[index + 1][0]
    else
      frame.sum
    end
  end
puts point
