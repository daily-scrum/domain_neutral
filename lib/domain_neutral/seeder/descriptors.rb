# Seeds descriptors from yml file, using norwegian as default
module DomainNeutral
  module Seeder
    class Descriptors      
      def self.seed(context)
        seeder = new(context)
        seeder.setup
        seeder.load_master_data
        seeder.validate_master
        seeder.validate_locale_alternatives
        seeder.create_fixtures_file
        seeder.seed_parents
        seeder.seed_everything_else
      end
      
      def initialize(context)
        @context = context
      end
      
      def seed_options
        DomainNeutral.seed_options
      end
      
      delegate :verbose, :master_locale, :locale_alternatives, :create_fixtures, to: :seed_options
      
      def setup
        if DomainNeutral.rails_generation < 4
          Descriptor.attr_accessible :name, :description, :index, :externalid, :parent, :value
        end
        Descriptor.enable_caching false
      end
      
      attr_reader :master
      
      # Load master descriptors from yaml file
      def load_master_data
        #@master = load_yaml(DomainNeutral.master_locale, :master)
        @master = load_yaml(master_locale, :master)
      end
      
      def seed_parents
        # Collect parents
        log "Collect parents"
        parents = []
        master.each do |descriptor_set, descriptors|
          parents << descriptors[:parent] if descriptors[:parent]
        end
        log "Parents collected: #{parents.inspect}"
        # Seed parents
        return if parents.empty?
        log "Seed parents"
        parents.map { |p| p.split('.')[0].underscore }.uniq.each do |parent|
          klass = parent.classify.constantize
          # Create only objects of Descriptor class
          if klass.new.is_a?( Descriptor) && section = master.delete(parent)
            seed_descriptor_set parent, section
          end
        end
      end
      
      def seed_everything_else
        # seed rest
        master.each do |descriptor_set, descriptors|
          seed_descriptor_set descriptor_set, descriptors
        end
      end
      
      # Validate descriptors in master yaml file
      def validate_master
        log 'Validating master locale file'
        undefined = []
        master.each do |descriptor_set, descriptors|
          descriptors.reject { |k,v| k == 'parent'  }.each do |symbol, descriptor|
            unless descriptor[:name]
              undefined << "Name not defined for #{descriptor_set}"
            end    
          end
        end
        abort undefined if undefined.size > 0
      end
      
      def validate_locale_alternatives
        undefined = []
        #DomainNeutral.locale_alternatives.each do |locale|
        locale_alternatives.each do |locale|
          log "Validating alternative locale file: #{locale}"
          loc_descriptors = load_yaml(locale, 'locale_alternative')
          master.each do |descriptor_set, descriptors|
            unless loc_descriptors[descriptor_set]
              undefined << "Locale: #{locale}. Keys not defined for '#{descriptor_set}'"
              next      
            end
            descriptors.keys.reject{ |k| k == 'parent' }.each do |descriptor|
              unless loc_descriptors[descriptor_set][descriptor]
                undefined << "Locale: #{locale}. Key not defined for '#{descriptor}' in '#{descriptor_set}'" 
                next      
              end
              %w(name description).each do |key|
                if descriptors[descriptor][key] && !loc_descriptors[descriptor_set][descriptor][key]
                  undefined << "Locale: #{locale}. Attribute '#{key}' not defined for '#{descriptor}' in '#{descriptor_set}'"
                end
              end
            end
          end
        end
        abort undefined if undefined.size > 0
      end
      
      def create_fixtures_file
        return unless create_fixtures
        fixtures = {}
        master.each do |descriptor_set, descriptors|
          base = {type: descriptor_set.classify}
          if parent = descriptors[:parent]
            abort "Parent for fixtures not yet implemented.", descriptors.inspect
            base[:parent] = parent
          end
          descriptors.reject { |k,v| k == 'parent'  }.each do |symbol, descriptor|
            fixtures["#{descriptor_set}_#{symbol}"] = descriptor.merge(base.merge(symbol: symbol)).to_hash
          end
        end
        path = fixtures_path.join('domain_neutral', 'descriptors.yml')
        FileUtils.mkdir_p path.dirname
        File.open(path, 'w') do |f|
          f.write fixtures.to_yaml
        end
        log "Seeders file created (#{path}):"
      end
      
    private
      def load_yaml(locale, type)
        file = locate_locale_file(locale, type)
        yml = HashWithIndifferentAccess.new YAML.load_file(file.to_s)
        yml[locale.to_sym][:descriptors]
      end
      
      def locate_locale_file(locale, type)
        alternative_locations = [
          Rails.root.join('config', 'locales', locale.to_s, "descriptors.yml"),
          Rails.root.join('config', 'locales', "#{locale}.descriptors.yml"),
          Rails.root.join('config', 'locales', "#{locale}.yml"),
          Rails.root.join('config', 'locales', "descriptors.yml")
        ]
        unless file = alternative_locations.select { |fname| fname.exist? }.first
          abort "Could not load #{type} file for descriptors. Expected to find any of the following files:\n" + 
            alternative_locations.map { |fname| "\t'#{fname}'" }.join("\n")
        end
        file
      end

      def seed_descriptor_set(descriptor_set, descriptors, default_parent = nil)
        log "seed_descriptor_set: #{descriptor_set.inspect}, descriptors: #{descriptors.inspect}"
        klass = descriptor_set.classify.constantize
        default_parent = descriptors.delete('parent')
        descriptors.each do |descriptor, keypairs|
          log "descriptor: #{descriptor.inspect}, keypairs: #{keypairs.inspect}"
          parent = keypairs['parent'] || default_parent || 'nil'
          unless object = klass[descriptor]
            if DomainNeutral.rails_generation < 4
              klass.create! keypairs.merge(symbol: descriptor, parent: eval(parent)), without_protection: true
            else
              klass.create! keypairs.merge(symbol: descriptor, parent: eval(parent))
            end
          else
            if DomainNeutral.rails_generation < 4
              object.update_attributes(keypairs.merge(parent: eval(parent)), without_protection: true)
            else
              object.update_attributes(keypairs.merge(parent: eval(parent)))
            end
          end
        end
      end
      
      def fixtures_path
        if ENV['FIXTURES_PATH']
          Rails.root.join(ENV['FIXTURES_PATH'])
        else
          Rails.root.join('test', 'fixtures')
        end
      end
      def abort(*messages)
        raise "#{self.class.name}: #{messages.join("\n")}"
      end
      
      def log(message)
        # @context.say message if DomainNeutral.verbose_seed
        if verbose
          @messenger ||= @context.is_a?( ActiveRecord::Migration) ? :say : :puts
          @context.send @messenger,  message
        end
      end
      
    end
  end
end
