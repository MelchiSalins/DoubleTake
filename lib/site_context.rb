require 'fileutils'
require 'selenium-webdriver'
require 'crawler_lib.rb'
require 'config.rb'
require 'pry'
require 'RMagick'
require 'yaml'
require 'csv'

# require 'pry-debugger'

# class Configuration
# 	# attr_accessor :stage, :prod, :ignored, :DESKTOP
# 	def initialize
# 		@stage = "https://rialto-stage.equiem.com.au"
# 		@prod  = "https://atrialto.com"
# 		@ignored = ["ignore_me", "not_important_url_prefix",".css", ".pdf", ".js", ".jpg", ".png", "video/pop", "user/logout", "?", "=", "#"]
# 		@SCREEN_RESOLUTION = {:desktop => [1400,800], :mobile => [300,150]}
# 		@IMAGE_THRESHOLD = 0
# 		@LOGIN = true
# 		@LOGIN_URI = 'login' # http://example.com/login
# 		@USER_DOM_ID = 'edit-name'
# 		@USER_VALUE = 'melchisalins'
# 		@PASS_DOM_ID = 'edit-pass'
# 		@PASS_VALUE = 'secret_password'
# 		@LOGIN_CONFIRM = true
# 		@LOGIN_CONFIRM_CHECK = 'homepage-onsite-team'
# 	end
# end

class SiteContext
	attr_accessor :driver

	def initialize
		puts "SiteContext initializes!"
	end

	def set_driver(browser = :chrome, remote = "http://192.168.15.43:4444/wd/hub/")
		# driver = Selenium::WebDriver.for(:remote, :url => remote, :desired_capabilities => browser)
		driver = Selenium::WebDriver.for :firefox
		return driver
	end

	def login_to_as(site, driver)
		$config.LOGGED_IN = true
		driver.get(site + $config.LOGIN_URI)
		username = driver.find_element(:id, $config.USER_DOM_ID)
		username.clear
		username.send_keys($config.USER_VALUE)
		password = driver.find_element(:id, $config.PASS_DOM_ID)
		password.clear
		password.send_keys($config.PASS_VALUE+"\n")

		if "Terms and Conditions".include?(driver.title)
			driver.find_element(:id, "edit-legal-accept").click
			driver.find_element(:id, "edit-save").click
		end

		if driver.find_element(:class, $config.LOGIN_CONFIRM_CHECK) != nil
			return true
		else
			return false
		end
	end #End of Method login_to_as
end

class Crawler < SiteContext
	include CrawlerHelper
	include Magick
	attr_accessor :site, :driver1, :driver2, :progress

	class Progress
		attr_accessor :driver1_type, :driver2_type
		attr_accessor :stage, :prod
		attr_accessor :bad_links, :to_be_scraped, :scraped

		def initialize
			@driver1_type = ""
			@driver2_type = ""
			@stage = ""
			@prod  = ""
			@bad_links    = []
			@to_be_scraped = []
			@scraped       = []
		end
	end


	def initialize(site, test, base, browser = :firefox)
		@site = site.to_s
		$config.SCREEN_RESOLUTION.keys.each do |key|
			FileUtils::mkdir_p "#{ENV['HOME']}/DoubleTake_data/#{@site}/#{key}"
		end
		puts "* Screenshots are saved in #{ENV['HOME']}/DoubleTake_data/#{@site}"
		$config.to_be_scraped << test
		@test_domain_length = test.length
		puts "Crawler initialized"
		@driver1 = SiteContext.new
		@driver1 = @driver1.set_driver(browser)
		@driver1.get(test)
		@driver1.manage.window.resize_to($config.SCREEN_RESOLUTION.first[1][0], $config.SCREEN_RESOLUTION.first[1][1]) #First resolution
		unless $cf == "scrape"
			@driver2 = SiteContext.new
			@driver2 = @driver2.set_driver(browser)
			@driver2.get(base)
			@driver2.manage.window.resize_to($config.SCREEN_RESOLUTION.first[1][0], $config.SCREEN_RESOLUTION.first[1][1]) #First resolution
		end
	end

	def clean_up
		@driver1.quit
		@driver2.quit unless $cf == "scrape"
		puts "Destroyed WebDriver instances."
	end

	def bad_link?(link)
		# This should populate bad_links[] and return bool
		# regarding the link being passed in.
		# $config.scraped << link
		# Bad link could be parameterised URLs(?, #) or
		# External domains such as facebook, twitter etc. or
		# link is non http Ex: mailto: ftp: file: etc.
		# puts $config.scraped
		if link.include?("$") || link.include?("#") || link.include?(".png") || link.include?(".js")
			puts "Bad Link: "+link
			$config.scraped << link if ($config.scraped.include?(link) == false)
			$config.bad_links << link if ($config.bad_links.include?(link) == false)
			return true
		elsif link.include?(".pdf") || link.include?(".jpeg") || link.include?(".css") || link.include?(".jpg")
			puts "Bad Link: "+link
			$config.scraped << link if ($config.scraped.include?(link) == false)
			$config.bad_links << link if ($config.bad_links.include?(link) == false)
			return true
		elsif link.include?("video/pop") || link.include?("?") || link.include?("/user/logout")
			puts "Bad Link: "+link
			$config.scraped << link if ($config.scraped.include?(link) == false)
			$config.bad_links << link if ($config.bad_links.include?(link) == false)
			return true
		elsif link[0..3] != "http" #TODO: This doesn't seem to work.
			puts "Bad Link: "+link
			$config.scraped << link if ($config.scraped.include?(link) == false)
			$config.bad_links << link if ($config.bad_links.include?(link) == false)
			return true
		elsif link[0..@test_domain_length-1] != $config.stage || link.include?("%")
			puts "Out of Scope: "+link
			$config.scraped << link if ($config.scraped.include?(link) == false)
			$config.bad_links << link if ($config.bad_links.include?(link) == false)
			return true
		elsif $config.scraped.include?(link)
			puts "Already scraped: "+link
			$config.bad_links << link if ($config.bad_links.include?(link) == false)
			return true
		else
			puts "Good Link: "+link
			return false
		end #End of `if`
	end

	def crawl
		# unless $config.to_be_scraped.empty?
		loop do
			puts "length of	progress.to_be_scraped: #{$config.to_be_scraped.length.to_s}"
			break if $config.to_be_scraped.length < 1
			puts "length of @to_be_scrapped: #{$config.to_be_scraped.length.to_s}"
			$config.to_be_scraped.each do |each_link|
				puts "*  length of @to_be_scrapped: #{$config.to_be_scraped.length.to_s}"
				puts "** length of $config.scraped: #{$config.scraped.length.to_s}"
				puts "Working on: #{each_link}"
				begin
					@driver1.get(each_link)
					#### This Code block collects New Links and cleans
					#   	$config.to_be_scraped Array.
					all_a_objs = @driver1.find_elements(:xpath, '//a')
					all_a_objs.each do |each_a_obj|
						if each_a_obj.attribute("href") != nil #Why? Cause some link obj are dicks and don't have a href
							# TODO: ^^ This if should be changed to begin - rescue
							$config.to_be_scraped << each_a_obj.attribute("href") if (each_a_obj.attribute("href").include?("http") && bad_link?(each_a_obj.attribute("href")) == false)
						end
					end #all_a_objs.each do |each_a_obj|
					$config.to_be_scraped.uniq! # Remove duplicate links.
					$config.to_be_scraped.each do |each_new_link|
						#This code block cleans the	$config.to_be_scraped Array
						$config.to_be_scraped =	$config.to_be_scraped - [each_new_link] if ($config.scraped.include?(each_new_link) || bad_link?(each_new_link))
					end 	#$config.to_be_scraped.each do |each_new_link|
					if $config.scraped.include?(each_link)
						# In case a bad link makes it into the loop
						# This code-block will skip over it.
						# It will also delte it from the	$config.to_be_scraped Array
						$config.to_be_scraped =	$config.to_be_scraped - [each_link]
						puts "Already Scrapped linked creeped in: #{each_link}"
						# next
					end

					#
					### End of Code Block to collect URL's to be scraped
					stage_uri = each_link[@test_domain_length..-1]
					prod_link = $config.prod + stage_uri
					# *****************************************
					if $cf == "scrape"
						$config.SCREEN_RESOLUTION.each do |type, res|
							name = sanitize(stage_uri)
							@driver1.manage.window.resize_to(res[0], res[1])
							@driver1.save_screenshot("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_stage.png")
						end
						@driver1.manage.window.resize_to($config.SCREEN_RESOLUTION.first[1][0], $config.SCREEN_RESOLUTION.first[1][1])
					else
						@driver2.get(prod_link)
						image_stuff(stage_uri)
					end
					# *****************************************
					$config.scraped << each_link # Last Step: Marking the URL as scraped!
					$config.scraped.uniq! # bad_link? may add duplicate entries
					$config.to_be_scraped =	$config.to_be_scraped - [nil] # This was issue when .delete() was used which resulted in element replaced by nil
					$config.to_be_scraped =	$config.to_be_scraped - [each_link]
					$config.to_be_scraped.uniq!
					File.open("#{ENV['HOME']}/DoubleTake_data/progress_#{@site}.yml", "w") {|f| f.write($config.to_yaml)}
				rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
					puts "Stale element error occured moving to next link: #{stage_uri}"
					puts e
					next
				rescue Exception => e
					puts "Generic Exception occured"
					#binding.pry
					puts e.backtrace
					next
				end #End of begin
			end 	#$config.to_be_scraped.each do |each_link|
		end # Loop do
		puts "to_be_scraped: " + $config.to_be_scraped.to_s
		puts "scraped      : " + $config.scraped.to_s
	end # Crawl Ending

	def image_stuff(stage_uri)
		name = sanitize(stage_uri)
		$config.SCREEN_RESOLUTION.each do |type, res|
			@driver1.manage.window.resize_to(res[0], res[1])
			@driver2.manage.window.resize_to(res[0], res[1])
			@driver1.save_screenshot("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_stage.png")
			@driver2.save_screenshot("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_prod.png")
			# a, b = IO.read("#{ENV['HOME']}/DoubleTake_data/desktop/stage_"+@site+"/"+name+".png")[0x10..0x18].unpack('NN')
			img1 = ImageList.new("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_stage.png")
			img2 = ImageList.new("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_prod.png")
			diff_img, diff_metric  = img1[0].compare_channel( img2[0], Magick::MeanSquaredErrorMetric )
			if diff_metric > $config.IMAGE_THRESHOLD
				diff_img.write("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/"+name+"_diff.png")
			else
				File.delete("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_stage.png")
				File.delete("#{ENV['HOME']}/DoubleTake_data/#{@site}/#{type}/#{name}_prod.png")
			end # if diff_metric > $IMAGE_THRESHOLD
		end
	end #def image_stuff(image1, image2)
end #Class Crawler < SiteContext
