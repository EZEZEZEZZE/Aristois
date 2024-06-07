repeat
    task.wait()
until game:IsLoaded()

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

if not isfolder("Aristois") then
    makefolder("Aristois")
end

if not isfolder("Aristois/Games") then
    makefolder("Aristois/Games")
end

local function fetchLatestCommit()
    local response = game:HttpGet("https://api.github.com/repos/EZEZEZEZZE/Aristois/commits")
    local commits = game.HttpService:JSONDecode(response)
    if commits and #commits > 0 then
        return commits[1].sha
    end
    return nil
end

local function updateAvailable()
    local latestCommit = fetchLatestCommit()
    if latestCommit then
        local lastCommitFile = "Aristois/last_commit.txt"
        if fileExists(lastCommitFile) then
            local lastCommit = readfile(lastCommitFile)
            return lastCommit ~= latestCommit, latestCommit
        else
            return true, latestCommit
        end
    end
    return false, nil
end

local function updateFiles(commitHash)
    local baseUrl = "https://raw.githubusercontent.com/EZEZEZEZZE/Aristois/" .. commitHash .. "/"
    local filesToUpdate = {
        "NewMainScript.lua", 
        "GuiLibrary.lua", 
        "Universal.lua",
        "Games/6872274481.lua",
        "Games/11630038968.lua"
    }
    for _, filePath in ipairs(filesToUpdate) do
        local localFilePath = "Aristois/" .. filePath
        if not fileExists(localFilePath) or updateAvailable then
            local fileUrl = baseUrl .. filePath
            downloadFile(fileUrl, localFilePath)
        end
    end
    writefile("Aristois/last_commit.txt", commitHash)
end

local updateAvailable, latestCommit = updateAvailable()
if updateAvailable then
    updateFiles(latestCommit)
end
