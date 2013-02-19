require 'test/unit'
require 'kolekt/sources/base'

module Foo
  class Bar < Base
  end
end

class TestBase < Test::Unit::TestCase
  def test_name
    assert_equal Foo::Bar.identifier, 'bar'
  end
end
