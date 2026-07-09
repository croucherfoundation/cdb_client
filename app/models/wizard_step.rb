class WizardStep
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/wizard_steps"

  include_root_in_json true
  parse_root_in_json false

  belongs_to :wizard_progress
end
