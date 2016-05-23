#!/usr/bin/env ruby
require 'biotcm'
require 'ruby-progressbar'
require 'yaml'
BioTCM.logger.level = Logger::ERROR

# Make the working directory
Dir.mkdir('crawled') unless Dir.exist?('crawled')

# Load mim2gene
if File.exist?('crawled/mim2gene.txt')
  mim2gene = BioTCM::Table.load('crawled/mim2gene.txt')
else
  mim2gene = BioTCM.curl('http://omim.org/static/omim/data/mim2gene.txt').to_table
  mim2gene.save('crawled/mim2gene.txt')
end

# Download materials
progressbar = ProgressBar.create(starting_at: 0, total: mim2gene.row_keys.size, format: '%t: |%B| %a %e')
mim2gene.row_keys.each do |mim|
  progressbar.increment

  next unless mim2gene.row(mim).first.last == 'phenotype'
  next if File.exist?("crawled/#{mim}.yaml")
  puts "Downloading #{mim} ..."

  content = BioTCM::Databases::OMIM.new(mim).instance_variable_get(:@content)
  File.open("crawled/#{mim}.yaml", 'w').puts YAML.dump(content)
end
