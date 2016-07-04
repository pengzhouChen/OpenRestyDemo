local mysql_class = require("resty.mysql")
local db = nil
--local dns_class = require("libs.dns")
local _M = {}

local _mt = { __index = _M }


function _M:connect_mod()
	return self.db:connect(self.connect_array)
end


function _M:set_keeplive_mod()
	return self.db:set_keeplive(10000, 50)
end


function _M:query_mod( sql_string )
	local ok, err = self:connect_mod()

	if not ok then
		return nil,err
	end

	local res, err, errno, sqlstate = self.db:query(sql_string)
    if not res then
        ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
        return ngx.exit(500)
    end

    local ok, err = self.db:set_keepalive(1000, 100)
    if not ok then
        ngx.say("failed to set keepalive: ", err)
    end

    return res
end


function _M:new()
--	local dns = dns_class:new()

--	local mysql_ip,err = dns:get_ip("rdspaabsaps5b31uztygo.mysql.rds.aliyuncs.com")

	local connect_array = {
		host = "121.40.5.179",
    	port = 3306,
    	database = "open_resty_china",
    	user = "chenpengzhou",
    	password = "ul2osWm9Iv3q3Lvv"
	}	

	db = mysql_class:new()

	return setmetatable({ connect_array = connect_array, db = db }, _mt)
end

return _M