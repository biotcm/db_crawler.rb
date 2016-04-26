desc 'Prepare the environment'
task :prepare do
  system('gem install bundler -qN') if `gem list "^bundler$" -q`.chomp.empty?
  system('bundle install --quiet')
end
