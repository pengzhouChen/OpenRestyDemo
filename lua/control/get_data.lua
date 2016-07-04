local _M = {}
local _mt = { __index = _M }

function _M:new()
	local activity_model_class = require("model.activity")
	local args = ngx.req.get_uri_args()
	local activity_model = activity_model_class:new(args.id)
	return setmetatable({ activity_model = activity_model }, _mt)
end

--[[
function _M:get_data_from_sql()
	local args = ngx.req.get_uri_args()	
	local res,err = activity_model:query_by_id_sql(args.id)
	if not res then
		ngx.say(":", err)
	end
	return res
end

function _M:get_data_from_redis()
	local args = ngx.req.get_uri_args()
	local res, err = activity_model:query_by_id_redis(args.id)
	local random = math.random(1,100)
	if random < 10 then
		local ok, err = activity_model:update_by_id_sql(args.id)
		if not ok then
			ngx.say("error to update data:", err)
		end
	end
	if not res then
		ngx.say(":", err)
	end
	return res
end
]]

return _M