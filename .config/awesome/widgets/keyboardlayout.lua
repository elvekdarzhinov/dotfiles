local capi = {awesome = awesome}
local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local button = require("awful.button")
local gtable = require("gears.table")
local widget_base = require("wibox.widget.base")

--- Keyboard Layout widget.
local keyboardlayout = { mt = {} }

local uk_flag = "🇬🇧"
local ru_flag = "🇷🇺"

-- Callback for updating current layout.
local function update_status(self)
    self._current = capi.awesome.xkb_get_layout_group()
    local text = ""

    if self._current == 0 then
        text = uk_flag
    else
        text = ru_flag
    end

    self.widget:set_text(text)
end

function keyboardlayout.new()
    local widget = textbox()
    local self = widget_base.make_widget(widget)

    self.widget = widget

    self.next_layout = function()
        self.set_layout((self._current + 1) % (#self._layout + 1))
    end

    update_status(self)

    -- callback for processing layout changes
    capi.awesome.connect_signal("xkb::group_changed", function () update_status(self) end);

    -- Mouse bindings
    self:buttons(gtable.join(button({ }, 1, self.next_layout)))

    return self
end

local _instance = nil;

function keyboardlayout.mt:__call()
    if _instance == nil then
        _instance = keyboardlayout.new()
    end
    return _instance
end

return setmetatable(keyboardlayout, keyboardlayout.mt)

