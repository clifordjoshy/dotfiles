local gears = require("gears")

local theme = {}

theme.font                       = "sans-serif 9"
theme.hotkeys_font               = "sans-serif bold 9"
theme.hotkeys_description_font   = theme.font

theme.hotkeys_modifiers_fg       = "#dddddd"
theme.hotkeys_fg                 = "#cccccc"

local walldir                    = "/usr/share/backgrounds/"
theme.wallpapers                 = {walldir .. "ign_waifu.png", walldir .. "scene.png"}

theme.bg_normal                  = "#101010"
theme.bg_focus                   = "#000000"
theme.bg_urgent                  = "#000000"
theme.fg_normal                  = "#aaaaaa"
theme.fg_focus                   = "#ff8c00"
theme.fg_urgent                  = "#af1d18"
theme.fg_minimize                = "#ffffff"

theme.bg_wibar                   = "#000000aa"
theme.bg_systray                 = "#272727"

theme.border_width               = 3
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
theme.widget_spotify             = icondir .. "spoti.png"
theme.widget_batt                = icondir .. "bat.png"
theme.widget_clock               = icondir .. "clock.png"
theme.widget_vol                 = icondir .. "spkr.png"
theme.widget_brightness          = icondir .. "brightness.png"
theme.widget_net                 = {icondir.."wifi_bar_0.png", icondir.."wifi_bar_1.png", icondir.."wifi_bar_2.png", icondir.."wifi_bar_3.png", icondir.."wifi_bar_4.png"} 

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
theme.useless_gap                = 5

return theme