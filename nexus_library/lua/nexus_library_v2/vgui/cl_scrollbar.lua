local PANEL = {}
function PANEL:Init()
	self.VBar:SetHideButtons(true)
	self.VBar:SetWide(Nexus:GetMargin("small"))

	self.VBar.Paint = function(s, w, h)
		draw.RoundedBox(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("header"))
	end

	self.VBar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("primary-text"))
	end
end
vgui.Register("Nexus:V2:ScrollPanel", PANEL, "DScrollPanel")