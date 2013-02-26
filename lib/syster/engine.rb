require 'logger'
require 'syster/sources'
require 'time'

module Syster
  class Engine
    module SourceCondition
      EXCLUDED = 'excluded'
      UNRUNNABLE = 'unrunnable'
      DRYED_OUT = 'DRYed out'
      READY = 'active'
      SUCCEEDED = 'succeeded'
      FAILED = 'failed'
    end

    attr_reader :sources

    def initialize options={}
      @options = options

      @log = options[:logger] || Logger.new(STDERR)

      @sources = {}

      Syster::Sources.available.each do |src|
        id = src.identifier

        if options[:excludes] and options[:excludes].find {|e| e === id}
          @sources[src] = SourceCondition::EXCLUDED
        elsif !src.runnable?
          @sources[src] = SourceCondition::UNRUNNABLE
        else
          @sources[src] = SourceCondition::READY
        end
      end
    end

    def run reporter
      internal_report = {
        :started => Time.now.utc.iso8601
      }

      @sources.each do |src, c|
        next unless c == SourceCondition::READY

        instance = src.new @options
        id = src.identifier
        @log.debug "Source #{id} DRYing..."
        dry = instance.dry

        if !dry.first
          @log.debug "Source #{id} couldn't DRY (#{dry.inspect})."
        else
          if !reporter.wants id, dry[1..-1]
            @log.debug "Source #{id} DRYed, not wanted (#{dry.inspect})."
            @sources[src] = SourceCondition::DRYED_OUT
          else
            @log.debug "Source #{id} DRYed, wanted (#{dry.inspect})."

            begin
              success, payload = instance.collect
            rescue Exception => e
              success = false
              payload = "raised an exception: #{e}, #{e.backtrace.join ', '}"
            end
  
            if success
              @sources[src] = SourceCondition::SUCCEEDED
              @log.debug "Source #{id} succeeded."
              reporter.report id, payload
            else
              @sources[src] = SourceCondition::FAILED
              @log.warn "Source #{id} failed (#{payload.inspect})."
            end
          end
        end
      end

      internal_report[:sources] = Hash[@sources.collect {|src, c| [src.identifier, c]}]
      internal_report[:finished] = Time.now.utc.iso8601
      reporter.report 'syster', internal_report

      begin
        reporter.finish
      rescue Exception => e
        @log.fatal "Reporter #{reporter.class.identifier} failed (#{e}, #{e.backtrace.join ', '})."
      end
    end
  end
end
