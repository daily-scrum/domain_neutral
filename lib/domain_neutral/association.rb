module DomainNeutral
  module Association
    extend ActiveSupport::Concern
    
    module ClassMethods
      def descriptor(name, options = {})
        belongs_to name 
      end
      
      def descriptors(*associations)
        associations.each do |association|
          descriptor association
        end
      end
    end
  end
end