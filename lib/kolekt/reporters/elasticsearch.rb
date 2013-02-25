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

      @log = params[:logger] || Logger.new(STDERR)

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
  
    def report identifier, payload
      @update[identifier] = ::JSON::dump payload

      if @dry.has_key? identifier
        @dry[identifier][:last_run] = Time.now.to_i
      end
    end

    def wants identifier, dry_payload
      unless @dry.has_key? identifier
        @dry[identifier] = {'payload'    => nil,
                            'last_dried' => 0,
                            'last_run'   => 0}
      end

      orig = @dry[identifier]['payload']

      @dry[identifier]['payload'] = dry_payload
      @dry[identifier]['last_dried'] = Time.now.to_i

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
