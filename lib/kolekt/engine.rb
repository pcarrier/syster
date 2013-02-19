require 'kolekt/sources'
require 'logger'

module Kolekt
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
      @sources = {}
      @log = options[:logger]
      @log ||= Logger.new(STDERR)

      Kolekt::Sources.available.each do |src|
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
        :started => Time.now.to_i
      }

      @sources.each do |src, c|
        next unless c == SourceCondition::READY

        instance = src.new
        id = src.identifier
        dry = instance.dry

        if dry.first and !reporter.wants id, dry[1..-1]
          @sources[src] = SourceCondition::DRYED_OUT
        else
          begin
            success, payload = instance.collect
          rescue Exception => e
            success = false
            @log.warn "#{id} raised an exception: #{e}"
          end

          if success
            @sources[src] = SourceCondition::SUCCEEDED
            reporter.report id, payload
          else
            @sources[src] = SourceCondition::FAILED
            @log.warn "#{id} failed: #{payload}"
          end
        end
      end

      internal_report[:sources] = Hash[@sources.collect {|src, c| [src.identifier, c]}]
      internal_report[:finished] = Time.now.to_i
      reporter.report 'kolekt', internal_report

      begin
        reporter.finish
      rescue Exception => e
        @log.fatal "Reporter failed (#{e}"
      end
    end
  end
end
