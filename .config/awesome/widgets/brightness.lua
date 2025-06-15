-------------------------------------------------
-- Brightness widget
-- Launches fixmonitors script on right click
-------------------------------------------------

local awful     = require("awful");
local wibox     = require("wibox");
local gears     = require("gears")
local beautiful = require("beautiful")
local naughty   = require("naughty")

local worker    = function(screen)
	local monitor = (screen.index == 1 and "sysfs/backlight/auto" or "sysfs/backlight/ddcci1")

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
		end,

		increase_brightness = function(self)
			awful.spawn(string.format("light -s '%s' -A 5", monitor), false);
		end,

		max_brightness = function(self)
			awful.spawn(string.format("light -s '%s' -S 100", monitor), false)
		end,

		decrease_brightness = function(self)
			awful.spawn(string.format("light -s '%s' -U 5", monitor), false);
		end,

		force_refresh = function(self)
			awful.spawn.easy_async("light -s '%s' -G", function(brightness_str, _, _, _)
				local brightness_int = math.ceil(tonumber(brightness_str));

				-- round brightness to next multiple of 5
				if brightness_int % 5 ~= 0 then
					local rounded_brightness = math.floor(brightness_int / 5 + 0.5) * 5
					awful.spawn(string.format("light -s '%s' -S %d", monitor, rounded_brightness), false);
					naughty.notify({
						preset = naughty.config.presets.low,
						title = "Brightness Override",
						text = string.format("Anomaly Fixed:  %d -> %d", brightness_int, rounded_brightness),
						timeout = 1,
					})
					brightness_int = rounded_brightness
				end
				self:update_brightness(brightness_int)
			end)
		end
	}

	gears.timer {
		timeout   = timeout,
		call_now  = true,
		autostart = true,
		callback  = function() brightness_widget:force_refresh() end
	}

	--- Adds mouse controls to the widget:
	--  - left click - max brightness
	--  - scroll up - brightness up
	--  - scroll down - brightness down
	--  - right click - fix monitors
	brightness_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			brightness_widget:max_brightness()
		elseif button == 4 then
			brightness_widget:increase_brightness()
		elseif button == 5 then
			brightness_widget:decrease_brightness()
		elseif button == 3 then
			awful.spawn("fixmonitors", false)
			return
		end
		brightness_widget:force_refresh()
	end
	);

	return brightness_widget;
end;

return worker;
