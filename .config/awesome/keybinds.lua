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
	awful.key({modkey, "Control"}, "j",
		function() awful.screen.focus_relative(1) end,
		{ description = "focus the next screen", group = "screen" }
	),
	awful.key({modkey, "Control"}, "k",
		function() awful.screen.focus_relative(-1) end,
		{ description = "focus the previous screen", group = "screen" }
	),
	-- awful.key({modkey}, "u",
	-- 	awful.client.urgent.jumpto,
	-- 	{ description = "jump to urgent client", group = "client" }
	-- ),
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
	awful.key({modkey}, "t",
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