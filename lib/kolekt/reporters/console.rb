require 'kolekt/reporters/base'
require 'json'

module Kolekt; module Reporters; class Console < Base
  def report name, payload
    puts JSON::dump [name, payload]
  end
end; end; end
