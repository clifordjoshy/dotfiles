-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
			-- Make sure we don't go into an endless error loop
			if in_error then
				return
			end
			in_error = true

			naughty.notify({
				preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
				text = tostring(err)
			})
			in_error = false
		end
	)
end

-- Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end
run_once({"picom", "xfce4-power-manager"})
-- todo consider installing unclutter(to hide mouse point when not in use)

-- Variable definitions

local terminal = "alacritty"
local editor = "vim"
local modkey = "Mod4" -- Super Key
local browser = "brave"
awful.util.tagnames = { "one", "two", "three", "four", "five" }

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile
	-- awful.layout.suit.floating,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

-- Active Screen Indicator
awful.util.screen_indicator = awful.widget.only_on_screen (nil, 1)

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- 1 = left mouse button
-- 3 = right mouse button
-- 4,5 = scroll wheel
-- 3 = scroll click
-- (we're creating new variables to the util object here [to use within theme])
awful.util.taglist_buttons = gears.table.join( -- move to tag on clicking the title
	awful.button({}, 1, function(t) t:view_only() end),
	-- move focused window to clicked tag
	awful.button({modkey}, 1, function(t)
			if client.focus then
				client.focus:move_to_tag(t)
			end
		end
	),
	-- -- select a tag (but why?)
	-- awful.button({}, 3, awful.tag.viewtoggle),
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


-- Main Menu
awful.util.mymainmenu = awful.menu({
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


-- Screen

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
		if beautiful.wallpaper then
			local wallpaper = beautiful.wallpaper
			-- If wallpaper is a function, call it with the screen
			if type(wallpaper) == "function" then
				wallpaper = wallpaper(s)
			end
			-- wallpaper fit options
			gears.wallpaper.maximized(wallpaper, s, true)
		end
	end
)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)


-- Key bindings
globalkeys = gears.table.join(
	awful.key({modkey}, "s", 
		hotkeys_popup.show_help,
		{ description = "show help", group = "awesome" }
	),
	awful.key({modkey}, "Left",
		awful.tag.viewprev,
		{ description = "view previous", group = "tag" }
	),
	awful.key({modkey}, "Right",
		awful.tag.viewnext,
		{ description = "view next", group = "tag" }
	),
	awful.key({modkey}, "Escape", 
		awful.tag.history.restore, 
		{ description = "go back", group = "tag" }
	),
	awful.key({modkey}, "j",
		function() awful.client.focus.byidx(1) end,
		{ description = "focus next by index", group = "client" }
	),
	awful.key({modkey}, "k",
		function() awful.client.focus.byidx(-1) end,
		{ description = "focus previous by index", group = "client" }
	),
	
	-- Layout manipulation
	awful.key({modkey, "Shift"}, "j",
		function() awful.client.swap.byidx(1) end,
		{ description = "swap with next client by index", group = "client" }
	),
	awful.key({modkey, "Shift"}, "k",
		function() awful.client.swap.byidx(-1) end,
		{ description = "swap with previous client by index", group = "client" }
	),
	awful.key({modkey, "Control"}, "j",
		function() awful.screen.focus_relative(1) end,
		{ description = "focus the next screen", group = "screen" }
	),
	awful.key({modkey, "Control"}, "k",
		function() awful.screen.focus_relative(-1) end,
		{ description = "focus the previous screen", group = "screen" }
	),
	awful.key({modkey}, "u",
		awful.client.urgent.jumpto,
		{ description = "jump to urgent client", group = "client" }
	),
	awful.key({modkey}, "Tab",
		function()
			awful.client.focus.history.previous()
			if client.focus then client.focus:raise() end
		end,
		{ description = "go back", group = "client" }
	),

	-- Standard program
	awful.key({modkey}, "Return",
		function() awful.spawn(terminal) end,
		{ description = "open a terminal", group = "apps" }
	),
	awful.key({modkey, "Control"}, "r",
		awesome.restart,
		{ description = "reload awesome", group = "awesome" }
	),
	awful.key({modkey, "Shift"}, "q", 
		awesome.quit, 
		{ description = "quit awesome", group = "awesome" }
	),
	awful.key({modkey}, "l",
		function() awful.tag.incmwfact(0.05) end,
		{ description = "increase master width factor", group = "layout" }
	),
	awful.key({modkey}, "h",
		function() awful.tag.incmwfact(-0.05) end,
		{ description = "decrease master width factor", group = "layout" }
	),
	awful.key({modkey, "Shift"}, "h",
		function() awful.tag.incnmaster(1, nil, true) end,
		{ description = "increase the number of master clients", group = "layout" }
	),
	awful.key({modkey, "Shift"}, "l",
		function() awful.tag.incnmaster(-1, nil, true) end,
		{ description = "decrease the number of master clients", group = "layout" }
	),
	awful.key({modkey, "Control"}, "h",
		function() awful.tag.incncol(1, nil, true) end,
		{ description = "increase the number of columns", group = "layout" }
	),
	awful.key({modkey, "Control"}, "l",
		function() awful.tag.incncol(-1, nil, true) end,
		{ description = "decrease the number of columns", group = "layout" }
	),
	-- awful.key({modkey, "Control"}, "n",
	-- 	function()
	-- 		local c = awful.client.restore()
	-- 		-- Focus restored client
	-- 		if c then
	-- 			c:emit_signal("request::activate", "key.unminimize", {raise = true})
	-- 		end
	-- 	end,
	-- 	{ description = "restore minimized", group = "client" }
	-- ),

	--lock screen
	awful.key({modkey}, "q",
		function() awful.spawn("slock", false) end,
		{ description = "lock screen", group = "system" }
	),
	
	-- Prompt
	awful.key({modkey}, "space",
		function() awful.spawn("dmenu_run -l 10 -p \'launch app: \'", false) end,
		{ description = "run prompt", group = "apps" }
	),
	
	-- pass false to awful.spawn for non window applications. otherwise loading cursor will show up
	-- Apps
	awful.key({modkey}, "b",
		function() awful.spawn(browser) end,
		{ description = "launch browser", group = "apps" }
	),
	awful.key({modkey}, "c",
		function() awful.spawn("spotify") end,
		{ description = "launch spotify", group = "apps" }
	),
	awful.key({modkey}, "n",
		function() awful.spawn(string.format("%s -e %s", terminal, editor)) end,
		{ description = "launch text editor", group = "apps" }
	),
	awful.key({modkey}, "v",
		function() awful.spawn("code") end,
		{ description = "launch vs code", group = "apps" }
	),
	awful.key({modkey}, "Print",
		function() awful.spawn("flameshot screen -c", false) end,
		{ description = "screenshot to clipboard", group = "apps" }
	),
	awful.key({modkey, "Control"}, "Print",
		function() awful.spawn.with_shell("flameshot screen -p ~/Pictures/Screenshots") end,
		{ description = "save screenshot", group = "apps" }
	),
	awful.key({modkey, "Shift"}, "s",
		function() awful.spawn("flameshot gui", false) end,
		{ description = "gui screenshot", group = "apps" }
	)
)

clientkeys = gears.table.join(
	awful.key({modkey}, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = "toggle fullscreen", group = "client" }
	),
	awful.key({modkey, "Shift"}, "c",
		function(c) c:kill() end,
		{ description = "close", group = "client" }
	),
	awful.key({modkey, "Control"}, "space", 
		awful.client.floating.toggle, 
		{ description = "toggle floating", group = "client"}
	),
	awful.key({modkey, "Control"}, "m",
		function(c) c:swap(awful.client.getmaster()) end,
		{ description = "move to master", group = "client" }
	),
	awful.key({modkey}, "o",
		function(c) c:move_to_screen() end,
		{ description = "move to screen", group = "client" }
	),
	awful.key({modkey}, "t",
		function(c) c.ontop = not c.ontop end,
		{ description = "toggle keep on top", group = "client" }
	),
	-- awful.key({modkey}, "n",
	-- 	function(c)
	-- 		-- The client currently has the input focus, so it cannot be
	-- 		-- minimized, since minimized clients can't have the focus.
	-- 		c.minimized = true
	-- 	end,
	-- 	{ description = "minimize", group = "client" }
	-- ),
	awful.key({modkey}, "m",
		function(c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{ description = "(un)maximize", group = "client" }
	),
	awful.key({modkey, "Shift"}, "m",
		function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end,
		{ description = "(un)maximize vertically", group = "client" }
	),
	awful.key({modkey, "Shift"}, "n",
		function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end,
		{ description = "(un)maximize horizontally", group = "client" }
	)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, #awful.util.tagnames do
	globalkeys = gears.table.join(globalkeys, 
	-- View tag only.
		awful.key({modkey}, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{ description = "view tag #" .. i, group = "tag" }
		),
		-- Toggle tag display.
		awful.key({modkey, "Control"}, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{ description = "show windows from tag #" .. i, group = "tag" }
		),
		-- Move client to tag.
		awful.key({modkey, "Shift"},
			"#" .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{ description = "move focused client to tag #" .. i, group = "tag" }
		)
		-- Toggle tag on focused client.
		-- awful.key({modkey, "Control", "Shift"},
		-- 	"#" .. i + 9,
		-- 	function()
		-- 		if client.focus then
		-- 			local tag = client.focus.screen.tags[i]
		-- 			if tag then
		-- 				client.focus:toggle_tag(tag)
		-- 			end
		-- 		end
		-- 	end,
		-- 	{ description = "toggle focused client on tag #" .. i, group = "tag" }
		-- )
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c) 
			c:emit_signal("request::activate", "mouse_click", {raise = true})
		end
	),
	awful.button({modkey}, 1, function(c)
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			awful.mouse.client.move(c)
		end
	),
	awful.button({modkey}, 3, function(c)
			c:emit_signal("request::activate", "mouse_click", {raise = true})
			awful.mouse.client.resize(c)
		end
	)
)

-- Set keys
root.keys(globalkeys)

-- Rules
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen
		}
	}, 
	-- Floating clients.
	{
		rule_any = {
			instance = {
				"copyq", -- Includes session name in class.
				"pinentry",
				"nmtui",				-- set when launched from wifi widget
			},
			class = {
				"Pavucontrol",
				-- "Arandr",
				"Blueman-manager",
				-- "Gpick",
				-- "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester" -- xev.
			},
			role = {
				-- "AlarmWindow", -- Thunderbird's calendar.
				-- "ConfigManager", -- Thunderbird's about:config.
				"pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = {floating = true, placement = awful.placement.centered}
	},

	--Set Spotify to always map on the tag named "five" on screen 1.
	{ rule = { class = "Spotify" }, properties = { screen = 1, tag = "five"} },
}

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
		-- Set the windows at the slave
		if not awesome.startup then awful.client.setslave(c) end

		if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end

		-- Windows like spotify only set class name after window opens. 
		-- So add a listener for when it attains classname and then apply rules

		if c.class == nil then 
			c.minimized = true
			c:connect_signal("property::class", function ()
					c.minimized = false
					awful.rules.apply(c)
				end
			)
		end

		c.shape = gears.shape.rounded_rect
	end
)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal(
-- 	"mouse::enter",
-- 	function(c)
-- 		c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- 	end
-- )

client.connect_signal("focus", function(c) 
		c.border_color = beautiful.border_focus
		if awful.util.screen_indicator.screen ~= c.screen then
			awful.util.screen_indicator.screen = c.screen
			awful.util.screen_indicator:emit_signal("widget::redraw_needed")
		end
	end
)
client.connect_signal("unfocus", function(c) c.border_color= beautiful.border_normal end)
