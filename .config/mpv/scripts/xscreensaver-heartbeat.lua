local function heartbeat()
    if not mp.get_property_native("pause") then
        mp.commandv("run", "xscreensaver-command", "-deactivate")
    end
end

mp.add_periodic_timer(60, heartbeat)
