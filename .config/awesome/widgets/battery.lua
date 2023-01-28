local setmetatable = setmetatable

local wibox = require("wibox")
local watch = require("awful.widget.watch")

local battery_widget = { mt = {} }

local GET_BAT_CMD = "cat /sys/class/power_supply/BAT1/capacity"
local GET_BAT_STATUS_CMD = "cat /sys/class/power_supply/BAT1/status"

local BAT_EMPTY = ""
local BAT_LOW = ""
local BAT_MEDIUM = ""
local BAT_HIGH = ""
local BAT_FULL = ""
local BAT_CHARGING = ""

local w = wibox.widget({
    widget = wibox.widget.textbox,
})

local awful = require("awful")

local function update(_, level)
    awful.spawn.easy_async_with_shell(GET_BAT_STATUS_CMD, function(stat)
        local battery_level = tonumber(level:sub(1, -2))
        local status = stat:sub(1, -2)
        local icon

        if status == "Charging" then
            icon = BAT_CHARGING
        elseif battery_level < 80 then
            icon = BAT_HIGH
        elseif battery_level < 60 then
            icon = BAT_MEDIUM
        elseif battery_level < 40 then
            icon = string.format("<span foreground='#f9e2af'>%s</span>", BAT_LOW)
        elseif battery_level < 20 then
            icon = string.format("<span foreground='#f38ba8'>%s</span>", BAT_EMPTY)
        else
            icon = BAT_FULL
        end

        w.markup = string.format("%s%4d%%", icon, battery_level)
    end)
end

function battery_widget.new()
    watch(GET_BAT_CMD, 20, update)

    return w
end

function battery_widget.mt:__call(...)
    return battery_widget.new(...)
end

return setmetatable(battery_widget, battery_widget.mt)
