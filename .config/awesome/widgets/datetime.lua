-------------------------------------------------
-- Time widget that shows calendar on hover
-------------------------------------------------

local awful        = require("awful")
local naughty      = require("naughty")
local beautiful    = require("beautiful")
local wibox        = require("wibox")
local gears        = require("gears")

-- Clock

local clock_widget = wibox.widget {
  widget = wibox.layout.fixed.horizontal,
  spacing = beautiful.widget_icon_gap,
  wibox.widget.imagebox(beautiful.widget_clock),
  wibox.widget.textclock(string.format(
    "<span foreground='%s'>%%a %%d %%b</span>" ..
    "<span foreground='%s'> &gt; </span>" ..
    "<span foreground='%s'>%%I:%%M %%p</span>",
    "#ff7730", "#ab7367", "#91c771"
  ), 1)
}

-- Calendar stuff
local cal          = {
  week_start = 2 --monday
}

function cal.build(month, year)
  local current_month, current_year = tonumber(os.date("%m")), tonumber(os.date("%Y"))
  local is_current_month = (not month or not year) or (month == current_month and year == current_year)
  local today = is_current_month and tonumber(os.date("%d")) -- otherwise nil and not highlighted
  local t = os.time { year = year or current_year, month = month and month + 1 or current_month + 1, day = 0 }
  local d = os.date("*t", t)
  local mth_days, st_day, this_month = d.day, (d.wday - d.day - cal.week_start + 1) % 7, os.date("%B %Y", t)
  local notifytable = {
    [1] = string.format("%s%s\n", string.rep(" ", math.floor((28 - this_month:len()) / 2)),
      "<b>" .. this_month .. "</b>")
  }
  for x = 0, 6 do
    notifytable[#notifytable + 1] = os.date("%a",
          os.time { year = 2006, month = 1, day = x + cal.week_start })
        :sub(1, utf8.offset(1, 3)) .. " "
  end
  notifytable[#notifytable] = string.format("%s\n%s", notifytable[#notifytable]:sub(1, -2), string.rep(" ", st_day * 4))
  local strx
  for x = 1, mth_days do
    strx = x
    if x == today then
      if x < 10 then x = " " .. x end
      strx = string.format("<span background='%s' foreground='%s'><b>%s</b></span>", beautiful.notification_fg,
        beautiful.notification_bg, x .. " ")
    end
    strx = string.format("%s%s", string.rep(" ", 3 - tostring(x):len()), strx)
    notifytable[#notifytable + 1] = string.format("%-4s%s", strx, (x + st_day) % 7 == 0 and x ~= mth_days and "\n" or "")
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
    preset  = { font = "monospace 10" },
    screen  = awful.screen.focused(),
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

function cal.next() cal.move(1) end

clock_widget:connect_signal("mouse::leave", cal.hide)

clock_widget:buttons(awful.util.table.join(
  awful.button({}, 3, function()
    cal.hide()
    naughty.destroy_all_notifications(
      { awful.screen.focused() },
      naughty.notificationClosedReason.dismissedByUser
    )
  end
  ),
  awful.button({}, 1, function()
    naughty.destroy_all_notifications({ awful.screen.focused() }, naughty.notificationClosedReason.dismissedByUser)
    if cal.notification then
      cal.hide()
    else
      cal.show()
    end
  end
  ),
  awful.button({}, 4, function() if cal.notification then cal.prev() end end),
  awful.button({}, 5, function() if cal.notification then cal.next() end end))
)

return clock_widget;
