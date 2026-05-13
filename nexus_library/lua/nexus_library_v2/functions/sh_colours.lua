local themes = {}
themes["Default"] = {
    ["background"] = Color(2, 6, 24), // Background of the frame
    ["primary"] = Color(131, 156, 245), // Primary elements like buttons

    ["background-secondary-text"] = Color(17, 15, 27, 120), // 
    ["background-text"] = Color(2, 6, 24), // Dark Text (to go on light backgrounds) 
    ["primary-text"] = Color(255, 255, 255, 201), // Light Text (to go on top background / primary / secondary)
    ["secondary-text"] = Color(255, 255, 255, 84), // Light Text (to go on top background / primary / secondary) that should be used to showcase less important information

    ["secondary"] = Color(2+25, 6+25, 24+25), // Secondary elements like secondary buttons / Frames that sit on top of the background
    ["secondary-2"] = Color(2+50, 6+50, 24+50), // Tertiary elements like scroll panels / Frames that sit on top of secondary elements

    ["header"] = Color(38, 38, 38, 255), // never used anymore but kept for compatibility

    ["accent"] = Color(172, 16, 55, 255), // Accent colours used for frame highlights

    ["orange"] = Color(235, 129, 22, 255),
    ["overlay"] = Color(200, 200, 200, 20), // Overlay colour for hover effects
    ["highlight"] = Color(255, 255, 255, 50), // Overlay colour for active effects
    ["red"] = Color(235, 94, 94, 255),
    ["blue"] = Color(92, 173, 255, 255),
    ["green"] = Color(91, 204, 147, 255),
}

themes["Dracula"] = {
    ["background"] = Color(40, 42, 54),
    ["primary"] = Color(189, 147, 249), -- Purple

    ["background-secondary-text"] = Color(40, 42, 54, 120),
    ["background-text"] = Color(40, 42, 54),
    ["primary-text"] = Color(248, 248, 242, 230), -- Light Text
    ["secondary-text"] = Color(248, 248, 242, 120), -- Light Text (Dimmed)

    ["secondary"] = Color(68, 71, 90),
    ["secondary-2"] = Color(98, 114, 164),

    ["header"] = Color(50, 52, 65, 255),

    ["accent"] = Color(255, 121, 198, 255),
    ["orange"] = Color(255, 184, 108, 255),

    ["overlay"] = Color(189, 147, 249, 20),
    ["highlight"] = Color(255, 255, 255, 40),

    ["red"] = Color(255, 85, 85, 255),
    ["blue"] = Color(139, 233, 253, 255),
    ["green"] = Color(80, 250, 123, 255),
}

themes["Abyss"] = {
    ["background"] = Color(10, 15, 20),
    ["primary"] = Color(0, 190, 200), -- Teal

    ["background-secondary-text"] = Color(15, 25, 35, 120),
    ["background-text"] = Color(10, 15, 20),
    ["primary-text"] = Color(240, 255, 255, 230), -- Light Text
    ["secondary-text"] = Color(100, 200, 200, 100), -- Light Text (Dimmed)

    ["secondary"] = Color(25, 35, 45),
    ["secondary-2"] = Color(40, 55, 70),

    ["header"] = Color(15, 20, 25, 255),

    ["accent"] = Color(0, 120, 180, 255),
    ["orange"] = Color(255, 160, 50, 255),

    ["overlay"] = Color(0, 255, 255, 15),
    ["highlight"] = Color(255, 255, 255, 30),

    ["red"] = Color(230, 60, 60, 255),
    ["blue"] = Color(60, 160, 255, 255),
    ["green"] = Color(60, 230, 150, 255),
}

themes["Synthwave"] = {
    ["background"] = Color(20, 10, 30),
    ["primary"] = Color(255, 0, 120), -- Hot Pink

    ["background-secondary-text"] = Color(45, 20, 50, 120),
    ["background-text"] = Color(20, 10, 30),
    ["primary-text"] = Color(255, 230, 255, 240), -- Light Text
    ["secondary-text"] = Color(200, 100, 200, 120), -- Light Text (Dimmed)

    ["secondary"] = Color(45, 25, 60),
    ["secondary-2"] = Color(70, 40, 90),

    ["header"] = Color(35, 15, 45, 255),

    ["accent"] = Color(0, 255, 255, 255),
    ["orange"] = Color(255, 150, 50, 255),

    ["overlay"] = Color(255, 0, 120, 15),
    ["highlight"] = Color(255, 255, 255, 50),

    ["red"] = Color(255, 50, 80, 255),
    ["blue"] = Color(80, 200, 255, 255),
    ["green"] = Color(50, 255, 150, 255),
}

themes["Gold"] = {
    ["background"] = Color(12, 12, 12),
    ["primary"] = Color(218, 165, 32), -- Gold

    ["background-secondary-text"] = Color(30, 30, 30, 120),
    ["background-text"] = Color(12, 12, 12),
    ["primary-text"] = Color(255, 255, 255, 230), -- Light Text
    ["secondary-text"] = Color(218, 165, 32, 100), -- Light Text (Dimmed)

    ["secondary"] = Color(30, 30, 30),
    ["secondary-2"] = Color(50, 50, 50),

    ["header"] = Color(20, 20, 20, 255),

    ["accent"] = Color(255, 215, 0, 255),
    ["orange"] = Color(200, 100, 20, 255),

    ["overlay"] = Color(255, 215, 0, 10),
    ["highlight"] = Color(255, 255, 255, 20),

    ["red"] = Color(200, 60, 60, 255),
    ["blue"] = Color(80, 120, 200, 255),
    ["green"] = Color(100, 180, 100, 255),
}

themes["Polar"] = {
    ["background"] = Color(245, 247, 250), -- Very Light Grey (White-ish)
    ["primary"] = Color(100, 200, 255),    -- Light Blue (Bright enough for dark text)

    ["background-secondary-text"] = Color(200, 200, 200, 120),
    
    -- NOTE: Swapped for Light Theme visibility
    ["background-text"] = Color(30, 32, 35, 255), -- Dark Text (Used by GetTextColor on light bg)
    ["primary-text"] = Color(30, 32, 35, 230),    -- Dark Text (Visible on Light Background)
    ["secondary-text"] = Color(60, 65, 70, 150),  -- Dark Text (Dimmed)

    ["secondary"] = Color(255-75, 255-75, 255-75), -- Pure White (Cards)
    ["secondary-2"] = Color(255-100, 255-100, 255-100), -- Grey (Input fields/borders)

    ["header"] = Color(255, 255, 255, 255),

    ["accent"] = Color(45, 100, 220, 255),
    ["orange"] = Color(230, 120, 20, 255),

    ["overlay"] = Color(45, 100, 220, 10),
    ["highlight"] = Color(0, 0, 0, 10), -- Dark highlight for light mode

    ["red"] = Color(220, 60, 60, 255),
    ["blue"] = Color(50, 120, 240, 255),
    ["green"] = Color(40, 180, 100, 255),
}

local additions = {}
for themeID, theme in pairs(themes) do
    local tbl = table.Copy(theme)
    tbl["background"].a = tbl["background"].a * .65
    tbl["primary"].a = tbl["primary"].a * .65

    tbl["secondary"].a = tbl["secondary"].a * .65
    tbl["secondary-2"].a = tbl["secondary-2"].a * .65

    tbl["header"].a = tbl["header"].a * .65
    tbl["accent"].a = tbl["accent"].a * .65
    tbl["orange"].a = tbl["orange"].a * .65

    tbl["red"].a = tbl["red"].a * .65
    tbl["blue"].a = tbl["blue"].a * .65
    tbl["green"].a = tbl["green"].a * .65

    table.insert(additions, {themeID.." Blur", tbl})
end

for _, data in pairs(additions) do
    themes[data[1]] = data[2]
end

function Nexus:GetThemes()
    return themes
end

function Nexus:GetColor(str)
    if CLIENT then
        local value = Nexus:GetSetting("nexus_theme") or Nexus:GetValue("nexus-forcetheme", "nexus_lib") or "Default"
        if Nexus:GetSetting("nexus_theme_blur", "false") == "true" then
            value = value.." Blur"
        end
        return themes[value] and themes[value][str] or themes["Default"][str]
    end

    return themes["Default"][str]
end