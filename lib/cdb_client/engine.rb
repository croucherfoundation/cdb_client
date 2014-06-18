require 'concerns/has_award'
require 'concerns/has_country'
require 'concerns/has_grant'
require 'concerns/has_institution'
require 'concerns/hk_names'

module CdbClient
  class Engine < ::Rails::Engine

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
    
    initializer "cdb_client.integration" do
      ActiveSupport.on_load :action_controller do
        helper CdbClientHelper
      end
    end

  end
end
