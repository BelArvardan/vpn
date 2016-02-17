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

m = Map("vypr", "<img src=\"/luci-static/resources/vypr.png\" alt=\"VyprVPN\">",
	translate("VyprVPN is a VPN service with a large number of servers all over the world.<br />" ..
		"For Account Information, visit <a href=\"https://www.goldenfrog.com/vyprvpn\">Billing and Account status</a>."))

local srvs_path = "/etc/openvpn/vypr.list"
local lock_download_path = "/tmp/vypr_download.lock"
local lock_delete_path = "/tmp/vypr_delete.lock"

s = m:section(TypedSection, "vypr", translate("General Settings"),
	"To connect to VyprVPN VPN service, fill in your username and password below " ..
	"and select the location and server type you would like to connect to from the dropdown box, " ..
	"then tick the checkbox next to enable and click 'Save and Apply'.<br />" ..
	"If you do not have a VyprVPN username / password or need to check " ..
	"if your account is active, click the Billing and Account status link above.")
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
		luci.sys.call("unzip -p /etc/openvpn/VyprVPNOpenVPNFiles.zip VyprVPNOpenVPNFiles/" .. value .. ".ovpn > /etc/openvpn/vypr.ovpn")
		Value.write(self, section, value)
	end
end

if fs.access(lock_download_path) then
	reload_download = s:option(Button, "_reload_download", translate("VPN Configs"))
	reload_download.inputtitle = translate("Updating... Reload this page")
	reload_download.write = function(self, section)
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "vypr"))
	end
elseif (not fs.access(lock_delete_path)) then
	download = s:option(Button, "_download", translate("VPN Configs"))
	download.inputtitle = translate("Download/Update config files")
	download.write = function(self, section)
		luci.sys.call("/usr/bin/vypr_download.sh &")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "vypr"))
	end
end

if fs.access(lock_delete_path) then
	reload_delete = s:option(Button, "_reload_delete", translate("Delete VPN Configs"))
	reload_delete.inputtitle = translate("Deleting... Reload this page")
	reload_delete.write = function(self, section)
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "vypr"))
	end
elseif (not fs.access(lock_download_path)) then
	delete = s:option(Button, "_delete", translate("Delete VPN Configs"))
	delete.inputtitle = translate("Delete config files")
	delete.write = function(self, section)
		luci.sys.call("/usr/bin/vypr_delete.sh &")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "vypr"))
	end
end

p = m:section(TypedSection, "vypr", translate("VPN Status"), "There is a 5 second delay to display your public (external) IP after connecting.")
p.addremove = false
p.anonymous = true

local active = p:option( DummyValue, "_active", translate("Started") )

function active.cfgvalue(self, section)
	local pid = fs.readfile("/var/run/openvpn.pid")
	if pid and #pid > 0 and tonumber(pid) ~= nil then
		return (sys.process.signal(pid, 0))
			and translate("yes (%i)", pid)
			or  translate("no")
	end
	return translate("no")
end

o = p:option(DummyValue, "_ip", translate("Public IP Vypr"))
o.template = "public_ip_vypr"

return m
