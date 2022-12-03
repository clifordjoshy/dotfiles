-------------------------------------------------
-- CPU used widget
-------------------------------------------------

local awful = require("awful");
local wibox = require("wibox");
local gears = require("gears");

local cpu_widget = {}

local worker = function(user_args)

	local args = user_args or {}

	local icon = args.icon;
	local font = args.font or "sans-serif 9";
	local timeout = 2;

	cpu_widget = wibox.widget {
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

		update_cpu_usage = function(self, usage)
			local memory_markup = string.format("<span font='%s' foreground='%s'>%d%%</span>", font, "#ff6363", usage);

			if self.memory:get_markup() ~= memory_markup then
				self.memory:set_markup(memory_markup);
			end
		end
	}

	local cores = {}

	local update_widget = function()
		local lines = {}
		for line in io.lines("/proc/stat") do
			if string.match(line, "cpu") then
				lines[#lines + 1] = line
			end
		end

		-- Read the amount of time the CPUs have spent performing
		-- different kinds of work. Read the first line of /proc/stat
		-- which is the sum of all CPUs.
		for index, time in pairs(lines) do
			local coreid = index - 1
			local core   = cores[coreid] or { last_active = 0, last_total = 0, usage = 0 }
			local at     = 1
			local idle   = 0
			local total  = 0

			for field in string.gmatch(time, "[%s]+([^%s]+)") do
				-- 4 = idle, 5 = ioWait. Essentially, the CPUs have done
				-- nothing during these times.
				if at == 4 or at == 5 then
					idle = idle + field
				end
				total = total + field
				at = at + 1
			end

			local active = total - idle

			if core.last_active ~= active or core.last_total ~= total then
				-- Read current data and calculate relative values.
				local dactive = active - core.last_active
				local dtotal  = total - core.last_total
				local usage   = math.abs((dactive / dtotal) * 100)

				core.last_active = active
				core.last_total  = total
				core.usage       = usage

				-- Save current data for the next run.
				cores[coreid] = core
			end
		end

		local avg_usage = 0;
		for _, core in pairs(cores) do
			avg_usage = avg_usage + core.usage;
		end
		avg_usage = math.ceil(avg_usage / #cores)

		cpu_widget:update_cpu_usage(avg_usage)
	end;

	gears.timer {
		timeout = timeout,
		call_now = true,
		autostart = true,
		callback = update_widget
	}

	--- Adds mouse controls to the widget:
	--  - left click - launch gotop
	cpu_widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			awful.spawn("alacritty -e gotop");
		end
	end
	);

	return cpu_widget;
end;

return setmetatable(cpu_widget, { __call = function(_, ...)
	return worker(...);
end
});
