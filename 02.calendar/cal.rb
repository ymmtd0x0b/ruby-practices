require 'date'
require 'optparse'

class OneYearCalendar
  YEAR_LINE_WIDTH = 63
  def initialize(year)
    @year = year
    @one_year_calendar = create_one_year_calendar(year)
  end

  def create_year_line
    "#{@year.to_s.center(YEAR_LINE_WIDTH)}\n"
  end

  def create_months_line(three_months)
    months = three_months.three_months_calendar.map do |month|
      month.month_title.sub(/ *([0-9]+月).*/, '\1').center(CalOneMonth::LINE_WIDTH)
    end
    "#{months.join(' ')}\n"
  end

  def print_calendar
    print create_year_line
    @one_year_calendar.map do |three_months|
      print create_months_line(three_months)
      print three_months.create_wdays_line
      print three_months.create_dates_lines
    end
  end

  private

  def create_one_year_calendar(year)
    january = Date.new(year, 1, 1)
    (0..3).map do |n|
      date = january.next_month(n * 3)
      ThreeMonthsCalendar.new(date.year, date.month)
    end
  end
end

class ThreeMonthsCalendar
  attr_reader :three_months_calendar

  def initialize(year, month)
    @three_months_calendar = create_three_months_calendar(year, month)
  end

  def create_months_title
    "#{@three_months_calendar.map(&:month_title).join(' ')}\n"
  end

  def create_wdays_line
    "#{Array.new(3) { CalOneMonth::WDAYS.join(' ') }.join('  ')}\n"
  end

  def create_dates_lines
    dates =
      (0..5).map do |week|
        one_week_line = @three_months_calendar.map { |current_month| current_month.dates_table[week] }
        "#{one_week_line.join('  ')}\n"
      end
    dates.join('')
  end

  def print_calendar
    print create_months_title
    print create_wdays_line
    print create_dates_lines
  end

  private

  def create_three_months_calendar(year, month)
    base_date = Date.new(year, month, 1)
    (0..2).map do |n|
      date = base_date.next_month(n)
      CalOneMonth.new(date.year, date.month)
    end
  end
end

class CalOneMonth
  attr_reader :month_title, :wdays, :dates_table

  DATE_CELL_WIDTH = 3
  LINE_WIDTH = 20
  WDAYS = %w[日 月 火 水 木 金 土]
  def initialize(year, month)
    @month_title = create_month_title(year, month)
    @wdays = WDAYS.join(' ')
    @dates_table = create_dates_table(year, month)
  end

  def print_calendar
    puts @month_title
    puts @wdays
    print @dates_table.join("\n")
  end

  def create_formatted_day(date)
    day = (date.day / 10).zero? ? date.day.to_s.rjust(1, ' ') : date.day.to_s # １桁の場合はスペースもハイライトの対象にする
    if date == Date.today
      " \e[47;30m#{day}\e[0m"
    else
      day.rjust(DATE_CELL_WIDTH, ' ')
    end
  end

  def create_formatted_blank_space
    (' ' * DATE_CELL_WIDTH)
  end

  def delete_highlight
    @calendar.map! do |one_week|
      if one_week.inspect.include?('\e[47;30m')
        one_week.inspect.gsub(/"(.*)\\e\[47;30m(..)\\e\[0m(.*)"/, '\1\2\3')
      else
        one_week
      end
    end
  end

  private

  def create_month_title(year, month)
    ("#{month}月 #{year}").center(LINE_WIDTH)
  end

  def create_dates_table(year, month)
    date = Date.new(year, month, 1)
    Array.new(6, '').map do |week| # 1 month == 6 weeks
      (0..6).each do |wday| # 1 week == 6 days (0~6,0:Sunday)
        if wday == date.wday && month == date.month
          week += create_formatted_day(date)
          date = date.next_day
        else
          week += create_formatted_blank_space
        end
      end
      week.slice(1..) # calコマンドの出力表示に合わせるために先頭の空白を削除
    end
  end
end

class Options
  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-y [value]', '--year [value]') do |v|
        if v.nil? # オプションのみで引数が与えられなかった場合
          @options[:y] = nil
        elsif (v =~ /\A[0-9]+\z/) == 0 # 引数が数字でのみで構成させているかチェック
          @options[:y] = v.to_i
        else # エラー処理
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
      opt.on('-h') { |v| @options[:h] = true }
      opt.on('-1') { |v| @options[:one] = true }
      opt.on('-3') { |v| @options[:three] = true }
      begin
       opt.parse!(ARGV)
      rescue => e
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/,'')}'\n"
        exit
      end

      if self.has?(:y) && self.has?(:m) # cal -y year -m month において、片方の引数が与えられていない場合はエラーとして終了
        case
        when self.get(:y).nil?
          print "cal: option requires an argument -- 'y'\n"
          exit
        when self.get(:m).nil?
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

options = Options.new
args = Arguments.new

case # オプションによるコマンドの分岐
when options.has?(:y) && options.has?(:m) # cal -y [year] -m [month]
  cal = CalOneMonth.new(options.get(:y), options.get(:m))
when options.has?(:y) # cal -y / cal -y [year]
  year = options.get(:y).nil? ? Date.today.year : options.get(:y) # 引数有りならyearに代入
  cal = OneYearCalendar.new(year)
when options.has?(:m) # cal -m [month]
  cal = CalOneMonth.new(Date.today.year, options.get(:m))
when options.has?(:h) # cal -h
  cal = CalOneMonth.new(Date.today.year, Date.today.month)
  cal.delete_highlight
when options.has?(:one) # cal -1
  cal = OneYearCalendar.new(Date.today.year)
when options.has?(:three) # cal -3
  date = Date.today.prev_month
  cal = ThreeMonthsCalendar.new(date.year, date.month)
when args.has?(:m) # cal [month] [year] 引数に月の値が存在すれば年・月が指定された事を意味する
  cal = CalOneMonth.new(args.get(:y), args.get(:m))
when args.has?(:y) # cal [year]
  cal = OneYearCalendar.new(args.get(:y))
else # cal
  cal = CalOneMonth.new(Date.today.year, Date.today.month)
end

cal.print_calendar
