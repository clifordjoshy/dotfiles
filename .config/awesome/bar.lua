local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local markup = lain.util.markup

local spotify_widget = require("widgets.spotify")
local volume_widget = require("widgets.pipewire")
local wifi_widget = require("widgets.wifi")
local brightness_widget = require("widgets.brightness")


local menu_bg = function (cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
-- [[[ Main Menu
local mymainmenu = awful.menu({
	items = {
		{"lock", "slock", beautiful.menu_lock_icon},
		{"log out", function() awesome.quit() end, beautiful.menu_logout_icon},
		{"reboot", "reboot", beautiful.menu_reboot_icon},
		{"power off", "shutdown now", beautiful.menu_power_icon},
	},
	theme = {
		height = 34,
		width = 140
	}
})
mymainmenu.wibox.shape = menu_bg

local menulauncher = wibox.widget.imagebox(beautiful.menu_launcher);
menulauncher:connect_signal("button::press", function(_, _, _, button) mymainmenu:show({coords = {x = 0, y = 32}}) end)

-- Hide the menu when the mouse leaves it
local mouse_in_main = false
-- when mouse leaves launcher icon without entering menu. close it
menulauncher:connect_signal("mouse::leave", function()
		if mymainmenu.wibox.visible then
			gears.timer{
				timeout = 0.1,
				autostart = true,
				callback = function () if not mouse_in_main then mymainmenu:hide() end end,
				single_shot = true
			}
		end
	end
)
mymainmenu.wibox:connect_signal("mouse::enter", function() mouse_in_main = true end)
mymainmenu.wibox:connect_signal("mouse::leave", function() 
		mymainmenu:hide()
		mouse_in_main = false
	end
)
-- ]]]


-- [[[ Middle Box [with client menu]
local middle_box = wibox.container.place();
middle_box.content_fill_horizontal = true;
local mouse_in_client_menu = false
local client_menu = nil
	
middle_box:connect_signal("button::press", function(_, _, _, button)
		if button == 3 then
			-- if not currently visible
			if(client_menu == nil) then
				local client_list = {}
				local max_len = 5			--biggest width. to set appropriate size for menu

				for _, c in ipairs(client.get()) do
					table.insert(client_list, {c.class, function() c:jump_to(false) end})
					max_len = math.max(max_len, #c.class)
				end
				if #client_list == 0 then return end

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
				single_shot = true,
				autostart = true,
				callback = function () 
					if not mouse_in_client_menu then 
						client_menu:hide()
						client_menu = nil
					end
				end,
			}
		end
	end
)
-- ]]]

-- [[[Taglist //tasklist
local taglist_buttons = gears.table.join(
	-- move to tag on clicking the title
	awful.button({}, 1, function(t) t:view_only() end),
	-- move focused window to clicked tag
	awful.button({modkey}, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end
	),
	-- adds focused window to the clicked tag also
	awful.button({modkey}, 3, function(t)
			if client.focus then
				client.focus:toggle_tag(t)
			end
		end
	),
	-- moves between tags on scroll wheel
	awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({}, 5,	function(t)	awful.tag.viewprev(t.screen) end)
)

-- awful.util.tasklist_buttons = gears.table.join(
-- 	-- minimises window if in focus, else activates(unminimise/focus) it
-- 	awful.button({}, 1, function(c)
-- 			if c == client.focus then
-- 				c.minimized = true
-- 			else
-- 				c:emit_signal("request::activate", "tasklist", {raise = true})
-- 			end
-- 		end
-- 	),
-- 	-- show list of all running windows
-- 	awful.button({}, 3, function() awful.menu.client_list({theme = {width = 250}}) end)
-- 	-- cycle focus between windows on screen
-- 	-- awful.button({}, 4, function() awful.client.focus.byidx(1) end),
-- 	-- awful.button({}, 5, function() awful.client.focus.byidx(-1) end))
-- )

-- ]]]

-- [[[ Widgets

-- Textclock
local clockicon = wibox.widget.imagebox(beautiful.widget_clock)
local mytextclock = wibox.widget.textclock(markup("#7788af", "%A %d %B ") .. markup("#ab7367", ">") .. markup("#de5e1e", " %I:%M %p "))
mytextclock.font = beautiful.font

-- Calendar
beautiful.cal = lain.widget.cal({
    attach_to = { mytextclock },
		followtag = true,
		icons = "",
    notification_preset = {
        font = "monospace 10",
        fg   = beautiful.fg_normal,
        bg   = beautiful.bg_normal
    }
})
mytextclock:disconnect_signal("mouse::enter", beautiful.cal.hover_on)
mytextclock:buttons(awful.util.table.join(
	awful.button({}, 1, function() 
			if beautiful.cal.notification then
				beautiful.cal.hide()
			else
				beautiful.cal.hover_on()
			end
		end
	),
	awful.button({}, 5, beautiful.cal.prev),
	awful.button({}, 4, beautiful.cal.next))
)

-- CPU
local cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, "#e33a6e", cpu_now.usage .. "% "))
    end
})

-- Battery
local baticon = wibox.widget.imagebox(beautiful.widget_batt)
local bat = lain.widget.bat({
    settings = function()
        local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or "..."

        if bat_now.ac_status == 1 then
            perc = perc .. " A/C"
        end

        widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_normal, perc .. " "))
    end
})

-- MEM
local memicon = wibox.widget.imagebox(beautiful.widget_mem)
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, "#e0da37", mem_now.used .. "M "))
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
	bg = beautiful.bg_systray,
	shape = trayshape,
	shape_clip = true,
	widget = wibox.container.background
}, 6, 0, 3, 4)

-- Spotify Widget
local my_spotify_widget = spotify_widget({icon = beautiful.widget_spotify, font=beautiful.font})

-- Volume Widget
local my_volume_widget = volume_widget({icon = beautiful.widget_vol, font=beautiful.font})

-- Wifi Widget
local my_wifi_widget = wifi_widget({icons = beautiful.widget_net, font=beautiful.font})

-- Wifi Widget
local my_brightness_widget = brightness_widget({icon = beautiful.widget_brightness, font=beautiful.font})

-- ]]]


function generate_wibar(s)
	-- layout indicator
	-- s.mylayoutbox = awful.widget.layoutbox(s)
	-- s.mylayoutbox:buttons(gears.table.join(
	-- 	awful.button({}, 1, function() awful.layout.inc(1) end),
	-- 	awful.button({}, 2, function() awful.layout.set(awful.layout.layouts[1]) end),
	-- 	awful.button({}, 3, function() awful.layout.inc(-1) end)
	-- ))

	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	}

	-- s.mytasklist = awful.widget.tasklist {
	-- 	screen = s,
	-- 	filter = awful.widget.tasklist.filter.currenttags,
	-- 	buttons = awful.util.tasklist_buttons
	-- }

	s.mywibar = awful.wibar({ position = "top", screen = s, bg = beautiful.bg_wibar, fg = beautiful.fg_normal })

	s.mywibar:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			menulauncher,
			s.mytaglist,
		},

		middle_box, -- Middle widget

		{	-- Right widgets
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

return generate_wibar;