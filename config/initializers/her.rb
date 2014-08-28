require 'settings'
require 'paginated_her'

Settings.cdb[:protocol] ||= 'http'
Settings.cdb[:api_host] ||= Settings.cdb[:host] || 'localhost'
Settings.cdb[:api_port] ||= Settings.cdb[:port] || 8002

CDB = Her::API.new
CDB.setup url: "#{Settings.cdb.protocol}://#{Settings.cdb.api_host}:#{Settings.cdb.api_port}" do |c|
  # Request
  c.use Faraday::Request::UrlEncoded

  # Response
  c.use PaginatedHer::Middleware::Parser
  c.use Faraday::Adapter::NetHttp
end



