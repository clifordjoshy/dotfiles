-------------------------------------------------
-- Attaches taskwarrior and calendar notifications to a widget
-- Based off of the lain widgets
-- This just joins those together and removes some unneeded stuff
-------------------------------------------------

local markup  = require("lain.markup")
local awful   = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

-- Taskwarrior stuff
local task = {}
function task.hide()
	if not task.notification then return end
	naughty.destroy(task.notification)
	task.notification = nil
end

function task.show()
	if task.notification then return end

	awful.spawn.easy_async(task.show_cmd , function(f)
		task.notification = naughty.notify {
			preset = task.notification_preset,
			title  = task.show_cmd,
			text   = markup.font(task.notification_preset.font, awful.util.escape(f:gsub("\n*$", ""))),
			timeout = 0
		}
	end
	)
end

-- Calendar stuff
local cal = {}

function cal.build(month, year)
	local current_month, current_year = tonumber(os.date("%m")), tonumber(os.date("%Y"))
	local is_current_month = (not month or not year) or (month == current_month and year == current_year)
	local today = is_current_month and tonumber(os.date("%d")) -- otherwise nil and not highlighted
	local t = os.time { year = year or current_year, month = month and month+1 or current_month+1, day = 0 }
	local d = os.date("*t", t)
	local mth_days, st_day, this_month = d.day, (d.wday-d.day-cal.week_start+1)%7, os.date("%B %Y", t)
	local notifytable = { [1] = string.format("%s%s\n", string.rep(" ", math.floor((28 - this_month:len())/2)), markup.bold(this_month)) }
	for x = 0,6 do notifytable[#notifytable+1] = os.date("%a", os.time { year=2006, month=1, day=x+cal.week_start }):sub(1, utf8.offset(1, 3)) .. " " end
	notifytable[#notifytable] = string.format("%s\n%s", notifytable[#notifytable]:sub(1, -2), string.rep(" ", st_day*4))
	local strx
	for x = 1,mth_days do
		strx = x
		if x == today then
			if x < 10 then x = " " .. x end
			strx = markup.bold(markup.color(beautiful.notification_bg, beautiful.notification_fg, x) .. " ")
		end
		strx = string.format("%s%s", string.rep(" ", 3 - tostring(x):len()), strx)
		notifytable[#notifytable+1] = string.format("%-4s%s", strx, (x+st_day)%7==0 and x ~= mth_days and "\n" or "")
	end
	if string.len(cal.icons or "") > 0 and today then cal.icon = cal.icons .. today .. ".png" end
	cal.month, cal.year = d.month, d.year

	return notifytable
end

function cal.getdate(month, year, offset)
	if not month or not year then
		month = tonumber(os.date("%m"))
		year  = tonumber(os.date("%Y"))
	end

	month = month + offset

	while month > 12 do
		month = month - 12
		year = year + 1
	end

	while month < 1 do
		month = month + 12
		year = year - 1
	end

	return month, year
end

function cal.hide()
	if not cal.notification then return end
	naughty.destroy(cal.notification)
	cal.notification = nil
end

function cal.show(month, year, scr)
	local text = table.concat(cal.build(month, year))

	if cal.notification then
		local title = cal.notification_preset.title or nil
		naughty.replace_text(cal.notification, title, text)
		return
	end

	cal.notification = naughty.notify {
		preset  = cal.notification_preset,
		screen  = cal.followtag and awful.screen.focused() or scr or 1,
		icon    = cal.icon,
		timeout = 0,
		text    = text
	}
end

function cal.move(offset)
		offset = offset or 0
		cal.month, cal.year = cal.getdate(cal.month, cal.year, offset)
		cal.show(cal.month, cal.year)
end
function cal.prev() cal.move(-1) end
function cal.next() cal.move( 1) end

function cal.attach(widget)
	widget:connect_signal("mouse::enter", cal.hover_on)
	widget:connect_signal("mouse::leave", cal.hide)
	widget:buttons(awful.util.table.join(
		awful.button({}, 1, cal.prev),
		awful.button({}, 3, cal.next),
		awful.button({}, 2, cal.hover_on),
		awful.button({}, 5, cal.prev),
		awful.button({}, 4, cal.next))
	)
end

function attach(widget)
	task.show_cmd            = "task next"
	task.followtag           = true
	task.notification_preset = {font = "monospace 10"}

	cal.week_start           = 2		--monday
	cal.followtag            = true
	cal.notification_preset  = {font = "monospace 10"}

	widget:connect_signal("mouse::leave", function()
			cal.hide()
			task.hide()
		end
	)
	widget:buttons(awful.util.table.join(
		awful.button({}, 3, function()
				cal.hide()
				if task.notification then
					task.hide()
				else
					task.show()
				end
			end
		),
		awful.button({}, 1, function()
				task.hide()
				if cal.notification then
					cal.hide()
				else
					cal.show()
				end
			end
		),
		awful.button({}, 5, function() if cal.notification then cal.prev() end end),
		awful.button({}, 4, function() if cal.notification then cal.next() end end))
	)
end

return {
	attach = attach,
	task = task,
	cal = cal
}	