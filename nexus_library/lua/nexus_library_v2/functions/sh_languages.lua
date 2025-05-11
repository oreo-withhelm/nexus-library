local defaultLanguage = "en" // make sure every addon natively supports this or the addon will shit itself

Nexus.Languages = Nexus.Languages or {
    ["Nexus Library"] = {
        ["en"] = {
            ["Server Name"] = Nexus.ServerName,
            ["Title"] = "Title",
            ["Search"] = "Search...",
            ["Subheading"] = "Subheading",
            ["Popup"] = "Popup",
            ["No"] = "No",
            ["Yes"] = "Yes",
            ["Loading Language"] = "You are already loading a language!",
            ["Config"] = "Config",
        },
    }
}

local requiredText = {
    ["en"] = {
        ["download"] = "This addon does not natively support the '%s' language is it okay to load it from Google Translate?",
        ["module not installed"] = "This server does not support language downloading please tell the owner to install gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Yes",
        ["no"] = "No",
        ["Failed load"] = "Failed to load language retry",
        ["Loading Language Package"] = "Loading Language Package %s/%s",
    },
    ["fr"] = {
        ["download"] = "Ce plugin ne prend pas en charge nativement la langue '%s', est-il possible de la charger depuis Google Translate ?",
        ["module not installed"] = "Ce serveur ne prend pas en charge le téléchargement des langues, veuillez demander au propriétaire d'installer gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Oui",
        ["no"] = "Non",
        ["Failed load"] = "Échec du chargement de la langue, réessayez",
        ["Loading Language Package"] = "Chargement du paquet de langue %s/%s",        
    },
    ["tr"] = {
        ["download"] = "Bu eklenti '%s' dilini yerel olarak desteklemiyor, Google Translate üzerinden yüklenmesi uygun mu?",
        ["module not installed"] = "Bu sunucu dil indirmeyi desteklemiyor, lütfen sahibine gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest) kurmasını söyleyin",
        ["yes"] = "Evet",
        ["no"] = "Hayır",
        ["Failed load"] = "Dil yüklenemedi, lütfen tekrar deneyin",
        ["Loading Language Package"] = "Dil Paketi Yükleniyor %s/%s",        
    },
    ["uk"] = {
        ["download"] = "Цей аддон не підтримує мову '%s' нативно, чи можна завантажити її через Google Translate?",
        ["module not installed"] = "Цей сервер не підтримує завантаження мов, будь ласка, скажіть власнику, щоб встановив gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Так",
        ["no"] = "Ні",
        ["Failed load"] = "Не вдалося завантажити мову, спробуйте ще раз",
        ["Loading Language Package"] = "Завантаження мовного пакету %s/%s",
    },    
    ["es"] = {
        ["download"] = "Este complemento no soporta nativamente el idioma '%s', ¿está bien cargarlo desde Google Translate?",
        ["module not installed"] = "Este servidor no soporta la descarga de idiomas, por favor dile al dueño que instale gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Sí",
        ["no"] = "No",
        ["Failed load"] = "Error al cargar el idioma, intenta de nuevo",
        ["Loading Language Package"] = "Cargando paquete de idioma %s/%s",        
    },
    ["pl"] = {
        ["download"] = "Ten dodatek nie obsługuje natywnie języka '%s', czy można załadować go z Google Translate?",
        ["module not installed"] = "Ten serwer nie obsługuje pobierania języków, proszę powiedzieć właścicielowi, aby zainstalował gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Tak",
        ["no"] = "Nie",
        ["Failed load"] = "Nie udało się załadować, spróbuj ponownie",
        ["Loading Language Package"] = "Ładowanie pakietu językowego %s/%s",
    },
    ["de"] = {
        ["download"] = "Dieses Addon unterstützt die Sprache '%s' nicht nativ. Ist es in Ordnung, sie von Google Translate zu laden?",
        ["module not installed"] = "Dieser Server unterstützt das Herunterladen von Sprachen nicht. Bitte teilen Sie dem Besitzer mit, dass er gmsv_reqwest installieren soll (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Ja",
        ["no"] = "Nein",
        ["Failed load"] = "Fehler beim Laden der Sprache. Bitte versuchen Sie es erneut.",
        ["Loading Language Package"] = "Lade Sprachpaket %s/%s",
    },
    ["zh"] = {
        ["download"] = "此插件不原生支持 '%s' 语言，是否可以从 Google Translate 加载它？",
        ["module not installed"] = "此服务器不支持语言下载，请告诉管理员安装 gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "是",
        ["no"] = "否",
        ["Failed load"] = "加载语言失败，请重试",
        ["Loading Language Package"] = "加载语言包 %s/%s",        
    },
    ["ru"] = {
        ["download"] = "Этот аддон не поддерживает язык '%s' нативно, можно ли загрузить его с помощью Google Translate?",
        ["module not installed"] = "Этот сервер не поддерживает загрузку языков, пожалуйста, скажите владельцу установить gmsv_reqwest (github.com/WilliamVenner/gmsv_reqwest)",
        ["yes"] = "Да",
        ["no"] = "Нет",
        ["Failed load"] = "Не удалось загрузить язык, попробуйте снова",
        ["Loading Language Package"] = "Загрузка языкового пакета %s/%s",        
    },
}

function Nexus:GetInstalledText(lang, str)
    return requiredText[lang] and requiredText[lang][str] or false
end

local flag = {
    ["en"] = "https://imgur.com/0wjHF5M",
    ["fr"] = "https://imgur.com/gg9IV6m",
    ["zh"] = "https://imgur.com/SZDpdgm",
    ["tr"] = "https://imgur.com/K0vpWKB",
    ["uk"] = "https://imgur.com/ut2b07U",
    ["es"] = "https://imgur.com/kHOv49T",
    ["pl"] = "https://imgur.com/YM182Ct",
    ["de"] = "https://imgur.com/szfxnck",
    ["ru"] = "https://imgur.com/ncDNWcr",
}

function Nexus:GetCurFlag()
    local lang = Nexus:GetSetting("nexus_language", defaultLanguage)
    return flag[lang]
end

function Nexus:IsLanguageLoaded(lang)
    for addon, languages in pairs(Nexus.Languages) do
        if not languages[lang] then
            return false
        end
    end

    return true
end

function Nexus:GetPhrase(str, addon, ply)
    addon = addon or "Nexus Library"

    str = string.gsub(str, "％s", "%%s")

    local lang = defaultLanguage
    if SERVER and (ply and IsValid(ply)) then
        lang = ply.NexusLanguage or lang
    elseif CLIENT then
        local localLang = Nexus:GetSetting("nexus_language", defaultLanguage)
        if Nexus.Languages[addon][lang] and Nexus.Languages[addon][lang][str] then
            lang = localLang
        end
    end

    local data = string.gsub(Nexus.Languages[addon][lang][str], "％s", "%%s")
    return data
end

function Nexus:GetRawPhrase(str, addon, lang)
    lang = lang or defaultLanguage
    return Nexus.Languages[addon][lang][str]
end

function Nexus:AddLanguages(addon, lang, tbl)
    Nexus.Languages[addon] = Nexus.Languages[addon] or {}
    Nexus.Languages[addon][lang] = Nexus.Languages[addon][lang] or {}

    for id, str in pairs(tbl) do
        Nexus.Languages[addon][lang][id] = str
    end
end

function Nexus:GetLanguages(addon)
    if not addon then
        local format = {} 
        for lang, _ in pairs(flag) do
            table.insert(format, lang)
        end
        return format
    end

    local format = {}
    for lang1, _ in pairs(Nexus.Languages[addon]) do
        table.insert(format, lang)
    end

    return format
end

function Nexus:GetDefaultLanguage()
    return defaultLanguage
end