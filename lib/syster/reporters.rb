module Syster
  module Reporters
    def self.available
      unless defined? @@AVAILABLE
        load_from_dir local_directory
        load_from_dir File.join(File.dirname(__FILE__), 'reporters')

        @@AVAILABLE = Hash[constants.collect do |c|
          const_get c
        end.select do |c|
          c.instance_of? Class and c.identifier != 'base' and c.runnable?
        end.collect do |c|
          [c.identifier, c]
        end]
      end

      return @@AVAILABLE
    end

    private
    def self.local_directory
      ENV['REPORTERS_DIR'] || '/var/lib/syster/reporters'
    end

    private
    def self.load_from_dir dir
      Dir[File.join(dir, '*.rb')].each {|f| require f}
    end
  end
end
