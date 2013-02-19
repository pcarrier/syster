require 'kolekt/reporters/base'
require 'awesome_print'

module Kolekt; module Reporters; class Console < Base
  def report name, payload
    puts "=== #{name} ==="
    ap payload
  end
end; end; end
