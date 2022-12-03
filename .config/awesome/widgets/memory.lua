-------------------------------------------------
-- Memory used widget
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local gears = require("gears");

local memory_widget = {}

local worker = function(user_args)

	local args = user_args or {}

	local icon = args.icon;
	local font = args.font or "sans-serif 9";
	local timeout = 2;

	memory_widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = args.space,
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			image = icon
		},
		{
			id = "memory",
			font = font,
			widget = wibox.widget.textbox
		},

		update_memory = function(self, memory)
			local memory_markup = string.format("<span font='%s' foreground='%s'>%dM</span>", font, "#e0da37", memory);

			if self.memory:get_markup() ~= memory_markup then
				self.memory:set_markup(memory_markup);
			end
		end
	}

	local update_widget = function()
		local mem_now = {}

		for line in io.lines("/proc/meminfo") do
			for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
				if k == "MemTotal" then mem_now.total = math.floor(v / 1024 + 0.5)
				elseif k == "MemFree" then mem_now.free = math.floor(v / 1024 + 0.5)
				elseif k == "Buffers" then mem_now.buf = math.floor(v / 1024 + 0.5)
				elseif k == "Cached" then mem_now.cache = math.floor(v / 1024 + 0.5)
				elseif k == "SReclaimable" then mem_now.srec = math.floor(v / 1024 + 0.5)
				end
			end
		end

		local mem_used = mem_now.total - mem_now.free - mem_now.buf - mem_now.cache - mem_now.srec
		memory_widget:update_memory(mem_used)
	end;

	gears.timer {
		timeout = timeout,
		call_now = true,
		autostart = true,
		callback = update_widget
	}

	--- Adds mouse controls to the widget:
	--  - left click - launch gotop
	memory_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			awful.spawn("alacritty -e gotop");
		end
	end
	);

	return memory_widget;
end;

return setmetatable(memory_widget, { __call = function(_, ...)
	return worker(...);
end
});
