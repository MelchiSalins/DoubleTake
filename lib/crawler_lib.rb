require 'config.rb'
require 'uri'
require 'selenium-webdriver'

module CrawlerHelper
	def test
		puts "Test call"
	end

	def fix_scheme(url)
		puts "- No scheme provided for #{url}, trying to fix it."
		driver = Selenium::WebDriver.for :firefox
		driver.get("http://"+url) #assumes redirect to https is setup if it exists.
		url_tmp = driver.current_url
		scheme = URI.parse(url_tmp).scheme
		driver.quit
		puts "scheme is: #{scheme}"
		return scheme+"://"+url
	end


	def sanitize(link)
		# puts link
		name = link.gsub(":", "")
		name = name.gsub("/", "")
		name = name.gsub("%", "")
		name = name.gsub('\\', "")
		name = name.gsub('.', "")
		# puts name
		return name
	end
	#
	# def bad_link?(each_link)
	# 	# return True if these characters exists in
	# 	# the URL: $, #, png, css, js, jpg, pdf
	# 	# Check for both upper and lower case ^
	# 	begin
	# 		each = each_link.upcase
	# 		if each.include?("?") || each.include?("#") || each.include?(".PNG") || each.include?(".CSS") || each.include?("JS") || each.include?("JPG") || each.include?("PDF") || each.include?("/VIDEO/POP")
	# 				# puts "Bad Link: " + each.to_s
	# 				return true
	# 		else
	# 			return false
	# 		end
	# 	rescue Exception => e
	# 		puts e.message
  # 			puts e.backtrace.inspect
  # 		end
	#
	# end

	def do_not_ignore?(each_link, scraped)
		# This checks if the passed link should be
		# scraped or not based on:
		# Has it already been scraped, is it bad_link?
		# puts each_link
		# puts scraped.class
		if scraped.include?(each_link)
			return false
		elsif bad_link?(each_link)
			return false
		else
			return true
		end
	end
end
