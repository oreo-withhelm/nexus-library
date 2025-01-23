local right = Material("vgui/gradient-r")
local left = Material("vgui/gradient-l")

local PANEL = {}
function PANEL:Init()
    self.active = false
    self.buttons = {}

    self.backgroundCol = Nexus:GetColor("secondary")
    self.secondaryCol = Nexus:OffsetColor(Nexus:GetColor("secondary"), 10, true)

    self:DockPadding(0, 0, Nexus:GetScale(2), 0)

    self.Scroll = self:Add("Nexus:V2:ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(Nexus:GetMargin("normal"), Nexus:GetMargin("normal"), 0, 0)
end

function PANEL:AddSpacer()
    self.spacer = self.Scroll:Add("DPanel")
    self.spacer:Dock(TOP)
    self.spacer:DockMargin(0, 0, Nexus:GetMargin("normal"), Nexus:GetMargin("normal"))
    self.spacer:SetTall(Nexus:GetScale(3))
    self.spacer.Paint = function(s, w, h)
        surface.SetDrawColor(self.secondaryCol.r, self.secondaryCol.g, self.secondaryCol.b, self.secondaryCol.a)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:AddItem(text, func, icon, id)
    id = id or (#self.buttons + 1)

    if self.buttons[id] then
        error("you have added a tab to the sidebar with an id that already exists")        
        return
    end

    self.active = self.active or id

    local button = self.Scroll:Add("DButton")
    button:Dock(TOP)
    button:DockMargin(0, 0, Nexus:GetMargin("normal"), Nexus:GetMargin("normal"))
    button:SetTall(Nexus:GetScale(30))
    button:SetText("")
    button.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("background"))

        local textColor = self.active == id and Nexus:GetColor("primary-text") or Nexus:GetColor("secondary-text")
        local size = h - Nexus:GetMargin("small")*2
        if icon then
            draw.RoundedBox(Nexus:GetMargin("small"), Nexus:GetMargin("small"), Nexus:GetMargin("small"), size, size, self.active == id and Nexus:GetColor("orange") or Nexus:GetColor("secondary"))

            Nexus:DrawImgur(icon, Nexus:GetMargin("small") + (size*.1), Nexus:GetMargin("small") + (size*.1), size*.8, size*.8, self.active == id and color_black or textColor)
        end

        draw.SimpleText(text, Nexus:GetFont({size = h*.6, dontScale = true}), icon and Nexus:GetMargin("small")*2 + size or Nexus:GetMargin("normal"), h/2, textColor, 0, 1)
    end
    button.func = func
    button.DoClick = function(s)
        self:SelectItem(id)
    end

    if IsValid(self.bumper) then
        self.bumper:Remove()
    end

    self.bumper = self.Scroll:Add("DPanel")
    self.bumper:Dock(TOP)
    self.bumper:SetTall(Nexus:GetMargin("small"))
    self.bumper.Paint = nil

    self.buttons[id] = button

    if self.active == id then
        self:SelectItem(id)
    end
end

function PANEL:SelectItem(id)
    for itemID, button in pairs(self.buttons) do
        if itemID == id then
            self.active = id
            button.func()
            return
        end
    end
end

function PANEL:SetMask(corners)
    --{roundness, true, true, true, true}
    self.mask = corners
end

function PANEL:DrawSidebar(w, h)
    surface.SetDrawColor(self.backgroundCol.r, self.backgroundCol.g, self.backgroundCol.b, 230)
    surface.SetMaterial(left)
    surface.DrawTexturedRect(0, 0, w, h)

    surface.SetDrawColor(self.backgroundCol.r, self.backgroundCol.g, self.backgroundCol.b, self.backgroundCol.a)
    surface.SetMaterial(right)
    surface.DrawTexturedRect(0, 0, w, h)

    local col = Nexus:GetColor("secondary")
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawRect(w - Nexus:GetScale(2), 0, Nexus:GetScale(2), h)
end    

function PANEL:Paint(w, h)
    if self.mask then
        Nexus.Masks.Start()
            self:DrawSidebar(w, h)
        Nexus.Masks.Source()
            draw.RoundedBoxEx(self.mask[1], 0, 0, w, h, color_white, self.mask[2], self.mask[3], self.mask[4], self.mask[5])
        Nexus.Masks.End()
        return
    end

    self:DrawSidebar(w, h)
end
vgui.Register("Nexus:V2:Sidebar", PANEL, "EditablePanel")