// optimised dynamic writeuint
function Nexus:WriteUInt(int)
    int = tonumber(int)
    while int >= 0x80 do
        net.WriteUInt(bit.band(int, 0x7F) + 0x80, 8)
        int = bit.rshift(int, 7)
    end
    net.WriteUInt(int, 8)
end

function Nexus:ReadUInt()
    local int, shift = 0, 0
    local counter = 0
    while true do
        if counter == 6 then
            break
        end

        local byte = net.ReadUInt(8)
        int = bit.bor(int, bit.lshift(bit.band(byte, 0x7F), shift))
        if bit.band(byte, 0x80) == 0 then break end
        shift = shift + 7
        counter = counter + 1
    end
    return int
end

local COLOR = 0
local NUMBER = 1
local STRING = 2
local TABLE = 3
local PLAYER = 4
local ANGLE = 5
local ENTITY = 6
local OTHER = 7
function Nexus:WriteType(value)
    local itemType = type(value)

    if IsColor(value) then
        net.WriteUInt(COLOR, 3)
        net.WriteColor(value)
    elseif itemType == "number" then
        net.WriteUInt(NUMBER, 3)
        Nexus:WriteUInt(value)
    elseif itemType == "string" then
        net.WriteUInt(STRING, 3)
        net.WriteString(value)
    elseif itemType == "table" then
        net.WriteUInt(TABLE, 3)
        net.WriteTable(value)
    elseif itemType == "Player" then
        net.WriteUInt(PLAYER, 3)
        net.WritePlayer(value)
    elseif itemType == "Angle" then
        net.WriteUInt(ANGLE, 3)
        net.WriteAngle(value)
    elseif itemType == "Entity" then
        net.WriteUInt(ENTITY, 3)
        net.WriteEntity(value)
    else
        net.WriteUInt(OTHER, 3)
        net.WriteTable({value}, true)
    end
end

function Nexus:ReadType()
    local int = net.ReadUInt(3)
    if int == COLOR then
        return net.ReadColor()
    elseif int == NUMBER then
        return Nexus:ReadUInt()
    elseif int == STRING then
        return net.ReadString()
    elseif int == TABLE then
        return net.ReadTable()
    elseif int == PLAYER then
        return net.ReadPlayer()
    elseif int == ANGLE then
        return net.ReadAngle()
    elseif int == ENTITY then
        return net.ReadEntity()
    elseif int == OTHER then
        return net.ReadTable(true)
    end
end