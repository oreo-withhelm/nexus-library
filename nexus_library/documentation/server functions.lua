-- print a chat message
-- tbl = {color_white, "hello there", color_black, " what are you doing!"}
Nexus:ChatMessage(ply, tbl)

-- if you want it to be in the users language and run :GetPhrase(str, addon)
-- make str the key of the language string and addonPhrase as the addon name
Nexus:Notify(ply, notification_type, seconds, str, addonPhrase)