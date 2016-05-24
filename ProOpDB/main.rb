#!/usr/bin/env ruby
require 'watir'
require 'watir-webdriver'
require 'ruby-progressbar'

# Make the working directory
Dir.mkdir('crawled') unless Dir.exist?('crawled')

# Start crawling
browser = Watir::Browser.new
browser.goto 'http://operons.ibt.unam.mx/OperonPredictor/svlByOrganism?sInitialOrg=ALL&sTypeOperon=allOperon&iOption=2'

unless File.exist?('scripts.txt')
  fout = File.open('scripts.txt', 'w')
  browser.links(class: 'enlace').map { |link| fout.puts link.href }
  fout.close
end

scripts = File.readlines('scripts.txt').map(&:chomp)
progressbar = ProgressBar.create(starting_at: 0, total: scripts.size, format: '%t: |%B| %a %e')
scripts.each do |script|
  progressbar.increment

  script = script.gsub(/javascript:/, '')
  /getOrganism\('(?<id>\w+)/ =~ script
  next if File.exist?("crawled/#{id}.txt")

  # Open the link
  browser.execute_script(script)
  button = browser.input(value: 'Download this data')
  button.wait_until_present(60)
  button.click

  # Download the entry
  popup = browser.windows.last
  popup.use
  browser.ready_state
  File.open("crawled/#{id}.txt", 'w').puts browser.html
  popup.close

  # Reset the state
  browser.windows.first.use
  browser.goto 'http://operons.ibt.unam.mx/OperonPredictor/svlByOrganism?sInitialOrg=ALL&sTypeOperon=allOperon&iOption=2'
end

# Close the browser
browser.close
