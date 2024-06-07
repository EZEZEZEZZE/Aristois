repeat task.wait() until game:IsLoaded()
getgenv().SecureMode = true
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextChatService = game:GetService("TextService")

local GuiLibrary = loadstring(readfile("Aristois/GuiLibrary.lua"))()
local WhitelistModule = loadstring(readfile("Aristois/Librarys/Whitelist.lua"))()
local boxHandleAdornment = Instance.new("BoxHandleAdornment")
local IsOnMobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, UserInputService:GetPlatform())

local Table = {
    ChatStrings1 = {
        ["KVOP25KYFPPP4"] = "Aristois",
    },
    ChatStrings2 = {
        ["Aristois"] = "KVOP25KYFPPP4",
    },
    checkedPlayers = {},
    Box = function()
        local boxHandleAdornment = Instance.new("BoxHandleAdornment")
        boxHandleAdornment.Size = Vector3.new(4, 6, 4)
        boxHandleAdornment.Color3 = Color3.new(1, 0, 0)
        boxHandleAdornment.Transparency = 0.6
        boxHandleAdornment.AlwaysOnTop = true
        boxHandleAdornment.ZIndex = 10
        boxHandleAdornment.Parent = workspace
        return boxHandleAdornment
    end
}

local checkedPlayers_mt = {
    __metatable = "Locked"
}
local WhitelistModule_mt = {
    __metatable = "Locked"
}

function Table.CheckPlayerType(plr)
    if not plr then
        return "UNKNOWN"
    end

    if getmetatable(Table.checkedPlayers) ~= checkedPlayers_mt then
        return "UNKNOWN"
    end
    
    if getmetatable(WhitelistModule) ~= WhitelistModule_mt then
        return "UNKNOWN"
    end
    
    if Table.checkedPlayers[plr] then
        return "PRIVATE"
    end
    
    if type(WhitelistModule.checkstate) ~= "function" then
        return "UNKNOWN"
    end

    if getmetatable(WhitelistModule.checkstate) then
        return "UNKNOWN"
    end

    if WhitelistModule.checkstate(plr) then
        Table.checkedPlayers[plr] = true 
        return "PRIVATE"
    else
        return "DEFAULT"
    end
end

setmetatable(Table.checkedPlayers, checkedPlayers_mt)
setmetatable(WhitelistModule, WhitelistModule_mt)

local CheckPlayerType = Table.CheckPlayerType
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}

local Window = GuiLibrary:CreateWindow({
    Name = "Rayfield Example Window",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "Aristois/configs",
       FileName = tostring(shared.AristoisPlaceId) .. ".lua"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
 })

 do
    function RunLoops:BindToRenderStep(name, func)
        if RunLoops.RenderStepTable[name] == nil then
            RunLoops.RenderStepTable[name] = RunService.RenderStepped:Connect(func)
        end
    end

    function RunLoops:UnbindFromRenderStep(name)
        if RunLoops.RenderStepTable[name] then
            RunLoops.RenderStepTable[name]:Disconnect()
            RunLoops.RenderStepTable[name] = nil
        end
    end

    function RunLoops:BindToStepped(name, func)
        if RunLoops.StepTable[name] == nil then
            RunLoops.StepTable[name] = RunService.Stepped:Connect(func)
        end
    end

    function RunLoops:UnbindFromStepped(name)
        if RunLoops.StepTable[name] then
            RunLoops.StepTable[name]:Disconnect()
            RunLoops.StepTable[name] = nil
        end
    end

    function RunLoops:BindToHeartbeat(name, func)
        if RunLoops.HeartTable[name] == nil then
            RunLoops.HeartTable[name] = RunService.Heartbeat:Connect(func)
        end
    end

    function RunLoops:UnbindFromHeartbeat(name)
        if RunLoops.HeartTable[name] then
            RunLoops.HeartTable[name]:Disconnect()
            RunLoops.HeartTable[name] = nil
        end
    end
end

local Combat = Window:CreateTab("Combat")
local Blatant = Window:CreateTab("Blatant")
local Render = Window:CreateTab("Render")
local Utility = Window:CreateTab("Utility")
local Word = Window:CreateTab("Word")

local function IsAlive(plr)
    if not plr then
        return false
    end
    
    if typeof(plr) == "Instance" and plr:IsA("Player") then
        return plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0
    end
    
    if typeof(plr) == "table" then
        for _, player in ipairs(plr) do
            if typeof(player) == "Instance" and player:IsA("Player") then
                if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then
                    return false
                end
            else
                return false 
            end
        end
        return true
    end
    
    return false 
end

local function getNearestPlayer(maxDist, findNearestHealthPlayer, teamCheck)
    local Players = game:GetService("Players"):GetPlayers()
    local targetData = {
        nearestPlayer = nil,
        dist = math.huge,
        lowestHealth = math.huge
    }

    local function updateTargetData(entity, mag, health)
        if findNearestHealthPlayer and health < targetData.lowestHealth then
            targetData.lowestHealth = health
            targetData.nearestPlayer = entity
        elseif mag < targetData.dist then
            targetData.dist = mag
            targetData.nearestPlayer = entity
        end
    end

    for _, player in ipairs(Players) do
        if player ~= lplr and player.Character and player.Character:FindFirstChild("Humanoid") and IsAlive(player) and IsAlive(lplr) then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local mag = (humanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
                local health = player.Character:FindFirstChild("Humanoid").Health
                
                if mag < maxDist then
                    if not teamCheck or player.Team ~= lplr.Team then -- Check team only if TeamCheck is enabled
                        updateTargetData(player, mag, health)
                    end
                end
            end
        end
    end

    return targetData.nearestPlayer
end

local function SpeedMultiplier()
    local baseMultiplier = 1
    local multiplier = baseMultiplier
    return multiplier
end


local function runcode(func) func() end

local nearest
local Distance = {["Value"] = 32}
runcode(function()
    local Section = Combat:CreateSection("AutoClicker",true)
    local CPSSliderAmount = {["Value"] = 10}
    local function FindTools()
        local tools = {}
        if lplr then
            if lplr.Character then
                for _, item in ipairs(lplr.Character:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, item)
                    end
                end
            end
        end
        return tools
    end

    local AutoClicker = Combat:CreateToggle({
        Name = "AutoClicker",
        CurrentValue = false,
        Flag = "AutoClicker",
        Callback = function(callback)
            if callback then
                local interval = 0.1 / CPSSliderAmount["Value"]
                local lastClickTime = tick()
                RunLoops:BindToHeartbeat("AutoClicker", function()
                    local tools = FindTools() 
                    for _, tool in ipairs(tools) do
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            if tick() - lastClickTime >= interval then
                                lastClickTime = tick()
                                tool:Activate()
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("AutoClicker")
            end
        end
    })
    local CPSSlider = Combat:CreateSlider({
        Name = "CPS",
        Range = {1, 60},
        Increment = 1,
        Suffix = "CPS",
        CurrentValue = 10,
        Flag = "CPS",
        Callback = function(Value)
            CPSSliderAmount["Value"] = Value
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Killaura", true)
    local FacePlayerEnabled = {Enabled = false}
    local Boxes = {Enabled = false}
    local TeamCheck = {Enabled = false}
    local boxHandleAdornment = Table.Box()
    local Distance = {Value = 32}
    
    local function updateBoxAdornment(nearest)
        if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
            if boxHandleAdornment.Parent ~= nearest.Character then
                boxHandleAdornment.Adornee = Boxes.Enabled and nearest.Character.HumanoidRootPart or nil
                if boxHandleAdornment.Adornee then
                    local cf = boxHandleAdornment.Adornee.CFrame
                    local x, y, z = cf:ToEulerAnglesXYZ()
                    boxHandleAdornment.CFrame = CFrame.new() * CFrame.Angles(-x, -y, -z)
                    boxHandleAdornment.Parent = nearest.Character
                end
            end
        else
            boxHandleAdornment.Adornee = nil
            boxHandleAdornment.Parent = nil
        end
    end
    local Killaura = Blatant:CreateToggle({
        Name = "Killaura",
        CurrentValue = false,
        Flag = "Killaura",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Killaura", function()
                    task.wait(0.01)
                    nearest = getNearestPlayer(Distance["Value"], false, TeamCheck.Enabled)
                    if nearest and nearest.Character and not nearest.Character:FindFirstChild("ForceField") and IsAlive(lplr) and IsAlive(nearest) then
                        if FacePlayerEnabled.Enabled then
                            lplr.Character:SetPrimaryPartCFrame(CFrame.new(lplr.Character.HumanoidRootPart.Position, Vector3.new(nearest.Character.HumanoidRootPart.Position.X, lplr.Character.HumanoidRootPart.Position.Y, nearest.Character.HumanoidRootPart.Position.Z)))
                        end
                        updateBoxAdornment(nearest)
                    else
                        updateBoxAdornment(nil)
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Killaura")
                updateBoxAdornment(nil)
            end
        end
    })
    local KillauraDistance = Blatant:CreateSlider({
        Name = "Distance",
        Range = {1, 32},
        Increment = 1,
        Suffix = "Studs",
        CurrentValue = 32,
        Flag = "KillAuraDistanceSlider",
        Callback = function(Value)
            Distance["Value"] = Value
        end
    })
    local FacePlayer = Blatant:CreateToggle({
        Name = "FacePlayer",
        CurrentValue = false,
        Flag = "RotationsKillauraToggle",
        Callback = function(val)
            FacePlayerEnabled.Enabled = val
        end
    })
    local BoxesToggle = Blatant:CreateToggle({
        Name = "Boxes",
        CurrentValue = false,
        Flag = "Boxes",
        Callback = function(val)
            Boxes.Enabled = val
        end
    })
    local TeamCheckToggle = Blatant:CreateToggle({
        Name = "Team Check",
        CurrentValue = false,
        Flag = "TeamCheck",
        Callback = function(val)
            TeamCheck.Enabled = val
        end
    })
end)

local SpeedSlider = {["Value"] = 22}
runcode(function()
    local Section = Blatant:CreateSection("Speed", true)
    local lastMoveTime = tick()
    local AutoJump = {Enabled = false}
    local AlwaysJump = {Enabled = false}
    local AutoPot = false
    local HeatSeeker = {Enabled = false}
    local IdleThreshold = {["Value"] = 0.97}
    local SpeedDuration = {["Value"] = 0.62}

    local SpeedToggle = Blatant:CreateToggle({
        Name = "Speed",
        CurrentValue = false,
        Flag = "Speed",
        Callback = function(callback)
            if callback then
                RunLoops:BindToHeartbeat("Speed", function(dt)
                    if IsAlive(lplr) then
                        local speedMultiplier = SpeedMultiplier()
                        local speedIncrease = SpeedSlider.Value
                        local currentSpeed = lplr.Character.Humanoid.WalkSpeed
                        local moveDirection = lplr.Character.Humanoid.MoveDirection
                        local newVelocity
                        if HeatSeeker.Enabled then
                            if moveDirection.magnitude < 0.01 then
                                lastMoveTime = tick()
                                newVelocity = Vector3.new(0, 0, 0)
                            elseif tick() - lastMoveTime > SpeedDuration["Value"] then
                                newVelocity = moveDirection * (1.1 * speedMultiplier - currentSpeed)
                            else
                                newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                            end
                            if tick() - lastMoveTime > IdleThreshold["Value"] then
                                lastMoveTime = tick()
                                newVelocity = Vector3.new(0, 0, 0)
                            end
                        else
                            newVelocity = moveDirection * (speedIncrease * speedMultiplier - currentSpeed)
                        end
                        lplr.Character:TranslateBy(newVelocity * dt)
                        if nearest and AutoJump.Enabled then
                            local distanceToNearest = (nearest.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                            if (lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air) and lplr.Character.Humanoid.MoveDirection ~= Vector3.zero then
                                if distanceToNearest <= 18 then
                                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 15, lplr.Character.HumanoidRootPart.Velocity.Z)
                                end
                            end
                        end
                        if AlwaysJump.Enabled then
                            if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 15, lplr.Character.HumanoidRootPart.Velocity.Z)
                            end
                        end
                    end
                end)
            else
                RunLoops:UnbindFromHeartbeat("Speed")
            end
        end
    })
    local DistanceSlider = Blatant:CreateSlider({
        Name = "Speed", 
        Range = {1, 30},
        Increment = 1,
        Suffix = "Speed.",
        CurrentValue = 30,
        Flag = "DistanceSlider",
        Callback = function(Value)
            SpeedSlider["Value"] = Value
        end
    })
    local HeatSeekerToggle = Blatant:CreateToggle({
        Name = "HeatSeeker",
        CurrentValue = HeatSeeker.Enabled,
        Flag = "HeatSeeker",
        Callback = function(val)
            HeatSeeker.Enabled = val
        end
    })
    local SpeedDurationSlider = Blatant:CreateSlider({
        Name = "SpeedDuration (HeatSeeker)",
        Range = {0.01, 0.62},
        Increment = 0.01,
        Suffix = "seconds",
        CurrentValue = 0.62,
        Flag = "SpeedDuration",
        Callback = function(Value)
            SpeedDuration["Value"] = Value
        end
    })

    local IdleThresholdSlider = Blatant:CreateSlider({
        Name = "IdleThreshold (HeatSeeker)",
        Range = {0.01, 0.97},
        Increment = 0.01,
        Suffix = "seconds",
        CurrentValue = 0.97,
        Flag = "IdleThreshold",
        Callback = function(Value)
            IdleThreshold["Value"] = Value
        end
    })
    local AutoJumpToggle = Blatant:CreateToggle({
        Name = "AutoJump",
        CurrentValue = AutoJump.Enabled,
        Flag = "AutoJump",
        Callback = function(val)
            AutoJump.Enabled = val
        end
    })
    local AlwaysJumpToggle = Blatant:CreateToggle({
        Name = "AlwaysJump",
        CurrentValue = AlwaysJump.Enabled,
        Flag = "AlwaysJump",
        Callback = function(val)
            AlwaysJump.Enabled = val
        end
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("Flight", true)
    local FlightKeybindCheck = false
    local FlightToggle = Blatant:CreateToggle({
        Name = "Flight",
        CurrentValue = false,
        Flag = "Flight",
        Callback = function(val)
            local flightEnabled = val
            local lastTick = tick()
            local airTimer = 0
            RunLoops:BindToHeartbeat("Fly", function()
                local currentTick = tick()
                local deltaTime = currentTick - lastTick
                lastTick = currentTick
                airTimer = airTimer + deltaTime
                local remainingTime = math.max(1000 - airTimer, 0)
                local player = Players.LocalPlayer
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
                if humanoid and humanoidRootPart then
                    local flySpeed = 10  

                    local flyVelocity = humanoid.MoveDirection * flySpeed
                    local flyUp = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                    local flyDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                    local velocity = flyVelocity + Vector3.new(0, (flyUp and 50 or 0) + (flyDown and -50 or 0), 0)

                    if flightEnabled then
                        humanoidRootPart.AssemblyLinearVelocity = velocity
                    else
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
    
                    if airTimer > 1000 then
                        local ray = Ray.new(humanoidRootPart.Position, Vector3.new(0, -1000, 0))
                        local ignoreList = {player, character}
                        local hitPart, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
                        if hitPart then
                            airTimer = 0
                        end
                    end
                end
            end)
            if not val then
                RunLoops:UnbindFromHeartbeat("Fly")
            end
        end
    })
    local ftkeybind = Blatant:CreateKeybind({
        Name = "Flight Keybind",
        CurrentKeybind = "C",
        HoldToInteract = false,
        Flag = "FlightKeybindToggle",
        Callback = function(Keybind)
            if FlightKeybindCheck == true then
                FlightKeybindCheck = false
                FlightToggle:Set(enabled)
            else
                if FlightKeybindCheck == false then
                    FlightKeybindCheck = true
                    FlightToggle:Set(not enabled)
                end
            end
        end,
    })
end)

runcode(function()
    local Section = Blatant:CreateSection("DeviceSpoofer", true)
    local selectedDevices = {Enum.Platform.Windows}

    local DeviceSpoofer = Utility:CreateToggle({
        Name = "Device Spoofer",
        CurrentValue = false,
        Flag = "Device",
        Callback = function(callback)
            if callback then
                local originalNamecall
                originalNamecall = hookmetamethod(game, "__namecall", function(...)
                    local args = {...}
                    local self = args[1]
                    local method = getnamecallmethod()

                    if self == UserInputService or self == GuiService then
                        if method == "GetPlatform" then
                            return selectedDevices[1]
                        end
                    end
                    return originalNamecall(...)
                end)
                getgenv().originalNamecall = originalNamecall
            else
                if getgenv().originalNamecall then
                    hookmetamethod(game, "__namecall", getgenv().originalNamecall)
                    getgenv().originalNamecall = nil
                end
            end
        end
    })
    local Dropdown = Utility:CreateDropdown({
        Name = "Device Selector",
        Options = {"Windows", "IOS", "Android", "XBoxOne", "PS3", "PS4", "Linux", "UWP"},
        CurrentOption = "Windows",
        Flag = "DeviceSelector", 
        Callback = function(Option)
            selectedDevices = {}
            for _, device in ipairs(Option) do
                table.insert(selectedDevices, Enum.Platform[device])
            end
        end,
    })
end)

Players.PlayerAdded:Connect(function(player)
    if CheckPlayerType(WhitelistModule.hashedClientIP) == "PRIVATE" then
        local chatStrings = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or TextChatService
        if chatStrings then
            chatStrings.SayMessageRequest:FireServer("/w " .. player.Name .. " " .. clients.ChatStrings2.Aristois, "All")
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if CheckPlayerType(v) == "PRIVATE" then
        local chatStrings = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or TextChatService
        if chatStrings then
            chatStrings.SayMessageRequest:FireServer("/w " .. v.Name .. " " .. clients.ChatStrings2.Aristois, "All")
        end
    end
end

if lplr then
    local whitelisted = WhitelistModule.checkstate(WhitelistModule.hashedClientIP)
    if whitelisted then
        local defaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or TextChatService
        local onMessageDoneFiltering = defaultChatSystemChatEvents and defaultChatSystemChatEvents:FindFirstChild("OnMessageDoneFiltering")
        if onMessageDoneFiltering then
            onMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
                local speaker, message = Players[messageData.FromSpeaker], messageData.Message
                if messageData.MessageType == "Whisper" and message == clients.ChatStrings2.Aristois then
                    GuiLibrary:Notify({
                        Title = "Aristois",
                        Content = messageData.FromSpeaker .. " is using Aristois!",
                        Duration = 60,
                        Image = 4483362458,
                        Actions = {
                            Ignore = {
                                Name = "Okay!",
                                Callback = function()
                                    print("The user tapped Okay!")
                                end
                            },
                        },
                    })
                end
            end)
        end
    end
end

WhitelistModule.update_tag_meta()
GuiLibrary:LoadConfiguration()

