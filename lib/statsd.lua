local Statsd
do
  local _base_0 = {
    setup = function(self, host, port, batching)
      self.host = host
      self.port = port
      self.batch = batching or 40
    end,
    time = function(self, bucket, time)
      return self:register(bucket, time .. "|ms")
    end,
    count = function(self, bucket, n)
      return self:register(bucket, n .. "|c")
    end,
    incr = function(self, bucket)
      return self:count(bucket, 1)
    end,
    register = function(self, bucket, suffix, sample_rate)
      return table.insert(self.buffer, bucket .. ":" .. suffix .. "\n")
    end,
    flush = function(self)
      if table.getn(self.buffer) > self.batch then
        pcall(function()
          local udp = ngx.socket.udp()
          udp:setpeername(self.host, self.port)
          udp:send(self.buffer)
          return udp:close()
        end)
        for k in pairs(self.buffer) do
          self.buffer[k] = nil
        end
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self)
      self.buffer = { }
    end,
    __base = _base_0,
    __name = "Statsd"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Statsd = _class_0
  return _class_0
end