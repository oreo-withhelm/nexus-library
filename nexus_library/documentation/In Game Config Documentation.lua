-- to make sure your file loads properly create a file in the directory listen below and make it sh_
-- lua/nexus_library/modules/sh_filename.lua

-- retrieves the data of an associated ID
-- returns (could be any data type)
-- Nexus:GetValue(id)

-- sets the value of an associated ID
-- this does not network the value to the client
-- Nexus:SetValue(id, value)

-- start the proccess with this
Nexus.Builder:Start()
    :SetName("Leaderboards") -- the unique name & ID of your addon

    -- just simple text that does nothing else
    :AddLabel({text = "Just a label"})

    -- A row of buttons
    -- https://imgur.com/Ca1XdQE
    :AddButtons({
        id = "nexus-example-buttonRow", -- Unique ID for Nexus:GetValue(id) Nexus:SetValue(id)
        label = "Button Row", -- The title of this element
        defaultValue = 1, -- Default for Nexus:GetValue(id)

        -- true means the result wont network to the client
        -- useful for securing DB details ect
        dontNetwork = false,

        -- Override the button colours to show the currently selected button
        -- that holds the current value
        showSelected = false,

        buttons = {
            // The text inside the button and the value to store with it (string or number)
            // color sets the button colour
            {text = "Button #1", value = 1},
            {text = "Button #2", value = 2, color = Nexus.Colors.Secondary},
            {text = "Button #3", value = 3, color = Nexus.Colors.Green},
            {text = "Long Button #4", value = 4, color = Nexus.Colors.Red},
        },

        /*
        -- buttons can also be a function return to make it dynamic
        buttons = {
            return {
                {text = "Button #1", value = 1},
                {text = "Button #2", value = 2, color = Nexus.Colors.Secondary},
                {text = "Button #3", value = 3, color = Nexus.Colors.Green},
                {text = "Long Button #4", value = 4, color = Nexus.Colors.Red},
            }
        end,

        */

        onChange = function(value) -- serverside called when the value changes
            -- value = 1
            print("Value has been changed", value)
        end,
    })

    -- Just one text entry input
    -- https://imgur.com/8hR36Lc
    :AddTextEntry({
        id = "nexus-example-textEntry", -- Unique ID for Nexus:GetValue(id) Nexus:SetValue(id)
        label = "Text Entry", -- The title of this element
        defaultValue = 100, -- Default for Nexus:GetValue(id)

        -- true means the result wont network to the client
        -- useful for securing DB details ect
        dontNetwork = false,

        placeholder = "Hello", -- The placeholder
        isNumeric = true, -- Make the text entry only accept numeric values

        onChange = function(value) -- serverside called when the value changes
            -- value = 100
            print("Value has been changed", value)
        end,
    })

    -- A row with multiple text entry boxes
    -- https://imgur.com/lxzKbCk
    :AddMultiTextEntry({
        id = "nexus-example-multiTextEntry", -- Unique ID for Nexus:GetValue(id) Nexus:SetValue(id)
        label = "Text Multi Entry", -- The title of this element

        -- true means the result wont network to the client
        -- useful for securing DB details ect
        dontNetwork = true,

        entries = {
            -- The ID will become the key for the table
            -- {id = "key", default = (string or number), placeholder = "", isNumeric = false}
            {id = "username", default = "a", placeholder = "username", isNumeric = false},
            {id = "password", default = "b", placeholder = "password", isNumeric = false},
        },

        onChange = function(value) -- serverside called when the value changes
            -- ["username"] = "a"
            -- ["password"] = "b"

            print("Value has been changed")
            PrintTable(value)
        end,
    })

    -- An advanced in game table maker
    -- It can also be turned into a percentage table
    -- https://imgur.com/sIGmoJk
    :AddTable({
        id = "nexus-example-table", -- Unique ID for Nexus:GetValue(id) Nexus:SetValue(id)
        label = "Text Multi Entry", -- The title of this element
        defaultValue = {}, -- Just dont touch unless you really *really* know what your doing

        -- true means the result wont network to the client
        -- useful for securing DB details ect
        dontNetwork = false,
        
        -- ["Chance"] key into the data
        -- chance = weight so it can add up to above or lower than 100
        isPercentage = false,

        // The different types of inputs you can have
        values = {
            -- The ID will become the key for the table
            --{id = "key", type = ("TextEntry", "CheckBox" or "ComboBox"), placeholder = "", isNumeric = false (for TextEntry only)},
            {id = "WeaponName", type = "TextEntry", placeholder = "WeaponName", isNumeric = false},
            {id = "Price", type = "TextEntry", placeholder = "Price", isNumeric = true},
            {id = "IsEnabled", type = "CheckBox", placeholder = "Weapon Class"},
            {id = "WeaponType", type = "ComboBox", placeholder = "Weapon Type", values = {"AR", "SMG"}},
            {id = "Location", type = "ComboBox", placeholder = "Location", values = function() return {"UK", "America"} end}, -- to have a dynamic result
        },

        onChange = function(value) -- serverside called when the value changes
            print("Value has been changed")
            PrintTable(value)
            /*

            [1]:
                    ["WeaponName"]	=	"AK 47"
                    ["Price"]	=	10000
                    ["IsEnabled"]	=	true
                    ["WeaponType"] = "AR"
                    ["Location"] = "America"
            [2]:
                    ["WeaponName"]	=	"SCAR"
                    ["Price"]	=	80000
                    ["IsEnabled"]	=	false
                    ["WeaponType"] = "AR"
                    ["Location"] = "UK"

            */
        
            /*
            An example if isPercentage is set to true
            [1]:
                    ["WeaponName"]	=	"AK 47"
                    ["Price"]	=	10000
                    ["IsEnabled"]	=	true
                    ["WeaponType"] = "AR"
                    ["Location"] = "America"
                    ["Chance"] = 20 -- auto inputted & acts more like a weight
            [2]:
                    ["WeaponName"]	=	"SCAR"
                    ["Price"]	=	80000
                    ["IsEnabled"]	=	false
                    ["WeaponType"] = "AR"
                    ["Location"] = "UK"
                    ["Chance"] = 10
            */
        end,
    })

    -- A key = value formated table
    -- more suited for admin ranks, chat command inputs
    -- https://imgur.com/zWrqcKB
    :AddKeyTable({
        id = "nexus-example-chatCommands", -- Unique ID for Nexus:GetValue(id) Nexus:SetValue(id)
        label = "Text Multi Entry", -- The title of this element

        -- true means the result wont network to the client
        -- useful for securing DB details ect
        dontNetwork = false,

        -- Default for Nexus:GetValue(id)
        -- returns a key = value formatted table
        defaultValue = {
            ["superadmin"] = true,
            ["admin"] = true,
        },

        placeholder = "Suit Name", -- The placeholder
        isNumeric = false, -- Make the text entry only accept numeric values

        onChange = function(value) -- serverside called when the value changes
            print("Value has been changed")
            PrintTable(value)

            /*
                ["superadmin"] = true,
                ["admin"] = true,
            */
        end,
    })
:End() -- always end with this
