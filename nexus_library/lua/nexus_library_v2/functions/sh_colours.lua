local colors = {
    ["background"] = Color(4, 4, 4),
    ["primary"] = Color(194, 118, 209),
    ["green"] = Color(62, 197, 138),
    ["secondary-text"] = Color(129, 129, 129),
    ["primary-text"] = Color(230, 230, 230),
    ["secondary"] = Color(35, 35, 35, 255),
    ["secondary-2"] = Color(50, 50, 50, 255),

    ["header"] = Color(38, 38, 38, 255),

    ["accent"] = Color(172, 16, 55, 255),
    ["orange"] = Color(235, 129, 22, 255),

    ["overlay"] = Color(200, 200, 200, 20),
    ["highlight"] = Color(255, 255, 255, 50),
    ["red"] = Color(192, 27, 27),
    ["blue"] = Color(100, 206, 255)
}

function Nexus:GetColor(str)
    return colors[str]
end