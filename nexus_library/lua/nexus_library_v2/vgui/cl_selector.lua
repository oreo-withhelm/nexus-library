local openDermaMenu;

local PANEL = {}
AccessorFunc(PANEL, "_Text", "Text", FORCE_STRING)
function PANEL:Init()
    self:SetTall(Nexus:GetScale(35))
    self:SetText("[ ]")

    self.Options = {}
end

function PANEL:SetDefaultAll()
    self.DefaultAll = true
    self:SetText(Nexus:GetPhrase("Selected All", "nexus_lib"))
end

function PANEL:OnRemove()
    if IsValid(openDermaMenu) and self == openDermaMenu.CParent then
        openDermaMenu:Remove()
    end
end

function PANEL:FormatText()
    local text = ""
    for _, v in ipairs(self.Options) do
        if !v.Clicked then continue end
        text = text..v.text..", "
    end

    text = string.Left(text, #text-2)
    text = "[ "..text.." ]"

    if text == "[  ]" then
        self:SetText(self.DefaultAll and Nexus:GetPhrase("Selected All", "nexus_lib") or "[ ]")
    else
        self:SetText(text)
    end
end

function PANEL:GetSelected()
    local tbl = {}
    for _, v in ipairs(self.Options) do
        if !v.Clicked then continue end
        table.insert(tbl, v.text)
    end

    return tbl
end

function PANEL:DoClick()
    table.sort(self.Options, function(a, b) return tostring(a.text) < tostring(b.text) end)

    if IsValid(openDermaMenu) and self == openDermaMenu.CParent then
        openDermaMenu:Remove()
        return
    end

    if IsValid(openDermaMenu) then
        openDermaMenu:Remove()
    end

    local scale = Nexus:GetMargin()
    local margin = Nexus:GetMargin()
    local animTime = 0.15

    local x, y = self:LocalToScreen(0, 0)

    openDermaMenu = vgui.Create("Panel")
    openDermaMenu:SetPos(x, y + self:GetTall())
    openDermaMenu:MakePopup()
    openDermaMenu.CParent = self
    openDermaMenu:DockPadding(margin, margin, margin, margin)
    openDermaMenu.Paint = function(s, w, h)
        draw.RoundedBoxEx(margin, 0, 0, w, h, Nexus:GetColor("background"), true, true, true, true)
    end

    openDermaMenu:SetAlpha(0)
    openDermaMenu:AlphaTo(255, animTime, 0)

    local scroll = openDermaMenu:Add("Nexus:V2:ScrollPanel")
    scroll:Dock(FILL)
    scroll.IsDermaMenu = true
    
    local vbar = scroll:GetVBar()
    vbar:SetWide(Nexus:GetScale(4))

    local totalHeight = margin
    local widest = 0
    local buttons = {}
    for k, v in ipairs(self.Options) do
        local button = scroll:Add("DButton")
        button:Dock(TOP)
        button:DockMargin(0, 0, margin * 0.5, margin * 0.5)
        button:SetText("")
        button:SetFont(Nexus:GetFont({size = 15}))
        button:SetContentAlignment(4)
        button:SizeToContents()
        button.CText = ((v.Clicked and "• " or "")..(istable(v) and tostring(v.text) or tostring(v)))

        surface.SetFont(Nexus:GetFont({size = 15}))
        local btnW, btnH = surface.GetTextSize(istable(v) and tostring(v.text) or tostring(v))
        button:SetTall(btnH + margin)
        widest = math.max(widest, btnW + margin * 2)
        
        button.IsDermaMenu = true
        button:SetAlpha(0)
        button:AlphaTo(255, animTime, k * 0.02)

        button.Paint = function(s, w, h)
            local col = s:IsHovered() and Nexus:GetColor("secondary-2") or Nexus:GetColor("background")
            draw.RoundedBox(margin * 0.5, 0, 0, w, h, col)

            draw.SimpleText(s.CText, s:GetFont(), Nexus:GetMargin(), h/2, Nexus:GetTextColor(Nexus:GetColor("secondary")), 0, 1)
        end

        button.DoClick = function(s)
            v.Clicked = !v.Clicked
            button.CText = ((v.Clicked and "• " or "")..(istable(v) and tostring(v.text) or tostring(v)))

            surface.PlaySound("ui/buttonclick.wav")
            v.func(v.Clicked)

            self:FormatText()
        end

        buttons[k] = button

        if k <= 5 then
            totalHeight = totalHeight + button:GetTall() + margin * 0.5
        end
    end

    widest = math.min(widest + margin*2 + Nexus:GetScale(4), Nexus:GetScale(200))
    totalHeight = math.min(totalHeight + margin, ScrH() - y - scale * 2)
    
    openDermaMenu:SetSize(math.max(widest, self:GetWide()), totalHeight)

    local posX, posY = openDermaMenu:GetPos()
    if posX + widest > ScrW() then
        openDermaMenu:SetPos(ScrW() - widest - scale, posY)
    end
    if posY + totalHeight > ScrH() then
        openDermaMenu:SetPos(posX, ScrH() - totalHeight - scale)
    end

    openDermaMenu.Think = function(s)
        openDermaMenu:MoveToFront()
        openDermaMenu:SetZPos(20)

        if not vgui.CursorVisible() or input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = input.GetCursorPos()
            local x, y, w, h = s:GetBounds()
            if mx < x or mx > x + w or my < y or my > y + h then
                s:AlphaTo(0, animTime, 0, function()
                    if IsValid(s) then
                        s:Remove()
                    end
                end)
            end
        end
    end
end

function PANEL:AddChoice(a, func)
    func = func or function() end

	table.Add(self.Options, {{text = a, func = func}})
end

function PANEL:Paint(w, h)
	draw.RoundedBox(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("secondary-2"))
	draw.SimpleText(self:GetText(), self:GetFont(), Nexus:GetMargin()+4, h/2, Nexus:GetColor("primary-text"), 0, 1)
	draw.SimpleText("•", self:GetFont(), w - Nexus:GetMargin() - 4, h/2, Nexus:GetColor("primary-text"), TEXT_ALIGN_RIGHT, 1)

    if self:IsHovered() then
        draw.RoundedBox(Nexus:GetMargin(), 0, 0, w, h, Nexus:GetColor("overlay"))
    end
end
vgui.Register("Nexus:V2:Selector", PANEL, "Nexus:Button")