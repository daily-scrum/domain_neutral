#require 'descriptor_model/symbolized_class'
module DomainNeutral
  class Descriptor < ActiveRecord::Base
    include SymbolizedClass
    include Comparable
    # Enable caching by default
    enable_caching

    belongs_to :parent, :polymorphic => true
    validates_presence_of :name, :symbol
    validates_uniqueness_of :symbol, scope: :type
  
    def <=>(other)
    	index <=> other.index
    end

    def ==(other)
    	self.class == other.class && symbol == other.symbol
    end

    def !=(other)
    	self.class == other.class && symbol != other.symbol
    end

    def to_i
      id
    end
  
    def name
      t :name
    end

    def description
      t :description
    end

  protected
    def i18n_scope
      @i18n_scope ||= [:descriptors, self.class.to_s.underscore, to_sym ]
    end

    def t(attribute)
      I18n.t( attribute, scope: i18n_scope, default: self[attribute] || '') # || '' here is used to fix validation
    end
  end
end
