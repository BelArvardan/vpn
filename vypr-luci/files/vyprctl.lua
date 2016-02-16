--[[
LuCI - Lua Configuration Interface

Copyright 2015 Promwad.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.vyrpctl", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/vypr") then
		return
	end

	local page

	page = entry({"admin", "services", "vypr"}, cbi("vypr/vypr"), _("VyprVPN"))
	page.dependent = true

	entry({"admin", "system", "public_ip_vypr"}, call("action_public_ip_vypr"))
end

function action_public_ip_vypr()
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

		luci.http.prepare_content("application/json")
		luci.http.write_json({ ipstring = res })
	end
end
