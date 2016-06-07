module DomainNeutral
  module Association
    extend ActiveSupport::Concern
    
    module ClassMethods
      def has_descriptor(name, options = {})
        # TODO: add delegate method
        belongs_to name, options
        r = reflect_on_association(name)
        class_eval <<-CODE, __FILE__, __LINE__
          def #{name}
            #{r.foreign_key} && #{r.klass}.find(#{r.foreign_key})
          end
        CODE
      end
    end
  end
end
class ActiveRecord::Base
  include DomainNeutral::Association
end