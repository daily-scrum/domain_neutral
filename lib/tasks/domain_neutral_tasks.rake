namespace :domain_neutral do
  namespace :seed do
    desc 'Seed descriptors directly without migration'
    task :descriptors => :environment do
      require 'domain_neutral/seeder/descriptors'
      DomainNeutral::Seeder::Descriptors.seed self 
    end
  end
end

