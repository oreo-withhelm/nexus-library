local margins = {
    ["large"] = function() return Nexus:GetScale(16) end,
    ["normal"] = function() return Nexus:GetScale(8) end,
    ["small"] = function() return Nexus:GetScale(4) end,
}
function Nexus:GetMargin(str)
    if not str then str = "normal" end
    return margins[str]()
end

local cachedScales = {}
function Nexus:GetScale(number)
    if cachedScales[number] then return cachedScales[number] end

    local scaledValue = math.max(number * (ScrH() / 1080), 1)
    local value = scaledValue % 2 == 0 and scaledValue or scaledValue + 1

    cachedScales[number] = value

    return value
end

local openDermaMenu
function Nexus:DermaMenu(tbl, onClicked)
    if not tbl then return end
    table.sort(tbl)

    if IsValid(openDermaMenu) then
        openDermaMenu:Remove()
    end

    local offset = Nexus:GetScale(4)
    local x, y = input.GetCursorPos()
    openDermaMenu = vgui.Create("Panel")
    openDermaMenu:SetPos(x + offset, y + offset)
    openDermaMenu:SetSize(100, 100)
    openDermaMenu:MakePopup()
    openDermaMenu:DockPadding(0, offset, 0, 0)
    openDermaMenu.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, Nexus:GetColor("background"))
        draw.RoundedBox(Nexus:GetMargin("normal"), 0, offset, w, h-offset, Nexus:GetColor("secondary-2"))
    end

    local scroll = openDermaMenu:Add("Nexus:V2:ScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(0, offset, 0, 0)
    scroll.IsDermaMenu = true
    scroll:GetCanvas().IsDermaMenu = true
    scroll:GetVBar().IsDermaMenu = true
    scroll:GetVBar().btnGrip.IsDermaMenu = true

    local tall = offset
    for k, v in ipairs(tbl) do
        local button = scroll:Add("DButton")
        button:Dock(TOP)
        button:DockMargin(Nexus:GetMargin("small"), 0, Nexus:GetMargin("small"), Nexus:GetMargin("small"))
        button:SetText(v)
        button:SetFont(Nexus:GetFont({size = 14}))
        button:SetTextColor(Nexus:GetTextColor(Nexus:GetColor("secondary")))
        button:SizeToContents()
        button:SetTall(button:GetTall() + Nexus:GetMargin("small"))
        button.IsDermaMenu = true
        button.Paint = function(s, w, h)
            draw.RoundedBox(Nexus:GetMargin("small"), 0, 0, w, h, s:IsHovered() and Nexus:GetColor("background") or Nexus:GetColor("header"))
        end
        button.DoClick = function()
            openDermaMenu:Remove()
            onClicked(v)
        end

        tall = k > 5 and tall or tall + button:GetTall() + Nexus:GetMargin("small")
    end

    tall = tall + offset
    openDermaMenu:SetTall(tall)
end

hook.Add("VGUIMousePressed", "Nexus:DermaMenu:Close", function(panel)
    if IsValid(openDermaMenu) and not panel.IsDermaMenu then
        openDermaMenu:Remove()
    end
end)