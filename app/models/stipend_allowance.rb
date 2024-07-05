class StipendAllowance
  include Her::JsonApi::Model
  use_api CDB
  collection_path "/api/stipend_allowances"
  include_root_in_json true
  parse_root_in_json false

  class << self
    def new_with_defaults(attributes={})
      StipendAllowance.new({
        scholar_per_annum: nil,
        fellow_per_annum: nil,
        sc_studentship_per_annum: nil,
        first_child_per_annum: nil,
        second_child_per_annum: nil,
        ra_per_annum: nil,
        ada_per_annum: nil,
        medical_insurance_per_annum: nil,
        arrival_costs: nil,
        commencement_award: nil,
        year: nil

      }.merge(attributes))
    end
  end

end
