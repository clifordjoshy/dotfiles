-------------------------------------------------
-- Brightness widget
-- Launches fixmonitors script on right click
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");
local beautiful = require("beautiful")

local worker = function(screen)
	local monitor = (screen.index == 1 and "sysfs/backlight/auto" or "sysfs/backlight/ddcci1")
	local GET_BRIGHTNESS_CMD = string.format("light -s '%s' -G", monitor);

	local icon = beautiful.widget_brightness;
	local timeout = 5;

	local brightness_widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.widget_icon_gap,
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = icon
		},
		{
			id = "brightness",
			widget = wibox.widget.textbox
		},

		update_brightness = function(self, brightness)
			local brightness_markup = string.format("<span foreground='%s'>%d%%</span>", "#c782ff", brightness);

			if self.brightness:get_markup() ~= brightness_markup then
				self.brightness:set_markup(brightness_markup);
			end
		end
	}

	local update_widget = function(widget, stdout, stderr, _, _)
		local parsed = tonumber(stdout)
		if parsed then
			local brightness = math.floor(parsed)
			widget:update_brightness(brightness)
		end
	end;

	watch(GET_BRIGHTNESS_CMD, timeout, update_widget, brightness_widget);

	--- Adds mouse controls to the widget:
	--  - left click - max brightness
	--  - scroll up - brightness up
	--  - scroll down - brightness down
	--  - right click - fix monitors D, timeout, updatescript
	brightness_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			awful.spawn(string.format("light -s '%s' -S 100", monitor), false);
		elseif button == 4 then
			awful.spawn(string.format("light -s '%s' -A 5", monitor), false);
		elseif button == 5 then
			awful.spawn(string.format("light -s '%s' -U 5", monitor), false);
		elseif button == 3 then
			awful.spawn("fixmonitors", false)
			return
		end
		awful.spawn.easy_async(GET_BRIGHTNESS_CMD,
			function(stdout, stderr, _, _) update_widget(brightness_widget, stdout, stderr) end)
	end
	);

	return brightness_widget;
end;

return worker;
