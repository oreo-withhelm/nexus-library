local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:GetMargin("normal")
    self.Panels = {}
    self.Tables = {}

    self.Navbar = self:Add("Nexus:V2:Navbar")
    self.Navbar:Dock(TOP)
    self.Navbar:DockMargin(self.margin, self.margin, self.margin, 0)

    for _, data in ipairs(Nexus.Addons) do
        self.Navbar:AddItem(data.name, function()
            self:SelectContent(data)
        end)
    end

    hook.Add("Nexus:IGC:ValueChanged", "Nexus:IGC:ValueChanged", function(id, value)
        if not IsValid(self) then return end
        if not self.Panels[id] then return end
        self.Panels[id](value)
    end)

    hook.Add("Nexus:IGC:V2:Edited", "Nexus:IGC:V2:ValueChanged", function(configID, column, m_id, value)
        if not IsValid(self) then return end
        if not self.Tables[configID] then return end

        self.Tables[configID]({
            configID = configID, 
            column = column, 
            m_id = m_id, 
            value = value,
        })
    end)
end

function PANEL:SelectContent(data)
    if IsValid(self.content) then self.content:Remove() end

    self.content = self:Add("Nexus:V2:ScrollPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(self.margin, self.margin, self.margin, self.margin)

    for _, v in ipairs(data.Elements or {}) do
        if v.id == "label" then
            self:AddLabel(istable(v.text) and Nexus:GetPhrase(v.text[1], v.text[2]) or v.text, v.margin, v.size)
        elseif v.id == "button-row" then
            local row = self:AddRow()
            if v.data.isToggle then
                row:SetTall(Nexus:GetScale(35))
            end
            local buttons = {}

            local dat = {}
            if isfunction(v.data.buttons) then
                dat = v.data.buttons()
            else
                dat = v.data.buttons
            end

            for int, buttonDATA in ipairs(dat or {}) do
                local button = self:AddButton(row, isfunction(buttonDATA.text) and buttonDATA.text() or buttonDATA.text or "N/A", v.data.showSelected and Nexus:GetColor("secondary") or buttonDATA.color, function()
                    net.Start("Nexus:IGC:V2:UpdateValue")
                        net.WriteString(v.id)
                        net.WriteString(v.data.id)
                        net.WriteUInt(int, 4)
                    net.SendToServer()
                end)

                if v.data.isToggle then
                    surface.SetFont(button:GetFont())
                    local tw, th = surface.GetTextSize(isfunction(buttonDATA.text) and buttonDATA.text() or buttonDATA.text or "N/A")
                    button:SetWide(tw + Nexus:GetMargin()*2)
                end

                table.Add(buttons, {{id = v.data.id, button = button, buttonDATA = buttonDATA}})

                if v.data.showSelected and Nexus:GetValue(v.data.id) == buttonDATA.value then
                    button:SetColor(Nexus:GetColor("green"))
                end
            end

            if v.data.isToggle then
                local label = row:Add("DLabel")
                label:Dock(FILL)
                label:SetText(Nexus:GetPhrase(v.data.label[1], v.data.label[2]))
                label:SetFont(Nexus:GetFont({size = 18}))
            end

            self.Panels[v.data.id] = function(value)
                if not v.data.showSelected then return end

                for _, v in ipairs(buttons) do
                    v.button:SetColor(Nexus:GetValue(v.id) == v.buttonDATA.value and Nexus:GetColor("green") or Nexus:GetColor("secondary"))
                end
            end
        elseif v.id == "text-entry" then
            local row = self:AddRow()

            local textEntry = self:AddTextEntry(row, Nexus:GetValue(v.data.id), v.data.placeholder, nil, nil, v.data.isNumeric)
            self:AddButton(row, "   Save   ", Nexus:GetColor("secondary"), function()
                local value = textEntry:GetText()
                net.Start("Nexus:IGC:V2:UpdateValue")
                    net.WriteString(v.id)
                    net.WriteString(v.data.id)
                    net.WriteString(value)
                net.SendToServer()
            end)

            self.Panels[v.data.id] = function(value)
                textEntry:SetText(value)
            end
        elseif v.id == "multi-text-entry" then
            local row = self:AddRow()

            local entries = {}
            local data = Nexus:GetValue(v.data.id)
            for _, v in ipairs(v.data.entries) do
                entries[v.id] = self:AddTextEntry(row, data[v.id] or v.default, v.placeholder, nil, Nexus:Scale(150), v.isNumeric)
            end

            self:AddButton(row, "   Save   ", Nexus:GetColor("secondary"), function()
                net.Start("Nexus:IGC:V2:UpdateValue")
                    net.WriteString(v.id)
                    net.WriteString(v.data.id)
                    for _, v in ipairs(v.data.entries) do
                        net.WriteString(entries[v.id]:GetText())
                    end
                net.SendToServer()
            end)

            self.Panels[v.data.id] = function(data)
                for id, val in pairs(data) do
                    entries[id]:SetText(val)
                end
            end
        elseif v.id == "key-table" then
            local form = self:AddKeyTable(v.data, function(isAdd, value)
                net.Start("Nexus:IGC:V2:UpdateValue")
                    net.WriteString(v.id)
                    net.WriteString(v.data.id)
                    net.WriteBool(isAdd)
                    net.WriteString(value)
                net.SendToServer()
            end)

            form.OnRowRightClick = function(s)
                local menu = DermaMenu() 
                menu:AddOption("Delete", function()
                    net.Start("Nexus:IGC:V2:UpdateValue")
                    net.WriteString(v.id)
                    net.WriteString(v.data.id)
                    net.WriteBool(false)
                    net.WriteUInt(#form:GetSelected(), 8)
                    for _, v in ipairs(form:GetSelected()) do
                        net.WriteString(v:GetColumnText(1))
                    end
                    net.SendToServer()
                end)
                menu:Open()
            end

            self.Panels[v.data.id] = function(tbl)
                if tbl.isAdd then
                    form:AddLine(tbl.value)
                else
                    for _, v in pairs(form:GetLines()) do
                        if v:GetColumnText(1) == tbl.value then
                            form:RemoveLine(v:GetID())
                        end
                    end
                end
            end
        elseif v.id == "table" then
            local form = self:AddTable(v.data, function(elements)
                net.Start("Nexus:IGC:V2:UpdateValue")
                net.WriteString(v.id)
                net.WriteString(v.data.id)
                net.WriteBool(true)
                for k, v in ipairs(v.data.values) do
                    if v.type == "TextEntry" or v.type == "ComboBox" then
                        net.WriteString(elements[k]:GetText()) // supports massive eco servers
                    elseif v.type == "CheckBox" then
                        net.WriteBool(elements[k]:GetState())
                    end
                end
                net.SendToServer()
            end)

            form.DoubleClicked = function(s, LineID, Line, column)
                if not IsValid(Line) or not Line.m_id then return end

                local baseV = v
                local k, v = column, v.data.values[column]

                local customUI = Nexus.UIBuilder:Start()
                :CreateFrame({
                    title = "Row Editor",
                    size = {
                        w = Nexus:Scale(450),
                        h = Nexus:Scale(300),
                    },
                
                    darken = true,
                    id = "Nexus:Config:RowEditor",
                    reference = s,
                })
                local Frame = customUI:GetLastPanel()
                local tall = Nexus:Scale(50) + self.margin

                local element = false
                if v.type == "TextEntry" then
                    element = Frame:Add("Nexus:TextEntry")
                    element:Dock(TOP)
                    element:DockMargin(self.margin, self.margin, self.margin, 0)
                    element:SetTall(Nexus:Scale(50))
                    element:SetPlaceholder(v.placeholder)
                    element:SetTooltip(v.placeholder)
                    element:SetTooltipDelay(0)
                    if v.isNumeric then
                        element:SetNumeric(true)
                    end
                    
                    tall = tall + self.margin + Nexus:Scale(50)
                elseif v.type == "CheckBox" then
                    element = Frame:Add("Nexus:CheckBox")
                    element:Dock(TOP)
                    element:DockMargin(self.margin, self.margin, self.margin, 0)
                    element:SetText(v.placeholder)
                    element:SetTall(Nexus:Scale(35))
        
                    tall = tall + self.margin + Nexus:Scale(35)
                elseif v.type == "ComboBox" then
                    element = Frame:Add("Nexus:V2:ComboBox")
                    element:Dock(TOP)
                    element:DockMargin(self.margin, self.margin, self.margin, 0)
                    element:SetText(v.placeholder)
                    element:SetTall(Nexus:Scale(50))
                    for _, item in ipairs(isfunction(v.values) and v.values() or v.values) do
                        element:AddChoice(item)
                    end
        
                    tall = tall + self.margin + Nexus:Scale(50)
                end

                local save = Frame:Add("Nexus:V2:Button")
                save:SetText("Save")
                save:Dock(TOP)
                save:DockMargin(self.margin, self.margin, self.margin, 0)
                save:SetTall(Nexus:Scale(50))
                save.DoClick = function()
                    net.Start("Nexus:IGC:V2:EditValue")
                    net.WriteString(v.id)
                    net.WriteUInt(Line.m_id, 32)
                    net.WriteString(baseV.data.id)
                    if v.type == "TextEntry" or v.type == "ComboBox" then
                        net.WriteString(element:GetText()) // supports massive eco servers
                    elseif v.type == "CheckBox" then
                        net.WriteBool(element:GetState())
                    end
                    net.SendToServer()
                end

                Frame:SetTall(tall + Nexus:Scale(50) + self.margin)
            end

            form.OnRowRightClick = function(s)
                local menu = DermaMenu() 
                local mx, my = input.GetCursorPos()
                menu:AddOption("Edit Value", function()
                    local num, pnl = s:GetSelectedLine()
                    s:DoDoubleClick(num, pnl, mx, my)
                end)

                menu:AddOption("Delete", function()
                    net.Start("Nexus:IGC:V2:UpdateValue")
                    net.WriteString(v.id)
                    net.WriteString(v.data.id)
                    net.WriteBool(false)
                    net.WriteUInt(#form:GetSelected(), 8)
                    for _, v in ipairs(form:GetSelected()) do
                        net.WriteUInt(v["m_id"], 20)
                    end
                    net.SendToServer()
                end)
                menu:Open()
            end

            form.FormatPercentages = function()
                if v.data.isPercentage then
                    local totalPercent = 0
                    for _, line in pairs(form:GetLines()) do
                        line:SetColumnText(#v.data.values, line["oValue"])
                        totalPercent = totalPercent + tonumber(line:GetColumnText(#v.data.values))
                    end

                    for k, line in pairs(form:GetLines()) do
                        local curWeight = tonumber(line:GetColumnText(#v.data.values))
                        local value = curWeight / totalPercent * 100
                        line:SetColumnText(#v.data.values, value)
                    end
                end
            end
            form.FormatPercentages()

            self.Tables[v.data.id] = function(tbl)
                for _, line in ipairs(form:GetLines()) do
                    if line["m_id"] == tbl["m_id"] then
                        for int, columnDATA in ipairs(v.data.values) do
                            if columnDATA["id"] == tbl.column then
                                line:SetValue(int, tbl.value)
                            end
                        end
                    end
                end
            end

            self.Panels[v.data.id] = function(tbl)
                if tbl.isAdd then
                    local packedDATA = {}
                    for k, v in ipairs(v.data.values) do
                        packedDATA[k] = tbl.value[v.id]
                    end

                    local line = form:AddLine(unpack(packedDATA))
                    line["m_id"] = tbl["value"]["m_id"]
                    line["oValue"] = tbl["value"]["Chance"]
                else
                    for _, v in pairs(form:GetLines()) do
                        if v["m_id"] == tbl.id then
                            form:RemoveLine(v:GetID())
                        end
                    end
                end

                form.FormatPercentages()
            end
        end
    end

    hook.Run("Nexus:Config:AddonOpened", data.name, self.content)
end

function PANEL:AddRow()
    local panel = self.content:Add("DPanel")
    panel:Dock(TOP)
    panel:DockMargin(0, 0, self.margin, 0)
    panel:SetTall(Nexus:GetScale(40))
    panel.Paint = nil

    return panel
end

function PANEL:AddLabel(text, margin, size)
    local label = self.content:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(0, 0, 0, Nexus:GetMargin("normal"))
    label:SetText(text)
    label:SetFont(Nexus:GetFont(25))
    label:SetTextColor(Nexus:GetTextColor(Nexus.Colors.Background))
    label:SizeToContents()

    if text == "" then
        label:SetTall(self.margin)
    end

    return label
end

function PANEL:AddButton(row, text, col, onClick)
    local button = row:Add("Nexus:V2:Button")
    button:Dock(LEFT)
    button:DockMargin(0, 0, self.margin, 0)
    button:SetColor(col or Nexus:GetColor("secondary"))
    button:SetText(text)
    button:AutoWide()
    button.DoClick = function()
        onClick()
    end

    return button
end

function PANEL:AddTextEntry(row, text, placeholder, min, max, isNumeric)
    min = min or Nexus:Scale(100)
    max = max or Nexus:Scale(600)

    local textEntry = row:Add("Nexus:V2:TextEntry")
    textEntry:Dock(LEFT)
    textEntry:DockMargin(0, 0, self.margin, 0)
    textEntry:SetText(text)
    textEntry:SetPlaceholder(placeholder)

    if isNumeric then
        textEntry:SetNumeric(true)
    end

    textEntry.FormatSize = function(s)
        local size = (self.margin * 3) + 8

        surface.SetFont(s:GetFont())
        local tw, th = surface.GetTextSize(s:GetText() == "" and s:GetPlaceholder() or s:GetText())
        size = size + tw

        size = math.Clamp(size, min, max)
        s:SetWide(size)
    end
    textEntry.OnChange = function(s)
        s.FormatSize(s)
    end
    textEntry:FormatSize()

    return textEntry
end

function PANEL:AddKeyTable(tbl, func)
    local data = Nexus:GetValue(tbl.id)

    local row = self:AddRow()
    row:DockPadding(1, 1, 1, 1)
    row:SetTall(Nexus:Scale(200))
    row.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, w, h, Nexus:GetColor("primary-text"))
        draw.RoundedBox(self.margin, 1, 1, w-2, h-2, Nexus:GetColor("header"))
    end

    local leftPanel = row:Add("Panel")
    leftPanel:Dock(LEFT)
    leftPanel:DockMargin(0, 0, 0, 0)
    leftPanel:SetWide(Nexus:Scale(200))

    local textEntry = leftPanel:Add("Nexus:V2:TextEntry")
    textEntry:Dock(TOP)
    textEntry:DockMargin(self.margin, self.margin, self.margin, 0)
    textEntry:SetTall(Nexus:Scale(50))
    textEntry:SetPlaceholder(tbl.placeholder)

    local form = row:Add("Nexus:ListView")
    form:Dock(FILL)
    form:DockMargin(0, 0, self.margin, 0)
    form:AddColumn(tbl.placeholder)
    form:SetColor(Nexus:GetColor("secondary"))
    for id, bool in pairs(data) do
        if not bool then continue end
        form:AddLine(id)
    end

    local saveButton = leftPanel:Add("Nexus:V2:Button")
    saveButton:Dock(TOP)
    saveButton:DockMargin(self.margin, self.margin, self.margin, 0)
    saveButton:SetTall(Nexus:Scale(50))
    saveButton:SetText("Add")
    saveButton:SetColor(Nexus:GetColor("green"))
    saveButton.DoClick = function(s)
        func(true, textEntry:GetText())
    end

    return form
end

function PANEL:AddTable(tbl, func)
    local data = Nexus:GetValue(tbl.id)

    local tall = 2 + self.margin*2 + Nexus:Scale(50)
    local row = self:AddRow()
    row:DockPadding(1, 1, 1, 1)
    row.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, w, h, Nexus:GetColor("primary-text"))
        draw.RoundedBox(self.margin, 1, 1, w-2, h-2, Nexus:GetColor("header"))
    end

    local leftPanel = row:Add("Panel")
    leftPanel:Dock(LEFT)
    leftPanel:DockMargin(0, 0, 0, 0)
    leftPanel:SetWide(Nexus:Scale(200))

    local form = row:Add("Nexus:ListView")
    form:Dock(FILL)
    form:DockMargin(0, 0, self.margin, 0)

    local elements = {}
    for k, v in ipairs(tbl.values) do
        form:AddColumn(v.placeholder or "")

        if v.type == "TextEntry" then
            local textEntry = leftPanel:Add("Nexus:V2:TextEntry")
            textEntry:Dock(TOP)
            textEntry:DockMargin(self.margin, self.margin, self.margin, 0)
            textEntry:SetTall(Nexus:Scale(50))
            textEntry:SetPlaceholder(v.placeholder)
            textEntry:SetTooltip(v.placeholder)
            textEntry:SetTooltipDelay(0)
            if v.isNumeric then textEntry:SetNumeric(true) end
            elements[k] = textEntry

            tall = tall + self.margin + Nexus:Scale(50)
        elseif v.type == "CheckBox" then
            local checkBox = leftPanel:Add("Nexus:CheckBox")
            checkBox:Dock(TOP)
            checkBox:DockMargin(self.margin, self.margin, self.margin, 0)
            checkBox:SetText(v.placeholder)
            checkBox:SetTall(Nexus:Scale(35))
            elements[k] = checkBox

            tall = tall + self.margin + Nexus:Scale(35)
        elseif v.type == "ComboBox" then
            local comboBox = leftPanel:Add("Nexus:V2:ComboBox")
            comboBox:Dock(TOP)
            comboBox:DockMargin(self.margin, self.margin, self.margin, 0)
            comboBox:SetText(v.placeholder)
            comboBox:SetTall(Nexus:Scale(50))
            for _, item in ipairs(isfunction(v.values) and v.values() or v.values) do
                comboBox:AddChoice(item)
            end
            elements[k] = comboBox

            tall = tall + self.margin + Nexus:Scale(50)
        end
    end

    for _, args in pairs(data) do
        local packedDATA = {}
        for k, v in ipairs(tbl.values) do
            packedDATA[k] = args[v.id]
        end

        local line = form:AddLine(unpack(packedDATA))
        line["m_id"] = args["m_id"]
        line["oValue"] = args["Chance"]
    end

    local saveButton = leftPanel:Add("Nexus:V2:Button")
    saveButton:Dock(TOP)
    saveButton:DockMargin(self.margin, self.margin, self.margin, 0)
    saveButton:SetTall(Nexus:Scale(50))
    saveButton:SetText("Add")
    saveButton:SetColor(Nexus:GetColor("green"))
    saveButton.DoClick = function(s)
        func(elements)
    end

    row:SetTall(math.max(Nexus:Scale(200), tall))

    return form
end
vgui.Register("Nexus:Config:MenuV2", PANEL, "EditablePanel")