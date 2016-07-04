local _M = {}
local _mt = { __index = _M }

local function set_cache(activity_list, activity_count_list, cjson, cache_ngx)
	local activity_list_cache = cjson.encode(activity_list)
	local activity_count_list_cache = cjson.encode(activity_count_list)
	local succ, err, forcible = cache_ngx:set("activity_list", activity_list_cache)
	if not succ then
		ngx.log(ngx.ERROR, "fail to set activity_list in shared cache:", err)
		return false
	end
	local succ, err, forcible = cache_ngx:set("activity_count_list", activity_count_list_cache)
	if not succ then
		ngx.log(ngx.ERROR, "fail to set activity_count_list in shared cache:", err)
		return false
	end
	return true
end

function _M:new()
	local redis_class = require("libs.redis_iresty")
	local redis = redis_class:new()

	local cache_ngx = ngx.shared.my_cache
	local cjson = require("cjson")
	local activity_list_cache = cache_ngx:get("activity_list")
	if not activity_list_cache then
		activity_list_cache = "{}"
	end
	local activity_list = cjson.decode(activity_list_cache) 
	local activity_count_list_cache = cache_ngx:get("activity_count_list")
	if not activity_count_list_cache then
		activity_count_list_cache = "{}"
	end
	local activity_count_list = cjson.decode(activity_count_list_cache)
	local activity_model_class = require("model.activity")

	return setmetatable({ activity_list = activity_list, 
		activity_count_list = activity_count_list, 
		activity_model_class = activity_model_class,
		cjson = cjson,
		cache_ngx = cache_ngx }, _mt)
end

function _M:handle_max_count_activity()
	local max_value = 0
	local max_value_key = ""
	for key, value in pairs( self.activity_count_list ) do
		if value >= max_value then
			max_value = value
			max_value_key = key
		end
	end
	local activity = self.activity_list[max_value_key]
	local activity_model = self.activity_model_class:new(activity.activity_id)
	local flag, err = activity_model:is_equal_date()
	if not flag then
		local ok, err = activity_model:del_from_redis()
		if not ok then
			ngx.say("fail to del activity from redis:", err)
		end
	end
--	ngx.log(ngx.INFO, "max_value_key:", max_value_key, ", max_value:", max_value)
	self.activity_count_list[max_value_key] = 0
	return set_cache(self.activity_list, self.activity_count_list, self.cjson, self.cache_ngx)
end

function _M:acitivity_count( activity_id )
    local activity_key = "activity_" .. activity_id
    if not self.activity_count_list[activity_key] then
    	self.activity_count_list[activity_key] = 0
    end
--	ngx.log(ngx.INFO, "activity_count_list[", activity_key, "] count:", self.activity_count_list[activity_key])
    self.activity_count_list[activity_key] = self.activity_count_list[activity_key] + 1
    local activity_model = self.activity_model_class:new(activity_id)
    self.activity_list[activity_key] = activity_model.model
    return set_cache(self.activity_list, self.activity_count_list, self.cjson, self.cache_ngx)
end

return _M