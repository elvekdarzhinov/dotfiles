----------------------------------------------------------------------------
--- Wallpaper Blurring Script
--
-- @author William McKinnon
-- @module wallpaper
--
--- Enjoy!
----------------------------------------------------------------------------

--      ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗ 
--      ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
--      ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
--      ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
--      ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
--       ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝

-- ===================================================================
-- Imports
-- ===================================================================

local awful = require("awful")
local filesystem = require("gears.filesystem")
local naughty = require("naughty")
local home_dir = os.getenv("HOME")

-- ===================================================================
-- Initialization
-- ===================================================================

local wallpaper = home_dir .. "/.local/share/bg"
local blurredWallpaper = home_dir .. "/.local/share/blurred-bg"

-- C api
local tag = tag
local client = client

local blurred = false;

-- Set initial wallpaper
awful.spawn.with_shell("feh --no-fehbg --bg-fill " .. wallpaper)

-- check if blurred wallpaper needs to be created
if not filesystem.file_readable(blurredWallpaper) then
  naughty.notify({
     preset = naughty.config.presets.normal,
     title = 'Wallpaper',
     text = 'Generating blurred wallpaper...'
   })
   -- uses image magick to create a blurred version of the wallpaper
   awful.spawn.with_shell("convert -filter Gaussian -blur 0x15 " .. wallpaper .. " " .. blurredWallpaper)
end

-- ===================================================================
-- Functionality
-- ===================================================================

-- changes to blurred wallpaper
local function blur()
   if not blurred then
      awful.spawn.with_shell("feh --no-fehbg --bg-fill " .. blurredWallpaper)
      blurred = true
   end
end

-- changes to normal wallpaper
local function unblur()
   if blurred then
      awful.spawn.with_shell("feh --no-fehbg --bg-fill " .. wallpaper)
      blurred = false
   end
end

-- blur / unblur on tag change
tag.connect_signal('property::selected', function(t)
   -- if tag has clients
   for _ in pairs(t:clients()) do
      blur()
      return
   end
   -- if tag has no clients
   unblur()
end)

-- check if wallpaper should be blurred on client open
client.connect_signal("manage", function()
   blur()
end)

-- check if wallpaper should be unblurred on client close
client.connect_signal("unmanage", function()
   local t = awful.screen.focused().selected_tag
   -- check if any open clients
   for _ in pairs(t:clients()) do
      return
   end
   -- unblur if no open clients
   unblur()
end)
