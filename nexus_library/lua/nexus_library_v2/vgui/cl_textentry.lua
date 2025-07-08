local PANEL = {}
AccessorFunc(PANEL, "PlaceholderColor", "PlaceholderColor")
function PANEL:Init()
	self:SetTall(Nexus:GetScale(35))
	self.margin = Nexus:Scale(10)

	self:SetPlaceholderColor(Nexus:GetColor("secondary-text"))

	self.TextEntry = self:Add("DTextEntry")
	self.TextEntry:Dock(FILL)
	self.TextEntry:DockMargin(self.margin+2, self.margin+2, self.margin+2, self.margin+2)
	self.TextEntry:SetFont(Nexus:GetFont({size = 15}))
	self.TextEntry.Paint = function(s, w, h)
		local col = Nexus.Colors.Text
		s:DrawTextEntryText(col, col, col)

		if (#s:GetText() == 0) then
			draw.SimpleText(self:GetPlaceholder() or "", s:GetFont(), 2, s:IsMultiline() and self.margin or h / 2, self:GetPlaceholderColor(), self.centerText and 1 or TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	self.TextEntry.OnValueChange = function(s)
		self:OnValueChange(text)
	end
	self.TextEntry.OnChange = function(s)
		self:OnChange()
	end
	self.TextEntry.OnEnter = function(s)
		self:OnEnter()
	end
	self.TextEntry.OnGetFocus = function(s)
		self:OnGetFocus()
	end
	self.TextEntry.OnLoseFocus = function(s)
		self:OnLoseFocus()
	end

	self.TextEntry:SetTooltipDelay(.2)
end

function PANEL:SetPlaceholder(str)
	self.placeholder = str
	if str == "" then
		self.TextEntry:SetTooltip(nil)
		return
	else
		self.TextEntry:SetTooltip(str)
	end
end

function PANEL:GetPlaceholder()
	return self.placeholder
end

function PANEL:OnLoseFocus() end
function PANEL:OnGetFocus() end
function PANEL:OnEnter() end
function PANEL:OnChange() end
function PANEL:SetNumeric(bool) self.TextEntry:SetNumeric(true) end
function PANEL:GetNumeric() return self.TextEntry:GetNumeric() end
function PANEL:OnValueChange() end
function PANEL:GetValue() return self.TextEntry:GetValue() end
function PANEL:SetFont(str)
	self.TextEntry:SetFont(str)
end

function PANEL:GetFont()
	return self.TextEntry:GetFont()
end

function PANEL:GetText()
	return self.TextEntry:GetText()
end

function PANEL:SetText(str)
	str = str or ""
	self.TextEntry:SetText(str)
end

function PANEL:SetMultiLine(state)
	self.TextEntry:SetMultiline(state)
end

function PANEL:OnMousePressed()
	self.TextEntry:RequestFocus()
end

function PANEL:CenterPlaceholder()
	self.centerText = true
end

function PANEL:Paint(w, h)
	draw.RoundedBox(Nexus:GetMargin("normal"), 0, 0, w, h, self.CustomCol or Nexus:GetColor("secondary-2"))
end
vgui.Register("Nexus:V2:TextEntry", PANEL, "EditablePanel")