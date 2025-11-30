local draw = draw

local replace = { ":", "/", }
function Nexus:ParseKey( k )
    local a = string.lower( k )
    for i=1, #replace do
        a = string.Replace( a, replace[i], "_" )
    end
    return a
end

file.CreateDir( "nexus_v2" )

// v1 -> v2 use Nexus:GetSetting(id) and Nexus:SetSetting(id, value) instead
function Nexus:SaveData( sid, path, name, data, bool, format )
    path = ( path or "nexus_datasave" )
    format = format or "dat"
    file.CreateDir( path )
    if sid then
        local a = self:ParseKey( sid )
        file.CreateDir( path .. "/" .. a )
        path = ( path .. "/" .. a .. "/" )
    else
        path = ( path .. "/" )
    end
    path = ( path .. name .. "." .. format )
    file.Write( path, ( bool and util.TableToJSON( data, true ) or data ) )
end

function Nexus:LoadData( sid, path, name, bool, format )
    path = ( path or "nexus_datasave" )
    format = format or "dat"
    if sid then
        local a = self:ParseKey( sid )
        path = ( path .. "/" .. a .. "/" )
    else
        path = ( path .. "/" )
    end
    path = ( path .. name .. "." .. format )
    if file.Exists( path, "DATA" ) then
        local r = file.Read( path, "DATA" )
        return ( bool and util.JSONToTable( r ) or r )
    end
    return false
end

function Nexus:ParseURL( s )
    local iconType = "imgur"
	s = string.Replace( s, "https://", "" )
	s = string.Replace( s, "http://", "" )	    

    if string.Left(s, 20) == "media.discordapp.net" or string.Left(s, 18) == "cdn.discordapp.com" then
        iconType = "discord"
        s = string.Replace(s, "webp", "png")
        return s, iconType
    end

    s = string.Replace( s, "i.imgur.com/", "" )
	s = string.Replace( s, "imgur.com/", "" )
	s = string.Replace( s, ".png", "" )
	s = string.Replace( s, ".jpeg", "" )
	s = string.Replace( s, ".jpg", "" )
	s = string.Replace( s, "/", "" )

	return s, iconType
end

local proxyURL = false
local function ImgurDownload(id)
    local function onError()
        print("[ Nexus ] Imgur: FAILED TO FETCH IMAGE: "..id)

        http.Fetch(proxyURL..id, function(b, len, head, code)
            if code != 200 or len == 34641 then print("[ Nexus ] Proxy: FAILED IMAGE SAVE: "..id) return end // not valid in our region

            Nexus:SaveData( nil, "nexus_v2", id, b, false, "png" )
            Nexus.Materials[ id ] = Material( "../data/nexus_v2/" .. id .. ".png", "noclamp smooth mips")
            print("[ Nexus ] Proxy: SAVED IMAGE: "..id)
        end, function(error)
            print("[ Nexus ] Proxy: FAILED TO FETCH IMAGE: "..id)
        end)
    end

    http.Fetch( "https://i.imgur.com/" .. id .. ".png", function(b, len, head, code)
        if code != 200 or len == 34641 then onError() return end // not valid image

        Nexus:SaveData( nil, "nexus_v2", id, b, false, "png" )
        Nexus.Materials[ id ] = Material( "../data/nexus_v2/" .. id .. ".png", "noclamp smooth mips")
        print("[ Nexus ] Imgur: SAVED IMAGE: "..id)
    end, function(error)
        onError()
    end)
end

local imgurQueue = {}
local function FetchURL()
    HTTP({
        method = "GET",
        url = "https://raw.githubusercontent.com/oreo-withhelm/static-data/refs/heads/main/vps-ip.txt",
        headers = {},
        success = function(code, body, headers)
            if !code == 200 then return end
            local url = string.Trim(body)
            url = string.Replace(url, ":3050/translate", ":3002/proxy?id=")
            proxyURL = url

            for _, id in pairs(imgurQueue) do
                ImgurDownload(id)
            end

            imgurQueue = {}
        end,
        failed = function(error)
        end
    })
end
FetchURL()

Nexus.Materials = {}
function Nexus:GetImgur( id )
    id, iconType = self:ParseURL( id )

    if self.Materials[ id ] then return self.Materials[ id ] end
    self.Materials[ id ] = Material( "color" )
    if self:LoadData( nil, "nexus_v2", id, false, "png" ) then
        self.Materials[ id ] = Material( "../data/nexus_v2/" .. id .. ".png", "noclamp smooth mips" )
        return self.Materials[ id ]
    end

    if file.Exists("materials/nexus_v2/"..id..".png", "GAME") then
        self.Materials[ id ] = Material( "nexus_v2/"..id..".png", "noclamp smooth mips" )
        return self.Materials[ id ]
    end

    if not proxyURL then
        table.insert(imgurQueue, id)
        return self.Materials[id]
    end

    ImgurDownload(id)

    return self.Materials[id]
end

function Nexus:GetMaterialSize(id)
    local mat = Nexus:GetImgur(id)
    return mat:Width(), mat:Height()
end

function Nexus:DrawImgur( id, x, y, w, h, color, r )
    x = x or 0; y = y or 0; w = w or 0; h = h or 0; color = color or color_white;

    surface.SetDrawColor( color or color_white )
    surface.SetMaterial( type(id) == "IMaterial" and id or self:GetImgur( id ) )
    if r then
        surface.DrawTexturedRectRotated( x, y, w, h, r )
    else
        surface.DrawTexturedRect( x, y, w, h )
    end
end