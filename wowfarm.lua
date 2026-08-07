-- ============================================================
-- Bunnyware V5 🐰 | Lite (AutoFarm + AntiAFK + AntiFling)
-- Using Overdrive's EXACT coin reading and reset logic.
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
-- AutoFarm (Overdrive's variables)
-- ============================================================
local AutoSection = MainTab:Section({ Title = "Coin Farming", Opened = true })

-- Overdrive's variables (renamed for our UI)
local u44 = false  -- Auto Farm toggle
local u45 = false  -- Auto Reset toggle
local s1 = "Map"   -- Return location

-- Our UI controls will set these

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
    Callback = function(v) maxCoinsSlider = v end
})

AutoSection:Dropdown({
    Title = "Return To Location",
    Desc = "Where to teleport after reset",
    Values = { "Map", "Above Map", "Voting Map", "Void", "Lobby" },
    Value = { "Map" },
    Multi = false,
    Callback = function(opt)
        if type(opt) == "table" and #opt > 0 then
            s1 = opt[1]
        end
    end
})

AutoSection:Toggle({
    Title = "Auto Collect Coins",
    Desc = "Automatically collects coins",
    Value = false,
    Callback = function(v)
        u44 = v
        if not v then
            -- cleanup
            if u75 then u75:Cancel() end
            u67(false)
            u74 = false
            u76 = nil
        end
    end
})

AutoSection:Toggle({
    Title = "Auto Reset on Max Coins",
    Desc = "Kills you when you reach max coins (uses Overdrive's exact method)",
    Value = false,
    Callback = function(v) u45 = v end
})

AutoSection:Toggle({
    Title = "Fling Murderer After Farm",
    Desc = "Flings the murderer when you reach max coins",
    Value = false,
    Callback = function(v) flingMurderer = v end
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
            local hum = u59(LocalPlayer.Character, "Humanoid")
            if hum then
                hum.Health = 0
                print("✅ Killed manually.")
            end
        end
    end
})

-- ============================================================
-- CORE ENGINE – EXACTLY AS OVERDRIVE
-- ============================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local u7 = task and task.wait or wait
local random = math.random
local rad = math.rad
local _workspace = workspace
local _Vector3 = Vector3
local new = _Vector3.new
local new2 = CFrame.new
local Angles = CFrame.Angles
local new3 = Vector2.new
local new4 = UDim2.new
local new5 = UDim.new
local new6 = TweenInfo.new
local fromRGB = Color3.fromRGB
local EnumFont = Enum.Font
local TextXAlignment = Enum.TextXAlignment
local _ = Enum.TextYAlignment
local EasingStyle = Enum.EasingStyle
local HighlightDepthMode = Enum.HighlightDepthMode
local _ = _workspace.CurrentCamera
local _pcall = pcall
local _type = type
local _tonumber = tonumber
local _next = next
local concat = table.concat
local char = string.char
local RoundTimerPart = _workspace.RoundTimerPart

-- Overdrive's helper functions (copied verbatim)
local function u39(...)
    local tween = TweenService:Create(...)
    tween:Play()
    return tween
end

local function u40(p1, p2, ...)
    if p1 and p2 then
        local v84 = Instance.new(p1)
        local t1 = { ... }
        for v86, v87 in _next, p2 do
            v84[v86] = v87
        end
        if t1[1] then
            for _, v89 in _next, t1 do
                v89.Parent = v84
            end
        end
        return v84
    end
end

local function u58()
    return _tonumber(RoundTimerPart:GetAttribute("Time"))
end

local function u59(p4, p5, p6)
    if p6 then
        for _, v98 in _next, p4:GetChildren() do
            if p5 == v98.Name and p6 == v98.ClassName then
                return v98
            end
        end
    else
        for _, v100 in _next, p4:GetChildren() do
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

local function u62()
    local n1 = 1e999
    local v106, v107 = u60(LocalPlayer)
    if v106 then
        local Position = v106.Position
        if u48 then
            local v109 = u59(u48, "CoinContainer")
            if v109 then
                for _, v111 in _next, v109:GetChildren() do
                    if v111.Name == "Coin_Server" and not v111:GetAttribute("Collected") then
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
    return v107
end

local function u63(p10, p11)
    local n2 = 1e999
    local v116 = nil
    for _, v118 in _next, p11:GetDescendants() do
        if v118:IsA("BasePart") and v118.Transparency ~= 1 then
            local v119 = u61(p10, v118.Position)
            if v119 < n2 then
                v116 = v118
                n2 = v119
            end
        end
    end
    return v116
end

local function u64(p12)
    if p12 == "Map" then
        if u48 then
            local v121 = nil
            for _, v123 in _next, u48.Spawns:GetChildren() do
                if v123.Name == "Spawn" or v123.Name == "PlayerSpawn" or v123.Name == "SpawnLocation" then
                    v121 = v123
                end
            end
            if v121 then
                local CFrame2 = v121.CFrame
                local v125 = new2(CFrame2.X, CFrame2.Y + 5, CFrame2.Z)
                if v125 then
                    local v126 = u60(LocalPlayer)
                    if v126 then
                        v126.Velocity = _Vector3.zero
                        v126.CFrame = v125
                    end
                end
            end
        end
    elseif p12 == "Above Map" then
        if u48 then
            local v130 = nil
            for _, v132 in _next, u48.Spawns:GetChildren() do
                if v132.Name == "Spawn" or v132.Name == "PlayerSpawn" or v132.Name == "SpawnLocation" then
                    v130 = v132
                end
            end
            if v130 then
                local CFrame3 = v130.CFrame
                local v134 = u63(new2(CFrame3.X, CFrame3.Y + 999, CFrame3.Z).Position, u48)
                if v134 then
                    local v135 = u60(LocalPlayer)
                    if v135 then
                        v135.Velocity = _Vector3.zero
                        v135.CFrame = new2(CFrame3.X, v134.CFrame.Y + 7, CFrame3.Z)
                    end
                end
            end
        end
    elseif p12 == "Voting Map" then
        local v129 = u60(LocalPlayer)
        if v129 then
            v129.Velocity = _Vector3.zero
            v129.CFrame = new2(-104, 154, -8)
        end
    elseif p12 == "Void" then
        local v128 = u60(LocalPlayer)
        if v128 then
            v128.Velocity = _Vector3.zero
            v128.CFrame = new2(99999, 99999, 99999)
        end
        if not u59(_workspace, "Safe Void Path") then
            local part = Instance.new("Part")
            part.Name = "Safe Void Path"
            part.Parent = _workspace
            part.CFrame = new2(99999, 99995, 99999)
            part.Anchored = true
            part.Size = new(300, 0.1, 300)
            part.Transparency = 0.5
        end
    elseif p12 == "Lobby" then
        local v127 = u60(LocalPlayer)
        if v127 then
            v127.Velocity = _Vector3.zero
            v127.CFrame = new2(-104, 152, 82)
        end
    end
end

-- ============================================================
-- COIN READING – EXACTLY OVERDRIVE'S u65()
-- ============================================================
local u49 = nil  -- false = in game, true = in lobby

-- Determine u49 (copied from Overdrive)
local function setup_u49()
    local v68 = u59(LocalPlayer, "PlayerGui")
    if v68 then
        local v69 = u59(v68, "MainGUI")
        if v69 then
            local v70 = u59(v69, "Game")
            if v70 then
                u49 = not u59(v70, "Inventory")
            end
        end
    end
end
setup_u49()

local function u65()
    if not u49 then
        return _tonumber(LocalPlayer.PlayerGui.MainGUI.Game.CoinBags.Container.Candy.CurrencyFrame.Icon.Coins.Text)
    else
        return _tonumber(LocalPlayer.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container.Candy.CurrencyFrame.Icon.Coins.Text)
    end
end

-- ============================================================
-- OVERDRIVE'S NOCLIP, GYRO, VELOCITY
-- ============================================================
local connection = nil
local function u66(p13)
    if p13 then
        if not connection then
            connection = RunService.Heartbeat:Connect(function()
                if u47 and LocalPlayer.Character then
                    for _, v168 in _next, LocalPlayer.Character:GetChildren() do
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
            for _, v138 in _next, LocalPlayer.Character:GetChildren() do
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
                        local v146 = new2(CFrame4.X, CFrame4.Y, CFrame4.Z) * Angles(rad(90), 0, rad(90))
                        u66(true)
                        u40("BodyGyro", {
                            Name = "ODH Auto Farm BodyGyro",
                            Parent = v140,
                            P = 90000,
                            MaxTorque = new(9000000000, 9000000000, 9000000000),
                            CFrame = v146
                        })
                        u40("BodyVelocity", {
                            Name = "ODH Auto Farm BodyVelocity",
                            Parent = v140,
                            Velocity = _Vector3.zero,
                            MaxForce = new(9000000000, 9000000000, 9000000000)
                        })
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
            end
        end
    end
end

-- ============================================================
-- OVERDRIVE'S VARIABLES (global to this script)
-- ============================================================
local u47 = nil  -- alive status
local u48 = nil  -- current map
local u74 = nil  -- farming state
local u75 = nil  -- current tween
local u76 = nil  -- current target coin

-- Overdrive's extra functions (u47 update, map update)
local function updateAliveStatus()
    local remote = ReplicatedStorage:FindFirstChild("Remotes")
    if remote then
        local extras = remote:FindFirstChild("Extras")
        if extras then
            local getPlayerData = extras:FindFirstChild("GetPlayerData")
            if getPlayerData and getPlayerData:IsA("RemoteFunction") then
                local success, data = _pcall(function() return getPlayerData:InvokeServer() end)
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

local function updateMap()
    if not u48 then
        for _, v73 in _next, _workspace:GetChildren() do
            if u59(v73, "CoinAreas") or u59(v73, "CoinContainer") then
                u48 = v73
            end
        end
    end
end

-- ============================================================
-- OVERDRIVE'S MAIN HEARTBEAT (copied exactly)
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not u44 then
        if u74 then
            u74 = false
            if LocalPlayer.Character then
                if u75 then u75:Cancel() end
                u67(false)
                u64(s1 or "Map")
            end
        end
    elseif u58() > 0 then
        -- Coin reading and reset (EXACTLY as Overdrive)
        local _Elite = LocalPlayer:GetAttribute("Elite") and 50 or 40
        if u65() == _Elite then
            if u74 then
                u74 = false
                u76 = nil
                if LocalPlayer.Character then
                    if u75 then u75:Cancel() end
                    u67(false)
                    u64(s1 or "Map")
                    if u45 then
                        local v148 = u59(LocalPlayer.Character, "Humanoid")
                        if v148 then v148.Health = 0 end
                    end
                end
            end
        elseif u47 and LocalPlayer.Character then
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
                        local v152 = u61(v149.Position, v150.Position) * 0.04465
                        if v152 > 15 then v152 = 3 end
                        v149.Velocity = _Vector3.zero
                        u75 = u39(v149, new6(v152, EasingStyle.Linear), {
                            CFrame = new2(CFrame5.X, CFrame5.Y - 3.5, CFrame5.Z) * Angles(rad(90), 0, rad(90))
                        })
                        v149.Velocity = _Vector3.zero
                    else
                        local v154 = u61(v149.Position, v150.Position)
                        if v154 <= 4.5 and not v150:GetAttribute("Collected") then
                            v150.CFrame = v149.CFrame * new2(random(-0.5, 0.5), random(-0.5, 2.5), random(-0.5, 0.5))
                        end
                    end
                end
            end
        end
    elseif u74 then
        u74 = false
        u76 = nil
        if LocalPlayer.Character then
            if u75 then u75:Cancel() end
            u67(false)
            u64(s1 or "Map")
            if u45 then
                local v155 = u59(LocalPlayer.Character, "Humanoid")
                if v155 then v155.Health = 0 end
            end
        end
    end
end)

-- ============================================================
-- OVERDRIVE'S SECOND HEARTBEAT (for void recovery)
-- ============================================================
local u77 = nil
RunService.Heartbeat:Connect(function()
    if not u44 then
        if u77 then
            u77 = false
            u64("Map")
        end
    elseif u58() < 1 and u47 and u48 and not u59(u48, "CoinContainer") then
        local v156 = nil
        u77 = true
        for _, v158 in _next, u48.Spawns:GetChildren() do
            if v158.Name == "Spawn" or v158.Name == "PlayerSpawn" or v158.Name == "SpawnLocation" then
                v156 = v158
            end
        end
        if v156 then
            local CFrame6 = v156.CFrame
            local v160 = u63(new2(CFrame6.X, CFrame6.Y - 999, CFrame6.Z).Position, u48)
            if v160 then
                local v161 = u60(LocalPlayer)
                if v161 then
                    local v162 = new2(CFrame6.X, v160.CFrame.Y - 15, CFrame6.Z)
                    v161.CFrame = v162
                    v161.Velocity = _Vector3.zero
                end
            end
        end
    else
        u77 = false
    end
end)

-- ============================================================
-- OVERDRIVE'S PERIODIC UPDATES (coroutine)
-- ============================================================
coroutine.wrap(function()
    while true do
        u7(0.5)
        if not LocalPlayer.Character then
            u47 = false
        else
            local v163 = ReplicatedStorage.Remotes.Extras.GetPlayerData:InvokeServer()
            if not v163 then
                u47 = false
            else
                local v164 = v163[LocalPlayer.Name]
                u47 = v164 and (not v164.Dead and not v164.Killed)
            end
        end
        for _, v166 in _next, _workspace:GetChildren() do
            if u59(v166, "CoinAreas") or u59(v166, "CoinContainer") then
                u48 = v166
            end
        end
        -- Update u49 periodically (in case UI changes)
        setup_u49()
    end
end)()

-- ============================================================
-- ANTI-FLING (our addition)
-- ============================================================
local lastPos = _Vector3.new()
local function AntiFlingCheck()
    if not antiFling then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = u60(LocalPlayer)
    if not hrp then return end
    if hrp.AssemblyLinearVelocity.Magnitude > 250 or hrp.AssemblyAngularVelocity.Magnitude > 250 then
        hrp.AssemblyLinearVelocity = _Vector3.zero
        hrp.AssemblyAngularVelocity = _Vector3.zero
        hrp.CFrame = new2(lastPos)
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
    if u75 then u75:Cancel() end
    u67(false)
    u74 = false
    u76 = nil
    setup_u49()
end)

-- ============================================================
-- DEBUG PRINTS (using Overdrive's coin reader)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(5)
        local coins = u65()
        local max = LocalPlayer:GetAttribute("Elite") and 50 or 40
        print(string.format("📊 Coins: %d  |  Max: %d  |  Reset Toggle: %s  |  u49: %s", coins, max, tostring(u45), tostring(u49)))
    end
end)

-- ============================================================
-- FINAL NOTIFICATION
-- ============================================================
Window:Notify({
    Title = "Bunnyware V5 🐰 Lite (Overdrive core)",
    Content = "Loaded! Coin reading uses Overdrive's exact method.",
    Duration = 5,
})

print("✅ Bunnyware V5 Lite with Overdrive's core logic loaded.")