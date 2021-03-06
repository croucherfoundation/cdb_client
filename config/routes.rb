CdbClient::Engine.routes.draw do 

  # Person pickers offers links to existing person records when they seem to match
  get "/people/suggestions" => "people#suggest", :as => 'people_suggestions', :defaults => {:format => :json}

  # Institution-pickers are repopulated when a country is chosen.
  get "/institutions/:country_code" => "institutions#index", :as => 'country_institutions', :defaults => {:format => :json}

end
