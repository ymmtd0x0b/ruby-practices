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

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
10.times do |index|
  frame = frames[index]
  point +=
    if frame[0] == 10 # ストライクの処理
      if frames[index + 1][0] == 10 # ２投目もストライクの場合
        10 + 10 + frames[index + 2][0] # ３投 = 計３フレームを跨いで計算
      else
        10 + frames[index + 1].sum # ３投 = 計２フレームを跨いで計算
      end
    elsif frame.sum == 10 # スペアの処理
      10 + frames[index + 1][0]
    else
      frame.sum
    end
end
puts point
