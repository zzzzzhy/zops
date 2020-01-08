-- Copyright 2019 skycomm <11657924@qq.com>
-- Licensed to the public under the MIT License.

module("luci.controller.tysniffer", package.seeall)
local fs = require "nixio.fs"
local http = require "luci.http"
local sys = require "luci.sys"

function index()

	entry({"admin", "services", "tysniffer"},alias("admin", "services", "tysniffer","config"),_("Tysniffer Config"),100).dependent = true

	entry({"admin", "services", "tysniffer","config"}, cbi("tysniffer/config"),_("Tysniffer Config"),10).leaf = true

	entry({"admin", "services", "tysniffer","wifi_log"}, cbi("tysniffer/wifi_log"),_("Wifi Log"),20).leaf = true
	
    entry({"admin", "services", "tysniffer", "read"}, call("read_data"))

	entry({"admin", "services", "tysniffer", "clear"}, call("clear_data"))

	entry({"admin", "services", "tysniffer", "status"}, call("action_status"))
end

function read_data()
	local util = require "luci.util"

	local log_data = { client = "", log = "" }

    local log_file = "/tmp/xxx-02.csv"

    if not fs.access(log_file) then
        log_data.log = util.trim(
        util.exec("cat /tmp/xxx-01.csv"))
    else
        log_data.log = util.trim(
            util.exec("cat /tmp/xxx-02.csv"))
    end

	http.prepare_content("application/json")
	http.write_json(log_data)
end

function clear_data(type)
	if type and type ~= "" then

		local log_file = "tmp/xxx-02.csv"

        if not fs.access(log_file) then
            log_file = "tmp/xxx-01.csv"
        end

		if fs.access(log_file) then
			fs.writefile(log_file, "")
		else
			http.status(404, "Not found")
			return
		end
	end

	http.prepare_content("application/json")
	http.write_json({ code = 0 })
end

function action_status()
	local running = false
	
	local file_name = "tysniffer"
	if file_name ~= "" then
		running = sys.call("pidof %s >/dev/null" % file_name) == 0
	end

	http.prepare_content("application/json")
	http.write_json({
		running = running
	})
end