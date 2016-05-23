#!/usr/bin/env ruby
require 'watir'
require 'watir-webdriver'

# Make the working directory
Dir.mkdir('crawled') unless Dir.exist?('crawled')

# Start crawling
browser = Watir::Browser.new
browser.goto 'http://operons.ibt.unam.mx/OperonPredictor/svlByOrganism?sInitialOrg=ALL&sTypeOperon=allOperon&iOption=2'
(0...browser.links(class: 'enlace').size).each do |index|
  # Reset the state
  browser.windows.first.use
  browser.goto 'http://operons.ibt.unam.mx/OperonPredictor/svlByOrganism?sInitialOrg=ALL&sTypeOperon=allOperon&iOption=2'

  # Find the link
  link = browser.links(class: 'enlace')[index]
  filename = link.text
  next if File.exist?("crawled/#{filename}.txt")

  # Open the link
  link.click
  button = browser.input(value: 'Download this data')
  button.wait_until_present
  button.click

  # Download the entry
  popup = browser.windows.last
  popup.use
  browser.ready_state
  File.open("crawled/#{filename}.txt", 'w').puts browser.html
  popup.close
end

# Close the browser
browser.close
