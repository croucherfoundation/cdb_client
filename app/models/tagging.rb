# == Schema Information
#
# Table name: taggings
#
#  id               :integer          not null, primary key
#  taggee_type      :string(255)
#  taggee_id        :integer(255)
#  tag_id           :integer(255)
#  created_at       :datetime
#  updated_at       :datetime
#
class Tagging < ActiveRecord::Base
  belongs_to :taggee, polymorphic: true

  scope :of, -> klass {
    where(taggee_type: klass.to_s)
  }

  # we don't really want to retrieve tags one at a time,
  # but here you go.
  #
  def tag
    Tag.find(tag_id)
  end

end
