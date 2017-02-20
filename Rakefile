@@company = "Danger Cove"

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

namespace :documentation do

  desc "Clean old documentation"
  task :docs_clean do
    puts("Blah #{@@company}")
  end

  desc "Generate documentation"
  task :docs_generate do
    sh "bundle exec jazzy -x -workspace,Picsojags.xcworkspace,-scheme,Picsojags --clean --author 'Danger Cove' --author_url https://www.dangercove.com --output Docs/ --theme fullwidth --min-acl private --exclude ./Pods"
  end

  desc "Run all documentation tasks"
  task :docs_all => [:docs_clean, :docs_generate] do
    puts "=== Documentation Complete ==="
  end

end

task :test => 'testing:test_all'
task :setup => 'setup:setup_all'
task :docs => 'documentation:docs_all'
task :default => :test
