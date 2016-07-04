local labelToolsClass = require("control.labelTools")
local labelTools = labelToolsClass:new()

function getFile(file_name)
  	local f = assert(io.open(file_name, 'r'))
    local string = f:read("*all")
    f:close()
    return string
end

ngx.req.read_body()
local data = ngx.req.get_body_data()
if nil == data then
	local file_name = ngx.req.get_body_file()
    ngx.say(">> temp file: ", file_name)
   	if file_name then
  		data = getFile(file_name)
    end
end
ngx.log(ngx.ERR, data)

labelTools:createLabel(data)

ngx.say("OK", data)