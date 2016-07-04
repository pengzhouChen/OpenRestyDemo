local get_data_class = require("control.get_data")
local get_data = get_data_class:new()

local cjson = require("cjson")

local res, err = cjson.encode(get_data.activity_model.model)

ngx.say(res)

math.randomseed(ngx.now())

local random = math.random(1,1000)
ngx.log(ngx.INFO, "random number:", random)
if random < 10 then
	ngx.log(ngx.INFO, "change modify date")
	local update_data_class = require("control.update_data")
	local update_data = update_data_class:new()
	local res, err = update_data:modify()
end

return res