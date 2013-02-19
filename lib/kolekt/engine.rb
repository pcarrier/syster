require 'kolekt/sources'
require 'logger'

module Kolekt; class Engine
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

    Kolekt::Sources.available.each do |source|
      id = source.identifier

      if options[:exclude] and options[:exclude].find {|e| e === id}
        @sources[source] = SourceCondition::EXCLUDED
      elsif !source.runnable?
        @sources[source] = SourceCondition::UNRUNNABLE
      else
        @sources[source] = SourceCondition::READY
      end
    end
  end

  def run reporter
    internal_report = {
      :started => Time.now.to_i
    }
    
    to_run = @sources.find_all do |src, condition|
      condition == SourceCondition::READY
    end
    
    to_run.each do |source, condition|
      instance = source.new
      dry = instance.dry
      if dry.first and reporter.wants dry[1..-1]
        @sources[source] = SourceCondition.DRYED_OUT
      else
        success, payload = instance.collect
        if success
          @sources[source] = SourceCondition::SUCCEEDED
          reporter.report source.identifier, payload
        else
          @sources[source] = SourceCondition::FAILED
          @log.warn "#{source.identifier} failed: #{payload}"
        end
      end
    end

    internal_report[:sources] = @sources
    internal_report[:stopped] = Time.now.to_i
    reporter.report 'kolekt', internal_report

    begin
      reporter.finish
    rescue Exception => e
      @log.fatal "Reporter failed (#{e}"
    end
  end
end; end