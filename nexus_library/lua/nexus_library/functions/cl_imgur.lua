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

Nexus.Materials = {}
function Nexus:GetImgur( id )
    id, iconType = self:ParseURL( id )
    id = string.lower(id)
    local url = id

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

    local function ImgurDownload()
        http.Fetch("https://i.imgur.com/"..id..".png", function(b, len, head, code)
            if code != 200 or len == 34641 then print("[ Nexus ] Imgur: FAILED IMAGE SAVE: "..id) return end // not valid in our region

            self:SaveData( nil, "nexus_v2", id, b, false, "png" )
            self.Materials[ id ] = Material( "../data/nexus_v2/" .. id .. ".png", "noclamp smooth mips")
            print("[ Nexus ] Imgur: SAVED IMAGE: "..id)
        end, function(error)
            print("[ Nexus ] Imgur: FAILED TO FETCH IMAGE: "..id)
        end)
    end

    local function GithubDownload()
        local url = ("https://raw.githubusercontent.com/oreo-withhelm/nexus-imgur/main/"..id..".png")
        http.Fetch(
            url,
            function(body, len, headers, code)
                if code != 200 then ImgurDownload() print("[ Nexus ] Github: INVALID RESPONSE: "..id) return end

                local f = file.Open("nexus_v2/"..id..".png", "wb", "DATA")
                if f then
                    f:Write(body)
                    f:Close()
                    print("[ Nexus ] Github: SAVED IMAGE: "..id)
                else
                    print("[ Nexus ] Github: FAILED IMAGE SAVE: "..id)
                end

                self.Materials[id] = Material("../data/nexus_v2/" .. id .. ".png", "noclamp smooth mips")
            end,
            function(error)
                print("[ Nexus ] Github: FAILED TO FETCH IMAGE: "..id)
            end
        )
    end
--[[
    local function DiscordDownload()
        url = "https://"..url
        print(url)
        print("https://cdn.discordapp.com/attachments/534843100976119808/1430168582985093313/Screenshot_20251021_063948_Facebook.jpg?ex=6900b4c9&is=68ff6349&hm=86589249a7a296ff21e85503e214e60314b44c44989480500f3cddb0dbe55461&=&format=png&width=1129&height=858")
        http.Fetch(
            url,
            function(body, len, headers, code)
                if code != 200 then print("[ Nexus ] Discord: INVALID RESPONSE: "..id) return end

                local f = file.Open("nexus/"..id..".png", "wb", "DATA")
                if f then
                    f:Write(body)
                    f:Close()
                    print("[ Nexus ] Discord: SAVED IMAGE: "..id)
                else
                    print("[ Nexus ] Discord: FAILED IMAGE SAVE: "..id)
                end

                self.Materials[id] = Material("../data/nexus/" .. id .. ".png", "noclamp smooth mips")
            end,
            function(error)
                print("[ Nexus ] Discord: FAILED TO FETCH IMAGE: "..id)
            end
        )
    end
--]]
    if iconType == "imgur" then
        GithubDownload()
        return self.Materials[id]
    end

    //DiscordDownload()
    GithubDownload()
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