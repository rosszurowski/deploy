# Parses and provides an easy interface for working with
# deployment environment variables.

require 'tempfile'

module Deploy
	class Environment

		attr_reader :name
		attr_accessor :config, :options

		def initialize(name, hash)

			@name = name
			@config = { :host => '', :port => '',  :user => '', :private_key => '', :local => '', :remote => '' }
			@options = { :verbose => false, :sync => true }

			@config[:host] = hash['host']
			@config[:port] = hash['port'] || '22'
			
			@config[:user] = hash['user'] || ''
			@config[:private_key] = hash['privateKey'] || ''

			@config[:local] = hash['path']['local'].gsub(/\s+/, "")
			@config[:remote] = hash['path']['remote'].gsub(/\s+/, "")

			# Set to project and server root if local/remote are empty
			@config[:local] = '/' if @config[:local].empty?
			@config[:local].insert(0,'/') unless @config[:local].start_with?('/')
			@config[:remote] = '/' if @config[:remote].empty?
			@config[:remote].insert(0,'/') unless @config[:remote].start_with?('/')


			@config[:excludes] = hash['exclude'] || Array.new

			@options[:reverse] = false
			@options[:verbose] = hash['verbose'].to_s.empty? ? false : hash['verbose']
			@options[:sync] = hash['sync'].to_s.empty? ? true : hash['sync']

			validate

			# TODO: Find a way to do a setter for @config[:excludes] instead of
			# freezing the hash
			@config[:excludes].freeze

		end

		# Runs the deploy based upon the current @config and @options settings
		# Creates rsync command and creates exclude file then cleans up
		def deploy

			# Create excludes file if needed
			unless @config[:excludes].empty?
				tmp_exclude = Tempfile.new(['excludes','.txt'])
				@config[:excludes].each do |ex|
					tmp_exclude.puts ex
				end
				# Don't upload the deploy configuration file
				tmp_exclude.puts Deploy::CONFIG_PATH 
				tmp_exclude.puts ".git" # Never sync git files
				tmp_exclude.close
			end

			rsync_cmd = 'rsync -a'																																# Always keep permissions
			rsync_cmd += 'v' if @options[:verbose]																									# Verbose if requested
			rsync_cmd += 'z'																																			# Always zip files

			rsync_cmd += ' --progress'																														# Always show progress
			
			if (@options[:sync] && !@options[:reverse])
				rsync_cmd += ' --force --delete --delete-excluded'    																# Sync unless explicitly requested or downloading
			end
			rsync_cmd += " --exclude-from=#{tmp_exclude.path}" unless @config[:excludes].empty?			# Include exclude file if it exists
			
			rsync_cmd += " -e \"ssh "																															# Pass custom ssh options
			rsync_cmd += " -i #{@config[:private_key]} " unless @config[:private_key].empty?					# Include a custom private key if requested
			rsync_cmd += "-p #{@config[:port]}\" "																									# Choose port if specified

			unless @options[:reverse]
				rsync_cmd += `pwd`.gsub(/\s+/, "") + "#{@config[:local]} "														# The local path from the current directory
			end

			rsync_cmd += "#{@config[:user]}@" unless @config[:user].empty?													# Only add user if not empty
			rsync_cmd += "#{@config[:host]}:"																											# Add host
			rsync_cmd += "~#{@config[:remote]}"																										# Add remote (relative to remote user home)
			
			if @options[:reverse]
				rsync_cmd += " " + `pwd`.gsub(/\s+/, "") + "#{@config[:local]}"												# Put the local path after if we're downloading
			end
			
			# Run the command
			# puts rsync_cmd
			system(rsync_cmd)

			# Remove excludes file if needed
			tmp_exclude.unlink unless @config[:excludes].empty?
		
		end
		
		private
		
		def validate
		
			# Fail without hostname (username is optional)
			(puts "Error: no hostname set for `#{@name}`"; exit;) if @config[:host].empty?

			# Fail if local/remote paths not set (because they should be in initialize
			# even if they're not set in the yml config file.
			(puts "Error: no local path set for `#{@name}`"; exit;) if @config[:local].empty?
			(puts "Error: no remote path set for `#{@name}`"; exit;) if @config[:remote].empty?

		end
		
	end
end