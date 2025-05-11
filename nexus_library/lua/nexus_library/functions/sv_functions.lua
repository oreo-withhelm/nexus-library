util.AddNetworkString("Nexus:RequestNetworks")
net.Receive("Nexus:RequestNetworks", function(len, ply)
    if ply.Nexus_Requested then return end
    ply.Nexus_Requested = true

    hook.Run("Nexus:FullyLoaded", ply)
end)

util.AddNetworkString("Nexus:ChatMessage")
function Nexus:ChatMessage(ply, tbl)
    net.Start("Nexus:ChatMessage")
    net.WriteUInt(#tbl, 4)
    for _, v in ipairs(tbl) do
        net.WriteType(v)
    end
    net.Send(ply)
end

util.AddNetworkString("Nexus:Notification")
function Nexus:Notify(ply, int, seconds, str, addonPhrase)
    if not IsValid(ply) then return end
    net.Start("Nexus:Notification")
    net.WriteBool(addonPhrase and true or false)
    if addonPhrase then
        net.WriteString(str)
        net.WriteString(addonPhrase)
    else
        net.WriteString(str)
    end
    net.WriteUInt(int, 2)
    net.WriteUInt(seconds, 5)
    net.Send(ply)
end

local id = 0
util.AddNetworkString("Nexus:PopupAsk")
function Nexus:PopupAsk(ply, str, callback)
    ply.Popup = {id, callback}

    net.Start("Nexus:PopupAsk")
    net.WriteUInt(id, 32)
    net.WriteString(str)
    net.Send(ply)

    id = id + 1
end

util.AddNetworkString("Nexus:PressedPopup")
net.Receive("Nexus:PressedPopup", function(len, ply)
    local id = net.ReadUInt(32)
    if !ply.Popup or ply.Popup[1] ~= id then
        Nexus:Notify(ply, 1, 3, "ERROR")
        return
    end

    ply.Popup[2]()
    ply.Popup = nil
    Nexus:Notify(ply, 1, 3, "Success")
end)