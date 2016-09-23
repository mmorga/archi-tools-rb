# frozen_string_literal: true
## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}
ENV['TEST_ENV'] = 'guard'

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

guard :minitest, all_after_pass: true do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}#{m[2]}_test.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
  watch(%r{^lib/archimate/autoload.rb$}) { 'test' }
  watch(%r{^lib/archimate.rb$}) { 'test' }
end

notification :gntp

guard 'ctags-bundler', src_path: %w(lib test), stdlib: true do
  watch(%r{^(lib|test)/.*\.rb$})
  watch('Gemfile.lock')
end
