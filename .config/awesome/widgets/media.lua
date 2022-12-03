-------------------------------------------------
-- Media Widget for Awesome Window Manager
-- Shows currently playing media using playerctl
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local watch = require("awful.widget.watch");
local beautiful = require("beautiful");

local GET_PLAYER_INFO = "playerctl metadata -af '{{playerName}}/#/{{title}}/#/{{artist}}/#/{{status}}'"

local ellipsize = function(text, length)
	if utf8.len(text) > length then
		return text:sub(0, utf8.offset(text, length - 2) - 1) .. "..."
	end
	return text
end

local media_widget = {};

local worker = function()

	local spotify_icon = beautiful.widget_media.spotify;
	local default_icon = beautiful.widget_media.default;

	local dim_opacity = 0.5;
	local max_length = 20;
	local timeout = 1;

	local player_info = {}
	local current_player = nil

	--if player override> 0 skip player updates until that many turns [to see the choice before going back to top player]
	local player_override = 0

	media_widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.widget_icon_gap,
		-- throwing in a separator here because i can't think of a better way to hide the sep when spotify is closed
		{
			widget = wibox.widget.separator,
			span_ratio = 0.65,
			color = "#aaaaaa",
			orientation = 'vertical',
			forced_width = 4
		},
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = default_icon
		},
		{
			id = "song_info",
			widget = wibox.widget.textbox
		},

		update_markup = function(self)
			self.icon.image = current_player == "spotify" and spotify_icon or default_icon
			if self.song_info:get_markup() ~= player_info[current_player].text then
				self.song_info:set_markup(player_info[current_player].text);
			end

			self.icon:set_opacity(player_info[current_player].playing and 1 or dim_opacity);
			self.song_info:set_opacity(player_info[current_player].playing and 1 or dim_opacity);
			self:emit_signal("widget::redraw_needed");
		end
	}


	local update_widget = function(widget, stdout, stderr)
		-- all players have been closed
		if stderr ~= '' then
			current_player = nil
			if widget:get_visible() then
				widget:set_visible(false);
			end
			return;
		end

		-- some player has been opened
		if current_player == nil then
			widget:set_visible(true);
		end

		player_info = {}
		local current_player_exists = false;
		local top_player = nil;

		--escape ampersand character
		local escaped = string.gsub(stdout, "&", "&amp;");

		for p in string.gmatch(escaped, "([^\n]*)\n") do
			local player, title, artist, status = string.match(p, "(.*)/#/(.*)/#/(.*)/#/(.*)")
			local song_text;
			if artist == '' then
				song_text = ellipsize(title, 2 * max_length)
			else
				song_text = string.format("%s ► %s", ellipsize(title, max_length), ellipsize(artist, max_length));
			end

			local song_markup = string.format("<span foreground='%s'>%s</span>",
				player == "spotify" and "#1db954" or "#b5bfe2", song_text);
			while player_info[player] ~= nil do
				player = player .. ' '
			end
			player_info[player] = { text = song_markup, playing = status == "Playing" };

			-- find highest priority player [first in list]
			if top_player == nil then
				top_player = player
			end
			-- if player override, check if the current_player still exists
			if current_player == player then
				current_player_exists = true
			end
		end

		if current_player_exists and player_override > 0 then
			player_override = player_override - 1
		else
			current_player = top_player
		end

		widget:update_markup()
	end;

	watch(GET_PLAYER_INFO, timeout, update_widget, media_widget);

	--- Adds mouse controls to the widget:
	--  - left click - play/pause
	--  - scroll up - play next song
	--  - scroll down - play previous song
	--  - right click - open instance if current player is spotify/mpv
	--  - middle click - go to next player
	media_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			awful.spawn("playerctl play-pause --player=" .. current_player, false);
		elseif button == 4 then
			awful.spawn("playerctl previous --player=" .. current_player, false);
		elseif button == 5 then
			awful.spawn("playerctl next --player=" .. current_player, false);
		elseif button == 3 then
			if current_player == "spotify" then
				for c in awful.client.iterate(function(c) return awful.rules.match(c, { class = "Spotify" }) end) do
					c:jump_to(false);
					return
				end
			elseif string.find(current_player, "mpv") then
				awful.spawn("wmctrl -xa mpv", false);
			end
		elseif button == 2 then
			k, _ = next(player_info, current_player)
			if k == nil then
				k, _ = next(player_info, nil)
			end
			current_player = k
			player_override = 2
			media_widget:update_markup()
		end

		awful.spawn.easy_async_with_shell("sleep 0.1 && " .. GET_PLAYER_INFO,
			function(stdout, stderr, _, _) update_widget(media_widget, stdout, stderr) end)
	end
	);

	return media_widget;
end;

return setmetatable(media_widget, { __call = function(_, ...)
	return worker(...);
end
});
