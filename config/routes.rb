CdbClient::Engine.routes.draw do 

  # Institution-pickers are repopulated when a country is chosen.
  get "/institutions/:country_code" => "institutions#index", :as => 'country_institutions', :defaults => {:format => :json}

  # Grant-people is a nested has_many to which we might want to add new items
  get "/grant_people/new" => "grant_people#new", :as => 'new_grant_person', :defaults => {:format => :html}

end
