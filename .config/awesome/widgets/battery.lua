-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows current battery percentage using the upower daemon
-- Based off of https://github.com/berlam/awesome-upower-battery
-------------------------------------------------

local wibox          = require("wibox");
local upower         = require("lgi").require("UPowerGlib")
local beautiful      = require("beautiful")
local awful          = require("awful")
local gears          = require("gears")

local battery_widget = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  spacing = beautiful.widget_icon_gap,
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    image = beautiful.widget_batt,
  },
  {
    id = "percentage",
    widget = wibox.widget.textbox
  },

  update_text = function(self, percentage, is_charging)
    local perc_str = percentage .. "%"

    if is_charging then
      perc_str = perc_str .. " A/C"
    end

    local battery_markup = string.format("<span foreground='%s'>%s</span>", "#46fff6", perc_str);

    if self.percentage:get_markup() ~= battery_markup then
      self.percentage:set_markup(battery_markup);
    end
  end
}

local function update_widget(device)
  local is_charging = device.state == upower.DeviceState.PENDING_CHARGE or
      device.state == upower.DeviceState.FULLY_CHARGED or
      device.state == upower.DeviceState.CHARGING

  local charge = math.floor(device.percentage);

  if charge <= 10 and not is_charging then
    awful.popup {
      widget = {
        widget = wibox.widget.background,
        bg = beautiful.notification_bg,
        {
          widget = wibox.container.margin,
          margins = 15,
          {
            layout = wibox.layout.fixed.horizontal,
            spacing = 10,
            {
              image = "/usr/share/icons/Papirus-Dark/symbolic/status/battery-level-10-symbolic.svg",
              widget = wibox.widget.imagebox,
              forced_height = 50,
              forced_width = 60
            },
            {
              markup =
              "<b>Battery Low</b>\nBattery level has dropped below 10%.\nShutdown imminent. Recharge immediately.",
              widget = wibox.widget.textbox,
              font = 'sans-serif 12'
            },

          },
        }
      },
      border_color = beautiful.notification_fg,
      border_width = 2,
      ontop = true,
      hide_on_right_click = true,
      type = "dialog",
      placement = awful.placement.centered,
      shape = beautiful.notification_shape,
      visible = true
    }
  end

  battery_widget:update_text(charge, is_charging)
end

gears.timer.delayed_call(function()
  -- get current battery device
  local display_device = upower.Client():get_display_device()
  -- callback for when device updates
  display_device.on_notify = update_widget

  update_widget(display_device)
end

)

--- Adds mouse controls to the widget:
--  - left click - unlimited power mode
battery_widget:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    awful.spawn("unlimited-power", false)
    return
  end
end
);
return battery_widget;
