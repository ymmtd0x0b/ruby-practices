# frozen_string_literal: true

require 'date'
require 'optparse'
require_relative './one_year_calendar'
require_relative './three_months_calendar'
require_relative './one_month_calendar'
require_relative './calendar_option'

option = CalendarOption.new

cal =
  if option.off_highlight
    OneMonthCalendar.new(Date.today.year, Date.today.month).off_highlight
  elsif option.three_months
    prev_month = Date.today.prev_month
    ThreeMonthsCalendar.new(prev_month)
  elsif option.year && option.month
    OneMonthCalendar.new(option.year, option.month)
  elsif option.month
    OneMonthCalendar.new(Date.today.year, option.month)
  elsif option.year || option.one_year
    OneYearCalendar.new(Date.today.year)
  else
    OneMonthCalendar.new(Date.today.year, Date.today.month)
  end

cal.print
