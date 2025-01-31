module CdbClient
  class Engine < ::Rails::Engine
    isolate_namespace CdbClient

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/helpers/*_helper.rb").each do |c|
        require_dependency(c)
      end
    end

    config.to_prepare do
      Dir.glob(Rails.root.join("db/migrate/*.rb")).each do |migration|
        require_dependency migration
      end
    end

  end
end
