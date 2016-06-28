-- Integration for awesome WM:
--
--  local getkey = require("getkey")
-- 
--  awful.key({ modkey },            "e",     function () getkey.prompt() end),
--  awful.key({ modkey, "Shift" },   "e",     function () getkey.menu() end),
--

local awful = require("awful")

GETKEY = "getkey"
GETKEY_KEYRING = "login"

local function splitlines(str)
	local t = {}
	for line in string.gmatch(str, "%C+") do
		table.insert(t, line)
	end
	return t
end

local function unlock(ring)
	awful.util.spawn_with_shell("zenity --password | getkey -k'" .. ring .. "' -U")
end

local function getkey(ring, key)
	awful.util.pread("getkey -k'" .. ring .. "' -s " .. key)
	naughty.notify({ text="Key added to clipboard"})
end

return {
    prompt = function ()
        awful.prompt.run({ prompt = "Keyring[" .. GETKEY_KEYRING .. "]: " },
            mypromptbox[mouse.screen].widget,
            function (s)
                local out = awful.util.pread(GETKEY .. " --keyring=" .. GETKEY_KEYRING .. " --selection " .. s)
                mypromptbox[mouse.screen].widget.text = out
            end,
            function (text, cur_pos, ncomp)
                local out = awful.util.pread(GETKEY .. " --keyring=" .. GETKEY_KEYRING .. " --completion=" .. text)
                
                local tokens = {}
                for token in string.gmatch(out, "%S+") do
                    table.insert(tokens, token)
                end

                return awful.completion.generic(text, cur_pos, ncomp, tokens)
            end,
            awful.util.getdir("cache") .. "/getkey_" .. GETKEY_KEYRING
        )
    end,
    menu = function ()
        local rings = awful.util.pread("getkey --list-keyrings")
        local keyrings = {}
        for a, ring in pairs(splitlines(rings)) do
            if string.len(ring) ~= 0 and ring ~= "session" then
                local keys = awful.util.pread("getkey -k " .. ring .. " --list")
                if string.len(keys) == 0 then
                    keyrings[a] = {ring, function() unlock(ring) end }
                else
                    local options = {}
                    for k, key in ipairs(splitlines(keys)) do
                        if string.len(key) ~= 0 then
                            options[k] = {key, function () getkey(ring, key) end}
                        end
                    end
                    keyrings[a] = {ring, options}
                end
            end
        end
        local keyringsMenu = awful.menu({ items = keyrings })
        keyringsMenu:show()
    end,
}
