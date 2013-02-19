require 'test/unit'
require 'kolekt/helpers/path'


class TestPath < Test::Unit::TestCase
  # Check that we survive missing directories
  ENV['PATH'] = '/doesnotexist:' + ENV['PATH']

  def test_simple_commands
    %w[true false ls].each do |e|
      assert_not_nil Kolekt::Helpers::Path.find(e), %[Couldn't find "#{e}""]
    end
  end

  def test_usr_bin_env
    assert_equal Kolekt::Helpers::Path.find('env'), '/usr/bin', %[env not in /usr/bin]
  end
end
