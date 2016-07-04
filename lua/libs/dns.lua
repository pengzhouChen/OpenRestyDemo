local _M = {}
local resolver, err = require("resty.resolver")

local _mt = { __index = _M }

function _M:new()
    return setmetatable({}, _mt)
end

function _M:get_ip( domain )

	local r, err = resolver:new{nameservers = { "114.114.114.114" }}

    if not r then
        ngx.say("failed to instantiate resolver: ", err)
        return
    end

	local answers, err = r:query(domain)

	if not answers then
		ngx.say("fail to query the DNS server:",err)
		return
	end

	if answers.errcode then
		ngx.say("server returned error code: ", answers.errcode,": ", answers.errstr)
		return
	end

	for i, ans in ipairs(answers) do
		if ans.address then
			return ans.address
		end
	end
end


return _M
