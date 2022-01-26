### 定数 ###
#「1 ~ Max」の範囲でFizzBuzzプログラムを処理させたい最大数
Max = 20

### FizzBuzzプログラム ###
1.step(Max,1) do |n|
  if n % 15 == 0
    puts "FizzBuzz"
  elsif n % 5 == 0
    puts "Buzz"
  elsif n % 3 == 0
    puts "Fizz"
  else
    puts n
  end
end