local queueonteleport = (syn and syn.queue_on_teleport) or queue_for_teleport or queue_on_teleport or queueonteleport

if not isfolder("Aristois") then
    makefolder("Aristois")
end

if not isfolder("Aristois/Games") then
    makefolder("Aristois/Games")
end

if not isfolder("Aristois/Librarys") then
    makefolder("Aristois/Librarys")
end

if not isfolder("Aristois/assets") then
    makefolder("Aristois/assets")
end

local function fetchLatestCommit()
    local response = game:HttpGet("https://api.github.com/repos/EZEZEZEZZE/Aristois/commits")
    local commits = game:GetService("HttpService"):JSONDecode(response)
    if commits and #commits > 0 then
        return commits[1].sha
    end
    return nil
end

local function fileExists(filePath)
    local success, _ = pcall(function() return readfile(filePath) end)
    return success
end

local function downloadFile(url, filePath)
    local response = game:HttpGet(url, true)
    if response then
        writefile(filePath, response)
    end
end

local function updateAvailable()
    local latestCommit = fetchLatestCommit()
    if latestCommit then
        local lastCommitFile = "Aristois/commithash.txt"
        if fileExists(lastCommitFile) then
            local lastCommit = readfile(lastCommitFile)
            return lastCommit ~= latestCommit, latestCommit
        else
            return true, latestCommit
        end
    end
    return false, nil
end

local bedwarsidtable = {
    6872274481,
    8444591321,
    8560631822
}

local bridgeduelidtable = {
    11630038968
}

local function updateFiles(commitHash)
    local baseUrl = "https://raw.githubusercontent.com/EZEZEZEZZE/Aristois/" .. commitHash .. "/"
    local filesToUpdate = {
        "NewMainScript.lua", 
        "GuiLibrary.lua", 
        "Universal.lua",
        "Librarys/Whitelist.lua",
        "Games/11630038968.lua"
    }
    for _, filePath in ipairs(filesToUpdate) do
        local localFilePath = "Aristois/" .. filePath
        if not fileExists(localFilePath) or updateAvailable then
            local fileUrl = baseUrl .. filePath
            downloadFile(fileUrl, localFilePath)
        end
    end
    writefile("Aristois/commithash.txt", commitHash)
end

local function downloadFile(url, filePath)
    local response = game:HttpGet(url, true)
    if response then
        writefile(filePath, response)
    end
end

local BedWarsgame = table.find(bedwarsidtable, placeid)
local BridgeDuelgame = table.find(bridgeduelidtable, placeid)

shared.ReadFile = true
shared.AristoisPlaceId = ""

if BedWarsgame then 
    shared.AristoisPlaceId = 6872274481
elseif BridgeDuelgame then
    shared.AristoisPlaceId = 11630038968
else
    shared.AristoisPlaceId = game.PlaceId
end

local updateAvailable, latestCommit = updateAvailable()
if updateAvailable then
    updateFiles(latestCommit)
end

if shared.AristoisPlaceId == 6872274481 or shared.AristoisPlaceId == 11630038968 then
    if shared.ReadFile then
        loadstring(readfile("Aristois/Games/" .. shared.AristoisPlaceId .. ".lua"))()
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EZEZEZEZZE/Aristois/main/Games/" .. shared.AristoisPlaceId .. ".lua"))()
    end
else
    local placeFilePrivate = "Aristois/Games/" .. tostring(shared.AristoisPlaceId) .. ".lua"
    if fileExists(placeFilePrivate) then
        loadstring(readfile(placeFilePrivate))()
    else
        if shared.ReadFile then
            loadstring(readfile("Aristois/Universal.lua"))()
        else
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EZEZEZEZZE/Aristois/main/Universal.lua"))()
        end
    end
end

if queueonteleport then
    queueonteleport('loadstring(readfile("Aristois/NewMainScript.lua"))()')
end
