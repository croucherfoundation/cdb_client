class ProjectPerson
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/project_people"

  belongs_to :project
  belongs_to :person, foreign_key: :person_uid
  accepts_nested_attributes_for :person
  sends_nested_attributes_for :person
  
  def self.new_with_defaults(attributes={})
    new({
      person_uid: "",
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
