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

		max_brightness = function(self)
			self:set_screen_brightness(100)
		end,

		increase_brightness = function(self)
			if monitor_index == 0 then
				awful.spawn("light -A 5", false);
			else
				self:_ddcutil_with_bus_number("setvcp 10 + 5")
			end
		end,

		set_screen_brightness = function(self, brightness_int)
			if monitor_index == 0 then
				awful.spawn(string.format("light -S %d", brightness_int), false)
			else
				self:_ddcutil_with_bus_number("setvcp 10 %d", brightness_int)
			end
		end,

		decrease_brightness = function(self)
			if monitor_index == 0 then
				awful.spawn("light -U 5", false);
			else
				self:_ddcutil_with_bus_number("setvcp 10 - 5")
			end
		end,

		force_refresh = function(self)
			local handler = function(brightness)
				local brightness_num = tonumber(brightness);
				if not brightness_num then
					return
				end
				local brightness_int = math.ceil(brightness_num);

				-- round brightness to next multiple of 5
				if brightness_int % 5 ~= 0 then
					local rounded_brightness = math.floor(brightness_int / 5 + 0.5) * 5
					self:set_screen_brightness(rounded_brightness)
					naughty.notify({
						preset = naughty.config.presets.low,
						title = "Brightness Override",
						text = string.format("Anomaly Fixed:  %d -> %d", brightness_int, rounded_brightness),
						timeout = 1,
					})
					brightness_int = rounded_brightness
				end

				self:update_brightness_text(brightness_int)
			end

			if monitor_index == 0 then
				awful.spawn.easy_async("light -G", handler)
			else
				self:_ddcutil_with_bus_number('-t getvcp 10', function(stdout)
					-- output looks like:  VCP 10 C 30 100
					local curr = gears.string.split(stdout, " ")[4]
					handler(curr)
				end)
			end
		end,


		_ddcutil_with_bus_number = function(self, args_str, handler, skip_retry)
			local _refetch_ddc_bus_number_and_run = function()
				local ddc_bus_cmd = string.format(
					'bash -c "ddcutil detect | grep -A 1 \'Display %d\' | tail -1 | cut -d\'-\' -f2"',
					monitor_index)
				awful.spawn.easy_async(ddc_bus_cmd, function(bus_number_str)
					local bus_number = tonumber(bus_number_str);
					if not bus_number then
						return
					end
					self._ddc_bus_number = bus_number
					self:_ddcutil_with_bus_number(args_str, handler, true)
				end)
			end

			if self._ddc_bus_number ~= nil then
				local cmd = string.format("ddcutil -b %d %s", self._ddc_bus_number, args_str)

				awful.spawn.easy_async(cmd, function(stdout, stderr, reason, exit_code)
					if exit_code == 0 then
						if handler then
							handler(stdout, stderr, reason, exit_code)
						end
					else
						if not skip_retry then
							_refetch_ddc_bus_number_and_run()
						end
					end
				end)
			else
				_refetch_ddc_bus_number_and_run()
			end
		end,

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
