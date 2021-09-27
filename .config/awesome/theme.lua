local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
local spotify_widget = require("widgets.spotify")


local theme = {}

theme.font														          = "sans-serif 9"
theme.hotkeys_font															= "sans-serif bold 9"
theme.hotkeys_description_font									= theme.font

theme.hotkeys_modifiers_fg											= "#dddddd"
theme.hotkeys_fg																= "#cccccc"

local walldir																		= "/usr/share/backgrounds/"
theme.wallpapers																= {walldir .. "ign_waifu.png", walldir .. "scene.png"}

theme.bg_normal                                 = "#101010"
theme.bg_focus                                  = "#000000"
theme.bg_urgent                                 = "#000000"
theme.fg_normal                                 = "#aaaaaa"
theme.fg_focus                                  = "#ff8c00"
theme.fg_urgent                                 = "#af1d18"
theme.fg_minimize                               = "#ffffff"

theme.bg_wibar 																	= "#000000aa"
theme.bg_systray 																= "#272727"

theme.border_width                              = dpi(1.5)
theme.border_normal                             = "#1c2022"
theme.border_focus                              = "#32a2a8"
theme.border_marked                             = "#3ca4d8"

theme.menu_height																= 34
theme.menu_width													  	 	=	140
theme.menu_font 																= "sans-serif 12"
theme.menu_bg_normal                            = "#101010"
theme.menu_bg_focus                             = "#444444"
theme.menu_border_width                         = 5
theme.menu_border_color                         = "#00000000"
theme.menu_fg_normal                            = "#dddddd"
theme.menu_fg_focus                             = theme.menu_fg_normal

local icondir																		= gears.filesystem.get_configuration_dir() .. "icons/"
theme.widget_cpu                                = icondir .. "cpu.png"
theme.widget_mem                                = icondir .. "mem.png"
theme.widget_batt                               = icondir .. "bat.png"
theme.widget_clock                              = icondir .. "clock.png"
theme.widget_temp                               = icondir .. "temp.png"
-- theme.widget_netdown                            = theme.icondir .. "net_down.png"
-- theme.widget_netup                              = theme.icondir .. "net_up.png"
-- theme.widget_vol                                = theme.icondir .. "spkr.png"

theme.menu_launcher 														= icondir .. "arch.png"
theme.menu_lock_icon														=	icondir .. "lock.svg" 
theme.menu_logout_icon													=	icondir .. "log-out.svg"
theme.menu_reboot_icon													=	icondir .. "refresh-cw.svg"
theme.menu_power_icon														=	icondir .. "power.svg"

theme.taglist_font 															= "sans-serif semi-bold italic 10"
-- theme.taglist_shape 													= function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 4) end
-- theme.taglist_shape 													= function(cr, w, h) gears.shape.parallelogram(cr, w, h, w*0.87) end
-- theme.taglist_shape_border_width 						= 5
-- theme.taglist_shape_border_color 						= "#00000000"
-- theme.taglist_bg_focus 											= "#185a7a"
-- theme.taglist_fg_focus 											= "#ffffff"
theme.taglist_bg_focus 													= "#00000000"
theme.taglist_fg_focus 													= "#42adf0"
theme.taglist_fg_occupied 											= "#a6a6a6"
theme.taglist_fg_empty 													= "#555555"

-- theme.tasklist_plain_task_name               = true
-- theme.tasklist_disable_icon                  = true
theme.useless_gap                               = 5

-- theme.layout_tile                            = icondir .. "tile.png"
-- theme.layout_tilegaps                        = icondir .. "tilegaps.png"
-- theme.layout_tileleft                        = icondir .. "tileleft.png"
-- theme.layout_tilebottom                      = icondir .. "tilebottom.png"
-- theme.layout_tiletop                         = icondir .. "tiletop.png"
-- theme.layout_fairv                           = icondir .. "fairv.png"
-- theme.layout_fairh                           = icondir .. "fairh.png"
-- theme.layout_spiral                          = icondir .. "spiral.png"
-- theme.layout_dwindle                         = icondir .. "dwindle.png"
-- theme.layout_max                             = icondir .. "max.png"
-- theme.layout_fullscreen                      = icondir .. "fullscreen.png"
-- theme.layout_magnifier                       = icondir .. "magnifier.png"
-- theme.layout_floating                        = icondir .. "floating.png"

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

-- Coretemp
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#f1af5f", coretemp_now .. "°C "))
    end
})

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_batt)
local bat = lain.widget.bat({
    settings = function()
        local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc

        if bat_now.ac_status == 1 then
            perc = perc .. " plug"
        end

        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, perc .. " "))
    end
})

-- -- ALSA volume
-- local volicon = wibox.widget.imagebox(theme.widget_vol)
-- theme.volume = lain.widget.alsa({
--     settings = function()
--         if volume_now.status == "off" then
--             volume_now.level = volume_now.level .. "M"
--         end
--         widget:set_markup(markup.fontfg(theme.font, "#7493d2", volume_now.level .. "% "))
--     end
-- })


-- Net
-- local netdownicon = wibox.widget.imagebox(theme.widget_netdown)
-- local netdowninfo = wibox.widget.textbox()
-- local netupicon = wibox.widget.imagebox(theme.widget_netup)
-- local netupinfo = lain.widget.net({
--     settings = function()
--         widget:set_markup(markup.fontfg(theme.font, "#e54c62", net_now.sent .. " "))
--         netdowninfo:set_markup(markup.fontfg(theme.font, "#87af5f", net_now.received .. " "))
--     end
-- })


-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#e0da37", mem_now.used .. "M "))
    end
})


function theme.at_screen_connect(s)
    local wallpaper = theme.wallpapers[s.index]
    gears.wallpaper.maximized(wallpaper, s)

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

    -- -- Create a tasklist widget
		-- s.mytasklist = awful.widget.tasklist {
		-- 	screen = s,
		-- 	filter = awful.widget.tasklist.filter.currenttags,
		-- 	buttons = awful.util.tasklist_buttons
		-- }


		s.mytaglist = awful.widget.taglist {
			screen = s,
			filter = awful.widget.taglist.filter.all,
			buttons = awful.util.taglist_buttons,
			-- style   = {
      --   shape = gears.shape.powerline
    	-- }
		}

		--Systray Container
		function trayshape(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, 25) end
		local mysystray = wibox.container.margin(wibox.widget {
			{
				wibox.widget.systray(true),
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

		-- Menu
		awful.util.mymainmenu.wibox.shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
		local menulauncher = awful.widget.launcher({ image = theme.menu_launcher, menu = awful.util.mymainmenu })

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
		
    -- Create the wibox
    s.mywibox = awful.wibox({ position = "top", screen = s, bg = theme.bg_wibar, fg = theme.fg_normal })
		
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            menulauncher,
            s.mytaglist,
        },
        -- s.mytasklist, -- Middle widget
        nil,
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- netdownicon,
            -- netdowninfo,
            -- netupicon,
            -- netupinfo.widget,
						spotify_widget(),
            volicon,
            -- theme.volume.widget,
            memicon,
            memory.widget,
            cpuicon,
            cpu.widget,
            tempicon,
            temp.widget,
            baticon,
            bat.widget,
            clockicon,
            mytextclock,
						mysystray,
					},
    }

end

client.connect_signal("manage", function (c)
    c.shape = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end
end)

return theme
