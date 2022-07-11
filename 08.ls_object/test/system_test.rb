# frozen_string_literal: true

require 'test/unit'
require_relative '../ls'

class TestLs < Test::Unit::TestCase
  test 'short_ls' do
    expected = <<~TEXT.chomp
      Desktop    Public          fjord
      Documents  Templates       snap
      Downloads  Videos          work
      Music      VirtualBox VMs
      Pictures   bin
    TEXT
    assert_equal expected, Ls.short_ls
  end
end
