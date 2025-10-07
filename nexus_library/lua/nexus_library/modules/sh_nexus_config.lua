Nexus:AddLanguages("nexus_lib", "en", {
    ["Selected All"] = "Selected All",
    ["Reset"] = "Reset",
    ["Search"] = "Search",
    ["Insert"] = "Insert",
    ["Yes"] = "Yes",
    ["No"] = "No",
})

Nexus.Builder:Start()
    :SetName("Nexus Core")

    :AddKeyTable({
        id = "nexus-config-admins",
        dontNetwork = false,
        defaultValue = {
            ["superadmin"] = true,
        },

        label = "Ranks that can edit nexus_config values",

        placeholder = "Usergroup",
        isNumeric = false,

        onChange = function(value) end,
    })

    :AddTextEntry({
        id = "nexus-logo",
        label = "Logo",
        defaultValue = "https://imgur.com/KD3QMpr",

        placeholder = "https://imgur.com/KD3QMpr",
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
:End()