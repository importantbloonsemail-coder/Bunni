-- ============================================================
-- Bunnyware V5 🐰 | Lite (AutoFarm + AntiAFK + AntiFling)
-- WITH DEBUG PRINTS & MULTIPLE COIN READERS
-- ============================================================

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Bunnyware V5 🐰 | Lite (AutoFarm + AntiAFK + AntiFling)",
    Author = "by Aleksandra \"Drew\" Malinina",
    Folder = "BunnywareConfig",
    Icon = "solar:folder-2-bold-duotone",
    ToggleKey = Enum.KeyCode.RightControl,
})

-- ============================================================
-- MAIN TAB
-- ============================================================
local MainTab = Window:Tab({ Title = "Main", Icon = "list" })

-- ============================================================
-- SECTION: Anti-Fling
-- ============================================================
local AntiFlingSection = MainTab:Section({ Title = "Anti-Fling", Opened = true })
local antiFling = false
AntiFlingSection:Toggle({
    Title = "Anti-Fling",
    Desc = "Prevents you from being flung across the map",
    Value = false,
    Callback = function(v) antiFling = v end
})

-- ============================================================
-- SECTION: Anti-AFK
-- ============================================================
local AntiAFKSection = MainTab:Section({ Title = "Anti-AFK Kick", Opened = true })
local antiAFK = false
AntiAFKSection:Toggle({
    Title = "Anti-AFK Kick",
    Desc = "Prevents being kicked for inactivity",
    Value = false,
    Callback = function(v)
        antiAFK = v
        if v then
            if not getgenv()._antiAFKRunning then
                getgenv()._antiAFKRunning = true
                task.spawn(function()
                    while getgenv()._antiAFKRunning do
                        task.wait(60)
                        if antiAFK then
                            local vu = game:GetService("VirtualUser")
                            pcall(function()
                                vu:CaptureController()
                                vu:ClickButton2(Vector2.new())
                            end)
                        end
                    end
                end)
            end
        else
            getgenv()._antiAFKRunning = false
        end
    end
})

-- ============================================================
-- SECTION: AutoFarm
-- ============================================================
local AutoSection = MainTab:Section({ Title = "Coin Farming", Opened = true })

local autoCollectCoins = false
local autoReady = false
local coinAvoidDistance = 20
local autoResetOnMax = false
local flingMurdererAfterFarm = false
local returnLocation = "Map"
local farmSpeed = 20
local maxCoins = 40

AutoSection:Slider({
    Title = "Murderer Avoidance Radius",
    Desc = "How far to stay away from the murderer",
    Step = 1,
    Value = { Min = 20, Max = 80, Default = 20 },
    Callback = function(v) coinAvoidDistance = v end
})

AutoSection:Slider({
    Title = "Farm Speed (studs/sec)",
    Desc = "How fast you move towards coins ( >21 may trigger anti-cheat )",
    Step = 1,
    Value = { Min = 5, Max = 40, Default = 20 },
    Callback = function(v) farmSpeed = v end
})

AutoSection:Paragraph({
    Title = "⚠️ WARNING",
    Desc = "Speeds above 21 studs/sec may trigger anti‑cheat detection and get you kicked. Use at your own risk!"
})

AutoSection:Slider({
    Title = "Max Coins Before Reset",
    Desc = "Set to 40 (default) or 50 (Elite gamepass) – Elite will override this",
    Step = 10,
    Value = { Min = 40, Max = 50, Default = 40 },
    Callback = function(v) maxCoins = v end
})

AutoSection:Dropdown({
    Title = "Return To Location",
    Desc = "Where to teleport after resetting",
    Values = { "Map", "Above Map", "Voting Map", "Void", "Lobby" },
    Value = { "Map" },
    Multi = false,
    Callback = function(opt)
        if type(opt) == "table" and #opt > 0 then
            returnLocation = opt[1]
        end
    end
})

AutoSection:Toggle({
    Title = "Auto Collect Coins",
    Desc = "Automatically collects coins on the map",
    Value = false,
    Callback = function(v)
        autoCollectCoins = v
        if not v then cleanupAutofarm() end
    end
})

AutoSection:Toggle({
    Title = "Auto Reset on Max Coins",
    Desc = "Kills you when you reach the max coin limit (with debug prints)",
    Value = false,
    Callback = function(v) autoResetOnMax = v end
})

AutoSection:Toggle({
    Title = "Fling Murderer After Farm",
    Desc = "Flings the murderer when you reach max coins",
    Value = false,
    Callback = function(v) flingMurdererAfterFarm = v end
})

AutoSection:Toggle({
    Title = "Auto Ready",
    Desc = "Automatically readies up when the game starts",
    Value = false,
    Callback = function(v) autoReady = v end
})

-- ============================================================
-- MANUAL RESET BUTTON FOR TESTING
-- ============================================================
AutoSection:Button({
    Title = "🔄 Force Reset Now (Test)",
    Desc = "Triggers the reset logic immediately – use to test if reset works",
    Callback = function()
        print("🔄 Manual reset triggered!")
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                print("✅ Killed manually.")
            end
        end
    end
})

-- ============================================================
-- CORE ENGINE – AUTOFARM & SUPPORT FUNCTIONS
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local u47 = false
local u48 = nil
local u74 = false
local u75 = nil
local u76 = nil

-- ============================================================
-- COIN READING – MULTIPLE METHODS
-- ============================================================
local function getCoinsFromUI()
    -- Method 1: Exact Overdrive paths
    local gui = LocalPlayer.PlayerGui
    if gui then
        local main = gui:FindFirstChild("MainGUI")
        if main then
            -- Try Game path
            local gameUI = main:FindFirstChild("Game")
            if gameUI then
                local coinText = gameUI:FindFirstChild("CoinBags") and gameUI.CoinBags:FindFirstChild("Container") and gameUI.CoinBags.Container:FindFirstChild("Candy") and gameUI.CoinBags.Container.Candy:FindFirstChild("CurrencyFrame") and gameUI.CoinBags.Container.Candy.CurrencyFrame:FindFirstChild("Icon") and gameUI.CoinBags.Container.Candy.CurrencyFrame.Icon:FindFirstChild("Coins")
                if coinText then
                    local num = tonumber(coinText.Text)
                    if num then return num end
                end
            end
            -- Try Lobby path
            local lobbyUI = main:FindFirstChild("Lobby")
            if lobbyUI then
                local coinText = lobbyUI:FindFirstChild("Dock") and lobbyUI.Dock:FindFirstChild("CoinBags") and lobbyUI.Dock.CoinBags:FindFirstChild("Container") and lobbyUI.Dock.CoinBags.Container:FindFirstChild("Candy") and lobbyUI.Dock.CoinBags.Container.Candy:FindFirstChild("CurrencyFrame") and lobbyUI.Dock.CoinBags.Container.Candy.CurrencyFrame:FindFirstChild("Icon") and lobbyUI.Dock.CoinBags.Container.Candy.CurrencyFrame.Icon:FindFirstChild("Coins")
                if coinText then
                    local num = tonumber(coinText.Text)
                    if num then return num end
                end
            end
        end
    end
    return nil
end

local function getCoinsFromRemote()
    -- Method 2: Server data
    local remote = ReplicatedStorage:FindFirstChild("Remotes")
    if remote then
        local extras = remote:FindFirstChild("Extras")
        if extras then
            local getPlayerData = extras:FindFirstChild("GetPlayerData")
            if getPlayerData and getPlayerData:IsA("RemoteFunction") then
                local success, data = pcall(function() return getPlayerData:InvokeServer() end)
                if success and data then
                    local myData = data[LocalPlayer.Name]
                    if myData then
                        if myData.Coins then return myData.Coins end
                        if myData.Currency then return myData.Currency end
                        if type(myData) == "number" then return myData end
                    end
                end
            end
        end
    end
    return nil
end

local function getCoinsByScanning()
    -- Method 3: Scan all TextLabels for a number
    local gui = LocalPlayer.PlayerGui
    if gui then
        for _, v in ipairs(gui:GetDescendants()) do
            if v:IsA("TextLabel") then
                local num = tonumber(string.gsub(v.Text or "", "[^%d]", ""))
                if num and num > 0 and num < 1000 then
                    return num
                end
            end
        end
    end
    return nil
end

local function getCoins()
    -- Try all methods in order
    local coins = getCoinsFromUI()
    if coins then return coins end
    coins = getCoinsFromRemote()
    if coins then return coins end
    coins = getCoinsByScanning()
    if coins then return coins end
    return 0
end

-- ============================================================
-- FIND MURDERER (for avoidance & fling)
-- ============================================================
local function findMurderer()
    for _, i in ipairs(game.Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
        if i.Backpack and i.Backpack:FindFirstChild("Knife") then return i end
    end
    return nil
end

-- ============================================================
-- FLING PLAYER (for "Fling Murderer After Farm")
-- ============================================================
local flingManager = flingManager or {}
local function getPlrHum(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function getHead(char) return char and (char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")) end
local function getRoot(char) return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")) end

local function flingPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return end
    local Humanoid = getPlrHum(character)
    local RootPart = Humanoid and Humanoid.RootPart
    if not RootPart then return end

    local TCharacter = targetPlayer.Character
    local THumanoid = getPlrHum(TCharacter)
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = getHead(TCharacter)
    local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if not TCharacter or not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

    if not flingManager.cFlingOldPos or RootPart.Velocity.Magnitude < 50 then
        flingManager.cFlingOldPos = RootPart.CFrame
    end

    if THead then
        workspace.CurrentCamera.CameraSubject = THead
    elseif Handle then
        workspace.CurrentCamera.CameraSubject = Handle
    elseif THumanoid and TRootPart then
        workspace.CurrentCamera.CameraSubject = THumanoid
    end

    local function FPos(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid and TCharacter and TCharacter.Parent then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                    task.wait()
                else
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                    task.wait()
                    FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            else
                break
            end
        until not BasePart or not BasePart.Parent or BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= targetPlayer.Character or targetPlayer.Parent ~= game.Players or targetPlayer.Character ~= TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
    end

    local OrgDestroyHeight = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if TRootPart and THead then
        if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
    elseif TRootPart and not THead then
        SFBasePart(TRootPart)
    elseif not TRootPart and THead then
        SFBasePart(THead)
    elseif not TRootPart and not THead and Accessory and Handle then
        SFBasePart(Handle)
    end

    if BV then BV:Destroy() end
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid

    repeat
        if RootPart and flingManager.cFlingOldPos then
            RootPart.CFrame = flingManager.cFlingOldPos * CFrame.new(0, 0.5, 0)
            character:SetPrimaryPartCFrame(flingManager.cFlingOldPos * CFrame.new(0, 0.5, 0))
            Humanoid:ChangeState("GettingUp")
            for _, x in next, character:GetChildren() do
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
        end
        task.wait()
    until not RootPart or (RootPart.Position - flingManager.cFlingOldPos.p).Magnitude < 25
    workspace.FallenPartsDestroyHeight = OrgDestroyHeight
end

-- ============================================================
-- AUTOFARM HELPER FUNCTIONS
-- ============================================================
local function u59(p4, p5, p6)
    if p6 then
        for _, v98 in next, p4:GetChildren() do
            if p5 == v98.Name and p6 == v98.ClassName then
                return v98
            end
        end
    else
        for _, v100 in next, p4:GetChildren() do
            if p5 == v100.Name then
                return v100
            end
        end
    end
end

local function u60(p7)
    if p7 and p7.Character then
        return u59(p7.Character, "HumanoidRootPart") or u59(p7.Character, "PrimaryPart")
    end
end

local function u61(p8, p9)
    local v104 = p8 - p9
    if v104 then
        return v104.Magnitude
    end
end

local function u58()
    return tonumber(workspace.RoundTimerPart:GetAttribute("Time")) or 0
end

local function u64(p12)
    if p12 == "Map" then
        if u48 then
            local v121 = nil
            for _, v123 in next, u48.Spawns:GetChildren() do
                if v123.Name == "Spawn" or v123.Name == "PlayerSpawn" or v123.Name == "SpawnLocation" then
                    v121 = v123
                end
            end
            if v121 then
                local CFrame2 = v121.CFrame
                local v125 = CFrame.new(CFrame2.X, CFrame2.Y + 5, CFrame2.Z)
                if v125 then
                    local v126 = u60(LocalPlayer)
                    if v126 then
                        v126.Velocity = Vector3.zero
                        v126.CFrame = v125
                    end
                end
            end
        end
    elseif p12 == "Above Map" then
        if u48 then
            local v130 = nil
            for _, v132 in next, u48.Spawns:GetChildren() do
                if v132.Name == "Spawn" or v132.Name == "PlayerSpawn" or v132.Name == "SpawnLocation" then
                    v130 = v132
                end
            end
            if v130 then
                local CFrame3 = v130.CFrame
                local highest = 0
                for _, part in next, u48:GetDescendants() do
                    if part:IsA("BasePart") and part.Position.Y > highest then
                        highest = part.Position.Y
                    end
                end
                local v134 = CFrame.new(CFrame3.X, highest + 10, CFrame3.Z)
                local v135 = u60(LocalPlayer)
                if v135 then
                    v135.Velocity = Vector3.zero
                    v135.CFrame = v134
                end
            end
        end
    elseif p12 == "Voting Map" then
        local v129 = u60(LocalPlayer)
        if v129 then
            v129.Velocity = Vector3.zero
            v129.CFrame = CFrame.new(-104, 154, -8)
        end
    elseif p12 == "Void" then
        local v128 = u60(LocalPlayer)
        if v128 then
            v128.Velocity = Vector3.zero
            v128.CFrame = CFrame.new(99999, 99999, 99999)
        end
        if not u59(workspace, "Safe Void Path") then
            local part = Instance.new("Part")
            part.Name = "Safe Void Path"
            part.Parent = workspace
            part.CFrame = CFrame.new(99999, 99995, 99999)
            part.Anchored = true
            part.Size = Vector3.new(300, 0.1, 300)
            part.Transparency = 0.5
        end
    elseif p12 == "Lobby" then
        local v127 = u60(LocalPlayer)
        if v127 then
            v127.Velocity = Vector3.zero
            v127.CFrame = CFrame.new(-104, 152, 82)
        end
    end
end

local function u62()
    local n1 = 1e999
    local v106, v107 = u60(LocalPlayer)
    if v106 then
        local Position = v106.Position
        if u48 then
            local v109 = u59(u48, "CoinContainer")
            if v109 then
                for _, v111 in next, v109:GetChildren() do
                    if v111.Name == "Coin_Server" and not v111:GetAttribute("Collected") then
                        local tooClose = false
                        local murderer = findMurderer()
                        if murderer and coinAvoidDistance > 0 then
                            local mHRP = u60(murderer)
                            if mHRP then
                                if (mHRP.Position - v111.Position).Magnitude < coinAvoidDistance then
                                    tooClose = true
                                end
                            end
                        end
                        if not tooClose then
                            local v112 = u61(Position, v111.Position)
                            if v112 < n1 then
                                n1 = v112
                                v107 = v111
                            end
                        end
                    end
                end
            end
        end
    end
    return v107
end

local function u66(p13)
    if p13 then
        if not getgenv()._noclipConnection then
            getgenv()._noclipConnection = RunService.Heartbeat:Connect(function()
                if autoCollectCoins and LocalPlayer.Character then
                    for _, v168 in next, LocalPlayer.Character:GetChildren() do
                        if v168:IsA("BasePart") then
                            v168.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if getgenv()._noclipConnection then
            getgenv()._noclipConnection:Disconnect()
            getgenv()._noclipConnection = nil
        end
        if LocalPlayer.Character then
            for _, v138 in next, LocalPlayer.Character:GetChildren() do
                if v138:IsA("BasePart") then
                    v138.CanCollide = true
                end
            end
        end
    end
end

local function u67(p14)
    local v140 = u59(LocalPlayer.Character, "UpperTorso")
    if v140 then
        local v141 = u59(v140, "ODH Auto Farm BodyGyro")
        local v142 = u59(v140, "ODH Auto Farm BodyVelocity")
        if p14 then
            if not v141 and not v142 then
                local v143 = u60(LocalPlayer)
                if v143 then
                    local v144 = u59(LocalPlayer.Character, "Humanoid")
                    if v144 then
                        local CFrame4 = v143.CFrame
                        local v146 = CFrame.new(CFrame4.X, CFrame4.Y, CFrame4.Z) * CFrame.Angles(math.rad(90), 0, math.rad(90))
                        u66(true)
                        local gyro = Instance.new("BodyGyro")
                        gyro.Name = "ODH Auto Farm BodyGyro"
                        gyro.Parent = v140
                        gyro.P = 90000
                        gyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
                        gyro.CFrame = v146
                        getgenv()._farmBodyGyro = gyro
                        local vel = Instance.new("BodyVelocity")
                        vel.Name = "ODH Auto Farm BodyVelocity"
                        vel.Parent = v140
                        vel.Velocity = Vector3.zero
                        vel.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                        getgenv()._farmBodyVelocity = vel
                        v143.CFrame = v146
                        v144.PlatformStand = true
                    end
                end
            end
        else
            local v147 = u59(LocalPlayer.Character, "Humanoid")
            if v147 then
                if v141 then v141:Destroy() end
                if v142 then v142:Destroy() end
                v147.PlatformStand = false
                u66(false)
                getgenv()._farmBodyGyro = nil
                getgenv()._farmBodyVelocity = nil
            end
        end
    end
end

local function cleanupAutofarm()
    if u75 then
        u75:Cancel()
        u75 = nil
    end
    u67(false)
    u74 = false
    u76 = nil
end

local function updateMap()
    if not u48 then
        for _, v73 in next, workspace:GetChildren() do
            if u59(v73, "CoinAreas") or u59(v73, "CoinContainer") then
                u48 = v73
            end
        end
    end
end

workspace.ChildRemoved:Connect(function(child)
    if child == u48 then
        u48 = nil
    end
end)

local function updateAliveStatus()
    local remote = ReplicatedStorage:FindFirstChild("Remotes")
    if remote then
        local extras = remote:FindFirstChild("Extras")
        if extras then
            local getPlayerData = extras:FindFirstChild("GetPlayerData")
            if getPlayerData and getPlayerData:IsA("RemoteFunction") then
                local success, data = pcall(function() return getPlayerData:InvokeServer() end)
                if success and data then
                    local myData = data[LocalPlayer.Name]
                    if myData then
                        u47 = (not myData.Dead and not myData.Killed)
                        return
                    end
                end
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        local hum = u59(char, "Humanoid")
        if hum then
            u47 = (hum.Health > 0)
            return
        end
    end
    u47 = false
end

-- ============================================================
-- AUTOFARM HEARTBEAT LOOP (with debug prints)
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not autoCollectCoins then
        if u74 then cleanupAutofarm() end
        return
    end
    updateMap()
    updateAliveStatus()
    local roundTime = u58()
    if roundTime <= 0 then
        if u74 then cleanupAutofarm() end
        return
    end
    if not u47 then
        if u74 then cleanupAutofarm() end
        return
    end

    local currentCoins = getCoins()
    local maxCoin = maxCoins
    -- Override if Elite
    if LocalPlayer:GetAttribute("Elite") then
        maxCoin = 50
    end

    -- Debug output every 5 seconds
    if not getgenv()._lastCoinPrint or tick() - getgenv()._lastCoinPrint > 5 then
        print(string.format("📊 Coins: %d  |  Max: %d  |  Reset Toggle: %s", currentCoins, maxCoin, tostring(autoResetOnMax)))
        getgenv()._lastCoinPrint = tick()
    end

    if autoResetOnMax and currentCoins >= maxCoin then
        print("🎯 RESET TRIGGERED! Coins:", currentCoins, "Max:", maxCoin)
        if flingMurdererAfterFarm then
            local murd = findMurderer()
            if murd then
                flingPlayer(murd)
                print("Flinging murderer after reaching max coins.")
            end
        end
        -- Overdrive style: teleport first, then kill
        if LocalPlayer.Character then
            if u75 then u75:Cancel() end
            u67(false)
            u64(returnLocation or "Map")
            local hum = u59(LocalPlayer.Character, "Humanoid")
            if hum then
                hum.Health = 0
                print("✅ Reset complete – killed after teleport.")
            else
                print("⚠️ No Humanoid found to kill.")
            end
        else
            print("⚠️ No character to reset.")
        end
        cleanupAutofarm()
        return
    end

    if not u74 then
        local targetCoin = u62()
        if not targetCoin then
            return
        end
        u76 = targetCoin
        u74 = true
        u67(true)
        local hrp = u60(LocalPlayer)
        if not hrp then
            u74 = false
            u67(false)
            return
        end
        local distance = u61(hrp.Position, u76.Position)
        local duration = distance / farmSpeed
        if duration > 15 then duration = 3 end
        hrp.Velocity = Vector3.zero
        if u75 then u75:Cancel() end
        u75 = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(u76.Position.X, u76.Position.Y - 3.5, u76.Position.Z) * CFrame.Angles(math.rad(90), 0, math.rad(90))
        })
        u75:Play()
        u75.Completed:Wait()
        if not u76:GetAttribute("Collected") then
            u76.CFrame = hrp.CFrame * CFrame.new(math.random(-0.5, 0.5), math.random(-0.5, 2.5), math.random(-0.5, 0.5))
            task.wait(0.1)
            u76:SetAttribute("Collected", true)
        end
        u67(false)
        u74 = false
        u76 = nil
        if u75 then
            u75:Cancel()
            u75 = nil
        end
    end
end)

-- ============================================================
-- ANTI-FLING CHECK
-- ============================================================
local lastPos = Vector3.new()
local function AntiFlingCheck()
    if not antiFling then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = u60(LocalPlayer)
    if not hrp then return end
    if hrp.AssemblyLinearVelocity.Magnitude > 250 or hrp.AssemblyAngularVelocity.Magnitude > 250 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(lastPos)
    else
        lastPos = hrp.Position
    end
end

local heartbeatConnection
local lastUpdateTime = 0
local UPDATE_INTERVAL = 0.1

heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
    local now = tick()
    if now - lastUpdateTime < UPDATE_INTERVAL then return end
    lastUpdateTime = now

    if antiFling then
        AntiFlingCheck()
    end
end)

-- ============================================================
-- AUTO READY
-- ============================================================
local function ReadyUp()
    if not autoReady then return end
    local gui = LocalPlayer.PlayerGui
    if gui then
        local btn = gui:FindFirstChild("ReadyButton") or gui:FindFirstChild("StartGame")
        if btn and btn:IsA("TextButton") then
            btn:FireServer()
        end
    end
end

local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GameStart")
if remote then
    remote.OnClientEvent:Connect(function()
        task.wait(1)
        ReadyUp()
    end)
end

-- ============================================================
-- CHARACTER RESPAWN HANDLING
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    cleanupAutofarm()
end)

-- ============================================================
-- FINAL NOTIFICATION
-- ============================================================
Window:Notify({
    Title = "Bunnyware V5 🐰 Lite",
    Content = "Loaded! AutoFarm (with debug) + AntiAFK + AntiFling",
    Duration = 5,
})

print("✅ Bunnyware V5 Lite loaded – watch console for coin stats.")