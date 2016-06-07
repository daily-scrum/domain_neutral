require 'domain_neutral/symbolized_class'
require "domain_neutral/engine"
require 'domain_neutral/railtie' if defined?(Rails)
require 'domain_neutral/association'
module DomainNeutral
  mattr_accessor :seed_options
  # Identifies the Rails generation version
  # Rails.version "4.2.1"
  # => 4
  def self.rails_generation
    @@__generation ||= Rails.version.split('.')[0].to_i
  end
  
  def self.seed
    require 'domain_neutral/seed'
    Seed.new
  end
end
