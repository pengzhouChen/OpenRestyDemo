local json = require("cjson")
local redisClass = require("libs.redis_iresty")


local _M = {}
local _mt = { __index = _M }

function _M:getLabelIndex()
	local redis = redisClass:new()
	redis:select(4)
	local id, err = redis:get("label_id_index")
	redis:incr("label_id_index")
	return id, err
end

function _M:isLabelInSystem()
	local redis = redisClass:new()
	redis:select(4)
	local res = redis:hget("label_content", self.content)
	if res ~= nil then
		return true
	else
	    return false
	end
end

function _M:insertToLabelInfo()
	local redis = redisClass:new()
	redis:select(4)
	return redis:hmset("label_" .. self.id .. "_info", "content", self.content, "expire_time", self.expireTime)
end

function _M:insertToLabelList()
	local redis = redisClass:new()
	redis:select(4)
	return redis:hset("label_content_id", self.content, self.id)
end

function _M:createLabelUserList()
	local redis = redisClass:new()
	redis:select(4)
	return redis:hset("label_" .. self.id .. "_user", 10000, ngx.now() * 2)
end

function _M:getLabelUserList()
	local redis = redisClass:new()
	redis:select(4)
	return redis:hkeys("label_" .. self.id .. "_user")
end

function _M:new(labelJson)
	if labelJson ~= nil then
		local labelTable = json.decode(labelJson)
	
		content = ""
		expireTime = ""
		if labelTable.content ~= nil then
			content = labelTable.content
		else
		   	content = "system"
		end

		if labelTable.expireTime ~= nil then
			expireTime = labelTable.expireTime
		else
			expireTime = "-1"
		end

		if self.isLabelInSystem(content) then
			ngx.log(ngx.DEBUG, content .. "is already in system!")
			return
		end

		id = self.getLabelIndex()
		return setmetatable({id = id, content = content, expireTime = expireTime}, _mt)
	else
	    return setmetatable({id = "", content = "", expireTime = ""}, _mt)
	end
end

function _M:updateDate(labelContent)
	local redis = redisClass:new()
	redis:select(4)
	self.id = redis:hget("label_content_id", labelContent)
	self.content = labelContent
	self.expireTime = redis:hget("label_" .. self.id .. "_info", "expire_time")
end

function _M:insertToLabelQuestionList(questionId)
	local redis = redisClass:new()
	redis:select(4)
	return redis:sadd("label_" .. self.id .. "_question_list", questionId)
end

return _M