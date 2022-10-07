local gears = require("gears")

local theme = {}

theme.font                       = "JetBrainsMono 9"
theme.hotkeys_font               = "sans-serif bold 9"
theme.hotkeys_description_font   = "sans-serif 9"

theme.hotkeys_modifiers_fg       = "#dddddd"
theme.hotkeys_fg                 = "#cccccc"

local walldir                    = gears.filesystem.get_configuration_dir() .. "wallpapers/"
theme.wallpapers                 = {walldir .. "wall_1.png", walldir .. "wall_2.png"}

theme.bg_normal                  = "#101010"
theme.bg_focus                   = "#000000"
theme.bg_urgent                  = "#000000"
theme.fg_normal                  = "#aaaaaa"
theme.fg_focus                   = "#ff8c00"
theme.fg_urgent                  = "#af1d18"
theme.fg_minimize                = "#ffffff"

theme.bg_wibar                   = "#1e2127"

theme.border_width               = 2.5
theme.border_focus               = "#32a2a8"
theme.border_normal              = "#00000000"
theme.border_marked              = theme.border_normal

theme.menu_font                  = "sans-serif 12"
theme.menu_bg_normal             = "#101010"
theme.menu_bg_focus              = "#444444"
theme.menu_border_width          = 5
theme.menu_border_color          = "#00000000"
theme.menu_fg_normal             = "#dddddd"
theme.menu_fg_focus              = theme.menu_fg_normal

local icondir                    = gears.filesystem.get_configuration_dir() .. "icons/"
theme.widget_cpu                 = icondir .. "cpu.png"
theme.widget_mem                 = icondir .. "mem.png"
theme.widget_media               = {spotify = icondir .. "spoti.png", default = icondir .. "media.png"}
theme.widget_batt                = icondir .. "bat.png"
theme.widget_clock               = icondir .. "clock.png"
theme.widget_vol                 = icondir .. "spkr.png"
theme.widget_brightness          = icondir .. "brightness.png"
theme.widget_wifi                = {icondir.."wifi_bar_0.png", icondir.."wifi_bar_1.png", icondir.."wifi_bar_2.png", icondir.."wifi_bar_3.png", icondir.."wifi_bar_4.png"} 
theme.widget_eth                 = icondir .. "ethernet.png" 

theme.widget_icon_gap            = 8
theme.widget_gap                 = 20
theme.bg_systray                 = "#1e2127"
theme.systray_icon_spacing       = 5

theme.menu_launcher              = icondir .. "arch.png"
theme.menu_lock_icon             = icondir .. "lock.svg" 
theme.menu_logout_icon           = icondir .. "log-out.svg"
theme.menu_reboot_icon           = icondir .. "refresh-cw.svg"
theme.menu_power_icon            = icondir .. "power.svg"

theme.minimise_def_icon          = icondir .. "minimise_def.png"

theme.taglist_font               = "sans-serif semi-bold italic 10"
theme.taglist_bg_focus           = "#00000000"
theme.taglist_bg_urgent          = "#00000000"
theme.taglist_fg_focus           = "#42adf0"
theme.taglist_fg_occupied        = "#a6a6a6"
theme.taglist_fg_urgent          = theme.taglist_fg_occupied
theme.taglist_fg_empty           = "#555555"

theme.tasklist_bg_normal         = "#00000000"
theme.tasklist_disable_task_name = true
theme.tasklist_plain_task_name   = true
theme.tasklist_bg_normal         = "#dddddd"
theme.useless_gap                = 2.5

theme.notification_font          = "sans-serif 9"
theme.notification_bg            = "#303030"
theme.notification_fg            = "#fafafa"
theme.notification_shape         = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 5) end
theme.notification_border_color  = theme.notification_fg
theme.notification_max_height    = 200
theme.notification_max_width     = 500
theme.notification_icon_size     = 100


return theme
