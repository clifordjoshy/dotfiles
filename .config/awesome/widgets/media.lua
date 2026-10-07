-------------------------------------------------
-- Media Widget for Awesome Window Manager
-------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local lgi = require('lgi')
local Playerctl = lgi.require('Playerctl', '2.0')

local max_length = 20
local dim_opacity = 0.5

local state = {
  players = {},      -- all active player instances
  current_key = nil, -- the player currently being shown on the widget

  advance = function(self)
    local valid_keys = {}
    for k, v in pairs(self.players) do
      if not v.hidden then table.insert(valid_keys, k) end
    end

    if #valid_keys == 0 then
      self.current_key = nil
      return
    elseif #valid_keys == 1 then
      return
    end

    local current_idx = gears.table.hasitem(valid_keys, self.current_key)
    self.current_key = valid_keys[(current_idx % #valid_keys) + 1]
  end
}


local media_widget = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  spacing = beautiful.widget_icon_gap,
  visible = false,
  {
    widget = wibox.widget.separator,
    span_ratio = 0.65,
    color = "#aaaaaa",
    orientation = 'vertical',
    forced_width = 4
  },
  { id = "icon",      widget = wibox.widget.imagebox, image = beautiful.widget_media.default },
  { id = "song_info", widget = wibox.widget.textbox },

  refresh = function(self)
    local active = state.players[state.current_key]
    if not active or active.hidden then
      self.visible = false
      return
    end

    local song_text = gears.string.xml_escape(active.text)

    self.icon.image = active.name == "spotify" and beautiful.widget_media.spotify or beautiful.widget_media.default
    self.song_info:set_markup(string.format("<span foreground='%s'>%s</span>",
      active.name == "spotify" and "#1db954" or "#b5bfe2", song_text))
    self.icon:set_opacity(active.is_playing and 1 or dim_opacity)
    self.song_info:set_opacity(active.is_playing and 1 or dim_opacity)
    self.visible = true
    self:emit_signal("widget::redraw_needed")
  end
}

local ellipsize = function(text, length)
  return utf8.len(text) > length and (text:sub(0, utf8.offset(text, length - 2) - 1) .. "...") or text
end

-- playerctl stuff

local playerctl_manager;

local function on_player_event(player)
  local title = player:get_title() or ""
  local artist = player:get_artist() or ""

  local p_state = state.players[player.player_instance]

  if title == "" and artist == "" then
    p_state.hidden = true
    return
  end

  if title == "" then
    title = "Unknown"
  end

  if artist == "" then
    p_state.text = ellipsize(title, max_length * 2)
  else
    p_state.text = string.format("%s ► %s", ellipsize(title, max_length), ellipsize(artist, max_length))
  end

  -- focus most recently changed player
  p_state.hidden = false
  p_state.is_playing = player.playback_status == "PLAYING"

  state.current_key = player.player_instance
  media_widget:refresh()
end

local function track_player(name_obj)
  local p = Playerctl.Player.new_from_name(name_obj)
  local key = p.player_instance

  state.players[key] = {
    obj = p,
    name = p.player_name,
    text = "Loading...",
    hidden = true,
    is_playing = false,
  }
  if not state.current_key then state.current_key = key end

  p.on_metadata = function() on_player_event(p) end
  p.on_playback_status = function() on_player_event(p) end

  on_player_event(p)
  playerctl_manager:manage_player(p)
end

local function remove_player(p)
  state.players[p.player_instance] = nil
  if state.current_key == p.player_instance then
    state:advance()
    media_widget:refresh()
  end
end

gears.timer.delayed_call(function()
  playerctl_manager = Playerctl.PlayerManager()
  playerctl_manager.on_name_appeared = function(_, name) track_player(name) end
  playerctl_manager.on_player_vanished = function(_, p) remove_player(p) end

  for _, name in ipairs(playerctl_manager.player_names) do track_player(name) end
end)

-- Interaction Controls

media_widget:connect_signal("button::press", function(_, _, _, button)
  local active = state.players[state.current_key]
  if not active then return end

  if button == 1 then
    active.obj:play_pause()
  elseif button == 4 then
    active.obj:previous()
  elseif button == 5 then
    active.obj:next()
  elseif button == 2 then
    state:advance()
    media_widget:refresh()
  elseif button == 3 then
    if active.name == "spotify" then
      for c in awful.client.iterate(function(c) return awful.rules.match(c, { class = "Spotify" }) end) do
        c:jump_to(false); return
      end
    elseif string.find(active.name, "mpv") then
      awful.spawn.easy_async("wmctrl -xa mpv", function() end)
    end
  end
end)

return media_widget
