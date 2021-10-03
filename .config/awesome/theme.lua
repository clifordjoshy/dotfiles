local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")

local spotify_widget = require("widgets.spotify")
local volume_widget = require("widgets.pipewire")
local wifi_widget = require("widgets.wifi")
local brightness_widget = require("widgets.brightness")


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

theme.taglist_font               = "sans-serif semi-bold italic 10"
theme.taglist_bg_focus           = "#00000000"
theme.taglist_bg_urgent          = "#00000000"
theme.taglist_fg_focus           = "#42adf0"
theme.taglist_fg_occupied        = "#a6a6a6"
theme.taglist_fg_urgent          = theme.taglist_fg_occupied
theme.taglist_fg_empty           = "#555555"

theme.screen_indicator_color     = theme.taglist_fg_focus
theme.screen_indicator_radius    = 15

-- theme.tasklist_plain_task_name   = true
-- theme.tasklist_disable_icon      = true
theme.useless_gap                = 5

local markup = lain.util.markup

-- Textclock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local mytextclock = wibox.widget.textclock(markup("#7788af", "%A %d %B ") .. markup("#ab7367", ">") .. markup("#de5e1e", " %I:%M %p "))
mytextclock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
		followtag = true,
		icons = "",
    notification_preset = {
        font = "monospace 10",
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})
mytextclock:disconnect_signal("mouse::enter", theme.cal.hover_on)
mytextclock:buttons(awful.util.table.join(
	awful.button({}, 1, function() 
			if theme.cal.notification then
				theme.cal.hide()
			else
				theme.cal.hover_on()
			end
		end
	),
	awful.button({}, 5, theme.cal.prev),
	awful.button({}, 4, theme.cal.next))
)

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#e33a6e", cpu_now.usage .. "% "))
    end
})

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_batt)
local bat = lain.widget.bat({
    settings = function()
        local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or "..."

        if bat_now.ac_status == 1 then
            perc = perc .. " A/C"
        end

        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, perc .. " "))
    end
})

-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#e0da37", mem_now.used .. "M "))
    end
})


-- Systray Container
function trayshape(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, 25) end
local mysystray = wibox.container.margin(wibox.widget {
	{
		wibox.widget.systray(),
		left = 10,
		top = 0,
		bottom = 0,
		right = 2,
		widget = wibox.container.margin
	},
	bg = theme.bg_systray,
	shape = trayshape,
	shape_clip = true,
	widget = wibox.container.background
}, 6, 0, 3, 4)


-- Spotify Widget
local my_spotify_widget = spotify_widget({icon = theme.widget_spotify, font=theme.font})

-- Volume Widget
local my_volume_widget = volume_widget({icon = theme.widget_vol, font=theme.font})

-- Wifi Widget
local my_wifi_widget = wifi_widget({icons = theme.widget_net, font=theme.font})

-- Wifi Widget
local my_brightness_widget = brightness_widget({icon = theme.widget_brightness, font=theme.font})


-- Active Screen Indicator Widget
awful.util.screen_indicator.widget = wibox.widget{
	widget = wibox.container.background,
    {
			{
				{widget = wibox.widget.textbox},
				forced_height = theme.screen_indicator_radius,
				forced_width = theme.screen_indicator_radius,
				shape = function(cr, w, h) gears.shape.arc(cr, w, h, 2, 0, 2*math.pi) end,
				shape_clip = true,
				bg = theme.screen_indicator_color,
				widget = wibox.container.background
			},
			top = 3,
			left = 10,
			layout = wibox.container.margin	
    },
}

function theme.at_screen_connect(s)
	gears.wallpaper.maximized(theme.wallpapers[s.index], s)

	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	-- s.mylayoutbox = awful.widget.layoutbox(s)
	-- s.mylayoutbox:buttons(gears.table.join(
	-- 	awful.button({}, 1, function() awful.layout.inc(1) end),
	-- 	awful.button({}, 2, function() awful.layout.set(awful.layout.layouts[1]) end),
	-- 	awful.button({}, 3, function() awful.layout.inc(-1) end)
	-- ))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = awful.util.taglist_buttons,
		-- style   = {
		--   shape = gears.shape.powerline
		-- }
	}

	-- Menu
	local menu_bg = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
	awful.util.mymainmenu.wibox.shape = menu_bg
	local menulauncher = wibox.widget.imagebox(theme.menu_launcher);
	menulauncher:connect_signal("button::press", function(_, _, _, button)
			awful.util.mymainmenu: show({coords = {x = 0, y = 32}})
		end
	)
	-- Hide the menu when the mouse leaves it
	local mouse_in_menu = false
	-- when mouse leaves launcher icon without entering menu. close it
	menulauncher:connect_signal("mouse::leave", function()
			if awful.util.mymainmenu.wibox.visible then
				gears.timer{
					timeout = 0.1,
					autostart = true,
					callback = function () if not mouse_in_menu then awful.util.mymainmenu:hide() end end,
					single_shot = true
				}
			end
		end
	)
	awful.util.mymainmenu.wibox:connect_signal("mouse::enter", function() mouse_in_menu = true end)
	awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() 
			awful.util.mymainmenu:hide()
			mouse_in_menu = false
		end
	)

	-- s.mytasklist = awful.widget.tasklist {
		-- 	screen = s,
		-- 	filter = awful.widget.tasklist.filter.currenttags,
		-- 	buttons = awful.util.tasklist_buttons
		-- }
		-- -- Running clients menu
	local middle_box = wibox.container.place();
	middle_box.content_fill_horizontal = true;
	local mouse_in_client_menu = false

	local client_menu = nil
	
	middle_box:connect_signal("button::press", function(_, _, _, button)
			if button == 3 then
				if(client_menu == nil) then
					local client_list = {}
					local max_len = 5
					for _, c in ipairs(client.get()) do
						table.insert(client_list, {c.class, function() c:jump_to(false) end})
						max_len = math.max(max_len, #c.class)
					end
					if #client_list == 0 then
						return
					end
					table.sort(client_list, function(a, b) return a[1] < b[1] end)
					client_menu = awful.menu({
						items=client_list,
						theme={font = "sans-serif 11", height = #client_list + 20, width = max_len*13 + 10}
					})
					client_menu.wibox.shape = menu_bg
					client_menu.wibox:connect_signal("mouse::enter", function() mouse_in_client_menu = true end)
					client_menu.wibox:connect_signal("mouse::leave", function() 
							client_menu:hide()
							client_menu = nil
							mouse_in_client_menu = false
						end
					)
					client_menu:show()
				
				else
					client_menu:hide()
					client_menu = nil
				end	
			end
		end
	)
	middle_box:connect_signal("mouse::leave", function()
			if client_menu ~= nil then
				gears.timer{
					timeout = 0.1,
					autostart = true,
					callback = function () 
						if not mouse_in_client_menu then 
							client_menu:hide()
							client_menu = nil
						end
					end,
					single_shot = true
				}
			end
		end
	)
	

	-- Create the wibar
	s.mywibar = awful.wibar({ position = "top", screen = s, bg = theme.bg_wibar, fg = theme.fg_normal })

	-- Add widgets to the wibox
	s.mywibar:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			menulauncher,
			s.mytaglist,
			awful.util.screen_indicator,
		},
		middle_box, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			my_spotify_widget,
			my_volume_widget,
			memicon,
			memory.widget,
			cpuicon,
			cpu.widget,
			my_brightness_widget,
			baticon,
			bat.widget,
			my_wifi_widget,
			clockicon,
			mytextclock,
			mysystray,
		},
	}
end

return theme
