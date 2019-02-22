module CdbClientHelper

  def cdb_url(path)
    URI.join(cdb_host, path).to_s
  end

  def cdb_host
    Settings.cdb[:host] ||= "db.croucher.org.hk"
    Settings.cdb[:protocol] ||= 'https'
    "#{Settings.cdb.protocol}://#{Settings.cdb.host}"
  end

end
