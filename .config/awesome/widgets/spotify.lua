-------------------------------------------------
-- Spotify Widget for Awesome Window Manager
-- Shows currently playing song on Spotify for Linux client
-- Based off of this:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/spotify-widget
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local markup = require("lain").util.markup

local GET_SPOTIFY_STATUS_CMD = 'sp status'
local GET_CURRENT_SONG_CMD = 'sp current'

local function ellipsize(text, length)
    return (text:len() > length and length > 0)
        and text:sub(0, length - 3) .. '...'
        or text
end

local spotify_widget = {}

local function worker(user_args)

    local args = user_args or {}

    local s_icon = '/home/cliford/.config/awesome/icons/spoti.png'
    local font = 'Noto Sans 9'
    local dim_when_paused = true
    local dim_opacity = 0.5
    local max_length = 20

    spotify_widget = wibox.widget {
				layout = wibox.layout.align.horizontal,
				{
						id = "icon",
						widget = wibox.widget.imagebox,
						image = s_icon,
				},
        {
            id = 'song_info',
            font = font,
            widget = wibox.widget.textbox,
        },

        set_status = function(self, is_playing)
            if dim_when_paused then
                self:get_children_by_id('icon')[1]:set_opacity(is_playing and 1 or dim_opacity)
                self:get_children_by_id('icon')[1]:emit_signal('widget::redraw_needed')

                self:get_children_by_id('song_info')[1]:set_opacity(is_playing and 1 or dim_opacity)
                self:get_children_by_id('song_info')[1]:emit_signal('widget::redraw_needed')
            end
        end,

        set_text = function(self, artist, song)
            local artist_to_display = ellipsize(artist, max_length)
						local title_to_display = ellipsize(song, max_length)
						local song_text = string.format("%s | %s ", title_to_display, artist_to_display)
	
            if self:get_children_by_id('song_info')[1]:get_markup() ~= song_text then
                self:get_children_by_id('song_info')[1]:set_markup(markup.fontfg(font, "#1db954", song_text))
            end
        end
    }

    local update_widget_status = function(widget, stdout, _, _, _)
        stdout = string.gsub(stdout, "\n", "")
        widget:set_status(stdout == 'Playing' and true or false)
    end

    local update_widget_text = function(widget, stdout, _, _, _)
        if string.find(stdout, 'Error: Spotify is not running.') ~= nil then
            widget:set_text('','')
            widget:set_visible(false)
            return
        end

        local escaped = string.gsub(stdout, "&", '&amp;')
        local album, _, artist, title =
            string.match(escaped, 'Album%s*(.*)\nAlbumArtist%s*(.*)\nArtist%s*(.*)\nTitle%s*(.*)\n')

        if album ~= nil and title ~=nil and artist ~= nil then
            widget:set_text(artist, title)
            widget:set_visible(true)
        end
    end

    watch(GET_SPOTIFY_STATUS_CMD, timeout, update_widget_status, spotify_widget)
    watch(GET_CURRENT_SONG_CMD, timeout, update_widget_text, spotify_widget)

    --- Adds mouse controls to the widget:
    --  - left click - play/pause
    --  - scroll up - play next song
    --  - scroll down - play previous song
    spotify_widget:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            awful.spawn("sp play", false)      -- left click
        elseif (button == 4) then
            awful.spawn("sp prev", false)  -- scroll up
        elseif (button == 5) then
            awful.spawn("sp next", false)  -- scroll down
        end
        awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_status(spotify_widget, stdout, stderr, exitreason, exitcode)
        end)
    end)

    return spotify_widget

end

return setmetatable(spotify_widget, { __call = function(_, ...)
    return worker(...)
end })