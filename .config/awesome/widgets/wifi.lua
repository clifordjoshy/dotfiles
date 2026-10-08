-------------------------------------------------
-- Native GObject Wifi/Ethernet Widget (LGI)
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local lgi = require("lgi")
local NM = lgi.NM
local GLib = lgi.GLib

-- Configuration values pulled from beautiful/fallback
local wifi_icons = beautiful.widget_wifi or {}
local eth_icon = beautiful.widget_eth
local speed_timeout = 4

-- Main Widget Blueprint Object
local wifi_widget = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  spacing = beautiful.widget_icon_gap or 4,
  {
    id = 'icon',
    widget = wibox.widget.imagebox,
    image = eth_icon,
  },
  {
    id = 'text',
    widget = wibox.widget.textbox,
  },

  update_strength = function(self, strength)
    local strength_icon = eth_icon
    if strength >= 0 and #wifi_icons > 0 then
      -- Safely snap 0-100 to an icon index
      strength_icon = wifi_icons[math.ceil(strength / 25) + 1] or strength_icon
    end
    if self.icon.image ~= strength_icon then
      self.icon.image = strength_icon
    end
  end,

  update_connectivity = function(self, is_connected)
    self:set_opacity(is_connected and 1 or 0.5)
    self:emit_signal('widget::redraw_needed')
  end,

  update_speed = function(self, down_speed)
    self.text:set_markup(string.format("<span foreground='%s'>%s</span>", "#ea76cb", down_speed))
  end
}

local state = {
  last_rx = 0,
  last_time = GLib.get_monotonic_time() / 1000000,
  current_interface = "",
}
local nm_client = nil;

local function on_nm_update()
  local connectivity = nm_client:get_connectivity()
  local is_connected = (connectivity == "FULL" or connectivity == "PORTAL")
  wifi_widget:update_connectivity(is_connected)

  local active_conn = nm_client:get_primary_connection()
  if not active_conn then
    state.current_interface = ""
    return
  end

  local conn_type = active_conn:get_connection_type()
  local devices = active_conn:get_devices()
  local primary_device = devices and devices[1]

  if primary_device then
    state.current_interface = primary_device:get_iface() or ""
  else
    state.current_interface = ""
  end

  -- Handle Icon Profiles depending on Type (Ethernet vs Wi-Fi)
  if conn_type == "802-3-ethernet" then
    wifi_widget:update_strength(-1)
  elseif conn_type == "802-11-wireless" and primary_device then
    local ap = primary_device:get_active_access_point()
    if ap then
      wifi_widget:update_strength(ap:get_strength() or 0)
    else
      wifi_widget:update_strength(0)
    end
  end
end

-- Download speed
gears.timer {
  timeout   = speed_timeout,
  call_now  = true,
  autostart = true,
  callback  = function()
    if state.current_interface == "" then
      wifi_widget:update_speed("0.0 KB/s")
      return true
    end
    local sys_path = string.format("/sys/class/net/%s/statistics/rx_bytes", state.current_interface)

    local contents = GLib.file_get_contents(sys_path)

    if contents then
      local current_rx = tonumber(contents) or 0
      local now = GLib.get_monotonic_time() / 1000000
      local elapsed = now - state.last_time

      if state.last_rx > 0 and elapsed > 0 then
        local bytes_per_sec = (current_rx - state.last_rx) / elapsed
        local speed_str
        if bytes_per_sec >= (1024 * 1024) then
          speed_str = string.format("%.1f MB/s", bytes_per_sec / (1024 * 1024))
        else
          speed_str = string.format("%.1f KB/s", bytes_per_sec / 1024)
        end
        wifi_widget:update_speed(speed_str)
      else
        wifi_widget:update_speed("0.0 KB/s")
      end

      state.last_rx = current_rx
      state.last_time = now
    else
      wifi_widget:update_speed("0.0 KB/s")
    end
    return true
  end
}

gears.timer.delayed_call(function()
  nm_client = NM.Client.new(nil)
  if not nm_client then return end

  nm_client.on_notify = function(obj, pspec)
    if pspec.name == "connectivity" or pspec.name == "primary-connection" then
      on_nm_update()
    end
  end

  on_nm_update()
end)

local info_tooltip = awful.tooltip {
  objects = { wifi_widget },
  timer_function = function()
    if not nm_client then return "Awaiting initialization" end

    local active_conn = nm_client:get_primary_connection()
    if not active_conn then return "No Active Network" end

    local ssid = active_conn:get_id() or "Unknown Connection"
    local ip_str = "No IP Assigned"

    local ip4_config = active_conn:get_ip4_config()
    if ip4_config then
      local addresses = ip4_config:get_addresses()
      if addresses and #addresses > 0 then
        ip_str = addresses[1]:get_address() or ip_str
      end
    end

    return string.format("ssid: %s\nip  : %s", ssid, ip_str)
  end,
  delay_show = 0.5,
  fg = "#cdcdcd",
  bg = "#202020",
  border_width = 1,
  border_color = "#cdcdcd",
}

-- Interactive Actions (Buttons / Popups)
wifi_widget:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    local nmtui_window = function(c) return awful.rules.match(c, { instance = "nmtui" }) end
    for c in awful.client.iterate(nmtui_window) do
      c:jump_to(false)
      return
    end
    -- Launches nmtui terminal cleanly
    awful.spawn("alacritty --class nmtui -e bash -c 'nmcli device wifi rescan ; nmtui'", false)
  elseif button == 3 then
    if not nm_client then return end
    nm_client:check_connectivity_async(nil, function() on_nm_update() end)
  end
end)


return wifi_widget
