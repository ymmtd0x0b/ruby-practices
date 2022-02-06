require 'date'
require 'optparse'

class OneYearCalendar
  YEAR_LINE_WIDTH = 63
  def initialize(date)
    @date = date
    @calendar = create_calendar
  end

  def get_year_line
    @date.year.to_s.center(YEAR_LINE_WIDTH) + "\n"
  end

  def get_months_line(three_months)
    months = three_months.calendar.map do |one_month|
      "#{one_month.date.month}月".center(CalOneMonth::LINE_WIDTH)
    end
    months.join(' ') + "\n"
  end

  def print_calendar
    print get_year_line
    @calendar.map do |three_months|
      print get_months_line(three_months)
      print three_months.get_wdays_line
      print three_months.get_dates_line
    end
  end

  private

  def create_calendar
    current_month = Date.new(@date.year, 1, 1)
    4.times.map do |n|
      ThreeMonthsCalendar.new(current_month.next_month(n * 3))
    end
  end
end

class ThreeMonthsCalendar
  attr_reader :calendar
  def initialize(date)
    @date = date
    @calendar = create_calendar
  end

  def get_months_line
    @calendar.map(&:month_line).join(' ') + "\n"
  end

  def get_wdays_line
    Array.new(3,CalOneMonth::WDAY).join(' ') + "\n"
  end

  def get_dates_line
    dates = 
      (0..5).map do |week|
        one_week_line = @calendar.map { |current_month| current_month.calendar[week] }
        one_week_line.join('  ') + "\n"
      end
    dates.join('')
  end
  
  def print_calendar
    print get_months_line
    print get_wdays_line
    print get_dates_line
  end

  private

  def create_calendar
    (0..2).map do |n|
      CalOneMonth.new(@date.next_month(n))
    end
  end
end

class CalOneMonth
  attr_reader :month_line, :wday, :calendar, :date
  DATE_CELL_WIDTH = 3
  LINE_WIDTH = 20
  WDAY = "日 月 火 水 木 金 土 "
  def initialize(date)
    @date = date
    @month_line = ("#{@date.month}月 #{@date.year}").center(LINE_WIDTH)
    @calendar = create_calendar
  end

  def print_calendar
    puts @month_line
    puts WDAY
    print @calendar.join("\n")
  end
  
  private

  def create_calendar
    day = Date.new(@date.year, @date.month, 1)
    Array.new(6, '').map do |one_week|
      (0..6).each do |wday|
        if wday == day.wday && @date.month == day.month
          one_week += day.day.to_s.rjust(DATE_CELL_WIDTH,' ')
          day = day.next_day
        else
          one_week += (' ' * DATE_CELL_WIDTH)
        end
      end
      one_week.slice(1..) # calコマンドの出力表示に合わせるために先頭の空白を削除
    end
  end
end

class Options
  def initialize
    @options = {}
    OptionParser.new do |opt|      
      opt.on('-y [value]', '--year [value]') do |v|
        if v.nil?  # オプションのみで引数が与えられなかった場合
          @options[:y] = nil
        elsif (v =~ /\A[0-9]+\z/) == 0  # 引数が数字でのみで構成させているかチェック
          @options[:y] = v.to_i
        else  # エラー処理
          print "cal: not a valid year #{v}\n"
          exit
        end
      end 

      opt.on('-m [value]', '--month [value]') do |value|
        if value.nil?
          print "cal: option requires an argument -- 'm'\n"
          exit
        end
        v = value.to_i
        if 1 <= v && v <= 12
          @options[:m] = v
        else
          print "cal: #{value} is neither a month number (1..12) nor a name\n"
          exit
        end
      end
      opt.on('-h') { |v| @options[:h] = true  }
      opt.on('-1') { |v| @options[:one] = true  }
      opt.on('-3') { |v| @options[:three] = true  }
      begin
       opt.parse!(ARGV)
      rescue => e
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/,'')}'\n"
        exit
      end

      if self.has?(:y) && self.has?(:m)  # cal -y year -m month において、片方の引数が与えられていない場合はエラーとして終了
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

  def has?(name)
    @options.include?(name)
  end

  def get(name)
    @options[name]
  end
end

class Arguments
  def initialize
    @args = {}
    if ARGV.size >= 3  # 引数３つ以上で処理の終了(引数異常)
      exit
    elsif ARGV.size == 2  # 引数２つで月・年に代入
      @args[:m] = check_month(ARGV[0])
      @args[:y] = ARGV[1].to_i
    elsif ARGV.size == 1  # 引数１つで年に代入
      @args[:y] = ARGV[0].to_i
    end
  end

  def check_month(v)
    m = v.to_i  # 仮に文字が渡されていればココで０になる
    if 1 <= m && m <= 12
      m
    else
      print "cal: #{v} is neither a month number (1..12) nor a name\n"
      exit
    end
  end

  def has?(name)
    @args.include?(name)
  end

  def get(name)
    @args[name]
  end
end

date = Date.today
options = Options.new
args = Arguments.new

case  # オプションによるコマンドの分岐
when options.has?(:y) == true && options.has?(:m) == true  # cal -y [year] -m [month]
  date.year = options.get(:y)
  date.month = options.get(:m)
  cal = CalOneMonth.new(date)
when options.has?(:y) == true  # cal -y / cal -y [year]
  date.year = options.get(:y) unless options.get(:y).nil?  # 引数有りならyearに代入
  cal = OneYearCalendar.new(date)
when options.has?(:m) == true  # cal -m [month]
  date.month = options.get(:m)
  cal = CalOneMonth.new(date)
when options.has?(:h) == true  # cal -h
  # date.h = false
  cal = CalOneMonth.new(date)
when options.has?(:one) == true  # cal -1
  cal = OneYearCalendar.new(date)
when options.has?(:three) == true  # cal -3
  date = date.prev_month
  cal = ThreeMonthsCalendar.new(date)
when args.has?(:m) == true  # cal [month] [year] 引数に月の値が存在すれば年・月が指定された事を意味する
  date.year = args.get(:y)  # 引数から年を取得
  date.month = args.get(:m)  # 引数から月を取得
  cal = CalOneMonth.new(date)
when args.has?(:y) == true  # cal [year]
  date.year = args.get(:y)  # 引数から年を取得
  cal = OneYearCalendar.new(date)
else  # cal
  cal = CalOneMonth.new(date)
end

cal.print_calendar
