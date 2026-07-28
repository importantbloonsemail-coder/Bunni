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
local MainTab = Window:CreateTab({ Name = "Main", Icon = "home", ImageSource = "Material", ShowTitle = true })
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
local espLabels = {}  -- for dropped gun labels

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
                -- Highlight
                local h = Instance.new("Highlight")
                h.Adornee = gunDrop
                h.FillColor = Color3.new(1,1,0)
                h.OutlineColor = Color3.new(1,1,0)
                h.FillTransparency = 0.3
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = game:GetService("CoreGui")
                table.insert(espHighlights, h)

                -- Billboard label
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

-- State variables (mirroring proven farm logic)
local u44 = false   -- auto farm toggle (mirrored)
local u45 = false   -- auto reset toggle (mirrored)
local u47 = false   -- player alive in game (mirrored)
local u48 = nil     -- map reference
local u74 = false   -- currently moving to coin
local u75 = nil     -- current tween
local u76 = nil     -- current target coin
local s1 = "Map"    -- return location

-- Helper functions (proven logic from advanced farms)
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
                local coinText = gameUI:FindFirstChild("CoinBags") and gameUI.CoinBags:FindFirstChild("Container") and gameUI.CoinBags.Container:FindFirstChild("Candy") and gameUI.CoinBags.Container.Candy:FindFirstChild("CurrencyFrame") and gameUI.CoinBags.Container.Candy.CurrencyFrame:FindFirstChild("Icon") and gameUI.CoinBags.Container.Candy.CurrencyFrame.Icon:FindFirstChild("Coins")
                if coinText then
                    return tonumber(coinText.Text) or 0
                end
            end
        end
    end
    return 0
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
    local hum = u59(LocalPlayer.Character, "Humanoid")
    if hum then
        u47 = (hum.Health > 0)
    else
        u47 = false
    end
end

-- Main heartbeat loop (proven farm logic)
RunService.Heartbeat:Connect(function()
    if not autoCollectCoins then
        if u74 then
            cleanupAutofarm()
        end
        return
    end

    updateMap()
    updateAliveStatus()

    local roundTime = u58()
    if roundTime <= 0 then
        if u74 then
            cleanupAutofarm()
        end
        return
    end

    if not u47 then
        if u74 then
            cleanupAutofarm()
        end
        return
    end

    local currentCoins = u65()
    if autoResetOnMax and currentCoins >= maxCoins then
        local hum = u59(LocalPlayer.Character, "Humanoid")
        if hum then
            hum.Health = 0
            print("Max coins reached. Resetting.")
            cleanupAutofarm()
            u64(returnLocation)
        end
        return
    end

    if not u74 then
        local targetCoin = u62()
        if not targetCoin then
            if flingMurdererAfterFarm then
                local murd = findMurderer()
                if murd then miniFling(murd) end
            end
            u64(returnLocation)
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
        local duration = distance * 0.04465
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
-- OTHER CORE FEATURES (unchanged)
-- ============================================================
local function GetAimbotTarget()
    local best, bestAngle = nil, fov
    local camCF = Camera.CFrame
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local hrp = u60(pl)
            if hrp then
                local pos = hrp.Position
                local screenPos, onScreen = Camera:WorldToScreenPoint(pos)
                if onScreen then
                    local vec = (pos - camCF.Position).unit
                    local angle = math.deg(math.acos(camCF.LookVector:Dot(vec)))
                    if angle < bestAngle then
                        local isMurderer = findMurderer() == pl
                        local isSheriff = findSheriff() == pl
                        local match = (aimbotTarget == "Murderer" and isMurderer) or
                                      (aimbotTarget == "Sheriff" and isSheriff) or
                                      (aimbotTarget == "All")
                        if match then
                            bestAngle = angle
                            best = pl
                        end
                    end
                end
            end
        end
    end
    return best
end

local function AimAtVisual(target)
    if not target then return end
    local hrp = u60(target)
    if not hrp then return end
    local pos = hrp.Position
    local targetCF = CFrame.new(Camera.CFrame.Position, pos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - smoothness)
end

local function AutoShoot()
    if not autoFarm then return end
    if findSheriff() ~= LocalPlayer then return end
    local murderer = findMurderer()
    if murderer then
        local predicted = getPredictedPosition(murderer, offset)
        if predicted then
            local char = LocalPlayer.Character
            if char then
                local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Pistol")
                if gun then
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
                end
            end
        end
    end
end

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

local function ApplyMisc()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = u59(char, "Humanoid")
    if not hum then return end

    if speedHack then
        hum.WalkSpeed = speedValue
    else
        hum.WalkSpeed = 16
    end
    if jumpPower then
        hum.JumpPower = jumpValue
    else
        hum.JumpPower = 50
    end

    if noclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if flyEnabled then
        local root = u60(LocalPlayer)
        if root then
            local bv = root:GetAttribute("FlyBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1/0,1/0,1/0)
                bv.Velocity = Vector3.new(0,0,0)
                bv.Parent = root
                root:SetAttribute("FlyBV", bv)
            end
            local move = hum.MoveDirection
            if move.Magnitude > 0 then
                bv.Velocity = move * 50
            else
                bv.Velocity = Vector3.new(0,0,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                bv.Velocity = bv.Velocity + Vector3.new(0, 30, 0)
            end
        end
    end
end

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

local function AutoKnifeThrowLoop()
    if not autoKnifeThrow then return end
    if findMurderer() ~= LocalPlayer then return end
    if knifeThrowCooldown then return end
    local target = getNearestPlayer()
    if target then
        local success = throwKnifeAt(target)
        if success then
            knifeThrowCooldown = true
            task.wait(1.5)
            knifeThrowCooldown = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetAimbotTarget()
        if target then
            AimAtVisual(target)
        end
    end
    AutoShoot()
    ApplyMisc()
    AntiFlingCheck()
    AutoKnifeThrowLoop()
end)

local function onGameStart()
    task.wait(1)
    ReadyUp()
end

local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GameStart")
if remote then
    remote.OnClientEvent:Connect(onGameStart)
end

Players.PlayerAdded:Connect(refreshESP)
Players.PlayerRemoved:Connect(refreshESP)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplyMisc()
    refreshESP()
    cleanupAutofarm()
end)

print("✅ Bunnyware loaded successfully! (by Aleksandra \"Drew\" Malinina)")
