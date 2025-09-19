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
        Nexus.RDNX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("highlight"))
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

    local button = self.Scroll:Add("DButton")
    button:SetTall(Nexus:GetScale(40))
    button:SetText("")
    button.Paint = function(s, w, h)
        if self.active == id then
            bgFrac = math.min(1, bgFrac+FrameTime()*5)
            textFrac = math.min(1, textFrac+FrameTime()*5)
        else
            bgFrac = math.max(0, bgFrac-FrameTime()*5)
        end
        hoverColor = color_zero:Lerp(Nexus:GetColor("green"), bgFrac)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, hoverColor)

        if s:IsHovered() then
            overlayFrac = math.min(1, overlayFrac+FrameTime()*5)
            textFrac = math.min(1, textFrac+FrameTime()*5)
        else
            overlayFrac = math.max(0, overlayFrac-FrameTime()*5)
        end
        bgColor = color_zero:Lerp(Nexus:GetColor("overlay"), overlayFrac)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, bgColor)

        if not (s:IsHovered() or self.active == id) then
            textFrac = math.max(0, textFrac-FrameTime()*5)
        end

        local wantedColor = self.active == id and Nexus:GetTextColor(Nexus:GetColor("green"))
            or s:IsHovered() and Nexus:GetColor("primary-text")
            or Nexus:GetColor("secondary-text")

        local lerpedTextColor = textColor:Lerp(wantedColor, textFrac)

        local x = Nexus:GetMargin("large")
        local size = (h - Nexus:GetMargin("small")*2)*.75
        if icon then
            Nexus:DrawImgur(icon, x, (h/2) - (size/2), size, size, lerpedTextColor)
            x = x + size + Nexus:GetMargin("small")
        end

        draw.SimpleText(text, Nexus:GetFont({size = h*.45, dontScale = true}), x, h/2, lerpedTextColor, 0, 1)
    end

    button.func = func
    button.data = data
    button.DoClick = function(s)
        self:SelectItem(id)
    end

    self.buttons[id] = button

    if self.active == id then
        self:SelectItem(id)
    end
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
                self:OnChange(self.CurPanel, button.func, button.data)
            end
            return
        end
    end
end

function PANEL:OnChange(panel)
end
// legacy
function PANEL:SetMask(corners) end
function PANEL:LoadLegacy()
    // no idea what this did
    self.bumper = self:Add("DPanel")
    self.bumper.Paint = nil
end

vgui.Register("Nexus:V2:Sidebar", PANEL, "EditablePanel")