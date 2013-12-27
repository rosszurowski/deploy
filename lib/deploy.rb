libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'yaml'
require 'deploy/version'
require 'deploy/environment'

module Deploy
  
  # Config path is loaded in from a config.yml stored in the gem
  GEM_SETTINGS_PATH = File.dirname(__FILE__) + '/config.yml'
  CONFIG_PATH = YAML::load(File.open(GEM_SETTINGS_PATH))['config_path']

  class Deployment

    attr_reader :environments
    
    attr_accessor :reverse

    def initialize()

      @config = YAML::load(File.open(CONFIG_PATH))
      @environments = Array.new

      @config.each do |env|
        @environments.push Environment.new(env[0], env[1])
      end

      @reverse = false

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

    # Set deployment reverse and apply it to all associated environments too
    def reverse=(reverse)
      
      @reverse = reverse
      @environments.each do |env|
        env.config[:reverse] = reverse
      end
      
    end

  end

end