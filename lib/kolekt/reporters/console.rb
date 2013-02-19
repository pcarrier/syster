require 'kolekt/reporters/base'
require 'mongo'
require 'socket'

# Configured through MONGODB_URI

module Kolekt::Reporters
  class Console < Base
    include Mongo
  
    def initialize
      @client = MongoClient.new
      @db = @client['kolekt']
      @coll = @db['hosts']
      @update = {}
    end
  
    def report name, payload
      @update[name] = payload
    end
  
  
    def wants identifier, dry_payload
      true
    end
  
    def finish
      @coll.update 
    end
  end
end
