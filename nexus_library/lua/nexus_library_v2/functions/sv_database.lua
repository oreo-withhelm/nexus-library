local id = 0

local SQL = {}
SQL.ToProcess = {}
function SQL:Init(addonName, data, callback)
    callback = callback or function() end

    self.id = id
    id = id + 1

    data.queries = data.queries or {}
    for _, v in ipairs(data.queries) do
        self:Query(v)
    end

    callback()
end

local function GetLastID()
    local data = sql.Query("SELECT last_insert_rowid() AS id")
    return tonumber(data and data[1].id or -1)
end

function SQL:Query(str, callback)
    callback = callback or function() end

    if istable(str) then
        local data = str
        local rawQuery = data[1]
        table.remove(data, 1)

        local values = {}
        for _, v in ipairs(data) do
            table.insert(values, isstring(v) and sql.SQLStr(v) or v)
        end

        str = string.format(rawQuery, unpack(values))
    else
        str = string.Replace(str, "%auto_increment%", "AUTOINCREMENT")
    end
    
    local data = sql.Query(str)
    callback(data, GetLastID())
end

function SQL:StartTransaction()
end

function SQL:AddTransaction(query)
    self:Query(query, function() end)
end

function SQL:EndTransaction(callback)
    callback()
end

function SQL:Disconnect()
end

local MySQL = {}
MySQL.ToProcess = {}
function MySQL:Init(addonName, data, callback)
    callback = callback or function() end

    data = data or {}
    data.login = data.login or {}
    data.queries = data.queries or {}

    local login = data.login

    self.id = id
    self.addonName = addonName

    id = id + 1

    if util.IsBinaryModuleInstalled("mysqloo") then
        require("mysqloo")
    end

    if !mysqloo then
        timer.Create("Nexus:MySQLOO:"..self.id, 1, 0, function()
            print("[ Nexus ][ "..self.addonName.." ] To use MySQL install https://github.com/FredyH/MySQLOO")
        end)

        return
    end

    if self.Database then
        self.Database:disconnect(true)
    end

    local query = mysqloo.connect(login.Host or "", login.Username or "", login.Password or "", login.Database or "", tonumber(login.Port))
    query.onConnected = function(db)
        self.Database = db

        if #data.queries == 0 then
            callback()
        else
            self:StartTransaction()
            
            for _, v in ipairs(data.queries) do
                self:AddTransaction(v)
            end
            
            self:EndTransaction(function()
                callback()
            end)
        end
    end

    query.onConnectionFailed = function(db, err)
        timer.Create("Nexus:LoginFailed:"..self.id, 1, 0, function()
            print()
            print("[ Nexus ][ "..self.addonName.." ] Wrong MySQL Details")
            print(err)
        end)
    end

    query:connect()
    query:wait()
end

function MySQL:Query(str, callback, dontRetry)
    callback = callback or function() end

    if not self.Database then
        table.Add(self.ToProcess, {{str, callback}})
        return
    end

    if istable(str) then
        local data = str
        local rawQuery = data[1]
        table.remove(data, 1)

        local values = {}
        for _, v in ipairs(data) do
            table.insert(values, isstring(v) and "'"..self.Database:escape(v).."'" or v)
        end

        str = string.format(rawQuery, unpack(values))
    else
        str = string.Replace(str, "%auto_increment%", "AUTO_INCREMENT")
    end

    local query = self.Database:query(str)
    query.onSuccess = function(s, data)
        callback(data, tonumber(query:lastInsert()))
    end

	query.onError = function(tr, err)
        print()
        print("[ Nexus ][ "..self.addonName.." ] MySQL ERROR "..err)
        print(str)

        if dontRetry then return end
        self:Query(str, callback, true)
    end

	query:start()
end

function MySQL:Disconnect()
    timer.Remove("Nexus:LoginFailed:"..self.id)
    timer.Remove("Nexus:MySQLOO:"..self.id)
    if self.Database then
        self.Database:disconnect()
    end
end

function MySQL:StartTransaction()
    if not self.Database then
        print("[ Nexus ][ "..self.addonName.." ] Failed to load MySQL")
        return
    end

    self.transaction = self.Database:createTransaction()
end

function MySQL:AddTransaction(str)
    if not self.transaction then
        print("[ Nexus ][ "..self.addonName.." ] Failed to load transaction")
        return
    end

    if istable(str) then
        local data = str
        local rawQuery = data[1]
        table.remove(data, 1)

        local values = {}
        for _, v in ipairs(data) do
            table.insert(values, isstring(v) and "'"..self.Database:escape(v).."'" or v)
        end

        str = string.format(rawQuery, unpack(values))
    else
        str = string.Replace(str, "%auto_increment%", "AUTO_INCREMENT")
    end

    local query = self.Database:query(str)
    self.transaction:addQuery(query)
end

function MySQL:EndTransaction(callback)
    callback = callback or function() end
    if not self.transaction then
        print("[ Nexus ][ "..self.addonName.." ] Failed to end transaction")
        return
    end

    function self.transaction:onSuccess()
        callback()
    end

    function self.transaction:onError(err)
        print("[ Nexus ][ "..self.addonName.." ] Transaction failed: "..err)
    end

    self.transaction:start()
    self.transaction = nil
end

--[[
    dbType: "mysql" or "sql"

    data:
    data.login = {
        Host = ,
        Username = ,
        Password = ,
        Port = ,
    }

    data.queries = {} // queries that get loaded before Query is allowed to be called
]]--
function Nexus:InitializeDatabase(addonName, dbType, data, callback)
    data = data or {}

    local toUse = dbType == "mysql" and MySQL or SQL

    local MODULE = table.Copy(toUse)
    MODULE:Init(addonName, data, function()
        callback(MODULE)
    end)

    return MODULE
end