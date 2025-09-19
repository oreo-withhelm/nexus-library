local PANEL = {}
function PANEL:Init()
	self.margin = Nexus:Scale(10)

	self.VBar:SetHideButtons(true)
	self.VBar:SetWide(Nexus:Scale(12))

	local col = table.Copy(Nexus:GetColor("secondary"))
	col.a = 100
	self.VBar.Paint = function(s, w, h)
		draw.RoundedBox(self.margin, 0, 0, w, h, col)
	end

	self.VBar.btnGrip.Paint = function(s, w, h)
		Nexus:DrawRoundedGradient(0, 0, w, h, Nexus:GetColor("primary"))
	end

	local old = self:GetCanvas().PerformLayout
	self:GetCanvas().PerformLayout = function(s, w, h)
		old(s, w, h)
		self:AfterPerformLayout(w, h)
	end
end

function PANEL:AfterPerformLayout(w, h)
end
vgui.Register("Nexus:ScrollPanel", PANEL, "DScrollPanel")