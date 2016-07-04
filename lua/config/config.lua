local _M = {}

local _mt = { __index = _M }



function _M:new()
	return setmetatable({}, _mt)
end

return _M