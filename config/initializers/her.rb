require 'settings'
require 'faraday_middleware'
require 'her'
require 'her/middleware/json_api_parser'

Settings.cdb[:protocol] ||= 'http'
Settings.cdb[:api_host] ||= Settings.cdb[:host] || 'localhost'
Settings.cdb[:api_port] ||= Settings.cdb[:port] || 8002

CDB = Her::API.new
CDB.setup url: "#{Settings.cdb.protocol}://#{Settings.cdb.api_host}:#{Settings.cdb.api_port}" do |c|
  # Request
  c.use FaradayMiddleware::EncodeJson
  # Response
  c.use Her::Middleware::JsonApiParser
  c.use Faraday::Adapter::NetHttp
end

