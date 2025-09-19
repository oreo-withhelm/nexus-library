local color_zero = Color(0, 0, 0, 0)
local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()
    self.State = false
    self:SetFont(Nexus:GetFont({size = 15}))
    self:SetTall(Nexus:GetScale(25))
    self:SetText("Nexus CheckBox V2")

    self.HoverFrac = 0
    self.HoverColor = color_zero
    
    self.Container = self:Add("DButton")
    self.Container:Dock(LEFT)
    self.Container:SetWide(Nexus:GetScale(50))
    self.Container:SetText("")
    self.Container.CurValue = 0
    self.Container.Paint = function(s, w, h)
        local tall = h
        self.Container.CurValue = math.Approach(self.Container.CurValue, self:GetState() and w-tall or 0, FrameTime()*350)

        Nexus.RNDX.Draw(tall/2, 1, (h/2) - (tall/2), w-2, tall, self:GetState() and Nexus:GetColor("green") or Nexus:GetColor("red"))

        Nexus.RNDX.Draw(tall/2, self.Container.CurValue, (h/2) - (tall/2), tall, tall, Nexus:GetColor("secondary-2"))

        if s:IsHovered() then
            self.HoverFrac = math.min(1, self.HoverFrac+FrameTime()*5)
        else
            self.HoverFrac = math.max(0, self.HoverFrac-FrameTime()*5)
        end
        self.HoverColor = color_zero:Lerp(Nexus:GetColor("overlay"), self.HoverFrac)
        Nexus.RNDX.Draw(tall/2, self.Container.CurValue, (h/2) - (tall/2), tall, tall, self.HoverColor)
    end
    self.Container.DoClick = function()
        self:SetState(!self:GetState())
    end
end

function PANEL:SetState(bool)
    self.State = bool
    self:OnChange(bool)
    self:OnStateChanged(bool)
end

function PANEL:OnStateChanged()
end

function PANEL:GetState()
    return self.State
end

function PANEL:SetFont(font)
    self.font = font
end

function PANEL:GetFont()
    return self.font
end

function PANEL:Paint(w, h)
    draw.SimpleText(self:GetText(), self:GetFont(), self.Container:GetWide() + Nexus:GetMargin(), h/2, Nexus:GetColor("primary-text"), 0, 1)
end

function PANEL:OnChange(state)
end

function PANEL:PerformLayout(w, h)
end
vgui.Register("Nexus:V2:CheckBox", PANEL, "EditablePanel")