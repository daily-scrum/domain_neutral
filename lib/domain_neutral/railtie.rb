require "rails"

module DomainNeutral
  # = Domain Neutral Railtie
  class Railtie < Rails::Railtie
    config.domain_neutral = ActiveSupport::OrderedOptions.new
    config.domain_neutral.seed = ActiveSupport::OrderedOptions.new
    
    
    config.domain_neutral.table_prefix = 'domain_neutral' # Table prefix
    config.domain_neutral.seed.master_locale = :en        # Default master data locale. Language used for seeding
    config.domain_neutral.seed.locale_alternatives = []   # Alternative locale data. These will be parsed and checked for consistency with the master
    config.domain_neutral.seed.verbose = true             # Display progress when seeding
    
    initializer 'domain_neutral.configure' do |app|
      DomainNeutral::Descriptor.table_name = app.config.domain_neutral.table_prefix.blank? ? 
        'descriptors' : "#{app.config.domain_neutral.prefix}_#{table_name}"
      DomainNeutral.seed_options = config.domain_neutral.seed
    end
  end
end