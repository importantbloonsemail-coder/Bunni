-- ============================================================
-- Bunnyware V5 🐰 | Join discord.gg/6PJZa9BP7G for updates
-- by Aleksandra "Drew" Malinina
-- Migrated to WindUI for enhanced stability.
-- ============================================================

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Bunnyware V5 🐰 | Join discord.gg/6PJZa9BP7G for updates",
    Author = "by Aleksandra \"Drew\" Malinina",
    Folder = "BunnywareConfig",
    Icon = "solar:folder-2-bold-duotone",
    ToggleKey = Enum.KeyCode.RightControl,
})

-- ============================================================
-- MAIN TAB
-- ============================================================
local MainTab = Window:Tab({ Title = "Main", Icon = "list" })
local MainSection = MainTab:Section({ Title = "Movement & Utilities", Opened = true })

-- Speed & Jump
local speedHack = false
local speedValue = 25
local jumpPower = false
local jumpValue = 75
local infiniteJump = false
local antiFling = false
local flyEnabled = false
local antiAFK = false
local noclipEnabled = false

MainSection:Toggle({
    Title = "Speed Hack",
    Desc = "Increases your walkspeed",
    Value = false,
    Callback = function(v) speedHack = v end
})

MainSection:Slider({
    Title = "Speed Amount",
    Desc = "Default: 25  |  Range: 16 - 100",
    Step = 1,
    Value = { Min = 16, Max = 100, Default = 25 },
    Callback = function(v) speedValue = v end
})

MainSection:Toggle({
    Title = "Jump Power",
    Desc = "Increases your jump height",
    Value = false,
    Callback = function(v) jumpPower = v end
})

MainSection:Slider({
    Title = "Jump Height",
    Desc = "Default: 75  |  Range: 50 - 200",
    Step = 5,
    Value = { Min = 50, Max = 200, Default = 75 },
    Callback = function(v) jumpValue = v end
})

-- Infinite Jump
local infJumpConnection = nil
local infJumpDebounce = false

local function enableInfiniteJump()
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
    infJumpDebounce = false
    infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
        if not infJumpDebounce and infiniteJump then
            infJumpDebounce = true
            local char = game.Players.LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            task.wait()
            infJumpDebounce = false
        end
    end)
end

local function disableInfiniteJump()
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
    infJumpDebounce = false
end

MainSection:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump infinitely in the air",
    Value = false,
    Callback = function(v)
        infiniteJump = v
        if v then
            enableInfiniteJump()
        else
            disableInfiniteJump()
        end
    end
})

MainSection:Toggle({
    Title = "Anti-Fling",
    Desc = "Prevents you from being flung",
    Value = false,
    Callback = function(v) antiFling = v end
})

MainSection:Toggle({
    Title = "Anti-AFK Kick",
    Desc = "Prevents being kicked for AFK",
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

MainSection:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(v) noclipEnabled = v end
})

-- ============================================================
-- PLAYER FLING
-- ============================================================
local FlingSection = MainTab:Section({ Title = "Player Fling", Opened = true })

local selectedFlingPlayer = nil
local flingDropdown = nil

local function getPlayerList()
    local names = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    if #names == 0 then
        names = {"No players"}
    end
    return names
end

local function updateFlingDropdown()
    if flingDropdown then
        local list = getPlayerList()
        flingDropdown:Refresh(list)
        if selectedFlingPlayer and not game.Players:FindFirstChild(selectedFlingPlayer) then
            selectedFlingPlayer = nil
        end
        if not selectedFlingPlayer and list[1] ~= "No players" then
            selectedFlingPlayer = list[1]
        end
        flingDropdown:SetValue(selectedFlingPlayer or "No players")
    end
end

flingDropdown = FlingSection:Dropdown({
    Title = "Select Player to Fling",
    Desc = "Choose a player to fling across the map",
    Values = getPlayerList(),
    Value = getPlayerList()[1] or "No players",
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        selectedFlingPlayer = option
    end
})

-- Update dropdown when players join/leave
game.Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updateFlingDropdown()
end)
game.Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    updateFlingDropdown()
end)

local function flingSelectedPlayer()
    if not selectedFlingPlayer or selectedFlingPlayer == "No players" then
        Window:Notify({
            Title = "Fling",
            Content = "No player selected!",
            Duration = 2,
        })
        return
    end
    local target = game.Players:FindFirstChild(selectedFlingPlayer)
    if not target then
        Window:Notify({
            Title = "Fling",
            Content = "Player not found!",
            Duration = 2,
        })
        return
    end
    if not target.Character then
        Window:Notify({
            Title = "Fling",
            Content = "Player has no character!",
            Duration = 2,
        })
        return
    end
    if type(flingPlayer) == "function" then
        flingPlayer(target)
        Window:Notify({
            Title = "Fling",
            Content = "Flinging " .. target.Name,
            Duration = 2,
        })
    else
        print("flingPlayer not available")
    end
end

FlingSection:Button({
    Title = "Fling Selected Player",
    Desc = "Launches the selected player into the air",
    Callback = flingSelectedPlayer
})

-- ============================================================
-- INVISIBILITY (Vertex-style) – FAST TOGGLE
-- ============================================================
local InvisibilitySection = MainTab:Section({ Title = "Invisibility", Opened = true })

local invisibilityEnabled = false
local invisibilityKeybind = Enum.KeyCode.Y
local invisibilityTask = nil

local function toggleInvisibility()
    if invisibilityTask then
        task.cancel(invisibilityTask)
        invisibilityTask = nil
    end

    invisibilityEnabled = not invisibilityEnabled
    local enable = invisibilityEnabled

    invisibilityTask = task.spawn(function()
        local char = game.Players.LocalPlayer.Character
        if not char then
            invisibilityTask = nil
            return
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then
            invisibilityTask = nil
            return
        end

        if enable then
            getgenv().Invis_SavedCFrame = hrp.CFrame
            getgenv().Invis_OriginalCameraSubject = workspace.CurrentCamera.CameraSubject
            getgenv().Invis_OriginalAutoRotate = humanoid.AutoRotate
            getgenv().Invis_Humanoid = humanoid

            local function isTool(part)
                local parent = part.Parent
                while parent and parent ~= char do
                    if parent:IsA("Tool") then
                        return true
                    end
                    parent = parent.Parent
                end
                return false
            end

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not isTool(part) then
                    part.LocalTransparencyModifier = 1
                end
            end

            getgenv().Invis_Connection = char.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("BasePart") and not isTool(descendant) then
                    descendant.LocalTransparencyModifier = 1
                end
            end)

            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.Parent = char
            getgenv().Invis_Outline = highlight

            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)

            local seat = Instance.new("Seat", workspace)
            seat.Anchored = false
            seat.CanCollide = false
            seat.Name = "InvisChair"
            seat.Transparency = 1
            seat.Position = Vector3.new(-25.95, 84, 3537.55)

            workspace.CurrentCamera.CameraSubject = hrp

            local weld = Instance.new("Weld", seat)
            weld.Part0 = seat
            weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

            task.wait()
            seat.CFrame = getgenv().Invis_SavedCFrame

            getgenv().Invis_Seat = seat

            local UserInputService = game:GetService("UserInputService")
            getgenv().Invis_RotationConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not invisibilityEnabled or not seat then return end

                local hum = getgenv().Invis_Humanoid
                if not hum then return end

                if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                    hum.AutoRotate = false
                    local cam = workspace.CurrentCamera
                    local look = cam.CFrame.LookVector
                    look = Vector3.new(look.X, 0, look.Z).Unit
                    if look.Magnitude > 0 then
                        seat.CFrame = CFrame.new(seat.Position, seat.Position + look)
                    end
                else
                    hum.AutoRotate = true
                end
            end)

            Window:Notify({
                Title = "Invisibility",
                Content = "Enabled",
                Duration = 1,
            })
        else
            if getgenv().Invis_Connection then
                getgenv().Invis_Connection:Disconnect()
                getgenv().Invis_Connection = nil
            end

            if getgenv().Invis_RotationConnection then
                getgenv().Invis_RotationConnection:Disconnect()
                getgenv().Invis_RotationConnection = nil
            end

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end

            if humanoid then
                humanoid.AutoRotate = getgenv().Invis_OriginalAutoRotate ~= nil and getgenv().Invis_OriginalAutoRotate or true
            end

            if getgenv().Invis_OriginalCameraSubject then
                workspace.CurrentCamera.CameraSubject = getgenv().Invis_OriginalCameraSubject
            end

            if getgenv().Invis_Outline then
                getgenv().Invis_Outline:Destroy()
                getgenv().Invis_Outline = nil
            end

            local seat = getgenv().Invis_Seat
            if seat then
                seat:Destroy()
                getgenv().Invis_Seat = nil
            end

            getgenv().Invis_SavedCFrame = nil
            getgenv().Invis_OriginalCameraSubject = nil
            getgenv().Invis_OriginalAutoRotate = nil
            getgenv().Invis_Humanoid = nil

            Window:Notify({
                Title = "Invisibility",
                Content = "Disabled",
                Duration = 1,
            })
        end

        invisibilityTask = nil
    end)
end

MainSection:Toggle({
    Title = "Invisibility",
    Desc = "Makes you invisible to other players (Vertex-style)",
    Value = false,
    Callback = function(v)
        if v ~= invisibilityEnabled then
            toggleInvisibility()
        end
    end
})

MainSection:Keybind({
    Title = "Invisibility Keybind",
    Desc = "Press to toggle invisibility on/off",
    Value = "Y",
    Callback = function(key)
        invisibilityKeybind = key
        print("Invisibility keybind set to:", key.Name)
    end
})

local invisKeybindConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == invisibilityKeybind then
        toggleInvisibility()
    end
end)

local function createFloatingInvisibilityButton()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BunnywareFloatingInvis"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 45)
    button.Position = UDim2.new(0.5, -80, 0.5, -22.5)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Text = "Invis: OFF"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 20
    button.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1
    stroke.Parent = button

    local dragging = false
    local dragStart = nil
    local startPos = nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    button.MouseButton1Click:Connect(function()
        toggleInvisibility()
        button.Text = "Invis: " .. (invisibilityEnabled and "ON" or "OFF")
    end)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 22, 0, 22)
    close.Position = UDim2.new(1, -26, 0, 2)
    close.AnchorPoint = Vector2.new(1, 0)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextScaled = true
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.ZIndex = 21
    close.Parent = button
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

MainSection:Button({
    Title = "Create Floating Invisibility Toggle",
    Desc = "Creates a movable button to toggle invisibility",
    Callback = createFloatingInvisibilityButton
})

-- ============================================================
-- TELEPORTS
-- ============================================================
local TeleportSection = MainTab:Section({ Title = "Teleports", Opened = true })

TeleportSection:Button({
    Title = "Teleport to Lobby",
    Desc = "Teleports you to the lobby",
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

TeleportSection:Button({
    Title = "Teleport to Map",
    Desc = "Teleports you to the current map",
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

local teleportReturnPos = nil

TeleportSection:Button({
    Title = "Teleport to Dropped Gun",
    Desc = "Teleports you to the dropped gun",
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
            teleportReturnPos = char.HumanoidRootPart.CFrame
            char.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 2, 0))
            task.wait(0.5)
            local gotGun = false
            if char:FindFirstChild("Gun") or char:FindFirstChild("Pistol") then
                gotGun = true
            end
            if not gotGun then
                local bp = localPlayer.Backpack
                if bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Pistol")) then
                    gotGun = true
                end
            end
            if gotGun and teleportReturnPos then
                char.HumanoidRootPart.CFrame = teleportReturnPos
            end
            teleportReturnPos = nil
        end
    end
})

TeleportSection:Toggle({
    Title = "Auto Get Dropped Gun",
    Desc = "Automatically teleports to dropped gun",
    Value = false,
    Callback = function(v)
        autoGetGun = v
        if v then
            if not gunDropConnection then
                gunDropConnection = workspace.DescendantAdded:Connect(function(obj)
                    if autoGetGun and obj.Name == "GunDrop" then
                        local localPlayer = game.Players.LocalPlayer
                        local char = localPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            teleportReturnPos = char.HumanoidRootPart.CFrame
                            char.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                            task.wait(0.5)
                            local gotGun = false
                            if char:FindFirstChild("Gun") or char:FindFirstChild("Pistol") then
                                gotGun = true
                            end
                            if not gotGun then
                                local bp = localPlayer.Backpack
                                if bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Pistol")) then
                                    gotGun = true
                                end
                            end
                            if gotGun and teleportReturnPos then
                                char.HumanoidRootPart.CFrame = teleportReturnPos
                                teleportReturnPos = nil
                            end
                        end
                    end
                end)
            end
        else
            if gunDropConnection then
                gunDropConnection:Disconnect()
                gunDropConnection = nil
            end
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

MainSection:Toggle({
    Title = "Round Timer",
    Desc = "Shows the remaining round time",
    Value = false,
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
                roundTimerLabel.Position = UDim2.new(0.5, 0, 0.08, 0)
                roundTimerLabel.Size = UDim2.new(0, 200, 0, 35)
                roundTimerLabel.Font = Enum.Font.GothamBold
                roundTimerLabel.Text = "0m 0s"
                roundTimerLabel.ZIndex = 10
                roundTimerLabel.TextStrokeTransparency = 0.5
                roundTimerLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
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
})

-- ============================================================
-- AIMBOT TAB
-- ============================================================
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
local AimbotSection = AimbotTab:Section({ Title = "Visual Aimbot", Opened = true })

local aimbotEnabled = false
local smoothness = 0.5
local fov = 90
local offset = 2.1
local aimbotPredictionOffset = 1.0
local fovCircleTransparency = 0.3

local fovCircleFrame = nil
local function updateFOVCircle()
    if fovCircleFrame then
        fovCircleFrame:Destroy()
        fovCircleFrame = nil
    end
    if not aimbotEnabled then return end

    local screenGui = game:GetService("CoreGui"):FindFirstChild("BunnywareFOVCircle")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BunnywareFOVCircle"
        screenGui.Parent = game:GetService("CoreGui")
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.ScreenInsets = Enum.ScreenInsets.None
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end

    local radius = (fov / 90) * 150
    local circle = Instance.new("Frame")
    circle.Position = UDim2.new(0.5, 0, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BackgroundTransparency = fovCircleTransparency
    circle.BorderSizePixel = 0
    circle.ClipsDescendants = false
    circle.ZIndex = 10
    circle.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 0, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = circle

    fovCircleFrame = circle
end

local function destroyFOVCircle()
    if fovCircleFrame then
        fovCircleFrame:Destroy()
        fovCircleFrame = nil
    end
    local screenGui = game:GetService("CoreGui"):FindFirstChild("BunnywareFOVCircle")
    if screenGui then screenGui:Destroy() end
end

AimbotSection:Toggle({
    Title = "Enable Visual Aimbot",
    Desc = "Aims at the murderer automatically",
    Value = false,
    Callback = function(v)
        aimbotEnabled = v
        if v then
            updateFOVCircle()
        else
            destroyFOVCircle()
        end
    end
})

AimbotSection:Slider({
    Title = "Smoothness",
    Desc = "How smooth the aimbot follows (0 = instant, 1 = very slow)",
    Step = 0.05,
    Value = { Min = 0, Max = 1, Default = 0.5 },
    Callback = function(v) smoothness = v end
})

AimbotSection:Slider({
    Title = "FOV (Field of View)",
    Desc = "The radius of the aimbot detection circle",
    Step = 5,
    Value = { Min = 0, Max = 360, Default = 90 },
    Callback = function(v)
        fov = v
        if aimbotEnabled then
            updateFOVCircle()
        end
    end
})

AimbotSection:Slider({
    Title = "FOV Circle Transparency",
    Desc = "How visible the FOV circle is",
    Step = 0.05,
    Value = { Min = 0, Max = 1, Default = 0.3 },
    Callback = function(v)
        fovCircleTransparency = v
        if fovCircleFrame then
            fovCircleFrame.BackgroundTransparency = v
        end
    end
})

AimbotSection:Slider({
    Title = "Aimbot Prediction Offset",
    Desc = "How far ahead to predict the target's movement",
    Step = 0.1,
    Value = { Min = 0, Max = 5, Default = 1.0 },
    Callback = function(v) aimbotPredictionOffset = v end
})

local aimbotKeybind = Enum.KeyCode.P
local aimbotKeybindConnection = nil

local function onAimbotKeyPress(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == aimbotKeybind then
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            updateFOVCircle()
        else
            destroyFOVCircle()
        end
        Window:Notify({
            Title = "Aimbot",
            Content = aimbotEnabled and "Enabled" or "Disabled",
            Duration = 1,
        })
    end
end

aimbotKeybindConnection = game:GetService("UserInputService").InputBegan:Connect(onAimbotKeyPress)

AimbotSection:Keybind({
    Title = "Toggle Aimbot Keybind",
    Desc = "Press this key to toggle the aimbot",
    Value = "P",
    Callback = function(key)
        aimbotKeybind = key
        print("Aimbot toggle keybind set to:", key.Name)
    end
})

local function createFloatingAimbotToggle()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BunnywareFloatingAimbot"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 45)
    button.Position = UDim2.new(0.5, -80, 0.5, -22.5)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Text = "Aimbot: OFF"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 20
    button.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1
    stroke.Parent = button

    local dragging = false
    local dragStart = nil
    local startPos = nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    button.MouseButton1Click:Connect(function()
        aimbotEnabled = not aimbotEnabled
        button.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
        if aimbotEnabled then
            updateFOVCircle()
        else
            destroyFOVCircle()
        end
    end)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 22, 0, 22)
    close.Position = UDim2.new(1, -26, 0, 2)
    close.AnchorPoint = Vector2.new(1, 0)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextScaled = true
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.ZIndex = 21
    close.Parent = button
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

AimbotSection:Button({
    Title = "Create Floating Aimbot Toggle",
    Desc = "Creates a movable button to toggle the aimbot",
    Callback = createFloatingAimbotToggle
})

-- ============================================================
-- TRIGGERBOT TAB – INSTANT SHOOT (RenderStepped)
-- ============================================================
local TriggerbotTab = Window:Tab({ Title = "Triggerbot", Icon = "crosshair" })
local TriggerbotSection = TriggerbotTab:Section({ Title = "Triggerbot Settings", Opened = true })

local triggerbotEnabled = false
local triggerbotMode = "Triggerbot (Mobile)"
local triggerbotKeybind = Enum.KeyCode.T

local TRIGGERBOT_MODES = {
    "Triggerbot (Mobile)",
    "Triggerbot (PC)"
}

local function findMurderer()
    for _, i in ipairs(game.Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
        if i.Backpack and i.Backpack:FindFirstChild("Knife") then return i end
    end
    return nil
end

local function isMurderer(player)
    if not player then return false end
    if player.Character and player.Character:FindFirstChild("Knife") then return true end
    if player.Backpack and player.Backpack:FindFirstChild("Knife") then return true end
    return false
end

local function triggerbotPC()
    local char = game.Players.LocalPlayer.Character
    if not char then return false end
    local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Pistol")
    if not gun then return false end
    local mouse = game.Players.LocalPlayer:GetMouse()
    if not mouse then return false end
    local target = mouse.Target
    if not target then return false end
    local targetModel = target:FindFirstAncestorOfClass("Model")
    if not targetModel then return false end
    local targetPlayer = game.Players:GetPlayerFromCharacter(targetModel)
    if not targetPlayer or targetPlayer == game.Players.LocalPlayer then return false end
    if not isMurderer(targetPlayer) then return false end
    local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false end

    local originCF
    local gunServer = gun:FindFirstChild("GunServer")
    if gunServer then
        local attachment = gunServer:FindFirstChild("GunRaycastAttachment1") or gunServer:FindFirstChild("RaycastAttachment")
        if attachment then
            originCF = attachment.WorldCFrame
        end
    end
    if not originCF then
        local handle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun")
        if handle and handle:IsA("BasePart") then
            originCF = handle.CFrame
        end
    end
    if not originCF then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        originCF = hrp.CFrame
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char}
    local direction = (targetHRP.Position - originCF.Position).Unit * 1000
    local result = workspace:Raycast(originCF.Position, direction, rayParams)
    if not result or not result.Instance:IsDescendantOf(targetModel) then return false end

    local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
    if shootRemote then
        shootRemote:FireServer(
            CFrame.new(originCF.Position, targetHRP.Position),
            CFrame.new(targetHRP.Position)
        )
        return true
    end
    return false
end

local function triggerbotMobile()
    local char = game.Players.LocalPlayer.Character
    if not char then return false end
    local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Pistol")
    if not gun then return false end

    local cam = workspace.CurrentCamera
    local viewportSize = cam.ViewportSize
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2

    -- Raycast from center of screen
    local ray = cam:ScreenPointToRay(centerX, centerY, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char}

    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if not result then return false end

    local hitPart = result.Instance
    local targetModel = hitPart:FindFirstAncestorOfClass("Model")
    if not targetModel then return false end

    local targetPlayer = game.Players:GetPlayerFromCharacter(targetModel)
    if not targetPlayer or targetPlayer == game.Players.LocalPlayer then return false end
    if not isMurderer(targetPlayer) then return false end

    local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false end

    -- Get gun origin
    local originCF
    local gunServer = gun:FindFirstChild("GunServer")
    if gunServer then
        local attachment = gunServer:FindFirstChild("GunRaycastAttachment1") or gunServer:FindFirstChild("RaycastAttachment")
        if attachment then
            originCF = attachment.WorldCFrame
        end
    end
    if not originCF then
        local handle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun")
        if handle and handle:IsA("BasePart") then
            originCF = handle.CFrame
        end
    end
    if not originCF then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        originCF = hrp.CFrame
    end

    -- Verify line of sight from gun to target
    local direction = (targetHRP.Position - originCF.Position).Unit * 1000
    local result2 = workspace:Raycast(originCF.Position, direction, raycastParams)
    if result2 and not result2.Instance:IsDescendantOf(targetModel) then return false end

    local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
    if shootRemote then
        shootRemote:FireServer(
            CFrame.new(originCF.Position, targetHRP.Position),
            CFrame.new(targetHRP.Position)
        )
        return true
    end
    return false
end

local triggerbotRunning = false
local renderConnection = nil
local shotCooldown = false

local function triggerbotLoop()
    if not triggerbotEnabled or not triggerbotRunning then return end

    if shotCooldown then return end  -- prevents spam, but still runs every frame

    local success = false
    if triggerbotMode == "Triggerbot (PC)" then
        success = triggerbotPC()
    else
        success = triggerbotMobile()
    end

    if success then
        shotCooldown = true
        task.spawn(function()
            task.wait(0.05)  -- small cooldown after firing
            shotCooldown = false
        end)
    end
end

local function startTriggerbot()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    triggerbotRunning = true
    renderConnection = game:GetService("RunService").RenderStepped:Connect(triggerbotLoop)
end

local function stopTriggerbot()
    triggerbotRunning = false
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
end

TriggerbotSection:Toggle({
    Title = "Enable Triggerbot",
    Desc = "Automatically shoots the murderer when aiming at them (instant)",
    Value = false,
    Callback = function(v)
        triggerbotEnabled = v
        if v then
            startTriggerbot()
            Window:Notify({
                Title = "Triggerbot",
                Content = "Enabled (" .. triggerbotMode .. ")",
                Duration = 2,
            })
        else
            stopTriggerbot()
            Window:Notify({
                Title = "Triggerbot",
                Content = "Disabled",
                Duration = 2,
            })
        end
    end
})

TriggerbotSection:Dropdown({
    Title = "Triggerbot Mode",
    Desc = "Mobile = center-screen | PC = mouse position",
    Values = TRIGGERBOT_MODES,
    Value = { "Triggerbot (Mobile)" },
    Multi = false,
    Callback = function(opt)
        if type(opt) == "table" and #opt > 0 then
            triggerbotMode = opt[1]
            if triggerbotEnabled then
                startTriggerbot()
                Window:Notify({
                    Title = "Triggerbot",
                    Content = "Switched to " .. triggerbotMode,
                    Duration = 2,
                })
            end
        end
    end
})

TriggerbotSection:Keybind({
    Title = "Triggerbot Toggle Keybind",
    Desc = "Press to toggle triggerbot on/off",
    Value = "T",
    Callback = function(key)
        triggerbotKeybind = key
        print("Triggerbot keybind set to:", key.Name)
    end
})

local triggerKeybindConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == triggerbotKeybind then
        triggerbotEnabled = not triggerbotEnabled
        if triggerbotEnabled then
            startTriggerbot()
            Window:Notify({
                Title = "Triggerbot",
                Content = "Enabled (" .. triggerbotMode .. ")",
                Duration = 2,
            })
        else
            stopTriggerbot()
            Window:Notify({
                Title = "Triggerbot",
                Content = "Disabled",
                Duration = 2,
            })
        end
    end
end)

local function createFloatingTriggerbotButton()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BunnywareFloatingTriggerbot"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 45)
    button.Position = UDim2.new(0.5, -80, 0.5, -22.5)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Text = "Triggerbot: OFF"
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 20
    button.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1
    stroke.Parent = button

    local dragging = false
    local dragStart = nil
    local startPos = nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    button.MouseButton1Click:Connect(function()
        triggerbotEnabled = not triggerbotEnabled
        button.Text = "Triggerbot: " .. (triggerbotEnabled and "ON" or "OFF")
        if triggerbotEnabled then
            startTriggerbot()
            Window:Notify({
                Title = "Triggerbot",
                Content = "Enabled (" .. triggerbotMode .. ")",
                Duration = 2,
            })
        else
            stopTriggerbot()
            Window:Notify({
                Title = "Triggerbot",
                Content = "Disabled",
                Duration = 2,
            })
        end
    end)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 22, 0, 22)
    close.Position = UDim2.new(1, -26, 0, 2)
    close.AnchorPoint = Vector2.new(1, 0)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextScaled = true
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.ZIndex = 21
    close.Parent = button
    close.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

TriggerbotSection:Button({
    Title = "Create Floating Triggerbot Toggle",
    Desc = "Creates a movable button to toggle the triggerbot",
    Callback = createFloatingTriggerbotButton
})

-- ============================================================
-- ESP TAB
-- ============================================================
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local ESPSection = ESPTab:Section({ Title = "ESP Settings", Opened = true })

local espEnabled = false
local espPlayer = false
local espMurderer = false
local espSheriff = false
local espDroppedGun = false
local murdererLabelEnabled = false

local espHighlights = {}
local espLabels = {}
local murdererLabels = {}

local roleData = {}
local function updateRoleData(data)
    roleData = data
    if espEnabled then refreshESP() end
end

local function setupRoleListener()
    local success, remote = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged", 5)
    end)
    if success and remote then
        remote.OnClientEvent:Connect(updateRoleData)
    end
end
setupRoleListener()

local function clearESP()
    for _, h in ipairs(espHighlights) do pcall(function() h:Destroy() end) end
    espHighlights = {}
    for _, lbl in ipairs(espLabels) do pcall(function() lbl:Destroy() end) end
    espLabels = {}
    for _, lbl in ipairs(murdererLabels) do pcall(function() lbl:Destroy() end) end
    murdererLabels = {}
end

local function refreshESP()
    clearESP()
    if not espEnabled then return end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local isMurderer = false
            local isSheriff = false
            if roleData and roleData[pl.Name] then
                local role = roleData[pl.Name].Role
                if role == "Murderer" then isMurderer = true end
                if role == "Sheriff" then isSheriff = true end
            end
            if not isMurderer then
                if pl.Character:FindFirstChild("Knife") or pl.Backpack:FindFirstChild("Knife") then
                    isMurderer = true
                end
            end
            if not isSheriff then
                if pl.Character:FindFirstChild("Gun") or pl.Backpack:FindFirstChild("Gun") then
                    isSheriff = true
                end
            end

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

            if murdererLabelEnabled and isMurderer and pl.Character then
                local attachPart = pl.Character:FindFirstChild("HumanoidRootPart") or pl.Character:FindFirstChild("Head")
                if attachPart then
                    local bill = Instance.new("BillboardGui")
                    bill.Adornee = attachPart
                    bill.Size = UDim2.new(0, 100, 0, 25)
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = game:GetService("CoreGui")
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = "murderer"
                    label.TextColor3 = Color3.new(1,0,0)
                    label.TextScaled = false
                    label.TextSize = 14
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bill
                    table.insert(murdererLabels, bill)
                end
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
end

local roundTimerPart = workspace:FindFirstChild("RoundTimerPart")
if roundTimerPart then
    roundTimerPart:GetAttributeChangedSignal("Time"):Connect(function()
        local time = roundTimerPart:GetAttribute("Time") or 0
        if time > 0 then
            task.wait(1)
            refreshESP()
        end
    end)
end

game:GetService("Players").PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshESP()
end)

ESPSection:Toggle({
    Title = "Enable ESP",
    Desc = "Turns on all ESP features",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if v then refreshESP() else clearESP() end
    end
})

ESPSection:Toggle({
    Title = "Show Players",
    Desc = "Highlights all players",
    Value = false,
    Callback = function(v) espPlayer = v; refreshESP() end
})

ESPSection:Toggle({
    Title = "Highlight Murderer",
    Desc = "Highlights the murderer in red",
    Value = false,
    Callback = function(v) espMurderer = v; refreshESP() end
})

ESPSection:Toggle({
    Title = "Highlight Sheriff",
    Desc = "Highlights the sheriff in blue",
    Value = false,
    Callback = function(v) espSheriff = v; refreshESP() end
})

ESPSection:Toggle({
    Title = "Dropped Gun ESP",
    Desc = "Highlights dropped guns",
    Value = false,
    Callback = function(v) espDroppedGun = v; refreshESP() end
})

ESPSection:Toggle({
    Title = "Murderer Label (even when ghost)",
    Desc = "Shows a 'murderer' label above the murderer's head",
    Value = false,
    Callback = function(v)
        murdererLabelEnabled = v
        refreshESP()
    end
})

-- ============================================================
-- AUTO TAB
-- ============================================================
local AutoTab = Window:Tab({ Title = "Auto", Icon = "play" })
local AutoSection = AutoTab:Section({ Title = "Coin Farming", Opened = true })

local autoCollectCoins = false
local autoReady = false
local coinAvoidDistance = 20
local autoResetOnMax = false
local flingMurdererAfterFarm = false
local returnLocation = "Map"
local farmSpeed = 20
local maxCoins = 40
local autoGetGun = false
local gunDropConnection = nil

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
    Desc = "Set to 40 or 50 (Elite gamepass owners can hold 50)",
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
    Desc = "Kills you when you reach the max coin limit",
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
-- COMBAT TAB
-- ============================================================
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local CombatSection = CombatTab:Section({ Title = "Combat Tools", Opened = true })

-- Shared functions (including flingPlayer used in Main tab)
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

local function findSheriffThatsNotMe()
    for _, i in ipairs(game.Players:GetPlayers()) do
        if i == game.Players.LocalPlayer then continue end
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
    return pos + vel * (offset / 15)
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

-- Fling Deluxe Integration
local flingManager = flingManager or {}
local function getPlrHum(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function getHead(char) return char and (char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")) end
local function getRoot(char) return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")) end

function flingPlayer(targetPlayer)
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

-- Combat functions
local shootProcessing = false
local knifeProcessing = false

local knifePredictionOffset = 3.0

local function silentShootCallback()
    if shootProcessing then return end
    shootProcessing = true
    local localPlayer = game.Players.LocalPlayer
    if findSheriff() ~= localPlayer then shootProcessing = false return end
    local murderer = findMurderer() or findSheriffThatsNotMe()
    if not murderer then shootProcessing = false return end
    if not localPlayer.Character:FindFirstChild("Gun") then
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if localPlayer.Backpack:FindFirstChild("Gun") then
            hum:EquipTool(localPlayer.Backpack:FindFirstChild("Gun"))
        else
            shootProcessing = false
            return
        end
    end
    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then shootProcessing = false return end
    local predicted = getPredictedPosition(murderer, offset)
    if not predicted then shootProcessing = false return end
    local gun = localPlayer.Character:FindFirstChild("Gun")
    if gun then
        local shootRemote = gun:FindFirstChild("Shoot")
        if shootRemote and shootRemote:IsA("RemoteEvent") then
            shootRemote:FireServer(CFrame.new(localPlayer.Character.RightHand.Position), CFrame.new(predicted))
        end
    end
    task.wait(0.3)
    shootProcessing = false
end

local function throwKnifeCallback()
    if knifeProcessing then return end
    knifeProcessing = true
    local localPlayer = game.Players.LocalPlayer
    if findMurderer() ~= localPlayer then knifeProcessing = false return end
    if not localPlayer.Character:FindFirstChild("Knife") then
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if localPlayer.Backpack:FindFirstChild("Knife") then
            hum:EquipTool(localPlayer.Backpack:FindFirstChild("Knife"))
        else
            knifeProcessing = false
            return
        end
    end
    local NearestPlayer = getNearestPlayer()
    if not NearestPlayer or not NearestPlayer.Character then knifeProcessing = false return end
    local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then knifeProcessing = false return end
    local predicted = getPredictedPosition(NearestPlayer, knifePredictionOffset)
    if not predicted then knifeProcessing = false return end
    local knife = localPlayer.Character:FindFirstChild("Knife")
    if knife then
        local events = knife:FindFirstChild("Events")
        if events then
            local throwRemote = events:FindFirstChild("KnifeThrown")
            if throwRemote and throwRemote:IsA("RemoteEvent") then
                throwRemote:FireServer(CFrame.new(localPlayer.Character.RightHand.Position), CFrame.new(predicted))
            end
        end
    end
    task.wait(0.3)
    knifeProcessing = false
end

CombatSection:Slider({
    Title = "Prediction Offset (Shooting)",
    Desc = "How far ahead to aim when shooting",
    Step = 0.1,
    Value = { Min = 0, Max = 10, Default = 2.1 },
    Callback = function(v) offset = v end
})

CombatSection:Slider({
    Title = "Prediction Offset (Knife)",
    Desc = "How far ahead to aim when throwing the knife",
    Step = 0.1,
    Value = { Min = 0, Max = 10, Default = 3.0 },
    Callback = function(v) knifePredictionOffset = v end
})

CombatSection:Paragraph({
    Title = "Tip",
    Desc = "Other known good offsets: shooting 1.2, 1.4, 2.7; knife 2.8, 3.2, 4.0"
})

-- ============================================================
-- DYNAMIC PING-BASED OFFSET TOGGLE
-- ============================================================
local dynamicPingOffset = false
local dynamicOffsetTask = nil

local function updateOffsetFromPing()
    if not dynamicPingOffset then return end
    
    local localPlayer = game.Players.LocalPlayer
    local ping = localPlayer:GetNetworkPing() * 1000
    ping = math.max(ping, 10)
    
    local baseOffset = 2.1
    local basePing = 25
    local newOffset = baseOffset * (ping / basePing)
    
    newOffset = math.max(newOffset, 0.5)
    newOffset = math.min(newOffset, 10)
    
    offset = newOffset
end

local function startDynamicOffset()
    if dynamicOffsetTask then return end
    
    dynamicOffsetTask = task.spawn(function()
        while dynamicPingOffset do
            task.wait(0.5)
            updateOffsetFromPing()
        end
    end)
end

local function stopDynamicOffset()
    if dynamicOffsetTask then
        task.cancel(dynamicOffsetTask)
        dynamicOffsetTask = nil
    end
end

CombatSection:Toggle({
    Title = "Dynamic Ping-Based Offset",
    Desc = "Automatically adjusts shooting offset based on your ping",
    Value = false,
    Callback = function(v)
        dynamicPingOffset = v
        if v then
            updateOffsetFromPing()
            startDynamicOffset()
            Window:Notify({
                Title = "Dynamic Offset",
                Content = "Enabled - adjusting for ping",
                Duration = 2,
            })
        else
            stopDynamicOffset()
            offset = 2.1
            Window:Notify({
                Title = "Dynamic Offset",
                Content = "Disabled - reset to 2.1",
                Duration = 2,
            })
        end
    end
})

CombatSection:Paragraph({
    Title = "Info",
    Desc = "Automatically adjusts shooting offset based on your current ping. Base: 2.1 @ 25ms"
})

CombatSection:Button({
    Title = "Throw Knife Now",
    Desc = "Throws a knife at the nearest player",
    Callback = throwKnifeCallback
})

CombatSection:Button({
    Title = "Silent Shoot (Murderer)",
    Desc = "Shoots the murderer without any visual indication",
    Callback = silentShootCallback
})

-- Silent all shoots toggle (OFF by default)
local silentAllShoots = false
local autoShootCooldown = false
local silentShootConnection = nil

local function performSilentShoot()
    if autoShootCooldown then return end
    autoShootCooldown = true
    task.spawn(function() task.wait(0.3) autoShootCooldown = false end)
    local localPlayer = game.Players.LocalPlayer
    if findSheriff() ~= localPlayer then return end
    local murderer = findMurderer() or findSheriffThatsNotMe()
    if not murderer then return end
    if not localPlayer.Character:FindFirstChild("Gun") then
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if localPlayer.Backpack:FindFirstChild("Gun") then
            hum:EquipTool(localPlayer.Backpack:FindFirstChild("Gun"))
        else return end
    end
    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then return end
    local predicted = getPredictedPosition(murderer, offset)
    if not predicted then return end
    local gun = localPlayer.Character:FindFirstChild("Gun")
    if gun then
        local shootRemote = gun:FindFirstChild("Shoot")
        if shootRemote and shootRemote:IsA("RemoteEvent") then
            shootRemote:FireServer(CFrame.new(localPlayer.Character.RightHand.Position), CFrame.new(predicted))
        end
    end
end

local function setupSilentShoot()
    if silentShootConnection then silentShootConnection:Disconnect() end
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    silentShootConnection = mouse.Button1Down:Connect(function()
        if not silentAllShoots then return end
        if mouse.Target then
            local target = mouse.Target
            if target:IsDescendantOf(game:GetService("CoreGui")) then return end
            if target:IsDescendantOf(player.PlayerGui) then return end
            if target:IsA("GuiObject") or (target.Parent and target.Parent:IsA("GuiObject")) then return end
        end
        task.spawn(function() task.wait(0.025) performSilentShoot() end)
    end)
end

CombatSection:Toggle({
    Title = "Make all shoots silent (PC)",
    Desc = "Every left-click while sheriff silently shoots the murderer",
    Value = false,
    Callback = function(v)
        silentAllShoots = v
        if not v and silentShootConnection then
            silentShootConnection:Disconnect()
            silentShootConnection = nil
        end
        if v and not silentShootConnection then
            setupSilentShoot()
        end
    end
})

-- Silent shoot keybind (default L)
local silentShootKeybind = Enum.KeyCode.L
local silentShootKeybindConnection = nil

local function onSilentShootKeyPress(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == silentShootKeybind then
        task.spawn(performSilentShoot)
    end
end

silentShootKeybindConnection = game:GetService("UserInputService").InputBegan:Connect(onSilentShootKeyPress)

CombatSection:Keybind({
    Title = "Silent Shoot Keybind",
    Desc = "Press this key to perform a silent shot",
    Value = "L",
    Callback = function(key)
        silentShootKeybind = key
        print("Silent shoot keybind set to:", key.Name)
    end
})

-- ============================================================
-- Other Combat Buttons (floating, fling, etc.)
-- ============================================================

local createCooldown = false
local function createFloatingButton(text, callback)
    if createCooldown then return end
    createCooldown = true
    task.wait(1)
    createCooldown = false
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BunnywareFloatingButton"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 45)
    local xScale = math.random(10, 90) / 100
    local yScale = math.random(10, 90) / 100
    button.Position = UDim2.new(xScale, 0, yScale, 0)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Text = text
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 20
    button.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1
    stroke.Parent = button
    local dragging = false
    local dragStart = nil
    local startPos = nil
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    button.MouseButton1Click:Connect(function() callback() end)
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 22, 0, 22)
    close.Position = UDim2.new(1, -26, 0, 2)
    close.AnchorPoint = Vector2.new(1, 0)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextScaled = true
    close.BackgroundTransparency = 1
    close.Font = Enum.Font.GothamBold
    close.ZIndex = 21
    close.Parent = button
    close.MouseButton1Click:Connect(function() screenGui:Destroy() end)
end

CombatSection:Button({
    Title = "Create Floating Silent Shoot",
    Desc = "Creates a movable button for silent shooting",
    Callback = function() createFloatingButton("🔫 Silent Shoot", silentShootCallback) end
})

CombatSection:Button({
    Title = "Create Floating Knife Throw",
    Desc = "Creates a movable button for throwing knives",
    Callback = function() createFloatingButton("🔪 Throw Knife", throwKnifeCallback) end
})

CombatSection:Button({
    Title = "Fling Murderer",
    Desc = "Flings the murderer across the map",
    Callback = function()
        local murderer = findMurderer()
        if murderer then flingPlayer(murderer) else print("No murderer found.") end
    end
})

CombatSection:Button({
    Title = "Fling Sheriff",
    Desc = "Flings the sheriff across the map",
    Callback = function()
        local sheriff = findSheriff()
        if sheriff then flingPlayer(sheriff) else print("No sheriff found.") end
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
local MiscSection = MiscTab:Section({ Title = "Utility", Opened = true })

MiscSection:Button({
    Title = "Copy Murderer Name",
    Desc = "Copies the murderer's username to your clipboard",
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

MiscSection:Button({
    Title = "Copy Sheriff Name",
    Desc = "Copies the sheriff's username to your clipboard",
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

MiscSection:Button({
    Title = "Send Roles to Chat",
    Desc = "Sends the murderer and sheriff names to the chat",
    Callback = function()
        local murd = findMurderer()
        local sher = findSheriff()
        local murdName = murd and murd.Name or "Unknown"
        local sherName = sher and sher.Name or "Unknown"
        local msg = string.format("Murderer: %s | Sheriff: %s | <<Bunnyware V5>>", murdName, sherName)
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

MiscSection:Button({
    Title = "FPS Boost",
    Desc = "Reduces graphics quality for better performance",
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
-- CORE ENGINE – AUTOFARM
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
    local currentCoins = u65()
    if autoResetOnMax and currentCoins >= maxCoins then
        if flingMurdererAfterFarm then
            local murd = findMurderer()
            if murd then
                flingPlayer(murd)
                print("Flinging murderer after reaching max coins.")
            end
        end
        local hum = u59(LocalPlayer.Character, "Humanoid")
        if hum then
            hum.Health = 0
            print("Max coins reached. Resetting.")
            cleanupAutofarm()
            local newChar = LocalPlayer.CharacterAdded:Wait()
            u64(returnLocation)
        end
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
-- OTHER CORE FEATURES
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
                        local match = isMurderer
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

    local currentPos = hrp.Position
    local vel = hrp.AssemblyLinearVelocity
    local predictedPos = currentPos + vel * (aimbotPredictionOffset / 15)

    local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)

    local factor = 1 - smoothness
    factor = math.max(factor, 0.01)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, factor)
end

local aimbotRenderConnection = RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = GetAimbotTarget()
        if target then
            AimAtVisual(target)
        end
    end
end)

-- ============================================================
-- OTHER MISC FEATURES
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
    if flyEnabled and flyBV then
        local root = u60(LocalPlayer)
        if root and hum then
            local move = hum.MoveDirection
            if move.Magnitude > 0 then
                flyBV.Velocity = move * 50
            else
                flyBV.Velocity = Vector3.new(0, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyBV.Velocity = flyBV.Velocity + Vector3.new(0, 30, 0)
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

local heartbeatConnection
local lastUpdateTime = 0
local UPDATE_INTERVAL = 0.1

heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
    local now = tick()
    if now - lastUpdateTime < UPDATE_INTERVAL then return end
    lastUpdateTime = now

    if speedHack or jumpPower or noclipEnabled or flyEnabled then
        ApplyMisc()
    end
    if antiFling then
        AntiFlingCheck()
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if espEnabled then refreshESP() end
    end
end)

local function onGameStart()
    task.wait(1)
    ReadyUp()
    task.wait(0.5)
    refreshESP()
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
    if flyEnabled then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
                flyBV.Velocity = Vector3.new(0, 0, 0)
                flyBV.Parent = root
            end
        end
    end
end)

-- Copy Discord invite to clipboard
pcall(function()
    if setclipboard then
        setclipboard("https://discord.gg/6PJZa9BP7G")
    end
end)

-- Final notification
Window:Notify({
    Title = "Bunnyware V5 🐰",
    Content = "Loaded successfully! Join discord.gg/6PJZa9BP7G for updates.",
    Duration = 5,
})

print("✅ Bunnyware V5 loaded (WindUI) by Aleksandra \"Drew\" Malinina")