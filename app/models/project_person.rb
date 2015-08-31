class ProjectPerson
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/project_people"

  belongs_to :project
  belongs_to :person, foreign_key: :person_uid
  accepts_nested_attributes_for :person
  sends_nested_attributes_for :person

  # temporary while we are not yet sending jsonapi data back to core properly
  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    new({
      person_uid: "",
      project_id: nil,
      position: 0,
      role: "",
      notes: "",
      person: Person.new_with_defaults
    }.merge(attributes))
  end

  def self.roles
    get_raw(:roles) do |parsed_data, response|
      parsed_data[:data]
    end
  end

end
