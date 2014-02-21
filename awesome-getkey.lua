-- awful.key({ modkey}, "e",                  dofile("/home/terom/.config/awesome/getkey.lua"))
--
require("awful")

GETKEY = "getkey"
GETKEY_KEYRING = "kapsi"

return function ()
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
        end
    )
end

