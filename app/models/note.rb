class Note < ActiveResource::Base
  include FormatApiResponse
  include CdbActiveResourceConfig

  belongs_to :person, foreign_key: :person_uid

  def save
    self.prefix_options[:note] = self.attributes
    super
  end

  def self.new_with_defaults(attributes={})
    self.new({
      title: "",
      text: ""
    }.merge(attributes))
  end

  def date
    DateTime.parse(created_at)
  end

end
