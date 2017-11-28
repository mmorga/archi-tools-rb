# frozen_string_literal: false

require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :test do
  desc "Run only integration tests."
  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList['test/integration/**/*_test.rb']
  end

  desc "Run tests and report slowest tests."
  Rake::TestTask.new(:profile) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.options = "--profile"
    t.test_files = FileList['test/**/*_test.rb']
  end
end

YARD::Rake::YardocTask.new do |t|
  t.options += ['--title', "YARD #{YARD::VERSION} Documentation"]
end

namespace :yard do
  desc "List all undocumented methods and classes."
  task :undocumented do
    command = 'yard --list --query '
    command << '"object.docstring.blank? && '
    command << '!(object.type == :method && object.is_alias?)"'
    sh command
  end
end

desc "Generate documentation incrementally"
task(:redoc) { sh "yard -c" }

task default: :test
