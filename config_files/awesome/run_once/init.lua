--[[

This code is part of TuXXX project
https:/github.com/tuxxx

--]]

local awful = require("awful")

return {
    spawn = function(cmd_arr)
        for _, cmd in ipairs(cmd_arr) do
            findme = cmd
            firstspace = cmd:find(" ")
            if firstspace then
                findme = cmd:sub(0, firstspace-1)
            end
            awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
        end
    end
}
