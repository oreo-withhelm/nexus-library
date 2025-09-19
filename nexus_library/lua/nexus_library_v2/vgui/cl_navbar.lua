local color_zero = Color(0, 0, 0, 0)

local PANEL = {}
function PANEL:Init()
    self:SetTall(Nexus:GetScale(35))

    self.active = false
    self.buttons = {}

    self.Scroll = self:Add("Nexus:V2:HorizontalScrollPanel")
    self.Scroll:Dock(FILL)

    local old = self.Scroll:GetCanvas().PerformLayout or function() end
    self.Scroll:GetCanvas().PerformLayout = function(s, w, h)
        old(s, w, h)

        local buttonHeight = self.Scroll:GetVBar():GetTall() > 0 and (h - Nexus:GetMargin()) or h
        surface.SetFont(Nexus:GetFont({size = math.Round(buttonHeight*.5), dontScale = true}))
        local size = (h - Nexus:GetMargin("small")*2)*.75

        local x, y = 0, 0
        for buttonID, button in pairs(self.buttons) do
            local tw, th = surface.GetTextSize(button.values.text)
            if button.values.icon then
                tw = tw + size + Nexus:GetMargin("small")
            end

            button:SetPos(x, y)
            button:SetSize(tw + Nexus:GetMargin()*2, buttonHeight)
            x = x + button:GetWide() + Nexus:GetMargin()
        end
    end
end

function PANEL:AddItem(text, func, icon, id)
    id = id or (#self.buttons + 1)

    if self.buttons[id] then
        error("you have added a tab to the sidebar with an id that already exists")        
        return
    end

    self.active = self.active or id

    local hoverColor = color_zero
    local bgColor = color_zero
    local textColor = Nexus:GetColor("secondary-text")

    local bgFrac = 0
    local overlayFrac = 0
    local textFrac = 0

    local button = self.Scroll:Add("DButton")
    button:SetTall(Nexus:GetScale(30))
    button:SetText("")

    local textWidth = -1
    button.Paint = function(s, w, h)
        if self.active == id then
            bgFrac = math.min(1, bgFrac+FrameTime()*5)
            textFrac = math.min(1, textFrac+FrameTime()*5)
        else
            bgFrac = math.max(0, bgFrac-FrameTime()*5)
        end
        hoverColor = color_zero:Lerp(Nexus:GetColor("green"), bgFrac)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, h - Nexus:GetScale(2), w, 2, hoverColor)

        if s:IsHovered() then
            overlayFrac = math.min(1, overlayFrac+FrameTime()*5)
            textFrac = math.min(1, textFrac+FrameTime()*5)
        else
            overlayFrac = math.max(0, overlayFrac-FrameTime()*5)
        end
        bgColor = color_zero:Lerp(Nexus:GetColor("overlay"), overlayFrac)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, h - Nexus:GetScale(2), w, 2, bgColor)

        if not (s:IsHovered() or self.active == id) then
            textFrac = math.max(0, textFrac-FrameTime()*5)
        end

        local wantedColor = self.active == id and Nexus:GetColor("primary-text")
            or s:IsHovered() and Nexus:GetColor("primary-text")
            or Nexus:GetColor("secondary-text")

        local lerpedTextColor = textColor:Lerp(wantedColor, textFrac)

        if textWidth == -1 then
            surface.SetFont(Nexus:GetFont({size = math.Round(h*.5), dontScale = true}))
            textWidth, _ = surface.GetTextSize(text)            
        end

        local size = (h - Nexus:GetMargin("small")*2)*.75
        local x = (w/2) - (textWidth + (icon and size + Nexus:GetMargin("small") or 0))/2
        if icon then
            Nexus:DrawImgur(icon, x, (h/2) - (size/2), size, size, lerpedTextColor)
            x = x + size + Nexus:GetMargin("small")
        end

        draw.SimpleText(text, Nexus:GetFont({size = math.Round(h*.5), dontScale = true}), x, (h/2), lerpedTextColor, 0, 1)
    end
    button.OnSizeChanged = function(s)
        textWidth = -1
    end

    button.values = {text = text, icon = icon}
    button.func = func
    button.DoClick = function(s)
        self:SelectItem(id)
    end

    self.buttons[id] = button

    if self.active == id then
        self:SelectItem(id)
    end
end

function PANEL:GetActiveText()
    return self.buttons[self.active].values.text
end

function PANEL:SetBody(bod)
    self.OurBody = bod
end

function PANEL:SelectItem(id)
    for itemID, button in pairs(self.buttons) do
        if itemID == id then
            self.active = id
            if isfunction(button.func) then
                button.func()
            else
                local old = self.CurPanel
                if IsValid(old) then
                    self.CurPanel:AlphaTo(0, .2, 0, function()
                        if IsValid(old) then old:Remove() end
                    end)
                end
                self.CurPanel = self.OurBody:Add(button.func)
                self.CurPanel:Dock(FILL)
                self.CurPanel:SetAlpha(0)
                self.CurPanel:AlphaTo(255, .2, 0, function()
                    if IsValid(old) then old:Remove() end
                end)
                self:OnChange(self.CurPanel, button.func)
            end
            return
        end
    end
end

function PANEL:OnChange(panel, panelStr)
    
end


function PANEL:Paint(w, h)
//    Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
end
vgui.Register("Nexus:V2:Navbar", PANEL, "EditablePanel")