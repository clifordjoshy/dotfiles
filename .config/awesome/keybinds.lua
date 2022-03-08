local gears = require("gears")
local awful = require("awful")

local hotkeys_popup = require("awful.hotkeys_popup")

-- Key bindings
local globalkeys = gears.table.join(
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
	awful.key({modkey}, "p",
		function() awful.screen.focus_relative(1) end,
		{ description = "focus the next screen", group = "screen" }
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
	awful.key({modkey, "Shift"}, "g",
		function()
			local c = awful.client.restore()
			if c then
				c.minimized = false
			end
		end,
		{ description = "restore minimized", group = "client" }
	),
	awful.key({modkey}, "t",
		function()
			for s in screen do
				for _,c in pairs(s.clients) do
					c.minimized = true
				end
			end
		end,
		{ description = "minimize all windows", group = "client" }
	),
	awful.key({modkey}, "a",
		function() awful.layout.inc(-1) end,
		{ description = "switch to previous layout", group = "layout" }
	),
	awful.key({modkey}, "d",
		function() awful.layout.inc(1) end,
		{ description = "switch to next layout", group = "layout" }
	),

	--lock screen
	awful.key({modkey}, "q",
		function() awful.spawn(screen_lock, false) end,
		{ description = "lock screen", group = "system" }
	),
	
	-- Prompt
	awful.key({modkey}, "space",
		function() awful.spawn("rofi -show drun", false) end,
		{ description = "run prompt", group = "apps" }
	),
	awful.key({modkey, "Shift"}, "z",
		function() awful.spawn("rofi -modi window -show window", false) end,
		{ description = "window switcher", group = "apps" }
	),
	awful.key({modkey, "Shift"}, "space",
		function() awful.spawn("rofi -modi file-browser-extended -show file-browser-extended", false) end,
		{ description = "rofi file browser", group = "apps" }
	),
	awful.key({modkey}, "z",
		function() awful.spawn("rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'", false) end,
		{ description = "clipboard manager", group = "apps" }
	),
	awful.key({modkey}, "e",
		function() awful.spawn.with_shell("rofi -modi blocks -show blocks -blocks-wrap ~/scripts/rofi-ytm/rofi-ytm.py -theme-str 'listview{lines:5;}'") end,
		{ description = "youtube music script", group = "apps" }
	),
	
	
	-- pass false to awful.spawn for non window applications. otherwise loading cursor will show up
	-- Apps
	awful.key({modkey}, "b",
		function() awful.spawn(browser) end,
		{ description = "launch browser", group = "apps" }
	),
	awful.key({modkey}, "c",
		function()
			local spotify = function(c) return awful.rules.match(c, {class = "Spotify"}) end;
			for c in awful.client.iterate(spotify) do
				return;
			end;
			awful.spawn("spotify")
		end,
		{ description = "launch spotify", group = "apps" }
	),
	awful.key({modkey}, "n",
		function() awful.spawn("gedit") end,
		{ description = "launch notepad", group = "apps" }
	),
	awful.key({modkey}, "v",
		function() awful.spawn("code") end,
		{ description = "launch vs code", group = "apps" }
	),
	awful.key({modkey}, "w",
		function() awful.spawn(browser.." --new-window web.whatsapp.com") end,
		{ description = "launch whatsapp", group = "apps" }
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
	),

	--Media Keys
	awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false) end),
	awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false) end),
	awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ 0%", false) end),
	
	awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause", false) end),
	awful.key({}, "XF86AudioPause", function() awful.spawn("playerctl play-pause", false) end),
	awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous", false) end),
	awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next", false) end),
	awful.key({}, "XF86AudioStop", function() awful.spawn("playerctl stop", false) end),
	
	awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("light -A 10", false) end),
	awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("light -U 10", false) end),
	
	awful.key({}, "XF86TouchpadToggle", function() awful.spawn("touchpad_toggle", false) end),

	--Alternative Media Keys
	awful.key({modkey}, "[",
		function() awful.spawn("playerctl previous", false) end,
		{ description = "previous track", group = "functions" }
	),
	awful.key({modkey}, "]",
		function() awful.spawn("playerctl next", false) end,
		{ description = "next track", group = "functions" }
	),
	awful.key({modkey}, "'",
		function() awful.spawn("playerctl play-pause", false) end,
		{ description = "pause/play track", group = "functions" }
	),
	awful.key({modkey, "Shift"}, "[",
		function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false) end,
		{ description = "volume down", group = "functions" }
	),
	awful.key({modkey, "Shift"}, "]",
		function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false) end,
		{ description = "volume up", group = "functions" }
	)

)

local clientkeys = gears.table.join(
	awful.key({modkey}, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = "toggle fullscreen", group = "client" }
	),
	awful.key({modkey, "Shift"}, "x",
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
	awful.key({modkey, "Control"}, "t",
		function(c) c.ontop = not c.ontop end,
		{ description = "toggle keep on top", group = "client" }
	),
	awful.key({modkey}, "g",
		function(c)
			c.minimized = true
		end,
		{ description = "minimize", group = "client" }
	),
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
for i = 1, #tagnames do
	globalkeys = gears.table.join(globalkeys, 
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
		awful.key({modkey, "Shift"}, "#" .. i + 9,
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

return {globalkeys = globalkeys, clientkeys = clientkeys}