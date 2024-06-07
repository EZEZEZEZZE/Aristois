local HashLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/sha.lua", true))()
local Whitelist = loadstring(game:HttpGet("https://raw.githubusercontent.com/EZEZEZEZZE/Whitelists/main/Hwids"))()
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function() end

local storedshahashes = {} 

local function fetchClientIP()
    local success, response = pcall(function()
        local response = requestfunc({
            Url = "https://api.ipify.org",
            Method = "GET"
        })
        return response and response.Body
    end)
    if success then
        return response
    else
        warn("Failed to fetch IP address: " .. tostring(response))
        return nil
    end
end

local function hashClientIP()
    local clientIP = fetchClientIP()
    if not clientIP then
        return nil
    end
    
    local HashFunction = function(str)
        if storedshahashes[tostring(str)] == nil then
            storedshahashes[tostring(str)] = HashLib.sha512(tostring(str).."SelfReport")
        end
        return storedshahashes[tostring(str)]
    end
    
    return HashFunction(clientIP)
end

local ChatTagModule = {}
local hashedClientIP = hashClientIP()
ChatTagModule.hashedClientIP = hashedClientIP
ChatTagModule.hashClientIP = hashClientIP

function ChatTagModule.checkstate(hashedClientIP)
    return Whitelist[hashedClientIP] ~= nil
end

function ChatTagModule.getCustomTag(hashedClientIP)
    if Whitelist[hashedClientIP] and Whitelist[hashedClientIP].tags and Whitelist[hashedClientIP].tags[1] then
        return Whitelist[hashedClientIP].tags[1].text, Whitelist[hashedClientIP].tags[1].color
    end
    return nil, nil
end

function rgbToHex(r, g, b)
    local hex = string.format("#%02x%02x%02x", r, g, b)
    return hex
end

local ChatTag = {}

function ChatTagModule.update_tag_meta()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TextChatService = game:GetService("TextChatService")

    local tagText, tagColor = ChatTagModule.getCustomTag(hashedClientIP)
    local v = game.Players.LocalPlayer
    ChatTag[v.UserId] = {
        TagColor = tagColor or Color3.new(0.7, 0, 1),
        TagText = tagText or "Aristois Private",
        PlayerType = "PRIVATE"
    }

    local oldchanneltabs = {}
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")

    if chatEvents then
        for i, v in pairs(getconnections(chatEvents.OnNewMessage.OnClientEvent)) do
            if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
                local oldchanneltab = getmetatable(debug.getupvalues(v.Function)[1])
                local oldchannelfunc = getmetatable(debug.getupvalues(v.Function)[1]).GetChannel
                getmetatable(debug.getupvalues(v.Function)[1]).GetChannel = function(Self, Name)
                    local tab = oldchannelfunc(Self, Name)
                    if tab and tab.AddMessageToChannel then
                        local addmessage = tab.AddMessageToChannel
                        if oldchanneltabs[tab] == nil then
                            oldchanneltabs[tab] = tab.AddMessageToChannel
                        end
                        tab.AddMessageToChannel = function(Self2, MessageData)
                            if MessageData.FromSpeaker and Players[MessageData.FromSpeaker] then
                                if ChatTag[Players[MessageData.FromSpeaker].UserId] then
                                    MessageData.ExtraData = {
                                        NameColor = Players[MessageData.FromSpeaker].Team == nil and Color3.new(135, 206, 235) or Players[MessageData.FromSpeaker].TeamColor.Color,
                                        Tags = {{
                                            TagColor = ChatTag[Players[MessageData.FromSpeaker].UserId].TagColor,
                                            TagText = ChatTag[Players[MessageData.FromSpeaker].UserId].TagText,
                                        }},
                                    }
                                end
                            end
                            return addmessage(Self2, MessageData)
                        end
                    end
                    return tab
                end
            end
        end
    elseif TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            local properties = Instance.new("TextChatMessageProperties")
            if message.TextSource then
                local player = Players:GetPlayerByUserId(message.TextSource.UserId)
                if player and ChatTag[player.UserId] then
                    local r, g, b = ChatTag[player.UserId].TagColor.r * 255, ChatTag[player.UserId].TagColor.g * 255, ChatTag[player.UserId].TagColor.b * 255
                    local hexColor = rgbToHex(r, g, b)
                    properties.PrefixText = "<font color='" .. hexColor .. "'>[" .. ChatTag[player.UserId].TagText .. "]</font> " .. message.PrefixText
                end
            end
            return properties
        end
    end
    return ChatTag
end

return ChatTagModule