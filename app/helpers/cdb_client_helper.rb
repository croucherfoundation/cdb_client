module CdbClientHelper

  def cdb_url(path)
    URI.join(cdb_host, path).to_s
  end

  def cdb_host
    Settings.cdb[:asset_host] ||= "db.croucher.org.hk"
    Settings.cdb[:asset_protocol] ||= 'https'
    "#{Settings.cdb.asset_protocol}://#{Settings.cdb.asset_host}"
  end

end
