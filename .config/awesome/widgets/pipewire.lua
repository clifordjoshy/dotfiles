-------------------------------------------------
-- Speaker Volume Widget for Pipewire-Pulse
-- Also toggles noisetorch
-------------------------------------------------

local awful                 = require("awful");
local wibox                 = require("wibox");
local gears                 = require("gears");
local beautiful             = require("beautiful");
local naughty               = require("naughty")

local NOISETORCH_STATUS_CMD = "pactl get-default-source | grep -q NoiseTorch"

-- local UPDATE_CMD = "bash -c \"pactl get-sink-volume @DEFAULT_SINK@ | awk '{printf \\\"%s\\\",\\$5}' && pactl get-default-source | grep -q NoiseTorch && echo -n ' N'\""
local UPDATE_CMD            = "bash -c \"pactl get-sink-volume @DEFAULT_SINK@ | awk '{printf \\\"%s\\\",\\$5}'\""

local volume_widget         = {}

local worker                = function()
	local icon = beautiful.widget_vol;
	local timeout = 5;

	volume_widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.widget_icon_gap,
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = icon
		},
		{
			id = "volume",
			widget = wibox.widget.textbox
		},

		update_volume = function(self, text)
			local volume_markup = string.format("<span foreground='%s'>%s</span>", "#04a5e5", text);

			if self.volume:get_markup() ~= volume_markup then
				self.volume:set_markup(volume_markup);
			end
		end,

		increase_volume = function(self)
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false);
		end,

		decrease_volume = function(self)
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false);
		end,

		force_refresh = function(self)
			awful.spawn.easy_async(UPDATE_CMD, function(volume_str, _, _, _)
				local volume_int = math.floor(tonumber(string.sub(volume_str, 1, -3)));

				-- round volume to next multiple of 5
				if volume_int % 5 ~= 0 then
					local rounded_volume = math.floor(volume_int / 5 + 0.5) * 5
					awful.spawn(string.format("pactl set-sink-volume @DEFAULT_SINK@ %d%%", rounded_volume), false);
					naughty.notify({
						preset = naughty.config.presets.low,
						title = "Volume Override",
						text = string.format("Anomaly Fixed:  %d -> %d", volume_int, rounded_volume),
						timeout = 1,
					})
					volume_int = rounded_volume
				end
				self:update_volume(string.format("%d%%", volume_int))
			end)
		end
	}

	gears.timer {
		timeout   = timeout,
		call_now  = true,
		autostart = true,
		callback  = function() volume_widget:force_refresh() end
	}

	--- Adds mouse controls to the widget:
	--  - left click - pavucontrol
	--  - scroll up - volume up
	--  - scroll down - volume down
	--  - right click - start noisetorch
	volume_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			awful.spawn("pavucontrol");
			return
		elseif button == 4 then
			volume_widget:increase_volume()
		elseif button == 5 then
			volume_widget:decrease_volume()
		elseif button == 3 then
			-- awful.spawn.easy_async_with_shell(NOISETORCH_STATUS_CMD, function(_, _, _, exitcode)
			-- 	awful.spawn("noisetorch -" .. (exitcode == 0 and "u" or "i"), false)
			-- end
			-- )
		end
		volume_widget:force_refresh()
	end
	);

	return volume_widget;
end;

return setmetatable(volume_widget, {
	__call = function(_, ...)
		return worker(...);
	end
});
