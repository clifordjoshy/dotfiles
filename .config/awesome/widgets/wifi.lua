-------------------------------------------------
-- Wifi Signal Widget
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");

local NET_SIGNAL_CMD = "bash -c \"nmcli -t -f IN-USE,SIGNAL device wifi | grep \'*\'\""
local NET_STATUS_CMD = "nmcli network connectivity"
local NET_SPEED_CMD = "bash -c \"ifstat | awk \'/wlp1s0/ {print $6}\'\""
local NET_INFO_CMD = "nmcli -t -f general.connection,ip4.address device show wlp1s0"

local wifi_widget = {}

local worker = function(user_args)

	local icons = user_args.icons;
	local font = user_args.font or "monospace 9";
	local timeout = 10;
	local speed_timeout = 4;
	local gap = user_args.space;
	
	wifi_widget = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		spacing = gap,
		{
			id = 'icon',
			widget = wibox.widget.imagebox,
			image = icons[2],
		},
		{
			id = 'text',
			widget = wibox.widget.textbox,
		},

		update_strength = function(self, strength)
			local strength_icon = icons[math.ceil(strength/25) + 1]
			if self.icon.image ~= strength_icon then
				self.icon.image = strength_icon
			end
		end,
		update_net = function(self, is_connected)
			self:set_opacity(is_connected and 1 or 0.5)
			self:emit_signal('widget::redraw_needed')
		end,
		update_speed = function(self, down_speed)
			self.text:set_markup(string.format("<span font='%s' foreground='%s'>%s</span>", font, "#ec9e9e", down_speed));
		end
	}

	local update_widget = function(widget, stdout, stderr, _, _)
		local strength_string = string.match(stdout, ":(%d*)");
		widget:update_strength(tonumber(strength_string) or 0);
	end;

	local is_connected = nil
	local update_conn = function(widget, stdout, stderr, _, _)
		local is_connected_now = stdout:find("limited") == nil
		if is_connected ~= is_connected_now then
			is_connected = is_connected_now
			widget:update_net(is_connected)
		end
	end

	local update_speed = function(widget, stdout)
		local speed;
		local K_pos = stdout:find("K")
		if K_pos then
			local data = tonumber(stdout:sub(1, K_pos-1))/1024
			speed = string.format("%.1f MB/s", data/speed_timeout)
		else
			local data = tonumber(stdout)/1024
			speed = string.format("%.1f KB/s", data/speed_timeout)
		end
		widget:update_speed(speed)
	end

	watch(NET_SIGNAL_CMD, timeout, update_widget, wifi_widget);
	watch(NET_STATUS_CMD, timeout, update_conn, wifi_widget);
	watch(NET_SPEED_CMD, speed_timeout, update_speed, wifi_widget);

	--- Adds mouse controls to the widget:
	--  - left click - nmtui
	--  - right click - refresh status
	wifi_widget:connect_signal("button::press", function(_, _, _, button)
			if button == 1 then
				local nmtui_window = function(c) return awful.rules.match(c, {instance = "nmtui"}) end;
				for c in awful.client.iterate(nmtui_window) do
					c:jump_to(false);
					return;
				end;
				awful.spawn.with_shell("nmcli device wifi rescan && alacritty --class nmtui -e nmtui", false);
			elseif button == 3 then
				awful.spawn.easy_async("nmcli network connectivity check", function (stdout) update_conn(wifi_widget, stdout) end) 
			end;
		end
	);

	local last_result = ""
	local info_tooltip;
	info_tooltip = awful.tooltip{
		objects = {wifi_widget},
		timer_function = function()
			 awful.spawn.easy_async_with_shell(NET_INFO_CMD, function(result)
					local formatted = result:gsub("GENERAL.CONNECTION:", "ssid: "):gsub("IP4.ADDRESS....", "ip  : ")
					last_result = formatted
					info_tooltip:set_markup(last_result)
				end)
			return last_result
		end,
		delay_show = 1,
		fg = "#cdcdcd",
		bg = "#202020",
		border_width = 1,
		border_color = "#cdcdcd",
	}

	return wifi_widget;
end;

return setmetatable(wifi_widget, {	__call = function(_, ...)
		return worker(...);
	end
});