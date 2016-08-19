# frozen_string_literal: true
require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
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
