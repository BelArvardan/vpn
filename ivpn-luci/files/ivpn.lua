--[[
LuCI - Lua Configuration Interface

Copyright 2015 Promwad.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local fs = require "nixio.fs"
local sys = require "luci.sys"

m = Map("ivpn", "<img src=\"/luci-static/resources/ivpn.png\" alt=\"IVPN\">",
	translate("IVPN is an online privacy service and security service. PGP fingerprint: 8169 5A68 8402 C4BE AB33 CEA4 92B6 B00E C485 B578.<br />" ..
		"For Account Information, visit <a href=\"https://www.ivpn.net/clientarea/login\">Billing and Account status</a>."))

local srvs_path = "/etc/openvpn/ivpn.list"
local lock_path = "/tmp/ivpn.lock"

s = m:section(TypedSection, "ivpn", translate("General Settings"),
	"To connect to IVPN, fill in your username and password below " ..
	"and select the location and server type you would like to connect to from the dropdown box, " ..
	"then tick the checkbox next to enable and click 'Save and Apply'.<br />" ..
	"Need an account? <a href=\"https://www.ivpn.net/aff.php?aff=1471\">Click here to Signup.</a>" ..
	" IVPN only uses proven open-source technologies, to bring you the best value and most secure VPN possible.")
s.addremove = false
s.anonymous = true

e = s:option(Flag, "enabled", translate("Enable"))
e.rmempty = false
e.default = e.enabled

local username = s:option(Value, "username", translate("Username"))

local pw = s:option(Value, "password", translate("Password"))
pw.password = true

if fs.access(srvs_path) then
	srv = s:option(ListValue, "server", translate("Server"))
	local l
	for l in io.lines(srvs_path) do
		srv:value(l)
	end

	srv.write = function(self, section, value)
		luci.sys.call("unzip -p /etc/openvpn/ivpn-openvpn-config.zip " .. value .. ".ovpn > /etc/openvpn/ivpn.ovpn")
		Value.write(self, section, value)
	end
end

if fs.access(lock_path) then
	reload = s:option(Button, "_reload", translate("VPN Configs"))
	reload.inputtitle = translate("Updating... Reload this page")
	reload.write = function(self, section)
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "ivpn"))
	end
else
	update = s:option(Button, "_update", translate("VPN Configs"))
	update.inputtitle = translate("Update config files")
	update.write = function(self, section)
		luci.sys.call("/usr/bin/ivpn.sh &")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "ivpn"))
	end
end

p = m:section(TypedSection, "ivpn", translate("VPN Status"), "There is a 5 second delay to display your public (external) IP after connecting.")
p.addremove = false
p.anonymous = true

local active = p:option( DummyValue, "_active", translate("Started") )
function active.cfgvalue(self, section)
	local pid = fs.readfile("/var/run/openvpn.pid")
	if pid and #pid > 0 and tonumber(pid) ~= nil then
		return (sys.process.signal(pid, 0))
			and translatef("yes (%i)", pid)
			or  translate("no")
	end
	return translate("no")
end

o = p:option(DummyValue, "_ip", translate("Public IP"))
o.template = "public_ip"

return m
