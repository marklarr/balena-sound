module SnapcastJsonRpcGateway
  def self.http_post(body)
    http = Net::HTTP.new("192.168.5.227", 1780)

    request = Net::HTTP::Post.new("/jsonrpc")
    request.body = body
    response = http.request(request)
    JSON.parse(response.read_body)
  end

  def self.get_status(client_id)
    body = %Q({"id":8,"jsonrpc":"2.0","method":"Client.GetStatus","params":{"id":"#{client_id}"}})
    http_post(body)
  end

  def self.set_volume_percent(client_id, volume_percent)
    body = %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"#{client_id}","volume":{"muted":false, "percent":#{volume_percent}}}})
    http_post(body)
  end

  def self.set_volume_muted(client_id, muted)
    body = %Q({"id":"8","jsonrpc":"2.0","method":"Client.SetVolume","params":{"id":"#{client_id}","volume":{"muted":#{muted}}}})
    http_post(body)
  end

  def self.get_server_status
    body = %Q({"id":1,"jsonrpc":"2.0","method":"Server.GetStatus"})
    http_post(body)
  end
end
