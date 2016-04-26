desc 'Prepare the environment'
task :prepare do
  system('gem install bundler -qN') if `gem list "^bundler$" -q`.chomp.empty?
  system('bundle install --quiet')
end

desc 'Run main script'
task :run do
  system('ruby main.rb')
end

task default: [:prepare, :run]
