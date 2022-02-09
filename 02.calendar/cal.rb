# frozen_string_literal: true

require 'date'
require 'optparse'
require_relative './class'

option = CalendarOption.new
today = Date.today

cal =
  case option.options.keys.join(',')
  when 'year'
    OneYearCalendar.new(option.get_value(:year))
  when 'month'
    OneMonthCalendar.new(today.year, option.get_value(:month))
  when 'year,month', 'month,year'
    OneMonthCalendar.new(option.get_value(:year), option.get_value(:month))
  when 'one_year'
    OneYearCalendar.new(today.year)
  when 'three_months'
    today = today.prev_month
    ThreeMonthsCalendar.new(today.year, today.month)
  when 'off_highlight'
    OneMonthCalendar.new(today.year, today.month).off_highlight
  when ''
    OneMonthCalendar.new(today.year, today.month)
  else
    exit
  end

cal.print_calendar
