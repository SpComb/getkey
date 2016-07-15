-- Integration for awesome WM:
--
--  local getkey = require("awesome-getkey")
-- 
--  awful.key({ modkey },            "e",     function () getkey.prompt() end),
--  awful.key({ modkey, "Shift" },   "e",     function () getkey.menu() end),
--

local awful = require("awful")
local naughty = require("naughty")

GETKEY = "getkey"
GETKEY_KEYRING = "login"

local function splitlines(str)
	local t = {}
	for line in string.gmatch(str, "%C+") do
        if string.len(line) ~= 0 then
            table.insert(t, line)
        end
	end
	return t
end

local function listkeyrings()
    return splitlines(awful.util.pread("getkey --list-keyrings"))
end

local function listkeys(ring)
    return splitlines(awful.util.pread("getkey --keyring='" .. ring .. "' --list"))
end

local function unlock(ring)
	awful.util.spawn_with_shell("zenity --password | getkey --keyring='" .. ring .. "' -U")
end

local function getkey(ring, key)
	awful.util.pread("getkey --keyring='" .. ring .. "' -s " .. key)
	naughty.notify({ text="Key added to clipboard: " .. key})
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
        local keyrings = {}

        for a, ring in pairs(listkeyrings()) do
            if string.len(ring) ~= 0 and ring ~= "session" then
                local options = {}
                local empty = true

                for i, key in ipairs(listkeys(ring)) do
                    options[i] = {key, function () getkey(ring, key) end}
                    empty = false
                end

                if empty then
                    keyrings[a] = {ring, function() unlock(ring) end }
                else
                    keyrings[a] = {ring, options}
                end
            end
        end

        awful.menu({ items = keyrings }):show()
    end,
}
