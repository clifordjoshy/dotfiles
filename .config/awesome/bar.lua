local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local media_widget = require("widgets.media")
local volume_widget = require("widgets.pipewire")
local wifi_widget = require("widgets.wifi")
local get_brightness_widget_for_screen = require("widgets.brightness")
local memory_widget = require("widgets.memory")
local cpu_widget = require("widgets.cpu")
local battery_widget = require("widgets.battery")
local clock_widget = require("widgets.datetime")
local menubar_utils = require("menubar.utils")
local caffeine = require("caffeine")

local menu_bg = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
-- [[[ Main Menu
local mymainmenu = awful.menu({
  items = {
    { "lock",      screen_lock,                   beautiful.menu_lock_icon },
    { "log out",   function() awesome.quit() end, beautiful.menu_logout_icon },
    { "reboot",    "reboot",                      beautiful.menu_reboot_icon },
    { "power off", "shutdown now",                beautiful.menu_power_icon },
  },
  theme = {
    height = 34,
    width = 140
  }
})
mymainmenu.wibox.shape = menu_bg

-- if we're in kill mode (kill apps with left click)
local kill_switch = false

local menulauncher = wibox.container.background(wibox.widget.imagebox(beautiful.menu_launcher));

local toggle_kill_switch = function()
  kill_switch = not kill_switch
  menulauncher.bg = kill_switch and '#ff4040' or nil
end

local is_kill_switch_enabled = function()
  return kill_switch
end

menulauncher:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    mymainmenu:show({ coords = { x = 0, y = 32 } })
  elseif button == 2 then
    toggle_kill_switch()
  end
end)


-- if mouse leaves launcher icon without entering menu in 0.1s, close menu
menulauncher:connect_signal("mouse::leave", function()
  if mymainmenu.wibox.visible then
    gears.timer {
      timeout = 0.1,
      autostart = true,
      callback = function() if not mymainmenu.mouse_in then mymainmenu:hide() end end,
      single_shot = true
    }
  end
end
)
mymainmenu.wibox:connect_signal("mouse::enter", function() mymainmenu.mouse_in = true end)
mymainmenu.wibox:connect_signal("mouse::leave", function()
  mymainmenu.mouse_in = false
  mymainmenu:hide()
end)
-- ]]]


-- [[[ Middle Box
local on_middlebar_mouse_button = function(_, _, _, button)
  if button == 3 then
    awful.spawn("rofi -show drun", false)
  elseif button == 2 then
    awful.spawn("rofi -modi window -show window", false)
  elseif button == 4 then
    if mouse.screen ~= awful.screen.focused({ client = true, mouse = false }) then awful.screen.focus(mouse.screen) end
    awful.client.focus.byidx(-1)
  elseif button == 5 then
    if mouse.screen ~= awful.screen.focused({ client = true, mouse = false }) then awful.screen.focus(mouse.screen) end
    awful.client.focus.byidx(1)
  end
end
-- ]]]

-- [[[ Widgets

-- Systray Container
local systray = wibox.container.margin(wibox.widget.systray(), 0, beautiful.systray_icon_spacing, 4, 4)


local function generate_wibar(s)
  -- Brightness Widget
  local my_brightness_widget = get_brightness_widget_for_screen(s)

  s.mytaglist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = gears.table.join(
    -- move to tag on clicking the title
      awful.button({}, 1, function(t) t:view_only() end)
    ),
  }

  s.mytasklist = awful.widget.tasklist {
    screen          = s,
    filter          = awful.widget.tasklist.filter.minimizedcurrenttags,
    buttons         = gears.table.join(
    -- unminimise window
      awful.button({}, 1, function(c) c.minimized = false end)
    ),
    layout          = {
      spacing = 10,
      layout  = wibox.layout.fixed.horizontal
    },
    widget_template = {
      {
        id     = 'appicon',
        widget = wibox.widget.imagebox,
      },
      widget = wibox.container.background,
      -- bg = "#ffffff30",
      -- shape = gears.shape.circle,
      -- shape_border_width = 5,
      -- shape_border_color = "#00000000"
      create_callback = function(self, c)
        local clientclass = string.lower(c.class)
        local icon_theme_icon = menubar_utils.lookup_icon(clientclass) or
            menubar_utils.lookup_icon(string.match(clientclass, "([^-]+)"))
        self.appicon.image = icon_theme_icon or c.icon or beautiful.minimise_def_icon
      end
    }
  }

  local my_middle_widget = wibox.container.place(
    wibox.container.margin(s.mytasklist, 7, 10, 5, 5),
    "left"
  )
  my_middle_widget.fill_horizontal = true
  my_middle_widget:connect_signal("button::press", on_middlebar_mouse_button);

  s.mywibar = awful.wibar({ position = "top", screen = s, bg = beautiful.bg_wibar, fg = beautiful.fg_normal })

  s.mywibar:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      menulauncher,
      s.mytaglist,
      s.mylayoutbox,
      {
        widget = wibox.widget.separator,
        span_ratio = 0.65,
        color = beautiful.fg_normal,
        orientation = 'vertical',
        forced_width = 20
      },
    },
    my_middle_widget,
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      spacing = beautiful.widget_gap,
      spacing_widget = {
        widget = wibox.widget.separator,
        span_ratio = 0.65,
        color = beautiful.fg_normal,
      },
      media_widget,
      volume_widget,
      memory_widget,
      cpu_widget,
      my_brightness_widget,
      battery_widget,
      wifi_widget,
      clock_widget,

      wibox.widget {
        caffeine.widget,
        s.index == 1 and systray or nil,
        layout = wibox.layout.fixed.horizontal -- or wibox.layout.fixed.vertical
      }
    },
  }
end

return {
  generate_wibar = generate_wibar,
  is_kill_switch_enabled = is_kill_switch_enabled,
  toggle_kill_switch = toggle_kill_switch
};
