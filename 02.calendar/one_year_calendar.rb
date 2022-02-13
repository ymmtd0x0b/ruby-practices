# frozen_string_literal: true

class OneYearCalendar
  YEAR_LINE_WIDTH = 63
  def initialize(year)
    @data = {
      year_title: Date.today.year.to_s.center(YEAR_LINE_WIDTH),
      twelve_months: create(year)
    }
  end

  def print
    puts @data[:year_title]
    @data[:twelve_months].each(&:print)
  end

  private

  def create(year)
    january = Date.new(year, 1, 1)
    (0..3).map do |n|
      date = january.next_month(n * 3)
      ThreeMonthsCalendar.new(date).delete_year_from_months_title
    end
  end
end
