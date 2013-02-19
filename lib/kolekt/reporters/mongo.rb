require 'kolekt/reporters/base'
require 'socket'

# Configured through ENV['MONGODB_URI']
module Kolekt::Reporters
  class Mongo < Base
    def self.runnable?
      begin
        require 'mongo'
      catch LoadException
        return false
      end
    end
  
    def initialize
      require 'mongo'

      @client = ::Mongo::MongoClient.new
      @db = @client['kolekt']
      @coll = @db['hosts']

      @update = {:hostname => Socket.gethostname}
    end
  
    def report name, payload
      @update[name] = payload
    end

    def wants identifier, dry_payload
      true
    end
  
    def finish
      @coll.update({:hostname => Socket.gethostname}, @update, :upsert => true)
    end
  end
end
