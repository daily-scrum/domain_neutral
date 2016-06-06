require 'domain_neutral/seeder/descriptors'
module DomainNeutral
  class Seed
    def descriptors(callee)
      Seeder::Descriptors.seed(callee)
    end
  end
end
