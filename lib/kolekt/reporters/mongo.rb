require 'kolekt/reporters/base'
require 'socket'

module Kolekt::Reporters
  class Mongo < Base
    def self.runnable?
      return false # mongodb rejects '.' in keys. F*** off.
      begin
        require 'mongo'
      catch LoadException
        return false
      end
    end
  
    def initialize params={}
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
