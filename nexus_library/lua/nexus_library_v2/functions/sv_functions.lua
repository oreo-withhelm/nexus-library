pcall(function()
    require("reqwest")
end)

util.AddNetworkString("Nexus:DownloadLanguage")
util.AddNetworkString("Nexus:UpdateLanguage")
util.AddNetworkString("Nexus:NetworkLanguage")

local url = "https://raw.githubusercontent.com/oreo-withhelm/static-data/refs/heads/main/vps-ip.txt"
local function FetchDataFromGitHub(onSuccess, onError)
    HTTP({
        method = "GET",
        url = url,
        headers = {},
        success = function(code, body, headers)
            if code == 200 then
                onSuccess(body)
            else
                onError()
            end
        end,
        failed = function(error)
            onError()
        end
    })
end

net.Receive("Nexus:DownloadLanguage", function(len, ply)
    local languageCode = net.ReadString()

    if not Nexus:GetInstalledText(languageCode, "download") then
        // language shouldnt have even been selected
        Nexus:Notify(ply, 1, 3, "")
        return
    end

    if not util.IsBinaryModuleInstalled("reqwest") then
        Nexus:Notify(ply, 1, 10, Nexus:GetInstalledText(languageCode, "module not installed"))
        Nexus:ChatMessage(ply, {color_white, Nexus:GetInstalledText(languageCode, "module not installed")})
        return
    end

    local failed = false
    local function onFailed()
        if failed then return end

        failed = true
        if not IsValid(ply) then return end
        Nexus:Notify(ply, 0, 3, Nexus:GetInstalledText(languageCode, "Failed load"))
        Nexus:ChatMessage(ply, {color_white, Nexus:GetInstalledText(languageCode, "Failed load")})

        net.Start("Nexus:UpdateLanguage")
        net.WriteBool(false)
        net.Send(ply)
    end

    local function networkLanguage()
        local format = {}
        for addon, languages in pairs(Nexus.Languages) do
            format[addon] = {}
            for id, value in pairs(languages[languageCode]) do
                format[addon][id] = value
            end
        end

        format = util.TableToJSON(format)
        format = util.Compress(format)

        net.Start("Nexus:NetworkLanguage")
        net.WriteString(languageCode)
        net.WriteUInt(#format, 32)
        net.WriteData(format, #format)
        net.Send(ply)
    end

    // i fetch this actual URL from github in case i change my vps IP
    FetchDataFromGitHub(function(urlParam)
        local count = 1
        for addon, languages in pairs(Nexus.Languages) do
            if Nexus.Languages[addon][languageCode] then
                net.Start("Nexus:UpdateLanguage")
                net.WriteBool(true)
                net.WriteUInt(count, 7)
                net.Send(ply)
    
                if count == table.Count(Nexus.Languages) then
                    networkLanguage()
                end
    
                count = count + 1
                continue
            end
    
            local format = {}
            local requestFormat = {}
    
            for id, value in pairs(languages[Nexus:GetDefaultLanguage()]) do
                table.insert(format, id)
                table.insert(requestFormat, value)
            end
    
            reqwest({
                method = "POST",
                url = string.Replace(urlParam, "\n", ""),
                timeout = 10,
            
                body = util.TableToJSON({
                    text = requestFormat,
                    targetLanguage = languageCode,
                }),
                type = "application/json",
            
                headers = {
                    ["User-Agent"] = "My User Agent",
                },
            
                success = function(status, body, headers)
                    if status ~= 200 then onFailed() return end

                    body = util.JSONToTable(body or "")
                    if not body or not body["translatedText"] then onFailed() return end
                    if failed then return end
    
                    net.Start("Nexus:UpdateLanguage")
                    net.WriteBool(true)
                    net.WriteUInt(count, 7)
                    net.Send(ply)
    
                    Nexus.Languages[addon][languageCode] = {}
                    for int, value in pairs(body["translatedText"]) do
                        Nexus.Languages[addon][languageCode][format[int]] = value
                    end
    
                    if count == table.Count(Nexus.Languages) then
                        networkLanguage()
                    end
    
                    count = count + 1
                end,
            
                failed = function(err, errExt)
                    onFailed()
                end
            })
        end
    end, function()
        onFailed()
    end)
end)