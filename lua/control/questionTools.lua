local questionClass = require('/model/question')
local labelClass = require('/model/label')

local _M = {}
local _mt = { __index = _M }

function _M:new()
	return setmetatable({}, _mt)
end

function _M:createQuestion( questionJson )
	local question = questionClass:new(questionJson)
	--插入问题基本信息
	question:insertToQuestionInfo()

	--将问题插入到用户问题列表
	local labels = self:getLabelIds(question.labels)
	local userIdList = {}
	local tempUserIdList = {}
	for i = 1, #labels do
		tempUserIdList = labels[i]:getLabelUserList()
		for j = 1, #tempUserIdList do
			table.insert(userIdList, tempUserIdList[j])
		end
	end
	question:insertToUserQuestionList(userIdList)

	--将问题插入到标签列表页
	for i = 1, #labels do
		labels[i]:insertToLabelQuestionList(question.id)
	end
end

function _M:getLabelIds( labelsContent )
	local tempLabel = labelClass:new()
	local labels = {}
	local labelCount = table.getn(labelsContent)
	for i = 1 , labelCount do
		ngx.log(ngx.ERR,labelsContent[i])
		tempLabel:updateDate(labelsContent[i])
		labels[i] = tempLabel
	end
	return labels
end

return _M