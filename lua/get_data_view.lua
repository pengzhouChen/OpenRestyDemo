math.randomseed(ngx.now())
local random_id = math.random(1, 100)

ngx.say(random_id)


local res_get_data = ngx.location.capture("/api/service/get_data_from_redis?id=" .. random_id)

--local res_get_data = ngx.location.capture("/api/service/get_data_from_sql?id=" .. random_id)

if res_get_data then
	ngx.print(res_get_data.body)
end

ngx.eof()

local res_modify_date = ngx.location.capture("/api/service/compare_modify_date?id=" .. random_id)

if res_modify_date then
	ngx.log(ngx.INFO, res_modify_date.body)
end