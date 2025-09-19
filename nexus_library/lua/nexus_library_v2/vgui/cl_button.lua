local color_zero = Color(0, 0, 0, 0)
local PANEL = {}
function PANEL:Init()
    self:SetTall(Nexus:GetScale(35))

    self:SetText("")
    self:SetFont(Nexus:GetFont({size = 15}))
    self:SetColor(Nexus:GetColor("primary"))

    function self:SetText(str)
        self.Text = str
        self:CalcTextSize()
    end
    self:SetText("nil")

    local old = self.SetFont
    function self:SetFont(amt)
        old(self, amt)
        self:CalcTextSize()
    end

    function self:GetText()
        return self.Text
    end

    function self:SetTextColor(col)
        self.TextCol = col
    end

    self.backgroundCol = color_zero
    self.backgroundFrac = 0

    self.Corners = {true, true, true, true}
    self.imageColor = color_white
end

function PANEL:OnMouseReleased(mousecode)
	self:MouseCapture(false)

	if (!self:IsEnabled()) then return end
	if (!self.Depressed && dragndrop.m_DraggingMain != self) then return end

	if (self.Depressed) then
		self.Depressed = nil
		self:OnReleased()
		self:InvalidateLayout(true)
	end

	if (self:DragMouseRelease(mousecode)) then
		return
	end

	if (self:IsSelectable() && mousecode == MOUSE_LEFT) then
		local canvas = self:GetSelectionCanvas()
		if (canvas) then
			canvas:UnselectAll()
		end
	end

	if (!self.Hovered) then return end
	self.Depressed = true

	if (mousecode == MOUSE_RIGHT) then
		self:DoRightClick()
	end

	if (mousecode == MOUSE_LEFT) then
		self:DoClickInternal()
		self:DoClick()
        self.pulse_time = CurTime()

        self.origin, _ = self:LocalCursorPos()
    end

	if (mousecode == MOUSE_MIDDLE) then
		self:DoMiddleClick()
	end

	self.Depressed = nil
end

function PANEL:CalcTextSize()
    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText())
    self.TextSize = {tw = tw, th = th}
end

function PANEL:SetIcon(str, func, color)
    self.icon = str
    self.iconH = func or function(h) return h*.55 end
    self.imageColor = color
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:SetSecondary()
    self.col = Nexus:GetColor("secondary-2")
end

function PANEL:AutoWide(extras)
    extras = extras or 0

    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText())
    self:SetWide(tw + Nexus:GetMargin()*2 + extras)
end

function PANEL:HideText()
    self.ShouldHideText = true
end

function PANEL:SetCorners(tl, tr, bl, br)
    self.Corners = {tl, tr, bl, br}
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(Nexus:GetMargin(), 0, 0, w, h, self.col, self.Corners[1], self.Corners[2], self.Corners[3], self.Corners[4])

    local textCol = self.TextCol or Nexus:GetTextColor(self.col)

    local tw, _ = self.ShouldHideText and 0 or draw.SimpleText(self.Text, self:GetFont(), 0, 0, color_zero)
    local totalWide = tw + (self.icon and self.iconH(h) + (self.ShouldHideText and 0 or Nexus:GetMargin("small")) or 0)

    local x = (w/2) - (totalWide/2)
    if self.icon then
        local size = self.iconH(h)
        local y = (h/2) - (size/2)
        Nexus:DrawImgur(self.icon, x, y, size, size, self.imageColor)
        x = x + (self.ShouldHideText and 0 or Nexus:GetMargin("small")) + size
    end

    draw.SimpleText(self.ShouldHideText and "" or self.Text, self:GetFont(), x, h - (h/2), textCol, 0, 1)

    if self:IsHovered() then
		self.backgroundFrac = math.min(1, self.backgroundFrac+FrameTime()*5)
	else
		self.backgroundFrac = math.max(0, self.backgroundFrac-FrameTime()*5)
	end
	self.backgroundCol = color_zero:Lerp(Nexus:GetColor("overlay"), self.backgroundFrac)
	draw.RoundedBoxEx(Nexus:GetMargin(), 0, 0, w, h, self.backgroundCol, self.Corners[1], self.Corners[2], self.Corners[3], self.Corners[4])

    if self.pulse_time then
        local t = CurTime() - self.pulse_time
        local duration = 0.2
        local eased_t = math.pow( t / duration, 2 )

        local max_dist = math.max( self.origin, w - self.origin ) * 2
        local size = max_dist * eased_t

        if size < max_dist and t < duration then
            Nexus.RNDX.Draw(Nexus:GetMargin(), self.origin - size / 2, 0, size, h, Nexus:GetColor("highlight"))
        else
            self.pulse_time = nil
        end
    end
end
vgui.Register("Nexus:V2:Button", PANEL, "DButton")