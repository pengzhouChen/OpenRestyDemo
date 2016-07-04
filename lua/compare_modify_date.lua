local update_data_class = require("control.update_data")
local update_data = update_data_class:new()

local ok, err = update_data:compare()
