-- caffeine
local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local caffeine_pid = -1

local AUTO_CAFFEINE_APPS = {
    "qbittorrent",
    "discord"
}

local active_triggers = {}

local caffeine_textbox = wibox.widget {
    widget = wibox.widget.textbox,
    text = "☕",
    visible = false,
    refresh = function(self)
        if caffeine_pid == -1 then
            self:set_visible(false)
        else
            self:set_visible(true)
        end
    end,
}

INHIBITOR_CMD =
"systemd-inhibit --what=sleep --who=awesome-widget --why='Detected fullscreen or caffeine apps' sleep infinity&"
GET_RUNNING_CAFFEINE_PID_CMD =
"sleep %f && systemd-inhibit --who=awesome-widget --no-pager --json short | jq '.[0] | .pid'"
KILL_PROCESS_CMD = "kill %d"

local refetch_caffeine_pid = function(on_fetch, delay)
    local delay = delay or 0.5
    awful.spawn.easy_async_with_shell(string.format(GET_RUNNING_CAFFEINE_PID_CMD, delay), function(pid, se, _, _)
        local pid_num = tonumber(pid)
        if pid_num ~= nil then
            caffeine_pid = pid_num
            caffeine_textbox:refresh()
        end
        if on_fetch ~= nil then
            on_fetch(caffeine_pid)
        end
    end)
end

local kill_caffeine_process = function(on_kill)
    awful.spawn.easy_async_with_shell(string.format(KILL_PROCESS_CMD, caffeine_pid), function(_, se, _, ec)
        if ec ~= 0 then
            naughty.notify({
                preset = naughty.config.presets.low,
                title = "Error",
                text = se,
                timeout = 5,
            })
            return
        end
        caffeine_pid = -1
        caffeine_textbox:refresh()

        if on_kill ~= nil then
            on_kill()
        end
    end)
end

local request_caffeine = function(trigger)
    table.insert(active_triggers, trigger)

    if caffeine_pid ~= -1 then
        return
    end

    -- if any existing process already, latch on to it
    refetch_caffeine_pid(function(pid)
        if pid ~= -1 then
            caffeine_pid = pid
            caffeine_textbox:refresh()
        else
            awful.spawn.with_shell(INHIBITOR_CMD)
            refetch_caffeine_pid()
        end
    end, 0)
end

local release_caffeine = function(trigger)
    local trigger_index = gears.table.hasitem(active_triggers, trigger)

    if caffeine_pid == -1 or trigger_index == nil then
        naughty.notify({
            preset = naughty.config.presets.low,
            title = "Warning",
            text = string.format("Unmatched decaffeination: %s", trigger),
            timeout = 5,
        })
        return
    end

    table.remove(active_triggers, trigger_index)

    if #active_triggers > 0 then
        return
    end

    kill_caffeine_process()
end

local _handle_fullscreen_signal = function(c, is_fullscreen)
    local trigger = string.format("fullscreen (%s)", c.instance)
    if is_fullscreen then
        request_caffeine(trigger)
    elseif gears.table.hasitem(active_triggers, trigger) ~= nil then
        release_caffeine(trigger)
    end
end

local _handle_app_signal = function(c, is_open)
    local appname = c.instance

    if gears.table.hasitem(AUTO_CAFFEINE_APPS, appname) ~= nil then
        if is_open then
            request_caffeine(appname)
        else
            release_caffeine(appname)
        end
    end

    -- release fullscreen triggers
    -- (for apps that were closed while fullscreen)
    if not is_open and c.fullscreen then
        _handle_fullscreen_signal(c, false)
    end
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

local on_media_play = function(media_name)
    local trigger = string.format("media (%s)", media_name)
    if gears.table.hasitem(active_triggers, trigger) ~= nil then
        return
    end
    request_caffeine(trigger)
end

local on_media_stop = function(media_name)
    local trigger = string.format("media (%s)", media_name)
    if gears.table.hasitem(active_triggers, trigger) == nil then
        return
    end
    release_caffeine(trigger)
end

local trigger_tooltip = awful.tooltip {
    objects = { caffeine_textbox },
    timer_function = function()
        return string.format(
            "Caffeinated (pid: %d)\nActive Triggers:\n%s",
            caffeine_pid,
            "  - " .. table.concat(active_triggers, "\n  - ")
        )
    end,
    fg = "#cdcdcd",
    bg = "#202020",
    border_width = 1,
    border_color = "#cdcdcd",
}

--- Adds mouse controls to the widget
caffeine_textbox:connect_signal("button::press", function(_, _, _, button)
    kill_caffeine_process()
end
);

-- Startup
-- capture any running inhibitors
refetch_caffeine_pid()


return {
    handle_media_play = on_media_play,
    handle_media_stop = on_media_stop,
    widget = caffeine_textbox
}
