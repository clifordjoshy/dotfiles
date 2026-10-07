-------------------------------------------------
-- Speaker Volume Widget for Pipewire-Pulse
-------------------------------------------------

local awful         = require("awful");
local wibox         = require("wibox");
local beautiful     = require("beautiful");
local naughty       = require("naughty");
local gears         = require("gears");

local volume_widget = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  spacing = beautiful.widget_icon_gap,
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    image = beautiful.widget_vol
  },
  {
    id = "volume",
    widget = wibox.widget.textbox
  },

  update_volume_text = function(self, volume, is_muted)
    local volume_str = is_muted and "~~~" or string.format("%d%%", volume)
    local volume_markup = string.format("<span foreground='%s'>%s</span>", "#04a5e5", volume_str);

    if self.volume:get_markup() ~= volume_markup then
      self.volume:set_markup(volume_markup);
    end
  end,
}


local fetch_volume = function()
  awful.spawn.easy_async_with_shell(
    "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@",
    function(stdout, _, _, _)
      if not stdout then
        return
      end
      local volume = tonumber(stdout:match("(%d+)%%")) or 0
      local is_muted = stdout:match("Mute: yes") ~= nil


      local volume_int = math.floor(volume);
      if volume_int % 5 ~= 0 then
        -- round volume to next multiple of 5
        local rounded_volume = math.floor(volume_int / 5 + 0.5) * 5
        naughty.notify({
          preset = naughty.config.presets.low,
          title = "Volume Override",
          text = string.format("Anomaly Fixed:  %d -> %d", volume_int, rounded_volume),
          timeout = 1,
        })
        awful.spawn(
          string.format("pactl set-sink-volume @DEFAULT_SINK@ %d%%", volume_int),
          false
        );
        return
      end

      volume_widget:update_volume_text(volume, is_muted)
    end
  )
end

-- startup
gears.timer.delayed_call(fetch_volume)

awful.spawn.with_line_callback("pactl subscribe", {
  stdout = function(line)
    if line:match("Event 'change' on sink") then
      fetch_volume()
    end
  end
})

--- Adds mouse controls to the widget:
--  - left click - pavucontrol
--  - scroll up - volume up
--  - scroll down - volume down
volume_widget:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    awful.spawn("pavucontrol");
    return
  elseif button == 4 then
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false);
  elseif button == 5 then
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false);
  end
end
);

return volume_widget;
