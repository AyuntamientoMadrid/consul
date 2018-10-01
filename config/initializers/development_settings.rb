# Allows local settings, such as loading custom gems without editing the Gemfile.
# In order to use it, add the following contents to config/development_settings.rb
# (based on pry-debundle):
#
# # Based on https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
# if defined?(Bundler)
#   Gem.post_reset_hooks.reject!{ |hook| hook.source_location.first =~ %r{/bundler/} }
#   Gem::Specification.reset
#   load "rubygems/core_ext/kernel_require.rb"
#
#   def gem(gem_name, *requirements) # :doc:
#     skip_list = (ENV['GEM_SKIP'] || "").split(/:/)
#     raise Gem::LoadError, "skipping #{gem_name}" if skip_list.include? gem_name
#     spec = Gem::Dependency.new(gem_name, *requirements).to_spec
#     spec.activate if spec
#   end
# end
#
# Then, add your custom development requirements to that file. For example:
# require "pry"
# require "byebug"
#
if Rails.env.development? || Rails.env.test?
  development_settings = Rails.root.join 'config', 'development_settings.rb'
  if File.exists? development_settings
    load development_settings
  end
end
