local _M = {}
local _mt = { __index = _M }

function _M:new()
	return setmetatable({}, _mt)
end

function _M:createLabel( labelJson )
	local labelClass = require('/model/label')
	local label = labelClass:new(labelJson)
	label:insertToLabelInfo()
	label:insertToLabelList()
	label:createLabelUserList()
end

return _M