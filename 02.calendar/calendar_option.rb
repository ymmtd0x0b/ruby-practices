# frozen_string_literal: true

class CalendarOption
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |opt|
      opt.on('-y [value]', '--year [value]') { |value| @options[:year] = value }
      opt.on('-m [value]', '--month [value]') { |value| @options[:month] = value }
      opt.on('-h') { @options[:off_highlight] = true }
      opt.on('-1') { @options[:one_year] = true }
      opt.on('-3') { @options[:three_months] = true }
      begin
        opt.parse!(ARGV)
      rescue StandardError => e
        print "cal: invalid option -- '#{e.message.gsub(/.+: -/, '')}'\n"
        exit
      end
      check_argument
      check_option_value
    end
  end

  def get_value(name)
    @options[name]
  end

  private

  def has?(name)
    @options.include?(name)
  end

  def check_year_value
    value = get_value(:year)
    if value.nil?
      @options[:year] = Date.today.year
    elsif value.start_with?(/\A[0-9]+\z/)
      @options[:year] = value.to_i
    else # 引数が存在し、数字以外が含まれていればエラー
      print "cal: not a valid year #{@options[:year]}\n"
      exit
    end
  end

  def check_month_value
    value = get_value(:month)
    if value.nil?
      print "cal: option requires an argument -- 'm'\n"
      exit
    end

    num = value.to_i
    if (1..12).cover?(num)
      @options[:month] = num
    else
      print "cal: #{value} is neither a month number (1..12) nor a name\n"
      exit
    end
  end

  def check_year_and_month_with_value
    if has?(:month) && get_value(:year).nil? # cal -y year -m month において、片方の引数が与えられていない場合はエラーとして終了
      print "cal: option requires an argument -- 'y'\n"
      exit
    elsif has?(:year) && get_value(:month).nil?
      print "cal: option requires an argument -- 'm'\n"
      exit
    end
  end

  def check_option_value
    case @options.keys.join
    when 'year'
      check_year_value
    when 'month'
      check_month_value
    when 'yearmonth', 'monthyear'
      check_year_value
      check_month_value
      check_year_and_month_with_value
    end
  end

  def check_argument
    case ARGV.size
    when 2 # 引数２つで月・年の順で指定されたと見做す
      @options[:month] = ARGV[0]
      @options[:year] = ARGV[1]
    when 1 # 引数１つで年のみ指定されたと見做す
      @options[:year] = ARGV[0]
    end
  end
end
