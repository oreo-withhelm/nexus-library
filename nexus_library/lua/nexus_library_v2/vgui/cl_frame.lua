local color_zero = Color(0, 0, 0, 0)
local PANEL = {}
function PANEL:Init()
    self.Roundness = Nexus:GetMargin("large")

    self.Header = self:Add("DPanel")
    self.Header:Dock(TOP)
    self.Header:DockPadding(Nexus:GetMargin("large"), Nexus:GetMargin(), Nexus:GetMargin("large"), Nexus:GetMargin())
    self.Header:SetTall(Nexus:GetScale(50))
    self.Header.Paint = function(s, w, h)
        
    end
    self.Header.PerformLayout = function(s, w, h)
        local tall = h - Nexus:GetMargin()*2
        s.QuickButtons:SetWide(Nexus:GetMargin()*2 + (#s.QuickButtons.Buttons * tall) + ((#s.QuickButtons.Buttons-1) * Nexus:GetMargin()))
        self.CloseButton:SetWide(tall)

        local tall = tall*.5
        local wide = tall*3.18 + Nexus:GetMargin()*2
        self.Header.TitleBox:SetWide(wide)
    end

    self.Header.TitleBox = self.Header:Add("DPanel")
    self.Header.TitleBox:Dock(LEFT)
    self.Header.TitleBox.Paint = nil
    self.Header.TitleBox.PerformLayout = function(s, w, h)
        local tall = h
        self.Header.TitleBox.Logo:SetSize(w, tall)
        self.Header.TitleBox.Logo:SetPos(0, (h/2) - (tall/2))
    end

    self.logo = Nexus:GetValue("nexus-logo")
    self.Header.TitleBox.Logo = self.Header.TitleBox:Add("DButton")
    self.Header.TitleBox.Logo:SetText("")
    self.Header.TitleBox.Logo.Paint = function(s, w, h)
        s.Frac = s.Frac or 0
        s.CurrentColor = s.CurrentColor or color_white

        if s:IsHovered() then
            s.Frac = math.min(1, s.Frac+FrameTime()*5)
        else
            s.Frac = math.max(0, s.Frac-FrameTime()*5)
        end
        s.CurrentColor = color_zero:Lerp(Nexus:GetColor("highlight"), s.Frac)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, s.CurrentColor, nil, true)

        local tall = h - Nexus:GetMargin()*2
        local wide = w - Nexus:GetMargin()*2
        Nexus:DrawImgur(self.logo, Nexus:GetMargin(), Nexus:GetMargin(), wide, tall)
    end
    self.Header.TitleBox.Logo.DoClick = function(s)
        gui.OpenURL("https://www.gmodstore.com/teams/V06g5EAhRaGpHvVnXz5HvA/products")
    end

    local col = Nexus:GetColor("secondary")
    self.Header.QuickButtons = self.Header:Add("DPanel")
    self.Header.QuickButtons:Dock(LEFT)
    self.Header.QuickButtons:DockMargin(Nexus:GetMargin("large")*2, 0, 0, 0)
    self.Header.QuickButtons.Paint = nil
    self.Header.QuickButtons.PerformLayout = function(s, w, h)
        for _, button in ipairs(s.Buttons) do
            if not IsValid(button) then continue end
            button:SetWide(h)
        end
    end

    local hoverColor = color_zero

    self.Header.QuickButtons.Buttons = {}
    self.Header.QuickButtons.AddButton = function(s, icon, doClick)
        local frac = 0
        local button = s:Add("DButton")
        button:Dock(LEFT)
        button:DockMargin(0, 0, Nexus:GetMargin(), 0)
        button:SetText("")
        button.Paint = function(s, w, h)
            Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("highlight"), nil, true)

            if s:IsHovered() then
                frac = math.min(1, frac+FrameTime()*5)
            else
                frac = math.max(0, frac-FrameTime()*5)
            end
            hoverColor = color_zero:Lerp(Nexus:GetColor("overlay"), frac)

            local size = h*.8
            Nexus:DrawImgur(icon, (w/2) - (size/2), (h/2)-(size/2), size, size)

            Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, hoverColor)
        end
        button.DoClick = function()
            doClick()
        end

        table.insert(self.Header.QuickButtons.Buttons, button)

        return button
    end

    self:AddHeaderButton("https://imgur.com/e6jSBqi", function()
        Nexus:DermaMenu(Nexus:GetLanguages(), function(value)
            if not Nexus:IsLanguageLoaded(value) then
                Nexus:QueryPopup(string.format(Nexus:GetInstalledText(value, "download"), value), function()
                    Nexus:LoadLanguage(value, function(success)
                        if IsValid(self) and success then
                            Nexus:SetSetting("nexus_language", value)
                            if IsValid(self) then
                                self:OnRefresh()
                            end
                        end
                    end)
                end, nil, Nexus:GetInstalledText(value, "yes"), Nexus:GetInstalledText(value, "no"))

                return
            end

            Nexus:SetSetting("nexus_language", value)
            if IsValid(self) then
                self:OnRefresh()
            end
        end)
    end)

    self:AddHeaderButton("eyedropper.png", function()
        local cols = {}
        for themeID, _ in pairs(Nexus:GetThemes()) do
            table.insert(cols, themeID)
        end
        Nexus:DermaMenu(cols, function(value)
            Nexus:SetSetting("nexus_theme", value)
            if IsValid(self) then
                self:OnRefresh()
            end
        end)
    end)

    local buttonColor = Nexus:GetColor("highlight")
    local textColor = color_black
    local frac = 0
    self.CloseButton = self.Header:Add("DButton")
    self.CloseButton:Dock(RIGHT)
    self.CloseButton:SetText("")
    self.CloseButton.Paint = function(s, w, h)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, buttonColor, nil, true)

        local size = h*.4
        Nexus:DrawImgur("https://imgur.com/q9PwEiy", (w/2) - (size/2), (h/2) - (size/2), size, size, textColor)

        if s:IsHovered() then
            frac = math.min(1, frac+FrameTime()*5)
        else
            frac = math.max(0, frac-FrameTime()*5)
        end

        buttonColor = Nexus:GetColor("highlight"):Lerp(Nexus:GetColor("primary"), frac)
        textColor = Nexus:GetTextColor(s:IsHovered() and Nexus:GetColor("primary") or Nexus:GetColor("background")):Lerp(Nexus:GetColor("background"), frac)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
    end
    self.CloseButton.DoClick = function()
        self:Remove()
    end

    self.Header.DragBar = self.Header:Add("DButton")
    self.Header.DragBar:Dock(FILL)
    self.Header.DragBar:SetText("")
    self.Header.DragBar.Paint = nil
    self.Header.DragBar:SetCursor("sizeall")
    self.Header.DragBar.OnMousePressed = function(s, code)
        if code == MOUSE_LEFT then
            self.Dragging = true
            local x, y = gui.MousePos()
            self.DragX = x - self:GetX()
            self.DragY = y - self:GetY()
        end
    end
    self.Header.DragBar.OnMouseReleased = function(s, code)
        if code == MOUSE_LEFT then
            self.Dragging = false
        end
    end
    local old = self.Header.DragBar.Think
    self.Header.DragBar.Think = function(s)
        old(s)
        if self.Dragging then
            local x, y = gui.MousePos()
            self:SetPos(x - self.DragX, y - self.DragY)
        end
    end

    local col = Nexus:GetColor("overlay")
    self.LineBreak = self:Add("DPanel")
    self.LineBreak:Dock(TOP)
    self.LineBreak:SetTall(Nexus:GetScale(2))
    self.LineBreak.Paint = function(s, w, h)
        surface.SetDrawColor(col.r, col.g, col.b, col.a)
        surface.DrawRect(0, 0, w, h)
    end

    self:LoadLegacy()
end

function PANEL:OnRefresh() end

function PANEL:HideHeaderButton()
    self.Header.QuickButtons:Hide()
end

function PANEL:AddHeaderButton(icon, doClick)
    return self.Header.QuickButtons:AddButton(icon, doClick)
end

function PANEL:SetLogo(logo)
    self.logo = logo
end

function PANEL:SetDraggable(bDraggable)
    self.Header.DragBar:SetVisible(bDraggable)
end

function PANEL:SelectContent(str)
    if IsValid(self.Content) then self.Content:Remove() end
    self.Content = self:Add(str)
    self.Content:Dock(FILL)
    self.Content:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), 0, 0)
end

function PANEL:Paint(w, h)
    Nexus.RDNX.Draw(self.Roundness, 0, 0, w, h, Nexus:GetColor("background"), nil, true)
end

// legacy support
function PANEL:SetBarIcon(icon, title, subheading, doClick) end
function PANEL:SetTitle(title) end
function PANEL:PerformLayout(w, h) end

function PANEL:LoadLegacy()
    self.BarButton = self.Header:Add("DButton")
    self.BarButton:Hide()

    self.Header.Content = self.Header:Add("DPanel")
    self.Header.Content:Dock(FILL)
    self.Header.Content:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), 0, Nexus:GetMargin())
    self.Header.Content.Paint = nil
    self.Header.Content:Hide()

    self.Header.TitleBox.TitleArea = self.Header.TitleBox:Add("Panel")
    self.Header.TitleBox.TitleArea:Hide()

    self.Header.TitleBox.TitleArea.ServerName = self.Header.TitleBox.TitleArea:Add("DLabel")
    self.Header.TitleBox.TitleArea.ServerName:Hide()

    self.Header.TitleBox.TitleArea.Title = self.Header.TitleBox.TitleArea:Add("DLabel")
    self.Header.TitleBox.TitleArea.Title:Hide()
end
vgui.Register("Nexus:V2:Frame", PANEL, "EditablePanel")