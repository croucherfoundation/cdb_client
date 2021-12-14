module ArConfig
  extend ActiveSupport::Concern

  included do
    self.site                   = ENV['CORE_API_URL']
    self.prefix                 = '/api/'
    self.format                 = FormatApiResponse
    self.include_format_in_path = false
  end
end
