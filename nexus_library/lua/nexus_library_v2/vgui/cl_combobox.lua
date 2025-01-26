function Nexus.PopoutMenu(s, tbl, onClicked, dontSort, spawnOnMouse, hide)
    tbl = tbl or {}

    if not dontSort then
        table.SortByMember(tbl, "text", true)
    end

    local margin = Nexus:GetMargin("normal")

    s.Panel = vgui.Create("DButton")
    s.Panel:SetSize(ScrW(), ScrH())
    s.Panel:MakePopup()
    s.Panel:SetText("")
    s.Panel.DoClick = function(ss)
        ss:Remove()
    end
    s.Panel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, hide and 0 or 210)
        surface.DrawRect(0, 0, w, h)
    end
    s.Panel.Think = function(ss)
        if not IsValid(s) then
            ss:Remove()
            return
        end

        ss:MoveToFront()
    end

    local x, y = s:LocalToScreen(0, s:GetTall() + margin)

    if spawnOnMouse then
        x, y = input.GetCursorPos()
        x = x + Nexus:GetMargin("normal")
        y = y + Nexus:GetMargin("normal")
    end

    local panel = s.Panel:Add("DPanel")
    panel:SetSize(Nexus:GetScale(200), Nexus:GetScale(300))
    panel:SetPos(x, y)
    panel.Paint = function(s, w, h)
        draw.RoundedBox(margin, 0, 0, w, h, Nexus:GetColor("background"))
    end

    local scroll = panel:Add("Nexus:V2:ScrollPanel")
    scroll:Dock(FILL)

    surface.SetFont(Nexus:GetFont({size = 15}))

    local maxW = Nexus:GetScale(150)

    local tall = 0
    for _, data in ipairs(tbl) do
        local v = data.text or data
        local button = scroll:Add("Nexus:V2:Button")
        button:Dock(TOP)
        button:DockMargin(margin, margin, margin, 0)
        button:SetTall(Nexus:GetScale(35))
        button:SetText(v)
        button:SetSecondary()
        button.DoClick = function()
            s.Panel:Remove()
            onClicked(v)
            if data.func then data.func() end
        end

        local tw, th = surface.GetTextSize(v)
        maxW = math.max(maxW, tw)
        tall = tall + Nexus:GetScale(35) + margin
    end

    maxW = maxW + margin*4
    maxW = math.max(maxW, s:GetWide())

    panel:SetWide(maxW)
    panel:SetTall(math.min(tall, Nexus:GetScale(300)) + margin)

    if spawnOnMouse then
        panel:SetWide(Nexus:GetScale(200))
    end
    return maxW
end

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin("normal")

	self:SetFont(Nexus:GetFont({size = 15}))
	self:SetTextColor(Color(120, 120, 120))
	self.Options = {}
    self.DontSort = false
end

function PANEL:DoClick()
	Nexus.PopoutMenu(self, self.Options, function(val)
		self.Selected = val
		self:SetText(val)
		self:OnSelect(false, val)
	end, self.DontSort)
end

function PANEL:SetValue(str)
    self:SetText(str)
end

function PANEL:GetValue()
    return self:GetText()
end

function PANEL:SetDontSort(bool)
    self.DontSort = bool
end

function PANEL:OnSelect(index, value)
end

function PANEL:AddChoice(a, func)
    func = func or function() end

	table.Add(self.Options, {{text = a, func = func}})
end

function PANEL:AutoWide()
    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText().."•")
    self:SetWide(tw + 4 + self.margin*3)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(self.margin, 0, 0, w, h, Nexus:GetColor("secondary-2"))
	draw.SimpleText(self:GetText(), self:GetFont(), self.margin+4, h/2, Nexus:GetColor("secondary-text"), 0, 1)
	draw.SimpleText("•", self:GetFont(), w - self.margin - 4, h/2, Nexus:GetColor("secondary-text"), TEXT_ALIGN_RIGHT, 1)
end
vgui.Register("Nexus:V2:ComboBox", PANEL, "Nexus:Button")