local _M = {}
local _mt = { __index = _M }

function _M:new()
	local activity_model_class = require("model.activity")
	local args = ngx.req.get_uri_args()
	local activity_model = activity_model_class:new(args.id)
	return setmetatable({ activity_model = activity_model }, _mt)
end

function _M:modify()
	ngx.say("modify")
	local cjson = require("cjson")
	self.activity_model:update()
	return 
end

function _M:compare()
	local cache_ngx = ngx.shared.my_cache
	local counter = tonumber(cache_ngx:get("compare_activity_counter"))
	local activity_list_cache_class = require("model.activity_list_cache")
	local activity_list = activity_list_cache_class:new()
	ngx.log(ngx.INFO, "count:", counter)

	if not counter then
		ngx.log(ngx.INFO, "Begin to count visit activity!")
		counter = 0
	elseif counter >= 10 then
		ngx.log(ngx.INFO, "handle_max_count_activity!")
		counter = 0
		local ok, err = activity_list:handle_max_count_activity()
		if not ok then
			return ok, err
		end
	else
		ngx.log(ngx.INFO, "count!")
		counter = counter + 1
    end

    local args = ngx.req.get_uri_args()
   	local activity_id = args.id
	local ok, err = activity_list:acitivity_count(activity_id)
	if not ok then
		return ok, err
	end
	local redis_class = require("libs.redis_iresty")
	local redis = redis_class:new()
	local ok, err = cache_ngx:set("compare_activity_counter", counter)
	if not ok then
		return ok, err
	end
end

return _M