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
    return math.max(int, 0)
end

local COLOR = 0
local NUMBER = 1
local STRING = 2
local TABLE = 3
local BOOLEAN = 4
local ANGLE = 5
local ENTITY = 6
local OTHER = 7

local function isFloat(n)
    return n ~= math.floor(n)
end

function Nexus:WriteType(value)
    local itemType = type(value)

    if IsColor(value) then
        net.WriteUInt(COLOR, 3)
        net.WriteColor(value)
    elseif itemType == "number" then
        net.WriteUInt(NUMBER, 3)

        local isFloat = isFloat(value)
        net.WriteBool(isFloat)
        if isFloat then
            net.WriteFloat(value)
        else
            if value >= 0 then
                net.WriteBool(true)
                Nexus:WriteUInt(value)
            else
                net.WriteBool(false)
                net.WriteInt(value, 32)
            end
        end
    elseif itemType == "string" then
        net.WriteUInt(STRING, 3)
        net.WriteString(value)
    elseif itemType == "table" then
        net.WriteUInt(TABLE, 3)
        net.WriteBool(table.IsSequential(value))
        net.WriteTable(value, table.IsSequential(value))
    elseif itemType == "Angle" then
        net.WriteUInt(ANGLE, 3)
        net.WriteAngle(value)
    elseif itemType == "Entity" or itemType == "Player" then
        net.WriteUInt(ENTITY, 3)
        net.WriteEntity(value)
    elseif itemType == "boolean" then
        net.WriteUInt(BOOLEAN, 3)
        net.WriteBool(value)
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
        local isFloat = net.ReadBool()
        if isFloat then
            return net.ReadFloat()
        end

        local isUnsigned = net.ReadBool()
        if isUnsigned then
            return Nexus:ReadUInt()
        else
            return net.ReadInt(32)
        end
    elseif int == STRING then
        return net.ReadString()
    elseif int == TABLE then
        local isSequential = net.ReadBool()
        return net.ReadTable(isSequential)
    elseif int == ANGLE then
        return net.ReadAngle()
    elseif int == ENTITY then
        return net.ReadEntity()
    elseif int == BOOLEAN then
        return net.ReadBool()
    elseif int == OTHER then
        return net.ReadTable(true)
    end
end