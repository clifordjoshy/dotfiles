-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows current battery percentage using the upower daemon
-- Based off of https://github.com/berlam/awesome-upower-battery
-------------------------------------------------

local wibox = require("wibox");
local upower   = require("lgi").require("UPowerGlib")
local naughty = require("naughty")

local battery_widget = {}

function update_widget (device)

	local is_charging = device.state == upower.DeviceState.PENDING_CHARGE or
											device.state == upower.DeviceState.FULLY_CHARGED or
											device.state == upower.DeviceState.CHARGING

	battery_widget:update_battery(math.floor(device.percentage), is_charging)
end

-- get current battery device
local display_device = upower.Client():get_display_device()
-- callback for when device updates
display_device.on_notify = update_widget

local worker = function(user_args)

	local args = user_args or {}

	local icon = args.icon;
	local font = args.font or "sans-serif 9";

	battery_widget = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		spacing = args.space,
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = icon
		},
		{
			id = "percentage",
			font = font,
			widget = wibox.widget.textbox
		},

		update_battery = function(self, percentage, is_charging)
			local perc_str = percentage .. "%"

			if is_charging then
				perc_str = perc_str .. " A/C"
			end

			local battery_markup = string.format("<span font='%s' foreground='%s'>%s</span>", font, "#46fff6", perc_str);

			if self.percentage:get_markup() ~= battery_markup then
				if percentage <= 10 and not is_charging then
					naughty.notify({
						title = "Battery Low",
						text = "Battery level has dropped below 10%.\nShutdown imminent. Recharge immediately.",
						icon = "/usr/share/icons/Adwaita/32x32/status/battery-level-10-charging-symbolic.symbolic.png",
						timeout = 0
					})
				end
				self.percentage:set_markup(battery_markup);
			end
		end
	}
	update_widget(display_device)
	return battery_widget;
end;

return setmetatable(battery_widget, {	__call = function(_, ...)
		return worker(...);
	end
});
