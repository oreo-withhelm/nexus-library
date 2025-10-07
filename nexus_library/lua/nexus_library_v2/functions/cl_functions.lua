local margins = {
    ["large"] = function() return Nexus:GetScale(16) end,
    ["normal"] = function() return Nexus:GetScale(8) end,
    ["small"] = function() return Nexus:GetScale(4) end,
}
function Nexus:GetMargin(str)
    if not str then str = "normal" end
    return math.Round(margins[str]())
end

local cachedScales = {}
function Nexus:GetScale(number)
    if cachedScales[number] then return cachedScales[number] end

    local scaledValue = math.max(number * (ScrH() / 1080), 1)
    local value = scaledValue % 2 == 0 and scaledValue or scaledValue + 1

    cachedScales[number] = value

    return math.Round(value)
end

hook.Add("OnScreenSizeChanged", "Nexus:ResetCache", function()
    cachedScales = {}
end)

local openDermaMenu

function Nexus:DermaMenu(tbl, onClicked, noSort, panel, alignLeft)
    if not tbl or not istable(tbl) then return end

    if !noSort then
        if istable(tbl[1]) then
            table.sort(tbl, function(a, b) return tostring(a.text) < tostring(b.text) end)
        else
            table.sort(tbl, function(a, b) return tostring(a) < tostring(b) end)
        end    
    end

    if IsValid(openDermaMenu) then
        openDermaMenu:Remove()
    end

    local scale = Nexus:GetScale(4)
    local margin = Nexus:GetMargin("normal")
    local animTime = 0.15

    local x, y = input.GetCursorPos()

    local pnlX, pnlY = 0, 0
    if panel then
        pnlX, pnlY = panel:LocalToScreen(0, 0)
    end
    
    openDermaMenu = vgui.Create("Panel")
    openDermaMenu:SetPos(panel and pnlX or x + scale, panel and pnlY + panel:GetTall() or y - Nexus:GetScale(15))
    openDermaMenu:MakePopup()
    openDermaMenu:DockPadding(margin, margin, margin, margin)
    openDermaMenu.Paint = function(s, w, h)
        draw.RoundedBoxEx(margin, 0, 0, w, h, Nexus:GetColor("secondary-2"), true, true, true, true)
    end

    openDermaMenu:SetAlpha(0)
    openDermaMenu:AlphaTo(255, animTime, 0)

    local scroll = openDermaMenu:Add("Nexus:V2:ScrollPanel")
    scroll:Dock(FILL)
    scroll.IsDermaMenu = true
    
    local vbar = scroll:GetVBar()
    vbar:SetWide(Nexus:GetScale(4))

    local totalHeight = margin
    local widest = 0
    local buttons = {}
    for k, v in ipairs(tbl) do
        local button = scroll:Add("DButton")
        button:Dock(TOP)
        button:DockMargin(0, 0, margin * 0.5, margin * 0.5)
        button:SetText(istable(v) and tostring(v.text) or tostring(v))
        button:SetFont(Nexus:GetFont({size = 15}))
        button:SetTextColor(Nexus:GetTextColor(Nexus:GetColor("secondary")))
        button:SizeToContents()
        if alignLeft then
            button:SetContentAlignment(4)
            button:SetTextInset(Nexus:GetMargin(), 0)
        end

        surface.SetFont(Nexus:GetFont({size = 15}))
        local btnW, btnH = surface.GetTextSize(istable(v) and tostring(v.text) or tostring(v))
        button:SetTall(btnH + margin)
        widest = math.max(widest, btnW + margin * 2)
        
        button.IsDermaMenu = true
        button:SetAlpha(0)
        button:AlphaTo(255, animTime, k * 0.02)

        button.Paint = function(s, w, h)
            if s:IsHovered() then
                Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
            end
        end
        
        button.DoClick = function(s)
            surface.PlaySound("ui/buttonclick.wav")
            openDermaMenu:AlphaTo(0, animTime, 0, function()
                if IsValid(openDermaMenu) then
                    openDermaMenu:Remove()
                end
            end)
            if onClicked then
                onClicked(v, k)
            end
        end

        buttons[k] = button

        if k <= 5 then
            totalHeight = totalHeight + button:GetTall() + margin * 0.5
        end
    end

    widest = math.min(widest + margin*2 + Nexus:GetScale(4), Nexus:GetScale(200))
    totalHeight = math.min(totalHeight + margin, ScrH() - y - scale * 2)
    
    openDermaMenu:SetSize(math.max(widest, panel and panel:GetWide() or 0), totalHeight)

    local posX, posY = openDermaMenu:GetPos()
    if posX + widest > ScrW() then
        openDermaMenu:SetPos(ScrW() - widest - scale, posY)
    end
    if posY + totalHeight > ScrH() then
        openDermaMenu:SetPos(posX, ScrH() - totalHeight - scale)
    end

    openDermaMenu.Think = function(s)
        openDermaMenu:MoveToFront()
        openDermaMenu:SetZPos(20)

        if not vgui.CursorVisible() or input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = input.GetCursorPos()
            local x, y, w, h = s:GetBounds()
            if mx < x or mx > x + w or my < y or my > y + h then
                s:AlphaTo(0, animTime, 0, function()
                    if IsValid(s) then
                        s:Remove()
                    end
                end)
            end
        end
    end

    return openDermaMenu
end

local black = Color(255, 255, 255, 30)
function Nexus:QueryPopup(str, onYes, onNo, yesText, noText)
    if isstring(str) and isstring(onYes) and isfunction(onNo) then
        Nexus:LegacyPopup(str, onYes, onNo)
        return
    end

    onNo = function() end
    yesText = yesText or Nexus:GetPhrase("Yes", "nexus_lib")
    noText = noText or Nexus:GetPhrase("No", "nexus_lib")

    if IsValid(Nexus.Popup) then Nexus.Popup:Remove() end
    local background = vgui.Create("DPanel")
    background:SetSize(ScrW(), ScrH())
    background:MakePopup()
    background.Paint = function(s, w, h)
        Nexus.RNDX.Draw(0, 0, 0, w, h, nil, Nexus.RNDX.BLUR)
        Nexus.RNDX.Draw(0, 0, 0, w, h, black)
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
    label:SetContentAlignment(5)
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
    sidebar:DockMargin(0, Nexus:GetMargin(), 0, 0)
    sidebar:SetMask({Nexus:GetMargin("large"), false, false, true, false})

    for i = 1, 25 do
        sidebar:AddItem(Nexus:GetPhrase("Server Name"), function()
        end, math.random(1, 2) == 2 and "https://imgur.com/2gTwRFi.png" or false)

        if i % 5 == 0 then
            sidebar:AddSpacer()
        end
    end

    local navbar = frame:Add("Nexus:V2:Navbar")
    navbar:Dock(TOP)
    navbar:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)

    for i = 1, 25 do
        navbar:AddItem(Nexus:GetPhrase("Server Name"), function() end, math.random(1, 2) == 2 and "https://imgur.com/2gTwRFi.png" or false)
    end

    local navbar = frame:Add("Nexus:V2:Navbar")
    navbar:Dock(TOP)
    navbar:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)

    for i = 1, 5 do
        navbar:AddItem(Nexus:GetPhrase("Server Name"), function() end, i < 2 and "https://imgur.com/2gTwRFi.png" or false)
    end

    local textEntry = frame:Add("Nexus:V2:TextEntry")
    textEntry:Dock(TOP)
    textEntry:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)
    textEntry:SetPlaceholder(Nexus:GetPhrase("Search"))

    local button = frame:Add("Nexus:V2:Button")
    button:Dock(TOP)
    button:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)
    button:SetText("Custom Button")

    local button = frame:Add("Nexus:V2:Button")
    button:Dock(TOP)
    button:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0)
    button:SetText("Custom Button")
    button:SetIcon("https://imgur.com/cj3KdnU")
    button:SetSecondary()

    local checkBox = frame:Add("Nexus:V2:CheckBox")
    checkBox:Dock(TOP)
    checkBox:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)

    local colorPicker = frame:Add("Nexus:V2:ColorPicker")
    colorPicker:Dock(TOP)
    colorPicker:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)

    local colorSelector = frame:Add("Nexus:V2:ColorSelector")
    colorSelector:Dock(TOP)
    colorSelector:SetTall(Nexus:GetScale(150))
    colorSelector:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)

    local ComboBox = frame:Add("Nexus:V2:ComboBox")
    ComboBox:Dock(TOP)
    ComboBox:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)
    ComboBox:AddChoice("awdawd", function() end)
    ComboBox:AddChoice("awdawd", function() end)
    ComboBox:AddChoice("awdawd", function() end)

    local date = frame:Add("Nexus:V2:Date")
    date:Dock(TOP)
    date:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)

    local numSlider = frame:Add("Nexus:V2:NumSlider")
    numSlider:Dock(TOP)
    numSlider:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)
    numSlider:SetValue(50)

    local Selector = frame:Add("Nexus:V2:Selector")
    Selector:Dock(TOP)
    Selector:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("large"), Nexus:GetMargin("normal"), 0)
    Selector:AddChoice("superadmin", function() end)
end

concommand.Add("nexus_examples", function()
    GenerateFrame()
end)

local loadingFrame = false
function Nexus:LoadLanguage(lang, callback)
    callback = callback or function() end

    if IsValid(loadingFrame) then
        notification.AddLegacy(Nexus:GetPhrase("Loading Language"), NOTIFY_ERROR, 3)
        return
    end

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
    timer.Simple(60, function()
        if IsValid(loadingFrame) then
            loadingFrame:Remove()
        end
        loadingFrame:Remove()
        callback(false)
    end)
end

//https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_util.lua
local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function Nexus:WrapText(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize(word)
            totalWidth = totalWidth + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= maxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                totalWidth = wordlen - spaceWidth
                return '\n' .. string.sub(word, 2)
            end

            totalWidth = wordlen
            return '\n' .. word
        end)

    return text
end
Nexus.textWrap = Nexus.WrapText // legacy support

net.Receive("Nexus:UpdateLanguage", function()
    local isUpdate = net.ReadBool()
    if IsValid(loadingFrame) and not isUpdate then
        loadingFrame.callback(false)
        loadingFrame:Remove()
    end

    if IsValid(loadingFrame) then
        loadingFrame.loaded = loadingFrame.loaded + 1
    end
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

    hook.Run("Nexus:LanguageChanged", lang)

    if IsValid(loadingFrame) then
        loadingFrame.callback(lang)
        loadingFrame:Remove()
    end
end)

hook.Add("InitPostEntity", "Nexus:LoadLanguage", function()
    local value = Nexus:GetSetting("nexus_language", Nexus:GetDefaultLanguage())
    if not Nexus:IsLanguageLoaded(value) then
        Nexus:LoadLanguage(value, function() end)
    end

    local isSuperadmin = false
    isSuperadmin = CAMI and CAMI.InheritanceRoot(LocalPlayer():GetUserGroup()) == "superadmin" or isSuperadmin
    isSuperadmin = not isSuperadmin and LocalPlayer() == "superadmin" or isSuperadmin
    if isSuperadmin and !Nexus:GetSetting("nexus-cu", false) then
        Nexus:Notification("Notification", "nexus_config [Nexus Core] has new config options (02/05/2025)")
        Nexus:SetSetting("nexus-cu", true)
    end
end)