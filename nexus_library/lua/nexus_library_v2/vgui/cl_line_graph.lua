local PANEL = {}

function PANEL:Init()
    self.margin = Nexus:GetMargin("large")
    self.Series = {}
    self.SeriesOrder = {}
    self.Points = {}

    self.GlobalMin = 0
    self.GlobalMax = 0
    self.MaxDataCount = 0

    self:SetMouseInputEnabled(true)

    self.colorsUsed = {}
end

function PANEL:GenerateRandomColor()
    local color
    local function isSimilar(c1, c2)
        return math.abs(c1.r - c2.r) < 30 and math.abs(c1.g - c2.g) < 30 and math.abs(c1.b - c2.b) < 30
    end

    repeat
        color = HSVToColor(math.random(0, 360), 0.8, 1)
    until not self.colorsUsed[tostring(color)] and not (function()
        for _, usedColor in pairs(self.colorsUsed) do
            if isSimilar(usedColor, color) then
                return true
            end
        end
        return false
    end)()

    self.colorsUsed[tostring(color)] = color
    return color
end

local function GetBezierPoint(t, p0, p1, p2, p3)
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t

    local x = uuu * p0.x + 3 * uu * t * p1.x + 3 * u * tt * p2.x + ttt * p3.x
    local y = uuu * p0.y + 3 * uu * t * p1.y + 3 * u * tt * p2.y + ttt * p3.y

    return {x = x, y = y}
end

local function DrawCurvedLine(points, segments)
    if #points < 2 then return end
    segments = segments or 20

    for i = 1, #points - 1 do
        local p0 = points[i-1] or points[i]
        local p1 = points[i]
        local p2 = points[i+1]
        local p3 = points[i+2] or p2

        local tension = 0.25

        local cp1 = {
            x = p1.x + (p2.x - p0.x) * tension,
            y = p1.y + (p2.y - p0.y) * tension
        }

        local cp2 = {
            x = p2.x - (p3.x - p1.x) * tension,
            y = p2.y - (p3.y - p1.y) * tension
        }

        local lastPt = p1
        for j = 1, segments do
            local t = j / segments
            local nextPt = GetBezierPoint(t, p1, cp1, cp2, p2)
            
            surface.DrawLine(lastPt.x, lastPt.y, nextPt.x, nextPt.y)
            lastPt = nextPt
        end
    end
end

function PANEL:AddLine(id, name, color)
    if not color then color = self:GenerateRandomColor() end
    
    self.Series[id] = {
        name = name,
        color = color,
        data = {}
    }
    
    table.insert(self.SeriesOrder, id)
end

function PANEL:AddValue(lineID, value, footerText, tooltipText)
    if not self.Series[lineID] then return end

    if not tooltipText then
        tooltipText = string.Comma(value)
    end

    table.insert(self.Series[lineID].data, {
        value = value,
        footerText = footerText,
        tooltipText = tooltipText
    })

    self:Recalculate()
end

function PANEL:PerformLayout(w, h)
    self:Recalculate()
end

function PANEL:Recalculate()
    local w, h = self:GetSize()
    
    self.GlobalMin = math.huge
    self.GlobalMax = -math.huge
    self.MaxDataCount = 0

    local hasData = false
    for id, line in pairs(self.Series) do
        if #line.data > 0 then hasData = true end
        self.MaxDataCount = math.max(self.MaxDataCount, #line.data)
        
        for _, pt in ipairs(line.data) do
            self.GlobalMin = math.min(self.GlobalMin, pt.value)
            self.GlobalMax = math.max(self.GlobalMax, pt.value)
        end
    end

    if not hasData then return end

    local range = self.GlobalMax - self.GlobalMin
    if range == 0 then range = 1 end
    local padding = range * 0.1
    
    self.DisplayMin = self.GlobalMin - padding
    self.DisplayMax = self.GlobalMax + padding
    local displayRange = self.DisplayMax - self.DisplayMin

    local maxLabelWidth = 0
    local rows = 8
    local valStep = (self.DisplayMax - self.DisplayMin) / rows
    
    surface.SetFont(Nexus:GetFont({size=10}))
    for i = 0, rows do
        local val = math.Round(self.DisplayMin + (i * valStep))
        local tw = surface.GetTextSize(string.Comma(val))
        maxLabelWidth = math.max(maxLabelWidth, tw)
    end

    self.LegendHeight = Nexus:GetScale(30)
    self.GraphAreaX = self.margin + maxLabelWidth + Nexus:GetMargin()
    self.GraphAreaY = self.margin
    self.GraphAreaW = w - self.GraphAreaX - self.margin
    self.GraphAreaH = h - (self.margin * 2) - self.LegendHeight

    self.Points = {}

    local xDivisor = math.max(1, self.MaxDataCount - 1)
    local segmentW = self.GraphAreaW / xDivisor

    for id, line in pairs(self.Series) do
        self.Points[id] = {}
        
        for i, pt in ipairs(line.data) do
            local x = self.GraphAreaX + ((i-1) * segmentW)
            
            local normalizedVal = (pt.value - self.DisplayMin) / displayRange
            
            local y = (self.GraphAreaY + self.GraphAreaH) - (normalizedVal * self.GraphAreaH)
            
            table.insert(self.Points[id], {
                x = x, 
                y = y, 
                data = pt,
                lineName = line.name,
                lineColor = line.color
            })
        end
    end
end

function PANEL:Paint(w, h)
    Nexus.RNDX.Draw(0, 0, 0, w, h, color_white, Nexus.RNDX.BLUR)
    Nexus.RNDX.Draw(0, 0, 0, w, h, Nexus:GetColor("background"))
    Nexus.RNDX.DrawOutlined(0, 0, 0, w, h, Nexus:GetColor("highlight"), 1)

    if self.MaxDataCount < 2 then return end

    local rows = 8
    local rowStep = self.GraphAreaH / rows
    local valStep = (self.DisplayMax - self.DisplayMin) / rows
    
    surface.SetDrawColor(255, 255, 255, 5)
    
    for i = 0, rows do
        local y = (self.GraphAreaY + self.GraphAreaH) - (i * rowStep)
        
        surface.DrawLine(self.GraphAreaX, y, self.GraphAreaX + self.GraphAreaW, y)
        
        local val = math.Round(self.DisplayMin + (i * valStep))
        draw.SimpleText(string.Comma(val), Nexus:GetFont({size=10}), self.GraphAreaX - Nexus:GetScale(5), y, Nexus:GetColor("secondary-text"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    for id, points in pairs(self.Points) do
        local color = self.Series[id].color
        surface.SetDrawColor(color)
        
        DrawCurvedLine(points, 20)
    end

    local mx, my = self:CursorPos()
    local hoveredPoint = nil
    local closestDist = Nexus:GetScale(20)

    for id, points in pairs(self.Points) do
        local color = self.Series[id].color

        for i, pt in ipairs(points) do
            local dist = math.Distance(mx, my, pt.x, pt.y)
            local isHovered = dist < closestDist
            
            if isHovered then
                hoveredPoint = pt
                closestDist = dist
            end

            if self.MaxDataCount < 20 or isHovered then
                Nexus.RNDX.Draw(Nexus:GetScale(4), pt.x-1, pt.y-Nexus:GetScale(2), 2, 6, color)
            end

            if id == self.SeriesOrder[1] then 
                if self.MaxDataCount < 10 or (i == 1 or i == self.MaxDataCount or i % 5 == 0) then
                    draw.SimpleText(pt.data.footerText, Nexus:GetFont({size=10}), pt.x, self.GraphAreaY + self.GraphAreaH + Nexus:GetScale(4), Nexus:GetColor("secondary-text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end
            end
        end
    end

    if hoveredPoint then
        local tipText = hoveredPoint.data.tooltipText
        local margin = Nexus:GetMargin()
        
        surface.SetFont(Nexus:GetFont({size=14}))
        local tw = surface.GetTextSize(tipText)
        local wTip = tw + (margin * 2)
        local hTip = margin * 2 + Nexus:GetScale(14)
        
        local tx = hoveredPoint.x - (wTip / 2)
        local ty = hoveredPoint.y - hTip - Nexus:GetScale(10)

        if tx < 0 then tx = 0 end
        if (tx + wTip) > w then tx = w - wTip end
        
        Nexus.RNDX.Draw(margin, tx, ty, wTip, hTip, Nexus:GetColor("secondary-2"))
        
        draw.SimpleText(tipText, Nexus:GetFont({size=14}), tx + (wTip / 2), ty + (hTip / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local legendY = h - self.LegendHeight/2
    local currentX = self.margin + Nexus:GetScale(5)

    for _, id in ipairs(self.SeriesOrder) do
        local series = self.Series[id]

        Nexus.RNDX.Draw(Nexus:GetMargin()*.25, currentX, legendY - Nexus:GetMargin()/2, Nexus:GetMargin(), Nexus:GetMargin(), series.color)
        
        surface.SetFont(Nexus:GetFont({size=14}))
        local tw, th = surface.GetTextSize(series.name)
        draw.SimpleText(series.name, Nexus:GetFont({size=14}), currentX + Nexus:GetScale(14), legendY, Nexus:GetColor("secondary-text"), TEXT_ALIGN_LEFT, 1)
        
        currentX = currentX + Nexus:GetScale(14) + tw + Nexus:GetScale(15)
    end
end

vgui.Register("Nexus:V2:Graph", PANEL, "EditablePanel")