local black = Color(0, 0, 0, 100)
local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)

    self.max = 100
    self.number = 0

    self.TextBox = self:Add("Nexus:TextEntry")
    self.TextBox:Dock(RIGHT)
    self.TextBox:SetText(self.number)
    self.TextBox:SetNumeric(true)
    self.TextBox.OnChange = function(s)
        local value = s:GetText() == "" and 0 or s:GetText()
        value = tonumber(value) or 0
        value = math.min(self.max, value)
        self.SettingValue = value
        self.number = value
        self:OnChange(self.number)
    end
    self.TextBox.OnValueChange = self.TextBox.OnChange

    self.Slider = self:Add("DPanel")
    self.Slider:Dock(FILL)
    self.Slider.Paint = function(s, w, h)
        Nexus:DrawRoundedGradient(0, h*.1, w, h*.8, Nexus:GetColor("secondary"), black)
        Nexus:DrawRoundedGradient(0, h*.1, self.Slider.Button:GetX() + self.Slider.Button:GetWide()/2, h*.8+1, Nexus:OffsetColor(Nexus:GetColor("primary"), -50), black)
        s.Wide = w
    end
    self.Slider.PerformLayout = function(s, w, h)
        self.Slider.Button:SetSize(Nexus:Scale(50), h)
    end

    self.Slider.Button = self.Slider:Add("DButton")
    self.Slider.Button:SetText("")
    self.Slider.Button.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, Nexus:Scale(50), h, Nexus:GetColor("primary"))

        local size = h*.5
        Nexus:DrawImgur("VcYwaxt", w/2, h/2, size, size, color_black, 90)

        if self.SettingValue then
            self.SettingValue = false

            s:SetX((self.Slider.Wide - w) / self.max * self.number)            
        end

        s.Wide = w
    end

    self.Slider.Button.OnMousePressed = function(s)
        s.IsPressed = true
    end

    self.Slider.Button.Think = function(s)
        self.Slider.Loaded = true

        local oldNum = self.number

        if not s.IsPressed then return end
        if not input.IsMouseDown(MOUSE_LEFT) then s.IsPressed = false return end
        local x, y = self.Slider:LocalCursorPos()
        x = x - (s:GetWide()/2)
        x = math.Clamp(x, 0, self.Slider.Wide - s.Wide)

        local sliderWidth = self.Slider.Wide - self.Slider.Button.Wide
        local normalizedValue = s:GetX() / sliderWidth
        local scaledValue = (normalizedValue * (self.max - (self.min or 0))) + (self.min or 0)
        
        self.TextBox:SetText(math.Round(scaledValue))


        self.number = self.TextBox:GetText()

        if oldNum ~= self.number then
            self:OnChange(tonumber(self.number))
        end

        s:SetX(x)
    end
end

function PANEL:SetValue(num)
    num = math.min(self.max, num)
    self.TextBox:SetText(num)
    self.TextBox:OnChange()
end

function PANEL:SetMax(num)
    self.max = num
end

function PANEL:SetMin(num)
    self.min = num
end

function PANEL:GetValue()
    return tonumber(self.number) 
end

function PANEL:SetBoxWide(val)
    self.TextBox:SetWide(val)
end

function PANEL:OnChange(value) end
function PANEL:Paint(w, h) end
function PANEL:PerformLayout(w, h)
    self.SettingValue = true

    self.TextBox:DockMargin(self.margin, h*.1, 0, h*.1)
end

vgui.Register("Nexus:NumSlider", PANEL, "EditablePanel")