# Nginx Lua StatsD Module

A simple, non-blocking StatsD facility for Nginx's Lua module using the Nginx Lua co-socket API.

## Supported Modes

- Increment
- Time
- Counter

## Usage

```lua
http {
	init_worker_by_lua '
		local Statsd = require("statsd")
		statsd = Statsd()
		statsd:setup(STATSD_HOSTNAME, STATSD_PORT, STATSD_BUFFER_SIZE)
	';
	server {
		location / {
			access_by_lua '
				-- Increment a counter for the url being hit
		      		statsd:count(ngx.var.uri)
			';		
			content_by_lua '
				--[[ 
					This will clear out the buffer of the statsd process if it
					has become full. It's worth mentioning that in the case
					of things like counters, a large buffer will cause inaccurate
					results as they'll be recorded potentially out of time period.
					The default buffer size is 40, but if your Statsd server is decent
					enough then there is no need to go that high.
				--]]
				statsd:flush()
			';		}	}}
```

## Installation

1. Install Nginx with the ngx_lua_module
2. Add the ```lib/statsd.lua``` file to your LUA_PATH somewhere
3. Instantiate a statsd logger instance somewhere in an init block, I suggest in the ```init_worker_by_lua``` phase.
4. Win and profit.

## Warranty

None, sorry!