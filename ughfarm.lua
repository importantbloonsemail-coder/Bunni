-- ============================================================
-- Bunnyware V5 🐰 | Lite (AutoFarm + AntiAFK + AntiFling)
-- Movement: working version (fast, no bugs)
-- Coin reading & reset: Overdrive's exact logic
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
-- Anti-Fling
-- ============================================================
local AntiFlingSection = MainTab:Section({ Title = "Anti-Fling", Opened = true })
local antiFling = false
AntiFlingSection:Toggle({
    Title = "Anti-Fling",
    Desc = "Prevents you from being flung",
    Value = false,
    Callback = function(v) antiFling = v end
})

-- ============================================================
-- Anti-AFK
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
-- AutoFarm
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
    Desc = "Speed (lower = faster, default 20)",
    Step = 1,
    Value = { Min = 5, Max = 40, Default = 20 },
    Callback = function(v) farmSpeed = v end
})

AutoSection:Paragraph({
    Title = "⚠️ WARNING",
    Desc = "Speeds above 21 studs/sec may trigger anti‑cheat. Use at your own risk!"
})

AutoSection:Slider({
    Title = "Max Coins Before Reset",
    Desc = "Will be overridden by Elite attribute (50 if Elite, else 40)",
    Step = 10,
    Value = { Min = 40, Max = 50, Default = 40 },
    Callback = function(v) maxCoins = v end
})

AutoSection:Dropdown({
    Title = "Return To Location",
    Desc = "Where to teleport after reset",
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
    Desc = "Automatically collects coins",
    Value = false,
    Callback = function(v)
        autoCollectCoins = v
        if not v then cleanupAutofarm() end
    end
})

AutoSection:Toggle({
    Title = "Auto Reset on Max Coins",
    Desc = "Kills you when you reach max coins (uses Overdrive's exact method)",
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
    Desc = "Automatically readies up",
    Value = false,
    Callback = function(v) autoReady = v end
})

-- ============================================================
-- MANUAL RESET BUTTON (for testing)
-- ============================================================
AutoSection:Button({
    Title = "🔄 Force Reset Now",
    Desc = "Triggers reset logic immediately",
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
-- CORE ENGINE – MOVEMENT CODE (working version)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local u47 = false            -- alive?
local u48 = nil              -- current map
local u74 = false            -- farming in progress?
local u75 = nil              -- current tween
local u76 = nil              -- current target coin

-- ============================================================
-- OVERDRIVE'S COIN READING (copied exactly)
-- ============================================================
local u49 = nil  -- false = in game, true = in lobby

local function determineGameOrLobby()
    local gui = LocalPlayer.PlayerGui
    if gui then
        local main = gui:FindFirstChild("MainGUI")
        if main then
            local gameUI = main:FindFirstChild("Game")
            if gameUI then
                u49 = not (gameUI:FindFirstChild("Inventory") ~= nil)
                return
            end
        end
    end
    u49 = nil
end
determineGameOrLobby()

local function u65()
    if not u49 then
        return tonumber(LocalPlayer.PlayerGui.MainGUI.Game.CoinBags.Container.Candy.CurrencyFrame.Icon.Coins.Text)
    else
        return tonumber(LocalPlayer.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container.Candy.CurrencyFrame.Icon.Coins.Text)
    end
end

-- ============================================================
-- HELPER FUNCTIONS (from Overdrive, used in movement)
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
                        local murderer = nil
                        for _, i in ipairs(game.Players:GetPlayers()) do
                            if i.Character and i.Character:FindFirstChild("Knife") then murderer = i break end
                        end
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

-- ============================================================
-- NOCLIP, BODYGYRO, BODYVELOCITY (from working version)
-- ============================================================
local connection = nil
local function u66(p13)
    if p13 then
        if not connection then
            connection = RunService.Heartbeat:Connect(function()
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
        if connection then
            connection:Disconnect()
            connection = nil
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
-- MAIN HEARTBEAT – working movement + Overdrive reset
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

    -- === OVERDRIVE'S COIN READING & RESET ===
    local currentCoins = u65()
    local maxCoin = LocalPlayer:GetAttribute("Elite") and 50 or 40

    -- Debug print every 5 seconds
    if not getgenv()._lastCoinPrint or tick() - getgenv()._lastCoinPrint > 5 then
        print(string.format("📊 Coins: %d  |  Max: %d  |  Reset Toggle: %s  |  u49: %s", currentCoins, maxCoin, tostring(autoResetOnMax), tostring(u49)))
        getgenv()._lastCoinPrint = tick()
    end

    if autoResetOnMax and currentCoins >= maxCoin then
        print("🎯 RESET TRIGGERED! Coins:", currentCoins, "Max:", maxCoin)
        if flingMurdererAfterFarm then
            local murderer = nil
            for _, i in ipairs(game.Players:GetPlayers()) do
                if i.Character and i.Character:FindFirstChild("Knife") then murderer = i break end
            end
            if murderer then
                -- simple fling
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local tRoot = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        root.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 10, 0))
                        root.Velocity = Vector3.new(9e7, 9e7, 9e7)
                        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                        task.wait(0.5)
                        root.CFrame = CFrame.new(root.Position - Vector3.new(0, 10, 0))
                    end
                end
            end
        end
        if LocalPlayer.Character then
            if u75 then u75:Cancel() end
            u67(false)
            u64(returnLocation or "Map")
            local hum = u59(LocalPlayer.Character, "Humanoid")
            if hum then
                hum.Health = 0
                print("✅ Reset complete – killed after teleport.")
            end
        end
        cleanupAutofarm()
        return
    end

    -- === FARMING MOVEMENT (working version) ===
    if u47 and LocalPlayer.Character then
        local v149 = u60(LocalPlayer)
        if v149 then
            local v150 = u62()
            if v150 then
                if v150 ~= u76 then
                    u76 = v150
                    u74 = true
                    if u75 then u75:Cancel() end
                    u67(true)
                    local CFrame5 = v150.CFrame
                    local dist = u61(v149.Position, v150.Position)
                    local duration = dist / farmSpeed
                    if duration > 15 then duration = 3 end
                    v149.Velocity = Vector3.zero
                    u75 = TweenService:Create(v149, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                        CFrame = CFrame.new(CFrame5.X, CFrame5.Y - 3.5, CFrame5.Z) * CFrame.Angles(math.rad(90), 0, math.rad(90))
                    })
                    u75:Play()
                else
                    local v154 = u61(v149.Position, v150.Position)
                    if v154 <= 4.5 and not v150:GetAttribute("Collected") then
                        v150.CFrame = v149.CFrame * CFrame.new(math.random(-0.5, 0.5), math.random(-0.5, 2.5), math.random(-0.5, 0.5))
                    end
                end
            else
                if u74 then
                    u74 = false
                    u76 = nil
                    u67(false)
                    if u75 then u75:Cancel() end
                end
            end
        end
    end
end)

-- ============================================================
-- ANTI-FLING (unchanged)
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

RunService.Heartbeat:Connect(function()
    if antiFling then AntiFlingCheck() end
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
-- CHARACTER RESPAWN
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    cleanupAutofarm()
    determineGameOrLobby()
end)

-- ============================================================
-- PERIODIC UPDATES (map, alive status, u49)
-- ============================================================
coroutine.wrap(function()
    while true do
        task.wait(0.5)
        if LocalPlayer.Character then
            updateAliveStatus()
        end
        updateMap()
        determineGameOrLobby()
    end
end)()

-- ============================================================
-- FINAL NOTIFICATION
-- ============================================================
Window:Notify({
    Title = "Bunnyware V5 🐰 Lite (Overdrive reset)",
    Content = "Loaded! Coin reading uses Overdrive's exact method.",
    Duration = 5,
})

print("✅ Bunnyware V5 Lite with Overdrive coin reading and reset.")