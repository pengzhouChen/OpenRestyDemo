local test_class = require("control.get_data")

local test = test_class:new()

local res, err = test:get_data_from_sql()

ngx.say("res:", res)