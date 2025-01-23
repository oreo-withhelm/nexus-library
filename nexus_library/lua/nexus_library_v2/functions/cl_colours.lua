local colors = {
    ["background"] = Color(28, 28, 28, 255),
    ["header"] = Color(38, 38, 38, 255),

    ["primary"] = Color(243, 73, 115),
    ["secondary"] = Color(51, 51, 51, 255),
    ["secondary-2"] = Color(64, 64, 64, 255),

    ["accent"] = Color(172, 16, 55, 255),
    ["orange"] = Color(235, 129, 22, 255),

    ["primary-text"] = Color(194, 194, 194),
    ["secondary-text"] = Color(129, 129, 129),

    ["overlay"] = Color(200, 200, 200, 20)
}

function Nexus:GetColor(str)
    return colors[str]
end