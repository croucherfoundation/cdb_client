require 'settings'
require 'faraday_middleware'
require 'her'
require 'her/middleware/json_api_parser'
require 'typhoeus/adapters/faraday'

api_url = ENV['CORE_API_URL']

CDB = Her::API.new
CDB.setup url: api_url do |c|
  # Request
  c.use FaradayMiddleware::EncodeJson
  c.adapter Faraday::Adapter::Typhoeus
  # Response
  c.use Her::Middleware::JsonApiParser
  c.adapter Faraday::Adapter::NetHttp
end
