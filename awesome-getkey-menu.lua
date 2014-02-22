-- Add to rc.lua or include
-- call gnomenu() using f.e. keybinding

function lines(str)
	local t = {}
	for line in string.gmatch(str, "%C+") do
		table.insert(t, line)
	end
	return t
end

function unlock(ring)
	awful.util.spawn_with_shell("zenity --password | getkey -U -k\"" .. ring .. "\"")
end

function getkey(ring, key)
	awful.util.pread("getkey --selection --keyring " .. ring .. " " .. key)
	naughty.notify({ text="Key added to clipboard"})
end

function gnomenu()
	local rings = awful.util.pread("getkey --list-keyrings")
	local keyrings = {}
	for a, ring in pairs(lines(rings)) do
		if string.len(ring) ~= 0 and ring ~= "session" then
			local keys = awful.util.pread("getkey -k " .. ring .. " --list")
			if string.len(keys) == 0 then
				keyrings[a] = {ring, function() unlock(ring) end }
			else
				local options = {}
				for k, key in ipairs(lines(keys)) do
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
end

