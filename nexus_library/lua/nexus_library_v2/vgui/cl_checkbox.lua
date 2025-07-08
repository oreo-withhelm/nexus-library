local RNDX = include("/external/cl_rndx.lua")

local PANEL = {}
AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)

function PANEL:Init()
    self.State = false
    self:SetTall(Nexus:GetScale(25))
    self:SetText("Nexus CheckBox V2")

    self.Container = self:Add("DButton")
    self.Container:Dock(LEFT)
    self.Container:SetWide(Nexus:GetScale(50))
    self.Container:SetText("")
    self.Container.CurValue = 0
    self.Container.Paint = function(s, w, h)
        local tall = h
        self.Container.CurValue = math.Approach(self.Container.CurValue, self:GetState() and w-tall or 0, FrameTime()*350)

        RNDX.Draw(tall/2, 1, (h/2) - (tall/2), w-2, tall, self:GetState() and Nexus:GetColor("green") or Nexus:GetColor("red"))
        RNDX.Draw(tall/2, self.Container.CurValue, (h/2) - (tall/2), tall, tall, Nexus:GetColor("header"))
    end
    self.Container.DoClick = function()
        self:SetState(!self:GetState())
    end
end

function PANEL:SetState(bool)
    self.State = bool
end

function PANEL:GetState()
    return self.State
end

function PANEL:Paint(w, h)
    draw.SimpleText(self:GetText(), Nexus:GetFont({size=h*.7, dontScale=true}), self.Container:GetWide() + Nexus:GetMargin(), h/2, Nexus:GetColor("primary-text"), 0, 1)
end

function PANEL:PerformLayout(w, h)
end
vgui.Register("Nexus:V2:CheckBox", PANEL, "EditablePanel")