local PANEL = {}
function PANEL:Init()
	self.VBar:SetHideButtons(true)
	self.VBar:SetWide(Nexus:GetMargin("small"))

	self.VBar.Paint = function(s, w, h)
		Nexus.RDNX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("header"), nil, true)
	end

	self.VBar.btnGrip.Paint = function(s, w, h)
		Nexus.RDNX.Draw(Nexus:GetMargin("small"), 0, 0, w, h, Nexus:GetColor("primary-text"), nil, true)
	end

	local old = self:GetCanvas().PerformLayout
	self:GetCanvas().PerformLayout = function(s, w, h)
		old(s, w, h)
		self:AfterPerformLayout(w, h)
	end
end

function PANEL:AfterPerformLayout(w, h)
end
vgui.Register("Nexus:V2:ScrollPanel", PANEL, "DScrollPanel")