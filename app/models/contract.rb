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
      year: nil,
    }.merge(attributes))
  end

  def self.reindex(id)
    begin
      post "/api/contracts/#{id}/reindex"
    rescue JSON::ParserError
      nil
    end
  end

  def approved?
    approved_at.present?
  end

  def self.csw_link_options(session_token:, q: nil, page: 1, year: nil)
    csw_link_request(:get, "/api/csw_event_contract_links/options",
      { q: q, page: page }, session_token)
  end

  def self.link_csw_event(event_id:, contract_id:, year:, session_token:, event_outline_id: nil, expected_revision: nil)
    values = { contract_id: contract_id, year: year, event_outline_id: event_outline_id }
    values[:expected_revision] = expected_revision unless expected_revision.nil?
    csw_link_request(:put, "/api/csw_event_contract_links/#{event_id}",
      values, session_token)
  end

  def self.unlink_csw_event(event_id:, contract_id:, year:, expected_revision:, session_token:, event_outline_id: nil)
    csw_link_request(:delete, "/api/csw_event_contract_links/#{event_id}",
      { contract_id: contract_id, event_outline_id: event_outline_id, year: year, expected_revision: expected_revision }, session_token)
  end

  def self.csw_event_link(event_id:, session_token:)
    csw_link_request(:get, "/api/csw_event_contract_links/#{event_id}", {}, session_token)
  end

  def self.csw_contract_events(contract_id:, session_token:, page: 1, year: nil)
    csw_link_request(:get, "/api/csw_event_contract_links/contracts/#{contract_id}/events",
      { page: page }, session_token)
  end

  def self.csw_link_request(method, path, values, session_token)
    return { status: 401, errors: ["Authentication required"] } if session_token.blank?

    public_send("#{method}_raw", path, values.merge(
      _headers: { "Authorization" => "Token token=#{session_token.to_json}" }
    )) do |parsed, response|
      { status: response.status, data: parsed[:data], meta: parsed[:metadata], errors: parsed[:errors] }
    end
  rescue JSON::ParserError, Her::Errors::ParseError, Faraday::Error
    { status: 502, errors: ["Contract service unavailable"] }
  end
  private_class_method :csw_link_request

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
