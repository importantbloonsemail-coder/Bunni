-- ============================================================
-- Bunnyware – Murder Mystery 2
-- by Aleksandra "Drew" Malinina
-- ============================================================

-- 1. Load Luna
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

-- 2. Create Window
local Window = Luna:CreateWindow({
    Name = "Bunnyware",
    Subtitle = "by Aleksandra \"Drew\" Malinina",
    LogoID = nil,
    LoadingEnabled = true,
    LoadingTitle = "Bunnyware",
    LoadingSubtitle = "by Aleksandra \"Drew\" Malinina",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "Bunnyware"
    },
    KeySystem = false,
})

-- 3. Create all regular tabs FIRST
local MainTab = Window:CreateTab({ Name = "Main", Icon = "cottage", ImageSource = "Material", ShowTitle = true })
local AimbotTab = Window:CreateTab({ Name = "Aimbot", Icon = "gps_fixed", ImageSource = "Material", ShowTitle = true })
local ESPTab = Window:CreateTab({ Name = "ESP", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
local AutoTab = Window:CreateTab({ Name = "Auto", Icon = "play_arrow", ImageSource = "Material", ShowTitle = true })
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "sports_kabaddi", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "info", ImageSource = "Material", ShowTitle = true })

-- 4. Home Tab
Window:CreateHomeTab({
    SupportedExecutors = {"Synapse X", "Krnl", "ScriptWare", "Fluxus", "Other"},
    DiscordInvite = "yourdiscord",
    Icon = 2,
})

-- ============================================================
-- MAIN TAB (movement, teleports, round timer)
-- ============================================================
MainTab:CreateParagraph({
    Title = "Welcome to Bunnyware",
    Text = "A powerful MM2 script by Aleksandra \"Drew\" Malinina.\nAll movement, teleports, and utilities are here."
})

-- Speed & Jump
local speedHack = false
local speedValue = 25
local jumpPower = false
local jumpValue = 75
local antiFling = false
local flyEnabled = false
local antiAFK = false
local noclipEnabled = false

MainTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(v) speedHack = v end
}, "SpeedHack")

MainTab:CreateSlider({
    Name = "Speed Amount",
    Description = "Default: 25  |  Range: 16 - 100",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(v) speedValue = v end
}, "SpeedAmount")

MainTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Callback = function(v) jumpPower = v end
}, "JumpPower")

MainTab:CreateSlider({
    Name = "Jump Height",
    Description = "Default: 75  |  Range: 50 - 200",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 75,
    Callback = function(v) jumpValue = v end
}, "JumpHeight")

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        if v then
            local char = game.Players.LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1/0,1/0,1/0)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.Parent = root
                    root:SetAttribute("FlyBV", bv)
                end
            end
        else
            local char = game.Players.LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = root:GetAttribute("FlyBV")
                    if bv then bv:Destroy() end
                end
            end
        end
    end
}, "Fly")

MainTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Callback = function(v) antiFling = v end
}, "AntiFling")

MainTab:CreateToggle({
    Name = "Anti-AFK Kick",
    Description = "Prevents being kicked for idle.",
    CurrentValue = false,
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
}, "AntiAFK")

MainTab:CreateToggle({
    Name = "Noclip",
    Description = "Walk through walls and parts.",
    CurrentValue = false,
    Callback = function(v) noclipEnabled = v end
}, "Noclip")

-- Teleports
MainTab:CreateParagraph({
    Title = "Teleports",
    Text = "Jump to lobby, map, or dropped gun."
})

MainTab:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        local lobby = workspace:FindFirstChild("Lobby")
        if lobby then
            local spawn = lobby:FindFirstChild("Spawns")
            if spawn then
                local sp = spawn:FindFirstChildWhichIsA("SpawnLocation") or spawn:GetChildren()[1]
                if sp then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(sp.Position)
                    end
                end
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Teleport to Map",
    Callback = function()
        local map = nil
        for _, o in ipairs(workspace:GetChildren()) do
            if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
                map = o
                break
            end
        end
        if map then
            local spawns = map:FindFirstChild("Spawns")
            if spawns then
                local children = spawns:GetChildren()
                if #children > 0 then
                    local sp = children[math.random(1, #children)]
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(sp.Position)
                    end
                end
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Teleport to Dropped Gun",
    Callback = function()
        local map = nil
        for _, o in ipairs(workspace:GetChildren()) do
            if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
                map = o
                break
            end
        end
        if not map then print("No map found.") return end
        local gunDrop = map:FindFirstChild("GunDrop")
        if not gunDrop then print("No dropped gun found.") return end
        local localPlayer = game.Players.LocalPlayer
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 2, 0))
        end
    end
})

-- Round Timer
local roundTimerEnabled = false
local roundTimerLabel = nil
local roundTimerTask = nil

local function secondsToMinutes(seconds)
    if seconds == -1 then return "" end
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%dm %ds", mins, secs)
end

MainTab:CreateToggle({
    Name = "Round Timer",
    Description = "Shows remaining round time on screen.",
    CurrentValue = false,
    Callback = function(v)
        roundTimerEnabled = v
        if v then
            if not roundTimerLabel then
                roundTimerLabel = Instance.new("TextLabel")
                roundTimerLabel.Parent = game:GetService("CoreGui")
                roundTimerLabel.BackgroundTransparency = 1
                roundTimerLabel.TextColor3 = Color3.new(1,1,1)
                roundTimerLabel.TextScaled = true
                roundTimerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                roundTimerLabel.Position = UDim2.new(0.5, 0, 0.15, 0)
                roundTimerLabel.Size = UDim2.new(0, 200, 0, 35)
                roundTimerLabel.Font = Enum.Font.Montserrat
                roundTimerLabel.Text = "0m 0s"
            end
            roundTimerLabel.Visible = true
            if not roundTimerTask then
                roundTimerTask = task.spawn(function()
                    while roundTimerEnabled do
                        task.wait(0.5)
                        local timePart = workspace:FindFirstChild("RoundTimerPart")
                        if timePart and timePart:GetAttribute("Time") then
                            local timeLeft = timePart:GetAttribute("Time")
                            roundTimerLabel.Text = secondsToMinutes(timeLeft)
                        else
                            roundTimerLabel.Text = "0m 0s"
                        end
                    end
                end)
            end
        else
            if roundTimerLabel then roundTimerLabel.Visible = false end
            if roundTimerTask then
                task.cancel(roundTimerTask)
                roundTimerTask = nil
            end
        end
    end
}, "RoundTimer")

-- ============================================================
-- AIMBOT TAB (unchanged)
-- ============================================================
local aimbotEnabled = false
local aimbotTarget = "Murderer"
local smoothness = 0.5
local fov = 90
local offset = 2.8

AimbotTab:CreateToggle({
    Name = "Enable Visual Aimbot",
    Description = "Moves your camera to aim at the target (no prediction).",
    CurrentValue = false,
    Callback = function(v) aimbotEnabled = v end
}, "AimbotEnabled")

AimbotTab:CreateDropdown({
    Name = "Target",
    Options = {"Murderer", "Sheriff", "All"},
    CurrentOption = {"Murderer"},
    MultipleOptions = false,
    Callback = function(opt) aimbotTarget = opt end
}, "AimbotTarget")

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Description = "Default: 0.5  |  Range: 0.0 - 1.0",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.5,
    Callback = function(v) smoothness = v end
}, "Smoothness")

AimbotTab:CreateSlider({
    Name = "FOV (Field of View)",
    Description = "Default: 90  |  Range: 0 - 360",
    Range = {0, 360},
    Increment = 5,
    CurrentValue = 90,
    Callback = function(v) fov = v end
}, "FOV")

AimbotTab:CreateSlider({
    Name = "Prediction Offset (Silent Shoot & Knife)",
    Description = "Default: 2.8  |  Range: 0.0 - 10.0",
    Range = {0, 10},
    Increment = 0.1,
    CurrentValue = 2.8,
    Callback = function(v) offset = v end
}, "Offset")

-- ============================================================
-- ESP TAB (with Dropped Gun label)
-- ============================================================
local espEnabled = false
local espPlayer = false
local espMurderer = false
local espSheriff = false
local espDroppedGun = false
local espCoins = false

local espHighlights = {}
local espLabels = {}

local function clearESP()
    for _, h in ipairs(espHighlights) do
        pcall(function() h:Destroy() end)
    end
    espHighlights = {}
    for _, lbl in ipairs(espLabels) do
        pcall(function() lbl:Destroy() end)
    end
    espLabels = {}
end

local function refreshESP()
    clearESP()
    if not espEnabled then return end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local isMurderer = pl.Character:FindFirstChild("Knife") or pl.Backpack:FindFirstChild("Knife")
            local isSheriff = pl.Character:FindFirstChild("Gun") or pl.Backpack:FindFirstChild("Gun")
            local show = false
            if espPlayer then show = true end
            if espMurderer and isMurderer then show = true end
            if espSheriff and isSheriff then show = true end

            if show then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = pl.Character
                highlight.FillColor = isMurderer and Color3.new(1,0,0) or (isSheriff and Color3.new(0,0.6,1) or Color3.new(0,1,0))
                highlight.OutlineColor = highlight.FillColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = game:GetService("CoreGui")
                table.insert(espHighlights, highlight)
            end
        end
    end

    if espDroppedGun then
        local map = nil
        for _, o in ipairs(workspace:GetChildren()) do
            if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then
                map = o
                break
            end
        end
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if gunDrop then
                local h = Instance.new("Highlight")
                h.Adornee = gunDrop
                h.FillColor = Color3.new(1,1,0)
                h.OutlineColor = Color3.new(1,1,0)
                h.FillTransparency = 0.3
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = game:GetService("CoreGui")
                table.insert(espHighlights, h)

                local bill = Instance.new("BillboardGui")
                bill.Adornee = gunDrop
                bill.Size = UDim2.new(0, 120, 0, 30)
                bill.StudsOffset = Vector3.new(0, 2, 0)
                bill.AlwaysOnTop = true
                bill.Parent = game:GetService("CoreGui")
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "🔫 Dropped Gun"
                label.TextColor3 = Color3.new(1,1,0)
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                label.Parent = bill
                table.insert(espLabels, bill)
            end
        end
    end

    if espCoins then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name == "Coin" then
                local h = Instance.new("Highlight")
                h.Adornee = obj
                h.FillColor = Color3.new(1,0.8,0)
                h.OutlineColor = Color3.new(1,0.8,0)
                h.FillTransparency = 0.3
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = game:GetService("CoreGui")
                table.insert(espHighlights, h)
            end
        end
    end
end

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(v)
        espEnabled = v
        if v then refreshESP() else clearESP() end
    end
}, "ESPEnabled")

ESPTab:CreateToggle({
    Name = "Show Players",
    CurrentValue = false,
    Callback = function(v) espPlayer = v; refreshESP() end
}, "ESPPlayer")

ESPTab:CreateToggle({
    Name = "Highlight Murderer",
    CurrentValue = false,
    Callback = function(v) espMurderer = v; refreshESP() end
}, "ESPMurderer")

ESPTab:CreateToggle({
    Name = "Highlight Sheriff",
    CurrentValue = false,
    Callback = function(v) espSheriff = v; refreshESP() end
}, "ESPSheriff")

ESPTab:CreateToggle({
    Name = "Dropped Gun ESP",
    CurrentValue = false,
    Callback = function(v) espDroppedGun = v; refreshESP() end
}, "ESPDroppedGun")

ESPTab:CreateToggle({
    Name = "Show Coins",
    CurrentValue = false,
    Callback = function(v) espCoins = v; refreshESP() end
}, "ESPCoins")

-- ============================================================
-- AUTO TAB (unchanged)
-- ============================================================
local autoCollectCoins = false
local autoFarm = false
local autoReady = false
local coinAvoidDistance = 20
local autoResetOnMax = false
local flingMurdererAfterFarm = false
local maxCoins = 40
local returnLocation = "Map"

AutoTab:CreateSlider({
    Name = "Murderer Avoidance Radius",
    Description = "Default: 20  |  Range: 20 - 80",
    Range = {20, 80},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(v) coinAvoidDistance = v end
}, "CoinAvoidDistance")

AutoTab:CreateSlider({
    Name = "Max Coins Before Reset",
    Description = "Default: 40  |  Range: 1 - 200",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = 40,
    Callback = function(v) maxCoins = v end
}, "MaxCoins")

AutoTab:CreateDropdown({
    Name = "Return To Location",
    Description = "Where to teleport after reset or manual stop.",
    Options = {"Map", "Above Map", "Voting Map", "Void", "Lobby"},
    CurrentOption = {"Map"},
    MultipleOptions = false,
    Callback = function(opt) returnLocation = opt end
}, "ReturnLocation")

AutoTab:CreateToggle({
    Name = "Auto Collect Coins",
    Description = "Farms coins using advanced tweening with BodyGyro/BodyVelocity.",
    CurrentValue = false,
    Callback = function(v)
        autoCollectCoins = v
        if not v then cleanupAutofarm() end
    end
}, "AutoCollectCoins")

AutoTab:CreateToggle({
    Name = "Auto Reset on Max Coins",
    Description = "Kills your character when max coins are reached.",
    CurrentValue = false,
    Callback = function(v) autoResetOnMax = v end
}, "AutoReset")

AutoTab:CreateToggle({
    Name = "Fling Murderer After Farm",
    Description = "Fling the murderer after collecting all coins.",
    CurrentValue = false,
    Callback = function(v) flingMurdererAfterFarm = v end
}, "FlingMurdererAfterFarm")

AutoTab:CreateToggle({
    Name = "Auto Farm (Sheriff)",
    Description = "Automatically shoots murderer when you are Sheriff.",
    CurrentValue = false,
    Callback = function(v) autoFarm = v end
}, "AutoFarm")

AutoTab:CreateToggle({
    Name = "Auto Ready",
    CurrentValue = false,
    Callback = function(v) autoReady = v end
}, "AutoReady")

-- ============================================================
-- COMBAT TAB (unchanged)
-- ============================================================
local function findMurderer()
    for _, i in ipairs(game.Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
        if i.Backpack and i.Backpack:FindFirstChild("Knife") then return i end
    end
    return nil
end

local function findSheriff()
    for _, i in ipairs(game.Players:GetPlayers()) do
        if i.Character and (i.Character:FindFirstChild("Gun") or i.Character:FindFirstChild("Pistol")) then return i end
        if i.Backpack and (i.Backpack:FindFirstChild("Gun") or i.Backpack:FindFirstChild("Pistol")) then return i end
    end
    return nil
end

local function getPredictedPosition(player, offset)
    if not player or not player.Character then return nil end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local pos = hrp.Position
    local vel = hrp.AssemblyLinearVelocity
    return pos + vel * (offset / 20)
end

local function getNearestPlayer()
    local localPlayer = game.Players.LocalPlayer
    local char = localPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, pl in ipairs(game.Players:GetPlayers()) do
        if pl ~= localPlayer and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = pl
                end
            end
        end
    end
    return nearest
end

local function throwKnifeAt(target)
    if not target or not target.Character then return false end
    local localPlayer = game.Players.LocalPlayer
    local char = localPlayer.Character
    if not char then return false end
    local knife = char:FindFirstChild("Knife")
    if not knife then
        local bp = localPlayer.Backpack
        if bp then
            knife = bp:FindFirstChild("Knife")
            if knife then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(knife) end
                task.wait(0.1)
                knife = char:FindFirstChild("Knife")
            end
        end
    end
    if not knife then return false end

    local predicted = getPredictedPosition(target, offset)
    if not predicted then return false end

    local events = knife:FindFirstChild("Events")
    if events then
        local throwRemote = events:FindFirstChild("KnifeThrown")
        if throwRemote and throwRemote:IsA("RemoteEvent") then
            throwRemote:FireServer(CFrame.new(char.RightHand.Position), CFrame.new(predicted))
            return true
        end
    end
    local remote = knife:FindFirstChild("Throw") or knife:FindFirstChild("Remote")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(CFrame.new(char.RightHand.Position), CFrame.new(predicted))
        return true
    end
    return false
end

CombatTab:CreateButton({
    Name = "Throw Knife Now",
    Description = "Throws knife at nearest player (manual, uses prediction offset).",
    Callback = function()
        local target = getNearestPlayer()
        if target then
            throwKnifeAt(target)
        else
            print("No player nearby.")
        end
    end
})

CombatTab:CreateButton({
    Name = "Silent Shoot (Murderer)",
    Description = "Shoots the murderer with prediction, without moving your camera.",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if findSheriff() ~= localPlayer then
            print("You are not Sheriff.")
            return
        end
        local murderer = findMurderer()
        if not murderer then
            print("No murderer found.")
            return
        end
        local char = localPlayer.Character
        if not char then return end
        local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Pistol")
        if not gun then
            local bp = localPlayer.Backpack
            if bp then
                gun = bp:FindFirstChild("Gun") or bp:FindFirstChild("Pistol")
                if gun then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(gun) end
                    task.wait(0.1)
                    gun = char:FindFirstChild("Gun") or char:FindFirstChild("Pistol")
                end
            end
        end
        if not gun then
            print("You don't have a gun.")
            return
        end

        local predicted = getPredictedPosition(murderer, offset)
        if not predicted then return end

        local remote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Remote")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(CFrame.new(char.RightHand.Position), CFrame.new(predicted))
        else
            local createBeam = gun:FindFirstChild("KnifeLocal")
            if createBeam then
                local rf = createBeam:FindFirstChild("CreateBeam")
                if rf and rf:IsA("RemoteFunction") then
                    rf:InvokeServer(1, predicted, "AH2")
                end
            end
        end
        print("Silent shot fired.")
    end
})

local autoKnifeThrow = false
local knifeThrowCooldown = false

CombatTab:CreateToggle({
    Name = "Auto Knife Throw",
    Description = "Automatically throws knife at nearest player when you are Murderer.",
    CurrentValue = false,
    Callback = function(v)
        autoKnifeThrow = v
        knifeThrowCooldown = false
    end
}, "AutoKnifeThrow")

local function miniFling(playerToFling)
    if not playerToFling or not playerToFling.Character then return end
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local targetChar = playerToFling.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    getgenv().OldPos = rootPart.CFrame
    targetRoot.Anchored = true
    targetRoot.CFrame = rootPart.CFrame * CFrame.new(0, 1.5, 0)
    task.wait(0.1)
    targetRoot.Anchored = false
    targetRoot.AssemblyLinearVelocity = Vector3.new(9e7, 9e7 * 10, 9e7)
    targetRoot.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
    task.wait(0.5)
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        targetRoot.CFrame = CFrame.new(getgenv().OldPos.p + Vector3.new(0, 2, 0))
    end
end

CombatTab:CreateParagraph({
    Title = "Fling",
    Text = "Launch other players."
})

CombatTab:CreateButton({
    Name = "Fling Murderer",
    Callback = function()
        local murderer = findMurderer()
        if murderer then miniFling(murderer) else print("No murderer found.") end
    end
})

CombatTab:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        local sheriff = findSheriff()
        if sheriff then miniFling(sheriff) else print("No sheriff found.") end
    end
})

-- ============================================================
-- MISC TAB (only Info and Performance)
-- ============================================================
MiscTab:CreateParagraph({
    Title = "Info",
    Text = "Copy names, broadcast roles, get ping."
})

MiscTab:CreateButton({
    Name = "Copy Murderer Name",
    Callback = function()
        local murd = findMurderer()
        if murd then
            if setclipboard then setclipboard(murd.Name) end
            print("Murderer name copied: " .. murd.Name)
        else
            print("No murderer found.")
        end
    end
})

MiscTab:CreateButton({
    Name = "Copy Sheriff Name",
    Callback = function()
        local sher = findSheriff()
        if sher then
            if setclipboard then setclipboard(sher.Name) end
            print("Sheriff name copied: " .. sher.Name)
        else
            print("No sheriff found.")
        end
    end
})

MiscTab:CreateButton({
    Name = "Send Roles to Chat",
    Callback = function()
        local murd = findMurderer()
        local sher = findSheriff()
        local murdName = murd and murd.Name or "Unknown"
        local sherName = sher and sher.Name or "Unknown"
        local msg = string.format("Murderer: %s | Sheriff: %s | <<Bunnyware>>", murdName, sherName)
        local textChannels = game:GetService("TextChatService"):FindFirstChild("TextChannels")
        if textChannels then
            for _, ch in ipairs(textChannels:GetChildren()) do
                if ch.Name ~= "RBXSystem" then
                    pcall(function() ch:SendAsync(msg) end)
                end
            end
        end
        print("Roles sent to chat.")
    end
})

MiscTab:CreateButton({
    Name = "Get Ping",
    Callback = function()
        local ping = game.Players.LocalPlayer:GetNetworkPing() * 1000
        if getgenv().YARHMFUNCTIONS and getgenv().YARHMFUNCTIONS.notification then
            getgenv().YARHMFUNCTIONS.notification(string.format("Ping: %.0f ms", ping))
        else
            print(string.format("Ping: %.0f ms", ping))
        end
    end
})

MiscTab:CreateParagraph({
    Title = "Performance",
    Text = "Boost FPS."
})

MiscTab:CreateButton({
    Name = "FPS Boost",
    Callback = function()
        local Terrain = workspace:FindFirstChildOfClass('Terrain')
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 9e9
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            end
        end
        for _, v in ipairs(game.Lighting:GetDescendants()) do
            if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
        print("FPS Boost applied.")
    end
})

-- ============================================================
-- CORE ENGINE – AUTOFARM (advanced tweening loop)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State variables
local u44 = false
local u45 = false
local u47 = false
local u48 = nil
local u74 = false
local u75 = nil
local u76 = nil
local s1 = "Map"

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

local function u65()
    local gui = LocalPlayer.PlayerGui
    if gui then
        local main = gui:FindFirstChild("MainGUI")
        if main then
            local gameUI = main:FindFirstChild("Game")
            if gameUI then
                local coinText = gameUI:FindFirstChild("CoinBags") and gameUI.CoinBags:FindFirstChild("Container") and gameUI.CoinBags.Container