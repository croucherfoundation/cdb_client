class Contract
  include Her::JsonApi::Model

  use_api CDB
  collection_path "/api/contracts"

  include_root_in_json true
  parse_root_in_json false

  def self.new_with_defaults(attributes={})
    Contract.new({
      name: nil,
      record_code: nil,
      description: nil,
      notes: nil,
      approved_at: nil,
      approved_by_uid: nil,
      issued_by_uid: nil,
      csw_partner_id: nil,
      round_id: nil,
    }.merge(attributes))
  end

  def approved?
    approved_at.present?
  end

  def approve(user=nil)
    self.approved_at ||= Time.now
    self.approved_by_uid ||= user.uid if user
  end

  def approve!(user=nil)
    self.approve
    self.save!
  end

  def issued?
    issued_at.present?
  end

  def issue(user=nil)
    self.issued_at ||= Time.now
    self.issued_by_uid ||= user.uid if user
  end

  def issue!(user=nil)
    self.issue(user)
    self.save
  end

end
