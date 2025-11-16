function Nexus:Scale(number)
    local val = math.floor(math.max(number*(math.min(ScrH(), 1080)/(1440)), 1))
    val = val%2 ~= 0 and val + 1 or val

    return val
end

Nexus.Frame = Nexus.Frame or nil
function Nexus:CreateFrame(title, w, h)
    if Nexus.Frame then Nexus.Frame:Remove() end
    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetTitle(title)
    frame:SetSize(Nexus:GetScale(w), Nexus:GetScale(h))

    Nexus.Frame = frame
    return frame
end

local cache = {}
function Nexus:OffsetColor(col, num, dontAlpha)
    stringCol = col.r.." "..col.g.." "..col.b.." "..col.a.." "..num..tostring(dontAlpha)
    if cache[stringCol] then
        return cache[stringCol]
    end

    local newCol = Color(col.r + num, col.g + num, col.b + num, (dontAlpha and col.a or col.a + num))
    cache[stringCol] = newCol
    return newCol
end

function Nexus:Overhead(ent, str, override, secondaryStr)
    if ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then return end

    local pos = ent:GetPos()
    local angle = ent:GetAngles()
    local eyeAngle = LocalPlayer():EyeAngles()

    angle:RotateAroundAxis(angle:Forward(), 90)
    angle:RotateAroundAxis(angle:Right(), - 90)

    local font = Nexus:GetFont(18*5, true)
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(str)
    local wide = tw + Nexus:Scale(150)
    local tall = th + Nexus:Scale(60)

    cam.Start3D2D(pos + ent:GetUp() * (override or 80), Angle(0, eyeAngle.y - 90, 90), 0.05)
        local y = secondaryStr and -tall*1.8 or 0 - (tall/2)
        draw.RoundedBox(10, -wide/2, y, wide, tall, Nexus:GetColor("background"))
        draw.SimpleText(str, font, 0, y + tall/2, Nexus:GetTextColor(Nexus:GetColor("background")), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if secondaryStr then
            local tw, th = surface.GetTextSize(secondaryStr)
            local wide = tw + Nexus:Scale(150)
            local tall = th + Nexus:Scale(60)
            draw.RoundedBox(10, -wide/2, y + tall + 10, wide, tall, Nexus:GetColor("background"))
            draw.SimpleText(secondaryStr, font, 0, y + tall + 10 + tall/2, Nexus:GetTextColor(Nexus:GetColor("background")), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

hook.Add("InitPostEntity", "Nexus:RequestNetworks", function()
    net.Start("Nexus:RequestNetworks")
    net.SendToServer()
end)

net.Receive("Nexus:ChatMessage", function()
    local tbl = {}
    for i = 1, net.ReadUInt(4) do
        local val = net.ReadType()
        table.insert(tbl, val)
    end

    chat.AddText(unpack(tbl))
end)

net.Receive("Nexus:Notification", function()
    local isPhrase = net.ReadBool()
    local str = net.ReadString()
    local addon = ""
    if isPhrase then
        addon = net.ReadString()
        addon = addon ~= "" and addon or false
    end

    local err, time = net.ReadUInt(2), net.ReadUInt(5)
    notification.AddLegacy(isPhrase and Nexus:GetPhrase(str, addon) or str, err, time)
end)

local bgCol = Color(0, 0, 0, 150)
function Nexus:StringQuery(title, text, callback, buttonText, isNumeric)
    callback = callback or function() end

    local bgBlur = vgui.Create("DPanel")
    bgBlur:SetSize(ScrW(), ScrH())
    bgBlur:MakePopup()
    bgBlur.Paint = function(s, w, h)
        Nexus.RNDX.Draw(0, 0, 0, w, h, color_white, Nexus.RNDX.BLUR)
        Nexus.RNDX.Draw(0, 0, 0, w, h, bgCol)
    end
    bgBlur.Think = function(s)
        if not IsValid(bgBlur.frame) then
            s:Remove()
        end
    end

    local frame = bgBlur:Add("Nexus:V2:Frame")
    frame:SetSize(Nexus:Scale(400), Nexus:GetScale(110))
    frame:Center()
    frame:SetTitle(title)
    frame:MakePopup()
    local old = frame.Think or function() end
    frame.Think = function()
        old(frame)
        frame:MoveToFront()

        if not bgBlur:IsValid() then
            frame:Remove()
        end
    end
    bgBlur.frame = frame

    local margin = Nexus:GetMargin()
    local entry = frame:Add("Nexus:V2:TextEntry")
    entry:Dock(FILL)
    entry:DockMargin(margin, margin, margin, margin)
    entry:SetPlaceholder(text)
    if isNumeric then
        entry:SetNumeric(true)    
    end

    local button = frame:Add("Nexus:V2:Button")
    button:Dock(RIGHT)
    button:DockMargin(0, margin, margin, margin)
    button:SetText(buttonText or Nexus:GetPhrase("Ok", "nexus_lib"))
    button.DoClick = function()
        callback(entry:GetValue())
        frame:Remove()
    end
end

function Nexus:LegacyPopup(title, text, callback)
    callback = callback or function() end

    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetSize(Nexus:Scale(400), Nexus:Scale(180))
    frame:Center()
    frame:SetTitle(title)
    frame:MakePopup()

    local margin = Nexus:GetMargin()
    local label = frame:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(margin, margin, margin, 0)
    label:SetText(text)
    label:SetFont(Nexus:GetFont({size = 15}))
    label:SetContentAlignment(5)
    label:SizeToContents()

    surface.SetFont(Nexus:GetFont({size = 15}))
    local tw, th = surface.GetTextSize(text)
    tw = tw + margin*4
    frame:SetWide(math.max(frame:GetWide(), tw))
    frame:SetX((ScrW()/2) - (frame:GetWide()/2))
    local panel = frame:Add("DPanel")
    panel:Dock(FILL)
    panel:DockMargin(margin, margin, margin, margin)
    panel.Paint = nil
    panel.PerformLayout = function(s, w, h)
        local wide = (w - margin)/2
        for k, v in ipairs(s:GetChildren()) do
            v:SetSize(wide, h)
            v:SetX((k-1) * (wide + margin))
        end
    end

    local button = panel:Add("Nexus:V2:Button")
    button:SetText("Yes")
    button.DoClick = function()
        callback()
        frame:Remove()
    end

    local button = panel:Add("Nexus:V2:Button")
    button:SetText("No")
    button:SetSecondary()
    button.DoClick = function()
        frame:Remove()
    end
end

net.Receive("Nexus:PopupAsk", function()
    local id = net.ReadUInt(32)
    local str = net.ReadString()
    Nexus:QueryPopup("Popup", str, function()
        net.Start("Nexus:PressedPopup")
        net.WriteUInt(id, 32)
        net.SendToServer()
    end)
end)

function Nexus:Notification(title, text, callback)
    callback = callback or function() end

    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetSize(Nexus:Scale(350), Nexus:Scale(120))
    frame:Center()
    frame:SetTitle(title)
    frame:MakePopup()

    local margin = Nexus:Scale(10)
    local label = frame:Add("DLabel")
    label:Dock(FILL)
    label:SetText(text)
    label:SetFont(Nexus:GetFont(20))
    label:SizeToContents()
    label:SetContentAlignment(5)

    surface.SetFont(Nexus:GetFont(20))
    local tw, th = surface.GetTextSize(text)
    tw = tw + Nexus:Scale(40)

    local size = math.max(Nexus:Scale(250), tw)
    frame:SetWide(size)
    frame:Center()
end

local gradient = Material("vgui/gradient-d")
local black = Color(0, 0, 0, 200)

function Nexus:DrawRoundedGradient(x, y, w, h, bgCol, overrideCol, roundness, rot, c1, c2, c3, c4)
	local col = overrideCol or black

    rot = rot or 0
    if Nexus:GetSetting("Nexus-Disable-Gradients", false) then
        draw.RoundedBox(roundness or Nexus:Scale(10), x, y, w, h-y, bgCol)
    else
        w = w % 2 == 0 and w or w + 1
        h = h % 2 == 0 and h or h + 1
        Nexus.Masks.Start()
            surface.SetDrawColor(bgCol.r, bgCol.g, bgCol.b, bgCol.a)
            surface.DrawRect(x, y, w, h)
            surface.SetDrawColor(col.r, col.g, col.b, col.a)
            surface.SetMaterial(gradient)
            surface.DrawTexturedRectRotated(x + w/2, y + h/2, w, h, rot)
        Nexus.Masks.Source()
            draw.RoundedBoxEx(roundness or Nexus:Scale(10), x, y, w, h-y, color_white, not c1, not c2, not c3, not c4)
        Nexus.Masks.End()
    end
end

local function toLinear(c)
    return (c <= 0.03928) and (c / 12.92) or (( (c + 0.055) / 1.055 ) ^ 2.4)
end

local colCache = {}
function Nexus:GetTextColor(color, alpha)
    local col = color
    if alpha and isnumber(alpha) then
        col = table.Copy(color)
        col.a = alpha
    end

    local key = string.format("%d,%d,%d,%d", col.r, col.g, col.b, col.a)
    if alpha and isbool(alpha) then
        key = key .. "_alpha"
    end
    if colCache[key] then return colCache[key] end

    local a = col.a / 255
    local r = col.r / 255
    local g = col.g / 255
    local b = col.b / 255

    local bgR, bgG, bgB = 0, 0, 0
    local blendedR = r * a + bgR * (1 - a)
    local blendedG = g * a + bgG * (1 - a)
    local blendedB = b * a + bgB * (1 - a)

    blendedR = toLinear(blendedR)
    blendedG = toLinear(blendedG)
    blendedB = toLinear(blendedB)

    local luminance = 0.2126 * blendedR + 0.7152 * blendedG + 0.0722 * blendedB

    local textCol = luminance > 0.179 and Nexus:GetColor("background-text") or Nexus:GetColor("primary-text")
    print(alpha)
    if alpha and isbool(alpha) then
        textCol = luminance > 0.179 and Nexus:GetColor("background-secondary-text") or Nexus:GetColor("secondary-text")
    end

    colCache[key] = textCol
    return textCol
end

if not file.Exists("nexus_user_settings.txt", "DATA") then
    file.Write("nexus_user_settings.txt", util.TableToJSON({}))
end

local cache = util.JSONToTable(file.Read("nexus_user_settings.txt", "DATA") or "") or {}
function Nexus:GetSetting(id, default)
    default = default or false
    return cache[id] or default
end

function Nexus:SetSetting(id, value)
    cache[id] = value
    file.Write("nexus_user_settings.txt", util.TableToJSON(cache))

    if id == "nexus_language" then
        hook.Run("Nexus:LanguageChanged", value)
    end
end