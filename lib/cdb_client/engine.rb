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

    initializer :cdb_client_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

  end
end
