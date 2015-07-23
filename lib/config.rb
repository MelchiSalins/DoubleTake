require 'yaml'
require 'pry'
require 'uri'
require 'crawler_lib'

class Configuration
	attr_accessor :stage, :prod, :ignored, :DESKTOP, :to_be_scraped
	attr_accessor :scraped, :bad_links, :LOGGED_IN
	attr_reader :LOGIN_URI, :USER_VALUE, :USER_DOM_ID
	attr_reader :PASS_VALUE, :PASS_DOM_ID
	attr_reader :LOGIN_CONFIRM_CHECK, :LOGIN_CONFIRM, :LOGIN
	attr_reader :URI_THRESHOLD, :IMAGE_THRESHOLD
	attr_reader :SCREEN_RESOLUTION, :WHITELIST

	def initialize
		@stage = ""
		@prod  = ""
		@ignored = ["ignore_me", "not_important_url_prefix",".css", ".pdf", ".js", ".jpg", ".png", "video/pop", "user/logout", "?", "=", "#"]
		@SCREEN_RESOLUTION = {:desktop => [1400,800], :iPadAir => [1024,768], :iphone6 => [375,667]}
		@IMAGE_THRESHOLD = 0
		@LOGIN = true
		@LOGIN_URI = 'user/login' # http://example.com/login
		@USER_DOM_ID = 'edit-name'
		@USER_VALUE = 'melchisalins'
		@PASS_DOM_ID = 'edit-pass'
		@PASS_VALUE = 'secret_password'
		@LOGIN_CONFIRM = false
		@LOGIN_CONFIRM_CHECK = 'region-wrapper'
		@WHITELIST = ['https://example.com/', 'https://example-stage.com/']
		@bad_links = []
		@to_be_scraped = []
		@scraped = []
		@LOGGED_IN = false
	end

	def all_good?
		begin
			# Fixes scheme of the URL if not present. This is needed by Selenium
			return_value = false
			if @stage.length <= 0 && @prod.length <= 0
				puts "* Stage and Production URL missing."
				return_value = false
				return return_value
			else
				@stage = fix_scheme(@stage) if URI.parse(@stage).scheme == nil
				@prod  = fix_scheme(@prod)  if URI.parse(@prod).scheme == nil
				return_value = true
			end

			if @LOGIN && @LOGIN_URI.nil? == false && @USER_DOM_ID.nil? == false && @USER_VALUE.nil? == false && @PASS_DOM_ID.nil? == false && @PASS_VALUE.nil? == false
				return_value = true
			else
				puts "* Please configure LOGIN parameters"
				return_value = false
				return return_value
			end

			if @LOGIN_CONFIRM && @LOGIN_CONFIRM_CHECK
				return_value = true
			elsif @LOGIN_CONFIRM == false
				return_value = true
			else
				puts "* Please configure LOGIN_CONFIRM_CHECK value"
				return_value = false
				return return_value
			end

			return return_value
		rescue Exception => e
			puts e
			return false
		end
	end

	def proceed_with_whitelist_scan?
		return_value = true
		if URI.parse($config.stage).host != URI.parse($config.WHITELIST.first).host
			puts "* Please make sure 'stage' and the 'whitelist' URL are the same domain."
			return_value = false
		end
		if $config.WHITELIST.length < 1
			puts "* Make sure to have atleast one URL to scan in whitelist"
			return_value = false
		end
		$config.WHITELIST.each do |each_url|
			if URI.parse(each_url).scheme == nil
				puts "* Please make sure to add a scheme to #{each_url}"
				return_value = false
			end
		end
		return_value
	end

end
# c = Configuration.new
# File.open("test_yaml.yml","w") {|f| f.write(c.to_yaml)}
# y = YAML.load(File.open("test_yaml.yml", "r"))
# puts y.inspect
# y.validate
