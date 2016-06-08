#!/usr/bin/env ruby
require 'biotcm'
require 'json'
require 'pathname'
require 'ruby-progressbar'

BASE_URL = 'http://amp.pharm.mssm.edu/Harmonizome'.freeze
DATA_DIR = 'results'.freeze

Dir.mkdir(DATA_DIR) unless Dir.exist?(DATA_DIR)

[
  'Achilles Cell Line Gene Essentiality Profiles'
].each do |dataset_name|
  puts "Start to download dataset: #{dataset_name}"

  data_dir =  Pathname.new(DATA_DIR).join(dataset_name)
  Dir.mkdir(data_dir) unless Dir.exist?(data_dir)

  dataset = JSON.parse(BioTCM.curl(BASE_URL + "/api/1.0/dataset/#{dataset_name.tr(' ', '+')}"))
  progressbar = ProgressBar.create(starting_at: 0, total: dataset['geneSets'].size, format: '%t: |%B| %a %e')

  dataset['geneSets'].each do |gene_set|
    gene_set = JSON.parse(BioTCM.curl(BASE_URL + gene_set['href']))

    filename = data_dir.join(gene_set['attribute']['name'] + '.json')
    File.open(filename, 'w').puts JSON.pretty_generate(gene_set) unless File.exist?(filename)

    progressbar.increment
  end
end
