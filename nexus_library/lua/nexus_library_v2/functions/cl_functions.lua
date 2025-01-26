local margins = {
    ["large"] = function() return Nexus:GetScale(16) end,
    ["normal"] = function() return Nexus:GetScale(8) end,
    ["small"] = function() return Nexus:GetScale(4) end,
}
function Nexus:GetMargin(str)
    if not str then str = "normal" end
    return margins[str]()
end

local cachedScales = {}
function Nexus:GetScale(number)
    if cachedScales[number] then return cachedScales[number] end

    local scaledValue = math.max(number * (ScrH() / 1080), 1)
    local value = scaledValue % 2 == 0 and scaledValue or scaledValue + 1

    cachedScales[number] = value

    return value
end

local openDermaMenu
function Nexus:DermaMenu(tbl, onClicked)
    if not tbl then return end
    table.sort(tbl)

    if IsValid(openDermaMenu) then
        openDermaMenu:Remove()
    end

    local offset = Nexus:GetScale(4)
    local x, y = input.GetCursorPos()
    openDermaMenu = vgui.Create("Panel")
    openDermaMenu:SetPos(x + offset, y + offset)
    openDermaMenu:SetSize(100, 100)
    openDermaMenu:MakePopup()
    openDermaMenu:DockPadding(0, offset, 0, 0)
    openDermaMenu.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("background"))
        draw.RoundedBox(Nexus:GetMargin("normal"), 0, offset, w, h-offset, Nexus:GetColor("secondary-2"))
    end

    local scroll = openDermaMenu:Add("Nexus:V2:ScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(0, offset, 0, 0)
    scroll.IsDermaMenu = true
    scroll:GetCanvas().IsDermaMenu = true
    scroll:GetVBar().IsDermaMenu = true
    scroll:GetVBar().btnGrip.IsDermaMenu = true

    local tall = offset
    for k, v in ipairs(tbl) do
        local button = scroll:Add("DButton")
        button:Dock(TOP)
        button:DockMargin(Nexus:GetMargin("small"), 0, Nexus:GetMargin("small"), Nexus:GetMargin("small"))
        button:SetText(v)
        button:SetFont(Nexus:GetFont({size = 14}))
        button:SetTextColor(Nexus:GetTextColor(Nexus:GetColor("secondary")))
        button:SizeToContents()
        button:SetTall(button:GetTall() + Nexus:GetMargin("small"))
        button.IsDermaMenu = true
        button.Paint = function(s, w, h)
            draw.RoundedBox(Nexus:GetMargin("small"), 0, 0, w, h, s:IsHovered() and Nexus:GetColor("background") or Nexus:GetColor("header"))
        end
        button.DoClick = function()
            openDermaMenu:Remove()
            onClicked(v)
        end

        tall = k > 5 and tall or tall + button:GetTall() + Nexus:GetMargin("small")
    end

    tall = tall + offset
    openDermaMenu:SetTall(tall)
end

function Nexus:QueryPopup(str, onYes, onNo, yesText, noText)
    onNo = function() end
    yesText = yesText or Nexus:GetPhrase("Yes")
    noText = noText or Nexus:GetPhrase("No")

    if IsValid(Nexus.Popup) then Nexus.Popup:Remove() end
    local background = vgui.Create("DPanel")
    background:SetSize(ScrW(), ScrH())
    background:MakePopup()
    background.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, w, h)
    end

    local frame = background:Add("Nexus:V2:Frame")
    frame:SetSize(Nexus:GetScale(350), Nexus:GetScale(200))
    frame:Center()
    frame:MakePopup()
    frame:SetTitle(Nexus:GetPhrase("Popup"))
    frame.Header.QuickButtons:Hide()
    frame.OnRefresh = function(a)
        GenerateFrame()
    end
    frame.OnRemove = function()
        background:Remove()
    end
    frame.Think = function(s)
        s:MoveToFront()
    end
    frame.PerformLayout = function(s, w, h)
        frame.yes:SetWide((w - Nexus:GetMargin("normal")*3)/2)
    end
    Nexus.Popup = frame

    local label = frame:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)
    label:SetText(str)
    label:SetWrap(true)
    label:SetAutoStretchVertical(true)
    label:SetFont(Nexus:GetFont({size = 15}))
    label.PerformLayout = function(s)
        frame:SetTall(Nexus:GetScale(100) + Nexus:GetMargin("normal")*2 + label:GetTall())
    end

    frame.yes = frame:Add("Nexus:V2:Button")
    frame.yes:Dock(LEFT)
    frame.yes:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0, Nexus:GetMargin("normal"))
    frame.yes:SetColor(Nexus:GetColor("green"))
    frame.yes:SetText(yesText)
    frame.yes.DoClick = function()
        onYes()
        frame:Remove()
    end

    frame.no = frame:Add("Nexus:V2:Button")
    frame.no:Dock(FILL)
    frame.no:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"))
    frame.no:SetText(noText)
    frame.no.DoClick = function()
        onNo()
        frame:Remove()
    end
end

hook.Add("VGUIMousePressed", "Nexus:DermaMenu:Close", function(panel)
    if IsValid(openDermaMenu) and not panel.IsDermaMenu then
        openDermaMenu:Remove()
    end
end)

local function GenerateFrame()
    if IsValid(Nexus.Frame) then Nexus.Frame:Remove() end
    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetSize(Nexus:GetScale(1000), Nexus:GetScale(800))
    frame:Center()
    frame:MakePopup()
    frame:SetBarIcon("https://imgur.com/K7q22tm", Nexus:GetPhrase("Title"), Nexus:GetPhrase("Subheading"), function() end)
    frame.OnRefresh = function(a)
        GenerateFrame()
    end
    Nexus.Frame = frame

    local scroll = frame:Add("Nexus:V2:ScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0, Nexus:GetMargin("normal"))

    local sidebar = frame:Add("Nexus:V2:Sidebar")
    sidebar:Dock(LEFT)
    sidebar:SetWide(Nexus:GetScale(150))
    sidebar:SetMask({Nexus:GetMargin("large"), false, false, true, false})

    for i = 1, 100 do
        sidebar:AddItem(Nexus:GetPhrase("Server Name"), function()
        end, math.random(1, 2) == 2 and "https://imgur.com/2gTwRFi.png" or false)

        if i % 5 == 0 then
            sidebar:AddSpacer()
        end
    end

    local navbar = frame:Add("Nexus:V2:Navbar")
    navbar:Dock(TOP)
    navbar:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)

    for i = 1, 10 do
        navbar:AddItem(Nexus:GetPhrase("Server Name"), function() end, math.random(1, 2) == 2 and "https://imgur.com/2gTwRFi.png" or false)
    end

    local navbar = frame:Add("Nexus:V2:Navbar")
    navbar:Dock(TOP)
    navbar:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)

    for i = 1, 20 do
        navbar:AddItem(Nexus:GetPhrase("Server Name"), function() end, math.random(1, 2) == 2 and "https://imgur.com/2gTwRFi.png" or false)
    end

    local textEntry = frame:Add("Nexus:V2:TextEntry")
    textEntry:Dock(TOP)
    textEntry:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)
    textEntry:SetPlaceholder(Nexus:GetPhrase("Search"))
end

concommand.Add("nexus_examples", function()
    GenerateFrame()
end)

local loadingLang = false
local loadingFrame = false
function Nexus:LoadLanguage(lang, callback)
    callback = callback or function() end

    if loadingLang then
        notification.AddLegacy(Nexus:GetPhrase("Loading Language"), NOTIFY_ERROR, 3)
        return
    end

    loadingLang = true

    net.Start("Nexus:DownloadLanguage")
    net.WriteString(lang)
    net.SendToServer()

    surface.SetFont(Nexus:GetFont({size = 20}))
    local tw, th = surface.GetTextSize(string.format(Nexus:GetInstalledText(lang, "Loading Language Package"), 10, 50))

    loadingFrame = vgui.Create("DPanel")
    loadingFrame:SetPos(Nexus:GetMargin("normal"), ScrH()/2)
    loadingFrame:SetSize(tw, th + Nexus:GetMargin("large"))
    loadingFrame.loaded = 0
    loadingFrame.callback = callback
    loadingFrame.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("background"))
        draw.SimpleText(string.format(Nexus:GetInstalledText(lang, "Loading Language Package"), s.loaded, table.Count(Nexus.Languages)), Nexus:GetFont({size = 20}), w/2, h/2, Nexus:GetColor("primary-text"), 1, 1)
    end
end

net.Receive("Nexus:UpdateLanguage", function()
    local isUpdate = net.ReadBool()
    if IsValid(loadingFrame) and not isUpdate then
        loadingFrame.callback(false)
        loadingFrame:Remove()
        loadingLang = false
        return
    end

    loadingFrame.loaded = loadingFrame.loaded + 1
end)

net.Receive("Nexus:NetworkLanguage", function()
    local lang = net.ReadString()
    local data = net.ReadUInt(32)
    data = net.ReadData(data)
    data = util.Decompress(data)
    data = util.JSONToTable(data)

    for addon, languages in pairs(data) do
        local tbl = {}
        for id, value in pairs(languages) do
            if id == "Server Name" then
                value = Nexus:GetRawPhrase(id, "Nexus Library", Nexus:GetDefaultLanguage())
            end
            tbl[id] = value
        end

        Nexus:AddLanguages(addon, lang, tbl)
    end

    loadingLang = false

    if IsValid(loadingFrame) then
        loadingFrame.callback(true)
        loadingFrame:Remove()
    end
end)

hook.Add("InitPostEntity", "Nexus:LoadLanguage", function()
    local value = Nexus:GetSetting("nexus_language", Nexus:GetDefaultLanguage())
    if not Nexus:IsLanguageLoaded(value) then
        Nexus:LoadLanguage(value, function() end)
    end
end)