--[[
LuCI - Lua Configuration Interface

Copyright 2015 Promwad.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.vyprctl", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/vypr") then
		return
	end

	local page = entry({"admin", "services", "vypr"}, cbi("vypr/vypr"), _("VyprVPN"))
	page.dependent = true

	entry({"admin", "system", "get_status_info"}, call("action_get_status_info"))
	
end

function get_openvpn_state()
	local pid = nixio.fs.readfile("/var/run/openvpn.pid")
	local current_pid = 0
	if pid and #pid > 0 and tonumber(pid) ~= nil and luci.sys.process.signal(pid, 0) then
		current_pid = tonumber(pid)
	end
	return current_pid
end

function get_ip()
	local ipt = io.popen("wget -O - -q http://whatismyip.org/ | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'")
	if ipt then
		local res = ""
		while true do
			l = ipt:read("*l")
			if not l then break end

			if l then
				res = res .. l
			end
		end

		ipt:close()
		return res
	end
end

function action_get_status_info()
	local ip = get_ip()
	local pid = get_openvpn_state()

	luci.http.prepare_content("application/json")
	luci.http.write_json({ ["process_id"] = pid, ["ipstring"] = ip })
end
