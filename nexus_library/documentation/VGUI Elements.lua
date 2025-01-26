-- i highly recommened you look at the methods in the functions doc to maximise the addons potential
-- Nexus:GetColor
-- Nexus:GetMargin
-- Nexus:GetPhrase

/*

"DFrame" -> "Nexus:V2:Frame"

-- adds a nice button that could be used as a store link for example with an icon
-- 3:1 aspect ratio
:SetBarIcon("imgurID", "Title", "Subheading", function()
    -- on clicked
end)

-- adds a button on the language bar
:AddHeaderButton("imgurID", function()
    -- on clicked
end)

:HideHeaderButton() -- Hide the language button
:SetTitle(title)
:SetLogo(logo)
:SelectContent(str) -- can be used to quickly :Dock(FILL) the space with a panel
PANEL:OnRefresh() -- called when the language changes
    self:Remove()
    ReOpenFrame()
end

*/


/*

"DButton" -> "Nexus:V2:Button"

Features all methods from DButton and

:SetIcon("imgurID")
:SetColor(Color(0, 0, 0))
:SetSecondary() -- make the button a secondary colour

-- automatically set the width of the button
-- extras = number, how much padding the text should get
:AutoWide(extras)

*/


/*

"DScrollPanel" -> "Nexus:V2:ScrollPanel"

&

"Nexus:V2:HorizontalScrollPanel"

-- Nexus:V2:ScrollPanel but horizontal
panel:GetCanvas() -- this method can be used here

*/


/*

"Nexus:V2:Navbar" - A navbar that side horizontally

-- Add an item to the navbar
-- if id isnt set then it will autoincrement 1, 2, 3 ect
:AddItem("text", function()
    -- when the values clicked
end, "imgurIcon" (not required), id (not required))

:SelectItem(id)

*/

/*

"Nexus:V2:Sidebar"

-- Add an item to the sidebar
-- if id isnt set then it will autoincrement 1, 2, 3 ect
:AddItem("text", function()
    -- when the values clicked
end, "imgurIcon" (not required), id (not required))

:SelectItem(id)

-- in case you want to round the corners
-- abit random ik but its useful if you want to apply it with no margin to the :Frame
:SetMask({true, true, true, true})

*/


/*

"DTextEntry" -> "Nexus:V2:TextEntry"

:SetPlaceholder(str)
:GetPlaceholder()

:SetNumeric(bool)
:GetNumeric()

:SetText(str)
:GetValue() & :GetText() -- does same thing

:SetFont(str)
:GetFont()

:SetMultiLine(bool)
:CenterPlaceholder() -- should we center the placeholder

PANEL:OnLoseFocus() end
PANEL:OnGetFocus() end
PANEL:OnEnter() end
PANEL:OnChange() end
PANEL:OnValueChange() end
*/


/*

"DComboBox" -> "Nexus:V2:ComboBox"

:SetValue(str) -- set the text in the comboBox
:GetValue()
:SetDontSort(bool) -- dont sort by alphabet
:OnSelect(index, value)
:AddChoice(value, function()
    -- whats happens when the option is clicked
    -- this is a substitute for the data store on regular ComboBox
end)
:AutoWide()

*/