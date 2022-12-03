-------------------------------------------------
-- Wifi/Ethernet Widget
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");
local gears = require("gears")
local beautiful = require("beautiful")

local NET_SIGNAL_CMD = "bash -c \"nmcli -t -f IN-USE,SIGNAL device wifi | grep \'*\'\""
local NET_STATUS_CMD = "nmcli network connectivity"
local NET_TYPE_CMD = "bash -c \"nmcli -f TYPE,DEVICE,STATE con show --active | awk '\\$3 == \\\"activated\\\" {printf \\\"%s:%s\\\",\\$1,\\$2; exit }'\""
local NET_SPEED_CMD = "ifstat %s | awk 'NR==4 {printf $6}'"
local NET_INFO_CMD = "nmcli -t -f general.connection,ip4.address device show %s"

local wifi_widget = {}

local worker = function()

	local wifi_icons = beautiful.widget_wifi;
	local eth_icon = beautiful.widget_eth;
	local timeout = 10;
	local speed_timeout = 4;

	wifi_widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.widget_icon_gap,
		{
			id = 'icon',
			widget = wibox.widget.imagebox,
			image = wifi_icons[2],
		},
		{
			id = 'text',
			widget = wibox.widget.textbox,
		},

		update_strength = function(self, strength)

			local strength_icon = eth_icon;
			if strength >= 0 then
				strength_icon = wifi_icons[math.ceil(strength / 25) + 1]
			end
			if self.icon.image ~= strength_icon then
				self.icon.image = strength_icon
			end
		end,
		update_net = function(self, is_connected)
			self:set_opacity(is_connected and 1 or 0.5)
			self:emit_signal('widget::redraw_needed')
		end,
		update_speed = function(self, down_speed)
			self.text:set_markup(string.format("<span foreground='%s'>%s</span>", "#ea76cb", down_speed));
		end
	}

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
			local data = tonumber(stdout:sub(1, K_pos - 1))
			if data == nil then return end
			speed = string.format("%.1f MB/s", data / (1024 * speed_timeout))
		else
			local data = tonumber(stdout) or 0
			if data == nil then return end
			speed = string.format("%.1f KB/s", data / (1024 * speed_timeout))
		end
		widget:update_speed(speed)
	end

	local conn_type = "";
	local interface = "";

	local update_type = function(widget, stdout, _, _, _)
		local newtype, newifc = stdout:match('(.*):(.*)\n')
		if conn_type ~= newtype then
			conn_type = newtype
			interface = newifc
			if newtype == "ethernet" then
				widget:update_strength(-1)
			end
		end
		if newtype ~= "ethernet" then
			awful.spawn.easy_async(NET_SIGNAL_CMD, function(stdout, _, _, _)
				local strength_string = string.match(stdout, ":(%d*)");
				wifi_widget:update_strength(tonumber(strength_string) or 0);
			end)
		end
	end

	watch(NET_STATUS_CMD, timeout, update_conn, wifi_widget);
	watch(NET_TYPE_CMD, timeout, update_type, wifi_widget);
	-- watch(NET_SPEED_CMD, speed_timeout, update_speed, wifi_widget);
	gears.timer {
		timeout   = speed_timeout,
		call_now  = true,
		autostart = true,
		callback  = function()
			awful.spawn.easy_async_with_shell(NET_SPEED_CMD:format(interface), function(out) update_speed(wifi_widget, out) end)
		end
	}

	--- Adds mouse controls to the widget:
	--  - left click - nmtui
	--  - right click - refresh status
	wifi_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			local nmtui_window = function(c) return awful.rules.match(c, { instance = "nmtui" }) end;
			for c in awful.client.iterate(nmtui_window) do
				c:jump_to(false);
				return;
			end
			awful.spawn("alacritty --class nmtui -e bash -c 'nmcli device wifi rescan && nmtui'", false);
		elseif button == 3 then
			awful.spawn.easy_async("nmcli network connectivity check", function(stdout) update_conn(wifi_widget, stdout) end)
		end
	end
	);

	local last_result = ""
	local info_tooltip;
	info_tooltip = awful.tooltip {
		objects = { wifi_widget },
		timer_function = function()
			awful.spawn.easy_async_with_shell(NET_INFO_CMD:format(interface), function(result)
				local formatted = result:gsub("GENERAL.CONNECTION:", "ssid: "):gsub("IP4.ADDRESS....", "ip  : "):sub(0, -2)
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

return setmetatable(wifi_widget, { __call = function(_, ...)
	return worker(...);
end
});
