-- Copyright (C) 2019 skycomm <11657924@qq.com>
-- Licensed to the public under the GNU General Public License v3.

local uci = require "luci.model.uci".cursor()
local fs  = require "nixio.fs"
local sys = require "luci.sys"

local f,t
f = SimpleForm("tysniffer", translate("Wifi Log"),
	translate("The data is refreshed every 3 seconds."))

f:append(Template("tysniffer/wifi_log"))
f.reset = false
f.submit = false


return f
