class WizardProgress
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/wizard_progresses"

  include_root_in_json true
  parse_root_in_json false

  has_many :wizard_steps

  class << self
    def for_resource(resource_type:, resource_id:, wizard_type: nil)
      params = { resource_type: resource_type, resource_id: resource_id }
      params[:wizard_type] = wizard_type if wizard_type.present?
      where(params)
    end

    def initialize_for_event(event_id:)
      post("/api/wizard_progresses/initialize_for_event", { event_id: event_id })
    end
  end
end
