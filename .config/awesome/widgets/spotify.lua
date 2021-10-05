-------------------------------------------------
-- Spotify Widget for Awesome Window Manager
-- Shows currently playing song on Spotify for Linux client
-- Based off of this:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/spotify-widget
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");

local GET_SPOTIFY_STATUS_CMD = "sp status";
local GET_CURRENT_SONG_CMD = "sp current";

local ellipsize = function(text, length)
	return text:len() > length and length > 0 and text:sub(0, length - 3) .. "..." or text;
end;

local spotify_widget = {};

local worker = function(user_args)

	local args = user_args or {}

	local s_icon = args.icon;
	local font = args.font or "sans-serif 9";
	local dim_when_paused = true;
	local dim_opacity = 0.5;
	local max_length = 20;
	local timeout = 5;
	
	spotify_widget = wibox.widget{
		layout = wibox.layout.fixed.horizontal,
		spacing = args.space,
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = s_icon
		},
		{
			id = "song_info",
			font = font,
			widget = wibox.widget.textbox
		},

		set_status = function(self, is_playing)
			if dim_when_paused then
				self.icon:set_opacity(is_playing and 1 or dim_opacity);
				self.icon:emit_signal("widget::redraw_needed");
				self.song_info:set_opacity(is_playing and 1 or dim_opacity);
				self.song_info:emit_signal("widget::redraw_needed");
			end;
		end,

		set_text = function(self, artist, song)
			local artist_to_display = ellipsize(artist, max_length);
			local title_to_display = ellipsize(song, max_length);
			local song_text = string.format("%s ► %s", title_to_display, artist_to_display);
			local song_markup = string.format("<span font='%s' foreground='%s'>%s</span>", font, "#1db954", song_text);

			if self.song_info:get_markup() ~= song_markup then
				self.song_info:set_markup(song_markup);
			end
		end
	}

	local update_widget_status = function(widget, stdout, _, _, _)
		stdout = string.gsub(stdout, "\n", "");
		widget:set_status(stdout == "Playing" and true or false);
	end;

	local update_widget_text = function(widget, stdout, _, _, _)
		if string.find(stdout, "Error: Spotify is not running.") ~= nil then
			widget:set_text("", "");
			widget:set_visible(false);
			return ;
		end;

		local escaped = string.gsub(stdout, "&", "&amp;");
		local album, _, artist, title = string.match(escaped, "Album%s*(.*)\nAlbumArtist%s*(.*)\nArtist%s*(.*)\nTitle%s*(.*)\n");

		if album ~= nil and title ~= nil and artist ~= nil then
			widget:set_text(artist, title);
			widget:set_visible(true);
		end;
	end;

	watch(GET_SPOTIFY_STATUS_CMD, timeout, update_widget_status, spotify_widget);
	watch(GET_CURRENT_SONG_CMD, timeout, update_widget_text, spotify_widget);

	--- Adds mouse controls to the widget:
	--  - left click - play/pause
	--  - scroll up - play next song
	--  - scroll down - play previous song
	--  - right click - open spotify instance
	spotify_widget:connect_signal("button::press", function(_, _, _, button)
			if button == 1 then
				awful.spawn("sp play", false);
			elseif button == 4 then
				awful.spawn("sp prev", false);
			elseif button == 5 then
				awful.spawn("sp next", false);
			elseif button == 3 then
				local spotify = function(c) return awful.rules.match(c, {class = "Spotify"}) end;
				for c in awful.client.iterate(spotify) do
					c:jump_to(false);
					return;
				end;
			end;
			awful.spawn.easy_async_with_shell("sleep 0.1 && " .. GET_SPOTIFY_STATUS_CMD, 
				function(stdout, stderr, _, _) update_widget_status(spotify_widget, stdout, stderr) end)
			awful.spawn.easy_async_with_shell("sleep 0.5 && " .. GET_CURRENT_SONG_CMD, 
				function(stdout, stderr, _, _) update_widget_text(spotify_widget, stdout, stderr) end)
		end
	);

	return spotify_widget;
end;

return setmetatable(spotify_widget, {	__call = function(_, ...)
		return worker(...);
	end
});
