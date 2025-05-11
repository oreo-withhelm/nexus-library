local PANEL = {}
function PANEL:Init()
    self:SetColor(color_white)
    self:SetText("")
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:DoClick()
    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetTitle("Colour")
    frame:SetSize(Nexus:GetScale(300), Nexus:GetScale(250))
    frame:Center()
    frame:MakePopup()
    frame.Think = function(s)
        if not IsValid(self) then
            s:Remove()
        end
    end

    local mixer = frame:Add("DColorMixer")
    mixer:Dock(FILL)
    mixer:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), 0)
    mixer:SetPalette(false)
    mixer:SetWangs(false)
    mixer:SetAlphaBar(false)

    local isRainbow
    local accept = frame:Add("Nexus:V2:Button")
    accept:Dock(BOTTOM)
    accept:SetTall(Nexus:GetScale(35))
    accept:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin())
    accept:SetText("Confirm")
    accept.DoClick = function()
        self:OnConfirm(isRainbow:GetState() and Color(-1, -1, -1) or mixer:GetColor())
    end

    isRainbow = frame:Add("Nexus:CheckBox")
    isRainbow:Dock(BOTTOM)
    isRainbow:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), 0)
    isRainbow:SetText("Rainbow")
end

function PANEL:OnConfirm(col)
end

function PANEL:Paint(w, h)
    local col = self.col
    if self.col.r == -1 then
        col = HSVToColor((CurTime() * 75) % 360, 1, 1)
    end

    draw.RoundedBox(Nexus:GetMargin(), 0, 0, w, h, col)

    if self:IsHovered() then
        draw.RoundedBox(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
    end
end
vgui.Register("Nexus:V2:ColorPicker", PANEL, "DButton")