# gnome-keyring-getkey
Hacked-together command-line gnome-keyring client, with awesome integration.

### Dependencies (APT)

* `python-gnomekeyring`
* `xsel`

## getkey
Python command-line client using `python-gnomekeyring`


List available keyrings from the local gnome-keyring-daemon:

    $ getkey --list-keyrings
    login
    foobar

Unlock a locked keyring if required, prompting for a password on stdin:

    $ getkey --keyring foobar --unlock
    ...

List keys from a given keyring:

    $ getkey --keyring foobar --list
    random1
    pw3

Retreive and print out the plaintext key:

    $ getkey --keyring foobar random1
    ...

Retreive a key into the X selection buffer, ready for pasting. Does not display the key:

    $ getkey --keyring foobar --selection pw3

Generate and store a new key, using `--generate-length` random alnum chars:

    $ getkey --keyring foobar --generate pw4

Output keynames for tab-completion:

    $ getkey --keyring foobar --completion=
    random1
    pw3
    $ getkey --keyring foobar --completion=ra
    random1

## awesome-getkey.lua
Simple awful.widgets.prompt -based integration.

Customize the keyring to use:

    GETKEY_KEYRING = "foobar"

Bind to a key in your `~/.config/awesome/rc.lua` using e.g.


    globalkeys = awful.util.table.join(
        ...

        awful.key({ modkey}, "e",                  dofile("/home/terom/dev/getkey/awesome-getkey-prompt.lua")),
        
        ...
    )

XXX: very hacky and largely untested.
