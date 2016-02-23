local mysql_c = require("resty.mysql")
local _M = {}


local connet_array = {
	host = "127.0.0.1",
    port = 3306,
    database = "world",
    user = "monty",
    password = "pass"
}


function _M.connect_mod( self, db )
	return db:connect(connect_array)
end

function _M.set_keeplive_mod( db )
	return db:set_keeplive(10000, 50)
end


function _M.query_mod( self, sql_string )
	local db, err = mysql_c:new()

	if not db then
		return nil,err
	end

	local ok, err = self:connect_mod(db)

	if not ok then
		return nil,err
	end

	local res, err, errno, sqlstate = db:query(sql_string)
    if not res then
        ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
        return ngx.exit(500)
    end

    self.set_keeplive_mod(db)

    return res
end