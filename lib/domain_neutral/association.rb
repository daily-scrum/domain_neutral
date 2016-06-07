module DomainNeutral
  module Association
    extend ActiveSupport::Concern
    
    # included do
    # end

    module Finder
      
    end

    module ClassMethods
      def has_descriptor(name, options = {})
        # TODO: add delegate method
        belongs_to name #, ->{ extending DomainNeutral::Association::Finder}, options 
      end
      
      # def descriptors(*associations)
      #   associations.each do |association|
      #     descriptor association
      #   end
      # end
    end
  end
end
class ActiveRecord::Base
  include DomainNeutral::Association
end