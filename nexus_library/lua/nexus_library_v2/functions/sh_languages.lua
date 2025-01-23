local defaultLanguage = "en" // make sure this exists below of the addon will shit itself

local languages = {}
languages = {
    ["en"] = {
        ["Server Name"] = Nexus.ServerName,
        ["Title"] = "Title",
        ["Search"] = "Search...",
        ["Subheading"] = "Subheading",
    },
    ["fr"] = {
        ["Server Name"] = Nexus.ServerName,
        ["Title"] = "French",
        ["Search"] = "French...",
        ["Subheading"] = "Subheading",
    },
}

local flag = {
    ["en"] = "https://imgur.com/0wjHF5M",
    ["fr"] = "https://imgur.com/gg9IV6m",
}

function Nexus:GetCurFlag()
    local lang = Nexus:GetSetting("nexus_language", defaultLanguage)
    return languages[lang] and flag[lang] or flag[defaultLanguage]
end

function Nexus:GetPhrase(str, addon)
    if addon then
        local data = languages[SERVER and defaultLanguage or Nexus:GetSetting("nexus_language", defaultLanguage)]
        return data and data[addon..str] or languages[defaultLanguage][addon..str]
    end

    local data = languages[SERVER and defaultLanguage or Nexus:GetSetting("nexus_language", defaultLanguage)]
    return data and data[str] or languages[defaultLanguage][str]
end

local addons = {}
function Nexus:AddLanguages(addon, lang, tbl)
    languages[lang] = languages[lang] or {}

    addons[addon] = addons[addon] or {}
    addons[addon][lang] = true

    for i, v in pairs(tbl) do
        languages[lang][addon..i] = v
    end
end

function Nexus:GetLanguages(addon)
    local format = {}
    for lang, _ in pairs(addons[addon]) do
        table.insert(format, lang)
    end
    return format
end