libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'deploy/version'
require 'deploy/environment'

module Deploy

  # TODO: Make this adjustable from the command line
  CONFIG_PATH = "deploy.yml"

  class Deployment

    attr_reader :environments

    def initialize()

      @config = YAML::load(File.open(CONFIG_PATH))
      @environments = Array.new

      @config.each do |env|
        @environments.push Environment.new(env[0], env[1])
      end

    end

    def go(args)

      # If there are no arguments, deploy using the first environment in
      # the configuration file, otherwise loop through and deploy each one
      if args.size == 0
        
        @environments.first.deploy
        
      else
        
        # Loop through the arguments and deploy any given ones that are also
        # present in the config file.
        args.each do |arg_env|
          
          curr_env = @environments.find { |e| e.name == arg_env }
          if curr_env.nil?
            puts "No environment found for #{arg_env}, add it to `#{Deploy::CONFIG_PATH}`"
          else
            curr_env.deploy
          end
        
        end
        
      end

    end

  end

end