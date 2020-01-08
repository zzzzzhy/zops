-- Copyright (C) 2019 skycomm <11657924@qq.com>
-- Licensed to the public under the GNU General Public License v3.

local uci = require "luci.model.uci".cursor()
local fs  = require "nixio.fs"
local sys = require "luci.sys"
local cjson = require "cjson"

m = Map("tysniffer", translate("Tysniffer Config"), "")
m:append(Template("tysniffer/status_header"))

s = m:section(NamedSection, "base", "cfg")
s.anonymous = true
s.addremove = false

adapterIP = s:option(Value, "adapterIP", translate("Capture packet adapter IP:"))
adapterIP.datatype = 'ipaddr'
adapterIP.default = '192.168.2.1'

captureInterval = s:option(Value, "captureInterval", translate("Capture packet captureInterval (microsecond):"))
captureInterval.datatype = 'uinteger'
captureInterval.default = 200

savePcap = s:option(Flag, "savePcap", translate("Save the pcap file:"))
-- savePcap.datatype = 'bool'
savePcap.enabled = 'true'
savePcap.disabled = 'false'
savePcap.default = savePcap.disabled
savePcap.rmempty = false

pcapSavePath = s:option(Value, "pcapSavePath", translate("Save the pcap file path:"))
pcapSavePath:depends("savePcap", 'true')
pcapSavePath.default = '/tmp/output.pcap'

uploadInterval = s:option(Value, "uploadInterval", translate("Data upload interval (ms):"))
uploadInterval.datatype = 'uinteger'
uploadInterval.default = 30000

serverUrl = s:option(Value, "serverUrl", translate("Upload server address:"))
serverUrl.datatype = 'string'
serverUrl.default = '222.180.200.194:7080'

removeFile = s:option(Flag, "removeFile", translate("Delete after upload:"))
-- removeFile.datatype = 'bool'
removeFile.enabled = 'true'
removeFile.disabled = 'false'
removeFile.default = removeFile.enabled
removeFile.rmempty = false

mac_saveInterval = s:option(Value, "macSaveInterval", translate("Single MAC deduplication time (ms):"))
mac_saveInterval.datatype = 'uinteger'
mac_saveInterval.default = 60000

mac_readInterval = s:option(Value, "macReadInterval", translate("File resolution interval (ms):"))
mac_readInterval.datatype = 'uinteger'
mac_readInterval.default = 20000

apmacSavePath = s:option(Value, "apmacSavePath", translate("Apmac saves the directory:"))
apmacSavePath.default = '/tmp/data/apmac'

macSavePath = s:option(Value, "macSavePath", translate("mac saves the directory:"))
macSavePath.default = '/tmp/data/mac'

airodumpCommands = s:option(TextValue, "airodumpCommands", translate("airodump:"))
airodumpCommands.default = "screen -dmS airodump airodump-ng  -babg -w /tmp/xxx --output-format csv wlan0,wlan1"

airbaseCommands = s:option(TextValue, "airbaseCommands", translate("airbase:"))
airbaseCommands.default = "airbase-ng -P -C 30 wlan0"

local function writeJson()
    if not fs.access("/mnt/tysniffer.json") then
        return
    end
    local sampleJson = fs.readfile("/mnt/tysniffer.json")
    local data = cjson.decode(sampleJson)
    data["capturerSettings"]["adapterIP"] = uci.get("tysniffer", "base", "adapterIP")
    data["capturerSettings"]["captureInterval"] = uci.get("tysniffer", "base", "captureInterval")
    if (uci.get("tysniffer", "base", "savePcap") == 'true') then
        data["capturerSettings"]["savePcap"] = true
    else
        data["capturerSettings"]["savePcap"] = false
    end

    data["capturerSettings"]["pcapSavePath"] = uci.get("tysniffer", "base", "pcapSavePath")
    data["uploaderSettings"]["uploadInterval"] = uci.get("tysniffer", "base", "uploadInterval")
    data["uploaderSettings"]["serverUrl"] = uci.get("tysniffer", "base", "serverUrl")
    
    if (uci.get("tysniffer", "base", "removeFile") == 'true') then
        data["uploaderSettings"]["removeFile"] = true
    else
        data["uploaderSettings"]["removeFile"] = false
    end

    data["macParserSettings"]["macSaveInterval"] = uci.get("tysniffer", "base", "macSaveInterval")
    data["macParserSettings"]["macReadInterval"] = uci.get("tysniffer", "base", "macReadInterval")
    data["macParserSettings"]["apmacSavePath"] = uci.get("tysniffer", "base", "apmacSavePath")
    data["macParserSettings"]["macSavePath"] = uci.get("tysniffer", "base", "macSavePath")
    local dumpcommands = {}
    dumpcommands[1] = uci.get("tysniffer", "base", "airodumpCommands")
    data["airodumpSettings"]["commands"]= dumpcommands
    local basecommands = {}
    basecommands = uci.get("tysniffer", "base", "airbaseCommands")
    data["airbaseSettings"]["commands"] = basecommands
    local jsonStr = cjson.encode(data);
    fs.writefile("/mnt/tysniffer.json",jsonStr)

end

m.on_after_commit = function(self)
    writeJson()
end

local apply = luci.http.formvalue("cbi.apply")
if apply then
    -- writeJson()
    io.popen("killall tysniffer")
    -- io.popen("echo 111111111111 > /mnt/1")
end

return m