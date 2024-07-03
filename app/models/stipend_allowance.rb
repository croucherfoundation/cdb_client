class StipendAllowance
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/stipend_allowances"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
      StipendAllowance.new({
        scholar_per_month: nil,
        fellow_per_month: nil,
        sc_studentship_per_month: nil,
        first_child_per_month: nil,
        second_child_per_month: nil,
        ra_per_annum: nil,
        ada_per_annum: nil,
        medical_insurance_per_annum: nil,
        arrival_costs: nil,
        year: nil

      }.merge(attributes))
    end
  end

end
