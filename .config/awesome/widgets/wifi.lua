-------------------------------------------------
-- Wifi Signal Widget
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");

local NET_SIGNAL_CMD = "bash -c \"nmcli -t -f IN-USE,SIGNAL device wifi | grep \'*\'\""
local NET_STATUS_CMD = "nmcli network connectivity"

local wifi_widget = {}

local worker = function(user_args)

	local icons = user_args.icons;
	local font = user_args.font or "sans-serif 9";
	local timeout = 10;
	
	wifi_widget = wibox.widget{
		widget = wibox.widget.imagebox,
		image = icons[2],

		update_strength = function(self, strength)
			local strength_icon = icons[math.ceil(strength/25) + 1]
			if self.image ~= strength_icon then
				self.image = strength_icon
			end
		end,
		update_net = function(self, is_connected)
			self:set_opacity(is_connected and 1 or 0.2)
			self:emit_signal('widget::redraw_needed')
		end
	}

	local update_widget = function(widget, stdout, stderr, _, _)
		local strength_string = string.match(stdout, ":(%d*)");
		widget:update_strength(tonumber(strength_string) or 0);
	end;

	local is_connected = false
	local update_conn = function(widget, stdout, stderr, _, _)
		local is_limited = stdout:find("limited") and true or false;
		if(is_connected == is_limited) then
			is_connected = not is_connected
			widget:update_net(is_connected)
		end
	end


	watch(NET_SIGNAL_CMD, timeout, update_widget, wifi_widget);
	watch(NET_STATUS_CMD, timeout, update_conn, wifi_widget);

	--- Adds mouse controls to the widget:
	--  - left click - nmtui
	--  - right click - refresh status
	wifi_widget:connect_signal("button::press", function(_, _, _, button)
			if button == 1 then
				-- without 0.1 delay, nmtui will not fill screen
				awful.util.spawn_with_shell("nmcli device wifi rescan && alacritty -e bash -c \'sleep 0.1 && nmtui\'", false);
			elseif button == 3 then
				awful.spawn.easy_async("nmcli network connectivity check", function (stdout) update_conn(wifi_widget, stdout) end) 
			end;
		end
	);

	return wifi_widget;
end;

return setmetatable(wifi_widget, {	__call = function(_, ...)
		return worker(...);
	end
});