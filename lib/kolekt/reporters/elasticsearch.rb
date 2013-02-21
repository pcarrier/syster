require 'kolekt/reporters/base'
require 'kolekt/helpers/require'
require 'socket'

module Kolekt::Reporters
  class ElasticSearch < Base
    def self.runnable?
      Kolekt::Helpers::Require.can_require? %w[net/http/persistent json]
    end
  
    def initialize params={}
      require 'net/http/persistent'
      require 'json'

      @log = params[:logger]
      @log ||= Logger.new(STDERR)

      @update = {}

      uri = params[:uri]
      uri ||= 'http://localhost:9200/kolekt/'
      @uri = URI uri

      @http = ::Net::HTTP::Persistent.new 'kolekt'

      begin
        @dry = get_dry
      rescue Exception => e
        @dry = {}
        @log.warn "Couldn't get DRY (#{e}, #{e.backtrace}), creating entries"
        create_indexes
      end
    end
  
    def report name, payload
      @update[name] = ::JSON::dump payload
    end

    def wants identifier, dry_payload
      orig = @dry[identifier]
      @dry[identifier] = dry_payload
      return orig == dry_payload
    end
  
    def finish
      post_host_update
      post_dry_update
      @http.shutdown
    end

    private
    def post_host_update
      script = @update.collect{|k,_| "ctx._source.#{k} = #{k}"}.join ';'
      params = @update.collect{|k,v| %["#{k}": #{v}]}.join ','

      post(host_uri + '_update', %[{"script": "#{script}", "params": {#{params}}}])
    end

    private
    def post_dry_update
      post dry_uri, ::JSON::dump(@dry)
    end

    private
    def get_dry
      rep = @http.request dry_uri
      payload = ::JSON::load rep.body
      raise 'not found' unless payload['exists']
      return payload['_source']
    end

    private
    def create_indexes
      post(dry_uri + '?op_type=create', '{}')
      post(host_uri + '?op_type=create', '{}')
    end

    private
    def dry_uri
      @dry_uri ||= @uri + "dry/#{Socket.gethostname}/"
    end

    private
    def host_uri
      @host_uri ||= @uri + "host/#{Socket.gethostname}/"
    end

    private
    def post uri, payload
      p = ::Net::HTTP::Post.new uri.path
      p.body = payload
      res = @http.request uri, p
      unless res.code[0] == '2'
          raise "#{uri} POST failed with #{res.code} (#{res.body})"
      end
      return res
    end
  end
end
