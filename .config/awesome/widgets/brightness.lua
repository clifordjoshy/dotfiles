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
	local monitor_index = screen.index - 1

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

		update_brightness_text = function(self, brightness)
			local brightness_markup = string.format("<span foreground='%s'>%d%%</span>", "#c782ff", brightness);

			if self.brightness:get_markup() ~= brightness_markup then
				self.brightness:set_markup(brightness_markup);
			end
		end,

		increase_brightness = function(self)
			if monitor_index == 0 then
				awful.spawn("light -A 5", false);
			else
				awful.spawn(string.format("ddcutil -d %d setvcp 10 + 5", monitor_index), false)
			end
		end,


		set_brightness = function(self, brightness_int)
			if monitor_index == 0 then
				awful.spawn(string.format("light -S %d", brightness_int), false)
			else
				awful.spawn(string.format("ddcutil -d %d setvcp 10 %d", monitor_index, brightness_int), false)
			end
		end,

		max_brightness = function(self)
			self:set_brightness(100)
		end,

		decrease_brightness = function(self)
			if monitor_index == 0 then
				awful.spawn("light -U 5", false);
			else
				awful.spawn(string.format("ddcutil -d %d setvcp 10 - 5", monitor_index), false)
			end
		end,

		force_refresh = function(self)
			local cmd = ""
			if monitor_index == 0 then
				cmd = "light -G"
			else
				cmd = string.format('bash -c "ddcutil -t -d %d getvcp 10 | tail -1 | cut -d\' \' -f4"', monitor_index)
			end
			awful.spawn.easy_async(cmd, function(brightness_str, _, _, _)
				local brightness_num = tonumber(brightness_str);
				if not brightness_num then
					return
				end
				local brightness_int = math.ceil(brightness_num);

				-- round brightness to next multiple of 5
				if brightness_int % 5 ~= 0 then
					local rounded_brightness = math.floor(brightness_int / 5 + 0.5) * 5
					self:set_brightness(rounded_brightness)
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
