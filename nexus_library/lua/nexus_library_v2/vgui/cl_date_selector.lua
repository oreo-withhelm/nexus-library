local PANEL = {}
function PANEL:Init()
    self:SetTall(Nexus:GetScale(35))
    self.DateValid = true

    self.Day = self:Add("Nexus:V2:Button")
    self.Day:SetColor(Nexus:GetColor("secondary-2"))
    self.Day:SetCorners(true, false, true, false)
    self.Day:Dock(LEFT)
    self.Day:SetText("")
    self.Day.Value = -1
    self.Day:SetColor(Color(0, 0, 0, 0))
    self.Day.PaintOver = function(s, w, h)
        draw.SimpleText(s.Value == -1 and "dd" or s.Value, Nexus:GetFont({size = 15}), w/2, h/2, Nexus:GetTextColor(Nexus:GetColor("secondary-2")), 1, 1)
    end
    self.Day.DoClick = function(s)
        local tbl = {Nexus:GetPhrase("Reset", "nexus_lib")}
        for i = 1, 32 do
            table.insert(tbl, i)
        end

        Nexus:DermaMenu(tbl, function(str)
            self.Day.Value = str == Nexus:GetPhrase("Reset", "nexus_lib") and -1 or str
            self:VerifyTime()
        end, true, s)
    end

    self.Month = self:Add("Nexus:V2:Button")
    self.Month:SetColor(Nexus:GetColor("secondary-2"))
    self.Month:SetCorners(false, false, false, false)
    self.Month:Dock(LEFT)
    self.Month:SetText("")
    self.Month.Value = -1
    self.Month:SetColor(Color(0, 0, 0, 0))
    self.Month.PaintOver = function(s, w, h)
        draw.SimpleText(s.Value == -1 and "mm" or s.Value, Nexus:GetFont({size = 15}), w/2, h/2, Nexus:GetTextColor(Nexus:GetColor("secondary-2")), 1, 1)
    end
    self.Month.DoClick = function(s)
        local tbl = {Nexus:GetPhrase("Reset", "nexus_lib"), 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
        Nexus:DermaMenu(tbl, function(str)
            self.Month.Value = str == Nexus:GetPhrase("Reset", "nexus_lib") and -1 or str
            self:VerifyTime()
        end, true, s)
    end

    self.Year = self:Add("Nexus:V2:Button")
    self.Year:SetColor(Nexus:GetColor("secondary-2"))
    self.Year:SetCorners(false, true, false, true)
    self.Year:Dock(LEFT)
    self.Year:SetText("")
    self.Year:SetColor(Color(0, 0, 0, 0))
    self.Year.Value = -1
    self.Year.PaintOver = function(s, w, h)
        draw.SimpleText(s.Value == -1 and "yyyy" or s.Value, Nexus:GetFont({size = 15}), w/2, h/2, Nexus:GetTextColor(Nexus:GetColor("secondary-2")), 1, 1)
    end
    self.Year.DoClick = function(s)
        local tbl = {Nexus:GetPhrase("Reset", "nexus_lib")}
        local TimeString = tonumber(os.date("%Y", os.time()))
        for i = 1, 5 do
            table.insert(tbl, TimeString)
            TimeString = TimeString + 1
        end

        Nexus:DermaMenu(tbl, function(str)
            self.Year.Value = str == Nexus:GetPhrase("Reset", "nexus_lib") and -1 or str
            self:VerifyTime()
        end, true, s)
    end
end

local function DateToEpoch(dateStr)
    local day, month, year = dateStr:match("(%d+):(%d+):(%d+)")
    if not day or not month or not year then
        return false
    end

    day = tonumber(day)
    month = tonumber(month)
    year = tonumber(year)
    
    local timeTable = {
        day = day,
        month = month,
        year = year,
        hour = 0,
        min = 0,
        sec = 0
    }

    local epoch = os.time(timeTable)
    
    return epoch
end

function PANEL:GetEpoch()
    return DateToEpoch(self.Day.Value..":"..self.Month.Value..":"..self.Year.Value)
end

function PANEL:OnChange(epoch)
end

function PANEL:VerifyTime()
    self:OnChange(self:GetEpoch())

    local isValid = true

    self.Day.Validated = true
    self.Month.Validated = true
    self.Year.Validated = true

    if isstring(self.Day.Value) or isstring(self.Month.Value) or isstring(self.Year.Value) then
        self.DateValid = false
        return false
    end

    if self.Day.Value == -1 and self.Month.Value == -1 and self.Year.Value == -1 then
        self.DateValid = true
        return
    end

    if self.Day.Value == -1 or self.Month.Value == -1 or self.Year.Value == -1 then
        isValid = false
    else
        local maxDays = 31
        if self.Month.Value == 2 then
            local isLeap = (self.Year.Value % 4 == 0 and self.Year.Value % 100 ~= 0) or (self.Year.Value % 400 == 0)
            maxDays = isLeap and 29 or 28
        elseif table.HasValue({4, 6, 9, 11}, self.Month.Value) then
            maxDays = 30
        end

        if self.Day.Value > maxDays then
            self.Day.Validated = false
            isValid = false
        end

        if self.Year.Value < 1900 or self.Year.Value > 2100 then
            self.Year.Validated = false
            isValid = false
        end
    end

    self.DateValid = isValid
end

function PANEL:SetEpoch(epoch)
    if not epoch then return end
    local dateStr = os.date("%d/%m/%Y", epoch)
    dateStr = string.Explode("/", dateStr)
    self.Day.Value = tonumber(dateStr[1])
    self.Month.Value = tonumber(dateStr[2])
    self.Year.Value = tonumber(dateStr[3])
end

function PANEL:PerformLayout(w, h)
    self.Day:SetWide(w/3)
    self.Month:SetWide(w/3)
    self.Year:SetWide(w/3)
end

function PANEL:Paint(w, h)
    Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("secondary-2"), nil, true)

    if !self.DateValid then
        Nexus.RNDX.Draw(Nexus:GetMargin(), 0, 0, w, h, Color(255, 100, 100, 50), nil, true)
    end
end
vgui.Register("Nexus:V2:Date", PANEL, "EditablePanel")