local color_zero = Color(0, 0, 0, 0)
local PANEL = {}
function PANEL:Init()
    self:SetColor(color_white)
    self:SetText("")

    self:SetColor(Nexus:GetColor("primary"))
    self:HideRainbow()

    self.HoverColor = color_zero
    self.HoverFrac = 0
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:GetColor(col)
    return self.col
end

function PANEL:HideRainbow()
    self.ShowHideRainbow = true
end

function PANEL:ShowRainbow()
    self.ShowHideRainbow = false
end

local blurCol = Color(0, 0, 0, 100)
function PANEL:DoClick()
    local blurMenu = vgui.Create("DPanel")
    blurMenu:SetSize(ScrW(), ScrH())
    blurMenu:MakePopup()
    blurMenu.Paint = function(s, w, h)
        Nexus.RNDX.Draw(0, 0, 0, w, h, color_white, Nexus.RNDX.BLUR)
        Nexus.RNDX.Draw(0, 0, 0, w, h, blurCol)
    end

    local frame = vgui.Create("Nexus:V2:Frame")
    frame:SetTitle("Colour")
    frame:SetSize(Nexus:GetScale(300), Nexus:GetScale(300))
    frame:Center()
    frame:MakePopup()
    frame.Think = function(s)
        if not IsValid(self) then
            s:Remove()
        end
        s:MoveToFront()
    end
    frame.OnRemove = function()
        blurMenu:Remove()
    end

    local mixer = frame:Add("Nexus:V2:ColorSelector")
    mixer:Dock(FILL)
    mixer:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), 0)
    mixer:HideAlpha()
    mixer:SetColor(self:GetColor())

    local isRainbow
    local accept = frame:Add("Nexus:V2:Button")
    accept:Dock(BOTTOM)
    accept:SetTall(Nexus:GetScale(35))
    accept:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin())
    accept:SetText("Confirm")
    accept:SetColor(Nexus:GetColor("green"))
    accept.DoClick = function()
        self:OnConfirm(isRainbow:GetState() and Color(-1, -1, -1) or mixer:GetColor())
        frame:Remove()
    end

    isRainbow = frame:Add("Nexus:V2:CheckBox")
    isRainbow:Dock(BOTTOM)
    isRainbow:DockMargin(Nexus:GetMargin(), Nexus:GetMargin(), Nexus:GetMargin(), 0)
    isRainbow:SetText("Rainbow")
    if self.ShowHideRainbow then
        isRainbow:Hide()
    end
end

function PANEL:OnConfirm(col)
    self.col = col
    self:OnChange(col)
end

function PANEL:OnChange(col)
end

function PANEL:Paint(w, h)
    local col = self.col
    if self.col.r == -1 then
        col = HSVToColor((CurTime() * 75) % 360, 1, 1)
    end

    Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, col, nil, true)

	if self:IsHovered() then
		self.HoverFrac = math.min(1, self.HoverFrac+FrameTime()*5)
	else
		self.HoverFrac = math.max(0, self.HoverFrac-FrameTime()*5)
	end
	self.HoverColor = color_zero:Lerp(Nexus:GetColor("overlay"), self.HoverFrac)
	Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, self.HoverColor)
end
vgui.Register("Nexus:V2:ColorPicker", PANEL, "DButton")