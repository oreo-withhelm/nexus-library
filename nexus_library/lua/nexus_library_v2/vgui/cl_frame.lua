local PANEL = {}
function PANEL:Init()
    local accentalpha = Color(Nexus:GetColor("accent").r, Nexus:GetColor("accent").b, Nexus:GetColor("accent").b, 210)
    self.Header = self:Add("Panel")
    self.Header:Dock(TOP)
    self.Header:SetTall(Nexus:GetScale(50))
    self.Header.Paint = function(s, w, h)
        draw.RoundedBoxEx(Nexus:GetMargin("large"), 0, 0, w, h, Nexus:GetColor("header"), true, true, false, false)

        Nexus.Masks.Start()
            local tall = h - Nexus:GetMargin("normal")*2
            local size = Nexus:GetScale(120)
            Nexus:DrawImgur("https://imgur.com/ONG3mbJ", -size/2, -size/2, size, size, Nexus:GetColor("accent"))
            Nexus:DrawImgur("https://imgur.com/ONG3mbJ", w + -size/2 - Nexus:GetMargin("normal") - tall/2, h/2 + -size/2, size, size, accentalpha)
            Nexus.Masks.Source()
            draw.RoundedBoxEx(Nexus:GetMargin("large"), 0, 0, w, h, color_white, true, true)
        Nexus.Masks.End()

        self.BarButton:SetWide(h*3)
    end
    self.Header.PerformLayout = function(s, w, h)
        local tall = h - Nexus:GetMargin("normal")*2
        s.QuickButtons:SetWide(Nexus:GetMargin("normal")*2 + (#s.QuickButtons.Buttons * tall) + ((#s.QuickButtons.Buttons-1) * Nexus:GetMargin("normal")))
        self.CloseButton:SetWide(tall)
    end

    self.Header.TitleBox = self.Header:Add("Panel")
    self.Header.TitleBox:Dock(LEFT)
    self.Header.TitleBox:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"))

    self.logo = "https://imgur.com/7BkhMeY"
    self.Header.TitleBox.Logo = self.Header.TitleBox:Add("Panel")
    self.Header.TitleBox.Logo:Dock(LEFT)
    self.Header.TitleBox.Logo:SetWide(Nexus:GetScale(30))
    self.Header.TitleBox.Logo.PaintOver = function(s, w, h)
        Nexus:DrawImgur(self.logo, 0, 0, w, h)
    end

    self.Header.TitleBox.TitleArea = self.Header.TitleBox:Add("Panel")
    self.Header.TitleBox.TitleArea:Dock(FILL)
    self.Header.TitleBox.TitleArea.PerformLayout = function(s, w, h)
        local totalH = s.ServerName:GetTall() + s.Title:GetTall()
        s.ServerName:SetWide(w)
        s.Title:SetWide(w)

        local y = (h/2) - (totalH/2)
        s.ServerName:SetY(y)
        s.Title:SetY(y + s.ServerName:GetTall())
    end

    self.Header.TitleBox.TitleArea.ServerName = self.Header.TitleBox.TitleArea:Add("DLabel")
    self.Header.TitleBox.TitleArea.ServerName:SetText(Nexus:GetPhrase("Server Name"))
    self.Header.TitleBox.TitleArea.ServerName:SetFont(Nexus:GetFont({size = 15, bold = true}))
    self.Header.TitleBox.TitleArea.ServerName:SizeToContents()
    self.Header.TitleBox.TitleArea.ServerName:SetTextColor(Nexus:GetColor("primary-text"))

    self.Header.TitleBox.TitleArea.Title = self.Header.TitleBox.TitleArea:Add("DLabel")
    self.Header.TitleBox.TitleArea.Title:SetText(Nexus:GetPhrase("Title"))
    self.Header.TitleBox.TitleArea.Title:SetFont(Nexus:GetFont({size = 12}))
    self.Header.TitleBox.TitleArea.Title:SizeToContents()
    self.Header.TitleBox.TitleArea.Title:SetTextColor(Nexus:GetColor("accent"))

    self.Header.TitleBox:SetWide(Nexus:GetScale(45) + self.Header.TitleBox.Logo:GetWide() + math.max(self.Header.TitleBox.TitleArea.ServerName:GetWide(), self.Header.TitleBox.TitleArea.Title:GetWide()))

    local col = Nexus:GetColor("secondary")
    self.Header.QuickButtons = self.Header:Add("DPanel")
    self.Header.QuickButtons:Dock(LEFT)
    self.Header.QuickButtons:DockPadding(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"))
    self.Header.QuickButtons.Paint = function(s, w, h)
        surface.SetDrawColor(col.r, col.g, col.b, col.a)
        surface.DrawRect(0, 0, w, h)
    end

    self.Header.QuickButtons.PerformLayout = function(s, w, h)
        for _, button in ipairs(s.Buttons) do
            button:SetWide(h - Nexus:GetMargin("normal")*2)
        end
    end

    self.Header.QuickButtons.Buttons = {}
    self.Header.QuickButtons.AddButton = function(s, icon, doClick)
        local button = s:Add("DButton")
        button:Dock(LEFT)
        button:DockMargin(0, 0, Nexus:GetMargin("normal"), 0)
        button:SetText("")
        button.Paint = function(s, w, h)
            draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("background"))

            local thickness = Nexus:GetScale(2)
            Nexus.Masks.Start()
                Nexus:DrawImgur(icon, thickness, thickness, w-thickness*2, h-thickness*2)
            Nexus.Masks.Source()
                draw.RoundedBox(Nexus:GetMargin("normal"), thickness, thickness, w-thickness*2, h-thickness*2, color_white)
            Nexus.Masks.End()

            if s:IsHovered() then
                draw.RoundedBox(Nexus:GetMargin("normal"), thickness, thickness, w-thickness*2, h-thickness*2, Nexus:GetColor("overlay"))
            end
        end
        button.DoClick = function()
            doClick()
        end

        table.insert(self.Header.QuickButtons.Buttons, button)
    end

    self:AddHeaderButton(Nexus:GetCurFlag(), function()
        Nexus:DermaMenu(self.languages, function(value)
            Nexus:SetSetting("nexus_language", value)
            self:OnRefresh()
        end)
    end)

    local overlay = Nexus:GetColor("overlay")
    self.BarButton = self.Header:Add("DButton")
    self.BarButton:Dock(LEFT)
    self.BarButton:SetText("")
    self.BarButton.Paint = function(s, w, h)
        if not s.Data then return end
        Nexus:DrawImgur(s.Data[1], 0, 0, w, h)

        local x = w*.1
        draw.SimpleTextOutlined(s.Data[2], Nexus:GetFont({size = 15, bold = true}), x, h/2, Nexus:GetColor("orange"), 0, TEXT_ALIGN_BOTTOM, 1, color_black)
        draw.SimpleTextOutlined(s.Data[3], Nexus:GetFont({size = 12}), x, h/2, Nexus:GetColor("primary-text"), 0, TEXT_ALIGN_TOP, 1, color_black)

        if s:IsHovered() then
            surface.SetDrawColor(overlay.r, overlay.g, overlay.b, overlay.a)
            surface.DrawRect(0, 0, w, h)
        end
    end
    self.BarButton.DoClick = function(s)
        if not s.Data then return end
        s.Data[4]()
    end

    self.BarButton:Hide()

    self.CloseButton = self.Header:Add("DButton")
    self.CloseButton:Dock(RIGHT)
    self.CloseButton:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), Nexus:GetMargin("normal"))
    self.CloseButton:SetText("")
    self.CloseButton.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("primary"))

        local size = h*.7
        Nexus:DrawImgur("https://imgur.com/HjXdSHZ", (w/2) - (size/2), (h/2) - (size/2), size, size, Nexus:GetColor("background"))

        if s:IsHovered() then
            draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("overlay"))
        end
    end
    self.CloseButton.DoClick = function()
        self:Remove()
    end

    self.Header.Content = self.Header:Add("DPanel")
    self.Header.Content:Dock(FILL)
    self.Header.Content:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0, Nexus:GetMargin("normal"))
    self.Header.Content.Paint = nil

    local col = Nexus:GetColor("secondary")
    self.LineBreak = self:Add("DPanel")
    self.LineBreak:Dock(TOP)
    self.LineBreak:SetTall(Nexus:GetScale(2))
    self.LineBreak.Paint = function(s, w, h)
        surface.SetDrawColor(col.r, col.g, col.b, col.a)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:SetBarIcon(icon, title, subheading, doClick)
    self.BarButton.Data = {icon, title, subheading, doClick}
    self.BarButton:Show()
end

function PANEL:SetLanguages(languages)
    self.languages = languages
end

function PANEL:AddHeaderButton(icon, doClick)
    self.Header.QuickButtons:AddButton(icon, doClick)
end

function PANEL:SetTitle(title)
    self.Header.TitleBox.TitleArea.Title:SetText(title)
    self.Header.TitleBox.TitleArea.Title:SizeToContents()
    self.Header.TitleBox:SetWide(Nexus:GetScale(45) + self.Header.TitleBox.Logo:GetWide() + math.max(self.Header.TitleBox.TitleArea.ServerName:GetWide(), self.Header.TitleBox.TitleArea.Title:GetWide()))
end

function PANEL:SetLogo(logo)
    self.logo = logo
end

function PANEL:SelectContent(str)
    if IsValid(self.Content) then self.Content:Remove() end
    self.Content = self:Add(str)
    self.Content:Dock(FILL)
    self.Content:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0, 0)
end

function PANEL:OnRefresh()
end

function PANEL:PerformLayout(w, h)
end

local color_zero = Color(0, 0, 0, 0)
function PANEL:Paint(w, h)
    self.overlay = self.overlay or table.Copy(Nexus:GetColor("secondary"))
    self.overlay.a = 100
    draw.RoundedBox(Nexus:GetMargin("large"), 0, 0, w, h, Nexus:GetColor("background"))
    Nexus:DrawRoundedGradient(0, 0, w, h, color_zero, self.overlay, Nexus:GetMargin("large"))
end
vgui.Register("Nexus:V2:Frame", PANEL, "EditablePanel")

function GenerateFrame()
    if IsValid(Nexus.Frame) then Nexus.Frame:Remove() end
    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetSize(Nexus:GetScale(1000), Nexus:GetScale(800))
    frame:Center()
    frame:MakePopup()
    frame:SetBarIcon("https://imgur.com/K7q22tm", Nexus:GetPhrase("Title"), Nexus:GetPhrase("Subheading"), function() end)
    frame:SetLanguages({"en", "fr", "a", "b", "c"})
    frame.OnRefresh = function(a)
        Nexus:GenerateFrame()
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