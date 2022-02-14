# frozen_string_literal: true

class CalendarOption
  attr_reader :year, :month, :off_highlight, :one_year, :three_months

  def initialize
    OptionParser.new do |opt|
      opt.on('-y [value]', '--year [value]') { |value| @year = value.to_i }
      opt.on('-m value', '--month value') { |value| @month = value.to_i }
      opt.on('-h') { @off_highlight = true }
      opt.on('-1') { @one_year = true }
      opt.on('-3') { @three_months = true }
      opt.parse!(ARGV)

      if @year.nil? && @month.nil?
        case ARGV.size
        when 2
          @year = ARGV[1].to_i
          @month = ARGV[0].to_i
        when 1
          @year = ARGV[0].to_i
        end
      end
    end
  end
end
