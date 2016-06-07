# DescriptorModel

Model framework for domain neutral classes, such as Descriptor which is fundamental for every database to describe characteristics of an object.
Example of descriptors:
  * Role
  * State or Status
  * Account
  
The above are entities that seldom change, and therefore should be accessible in a faster way than being looked up from database on every request.

Benefits:
  * Stores descriptors in cache.
  * Supports association declaration (`has_descriptor`) that takes advantage of using the cache.

# Installation

  gem 'domain_neutral'

  then bundle
  
Once bundled, you can install and run the migration:

```
$ rake domain_neutral:install:migrations
$ rake db:migrate
```

Create your models, and locale file(s). See further down- 

# Usage


## Implementing a descending model

The following example is used for associating a role to a user.

The role model:
```ruby
class Role < DomainNeutral::Descriptor
end
```
See [Seeding](#Seeding) for seeding of data

```ruby
class User < ActiveRecord::Base
  has_descriptor :role
end
```

To assign a role to a user, there are some alternatives. Examples:

```ruby
user.role = Role[:project_manager]
user.role = Role.project_manager
```

If you want to know if a user has a particular role, you can just ask for it.

```ruby
user.role.project_manager?
```

The above 2 examples are implemented as a part of the SymbolizedClass module that the DomainNeutral gem exposes.
There are other methods as well, such as `collection`, `is_one_of?` and `is_none_of?`
See [SymbolizedClass](lib/domain_neutral/symbolized_class.rb) for details.


If you have defined the `index` attribute for the descriptor, you may also compare them:

```ruby
if user.role < Role.project_manager
  raise AccessDenied, "You are not authorized to access this..."
end
```

## Migrating new model

In practice you will not need to migrate new models as they are descendant of the `DomainNeutral::Descriptor` class.
However, to add new descriptors, you will need to define the descriptor class, and as a minimum, add the descriptions to the locale file.
Once the descriptions are added to the locale file, you can seed the data through a migration.

### Seeding

Create a migration, such as:
```
rails g migration add_role_descriptors
```

Then seed from the migration file:
```ruby
class CreateDescriptors < ActiveRecord::Migration
  def change
    DomainNeutral.seed.descriptors(self)
  end
end
```

Note: If you want to delete descriptor records, `DomainNeutral.seed.descriptors` will not remove these records.

# Localization

The attributes enlisted for translation are:
*  name
*  descriptioon

All attributes, including the above are used for seeding
  parent
  index
  value
  
Structure
```yaml
  <language>:
    descriptors:
      <model>:
        [parent: <default parent for objects>]
        <symbol>:
          <attributes>    

Example:

```yaml
  en:
    descriptors:
      status:
        not_started:
          name: Not started
          index: 1
          description: 'The task has not yet started'
        in_progress:
          name: In Progress
          index: 2
          description: 'The task is in progress'
      role/group:
        organization:
          name: Organization
        project:
          name: Project
        team:
          name: Team
      project/role:
        parent: Role::Group.project
        project_manager:
          name: Project Manager
      organization/role:
        department_manager:
          parent: Role::Group.organization
          name: Department Manager
 ```

# Caching

By default caching is turned on. You may switch off caching globally by setting cache off in the application.rb file:
```ruby
config.domain_neutral.cache = false
```
It is recommended to switch off cache in test.
See [SymbolizedClass](lib/domain_neutral/symbolized_class.rb) for details on how caching is done.

# Configuration
  
Configuration is done in application.rb and/or respective environment files.

Default values:

```ruby
config.domain_neutral.table_prefix = 'domain_neutral' # Table prefix
config.domain_neutral.cache = true                    # Use cache
config.domain_neutral.seed.master_locale = :en        # Default master data locale. Language used for seeding
config.domain_neutral.seed.locale_alternatives = []   # Alternative locale data. These will be parsed and checked for consistency with the master
config.domain_neutral.seed.verbose = true             # Display progress when seeding
config.domain_neutral.seed.create_fixtures = true     # Create fixtures from master file
```

Extending the Descriptor class. Add the changes to a initializer file. Example:
```ruby
class DomainNeutral::Descriptor
  def to_heading
    {symbol => name}
  end
end
```

   
  

# License

This project uses [MIT-LICENSE](MIT-LICENSE).