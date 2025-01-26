/*

SCALING FUNCTIONS

*/

/*

fetches a colour can be any of the following
"background"
"header"

"primary"
"secondary"
"secondary-2"

"accent"
"orange"

"primary-text"
"secondary-text"

"overlay"
"green"

*/
Nexus:GetColor(str)

/*

a nice way to get consistant margins on code & design changes
can be any of the following:
large, normal, small

*/
Nexus:GetMargin(str)

Nexus:GetScale(number) -- scaling function

Nexus:GetFont({size = 15, dontScale = false, bold = true})


/*

VGUI FUNCTIONS

*/

-- A DMenu alternative
Nexus:DermaMenu({
    "value one",
    "value, two",
}, function(value)
    print(value)
end)

-- a yes/no style popup
-- if yes / no text isnt set it automatically fetches yes/no
-- from their language
Nexus:QueryPopup("text", function()
    print("yes clicked")
end, function()
    print("no clicked")
end, "yes text" (optional), "no text" (optional))

-- Nexus:OffsetColor(Color(150, 150, 150), 50, true)
-- dontAlpha means dont affect the alpha
Nexus:OffsetColor(col, num, dontAlpha)

-- Add an NPC overhead
-- override means override the up position of the panel
Nexus:Overhead(ent, str, override, secondaryStr (optional))

-- draw a rounded gradient
-- * means optional
Nexus:DrawRoundedGradient(x, y, w, h, bgCol, overrideCol*, roundness*, rot*, c1*, c2*, c3*, c4*)

-- download an imgur link
Nexus:GetImgur(id) -- returns a material

-- set color as the background colour behind the text
-- and it will return what colour the text should be
Nexus:GetTextColor(color)

-- get a user settings
Nexus:GetSetting(id, default) -- returns the value set or default

-- set a settings on the user
Nexus:SetSetting(id, value)