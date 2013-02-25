require 'test/unit'
require 'syster/sources/base'

module Foo
  class Bar < Syster::Sources::Base
  end
end

class TestBase < Test::Unit::TestCase
  def test_name
    assert_equal Foo::Bar.identifier, 'bar'
  end
end
