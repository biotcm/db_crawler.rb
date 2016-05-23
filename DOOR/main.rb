#!/usr/bin/env ruby
require 'watir'
require 'watir-webdriver'
require 'net/http'
require 'ruby-progressbar'

# Make the working directory
Dir.mkdir('crawled') unless Dir.exist?('crawled')

# Fetch the list
unless File.exist?('urls.txt')
  browser = Watir::Browser.new
  browser.goto 'http://csbl.bmb.uga.edu/DOOR/displayspecies.php'
  browser.wait_until { browser.a(text: '1').exist? }
  browser.select(name: 'spe_table_length').select('All')

  fout = File.open('urls.txt', 'w')
  browser.links.each do |link|
    next unless link.text =~ /^NC/
    fout.puts link.href
  end
  fout.close
  browser.close
end

# Download directly
urls = File.readlines('urls.txt').map(&:chomp)
progressbar = ProgressBar.create(starting_at: 0, total: urls.size, format: '%t: |%B| %a %e')
urls.each do |url|
  progressbar.increment

  /id=(?<id>\d+)/ =~ url
  next if File.exist?("crawled/#{id}.txt")

  res = Net::HTTP.get_response(URI(
    "http://csbl.bmb.uga.edu/DOOR/downloadNCoperon.php?NC_id=#{id}"
  ))

  if res.is_a?(Net::HTTPOK)
    File.open("crawled/#{id}.txt", 'w').puts res.body
  end
end
