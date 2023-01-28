local setmetatable = setmetatable

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local volume_widget = { mt = {} }

local GET_VOL_CMD = "pamixer --get-volume"
local GET_MUTE_CMD = "pamixer --get-mute"

local VOL_MUTE = "婢"
local VOL_LOW = "奄"
local VOL_MEDIUM = "奔"
local VOL_HIGH = "墳"

local w = wibox.widget({
    widget = wibox.widget.textbox,
})

local function update(_, level)
    awful.spawn.easy_async_with_shell(GET_MUTE_CMD, function(is_mute)
        local volume_level = tonumber(level:sub(1, -2))
        local icon

        if is_mute:sub(1, -2) == "true" or volume_level == 0 then
            icon = string.format("<span foreground='#f38ba8'>%s</span>", VOL_MUTE)
        elseif volume_level < 33 then
            icon = VOL_LOW
        elseif volume_level < 66 then
            icon = VOL_MEDIUM
        else
            icon = VOL_HIGH
        end

        w.markup = string.format("%s%3d%%", icon, volume_level)
    end)
end

function volume_widget.new()
    watch(GET_VOL_CMD, 2, update)

    return w
end

function volume_widget.mt:__call()
    return volume_widget.new()
end

return setmetatable(volume_widget, volume_widget.mt)
