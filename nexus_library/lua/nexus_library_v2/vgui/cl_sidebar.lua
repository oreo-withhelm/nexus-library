local color_zero = Color(0, 0, 0, 0)

local PANEL = {}
function PANEL:Init()
    self:SetWide(Nexus:GetScale(200))

    self.active = false
    self.buttons = {}

    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(Nexus:GetMargin("normal"), 0, 0, 0)
    local old = self.Scroll:GetCanvas().PerformLayout
    self.Scroll:GetCanvas().PerformLayout = function(s, w, h)
        old(s, w, h)

        local x, y = 0, 0
        for _, v in ipairs(s:GetChildren()) do
            if v.isSpacer then
                y = y - Nexus:GetMargin("small") + Nexus:GetMargin()
            end
            v:SetPos(x, y)
            v:SetWide(self.Scroll:GetVBar():IsVisible() and w - Nexus:GetMargin() or w)
            y = y + v:GetTall() + (v.isSpacer and Nexus:GetMargin() or Nexus:GetMargin("small"))
        end
    end

    self:LoadLegacy()
end

function PANEL:AddSpacer()
    self.spacer = self.Scroll:Add("DPanel")
    self.spacer:SetTall(Nexus:GetScale(2))
    self.spacer.isSpacer = true
    self.spacer.Paint = function(s, w, h)
        Nexus.RDNX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("highlight"), nil, true)
    end
end

function PANEL:AddItem(text, func, icon, id, data)
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

    local button = self.Scroll:Add("Nexus:V2:Button")
    button:SetTall(Nexus:GetScale(40))
    button:SetText(text)
    button:SetContentAlignment(4)
    button:SetFont(Nexus:GetFont({size = 18}))
    button:SetIcon(icon)
    button.func = func
    button.data = data
    button.DoClick = function(s)
        self:SelectItem(id)
    end

    self.buttons[id] = button

    button:SetColor(color_zero)
    button:SetTextColor(Nexus:GetColor("secondary-text"))
    button.imageColor = Nexus:GetColor("secondary-text")

    if self.active == id then
        self:SelectItem(id)
    end

    return button
end

function PANEL:SetBody(bod)
    self.OurBody = bod
end

function PANEL:SelectItem(id)
    for _, button in pairs(self.buttons) do
        button:SetColor(color_zero)
        button:SetTextColor(Nexus:GetColor("secondary-text"))
        button.imageColor = Nexus:GetColor("secondary-text")
    end

    for itemID, button in pairs(self.buttons) do
        if itemID == id then
            self.active = id

            button:SetColor(Nexus:GetColor("green"))
            button:SetTextColor(Nexus:GetTextColor(Nexus:GetColor("green")))
            button.imageColor = color_white

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
                self:OnChange(self.CurPanel, button.func, button.data)
            end
            return
        end
    end
end

function PANEL:OnChange(panel, func, data)
end
// legacy
function PANEL:SetMask(corners) end
function PANEL:LoadLegacy()
    // no idea what this did
    self.bumper = self:Add("DPanel")
    self.bumper.Paint = nil
end

vgui.Register("Nexus:V2:Sidebar", PANEL, "EditablePanel")