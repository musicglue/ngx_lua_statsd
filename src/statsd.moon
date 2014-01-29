class Statsd
  new: =>
    @buffer = {}
    
  setup: (host, port, batching) =>
    @host = host
    @port = port
    @batch = batching or 40
  
  time: (bucket, time) =>
    @register bucket, time .. "|ms"
  
  count: (bucket, n) =>
    @register bucket, n .. "|c"
    
  incr: (bucket) =>
    @count bucket, 1
    
  register: (bucket, suffix, sample_rate) =>
    table.insert @buffer, bucket .. ":" .. suffix .. "\n"
  
  flush: =>
    if table.getn(@buffer) > @batch
      pcall ->
        udp = ngx.socket.udp()
        udp\setpeername(@host, @port)
        udp\send(@buffer)
        udp\close!

      for k in pairs @buffer do
        @buffer[k] = nil