local json = require("cjson")
local redisClass = require("libs.redis_iresty")


local _M = {}
local _mt = { __index = _M }

function _M:getQuestionId()
	local redis = redisClass:new()
	redis:select(4)
	local id,err = redis:get("question_id_index")
	redis:incr("question_id_index")
	return id
end

function _M:insertToQuestionInfo()
	local redis = redisClass:new()
	redis:select(4)
	local labelsJson = json.encode(self.labels)
	local answersJson = json.encode(self.answers)
	return redis:hmset("question_" .. id .. "_info", "content", self.content, "labels", labelsJson, "answers", answersJson)	
end

function _M:insertToUserQuestionList(userList)
	local redis = redisClass:new()
	redis:select(4)
	--todo
	local userCount = table.getn(userList)
	for i = 1, userCount do
		redis:sadd("user_" .. userList[i] .. "_question_list", self.id)
	end
end

function _M:new(questionJson)
	local questionTable = json.decode(questionJson)
	content = questionTable.content
	labels = questionTable.labels
	answers = self:encodeAnswers(questionTable.answers)
	id = self.getQuestionId()
	return setmetatable({id = id, content = content, labels = labels, answers = answers}, _mt)
end

function _M:encodeAnswers(answers)
	local answersCount = table.getn(answers)
	local res = {}
	for i = 1 , answersCount do
		temp = {id = i, content = answers[i].content, label = answers[i].label}
		res[i] = temp
	end
	return res
end

return _M