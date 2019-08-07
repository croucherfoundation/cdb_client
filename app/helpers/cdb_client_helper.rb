module CdbClientHelper

  def cdb_url(path, params={})
    uri = URI.join(cdb_host, path.sub(/^\//, ''))
    uri.query = params.to_query if params.any?
    uri.to_s
  end

  def cdb_host
    ENV['CORE_URL'] || "#{Settings.cdb.protocol}://#{Settings.cdb.host}"
  end

end
