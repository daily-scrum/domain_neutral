module DomainNeutral
  module SymbolizedClass
    # = Domain Neutral SymbolizedClass
    #
    # This mudule implements two important features:
    # * access (finding) to objects, using a symbol
    # * cache of objects that imcludes this module, if enabled
    #
    # A requirement for including this module is that the class has an attribute named symbol.
    #
    # Usage:
    #
    #     class MySymbolizedClass < ActiveRecord::Base
    #       include DomainNeutral::SymbolizedClass
    #       ...
    #     end
    
    
    extend ActiveSupport::Concern
    
    included do
      class_attribute :caching_enabled
      after_save :flush_cache, if: :caching_enabled
    end

    module ClassMethods
      # Access descriptor by symbol, e.g.
      #
      #   Role[:manager]
      #   => Manager role
      #   Same as Role.where(symbol: :manager).first
      def [](symbol)
        find_by_symbol(symbol)
      end

      # Access like Role.manager
      #
      #   Role.manager
      #   => Manager role
      #   Same as Role.where(symbol: :manager).first
      def method_missing(method, *args)
        begin
          if method != :find_by_symbol
            if obj = find_by_symbol(method)
              redefine_method method do
                find_by_symbol(method)
              end
              return obj
            end
          end
        rescue
          # Ignore errors, and call super
        end
        super
      end

      # Overrides find by using cache.
      # The key in cache is [class_name, id] or ':class_name/:id', e.g. 'Role/1'
      def find(id)
        if caching_enabled
          Rails.cache.fetch([name, id]) { super }
        else
          super
        end
      end
      
      # Find object by symbol
      #
      # See also
      #   Descriptor[:symbol]
      #   Descriptor.symbol
      def find_by_symbol(symbol)
        if caching_enabled
          Rails.cache.fetch([name, symbol.to_s]) do
            where(symbol: symbol).first
          end
        else
          where(symbol: symbol).first
        end
      end

      # Role.collection(:site_admin, :user_admin, :admin)
      # => Role[] consisting of Role.site_admin, Role.user_admin, Role.admin
      def collection(*syms)
        syms.flatten.map { |s| self[s] }
      end
  

      # Turn cache on or off
      # Calling enable_caching without parameter or true will turn on caching
      # By default cache is off. 
      #
      # Example - enabling caching
      #     class MySymbolizedClass < ActiveRecord::Base
      #       include DomainNeutral::SymbolizedClass
      #       enable_caching
      #       ...
      #     end
      #
      # Example - disable caching
      #     class MySymbolizedClass < ActiveRecord::Base
      #       include DomainNeutral::SymbolizedClass
      #       enable_caching false
      #       ...
      #     end
      
      def enable_caching(*args)
        self.caching_enabled = args.size > 0 ? args.first : true
      end
    end

    # Store symbol
    def symbol=(name)
      write_attribute(:symbol, name.to_s)
    end

    # Retrieve symbol
    def symbol
      @symbol ||= begin
        s = read_attribute(:symbol)
        s && s.to_sym
      end
    end

    def to_sym
      symbol
    end

    # Role.admin.is_one_of?(:admin, :site_admin)
    # => true
    # Role.admin.is_one_of?(:site_admin, :user_admin)
    # => false
    def is_one_of?(*syms)
      syms.flatten.include?(to_sym)
    end
  
    # Role.admin.is_none_of?(:site_admin, :user_admin)
    # => true
    # Role.admin.is_none_of?(:admin, :site_admin)
    # => false
    def is_none_of?(*syms)
      !syms.flatten.include?(to_sym)
    end  

    # Allow to test for a specific role or similar like Role.accountant?
    def method_missing(method, *args)
      if method.to_s =~ /^(\w+)\?$/
        v = self.class.find_by_symbol($1)
        raise NameError unless v
        other = v.to_sym
        self.class.class_eval { define_method(method) { self.to_sym == other }}
        return self.to_sym == other
      end
      super
    end

    def respond_to?(meth, include_private = false) # :nodoc
      if m = /^(\w+)\?$/.match(meth.to_s)
        return true if self.to_sym == m[1].to_sym
      end
      super
    end
    
    # Flushes cache if record is saved
    def flush_cache
      Rails.cache.delete([self.class.name, symbol_was.to_s])
      Rails.cache.delete([self.class.name, id])
    end
  end
end