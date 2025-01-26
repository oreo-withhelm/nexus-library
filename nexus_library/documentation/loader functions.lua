-- load a file based on
-- cl_, sh_, sv_ prefix
Nexus:LoadServer(path)
Nexus:LoadClient(path)
Nexus:LoadShared(path)

-- load a singular file and detect its realm
Nexus:LoadFile(path)

-- load a directory in lua/
/*

loadFirst = {
"lua/myfile/sv_sql.lua",    
"lua/myfile/sv_database.lua",
}

-- this loads these files before any other in the directory
*/
Nexus:LoadDirectory(dir, loadFirst (optional))

hook.Add("Nexus:Loaded", ...) -- gets called when the nexus config file has loaded