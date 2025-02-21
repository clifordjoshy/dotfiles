local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local media_widget = require("widgets.media")
local volume_widget = require("widgets.pipewire")
local wifi_widget = require("widgets.wifi")
local brightness_widget = require("widgets.brightness")
local memory_widget = require("widgets.memory")
local cpu_widget = require("widgets.cpu")
local battery_widget = require("widgets.battery")
local cal_task = require("widgets.cal_task")
local menubar_utils = require("menubar.utils")

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

-- a function that will either call a kill_fn or a default depending on the kill switch
handle_kill_switch = function(kill_fn, default_fn)
	if kill_switch then
		kill_switch = false
		menulauncher.bg = nil
		kill_fn()
	else
		default_fn()
	end
end

menulauncher:connect_signal("button::press", function(_, _, _, button)
	if button == 1 then
		mymainmenu:show({ coords = { x = 0, y = 32 } })
	elseif button == 2 then
		toggle_kill_switch()
	end
end)

-- Hide the menu when the mouse leaves it
local mouse_in_main = false
-- when mouse leaves launcher icon without entering menu. close it
menulauncher:connect_signal("mouse::leave", function()
	if mymainmenu.wibox.visible then
		gears.timer {
			timeout = 0.1,
			autostart = true,
			callback = function() if not mouse_in_main then mymainmenu:hide() end end,
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


-- [[[Taglist //tasklist
local taglist_buttons = gears.table.join(
-- move to tag on clicking the title
	awful.button({}, 1, function(t) t:view_only() end),
	-- move focused window to clicked tag
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end
	),
	-- adds focused window to the clicked tag also
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end
	)
)

local tasklist_buttons = gears.table.join(
-- unminimise window
	awful.button({}, 1, function(c) c.minimized = false end)
)

-- ]]]

-- [[[ Widgets

-- Textclock
local mytextclock = wibox.widget.textclock(string.format(
	"<span foreground='%s'>%%a %%d %%b</span>" ..
	"<span foreground='%s'> &gt; </span>" ..
	"<span foreground='%s'>%%I:%%M %%p</span>",
	"#ff7730", "#ab7367", "#91c771"
));
-- mytextclock.font = beautiful.font
local clock_widget = wibox.widget {
	widget = wibox.layout.fixed.horizontal,
	spacing = beautiful.widget_icon_gap,
	wibox.widget.imagebox(beautiful.widget_clock),
	mytextclock
}

-- Calendar
cal_task.attach(clock_widget)
clock_widget:buttons(gears.table.join(
	clock_widget:buttons(),
	awful.button({}, 2, function() mytextclock:force_update() end)
))

-- Systray Container
local mysystray = wibox.container.margin(wibox.widget.systray(), 0, beautiful.systray_icon_spacing, 4, 4)

-- Media Widget
local my_media_widget = media_widget()

-- Volume Widget
local my_volume_widget = volume_widget()

-- Wifi Widget
local my_wifi_widget = wifi_widget()

-- Battery
local my_battery_widget = battery_widget()

-- Memory Widget
local my_memory_widget = memory_widget()

-- CPU Widget
local my_cpu_widget = cpu_widget()

-- ]]]


-- global function to refresh volume
refresh_volume = function()
	my_volume_widget:force_refresh()
end


local function generate_wibar(s)
	-- layout indicator
	-- s.mylayoutbox = awful.widget.layoutbox(s)
	-- s.mylayoutbox:buttons(gears.table.join(
	-- 	awful.button({}, 1, function() awful.layout.inc(1) end),
	-- 	awful.button({}, 2, function() awful.layout.set(awful.layout.layouts[1]) end),
	-- 	awful.button({}, 3, function() awful.layout.inc(-1) end)
	-- ))


	-- Brightness Widget
	local my_brightness_widget = brightness_widget(s)

	s.mytaglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	}

	s.mytasklist = awful.widget.tasklist {
		screen          = s,
		filter          = awful.widget.tasklist.filter.minimizedcurrenttags,
		buttons         = tasklist_buttons,
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
			my_media_widget,
			my_volume_widget,
			my_memory_widget,
			my_cpu_widget,
			my_brightness_widget,
			my_battery_widget or nil,
			my_wifi_widget,
			clock_widget,
			s.index == 1 and mysystray or nil,
		},
	}
end

return generate_wibar;
