local PANEL = {}
function PANEL:Init()
	self.margin = Nexus:GetScale(10)

    self:SetText("")
    self:SetFont(Nexus:GetFont({size = 18}))
    self.col = Nexus:GetColor("primary")

    function self:SetText(str)
        self.Text = str
    end

    function self:GetText()
        return self.Text
    end

    function self:SetTextColor(col)
        self.TextCol = col
    end
end

function PANEL:SetIcon(str)
    self.icon = str
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:SetSecondary()
    self.col = Nexus:GetColor("secondary")
end

function PANEL:AutoWide(extras)
    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText())
    self:SetWide(tw + self.margin*2 + extras)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, self.col)

    local textCol = self.TextCol or Nexus:GetTextColor(self.col)
    draw.SimpleText(self.Text, self:GetFont(), w/2, h - (h/2), textCol, 1, 1)

    if self.icon then
        local size = h * 0.5
        local x, y = (w/2) - (size/2)
        Nexus:DrawImgur(self.icon, x, x, size, size, color_white)
    end

    if self:IsHovered() or self.Clicked then
        draw.RoundedBox(self.margin, 0, h - h, w, h, Nexus:GetColor("overlay"))
    end
end
vgui.Register("Nexus:V2:Button", PANEL, "DButton")