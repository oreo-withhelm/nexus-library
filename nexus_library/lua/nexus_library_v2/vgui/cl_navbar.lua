local PANEL = {}
function PANEL:Init()
    self:SetTall(Nexus:GetScale(35))

    self.active = false
    self.buttons = {}

    self.Scroll = self:Add("Nexus:V2:HorizontalScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:GetCanvas():DockPadding(Nexus:GetMargin("large"), 0, 0, 0)

    local old = self.Scroll:GetCanvas().PerformLayout or function() end
    self.Scroll:GetCanvas().PerformLayout = function(s, w, h)
        old(s, w, h)

        if not self.UpdateButtons then return end
        self.UpdateButtons = false

        surface.SetFont(Nexus:GetFont({size = h*.5, dontScale = true}))
        for buttonID, button in pairs(self.buttons) do
            local tw, th = surface.GetTextSize(button.values.text)
            local wide = tw

            if button.values.icon then
                local size = h - Nexus:GetMargin("normal")*2
                wide = wide + size + Nexus:GetMargin("small")
            end
            button:SetWide(wide)
        end
    end
end

function PANEL:AddItem(text, func, icon, id)
    id = id or (#self.buttons + 1)

    self.UpdateButtons = true

    if self.buttons[id] then
        error("you have added a tab to the sidebar with an id that already exists")        
        return
    end

    self.active = self.active or id

    local button = self.Scroll:Add("DButton")
    button:Dock(LEFT)
    button:DockMargin(0, 0, Nexus:GetMargin("large"), Nexus:GetMargin("small"))
    button:SetTall(Nexus:GetScale(30))
    button:SetText("")
    button.Paint = function(s, w, h)
        local textColor = self.active == id and Nexus:GetColor("primary-text") or Nexus:GetColor("secondary-text")
        local size = h - Nexus:GetMargin("normal")*2
        if icon then
            Nexus:DrawImgur(icon, 0, Nexus:GetMargin("normal") + (size*.1), size, size, textColor)
        end

        draw.SimpleText(text, Nexus:GetFont({size = h*.5, dontScale = true}), icon and Nexus:GetMargin("small") + size, h/2, textColor, 0, 1)
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

function PANEL:SelectItem(id)
    for itemID, button in pairs(self.buttons) do
        if itemID == id then
            self.active = id
            button.func()
            return
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("secondary"))
end
vgui.Register("Nexus:V2:Navbar", PANEL, "EditablePanel")