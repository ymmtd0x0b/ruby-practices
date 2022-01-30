###################
#ライブラリの読み込み
###################
require 'date'
require 'optparse'

###################
#クラスの定義
###################
#カレンダーの雛形
class CalOneYear #１年分のカレンダー
  def initialize(date)
    @date = date
    @year = date.year
    @month = date.month
    @calendar = Array.new(4){ Array.new(3) }
  end

  def create_cal
    month = 1
    #１２ヶ月分のカレンダーを作成
    4.times do |i|
      3.times do |j|
        @date.month = month
        @calendar[i][j] = CalOneMonth.new(@date)
        @calendar[i][j].create_cal
        month += 1
      end
    end
  end

  #出力処理
  def print_cal #３ヶ月分の出力
    ###それぞれ独立した各月のカレンダーを行単位で結合して出力する
    #タイトルの出力
    year_title = "                            #{@year}"
    print year_title + "\n"
    4.times do |r|
      title_line = ""
      3.times do |i|
        title_line += ("        " + @calendar[r][i].month.to_s + "月" + "           ").chars.slice(0..20).join
      end
      print title_line + "\n"

      #曜日の出力
      wday_line = ""
      3.times do |i|
        wday_line += @calendar[r][i].wday.join
      end
      print wday_line + "\n"
    
      #カレンダー：日数部分
      6.times do |row| #カレンダーの日数部分は６行
        date_line = ""
        3.times do |i|
          date_line += @calendar[r][i].calendar[row].join + "  "
        end
        print date_line + "\n"
      end
      # print "\n" #１行空白
    end
  end
end

class CalThreeMonths #３ヶ月分のカレンダー
  def initialize(date)
    @date = date
    @year = date.year
    @month = date.month
    @calendar = Array.new(3)
  end

  def create_cal
    ###前月を基点の日付(変数date)として、３ヶ月分のカレンダーを作成
    #基点の日付(前月)を計算
    date = @date.today.prev_month
    @date.year = date.year
    @date.month = date.month

    #３ヶ月分のカレンダーを作成
    3.times do |i|
      #変数dateに設定された日付のカレンダーを作成
      @calendar[i] = CalOneMonth.new(@date)
      @calendar[i].create_cal

      #基点の日付を更新(次月を計算)
      date = date.next_month
      @date.year = date.year
      @date.month = date.month
    end
  end

  #出力処理
  def print_cal #３ヶ月分の出力
    ###それぞれ独立した各月のカレンダーを行単位で結合して出力する
    #タイトルの出力
    title_line =  @calendar[0].title +
                  @calendar[1].title +
                  @calendar[2].title
    print title_line + "\n"

    #曜日の出力
    wday_line = ""
    3.times do |i|
      wday_line += @calendar[i].wday.join
    end
    print wday_line + "\n"
  
    #カレンダー：日数部分
    6.times do |row| #カレンダーの日数部分は６行
      date_line = ""
      3.times do |i|
        date_line += @calendar[i].calendar[row].join + "  "
      end
      print date_line + "\n"
    end
  end
end

class CalOneMonth #１ヶ月分のカレンダー
  attr_reader :title, :wday, :month, :calendar
  def initialize(date)
    #インスタンス変数
    @date = date
    @year = date.year
    @month = date.month

    #カレンダー：タイトル
    @title = ("      #{@month.to_s}月 #{@year}        ").chars.slice(0..20).join
    
    #カレンダー：曜日
    @wday = ["日 ", "月 ", "火 ", "水 ", "木 ", "金 ", "土  "]

    #日数の雛形(この雛形に当月の日数を埋めていく)
    @calendar = [["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],
                ["  ", "   ", "   ", "   ", "   ", "   ", "   "],]
  end

  #出力処理
  def print_cal #１ヶ月分の出力
    #タイトルの出力
    print @title + "\n"

    #曜日の出力
    print @wday.join + "\n"
  
    #カレンダー：日数部分
    rows = @calendar.size
    rows.times do |row|
      print @calendar[row].join + "  \n"
    end
  end
  
  #雛形に日数を埋め込む処理
  def create_cal
    #当月の日数を取得
    days = Date.new(@year, @month, -1).day
    
    ###日付を適切なカレンダー位置に埋め込む
    week = 0
    1.step(days,1) do |day|
      date = Date.new(@year,@month,day)
      col = date.wday
      if date.sunday?
        n = -2
      else
        n = -3
      end
      #当月の日数を変数calenderの適切な座標に埋め込む
      #当日をハイライト
      if date == @date.today && @date.h == true
        day = (" " + day.to_s).slice(-2..-1) #１桁の数字は直前の空白も含んでハイライトを付ける / 擬似的に２桁にする
        day = "\e[47;30m" + day + "\e[0m" #背景色：白, 文字色：黒のカラーコードで日にちを挟む
        n -= 12 #ANSIカラーコードの分だけスライスする数を増やす
      end
      @calendar[week][col] = (@calendar[week][col] + day.to_s).chars.slice(n..-1).join #日にちを適切な座標に埋め込み
      week += 1 if col == 6 #金曜日(行末)まで到達したら週(行)を更新...()内は配列表現
    end
  end
end

#オプションを扱うクラス
class Options
  def initialize
    @options = {}
    OptionParser.new do |opt|      
      #cal -y [year] / cal --year [year] の登録
      opt.on('-y [value]', '--year [value]') do |v|
        if v.nil? #オプションのみで引数が与えられなかった場合
          @options[:y] = nil
        elsif (v =~ /\A[0-9]+\z/) == 0 #引数が数字でのみで構成させているかチェック
          @options[:y] = v.to_i #数値に変換
        else #エラー処理
          print "cal: not a valid year #{v}\n"
          exit
        end
      end 

      #cal -m [month] / cal --month [month] の登録
      opt.on('-m [value]', '--month [value]') do |value|
        if value.nil?
          print "cal: option requires an argument -- 'm'\n"
          exit
        end
        v = value.to_i #数値に変換
        if 1 <= v && v <= 12
          @options[:m] = v
        else
          print "cal: #{value} is neither a month number (1..12) nor a name\n"
          exit
        end
      end
      opt.on('-h') { |v| @options[:h] = true  } #cal -h の登録
      opt.on('-1') { |v| @options[:one] = true  } #cal -1 の登録
      opt.on('-3') { |v| @options[:three] = true  } #cal -3 の登録
      begin
       opt.parse!(ARGV)
      rescue => e #設定外のオプションが指定された場合のエラー処理
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/,'')}'\n"
        exit
      end

      #cal -y year -m month において、片方の引数が与えられていない場合はエラーとして終了
      if self.has?(:y) && self.has?(:m)
        case
        when self.get(:y).nil? == true
          print "cal: option requires an argument -- 'y'\n"
          exit
        when self.get(:m).nil? == true
          print "cal: option requires an argument -- 'm'\n"
          exit
        end
      end
    end
  end

  #nameに渡されたオプションが存在するか確認
  def has?(name)
    @options.include?(name)
  end

  #nameに渡されたオプションの値を取得
  def get(name)
    @options[name]
  end
end

#引数の扱うクラス
class Arguments
  def initialize
    @args = {}
    if ARGV.size >= 3 #引数３つ以上で処理の終了(引数異常)
      exit
    elsif ARGV.size == 2 #引数２つで月・年に代入
      @args[:m] = check_month(ARGV[0])
      @args[:y] = ARGV[1].to_i
    elsif ARGV.size == 1 #引数１つで年に代入
      @args[:y] = ARGV[0].to_i
    end
  end

  #月に代入される値のチェック
  def check_month(v)
    m = v.to_i
    if 1 <= m && m <= 12
      m
    else
      #エラー処理
      print "cal: #{v} is neither a month number (1..12) nor a name\n"
      exit
    end
  end

  #引数が２つある場合にtrueを返す
  def has?(name)
    @args.include?(name)
  end

  #月・年の値を取得
  def get(name)
    @args[name]
  end
end

#日付に関するデータを保持するクラス
class GetDate
  attr_reader :today, :year, :month, :h
  attr_writer :year, :month, :h
  def initialize
    @today = Date.today
    @year = @today.year
    @month = @today.month
    @h = true #ハイライトの有無 デフォルトでハイライト有効
  end
end

###事前準備
###コマンド実行時の日付の各パラメータを取得
date = GetDate.new

###############
#メイン処理
###############
options = Options.new
args = Arguments.new

case #オプションによるコマンド処理の分岐
#cal -y [year] -m [month]
when options.has?(:y) == true && options.has?(:m) == true
  date.year = options.get(:y)
  date.month = options.get(:m)
  cal = CalOneMonth.new(date)

#cal -y / cal -y [year]
when options.has?(:y) == true
  date.year = options.get(:y).to_i unless options.get(:y).nil? #引数有りならyearに代入
  cal = CalOneYear.new(date)

#cal -m / cal -m [month]
when options.has?(:m) == true 
  date.month = options.get(:m).to_i
  cal = CalOneMonth.new(date)

#cal -h
when options.has?(:h) == true
  date.h = false
  cal = CalOneMonth.new(date)

#cal -1
when options.has?(:one) == true
  cal = CalOneYear.new(date)

#cal -3 
when options.has?(:three) == true
  cal = CalThreeMonths.new(date)

#cal [month] [year]
when args.has?(:m) == true #引数に月の値が存在すれば年・月が指定された事を意味する
  date.year = args.get(:y) #引数から年を取得
  date.month = args.get(:m) #引数から月を取得
  cal = CalOneMonth.new(date)

#cal [year]
when args.has?(:y) == true
  date.year = args.get(:y) #引数から年を取得
  cal = CalOneYear.new(date)

#cal
else
  cal = CalOneMonth.new(date)
end

cal.create_cal #カレンダーの作成
cal.print_cal #出力
