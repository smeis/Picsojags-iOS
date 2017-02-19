namespace :setup do

  desc "Copy configuration files"
  task :copy_configs do
    # Check if config already exists
    if !File.file?('./Config/PhotoServices.plist')
      puts "Creating PhotoServices.plist"
      FileUtils.cp('./Config/PhotoServices-sample.plist', './Config/PhotoServices.plist')
    end
  end

  desc "Copy all files"
  task :copy_all => [:copy_configs] do
    puts "=== Configs Copied ==="
  end

  desc "Install gems"
  task :install_gems do
    sh "bundle install"
  end

  desc "Install pods"
  task :install_pods do
    sh "bundle exec pod install"
  end

  desc "Install required tools"
  task :install_all => [:install_gems, :install_pods] do
    puts "=== Tools Installed ==="
  end

  task

  desc "Run all setup tasks"
  task :setup_all => [:copy_all, :install_all] do
    puts "=== Setup Complete ==="
  end

end

namespace :testing do

  desc "Run the iOS binary"
  task :test_binary do
    sh "xcodebuild -workspace Picsojags.xcworkspace -scheme Picsojags -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7' test"
  end

  desc "Run all tests"
  task :test_all => [:test_binary] do
    puts "=== Testing Complete ==="
  end

end

task :test => 'testing:test_all'
task :setup => 'setup:setup_all'
task :default => :test
