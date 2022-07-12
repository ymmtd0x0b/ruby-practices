# frozen_string_literal: true

require 'test/unit'
require_relative '../short_ls'
require_relative '../long_ls'

class TestShortLs < Test::Unit::TestCase
  test 'short_ls' do
    expected = <<~TEXT.chomp
      Desktop    Public          fjord
      Documents  Templates       snap
      Downloads  Videos          work
      Music      VirtualBox VMs
      Pictures   bin
    TEXT
    assert_equal expected, ShortLs.new([]).lines
  end
end

class TestLongLs < Test::Unit::TestCase
  test 'long_ls' do
    expected = `ls -l #{Dir.home}`.chomp
    assert_equal expected, LongLs.new([]).lines
  end
end
