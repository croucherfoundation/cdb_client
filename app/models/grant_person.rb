class GrantPerson
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/grant_people"

  belongs_to :grant
  belongs_to :person, foreign_key: :person_uid
  
  def self.new_with_defaults(attributes={})
    new({
      position: 0,
      role: "",
      applicant: false,
      notes: "",
      person_uid: "",
      person: Person.new_with_defaults
    }.merge(attributes))
  end

  def self.roles
    get_raw(:roles) do |parsed_data, response|
      parsed_data[:data]
    end
  end

end
