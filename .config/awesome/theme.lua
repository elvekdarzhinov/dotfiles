local dpi = require("beautiful.xresources").apply_dpi
local cairo = require("lgi").cairo
local gears_color = require("gears.color")
local themes_path = require("gears.filesystem").get_themes_dir()
local colors = require("colors")

local theme = {}

theme.wallpaper = "~/.local/share/bg"

theme.font = "FantasqueSansMono Nerd Font 14"
theme.font_larger = "FantasqueSansMono Nerd Font 16"

theme.hotkeys_font = theme.font
theme.hotkeys_description_font = "FantasqueSansMono Nerd Font 10"

theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.systray_icon_spacing = 10
theme.useless_gap = dpi(4)
theme.border_width = dpi(1.5)

-- Colors
theme.bg_minimize = colors.mocha.surface1
theme.fg_minimize = colors.mocha.subtext0
theme.fg_normal = colors.mocha.lavender
theme.bg_normal = colors.mocha.base
theme.fg_focus = colors.mocha.base
theme.bg_focus = colors.mocha.lavender
theme.bg_urgent = colors.mocha.red
theme.border_normal = colors.mocha.base
theme.border_focus = colors.mocha.lavender
theme.border_marked = colors.mocha.lavender
theme.tasklist_bg_focus = colors.mocha.lavender
-- theme.bg_systray = theme.bg_normal

local taglist_square_sel = function(size, fg, x, y)
    local img = cairo.ImageSurface(cairo.Format.ARGB32, size + x, size + y)
    local cr = cairo.Context(img)
    cr:set_source(gears_color(fg))
    cr:rectangle(x, y, size, size)
    cr:fill()
    return img
end

local taglist_squares_unsel = function(size, fg, x, y)
    local line_width = 1.5
    local img = cairo.ImageSurface(cairo.Format.ARGB32, size + x + 5, size + y + 5)
    local cr = cairo.Context(img)
    cr:set_source(gears_color(fg))
    cr:set_line_width(line_width)
    cr:rectangle(x + line_width / 2, y + line_width / 2, size - line_width / 2, size - line_width / 2)
    cr:stroke()
    return img
end

-- Generate taglist squares:
local taglist_square_size = dpi(6)
theme.taglist_squares_sel = taglist_square_sel(taglist_square_size, theme.fg_focus, dpi(2), dpi(2))
theme.taglist_squares_unsel = taglist_squares_unsel(taglist_square_size, theme.fg_normal, dpi(2), dpi(2))

-- Variables set for theming the menu:
theme.menu_height = dpi(20)
theme.menu_width = dpi(150)

-- You can use your own layout icons like this:
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"

theme.layout_txt_tile = "[]="
theme.layout_txt_floating = "><>"

return theme

