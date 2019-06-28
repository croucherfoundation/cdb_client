require 'settings'
require 'faraday_middleware'
require 'her'
require 'her/middleware/json_api_parser'

api_url = ENV['CORE_URL'] || "#{Settings.cdb.protocol}://#{Settings.cdb.api_host}:#{Settings.cdb.api_port}"

CDB = Her::API.new
CDB.setup url: api_url do |c|
  # Request
  c.use FaradayMiddleware::EncodeJson
  # Response
  c.use Her::Middleware::JsonApiParser
  c.use Faraday::Adapter::NetHttp
end

