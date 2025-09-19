Nexus = Nexus or {}

local fontCache = {}
local fontCacheV2 = {}
function Nexus:GetFont(size, dontScale, isBold)
    if not istable(size) then
        size = math.floor(size)

        local name = "Nexus:"..tostring(size)..":"..(dontScale and "Non" or "Scaled")..(isBold and "Bold" or "NonBold")
        if fontCache[name] then return name end
        surface.CreateFont(name, {
            font = isBold and "Lato" or "Lato Regular",
            size = dontScale and size or Nexus:Scale(size),
            weight = isBold and 700 or 500,
            extended = true,
            antialias = true,
        })

        fontCache[name] = {size, dontScale, isBold}
        return name
    else
        local data = size
        local size = math.floor(data.size)
        local dontScale = data.dontScale
        local isBold = data.bold
        local activeFont = data.font or (isBold and "Lato" or "Lato Regular")
        local name = "NexusV2:"..tostring(size)..":"..(dontScale and "Non" or "Scaled")..(isBold and "Bold" or "NonBold")..(activeFont)

        if fontCacheV2[name] then return name end

        surface.CreateFont(name, {
            font = activeFont,
            size = dontScale and size or Nexus:GetScale(size),
            weight = isBold and 700 or 100,
            extended = true,
            antialias = true,
        })

        fontCacheV2[name] = {size, dontScale, isBold}
        return name
    end
end

hook.Add("OnScreenSizeChanged", "Nexus:ScaleFonts", function()
    fontCache = {}
    fontCacheV2 = {}
end)