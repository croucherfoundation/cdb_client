# require 'concerns/has_award'
# require 'concerns/has_country'
# require 'concerns/has_grant'
# require 'concerns/has_institution'
# require 'concerns/has_tags'
# require 'concerns/hk_names'

module CdbClient
  class Engine < ::Rails::Engine
    isolate_namespace CdbClient

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    initializer :cdb_client_helper do |app|
      ActiveSupport.on_load :action_controller do
        helper CdbClientHelper
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
