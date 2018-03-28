--[[

Configuration for Awesome Window Manager.

This code is part of TuXXX project
https:/github.com/tuxxx

--]]

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local run_once      = require("run_once").spawn
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart processes
run_once({"feh --randomize --bg-fill /home/tuxxx/.wallpapers"})
run_once({"nm-applet"})
run_once({"mixxx"})
-- }}}

-- {{{ Variable definitions
local chosen_theme = "powerarrow-dark"
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "xterm"

awful.util.terminal = terminal
awful.util.tagnames = { "mixxx", "jack", "settings", "web" }
awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.floating,
    awful.layout.suit.max
}
awful.util.taglist_buttons = awful.util.table.join(
    awful.button({ }, 1, function(t)
        t:view_only()
	if t.name == "mixxx" then
            run_once({"mixxx"})
	end
	if t.name == "jack" then
            run_once({"qjackctl", "bridges_gui"})
	end
	if t.name == "web" then
            run_once({"iceweasel"})
	end
	if t.name == "settings" then
            run_once({"arandr"})
	end
    end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

local theme_path = string.format("/etc/xdg/awesome/themes/%s/theme.lua", chosen_theme)
beautiful.init(theme_path)
-- }}}

-- {{{ Menu
awful.util.mymainmenu = awful.menu.new( { items = {
    { "shutdown", function() awful.spawn("ls") end }
}})
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Help
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show this help", group="awesome"}),
    -- Menu
    awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back to previous workspace", group = "tag"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
            if s.mybottomwibox then
                s.mybottomwibox.visible = not s.mybottomwibox.visible
            end
        end
    end),
    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"})

    --]]
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap + awful.placement.no_offscreen,
                     size_hints_honor = false
      }
    },

    -- Dialogs
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = false } },

    { rule = { class = "Mixxx" },
      properties = { tag = "mixxx" } },
    { rule = { class = "qjackctl" },
      properties = { titlebars_enabled = true, tag = "jack" } },
    { rule = { class = "Gtkdialog" },
      properties = { titlebars_enabled = true, tag = "jack" } },
    { rule = { class = "Firefox-esr" },
      properties = { titlebars_enabled = true, tag = "web" } },
    { rule = { class = "Arandr" },
      properties = { titlebars_enabled = true, tag = "settings" } },
    { rule = { class = "Pavucontrol" },
      properties = { titlebars_enabled = true, maximized_horizontal = true, maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized then -- no borders if only 1 client visible
            c.border_width = 0
        elseif #awful.screen.focused().clients > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
