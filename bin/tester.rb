require 'kolekt/reporters/console'
require 'kolekt/engine'

Kolekt::Engine.new.run Kolekt::Reporters::Console.new
