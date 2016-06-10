module DomainNeutral
  class Engine < ::Rails::Engine
    isolate_namespace DomainNeutral
    paths['app/models'].autoload_once! # Ensure we do not loose table_name definition in development environment if overridden
  end
end
