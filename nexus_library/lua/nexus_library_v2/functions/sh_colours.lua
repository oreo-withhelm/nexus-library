//secondary and secondary-2 act like background-1 background-2 they sit on stop of background
local themes = {}
themes["Default"] = {
    ["background"] = Color(17, 15, 27, 255),
    ["primary"] = Color(194, 118, 209, 255),

    ["background-secondary-text"] = Color(17, 15, 27, 120),
    ["background-text"] = Color(17, 15, 27, 255),
    ["primary-text"] = Color(255, 255, 255, 201),
    ["secondary-text"] = Color(255, 255, 255, 84),

    ["secondary"] = Color(38, 36, 51, 255),
    ["secondary-2"] = Color(60, 58, 78, 255),

    ["header"] = Color(38, 38, 38, 255),

    ["accent"] = Color(172, 16, 55, 255),
    ["orange"] = Color(235, 129, 22, 255),

    ["overlay"] = Color(200, 200, 200, 20),
    ["highlight"] = Color(255, 255, 255, 50),
    ["red"] = Color(235, 94, 94, 255),
    ["blue"] = Color(92, 173, 255, 255),
    ["green"] = Color(91, 204, 147, 255),
}

themes["Halloween"] = {
    ["background"] = Color(15, 10, 20, 255),
    ["primary"] = Color(255, 128, 0, 255),

    ["background-secondary-text"] = Color(17, 15, 27, 120),
    ["background-text"] = Color(15, 10, 20, 255),
    ["primary-text"] = Color(255, 239, 200, 255),
    ["secondary-text"] = Color(255, 239, 200, 120),

    ["secondary"] = Color(35, 25, 45, 255),
    ["secondary-2"] = Color(55, 40, 70, 255),

    ["header"] = Color(40, 30, 50, 255),

    ["accent"] = Color(150, 40, 150, 255),
    ["orange"] = Color(255, 128, 0, 255),

    ["overlay"] = Color(255, 165, 0, 15),
    ["highlight"] = Color(255, 255, 255, 40),

    ["red"] = Color(220, 50, 50, 255),
    ["blue"] = Color(120, 100, 255, 255),
    ["green"] = Color(120, 255, 150, 255),
}

themes["Green"] = {
    ["background"] = Color(10, 20, 15, 255),
    ["primary"] = Color(30, 150, 60, 255),

    ["background-secondary-text"] = Color(17, 15, 27, 120),
    ["background-text"] = Color(10, 20, 15, 255),
    ["primary-text"] = Color(255, 255, 255, 220),
    ["secondary-text"] = Color(255, 255, 255, 100),

    ["secondary"] = Color(25, 45, 35, 255),
    ["secondary-2"] = Color(40, 65, 55, 255),

    ["header"] = Color(35, 50, 40, 255),

    ["accent"] = Color(30, 150, 60, 255),
    ["orange"] = Color(255, 215, 120, 255),

    ["overlay"] = Color(255, 255, 255, 15),
    ["highlight"] = Color(255, 255, 255, 50),

    ["red"] = Color(200, 20, 20, 255),
    ["blue"] = Color(100, 180, 255, 255),
    ["green"] = Color(50, 200, 100, 255),
}

themes["Neon"] = {
    ["background"] = Color(5, 5, 10, 255),
    ["primary"] = Color(0, 255, 200, 255),

    ["background-secondary-text"] = Color(17, 15, 27, 120),
    ["background-text"] = Color(5, 5, 10, 255),
    ["primary-text"] = Color(255, 255, 255, 230),
    ["secondary-text"] = Color(255, 255, 255, 100),

    ["secondary"] = Color(20, 20, 40, 255),
    ["secondary-2"] = Color(35, 35, 60, 255),

    ["header"] = Color(15, 15, 25, 255),
    ["accent"] = Color(255, 0, 150, 255),
    ["orange"] = Color(255, 140, 0, 255),

    ["overlay"] = Color(0, 255, 200, 15),
    ["highlight"] = Color(255, 255, 255, 40),

    ["red"] = Color(255, 80, 80, 255),
    ["blue"] = Color(80, 160, 255, 255),
    ["green"] = Color(80, 255, 150, 255),
}

local additions = {}
for themeID, theme in pairs(themes) do
    local tbl = table.Copy(theme)
    tbl["background"].a = 160
    tbl["primary"].a = 160

    tbl["secondary"].a = 160
    tbl["secondary-2"].a = 160

    tbl["header"].a = 160
    tbl["accent"].a = 160
    tbl["orange"].a = 160

    tbl["red"].a = 160
    tbl["blue"].a = 160
    tbl["green"].a = 160

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
        local value = Nexus:GetSetting("nexus_theme") or Nexus:GetValue("nexus-forcetheme", "nexus_lib")
        return themes[value] and themes[value][str] or themes["Default"][str]
    end

    return themes["Default"][str]
end