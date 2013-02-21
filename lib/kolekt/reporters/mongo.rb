require 'kolekt/reporters/base'
require 'kolekt/helpers/require'
require 'socket'

module Kolekt::Reporters
  class Mongo < Base
    def self.runnable?
      # Sadly mongodb doesn't allow '$' or '.' in key names.
      # If somebody can be bothered to implement a decent workaround,
      # I'll take patches.
      return false
      Kolekt::Helpers::Require.can_require? %w[mongo]
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
      # TODO: This allows stale data inside the sources.
      @coll.update({:hostname => Socket.gethostname}, @update, :upsert => true)
    end
  end
end
