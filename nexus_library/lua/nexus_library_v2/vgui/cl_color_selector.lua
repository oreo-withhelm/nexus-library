local PANEL = {}
function PANEL:Init()
    self.Hue = 0
    self.MarkerX = 0
    self.Dragging = false
end

function PANEL:Paint(w, h)
    Nexus.MelonMasks.Start()
        for x = 0, w - 1 do
            surface.SetDrawColor(HSVToColor((x / w) * 360, 1, 1))
            surface.DrawRect(x, 0, 1, h)
        end
    Nexus.MelonMasks.Source()
        Nexus.RNDX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, color_white)
    Nexus.MelonMasks.End()

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(self.MarkerX - 1, 0, 2, h)    
end

function PANEL:SetHue(h)
    self.Hue = h
    self.MarkerX = (h / 360) * (self._wide or self:GetWide())
end

function PANEL:GetHue()
    return self.Hue
end

function PANEL:OnMousePressed()
    self.Dragging = true
    self:MouseCapture(true)
    self:UpdateFromMouse()
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self:MouseCapture(false)
end

function PANEL:Think()
    if self.Dragging then
        self:UpdateFromMouse()
    end
end

function PANEL:PerformLayout(w, h)
    self._wide = w
    self:SetHue(self.Hue)
end

function PANEL:UpdateFromMouse()
    local x, _ = self:CursorPos()
    x = math.Clamp(x, 0, self:GetWide())
    self.MarkerX = x
    self.Hue = (x / self:GetWide()) * 360

    if self.OnChange then
        self:OnChange(self.Hue)
    end
end
vgui.Register("Nexus:V2:HorizontalHuePicker", PANEL, "EditablePanel")

local PANEL = {}
function PANEL:Init()
    self.Alpha = 255
    self.MarkerX = 0
    self.FixedColor = Color(255, 255, 255)
    self.Dragging = false
end

function PANEL:SetFixedColor(c)
    self.FixedColor = Color(c.r, c.g, c.b)
end

function PANEL:SetAlpha(a)
    self.Alpha = a
    self.MarkerX = (a / 255) * (self._wide or self:GetWide())
end

function PANEL:GetAlpha()
    return self.Alpha
end

function PANEL:PerformLayout(w, h)
    self._wide = w
    self:SetAlpha(self.Alpha)
end

local one = Color(235, 235, 235, 255)
local two = Color(180, 180, 180, 255)
local non = Color(0, 0, 0, 0)
function PANEL:Paint(w, h)
    Nexus.MelonMasks.Start()
        local size = 8
        for ix = 0, math.ceil(w / size) - 1 do
            for iy = 0, math.ceil(h / size) - 1 do
                local col = ((ix + iy) % 2 == 0) and one or two
                surface.SetDrawColor(col)
                surface.DrawRect(ix * size, iy * size, size, size)
            end
        end

        for x = 0, w - 1 do
            surface.SetDrawColor(self.FixedColor.r, self.FixedColor.g, self.FixedColor.b, (x / w) * 255)
            surface.DrawRect(x, 0, 1, h)
        end
    Nexus.MelonMasks.Source()
        Nexus.RNDX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, color_white)
    Nexus.MelonMasks.End()

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(self.MarkerX - 1, 0, 2, h)
end

function PANEL:OnMousePressed()
    self.Dragging = true
    self:MouseCapture(true)
    self:UpdateFromMouse()
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self:MouseCapture(false)
end

function PANEL:Think()
    if self.Dragging then
        self:UpdateFromMouse()
    end
end

function PANEL:UpdateFromMouse()
    local x, _ = self:CursorPos()
    x = math.Clamp(x, 0, self:GetWide())
    self.MarkerX = x
    self.Alpha = (x / self:GetWide()) * 255
    if self.OnChange then
        self:OnChange(self.Alpha)
    end
end
vgui.Register("Nexus:V2:HorizontalAlphaBar", PANEL, "EditablePanel")

local PANEL = {}
function PANEL:Init()
    self.OurColor = self:Add("DPanel")
    self.OurColor:Dock(TOP)
    self.OurColor:DockMargin(0, 0, 0, Nexus:GetMargin("small"))
    self.OurColor:SetTall(Nexus:GetScale(10))
    self.OurColor.Paint = function(s, w, h)
        Nexus.RDNX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, self:GetColor())
    end

    self.ColorCube = vgui.Create("DColorCube", self)
    self.ColorCube:Dock(FILL)
    self.ColorCube:SetPos(0, 0)
    self.ColorCube.PaintOver = nil
    self.ColorCube.Knob.Paint = function(s, w, h)
        Nexus.RDNX.DrawOutlined(Nexus:GetMargin("small"), 0, 0, w, h, color_white, 2)
    end
    self.ColorCube.Paint = function(s, w, h)
        Nexus.RDNX.Draw(Nexus:GetMargin(), 0, 0, w, h, s.m_BaseRGB)
    end
    self.ColorCube.BGValue.PaintAt = function(s, x, y, dw, dh)
        dw, dh = dw or s:GetWide(), dh or s:GetTall()
        s:LoadMaterial()

        if not s.m_Material then return true end

        if s:GetKeepAspect() then
            local w = s.ActualWidth
            local h = s.ActualHeight

            if w > dw && h > dh then
                if w > dw then
                    local diff = dw / w
                    w = w * diff
                    h = h * diff
                end

                if h > dh then
                    local diff = dh / h
                    w = w * diff
                    h = h * diff
                end
            end

            if w < dw then
                local diff = dw / w
                w = w * diff
                h = h * diff
            end

            if h < dh then
                local diff = dh / h
                w = w * diff
                h = h * diff
            end

            local OffX = (dw - w) * 0.5
            local OffY = (dh - h) * 0.5

            Nexus.RDNX.DrawMaterial(Nexus:GetMargin(), OffX + x, OffY + y, w, h, s.m_Color, s.m_Material)
        end

        Nexus.RDNX.DrawMaterial(Nexus:GetMargin(), x, y, dw, dh, s.m_Color, s.m_Material)
    end
    self.ColorCube.BGSaturation.PaintAt = self.ColorCube.BGValue.PaintAt

    self.AlphaBar = vgui.Create("Nexus:V2:HorizontalAlphaBar", self)
    self.AlphaBar:Dock(BOTTOM)
    self.AlphaBar:SetTall(Nexus:GetScale(15))
    self.AlphaBar:DockMargin(0, Nexus:GetMargin("small"), 0, 0)

    self.HuePicker = vgui.Create("Nexus:V2:HorizontalHuePicker", self)
    self.HuePicker:Dock(BOTTOM)
    self.HuePicker:SetTall(Nexus:GetScale(15))
    self.HuePicker:DockMargin(0, Nexus:GetMargin("small"), 0, 0)

    self.CurrentColor = Nexus:GetColor("primary")

    local h, s, v = ColorToHSV(self.CurrentColor)
    self.HuePicker:SetHue(h)
    self.ColorCube:SetBaseRGB(HSVToColor(h, 1, 1))
    self.ColorCube:SetColor(self.CurrentColor)
    self.AlphaBar:SetFixedColor(self.CurrentColor)
    self.AlphaBar:SetAlpha(self.CurrentColor.a)

    self.HuePicker.OnChange = function(_, hue)
        local _, s, v = ColorToHSV(self.ColorCube:GetRGB())
        local col = HSVToColor(hue, s, v)
        self.ColorCube:SetBaseRGB(HSVToColor(hue, 1, 1))
        self.ColorCube:SetColor(col)
        self.AlphaBar:SetFixedColor(col)
        self.CurrentColor = col
        self.CurrentColor.a = self.AlphaBar:GetAlpha()
        if self.OnColorChanged then
            self:OnColorChanged(self.CurrentColor)
        end
    end
    self.ColorCube.OnUserChanged = function(_, col)
        self.AlphaBar:SetFixedColor(col)
        self.CurrentColor = col
        self.CurrentColor.a = self.AlphaBar:GetAlpha()
        if self.OnColorChanged then
            self:OnColorChanged(self.CurrentColor)
        end
    end

    self.AlphaBar.OnChange = function(_, a)
        self.CurrentColor.a = a
        if self.OnColorChanged then
            self:OnColorChanged(self.CurrentColor)
        end
    end

    self:SetColor(Color(57, 120, 255))
end

function PANEL:OnChange(col) end

function PANEL:OnColorChanged(col)
    if self.isSafe then return end

    self:OnChange(col)
end

function PANEL:SetColor(col)
    col = table.Copy(col)
    local h, s, v = ColorToHSV(col)
    self.CurrentColor = col

    self.HuePicker:SetHue(h)
    self.ColorCube:SetBaseRGB(HSVToColor(h, 1, 1))
    self.ColorCube:SetColor(col)
    self.AlphaBar:SetAlpha(col.a)
    self.AlphaBar:OnChange(h)
end

function PANEL:GetColor()
    return self.CurrentColor
end

function PANEL:HideAlpha()
    self.AlphaBar:Hide()
end
vgui.Register("Nexus:V2:ColorSelector", PANEL, "EditablePanel")