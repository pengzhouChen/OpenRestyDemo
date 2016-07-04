local _M = {}
local _mt = { __index = _M }

local function redis_insert( key, value, redis )
	local ok, err = redis:set(key, value)
	if not ok then
		ngx.say("fail to insert :" , key, err)
		return 
	end
	return ok
end

local function redis_del( key, redis )
	local ok, err = redis:del(key)
	if not ok then
		ngx.say("fail to del:",key,err)
		return 
	end
	return ok
end

local function query_by_id_sql( id, db )
	local res, err = db:query_mod("select * from activity where activity_id = " .. id )
	if not res then
		ngx.log(ngx.ERROR, "can't return activity!error:", err)
		return res, err
	end
	return res[1]
end

local function query_by_id_redis( id, redis, db )
	local redis_key = "activity_" .. id
	local activity_json_string, err = redis:get(redis_key)
	local json = require("cjson")
	if not activity_json_string then
		ngx.log(ngx.INFO, "not hit!")		
		local res, err = query_by_id_sql(id, db)
		activity_json_string = json.encode(res)
		redis_insert(redis_key, activity_json_string, redis)
		return res, err
	end
	ngx.log(ngx.INFO, "value:", activity_json_string)
	local res, err = json.decode(activity_json_string)
	ngx.log(ngx.INFO, "activity_id:", res.activity_id)
	return res
end


function _M:new( id )
	local redis_class = require("libs.redis_iresty")
	local mysql_class = require("libs.mysql_iresty")
	local redis = redis_class:new()
	local db = mysql_class:new()
	local model = query_by_id_redis( id, redis, db )
	return setmetatable({ redis = redis, db = db, model = model }, _mt)
end

function _M:new_sql( id )
	local redis_class = require("libs.redis_iresty")
	local mysql_class = require("libs.mysql_iresty")
	local redis = redis_class:new()
	local db = mysql_class:new()
	local model = query_by_id_sql( id, db )
	return setmetatable({ redis = redis, db = db, model = model }, _mt)
end


function _M:update()
	ngx.say("update")
	local cjson = require("cjson")
	ngx.say(cjson.encode(self.model))	
	local sql_str = [[update activity set modify_date = "]] .. ngx.localtime() ..  [[" where activity_id = ]] .. self.model.activity_id
	local ok, err = self.db:query_mod(sql_str)
	if not ok then
		ngx.say("can't update activity!error:", err)
	end
	return ok
end

function _M:is_equal_date()
	if self.model.modify_date == (query_by_id_sql(self.model.activity_id, self.db)).modify_date then
		return true
	end
	return false
end

function _M:del_from_redis()
	return redis_del("activity_" .. self.model.activity_id, self.redis)
end


return _M