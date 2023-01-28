-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.autofocus")

-- C api
local awesome = awesome
local client = client
local root = root

-- {{{ Error handling
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init("/home/nt/.config/awesome/theme.lua")

local modkey = "Mod4"
local terminal = "alacritty"
local browser = "brave"
local reader = "zathura"
local file_manager = "lfub"
local editor = "nvim"
local editor_cmd = terminal .. " -e " .. editor

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Bling
local bling = require("bling")

local calculator = bling.module.scratchpad({
    command = "alacritty -t Calculator -e eva",
    rule = { instance = "Calculator" }, -- The rule that the scratchpad will be searched by
    sticky = true,
    autoclose = false, -- Whether it should hide itself when losing focus
    floating = true, -- Whether it should be floating (MUST BE TRUE FOR ANIMATIONS)
    geometry = { x = 560, y = 240, width = 800, height = 600 },
    reapply = true,
    dont_focus_before_close = true,
})
-- }}}

-- {{{ Menu
-- Create a main menu
local mymainmenu = awful.menu({
    items = {
        {
            "hotkeys",
            function()
                hotkeys_popup.show_help(nil, awful.screen.focused())
            end,
        },
        { "open terminal", terminal },
        { "edit config", editor_cmd .. " " .. awesome.conffile },
        { "restart", awesome.restart },
        {
            "quit",
            function()
                awesome.quit()
            end,
        },
    },
})
-- }}}


-- {{{ Screen content
awful.screen.connect_for_each_screen(function(s)
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)

    -- Create tags
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Taglist widget
    s.mytaglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        -- layout = {
        --     spacing = 10,
        --     top = 5,
        --     spacing_widget = {
        --         color = "#dddddd",
        --         shape = gears.shape.powerline,
        --         widget = wibox.widget.separator,
        --     },
        --     layout = wibox.layout.fixed.horizontal,
        -- },
        widget_template = {
            {
                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                widget = wibox.container.margin,
                left = 15,
                right = 15,
            },
            id = "background_role",
            widget = wibox.container.background,
        },
    })

    -- Tasklist widget
    s.mytasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        widget_template = {
            {
                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                widget = wibox.container.margin,
                left = 15,
                right = 15,
            },
            id = "background_role",
            widget = wibox.container.background,
        },
        buttons = gears.table.join(
            awful.button({}, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    c:emit_signal("request::activate", "tasklist", { raise = true })
                end
            end),
            awful.button({}, 3, function()
                awful.menu.client_list({ theme = { width = 250 } })
            end)
        ),
    })

    -- Widgets
    s.mylayoutbox = require("widgets.textlayoutbox")(s)
    local volume_widget = require("widgets.volume")()
    local keyboardlayout_widget = require("widgets.keyboardlayout")()
    local battery_widget = require("widgets.battery")()
    local textclock_widget = wibox.widget.textclock()
    local systray_widget = wibox.widget.systray()

    s.mywibar = awful.wibar({ position = "top", screen = s, height = 26 })

    s.mywibar:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 15,
            s.mytaglist,
            s.mylayoutbox,
        },
        { -- Middle widget
            widget = wibox.container.margin,
            left = 15,
            right = 15,
            s.mytasklist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 15,
            systray_widget,
            keyboardlayout_widget,
            battery_widget,
            volume_widget,
            textclock_widget,
        },
    })
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
    mymainmenu:toggle()
end)))
-- }}}


-- {{{ Key bindings
-- stylua: ignore start
local globalkeys = gears.table.join(
    awful.key({                   }, "XF86AudioRaiseVolume", function() awful.spawn.with_shell("pamixer -i 2") end),
    awful.key({                   }, "XF86AudioLowerVolume", function() awful.spawn.with_shell("pamixer -d 2") end),
    awful.key({                   }, "XF86AudioMute", function() awful.spawn.with_shell("pamixer -t") end),
    awful.key({                   }, "Print", function() awful.spawn.with_shell("flameshot gui") end),
    awful.key({                   }, "XF86MonBrightnessUp", function() awful.spawn.with_shell("light -A 5") end),
    awful.key({                   }, "XF86MonBrightnessDown", function() awful.spawn.with_shell("light -U 5") end),
    awful.key({                   }, "XF86Calculator", function() calculator:toggle() end),
    awful.key({ modkey, "Shift"   }, "Delete", function() awful.spawn("sysact") end,
              { description = "shutdown, reboot, etc", group = "awesome" }),
    awful.key({ modkey            }, "s", hotkeys_popup.show_help,
              { description = "show help", group = "awesome" }),
    awful.key({ modkey, "Control" }, "h", awful.tag.viewprev,
              { description = "view previous", group = "tag" }),
    awful.key({ modkey, "Control" }, "l", awful.tag.viewnext,
              { description = "view next", group = "tag" }),
    awful.key({ modkey            }, "Escape", awful.tag.history.restore,
              { description = "go back", group = "tag" }),
    awful.key({ modkey            }, "j", function() awful.client.focus.byidx(1) end,
              { description = "focus next by index", group = "client" }),
    awful.key({ modkey            }, "k", function() awful.client.focus.byidx(-1) end,
              { description = "focus previous by index", group = "client" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function() awful.client.swap.byidx(1) end,
              { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift"   }, "k", function() awful.client.swap.byidx(-1) end,
              { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
              { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
              { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey            }, "u", awful.client.urgent.jumpto,
              { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey            }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end,
              { description = "go back", group = "client" }),
    awful.key({ modkey            }, "b", function()
        local screen = awful.screen.focused()
        screen.mywibar.visible = not screen.mywibar.visible
    end,
              { description = "toggle statusbar", group = "layout" }),

    -- Standard program
    awful.key({ modkey            }, "e", function() awful.spawn(terminal .. " -e " .. file_manager) end,
              { description = "open a file manager", group = "launcher" }),
    awful.key({ modkey            }, "w", function() awful.spawn(browser) end,
              { description = "open a browser", group = "launcher" }),
    awful.key({ modkey            }, "z", function() awful.spawn(reader) end,
              { description = "open pdf reader", group = "launcher" }),
    awful.key({ modkey            }, "Return", function() awful.spawn(terminal) end,
              { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift"   }, "Escape", awesome.quit,
              { description = "quit awesome", group = "awesome" }),

    -- Gaps
    awful.key({ modkey, "Shift"   }, "]", function() awful.tag.incgap(4) end,
              { description = "increase gaps", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "[", function() awful.tag.incgap(-4) end,
              { description = "decrease gaps", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "=", function() awful.tag.setgap(4) end,
              { description = "set default gaps", group = "layout" }),

    awful.key({ modkey            }, "l", function() awful.tag.incmwfact(0.05) end,
              { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey            }, "h", function() awful.tag.incmwfact(-0.05) end,
              { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "h", function() awful.tag.incnmaster(1, nil, true) end,
              { description = "increase number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
              { description = "decrease number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
              { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
              { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey            }, "space", function() awful.layout.inc(1) end,
              { description = "select next", group = "layout" }),
    awful.key({ modkey, "Control"   }, "space", function() awful.layout.inc(-1) end,
              { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Shift"   }, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
        end
    end,
              { description = "restore minimized", group = "client" }),

    awful.key({ modkey, "Shift"   }, "e", function() awful.spawn("rofi -modi emoji -show emoji") end,
              { description = "emoji selector", group = "launcher" }),
    awful.key({ modkey            }, "d", function() awful.spawn("rofi -show drun") end,
              { description = "open application launcher", group = "launcher" }),

    awful.key({ modkey            }, "r", function() awful.spawn("rofi -show run") end,
              { description = "run prompt", group = "launcher" })
)

local clientkeys = gears.table.join(
    awful.key({ modkey            }, "c", function(c) c:kill() end,
              { description = "close window", group = "client" }),
    awful.key({ modkey, "Shift" }, "space", awful.client.floating.toggle,
              { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Shift"   }, "Return", function(c) c:swap(awful.client.getmaster()) end,
              { description = "move to master", group = "client" }),
    awful.key({ modkey            }, "o", function(c) c:move_to_screen() end,
              { description = "move to screen", group = "client" }),
    awful.key({ modkey            }, "t", function(c) c.ontop = not c.ontop end,
              { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey            }, "n", function(c) c.minimized = true end,
              { description = "minimize", group = "client" }),
    -- FIXME: implement proper function
    awful.key({ modkey            }, "f", function(c)
        c.fullscreen = not c.fullscreen
        local cur_tag = client.focus and client.focus.first_tag or nil
        if cur_tag then
            for _, tag_client in ipairs(cur_tag:clients()) do
                if c.window ~= tag_client.window then
                    tag_client.minimized = c.fullscreen
                end
            end
        end
        c:raise()
    end,
              { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey            }, "m", function(c)
        c.maximized = not c.maximized
    end,
              { description = "maximize/unmaximize", group = "client" })
)

-- Bind all key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(
        globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- stylua: ignore end
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        },
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA", -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "JetBrains Toolbox",
                "jetbrains-toolbox",
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin", -- kalarm.
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "JetBrains Toolbox",
                "Event Tester", -- xev.
                "splash", -- intellij-idea splash screen
            },
            role = {
                "GtkFileChooserDialog",
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
            },
        },
        properties = {
            floating = true,
            placement = awful.placement.centered,
        },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)
-- }}}
