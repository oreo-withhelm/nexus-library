Nexus:AddLanguages("nexus_lib", "en", {
    ["Selected All"] = "Selected All",
    ["Reset"] = "Reset",
    ["Search"] = "Search",
    ["Insert"] = "Insert",
    ["Yes"] = "Yes",
    ["No"] = "No",
    ["Ok"] = "Ok",
    ["Default Theme"] = "Default theme for Nexus UI",
    ["Edit Ranks"] = "Usergroups that have access to the Nexus Admin Panel.",

    ["Thin"] = "Thin Header",
    ["Default"] = "Default Header",
})

Nexus.Builder:Start()
    :SetName("Nexus Core")

    :AddKeyTable({
        id = "nexus-config-admins",
        dontNetwork = false,
        defaultValue = {
            ["superadmin"] = true,
        },

        label = {"Edit Ranks", "nexus_lib"},

        placeholder = "Usergroup",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-logo",
        label = "Logo (1590x500)",
        defaultValue = "https://imgur.com/KD3QMpr",

        placeholder = "https://imgur.com/KD3QMpr",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-link",
        label = "Link",
        defaultValue = "https://www.gmodstore.com/teams/V06g5EAhRaGpHvVnXz5HvA/products",

        placeholder = "https://www.gmodstore.com/teams/V06g5EAhRaGpHvVnXz5HvA/products",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-title",
        label = "Title",
        defaultValue = "Nexus Addons",

        placeholder = "Nexus Addons",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddButtons({
        id = "nexus-forcetheme",
        showSelected = true,
        defaultValue = "Default",

        label = {"Default Theme", "nexus_lib"},
        buttons = function()
            local tbl = {}
            for id, theme in pairs(Nexus:GetThemes()) do
                table.insert(tbl, {text = id, value = id})
            end
            return tbl
        end,

        onChange = function(value, ply)

        end,
    })
:End()