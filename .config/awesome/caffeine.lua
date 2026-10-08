local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local caffeine_job_id = nil
local active_triggers = {}

local AUTO_CAFFEINE_APPS = {
    ["qbittorrent"] = true,
    ["discord"] = true
}

local caffeine_textbox = wibox.widget {
    widget = wibox.widget.textbox,
    text = "☕",
    visible = false,
    refresh = function(self)
        self:set_visible(caffeine_job_id ~= nil)
    end,
}

local INHIBITOR_CMD =
"systemd-inhibit --what=sleep --who=awesome-widget --why='Detected fullscreen or caffeine apps' sleep 365d"

local function kill_caffeine_process()
    if not caffeine_job_id then return end

    awesome.kill(caffeine_job_id, awesome.unix_signal['SIGTERM'])
    caffeine_job_id = nil
    caffeine_textbox:refresh()
end

local function request_caffeine(trigger)
    table.insert(active_triggers, trigger)

    -- If already inhibiting, do nothing else
    if caffeine_job_id then return end

    caffeine_job_id = awful.spawn.easy_async(INHIBITOR_CMD, function(_, _, _, exit_code)
        caffeine_job_id = nil
        caffeine_textbox:refresh()
    end)

    caffeine_textbox:refresh()
end

local function release_caffeine(trigger)
    local trigger_index = gears.table.hasitem(active_triggers, trigger)
    if not trigger_index then return end

    table.remove(active_triggers, trigger_index)

    if #active_triggers == 0 then
        kill_caffeine_process()
    end
end

local function _handle_fullscreen_signal(c, is_fullscreen)
    if not c or not c.instance then return end
    local trigger = string.format("fullscreen (%s)", c.instance)
    if is_fullscreen then
        request_caffeine(trigger)
    else
        release_caffeine(trigger)
    end
end

local function _handle_app_signal(c, is_open)
    if not c or not c.instance then return end
    local appname = c.instance

    if AUTO_CAFFEINE_APPS[appname] then
        if is_open then
            request_caffeine(appname)
        else
            release_caffeine(appname)
        end
    end

    -- release fullscreen triggers
    -- (for apps that were closed while fullscreen)
    _handle_fullscreen_signal(c, false)
end

-- Signals
client.connect_signal("manage", function(c)
    _handle_app_signal(c, true)
end)
client.connect_signal("unmanage", function(c)
    _handle_app_signal(c, false)
end)
client.connect_signal("property::fullscreen", function(c)
    _handle_fullscreen_signal(c, c.fullscreen)
end)
awesome.connect_signal("exit", function()
    kill_caffeine_process()
end)

local trigger_tooltip = awful.tooltip {
    objects = { caffeine_textbox },
    timer_function = function()
        return string.format(
            "Caffeinated (pid: %d)\nActive Triggers:\n%s",
            caffeine_job_id or -1,
            "  - " .. table.concat(active_triggers, "\n  - ")
        )
    end,
    delay_show = 0.5,
    fg = "#cdcdcd",
    bg = "#202020",
    border_width = 1,
    border_color = "#cdcdcd",
}

caffeine_textbox:connect_signal("button::press", function()
    active_triggers = {}
    kill_caffeine_process()
end)

return {
    handle_media_play = on_media_play,
    handle_media_stop = on_media_stop,
    widget = caffeine_textbox
}
