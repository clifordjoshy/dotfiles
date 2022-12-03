-------------------------------------------------
-- Speaker Volume Widget for Pipewire-Pulse
-- Also toggles noisetorch
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");

-- local GET_SINK_VOL_CMD = "pactl get-sink-volume @DEFAULT_SINK@";
-- local GET_SOURCE_VOL_CMD = "pactl get-source-volume @DEFAULT_SOURCE@";
local NOISETORCH_STATUS_CMD = "pactl get-default-source | grep -q NoiseTorch"

local UPDATE_CMD = "bash -c \"pactl get-sink-volume @DEFAULT_SINK@ | awk '{printf \\\"%s\\\",\\$5}' && pactl get-default-source | grep -q NoiseTorch && echo -n ' N'\""

local volume_widget = {}

local worker = function(user_args)

	local args = user_args or {}

	local icon = args.icon;
	local font = args.font or "sans-serif 9";
	local timeout = 2;

	volume_widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = args.space,
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = icon
		},
		{
			id = "volume",
			font = font,
			widget = wibox.widget.textbox
		},

		update_volume = function(self, text)

			local volume_markup = string.format("<span font='%s' foreground='%s'>%s</span>", font, "#04a5e5", text);

			if self.volume:get_markup() ~= volume_markup then
				self.volume:set_markup(volume_markup);
			end
		end
	}

	local update_widget = function(widget, stdout, stderr, _, _)
		-- if album ~= nil and title ~= nil and artist ~= nil then
		widget:update_volume(stdout);
		-- end;
	end;

	watch(UPDATE_CMD, timeout, update_widget, volume_widget);

	--- Adds mouse controls to the widget:
	--  - left click - pavucontrol
	--  - scroll up - volume up
	--  - scroll down - volume down
	--  - right click - start noisetorch
	volume_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			awful.spawn("pavucontrol");
			return
			-- using amixer instead of pactl to limit volume to 100%
		elseif button == 4 then
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false);
			-- awful.spawn("amixer set Master 5%+", false);
		elseif button == 5 then
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false);
			-- awful.spawn("amixer set Master 5%-", false);
		elseif button == 3 then
			awful.spawn.easy_async_with_shell(NOISETORCH_STATUS_CMD, function(_, _, _, exitcode)
				awful.spawn("noisetorch -" .. (exitcode == 0 and "u" or "i"), false)
			end
			)
		end
		awful.spawn.easy_async(UPDATE_CMD, function(stdout, stderr, _, _) update_widget(volume_widget, stdout, stderr) end)
	end
	);

	return volume_widget;
end;

return setmetatable(volume_widget, { __call = function(_, ...)
	return worker(...);
end
});
