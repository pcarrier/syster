require 'syster/reporters/base'
require 'syster/helpers/require'
require 'socket'

module Syster::Reporters
  class Mongo < Base
    def self.runnable?
      Syster::Helpers::Require.can_require? %w[mongo]
    end

    def initialize params={}
      require 'mongo'

      @hostname = Socket.gethostname

      uri = params[:uri] || ENV['MONGODB_URI']
      client = ::Mongo::MongoClient.from_uri uri

      @db = client['syster']

      drys = @db['dry'].find(:hostname => @hostname)

      raise 'Multiple DRYs!' if drys.count > 1

      if drys.count == 0
        @dry = {:hostname => @hostname}
      else
        @dry = drys.first
      end

      @update = {:hostname => @hostname}
    end

    def report name, payload
      @update[name] = mongify payload
    end

    def wants identifier, dry_payload
      orig = @dry[identifier]
      @dry[identifier] = dry_payload

      return orig != dry_payload
    end

    def finish
      @db['host'].update({:hostname => @hostname}, {'$set' => @update}, :upsert => true)
      @db['dry'].save @dry
    end

    # Sad I had to write this...
    # But the query DSL makes it half-OK.
    # {"$and": [ {"facter.kernel":"Darwin"}, {"augeas.etc.shells": "/bin/zsh"}]}
    private
    def mongify o
      if o.respond_to? :keys
        return Hash[o.collect do |k,v|
          k = k.to_s.gsub '.', '_'
          k = '%'+k[1..-1] if k.start_with? '$'
          next [k, mongify(v)]
        end]
      elsif Array === o
        return o.collect {|i| mongify i}
      else
        return o
      end
    end
  end
end
