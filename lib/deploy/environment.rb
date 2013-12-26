# Parses and provides an easy interface for working with
# deployment environment variables.

require 'tempfile'

module Deploy
	class Environment

		attr_accessor :config, :options

		def initialize(name, hash)

			@name = name
			@config = { :host => '', :user => '', :pass => '', :local => '', :remote => '' }
			@options = { :verbose => false, :sync => true }

			@config[:host] = hash['host']
			@config[:user] = hash['user']
			@config[:pass] = hash['pass'] unless hash['pass'].nil?

			@config[:local] = hash['path']['local'].gsub(/\s+/, "")
			@config[:remote] = hash['path']['remote'].gsub(/\s+/, "")

			# Set to project and server root if local/remote are empty
			@config[:local] = '/' if @config[:local].empty?
			@config[:local].insert(0,'/') unless @config[:local].start_with?('/')
			@config[:remote] = '/' if @config[:remote].empty?
			@config[:remote].insert(0,'/') unless @config[:remote].start_with?('/')


			@config[:excludes] = hash['exclude'] if hash['exclude']

			@options[:verbose] = hash['verbose'] unless hash['verbose'].nil?
			@options[:sync] = hash['sync'] unless hash['sync'].nil?

			validate

			# TODO: Find a way to do a setter for @config[:excludes] instead of
			# freezing the hash
			@config[:excludes].freeze

		end

		# Runs the deploy based upon the current @config and @options settings
		# Creates rsync command and creates exclude file then cleans up
		def deploy

			# Create excludes file if needed
			if(@config[:excludes])
				tmp_exclude = Tempfile.new(['excludes','.txt'])
				@config[:excludes].each do |ex|
					tmp_exclude.puts ex
				end
				tmp_exclude.close
			end

			rsync_cmd = 'rsync -a'																												# Always keep permissions
			rsync_cmd += 'v' if @options[:verbose]																					# Verbose if requested
			rsync_cmd += 'z'																															# Always zip files

			rsync_cmd += ' --progress'																										# Always show progress
			rsync_cmd += ' --force --delete' unless !@options[:sync]												# Sync unless explicitly requested
			rsync_cmd += " --exclude-from=#{@config['excludes']}" if @config[:excludes]			# Include exclude file if it exists
			rsync_cmd += " -e \"ssh -p22\""

			rsync_cmd += " .#{@config[:local]}"
			rsync_cmd += " #{@config[:user]}@#{@config[:host]}:~#{@config[:remote]}"

			# Run the command
			system(rsync_cmd)

			# Remove excludes file if needed
			tmp_exclude.unlink if @config[:excludes]

		end

		private

		def validate

			# Fail without hostname/username (password is optional)
			raise "Error: no hostname set for #{@name}" if @config[:host].empty?
			raise "Error: no user set for #{@name}" if @config[:user].empty?

			# Fail if local/remote paths not set (because they should be in initialize
			# even if they're not set in the yml config file.
			raise "Error: no local path set for #{@name}" if @config[:local].empty?
			raise "Error: no remote path set for #{@name}" if @config[:remote].empty?

		end

	end
end