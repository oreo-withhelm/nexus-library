local gradientMat = Material("vgui/gradient-u")
local function DrawGradientPoly(data, xpos, ypos, w, h, col)
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(1)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

    render.SetBlend(0)
    for _, v in ipairs(data) do
        surface.SetDrawColor(255, 255, 255)
        surface.DrawPoly(v)
    end
    render.SetBlend(1)

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)

    surface.SetMaterial(gradientMat)
    surface.SetDrawColor(col.r, col.g, col.b)
    surface.DrawTexturedRect(0, 0, w, h)

    render.SetStencilEnable(false)
end

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
    self.Values = {}

    self.Polys = {}
    self.DataPos = {}

    self.Min = math.huge
    self.Max = 0

    self:SetColor(Color(49, 126, 199))
end

function PANEL:AddValue(value, footerText, displayedText)
    if not displayedText then
        displayedText = "$"..string.Comma(value)
    end

    table.Add(self.Values, {{value = value, footerText = footerText, displayedText = displayedText}})

    self.Min = math.huge
    self.Max = 0

    for _, v in ipairs(self.Values) do
        self.Min = math.min(self.Min, v.value)
        self.Min = math.max(0, self.Min - (self.Min*0.01))
        self.Min = math.floor(self.Min, 2)

        self.Max = math.max(self.Max, v.value)
        self.Max = self.Max + (self.Max*0.01)
        self.Max = math.ceil(self.Max, 2)

        self.Range = math.ceil(self.Max - self.Min)
    end

    self.Reformat = true
end

function PANEL:Paint(w, h)
    local newH = h - Nexus:Scale(50)
    draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Header)

    if #self.Values == 0 then return end

    local step = 2
    local fontSize = Nexus:Scale(20)
    local numberCount = ((newH-fontSize)/fontSize)
    local eachValue = (self.Range / (math.Round((numberCount)/step)-1))

    local widthUsed = 0
    local value = self.Max
    local newRange = self.Max
    local newH = 0
    local th = 0
    for i = 1, numberCount, step do
        local ypos = ((i-1)*fontSize) + self.margin
        local temp = numberCount - i
        local tw, th = draw.SimpleText(DarkRP.formatMoney(math.Round(value)), Nexus:GetFont(fontSize, true), self.margin, ypos, color_white, 0, 0)
        value = value - (eachValue)
        widthUsed = math.max(widthUsed, tw)
        newH = ypos + th
    end
    newH = newH - self.margin - th
    newRange = math.Round(self.Max - value)

    local xpos = widthUsed + (self.margin*2)
    local ypos = (((numberCount+1)-1)*fontSize) + self.margin
    surface.SetDrawColor(200, 200, 200)
    surface.DrawRect(self.margin, ypos, w - (self.margin*2), 2)

    surface.SetDrawColor(200, 200, 200)
    surface.DrawRect(xpos, self.margin, 2, h - (self.margin*2))

    local newW = (w - xpos - 2)/#self.Values
    xpos = xpos + (newW/2)

    if self.Reformat then
        self.Polys = {}
        self.DataPos = {}

        for k, v in ipairs(self.Values) do
            local x, y = 0, (newH - ((v.value - self.Min) / (self.Max - self.Min)) * newH) + self.margin
            self.DataPos[k] = {x = xpos, y = y}
            xpos = xpos + newW
        end

        for k, v in ipairs(self.DataPos) do
            self.Polys[k] = {
                {x = v.x, y = ypos},
                {x = v.x, y = v.y},
                {x = self.DataPos[k+1] and self.DataPos[k+1].x or v.x, y = self.DataPos[k+1] and self.DataPos[k+1].y or v.y},
                {x = self.DataPos[k+1] and self.DataPos[k+1].x or v.x, y = ypos},
            }
        end
        self.Reformat = false
    end

    DrawGradientPoly(self.Polys, self.DataPos[1].x, self.margin, w, h - (h - ypos), self.GraphCol)

    for k, v in ipairs(self.Values) do
        local x, y = self.DataPos[k].x, self.DataPos[k].y
        draw.RoundedBox(self.margin, x - (self.margin/2), y - (self.margin/2), self.margin, self.margin, color_white)
        local tw, th = draw.SimpleText(v.footerText, Nexus:GetFont(25), x, ypos + 2, color_white, 1, 0)
        draw.SimpleText(v.displayedText, Nexus:GetFont(25), x, (y - self.margin - Nexus:Scale(25)) <= 0 and y + self.margin + th or y - self.margin, color_white, 1, TEXT_ALIGN_BOTTOM)
    end
end

function PANEL:SetColor(col)
    self.GraphCol = col
end
vgui.Register("Nexus:Graph", PANEL, "EditablePanel")