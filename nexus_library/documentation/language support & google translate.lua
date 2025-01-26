/*

SERVER & CLIENT (Shared)

*/
Nexus:IsLanguageLoaded(lang) -- true : false is the language loaded

Nexus:GetRawPhrase(str, addon, lang) -- returns the text of an addon in a specific language

/*

adds a addons language into the 'database'

ALWAYS MAKE YOUR ADDON SUPPORT ENGLISH "en" SO THAT USERS CAN AUTO TRANSLATE
USING THE GOOGLE TRANLSATE PACKAGE BUILDER

Nexus:AddLanguages("weapons shop", "en", {
    ["Hello"] = "Hello",
    ["Open"] = "Would you like to open the menu"
})

then you can call
Nexus:GetPhrase("Open", "weapons shop")

obviously its better to natively support as many addons as you can because google translate isnt perfect

*/
Nexus:AddLanguages(addon, lang, tbl)

-- get the languages currently loaded into an addon
Nexus:GetLanguages(addon)

/*

CLIENT

*/
Nexus:GetPhrase(str, addon) -- returns the text of an addon from the players currently selected language
Nexus:GetCurFlag() -- returns the imgur link of the current selected flag language

-- you should never call this as the user does it themself 
-- but just in case you want to precache some language for some reason
Nexus:LoadLanguage(lang, callback)