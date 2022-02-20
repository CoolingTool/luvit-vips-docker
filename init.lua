local uv = require 'uv'
local v = require 'vips'
local http = require 'coro-http'
local fs = require 'coro-fs'
local chown = require 'fs'.chown

local avatarForm = 'https://cdn.discordapp.com/avatars/%s.png?size=128'
local emojiForm = 'https://twemoji.maxcdn.com/v/latest/svg/%s.svg'
local circForm = [[
    <svg height="%s" width="%s">
        <circle cx="%s" cy="%s" r="%s" fill="#FFF"/>
    </svg>
]]



local function download(url, size)
    return v.Image.thumbnail_buffer(select(2, http.request("GET", url)), size)
end



local function bro()
    local w, h = 230, 112

    local rsiz = 64

    local link1 = 
        avatarForm:format'839035980371460107/6cd41ca58bdbbd3173ddc57cdf266bc7'
    local link2 = 
        avatarForm:format'821432433491705977/902a3a4917e4df496f61aa08438db626'

    local ranks = {
        download(emojiForm:format'1f464', rsiz),
        download(emojiForm:format'1f5e3', rsiz),
        download(emojiForm:format'1f465', rsiz),
        download(emojiForm:format'1fac2', rsiz),
    }

    local base = v.Image.black(w, h):copy{interpretation = "srgb"}
    local circ = v.Image.new_from_buffer(circForm:format(h, w, h/2, h/2, h/2))

    local x = uv.hrtime()

    local icon1 = download(link1, h):composite(circ, "dest-in")
    local icon2 = download(link2, h):composite(circ, "dest-in")

    local final = base:insert(icon1, 0, 0)
        :insert(icon2, w - h, 0)
        :composite(ranks[math.random(#ranks)], 'over',
                    {x = w/2 - rsiz/2, y = h/2 - rsiz/2})

    local png = final:pngsave_buffer()

    local path = 'out/bro.png'
    fs.writeFile(path, png)
    --fs.chmod(path, 0x777)
    --chown(path, 65534, 65534)

    print('bro:', (uv.hrtime() - x)/1000000000)
end

local function emote()
    local x = uv.hrtime()

    local svg = download(emojiForm:format'1f9ca', 1024)
        
    local png = svg:pngsave_buffer()

    local path = 'out/emoji.png'
    fs.writeFile(path, png)
    --fs.chmod(path, 0x777)
    --chown(path, 65534, 65534)

    print('emote:', (uv.hrtime() - x)/1000000000)
end

return bro(), emote()