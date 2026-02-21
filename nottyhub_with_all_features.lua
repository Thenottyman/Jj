repeat task.wait() until game:IsLoaded()

-- ============================================================
-- VOID HUB: DUELS + BOOSTER (Obsidian UI Edition)
-- ============================================================

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Right"

local Window = Library:CreateWindow({
    Title = 'Void Hub',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    Footer = "Duels + Booster + Semi TP + AP Spam",
})

local Tabs = {
    CombatTab   = Window:AddTab("Combat",   "swords"),
    MovementTab = Window:AddTab("Movement", "zap"),
    StealingTab = Window:AddTab("Stealing", "target"),
    VisualsTab  = Window:AddTab("Visuals",  "eye"),
    BoosterTab  = Window:AddTab("Booster",  "ghost"),
    SemiTPTab   = Window:AddTab("Semi TP",  "shuffle"),
    AutoDuelTab = Window:AddTab("Auto Duel","activity"),
    APSpamTab   = Window:AddTab("AP Spam",  "message-circle"),
    UISettings  = Window:AddTab("UI Settings", "settings"),
}

Library:SetWatermark("Void Hub — Duels + Booster + Semi TP + AP Spam")

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local SoundService   = game:GetService("SoundService")
local Lighting       = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService    = game:GetService("HttpService")
local Workspace      = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TextChatService = game:GetService("TextChatService")

local Player    = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

local function waitForCharacter()
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        return char
    end
    return Player.CharacterAdded:Wait()
end
task.spawn(function() waitForCharacter() end)

if not getgenv then getgenv = function() return _G end end

-- ============================================================
-- CONFIG & STATE
-- ============================================================
local ConfigFileName = "VoidHubConfig.json"
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Enabled = {
    SpeedBoost         = false,
    AntiRagdoll        = false,
    SpinBot            = false,
    SpeedWhileStealing = false,
    AutoSteal          = false,
    Unwalk             = false,
    Optimizer          = false,
    Galaxy             = false,
    SpamBat            = false,
    BatAimbot          = false,
    AutoDisableSpeed   = true,
    GalaxySkyBright    = false,
    AutoWalkEnabled    = false,
    AutoRightEnabled   = false,
    ScriptUserESP      = true,
    MedusaInRange      = false,
    PlayerFollower     = false,
    AutoStealBooster   = false,
    SemiInvisible      = false,
    HighestBrainrot    = false,
    SpeedBoostBooster  = false,
    SpeedWhileStealingBooster = false,
    APSpam             = false,
    AutoDuels          = false,
    SemiTP             = false,
}

local Values = {
    BoostSpeed            = 30,
    SpinSpeed             = 30,
    StealingSpeedValue    = 29,
    STEAL_RADIUS          = 20,
    STEAL_DURATION        = 1.3,
    DEFAULT_GRAVITY       = 196.2,
    GalaxyGravityPercent  = 70,
    HOP_POWER             = 35,
    HOP_COOLDOWN          = 0.08,
    MedusaRange           = 15,
    PlayerFollowerSpeed   = 50,
    PlayerFollowerDistance = 5,
    BOOST_STEAL_RADIUS    = 25,
    BOOST_STEAL_DURATION  = 0.01,
    BOOST_SPEED           = 37.6,
    BoosterStealSpeed     = 28,
}

local KEYBINDS = {
    SPEED     = Enum.KeyCode.V,
    SPIN      = Enum.KeyCode.N,
    GALAXY    = Enum.KeyCode.M,
    BATAIMBOT = Enum.KeyCode.X,
    NUKE      = Enum.KeyCode.Q,
    AUTOLEFT  = Enum.KeyCode.Z,
    AUTORIGHT = Enum.KeyCode.C,
}

pcall(function()
    if readfile and isfile and isfile(ConfigFileName) then
        local data = HttpService:JSONDecode(readfile(ConfigFileName))
        if data then
            for k, v in pairs(data) do if Enabled[k] ~= nil then Enabled[k] = v end end
            for k, v in pairs(data) do if Values[k] ~= nil then Values[k] = v end end
            if data.KEY_SPEED    then KEYBINDS.SPEED    = Enum.KeyCode[data.KEY_SPEED]    end
            if data.KEY_SPIN     then KEYBINDS.SPIN     = Enum.KeyCode[data.KEY_SPIN]     end
            if data.KEY_GALAXY   then KEYBINDS.GALAXY   = Enum.KeyCode[data.KEY_GALAXY]   end
            if data.KEY_BATAIMBOT then KEYBINDS.BATAIMBOT = Enum.KeyCode[data.KEY_BATAIMBOT] end
            if data.KEY_AUTOLEFT then KEYBINDS.AUTOLEFT = Enum.KeyCode[data.KEY_AUTOLEFT] end
            if data.KEY_AUTORIGHT then KEYBINDS.AUTORIGHT = Enum.KeyCode[data.KEY_AUTORIGHT] end
        end
    end
end)

local function SaveConfig()
    local data = {}
    for k, v in pairs(Enabled) do data[k] = v end
    for k, v in pairs(Values) do data[k] = v end
    data.KEY_SPEED     = KEYBINDS.SPEED.Name
    data.KEY_SPIN      = KEYBINDS.SPIN.Name
    data.KEY_GALAXY    = KEYBINDS.GALAXY.Name
    data.KEY_BATAIMBOT = KEYBINDS.BATAIMBOT.Name
    data.KEY_AUTOLEFT  = KEYBINDS.AUTOLEFT.Name
    data.KEY_AUTORIGHT = KEYBINDS.AUTORIGHT.Name
    local success = false
    if writefile then pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(data)) success = true end) end
    return success
end

-- ============================================================
-- SHARED STATE & CONNECTIONS
-- ============================================================
local Connections = {}
local State = {
    medusaConnection        = nil,
    medusaEnabled           = false,
    playerFollowerConnection = nil,
    playerFollowerActive    = false,
    playerFollowerTarget    = nil,
}
local isStealing      = false
local lastBatSwing    = 0
local BAT_SWING_COOLDOWN = 0.12

local boosterStealData   = {}
local boosterIsStealing  = false
local lastHighestCheck   = 0
local HIGHEST_CHECK_INTERVAL = 0.5
local currentHighestPrompt  = nil
local currentHighestValue   = nil
local semiConnections       = {SemiInvisible = {}}
local isInvisible           = false
local semiClone, oldRoot, hip, animTrack, semiConnection, characterConnection

local SlapList = {
    {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},
    {5,"Diamond Slap"},{6,"Emerald Slap"},{7,"Ruby Slap"},
    {8,"Dark Matter Slap"},{9,"Flame Slap"},{10,"Nuclear Slap"},
    {11,"Galaxy Slap"},{12,"Glitched Slap"}
}

local ADMIN_KEY = "78a772b6-9e1c-4827-ab8b-04a07838f298"
local REMOTE_EVENT_ID = "352aad58-c786-4998-886b-3e4fa390721e"
local BALLOON_REMOTE = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_ID, true)

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function getHRP()
    local char = Player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = Player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function getMovementDirection()
    local c = Player.Character
    if not c then return Vector3.zero end
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end

local function getNearestPlayer()
    local c = Player.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local pos = h.Position
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local oh = p.Character:FindFirstChild("HumanoidRootPart")
            if oh then
                local d = (pos - oh.Position).Magnitude
                if d < dist then dist = d; nearest = p end
            end
        end
    end
    return nearest
end

local function INSTANT_NUKE(target)
    if not BALLOON_REMOTE or not target then return end
    for _, p in ipairs({"balloon","ragdoll","jumpscare","morph","tiny","rocket","inverse","jail"}) do
        BALLOON_REMOTE:FireServer(ADMIN_KEY, target, p)
    end
end

local function findBat()
    local c = Player.Character
    if not c then return nil end
    local bp = Player:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    for _, i in ipairs(SlapList) do
        local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
        if t then return t end
    end
    return nil
end

local function findMedusa()
    local char = Player.Character
    if not char then return nil end
    local bp = Player:FindFirstChildOfClass("Backpack")
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("medusa") then return item end
    end
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("medusa") then return item end
        end
    end
    return nil
end

local function isMyPlotByName(pn)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

-- ============================================================
-- COMBAT FEATURES
-- ============================================================

local function startSpamBat()
    if Connections.spamBat then return end
    Connections.spamBat = RunService.Heartbeat:Connect(function()
        if not Enabled.SpamBat then return end
        local c = Player.Character; if not c then return end
        local bat = findBat(); if not bat then return end
        if bat.Parent ~= c then bat.Parent = c end
        local now = tick()
        if now - lastBatSwing < BAT_SWING_COOLDOWN then return end
        lastBatSwing = now
        pcall(function() bat:Activate() end)
    end)
end

local function stopSpamBat()
    if Connections.spamBat then Connections.spamBat:Disconnect(); Connections.spamBat = nil end
end

local aimbotTarget = nil

local function findNearestEnemy(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local torso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - myHRP.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearest = eh; nearestTorso = torso or eh end
            end
        end
    end
    return nearest, nearestDist, nearestTorso
end

local function startBatAimbot()
    if Connections.batAimbot then return end
    Connections.batAimbot = RunService.Heartbeat:Connect(function(dt)
        if not Enabled.BatAimbot then return end
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat = findBat()
        if bat and bat.Parent ~= c then hum:EquipTool(bat) end
        local target, dist, torso = findNearestEnemy(h)
        aimbotTarget = torso or target
        if target and torso then
            local dir = (torso.Position - h.Position)
            local flatDir = Vector3.new(dir.X, 0, dir.Z)
            local flatDist = flatDir.Magnitude
            local spd = 55
            if flatDist > 1.5 then
                local moveDir = flatDir.Unit
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, h.AssemblyLinearVelocity.Y, moveDir.Z * spd)
            else
                local tv = target.AssemblyLinearVelocity
                h.AssemblyLinearVelocity = Vector3.new(tv.X, h.AssemblyLinearVelocity.Y, tv.Z)
            end
        end
    end)
end

local function stopBatAimbot()
    if Connections.batAimbot then Connections.batAimbot:Disconnect(); Connections.batAimbot = nil end
    aimbotTarget = nil
end

local function startMedusaInRange()
    if State.medusaConnection then State.medusaConnection:Disconnect() end
    State.medusaEnabled = true
    State.medusaConnection = RunService.RenderStepped:Connect(function()
        if not State.medusaEnabled then return end
        local char = Player.Character; if not char then return end
        local root = getHRP()
        local humanoid = getHumanoid()
        if not root or not humanoid then return end
        local medusa = findMedusa()
        if medusa then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local target = p.Character.HumanoidRootPart
                    local dist = (target.Position - root.Position).Magnitude
                    if dist <= Values.MedusaRange then
                        humanoid:Move((target.Position - root.Position).Unit)
                        if medusa.Parent ~= char then char.Humanoid:EquipTool(medusa) end
                        medusa:Activate()
                    end
                end
            end
        end
    end)
end

local function stopMedusaInRange()
    State.medusaEnabled = false
    if State.medusaConnection then State.medusaConnection:Disconnect(); State.medusaConnection = nil end
end

local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not Enabled.AntiRagdoll then return end
        local char = Player.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local humState = hum:GetState()
            if humState == Enum.HumanoidStateType.Physics or humState == Enum.HumanoidStateType.Ragdoll or humState == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                Workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    if Player.Character then
                        local PlayerModule = Player.PlayerScripts:FindFirstChild("PlayerModule")
                        if PlayerModule then
                            local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
                            Controls:Enable()
                        end
                    end
                end)
                if root then root.Velocity = Vector3.new(0,0,0); root.RotVelocity = Vector3.new(0,0,0) end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end)
end

local function stopAntiRagdoll()
    if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect(); Connections.antiRagdoll = nil end
end

-- ============================================================
-- MOVEMENT FEATURES
-- ============================================================

local spinBAV = nil

local function startSpinBot()
    local c = Player.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if spinBAV then spinBAV:Destroy(); spinBAV = nil end
    for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end
    spinBAV = Instance.new("BodyAngularVelocity")
    spinBAV.Name = "SpinBAV"
    spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    spinBAV.Parent = hrp
end

local function stopSpinBot()
    if spinBAV then spinBAV:Destroy(); spinBAV = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then for _, v in pairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end end
    end
end

RunService.Heartbeat:Connect(function()
    if Enabled.SpinBot and spinBAV then
        spinBAV.AngularVelocity = Player:GetAttribute("Stealing") and Vector3.new(0,0,0) or Vector3.new(0, Values.SpinSpeed, 0)
    end
end)

local function startSpeedBoost()
    if Connections.speed then return end
    Connections.speed = RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedBoost then return end
        pcall(function()
            local c = Player.Character; if not c then return end
            local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
            local md = getMovementDirection()
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(md.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, md.Z * Values.BoostSpeed)
            end
        end)
    end)
end

local function stopSpeedBoost()
    if Connections.speed then Connections.speed:Disconnect(); Connections.speed = nil end
end

local savedAnimations = {}

local function startUnwalk()
    local c = Player.Character; if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate = anim:Clone(); anim:Destroy() end
end

local function stopUnwalk()
    local c = Player.Character
    if c and savedAnimations.Animate then savedAnimations.Animate:Clone().Parent = c; savedAnimations.Animate = nil end
end

local galaxyVectorForce = nil
local galaxyAttachment  = nil
local galaxyEnabled     = false
local hopsEnabled       = false
local lastHopTime       = 0
local spaceHeld         = false
local originalJumpPower = 50

local function captureJumpPower()
    local c = Player.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum.JumpPower > 0 then originalJumpPower = hum.JumpPower end
    end
end
task.spawn(function() task.wait(1); captureJumpPower() end)
Player.CharacterAdded:Connect(function() task.wait(1); captureJumpPower() end)

local function setupGalaxyForce()
    pcall(function()
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        if galaxyVectorForce then galaxyVectorForce:Destroy() end
        if galaxyAttachment then galaxyAttachment:Destroy() end
        galaxyAttachment = Instance.new("Attachment"); galaxyAttachment.Parent = h
        galaxyVectorForce = Instance.new("VectorForce")
        galaxyVectorForce.Attachment0 = galaxyAttachment
        galaxyVectorForce.ApplyAtCenterOfMass = true
        galaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
        galaxyVectorForce.Force = Vector3.new(0, 0, 0)
        galaxyVectorForce.Parent = h
    end)
end

local function updateGalaxyForce()
    if not galaxyEnabled or not galaxyVectorForce then return end
    local c = Player.Character; if not c then return end
    local mass = 0
    for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
    local tg = Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent / 100)
    galaxyVectorForce.Force = Vector3.new(0, mass * (Values.DEFAULT_GRAVITY - tg) * 0.95, 0)
end

local function adjustGalaxyJump()
    pcall(function()
        local c = Player.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if not galaxyEnabled then hum.JumpPower = originalJumpPower; return end
        local ratio = math.sqrt((Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent / 100)) / Values.DEFAULT_GRAVITY)
        hum.JumpPower = originalJumpPower * ratio
    end)
end

local function doMiniHop()
    if not hopsEnabled then return end
    pcall(function()
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if tick() - lastHopTime < Values.HOP_COOLDOWN then return end
        lastHopTime = tick()
        if hum.FloorMaterial == Enum.Material.Air then
            h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, Values.HOP_POWER, h.AssemblyLinearVelocity.Z)
        end
    end)
end

local function startGalaxy()
    galaxyEnabled = true; hopsEnabled = true
    setupGalaxyForce(); adjustGalaxyJump()
end

local function stopGalaxy()
    galaxyEnabled = false; hopsEnabled = false
    if galaxyVectorForce then galaxyVectorForce:Destroy(); galaxyVectorForce = nil end
    if galaxyAttachment  then galaxyAttachment:Destroy();  galaxyAttachment  = nil end
    adjustGalaxyJump()
end

RunService.Heartbeat:Connect(function()
    if hopsEnabled and spaceHeld then doMiniHop() end
    if galaxyEnabled then updateGalaxyForce() end
end)

local function startPlayerFollower()
    if State.playerFollowerConnection then State.playerFollowerConnection:Disconnect() end
    State.playerFollowerActive = true
    State.playerFollowerConnection = RunService.Heartbeat:Connect(function()
        if not State.playerFollowerActive then return end
        local closestPlayer, closestDistance = nil, math.huge
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= Player then
                local otherCharacter = otherPlayer.Character
                if otherCharacter then
                    local otherHRP = otherCharacter:FindFirstChild("HumanoidRootPart")
                    if otherHRP then
                        local ourHRP = getHRP()
                        if ourHRP then
                            local distance = (ourHRP.Position - otherHRP.Position).Magnitude
                            if distance < closestDistance then closestDistance = distance; closestPlayer = otherPlayer end
                        end
                    end
                end
            end
        end
        State.playerFollowerTarget = closestPlayer
        if not closestPlayer or not closestPlayer.Character then return end
        local targetCharacter = closestPlayer.Character
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
        if not targetHRP or not targetHumanoid then return end
        local ourHRP = getHRP(); if not ourHRP then return end
        local targetVelocity = targetHRP.AssemblyLinearVelocity
        local targetPosition = targetHRP.Position
        local targetLookDirection = targetHRP.CFrame.LookVector
        local offsetPosition = targetPosition - (targetLookDirection * Values.PlayerFollowerDistance)
        local moveDirection = (offsetPosition - ourHRP.Position)
        local currentVelocity = ourHRP.AssemblyLinearVelocity
        if moveDirection.Magnitude > 0.5 then
            ourHRP.AssemblyLinearVelocity = currentVelocity:Lerp(moveDirection.Unit * Values.PlayerFollowerSpeed, 0.2)
        else
            ourHRP.AssemblyLinearVelocity = currentVelocity:Lerp(targetVelocity, 0.1)
        end
        local targetIsJumping = targetHumanoid:GetState() == Enum.HumanoidStateType.Jumping or targetVelocity.Y > 0.1
        if not State.playerFollowerTarget._lastJumpState then State.playerFollowerTarget._lastJumpState = false end
        if targetIsJumping and not State.playerFollowerTarget._lastJumpState then
            local ourHumanoid = Player.Character:FindFirstChild("Humanoid")
            if ourHumanoid then ourHumanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
        State.playerFollowerTarget._lastJumpState = targetIsJumping
    end)
end

local function stopPlayerFollower()
    State.playerFollowerActive = false
    if State.playerFollowerConnection then State.playerFollowerConnection:Disconnect(); State.playerFollowerConnection = nil end
    State.playerFollowerTarget = nil
end

local POSITION_1  = Vector3.new(-476.48, -6.28, 92.73)
local POSITION_2  = Vector3.new(-483.12, -4.95, 94.80)
local POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
local POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)
local autoWalkPhase     = 1
local autoRightPhase    = 1
local autoWalkConnection  = nil
local autoRightConnection = nil
local AutoWalkEnabled   = false
local AutoRightEnabled  = false

local coordESPFolder = Instance.new("Folder", Workspace)
coordESPFolder.Name = "VoidHub_CoordESP"

local function createCoordMarker(position, labelText, color)
    local dot = Instance.new("Part", coordESPFolder)
    dot.Anchored = true; dot.CanCollide = false; dot.CastShadow = false
    dot.Material = Enum.Material.Neon; dot.Color = color
    dot.Shape = Enum.PartType.Ball; dot.Size = Vector3.new(1,1,1)
    dot.Position = position; dot.Transparency = 0.2
    local bb = Instance.new("BillboardGui", dot)
    bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 100, 0, 20)
    bb.StudsOffset = Vector3.new(0, 2, 0); bb.MaxDistance = 300
    local text = Instance.new("TextLabel", bb)
    text.Size = UDim2.new(1,0,1,0); text.BackgroundTransparency = 1
    text.Text = labelText; text.TextColor3 = color
    text.TextStrokeColor3 = Color3.fromRGB(0,0,0); text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold; text.TextSize = 12
    return dot
end

createCoordMarker(POSITION_1,  "L1",    Color3.fromRGB(167, 139, 250))
createCoordMarker(POSITION_2,  "L END", Color3.fromRGB(139, 92,  246))
createCoordMarker(POSITION_R1, "R1",    Color3.fromRGB(236, 72,  153))
createCoordMarker(POSITION_R2, "R END", Color3.fromRGB(217, 70,  239))

local function faceSouth()
    local c = Player.Character; if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
    h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0, 0, 0)
    local camera = Workspace.CurrentCamera
    if camera then
        local charPos = h.Position
        camera.CFrame = CFrame.new(charPos.X, charPos.Y + 5, charPos.Z - 12) * CFrame.Angles(math.rad(-15), 0, 0)
    end
end

local function faceNorth()
    local c = Player.Character; if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
    h.CFrame = CFrame.new(h.Position) * CFrame.Angles(0, math.rad(180), 0)
    local camera = Workspace.CurrentCamera
    if camera then
        local charPos = h.Position
        camera.CFrame = CFrame.new(charPos.X, charPos.Y + 2, charPos.Z + 12) * CFrame.Angles(0, math.rad(180), 0)
    end
end

local function startAutoWalk()
    if autoWalkConnection then autoWalkConnection:Disconnect() end
    autoWalkPhase = 1
    autoWalkConnection = RunService.Heartbeat:Connect(function()
        if not AutoWalkEnabled then return end
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if autoWalkPhase == 1 then
            local targetPos = Vector3.new(POSITION_1.X, h.Position.Y, POSITION_1.Z)
            local dist = (targetPos - h.Position).Magnitude
            if dist < 1 then
                autoWalkPhase = 2
                local dir = (POSITION_2 - h.Position)
                local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
                hum:Move(moveDir, false)
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.BoostSpeed)
                return
            end
            local dir = (POSITION_1 - h.Position)
            local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
            hum:Move(moveDir, false)
            h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.BoostSpeed)
        elseif autoWalkPhase == 2 then
            local targetPos = Vector3.new(POSITION_2.X, h.Position.Y, POSITION_2.Z)
            local dist = (targetPos - h.Position).Magnitude
            if dist < 1 then
                hum:Move(Vector3.zero, false); h.AssemblyLinearVelocity = Vector3.new(0,0,0)
                AutoWalkEnabled = false; Enabled.AutoWalkEnabled = false
                if autoWalkConnection then autoWalkConnection:Disconnect(); autoWalkConnection = nil end
                faceSouth()
                return
            end
            local dir = (POSITION_2 - h.Position)
            local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
            hum:Move(moveDir, false)
            h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.BoostSpeed)
        end
    end)
end

local function stopAutoWalk()
    if autoWalkConnection then autoWalkConnection:Disconnect(); autoWalkConnection = nil end
    autoWalkPhase = 1
    local c = Player.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero, false) end end
end

local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase = 1
    autoRightConnection = RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        if autoRightPhase == 1 then
            local targetPos = Vector3.new(POSITION_R1.X, h.Position.Y, POSITION_R1.Z)
            local dist = (targetPos - h.Position).Magnitude
            if dist < 1 then
                autoRightPhase = 2
                local dir = (POSITION_R2 - h.Position)
                local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
                hum:Move(moveDir, false)
                h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.BoostSpeed)
                return
            end
            local dir = (POSITION_R1 - h.Position)
            local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
            hum:Move(moveDir, false)
            h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.BoostSpeed)
        elseif autoRightPhase == 2 then
            local targetPos = Vector3.new(POSITION_R2.X, h.Position.Y, POSITION_R2.Z)
            local dist = (targetPos - h.Position).Magnitude
            if dist < 1 then
                hum:Move(Vector3.zero, false); h.AssemblyLinearVelocity = Vector3.new(0,0,0)
                AutoRightEnabled = false; Enabled.AutoRightEnabled = false
                if autoRightConnection then autoRightConnection:Disconnect(); autoRightConnection = nil end
                faceNorth()
                return
            end
            local dir = (POSITION_R2 - h.Position)
            local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
            hum:Move(moveDir, false)
            h.AssemblyLinearVelocity = Vector3.new(moveDir.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, moveDir.Z * Values.BoostSpeed)
        end
    end)
end

local function stopAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect(); autoRightConnection = nil end
    autoRightPhase = 1
    local c = Player.Character
    if c then local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero, false) end end
end

-- ============================================================
-- STEALING FEATURES
-- ============================================================

local ProgressBarFill, ProgressLabel, ProgressPercentLabel, RadiusInput
local stealStartTime  = nil
local progressConnection = nil
local StealData       = {}

local DISCORD_TEXT = "Void Hub - Purple"

local function getDiscordProgress(percent)
    local totalChars = #DISCORD_TEXT
    local adjustedPercent = math.min(percent * 1.5, 100)
    local charsToShow = math.floor((adjustedPercent / 100) * totalChars)
    return string.sub(DISCORD_TEXT, 1, charsToShow)
end

local function ResetProgressBar()
    if ProgressLabel then ProgressLabel.Text = "READY" end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "" end
    if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function findNearestPrompt()
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nd and dist <= Values.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then np, nd, nn = ch, dist, pod.Name; break end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false; isStealing = true
    stealStartTime = tick()
    if ProgressLabel then ProgressLabel.Text = name or "STEALING..." end
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConnection:Disconnect(); return end
        local prog = math.clamp((tick() - stealStartTime) / Values.STEAL_DURATION, 0, 1)
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(prog, 0, 1, 0) end
        if ProgressPercentLabel then
            local percent = math.floor(prog * 100)
            ProgressPercentLabel.Text = getDiscordProgress(percent)
        end
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(Values.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        if progressConnection then progressConnection:Disconnect() end
        ResetProgressBar(); data.ready = true; isStealing = false
    end)
end

local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if Connections.autoSteal then Connections.autoSteal:Disconnect(); Connections.autoSteal = nil end
    isStealing = false; ResetProgressBar()
end

local function startSpeedWhileStealing()
    if Connections.speedWhileStealing then return end
    Connections.speedWhileStealing = RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedWhileStealing or not Player:GetAttribute("Stealing") then return end
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        local md = getMovementDirection()
        if md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(md.X * Values.StealingSpeedValue, h.AssemblyLinearVelocity.Y, md.Z * Values.StealingSpeedValue)
        end
    end)
end

local function stopSpeedWhileStealing()
    if Connections.speedWhileStealing then Connections.speedWhileStealing:Disconnect(); Connections.speedWhileStealing = nil end
end

-- ============================================================
-- VISUAL FEATURES
-- ============================================================

local originalTransparency = {}
local xrayEnabled = false

local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.Brightness = 3
        Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                end
            end)
        end
    end)
    xrayEnabled = true
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
    if xrayEnabled then
        for part, value in pairs(originalTransparency) do if part then part.LocalTransparencyModifier = value end end
        originalTransparency = {}; xrayEnabled = false
    end
end

local originalSkybox, galaxySkyBright, galaxySkyBrightConn = nil, nil, nil
local galaxyPlanets = {}
local galaxyBloom, galaxyCC = nil, nil

local function enableGalaxySkyBright()
    if galaxySkyBright then return end
    originalSkybox = Lighting:FindFirstChildOfClass("Sky")
    if originalSkybox then originalSkybox.Parent = nil end
    galaxySkyBright = Instance.new("Sky")
    galaxySkyBright.SkyboxBk = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxDn = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxFt = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxLf = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxRt = "rbxassetid://1534951537"
    galaxySkyBright.SkyboxUp = "rbxassetid://1534951537"
    galaxySkyBright.StarCount = 10000
    galaxySkyBright.CelestialBodiesShown = false
    galaxySkyBright.Parent = Lighting
    galaxyBloom = Instance.new("BloomEffect")
    galaxyBloom.Intensity = 1.5; galaxyBloom.Size = 40; galaxyBloom.Threshold = 0.8
    galaxyBloom.Parent = Lighting
    galaxyCC = Instance.new("ColorCorrectionEffect")
    galaxyCC.Saturation = 0.8; galaxyCC.Contrast = 0.3
    galaxyCC.TintColor = Color3.fromRGB(200, 150, 255)
    galaxyCC.Parent = Lighting
    Lighting.Ambient = Color3.fromRGB(120, 60, 180)
    Lighting.Brightness = 3; Lighting.ClockTime = 0
    for i = 1, 2 do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(800+i*200, 800+i*200, 800+i*200)
        p.Anchored = true; p.CanCollide = false; p.CastShadow = false
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(140+i*20, 60+i*10, 200+i*15)
        p.Transparency = 0.3
        p.Position = Vector3.new(math.cos(i*2)*(3000+i*500), 1500+i*300, math.sin(i*2)*(3000+i*500))
        p.Parent = Workspace
        table.insert(galaxyPlanets, p)
    end
    galaxySkyBrightConn = RunService.Heartbeat:Connect(function()
        if not Enabled.GalaxySkyBright then return end
        local t = tick() * 0.5
        Lighting.Ambient = Color3.fromRGB(120+math.sin(t)*60, 50+math.sin(t*0.8)*40, 180+math.sin(t*1.2)*50)
        if galaxyBloom then galaxyBloom.Intensity = 1.2 + math.sin(t*2) * 0.4 end
    end)
end

local function disableGalaxySkyBright()
    if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect(); galaxySkyBrightConn = nil end
    if galaxySkyBright then galaxySkyBright:Destroy(); galaxySkyBright = nil end
    if originalSkybox then originalSkybox.Parent = Lighting end
    if galaxyBloom then galaxyBloom:Destroy(); galaxyBloom = nil end
    if galaxyCC then galaxyCC:Destroy(); galaxyCC = nil end
    for _, obj in ipairs(galaxyPlanets) do if obj then obj:Destroy() end end
    galaxyPlanets = {}
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.Brightness = 2; Lighting.ClockTime = 14
end

-- ============================================================
-- BOOSTER FEATURES
-- ============================================================

local function removeFolders()
    local playerName = Player.Name
    local playerFolder = Workspace:FindFirstChild(playerName)
    if not playerFolder then return end
    local doubleRig = playerFolder:FindFirstChild("DoubleRig")
    if doubleRig then doubleRig:Destroy() end
    local constraints = playerFolder:FindFirstChild("Constraints")
    if constraints then constraints:Destroy() end
    local childAddedConn = playerFolder.ChildAdded:Connect(function(child)
        if child.Name == "DoubleRig" or child.Name == "Constraints" then child:Destroy() end
    end)
    table.insert(semiConnections.SemiInvisible, childAddedConn)
end

local function doClone()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
        hip = Player.Character.Humanoid.HipHeight
        oldRoot = Player.Character:FindFirstChild("HumanoidRootPart")
        if not oldRoot or not oldRoot.Parent then return false end
        local tempParent = Instance.new("Model"); tempParent.Parent = game
        Player.Character.Parent = tempParent
        semiClone = oldRoot:Clone()
        semiClone.Parent = Player.Character
        oldRoot.Parent = Workspace.CurrentCamera
        semiClone.CFrame = oldRoot.CFrame
        Player.Character.PrimaryPart = semiClone
        Player.Character.Parent = Workspace
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == oldRoot then v.Part0 = semiClone end
                if v.Part1 == oldRoot then v.Part1 = semiClone end
            end
        end
        tempParent:Destroy()
        return true
    end
    return false
end

local function revertClone()
    if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not Player.Character or Player.Character.Humanoid.Health <= 0 then return false end
    local tempParent = Instance.new("Model"); tempParent.Parent = game
    Player.Character.Parent = tempParent
    oldRoot.Parent = Player.Character
    Player.Character.PrimaryPart = oldRoot
    Player.Character.Parent = Workspace
    oldRoot.CanCollide = true
    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("Motor6D") then
            if v.Part0 == semiClone then v.Part0 = oldRoot end
            if v.Part1 == semiClone then v.Part1 = oldRoot end
        end
    end
    if semiClone then
        local oldPos = semiClone.CFrame
        semiClone:Destroy(); semiClone = nil
        oldRoot.CFrame = oldPos
    end
    oldRoot = nil
    if Player.Character and Player.Character.Humanoid then
        Player.Character.Humanoid.HipHeight = hip
    end
end

local function animationTrickery()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
        local anim = Instance.new("Animation")
        anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
        local humanoid = Player.Character.Humanoid
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
        animTrack = animator:LoadAnimation(anim)
        animTrack.Priority = Enum.AnimationPriority.Action4
        animTrack:Play(0, 1, 0)
        anim:Destroy()
        local animStoppedConn = animTrack.Stopped:Connect(function()
            if isInvisible then animationTrickery() end
        end)
        table.insert(semiConnections.SemiInvisible, animStoppedConn)
        task.delay(0, function()
            animTrack.TimePosition = 0.7
            task.delay(1, function() animTrack:AdjustSpeed(math.huge) end)
        end)
    end
end

local function enableInvisibility()
    if not Player.Character or Player.Character.Humanoid.Health <= 0 then return false end
    removeFolders()
    local success = doClone()
    if success then
        task.wait(0.1)
        animationTrickery()
        semiConnection = RunService.PreSimulation:Connect(function(dt)
            if Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 and oldRoot then
                local root = Player.Character.PrimaryPart or Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local cf = root.CFrame - Vector3.new(0, Player.Character.Humanoid.HipHeight + (root.Size.Y / 2) - 1 + 0.09, 0)
                    oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)
                    oldRoot.Velocity = root.Velocity
                    oldRoot.CanCollide = false
                end
            end
        end)
        table.insert(semiConnections.SemiInvisible, semiConnection)
        characterConnection = Player.CharacterAdded:Connect(function(newChar)
            if isInvisible then
                if animTrack then animTrack:Stop(); animTrack:Destroy(); animTrack = nil end
                if semiConnection then semiConnection:Disconnect() end
                revertClone(); removeFolders()
                isInvisible = false
                for _, conn in ipairs(semiConnections.SemiInvisible) do if conn then conn:Disconnect() end end
                semiConnections.SemiInvisible = {}
            end
        end)
        table.insert(semiConnections.SemiInvisible, characterConnection)
        return true
    end
    return false
end

local function disableInvisibility()
    if animTrack then animTrack:Stop(); animTrack:Destroy(); animTrack = nil end
    if semiConnection then semiConnection:Disconnect() end
    if characterConnection then characterConnection:Disconnect() end
    revertClone(); removeFolders()
end

local function setupGodmode()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    local oldNI = mt.__newindex
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if self == hum then
            if m == "ChangeState" and select(1, ...) == Enum.HumanoidStateType.Dead then return end
            if m == "SetStateEnabled" then
                local st, en = ...
                if st == Enum.HumanoidStateType.Dead and en == true then return end
            end
            if m == "Destroy" then return end
        end
        if self == char and m == "BreakJoints" then return end
        return oldNC(self, ...)
    end)
    mt.__newindex = newcclosure(function(self, k, v)
        if self == hum then
            if k == "Health" and type(v) == "number" and v <= 0 then return end
            if k == "MaxHealth" and type(v) == "number" and v < hum.MaxHealth then return end
            if k == "BreakJointsOnDeath" and v == true then return end
            if k == "Parent" and v == nil then return end
        end
        return oldNI(self, k, v)
    end)
    setreadonly(mt, true)
end

local function toggleSemiInvisible(state)
    Enabled.SemiInvisible = state
    isInvisible = state
    if state then
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            warn("⚠️ Wait for character to load")
            return
        end
        removeFolders(); setupGodmode(); enableInvisibility()
    else
        disableInvisibility()
        for _, conn in ipairs(semiConnections.SemiInvisible) do if conn then conn:Disconnect() end end
        semiConnections.SemiInvisible = {}
    end
end

local function parseGenValue(text)
    if not text or text == "" then return 0 end
    text = text:gsub(",", ""):gsub("%s+", "")
    local suffixes = {K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18,Sx=1e21,Sp=1e24,Oc=1e27,No=1e30,Dc=1e33}
    for suffix, mult in pairs(suffixes) do
        local num = text:match("^([%d%.]+)" .. suffix .. "$")
        if num then return (tonumber(num) or 0) * mult end
    end
    return tonumber(text) or 0
end

local function findPromptFromOverhead(billboard)
    if not billboard then return nil end
    local base = billboard.Parent
    for _ = 1, 6 do
        if not base then break end
        local spawn = base:FindFirstChild("Spawn")
        if spawn then
            local att = spawn:FindFirstChild("PromptAttachment")
            if att then for _, ch in ipairs(att:GetChildren()) do if ch:IsA("ProximityPrompt") then return ch end end end
        end
        local att = base:FindFirstChild("PromptAttachment")
        if att then for _, ch in ipairs(att:GetChildren()) do if ch:IsA("ProximityPrompt") then return ch end end end
        base = base.Parent
    end
    if billboard.Parent then
        local parent = billboard.Parent
        for _ = 1, 4 do
            if not parent then break end
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "Spawn" then
                    local att = child:FindFirstChild("PromptAttachment")
                    if att then for _, ch in ipairs(att:GetChildren()) do if ch:IsA("ProximityPrompt") then return ch end end end
                end
            end
            parent = parent.Parent
        end
    end
    return nil
end

local function findHighestBrainrotPrompt()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil, 0 end
    local bestPrompt, bestValue = nil, 0
    for _, plot in ipairs(plots:GetChildren()) do
        if plot.Name:lower():find(Player.Name:lower()) then continue end
        for _, obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("BillboardGui") and obj.Name == "AnimalOverhead" then
                local genLabel = obj:FindFirstChild("Generation")
                if genLabel and genLabel:IsA("TextLabel") then
                    local value = parseGenValue(genLabel.Text)
                    if value > bestValue then
                        local prompt = findPromptFromOverhead(obj)
                        if prompt then bestValue = value; bestPrompt = prompt end
                    end
                end
            end
        end
    end
    return bestPrompt, bestValue
end

local function findNearestBoosterPrompt()
    if Enabled.HighestBrainrot then
        if tick() - lastHighestCheck > HIGHEST_CHECK_INTERVAL then
            lastHighestCheck = tick()
            local prompt, value = findHighestBrainrotPrompt()
            if prompt then currentHighestPrompt = prompt; currentHighestValue = value
            else currentHighestPrompt = nil; currentHighestValue = nil end
        end
        return currentHighestPrompt, 0, "HighestBrainrot"
    end
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if plot.Name:lower():find(Player.Name:lower()) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nd and dist <= Values.BOOST_STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then np, nd, nn = ch, dist, pod.Name; break end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function executeBoosterSteal(prompt)
    if boosterIsStealing then return end
    if not boosterStealData[prompt] then
        boosterStealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(boosterStealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(boosterStealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = boosterStealData[prompt]
    if not data.ready then return end
    data.ready = false; boosterIsStealing = true
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(Values.BOOST_STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        data.ready = true; boosterIsStealing = false
    end)
end

local function startBoosterAutoSteal()
    if Connections.boosterAutoSteal then return end
    Connections.boosterAutoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoStealBooster or boosterIsStealing then return end
        local p = findNearestBoosterPrompt()
        if p then executeBoosterSteal(p) end
    end)
end

local function stopBoosterAutoSteal()
    if Connections.boosterAutoSteal then Connections.boosterAutoSteal:Disconnect(); Connections.boosterAutoSteal = nil end
    boosterIsStealing = false; currentHighestPrompt = nil; currentHighestValue = nil
end

local function startBoosterSpeedWhileStealing()
    if Connections.boosterSpeedWhileStealing then return end
    Connections.boosterSpeedWhileStealing = RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedWhileStealingBooster or not Player:GetAttribute("Stealing") then return end
        local c = Player.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        local md = getMovementDirection()
        if md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(md.X * Values.BoosterStealSpeed, h.AssemblyLinearVelocity.Y, md.Z * Values.BoosterStealSpeed)
        end
    end)
end

local function stopBoosterSpeedWhileStealing()
    if Connections.boosterSpeedWhileStealing then Connections.boosterSpeedWhileStealing:Disconnect(); Connections.boosterSpeedWhileStealing = nil end
end

local function toggleBoosterSpeedBoost(state)
    Enabled.SpeedBoostBooster = state
    if Connections.boosterSpeed then Connections.boosterSpeed:Disconnect(); Connections.boosterSpeed = nil end
    if Connections.boosterGiantPotion then Connections.boosterGiantPotion:Disconnect(); Connections.boosterGiantPotion = nil end
    if state then
        Connections.boosterSpeed = RunService.Heartbeat:Connect(function()
            local char = Player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = Values.BOOST_SPEED end
            end
        end)
        Connections.boosterGiantPotion = RunService.RenderStepped:Connect(function()
            local char = Player.Character
            local backpack = Player:FindFirstChild("Backpack")
            if not char or not backpack then return end
            local tool = char:FindFirstChild("Giant Potion") or backpack:FindFirstChild("Giant Potion")
            if tool and tool:IsA("Tool") then
                tool.Parent = char; pcall(function() tool:Activate() end)
            end
        end)
    else
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end
end

local TP_POSITIONS = {
    BASE1 = {STAND_HERE = Vector3.new(-334.84, -5.40, 101.02)},
    BASE2 = {STAND_HERE = Vector3.new(-334.84, -5.40, 19.20)},
}

local function carpetTeleportToBase(baseNum)
    local char = Player.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        local carpet = backpack:FindFirstChild("Flying Carpet")
        if carpet and char:FindFirstChild("Humanoid") then
            char.Humanoid:EquipTool(carpet); task.wait(0.1)
        end
    end
    if baseNum == 1 then hrp.CFrame = CFrame.new(TP_POSITIONS.BASE1.STAND_HERE)
    elseif baseNum == 2 then hrp.CFrame = CFrame.new(TP_POSITIONS.BASE2.STAND_HERE) end
end

local standHereOrbs = {}
local function createStandHereOrbs()
    local function createOrb(name, position, text)
        local part = Instance.new("Part")
        part.Name = name; part.Size = Vector3.new(3.8, 0.3, 3.8)
        part.Material = Enum.Material.Neon; part.Color = Color3.fromRGB(139, 92, 246)
        part.Transparency = 0.3; part.Anchored = true; part.CanCollide = false
        part.Position = position; part.Parent = Workspace
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 4, 0); billboard.AlwaysOnTop = true
        billboard.Parent = part
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1,0,1,0); textLabel.BackgroundTransparency = 1
        textLabel.Text = text; textLabel.TextColor3 = Color3.fromRGB(255,255,255)
        textLabel.TextStrokeTransparency = 0.3; textLabel.TextStrokeColor3 = Color3.fromRGB(139,92,246)
        textLabel.Font = Enum.Font.GothamBold; textLabel.TextSize = 18
        textLabel.Parent = billboard
        return part
    end
    standHereOrbs.base1 = createOrb("VoidStandBase1", TP_POSITIONS.BASE1.STAND_HERE, "⬇ STAND HERE (BASE 1) ⬇")
    standHereOrbs.base2 = createOrb("VoidStandBase2", TP_POSITIONS.BASE2.STAND_HERE, "⬇ STAND HERE (BASE 2) ⬇")
end
createStandHereOrbs()

-- Progress Bar GUI (steal indicator)
local sg = Instance.new("ScreenGui")
sg.Name = "VoidHubProgress"; sg.ResetOnSpawn = false; sg.Parent = playerGui

local progressBar = Instance.new("Frame", sg)
progressBar.Size = UDim2.new(0, 420, 0, 56)
progressBar.Position = UDim2.new(0.5, -210, 1, -168)
progressBar.BackgroundColor3 = Color3.fromRGB(10, 7, 15)
progressBar.BorderSizePixel = 0; progressBar.ClipsDescendants = true
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 14)

ProgressLabel = Instance.new("TextLabel", progressBar)
ProgressLabel.Size = UDim2.new(0.35,0,0.5,0); ProgressLabel.Position = UDim2.new(0,10,0,0)
ProgressLabel.BackgroundTransparency = 1; ProgressLabel.Text = "READY"
ProgressLabel.TextColor3 = Color3.fromRGB(255,255,255); ProgressLabel.Font = Enum.Font.GothamBold
ProgressLabel.TextSize = 14; ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left; ProgressLabel.ZIndex = 3

ProgressPercentLabel = Instance.new("TextLabel", progressBar)
ProgressPercentLabel.Size = UDim2.new(1,0,0.5,0); ProgressPercentLabel.Position = UDim2.new(0,0,0.5,0)
ProgressPercentLabel.BackgroundTransparency = 1; ProgressPercentLabel.Text = ""
ProgressPercentLabel.TextColor3 = Color3.fromRGB(167,139,250); ProgressPercentLabel.Font = Enum.Font.GothamBlack
ProgressPercentLabel.TextSize = 18; ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Center; ProgressPercentLabel.ZIndex = 3

local pTrack = Instance.new("Frame", progressBar)
pTrack.Size = UDim2.new(0.94,0,0,8); pTrack.Position = UDim2.new(0.03,0,1,-15)
pTrack.BackgroundColor3 = Color3.fromRGB(18,13,25); pTrack.ZIndex = 2
Instance.new("UICorner", pTrack).CornerRadius = UDim.new(1,0)
ProgressBarFill = Instance.new("Frame", pTrack)
ProgressBarFill.Size = UDim2.new(0,0,1,0); ProgressBarFill.BackgroundColor3 = Color3.fromRGB(139,92,246); ProgressBarFill.ZIndex = 2
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1,0)

-- ============================================================
-- GUI BUILDING — OBSIDIAN LIBRARY
-- ============================================================

-- TAB 1: ⚔ Combat
local CombatBox = Tabs.CombatTab:AddLeftGroupbox("Melee")

CombatBox:AddToggle("SpamBat", {Text = "Spam Bat", Default = Enabled.SpamBat}):OnChanged(function(v)
    Enabled.SpamBat = v
    if v then startSpamBat() else stopSpamBat() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Spam Bat'")
end)

CombatBox:AddToggle("BatAimbot", {Text = "Bat Aimbot", Default = Enabled.BatAimbot}):AddKeyPicker("BatAimbotKey", {Default = "X", SyncToggleState = false, Mode = "Toggle", Text = "Bat Aimbot"}):OnChanged(function(v)
    Enabled.BatAimbot = v
    if v then startBatAimbot() else stopBatAimbot() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Bat Aimbot'")
end)

local CombatBox2 = Tabs.CombatTab:AddLeftGroupbox("Utility")

CombatBox2:AddToggle("AntiRagdoll", {Text = "Anti Ragdoll", Default = Enabled.AntiRagdoll}):OnChanged(function(v)
    Enabled.AntiRagdoll = v
    if v then startAntiRagdoll() else stopAntiRagdoll() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Anti Ragdoll'")
end)

CombatBox2:AddToggle("MedusaInRange", {Text = "Medusa In Range", Default = Enabled.MedusaInRange}):OnChanged(function(v)
    Enabled.MedusaInRange = v
    if v then startMedusaInRange() else stopMedusaInRange() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Medusa In Range'")
end)

CombatBox2:AddSlider("MedusaRange", {Text = "Medusa Range", Default = Values.MedusaRange, Min = 5, Max = 30, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.MedusaRange = v
    Library:Notify("Medusa Range Set To " .. v)
end)

local CombatBox3 = Tabs.CombatTab:AddRightGroupbox("Instant Nuke")

CombatBox3:AddButton({Text = "🔥 Nuke Nearest [Q]", Func = function()
    local n = getNearestPlayer()
    if n then INSTANT_NUKE(n) end
    Library:Notify("Nuked Nearest Player!")
end, Tooltip = "Instantly nukes the nearest player"})

-- TAB 2: 🏃 Movement
local MoveBox1 = Tabs.MovementTab:AddLeftGroupbox("Speed")

MoveBox1:AddToggle("SpeedBoost", {Text = "Speed Boost", Default = Enabled.SpeedBoost}):AddKeyPicker("SpeedKey", {Default = "V", SyncToggleState = false, Mode = "Toggle", Text = "Speed Boost"}):OnChanged(function(v)
    Enabled.SpeedBoost = v
    if v then startSpeedBoost() else stopSpeedBoost() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Speed Boost'")
end)

MoveBox1:AddSlider("BoostSpeed", {Text = "Boost Speed", Default = Values.BoostSpeed, Min = 1, Max = 70, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.BoostSpeed = v
    Library:Notify("Boost Speed Set To " .. v)
end)

local MoveBox2 = Tabs.MovementTab:AddLeftGroupbox("Spin / Galaxy")

MoveBox2:AddToggle("SpinBot", {Text = "Spin Bot", Default = Enabled.SpinBot}):AddKeyPicker("SpinKey", {Default = "N", SyncToggleState = false, Mode = "Toggle", Text = "Spin Bot"}):OnChanged(function(v)
    Enabled.SpinBot = v
    if v then startSpinBot() else stopSpinBot() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Spin Bot'")
end)

MoveBox2:AddSlider("SpinSpeed", {Text = "Spin Speed", Default = Values.SpinSpeed, Min = 5, Max = 50, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.SpinSpeed = v
    Library:Notify("Spin Speed Set To " .. v)
end)

MoveBox2:AddToggle("Galaxy", {Text = "Galaxy Mode", Default = Enabled.Galaxy}):AddKeyPicker("GalaxyKey", {Default = "M", SyncToggleState = false, Mode = "Toggle", Text = "Galaxy Mode"}):OnChanged(function(v)
    Enabled.Galaxy = v
    if v then startGalaxy() else stopGalaxy() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Galaxy Mode'")
end)

MoveBox2:AddSlider("GalaxyGravityPercent", {Text = "Gravity %", Default = Values.GalaxyGravityPercent, Min = 25, Max = 130, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.GalaxyGravityPercent = v
    if galaxyEnabled then adjustGalaxyJump() end
    Library:Notify("Gravity % Set To " .. v)
end)

MoveBox2:AddSlider("HOP_POWER", {Text = "Hop Power", Default = Values.HOP_POWER, Min = 10, Max = 80, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.HOP_POWER = v
    Library:Notify("Hop Power Set To " .. v)
end)

local MoveBox3 = Tabs.MovementTab:AddRightGroupbox("Auto Walk")

MoveBox3:AddToggle("AutoWalkEnabled", {Text = "Auto Left", Default = Enabled.AutoWalkEnabled}):AddKeyPicker("AutoLeftKey", {Default = "Z", SyncToggleState = false, Mode = "Toggle", Text = "Auto Left"}):OnChanged(function(v)
    AutoWalkEnabled = v; Enabled.AutoWalkEnabled = v
    if v then startAutoWalk() else stopAutoWalk() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Auto Left'")
end)

MoveBox3:AddToggle("AutoRightEnabled", {Text = "Auto Right", Default = Enabled.AutoRightEnabled}):AddKeyPicker("AutoRightKey", {Default = "C", SyncToggleState = false, Mode = "Toggle", Text = "Auto Right"}):OnChanged(function(v)
    AutoRightEnabled = v; Enabled.AutoRightEnabled = v
    if v then startAutoRight() else stopAutoRight() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Auto Right'")
end)

local MoveBox4 = Tabs.MovementTab:AddRightGroupbox("Misc")

MoveBox4:AddToggle("Unwalk", {Text = "Unwalk (No Anim)", Default = Enabled.Unwalk}):OnChanged(function(v)
    Enabled.Unwalk = v
    if v then startUnwalk() else stopUnwalk() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Unwalk'")
end)

MoveBox4:AddToggle("PlayerFollower", {Text = "Player Follower", Default = Enabled.PlayerFollower}):OnChanged(function(v)
    Enabled.PlayerFollower = v
    if v then startPlayerFollower() else stopPlayerFollower() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Player Follower'")
end)

MoveBox4:AddSlider("PlayerFollowerSpeed", {Text = "Follow Speed", Default = Values.PlayerFollowerSpeed, Min = 20, Max = 80, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.PlayerFollowerSpeed = v
    Library:Notify("Follow Speed Set To " .. v)
end)

MoveBox4:AddSlider("PlayerFollowerDistance", {Text = "Follow Distance", Default = Values.PlayerFollowerDistance, Min = 1, Max = 15, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.PlayerFollowerDistance = v
    Library:Notify("Follow Distance Set To " .. v)
end)

-- TAB 3: 🎯 Stealing
local StealBox1 = Tabs.StealingTab:AddLeftGroupbox("Auto Steal")

StealBox1:AddToggle("AutoSteal", {Text = "Auto Steal", Default = Enabled.AutoSteal}):OnChanged(function(v)
    Enabled.AutoSteal = v
    if v then startAutoSteal() else stopAutoSteal() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Auto Steal'")
end)

StealBox1:AddSlider("STEAL_DURATION_UI", {Text = "Steal Duration (×10)", Default = math.floor(Values.STEAL_DURATION * 10), Min = 1, Max = 30, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.STEAL_DURATION = v / 10
    Library:Notify("Steal Duration Set To " .. v/10 .. "s")
end)

StealBox1:AddToggle("SpeedWhileStealing", {Text = "Speed While Stealing", Default = Enabled.SpeedWhileStealing}):OnChanged(function(v)
    Enabled.SpeedWhileStealing = v
    if v then startSpeedWhileStealing() else stopSpeedWhileStealing() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Speed While Stealing'")
end)

StealBox1:AddSlider("StealingSpeedValue", {Text = "Steal Speed", Default = Values.StealingSpeedValue, Min = 10, Max = 35, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.StealingSpeedValue = v
    Library:Notify("Steal Speed Set To " .. v)
end)

local StealBox2 = Tabs.StealingTab:AddRightGroupbox("Instant Grab")

StealBox2:AddToggle("AutoStealBooster", {Text = "Instant Grab", Default = Enabled.AutoStealBooster}):OnChanged(function(v)
    Enabled.AutoStealBooster = v; Enabled.HighestBrainrot = false
    if v then startBoosterAutoSteal() else stopBoosterAutoSteal() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Instant Grab'")
end)

StealBox2:AddToggle("HighestBrainrot", {Text = "Insta Grab Highest 🎯", Default = Enabled.HighestBrainrot}):OnChanged(function(v)
    Enabled.HighestBrainrot = v; Enabled.AutoStealBooster = v
    if v then startBoosterAutoSteal() else stopBoosterAutoSteal() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Highest Brainrot Mode'")
end)

StealBox2:AddToggle("SpeedWhileStealingBooster", {Text = "Boost Speed While Stealing", Default = Enabled.SpeedWhileStealingBooster}):OnChanged(function(v)
    Enabled.SpeedWhileStealingBooster = v
    if v then startBoosterSpeedWhileStealing() else stopBoosterSpeedWhileStealing() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Boost Speed While Stealing'")
end)

StealBox2:AddSlider("BoosterStealSpeed", {Text = "Booster Steal Speed", Default = Values.BoosterStealSpeed, Min = 20, Max = 35, Rounding = 0, Compact = false}):OnChanged(function(v)
    Values.BoosterStealSpeed = v
    Library:Notify("Booster Steal Speed Set To " .. v)
end)

local StealBox3 = Tabs.StealingTab:AddRightGroupbox("Carpet Teleport")

StealBox3:AddButton({Text = "🏠 Base 1", Func = function()
    carpetTeleportToBase(1)
    Library:Notify("Teleported to Base 1")
end, Tooltip = "Teleport to Base 1"})

StealBox3:AddButton({Text = "🏠 Base 2", Func = function()
    carpetTeleportToBase(2)
    Library:Notify("Teleported to Base 2")
end, Tooltip = "Teleport to Base 2"})

-- TAB 4: ✨ Visuals
local VisBox1 = Tabs.VisualsTab:AddLeftGroupbox("Performance")

VisBox1:AddToggle("Optimizer", {Text = "Optimizer + XRay", Default = Enabled.Optimizer}):OnChanged(function(v)
    Enabled.Optimizer = v
    if v then enableOptimizer() else disableOptimizer() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Optimizer'")
end)

local VisBox2 = Tabs.VisualsTab:AddLeftGroupbox("Skybox / Lighting")

VisBox2:AddToggle("GalaxySkyBright", {Text = "Galaxy Sky Bright", Default = Enabled.GalaxySkyBright}):OnChanged(function(v)
    Enabled.GalaxySkyBright = v
    if v then enableGalaxySkyBright() else disableGalaxySkyBright() end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Galaxy Sky Bright'")
end)

local VisBox3 = Tabs.VisualsTab:AddRightGroupbox("Config")

VisBox3:AddButton({Text = "💾 Save Config", Func = function()
    local success = SaveConfig()
    Library:Notify(success and "✅ Config Saved!" or "❌ Save Failed!")
end, Tooltip = "Saves your current configuration"})

local VisBox4 = Tabs.VisualsTab:AddRightGroupbox("Keybinds Info")
VisBox4:AddLabel("V=Speed | N=Spin | M=Galaxy | X=Aimbot")
VisBox4:AddLabel("Z=AutoLeft | C=AutoRight | Q=Nuke")
VisBox4:AddLabel("RightCtrl = Toggle GUI")

-- TAB 5: 👻 Booster
local BoostBox1 = Tabs.BoosterTab:AddLeftGroupbox("Semi Invisible")

BoostBox1:AddToggle("SemiInvisible", {Text = "Semi Invisible (With Brainrot)", Default = Enabled.SemiInvisible}):OnChanged(function(v)
    toggleSemiInvisible(v)
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Semi Invisible'")
end)

local BoostBox2 = Tabs.BoosterTab:AddLeftGroupbox("Speed Boost")

BoostBox2:AddToggle("SpeedBoostBooster", {Text = "Potion Speed Boost (37.6 WalkSpeed)", Default = Enabled.SpeedBoostBooster}):OnChanged(function(v)
    toggleBoosterSpeedBoost(v)
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Potion Speed Boost'")
end)

local BoostBox3 = Tabs.BoosterTab:AddRightGroupbox("Carpet Teleport")

BoostBox3:AddButton({Text = "🏠 Base 1", Func = function()
    carpetTeleportToBase(1)
    Library:Notify("Teleported to Base 1")
end})

BoostBox3:AddButton({Text = "🏠 Base 2", Func = function()
    carpetTeleportToBase(2)
    Library:Notify("Teleported to Base 2")
end})

local BoostBox4 = Tabs.BoosterTab:AddRightGroupbox("Extra Scripts")

BoostBox4:AddToggle("APSpam", {Text = "AP Spam", Default = Enabled.APSpam}):OnChanged(function(v)
    Enabled.APSpam = v
    if v then
        loadstring(game:HttpGet("https://monlua-protector.vercel.app/raw/1cc5c7e365de72de0cf05cf384dc9387"))()
    end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'AP Spam'")
end)

BoostBox4:AddToggle("AutoDuels", {Text = "Auto Duels", Default = Enabled.AutoDuels}):OnChanged(function(v)
    Enabled.AutoDuels = v
    if v then
        loadstring(game:HttpGet("https://monlua-protector.vercel.app/raw/8276bfc710f57bae303f1e2e9dcd5dd4"))()
    end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Auto Duels'")
end)

BoostBox4:AddToggle("SemiTP", {Text = "Semi TP", Default = Enabled.SemiTP}):OnChanged(function(v)
    Enabled.SemiTP = v
    if v then
        loadstring(game:HttpGet("https://monlua-protector.vercel.app/raw/03c795e3b1e2ee12eb04728a4cc083c4"))()
    end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Semi TP'")
end)

-- UI Settings Tab
local MenuGroup = Tabs.UISettings:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("custom_cursor", {Text = "Custom Cursor", Default = true}):OnChanged(function(v)
    Library.ShowCustomCursor = v
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Custom Cursor'")
end)

MenuGroup:AddDropdown("DPIDropdown", {Text = "DPI Scale", Default = "100%", Values = {"50%","75%","100%","125%","150%"}}):OnChanged(function(v)
    local val = v:gsub("%%", "")
    local DPI = tonumber(val)
    Library:SetDPIScale(DPI)
    Library:Notify("DPI Scale Set To " .. v)
end)

MenuGroup:AddDivider()
MenuGroup:AddLabel("RightCtrl to show/hide UI")
MenuGroup:AddButton({Text = "Unload", Func = function()
    Library:Unload()
end, Tooltip = "Completely unloads the script"})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('VoidHub')
SaveManager:SetFolder('VoidHub/configs')
SaveManager:BuildConfigSection(Tabs.UISettings)
ThemeManager:ApplyToTab(Tabs.UISettings)

-- ============================================================
-- KEYBIND INPUT HANDLING
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = true end

    if input.KeyCode == KEYBINDS.SPEED then
        Enabled.SpeedBoost = not Enabled.SpeedBoost
        if Toggles.SpeedBoost then Toggles.SpeedBoost:SetValue(Enabled.SpeedBoost) end
        if Enabled.SpeedBoost then startSpeedBoost() else stopSpeedBoost() end
    end
    if input.KeyCode == KEYBINDS.SPIN then
        Enabled.SpinBot = not Enabled.SpinBot
        if Toggles.SpinBot then Toggles.SpinBot:SetValue(Enabled.SpinBot) end
        if Enabled.SpinBot then startSpinBot() else stopSpinBot() end
    end
    if input.KeyCode == KEYBINDS.GALAXY then
        Enabled.Galaxy = not Enabled.Galaxy
        if Toggles.Galaxy then Toggles.Galaxy:SetValue(Enabled.Galaxy) end
        if Enabled.Galaxy then startGalaxy() else stopGalaxy() end
    end
    if input.KeyCode == KEYBINDS.BATAIMBOT then
        Enabled.BatAimbot = not Enabled.BatAimbot
        if Toggles.BatAimbot then Toggles.BatAimbot:SetValue(Enabled.BatAimbot) end
        if Enabled.BatAimbot then startBatAimbot() else stopBatAimbot() end
    end
    if input.KeyCode == KEYBINDS.NUKE then
        local n = getNearestPlayer(); if n then INSTANT_NUKE(n) end
    end
    if input.KeyCode == KEYBINDS.AUTOLEFT then
        AutoWalkEnabled = not AutoWalkEnabled; Enabled.AutoWalkEnabled = AutoWalkEnabled
        if Toggles.AutoWalkEnabled then Toggles.AutoWalkEnabled:SetValue(AutoWalkEnabled) end
        if AutoWalkEnabled then startAutoWalk() else stopAutoWalk() end
    end
    if input.KeyCode == KEYBINDS.AUTORIGHT then
        AutoRightEnabled = not AutoRightEnabled; Enabled.AutoRightEnabled = AutoRightEnabled
        if Toggles.AutoRightEnabled then Toggles.AutoRightEnabled:SetValue(AutoRightEnabled) end
        if AutoRightEnabled then startAutoRight() else stopAutoRight() end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then spaceHeld = false end
end)

-- ============================================================
-- CHARACTER RESPAWN HANDLER
-- ============================================================
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if Enabled.SpinBot   then stopSpinBot();   task.wait(0.1); startSpinBot()   end
    if Enabled.Galaxy    then setupGalaxyForce(); adjustGalaxyJump()            end
    if Enabled.SpamBat   then stopSpamBat();   task.wait(0.1); startSpamBat()   end
    if Enabled.BatAimbot then stopBatAimbot(); task.wait(0.1); startBatAimbot() end
    if Enabled.Unwalk    then startUnwalk() end
    if Enabled.MedusaInRange  then stopMedusaInRange();  task.wait(0.1); startMedusaInRange()  end
    if Enabled.PlayerFollower then stopPlayerFollower(); task.wait(0.1); startPlayerFollower() end
end)

-- ============================================================
-- CONFIG RESTORE ON LOAD
-- ============================================================
task.spawn(function()
    task.wait(3)
    local c = Player.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then
        c = Player.CharacterAdded:Wait(); task.wait(1)
    end

    if Enabled.AntiRagdoll     then startAntiRagdoll()     end
    if Enabled.AutoSteal       then startAutoSteal()        end
    if Enabled.Optimizer       then enableOptimizer()       end
    if Enabled.GalaxySkyBright then enableGalaxySkyBright() end
    task.wait(0.5)
    if Enabled.SpeedBoost      then startSpeedBoost()       end
    if Enabled.SpinBot         then startSpinBot()          end
    if Enabled.SpamBat         then startSpamBat()          end
    if Enabled.BatAimbot       then startBatAimbot()        end
    if Enabled.Galaxy          then startGalaxy()           end
    if Enabled.SpeedWhileStealing then startSpeedWhileStealing() end
    if Enabled.Unwalk          then startUnwalk()           end
    if Enabled.AutoWalkEnabled then AutoWalkEnabled = true;   startAutoWalk()  end
    if Enabled.AutoRightEnabled then AutoRightEnabled = true; startAutoRight() end
    if Enabled.MedusaInRange   then startMedusaInRange()    end
    if Enabled.PlayerFollower  then startPlayerFollower()   end
    if Enabled.AutoStealBooster then startBoosterAutoSteal() end
    if Enabled.SpeedWhileStealingBooster then startBoosterSpeedWhileStealing() end
    if Enabled.SpeedBoostBooster then toggleBoosterSpeedBoost(true) end
end)


-- ============================================================
-- SEMI TP FEATURE STATE
-- ============================================================
local pos1        = Vector3.new(-352.98, -7, 74.30)
local pos2        = Vector3.new(-352.98, -6.49, 45.76)
local standing1   = Vector3.new(-336.36, -4.59, 99.51)
local standing2   = Vector3.new(-334.81, -4.59, 18.90)

local spot1_sequence = {
    CFrame.new(-370.810913,-7.00000334,41.2687263,0.99984771,1.22364419e-09,0.0174523517,-6.54859778e-10,1,-3.2596418e-08,-0.0174523517,3.25800258e-08,0.99984771),
    CFrame.new(-336.355286,-5.10107088,17.2327671,-0.999883354,-2.76150569e-08,0.0152716246,-2.88224964e-08,1,-7.88441525e-08,-0.0152716246,-7.9275118e-08,-0.999883354),
}
local spot2_sequence = {
    CFrame.new(-354.782867,-7.00000334,92.8209305,-0.999997616,-1.11891862e-09,-0.00218066527,-1.11958298e-09,1,3.03415071e-10,0.00218066527,3.05855785e-10,-0.999997616),
    CFrame.new(-336.942902,-5.10106993,99.3276443,0.999914348,-3.63984611e-08,0.0130875716,3.67094941e-08,1,-2.35254749e-08,-0.0130875716,2.40038975e-08,0.999914348),
}
local autoSemiTpCFrameLeft  = CFrame.new(-349.325867,-7.00000238,95.0031433,-0.999048233,-8.29406233e-09,-0.0436184891,-1.03892832e-08,1,4.78084594e-08,0.0436184891,4.82161227e-08,-0.999048233)
local autoSemiTpCFrameRight = CFrame.new(-349.560211,-7.00000238,27.0543289,-0.999961913,5.50995267e-08,-0.00872585084,5.48100907e-08,1,3.34090586e-08,0.00872585084,3.29295204e-08,-0.999961913)

local semiTPEnabled     = false
local autoPotion        = false
local speedAfterSteal   = false
local SEMI_SPEED_BOOST  = 28
local semiSpeedConn     = nil
local semiIsHolding     = false
local semiEquipTask     = nil

-- Semi TP ESP markers
local function createSemiTPESP(position, labelText)
    local box = Instance.new("Part")
    box.Size = Vector3.new(5,0.5,5); box.Position = position
    box.Anchored = true; box.CanCollide = false; box.Transparency = 0.5
    box.Material = Enum.Material.Neon; box.Color = Color3.fromRGB(10,7,15); box.Parent = Workspace
    local sel = Instance.new("SelectionBox", box)
    sel.Adornee = box; sel.LineThickness = 0.05; sel.Color3 = Color3.fromRGB(167,139,250)
    local bb = Instance.new("BillboardGui", box)
    bb.Adornee = box; bb.Size = UDim2.new(0,150,0,40)
    bb.StudsOffset = Vector3.new(0,2,0); bb.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = labelText; lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextSize = 18; lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.5; lbl.TextStrokeColor3 = Color3.fromRGB(88,28,135)
end
createSemiTPESP(pos1, "Teleport Here")
createSemiTPESP(pos2, "Teleport Here")
createSemiTPESP(standing1, "Standing 1")
createSemiTPESP(standing2, "Standing 2")
createSemiTPESP(autoSemiTpCFrameLeft.Position, "Auto TP Left")
createSemiTPESP(autoSemiTpCFrameRight.Position, "Auto TP Right")

-- Semi TP proximity hooks
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, plr)
    if plr ~= Player or not semiTPEnabled then return end
    semiIsHolding = true
    if semiEquipTask then task.cancel(semiEquipTask) end
    semiEquipTask = task.spawn(function()
        task.wait(1)
        if semiIsHolding and semiTPEnabled then
            local bp = Player:WaitForChild("Backpack", 2)
            if bp then
                local carpet = bp:FindFirstChild("Flying Carpet")
                if carpet and Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid:EquipTool(carpet)
                end
            end
        end
    end)
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, plr)
    if plr ~= Player then return end
    semiIsHolding = false
    if semiEquipTask then task.cancel(semiEquipTask) end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, plr)
    if plr ~= Player or not semiTPEnabled then return end
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local bp  = Player:FindFirstChild("Backpack")
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if bp and hum then
            local carpet = bp:FindFirstChild("Flying Carpet")
            if carpet then hum:EquipTool(carpet); task.wait(0.1) end
        end
        local d1 = (root.Position - pos1).Magnitude
        local d2 = (root.Position - pos2).Magnitude
        root.CFrame = CFrame.new(d1 < d2 and pos1 or pos2)
        if autoPotion then
            local bp2 = Player:FindFirstChild("Backpack")
            if bp2 then
                local potion = bp2:FindFirstChild("Giant Potion")
                if potion and Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    Player.Character.Humanoid:EquipTool(potion)
                    task.wait(0.1)
                    pcall(function() potion:Activate() end)
                end
            end
        end
        if speedAfterSteal then
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if semiSpeedConn then semiSpeedConn:Disconnect() end
                semiSpeedConn = RunService.Heartbeat:Connect(function()
                    if not speedAfterSteal or humanoid.MoveDirection.Magnitude == 0 or not root.Parent then return end
                    local md = humanoid.MoveDirection.Unit
                    root.AssemblyLinearVelocity = Vector3.new(md.X*SEMI_SPEED_BOOST, root.AssemblyLinearVelocity.Y, md.Z*SEMI_SPEED_BOOST)
                end)
            end
        end
    end
    semiIsHolding = false
end)

local function semiTPExecuteSequence(sequence)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local hum  = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    local bp   = Player:FindFirstChild("Backpack")
    if not root or not hum or not bp then return end
    local carpet = bp:FindFirstChild("Flying Carpet")
    if carpet then hum:EquipTool(carpet); task.wait(0.1) end
    root.CFrame = sequence[1]; task.wait(0.1); root.CFrame = sequence[2]
    task.wait(0.2)
    local d1 = (root.Position - pos1).Magnitude
    local d2 = (root.Position - pos2).Magnitude
    root.CFrame = CFrame.new(d1 < d2 and pos1 or pos2)
end

-- ============================================================
-- AUTO DUEL FEATURE STATE
-- ============================================================
local duelWaypoints         = {}
local duelCurrentWP         = 1
local duelMoving            = false
local duelConnection        = nil
local duelSpeedConn         = nil
local duelIsWaitingForGrab  = false
local duelGrabDetected      = false
local duelStatusText        = "Ready"
local duelSpeedText         = "--"
local duelStatusColor       = Color3.fromRGB(167,139,250)

local function duelStopMoving()
    if duelConnection then duelConnection:Disconnect(); duelConnection = nil end
    duelMoving = false; duelIsWaitingForGrab = false; duelGrabDetected = false
    duelStatusText = "Ready"; duelStatusColor = Color3.fromRGB(167,139,250)
end

local function duelMoveToWaypoint()
    if duelConnection then duelConnection:Disconnect() end
    duelConnection = RunService.Stepped:Connect(function()
        if not duelMoving or duelIsWaitingForGrab then return end
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local wp   = duelWaypoints[duelCurrentWP]
        local dist = (root.Position - wp.position).Magnitude
        if dist < 5 then
            if (duelCurrentWP == 4 or duelCurrentWP == 6) and not duelGrabDetected then
                duelIsWaitingForGrab = true
                duelStatusText  = "Grab the pet please..."
                duelStatusColor = Color3.fromRGB(250,166,26)
                root.AssemblyLinearVelocity = Vector3.zero
                return
            end
            if duelCurrentWP == #duelWaypoints then
                duelStatusText  = "FINISHED!"
                duelStatusColor = Color3.fromRGB(34,197,94)
                duelStopMoving(); return
            end
            duelCurrentWP += 1
            duelStatusText  = "Arrived at: "..duelCurrentWP
            duelStatusColor = Color3.fromRGB(167,139,250)
        else
            local dir = (wp.position - root.Position).Unit
            root.AssemblyLinearVelocity = Vector3.new(dir.X*wp.speed, root.AssemblyLinearVelocity.Y, dir.Z*wp.speed)
        end
    end)
end

duelSpeedConn = RunService.Heartbeat:Connect(function()
    local char = Player.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if hum then
        duelSpeedText = "Speed: "..tostring(math.floor(hum.WalkSpeed))
        if hum.WalkSpeed < 23 and duelIsWaitingForGrab and not duelGrabDetected then
            task.wait(0.3)
            duelIsWaitingForGrab = false; duelGrabDetected = true
            duelStatusText  = "Arrived at: "..duelCurrentWP
            duelStatusColor = Color3.fromRGB(167,139,250)
        end
    end
end)

local function startAutoDuel()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    duelMoving = true; duelGrabDetected = false
    if (root.Position - Vector3.new(-475,-7,96)).Magnitude > (root.Position - Vector3.new(-474,-7,23)).Magnitude then
        duelWaypoints = {
            {position=Vector3.new(-475,-7,96),  speed=59},
            {position=Vector3.new(-483,-5,95),  speed=59},
            {position=Vector3.new(-487,-5,95),  speed=55},
            {position=Vector3.new(-492,-5,95),  speed=55},
            {position=Vector3.new(-473,-7,95),  speed=29},
            {position=Vector3.new(-473,-7,11),  speed=29},
        }
    else
        duelWaypoints = {
            {position=Vector3.new(-474,-7,23),  speed=55},
            {position=Vector3.new(-484,-5,24),  speed=55},
            {position=Vector3.new(-488,-5,24),  speed=55},
            {position=Vector3.new(-493,-5,25),  speed=55},
            {position=Vector3.new(-473,-7,25),  speed=29},
            {position=Vector3.new(-474,-7,112), speed=29},
        }
    end
    duelCurrentWP = 1; duelMoveToWaypoint()
    duelStatusText  = "Running..."
    duelStatusColor = Color3.fromRGB(167,139,250)
end

-- ============================================================
-- AP SPAM FEATURE STATE
-- ============================================================
local apSelectedPlayers = {}
local apSelectedSet     = {}
local autoDefenseEnabled = false
local lastDefenseTime   = 0
local defenseCooldown   = 3

local function apSendCommands(targetName)
    local commands = {
        ";balloon "  ..targetName,
        ";rocket "   ..targetName,
        ";morph "    ..targetName,
        ";jumpscare "..targetName,
        ";jail "     ..targetName,
    }
    local channel = TextChatService.TextChannels and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if not channel then return end
    task.spawn(function()
        for _, cmd in ipairs(commands) do
            pcall(function() channel:SendAsync(cmd) end)
            task.wait(0.12)
        end
    end)
end

local function apSpamSelected()
    if #apSelectedPlayers == 0 then return end
    for _, plr in ipairs(apSelectedPlayers) do apSendCommands(plr.Name) end
end

local function checkForStealingNotification()
    local ok, result = pcall(function()
        local ng = Player.PlayerGui:FindFirstChild("Notification"); if not ng then return false end
        local nf = ng:FindFirstChild("Notification"); if not nf then return false end
        local ch = nf:GetChildren(); if #ch < 4 then return false end
        local tl = ch[4]; if not tl:IsA("TextLabel") then return false end
        return tl.Text:find("Someone is stealing your") ~= nil
    end)
    return ok and result
end

-- Auto defense loop
local lastDefCheck = 0
task.spawn(function()
    while task.wait(0.1) do
        if autoDefenseEnabled and tick() - lastDefCheck >= 0.1 then
            lastDefCheck = tick()
            if checkForStealingNotification() then
                local now = tick()
                if now - lastDefenseTime >= defenseCooldown then
                    lastDefenseTime = now
                    local myChar = Player.Character
                    if myChar then
                        local myHead = myChar:FindFirstChild("Head")
                        if myHead then
                            local closest, closestDist = nil, math.huge
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr ~= Player then
                                    local head = plr.Character and plr.Character:FindFirstChild("Head")
                                    if head then
                                        local dist = (head.Position - myHead.Position).Magnitude
                                        if dist < closestDist then closestDist = dist; closest = plr end
                                    end
                                end
                            end
                            if closest then apSendCommands(closest.Name) end
                        end
                    end
                end
            end
        end
    end
end)

-- F key for AP spam
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then apSpamSelected() end
end)

-- ============================================================
-- TAB 6: Semi TP
-- ============================================================
local SemiBox1 = Tabs.SemiTPTab:AddLeftGroupbox("Semi Teleport")

SemiBox1:AddToggle("SemiTPEnabled", {Text = "Enable Semi TP (On Steal)", Default = false}):OnChanged(function(v)
    semiTPEnabled = v
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Semi TP'")
end)

SemiBox1:AddToggle("AutoPotionSemi", {Text = "Auto Giant Potion On Steal", Default = false}):OnChanged(function(v)
    autoPotion = v
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Auto Potion'")
end)

SemiBox1:AddToggle("SpeedAfterSteal", {Text = "Speed Boost After Steal", Default = false}):OnChanged(function(v)
    speedAfterSteal = v
    if not v and semiSpeedConn then semiSpeedConn:Disconnect(); semiSpeedConn = nil end
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Speed After Steal'")
end)

SemiBox1:AddSlider("SemiSpeedBoost", {Text = "Speed After Steal Amount", Default = SEMI_SPEED_BOOST, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(v)
    SEMI_SPEED_BOOST = v
    Library:Notify("Semi Speed Set To " .. v)
end)

local SemiBox2 = Tabs.SemiTPTab:AddRightGroupbox("Manual TP")

SemiBox2:AddButton({Text = "▶ Auto TP Left", Func = function()
    semiTPExecuteSequence(spot1_sequence)
    Library:Notify("Executed Auto TP Left")
end, Tooltip = "TP through left spot sequence"})

SemiBox2:AddButton({Text = "▶ Auto TP Right", Func = function()
    semiTPExecuteSequence(spot2_sequence)
    Library:Notify("Executed Auto TP Right")
end, Tooltip = "TP through right spot sequence"})

SemiBox2:AddButton({Text = "📍 TP to Spot 1 (Pos1)", Func = function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(pos1) end
    Library:Notify("Teleported to Pos 1")
end})

SemiBox2:AddButton({Text = "📍 TP to Spot 2 (Pos2)", Func = function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(pos2) end
    Library:Notify("Teleported to Pos 2")
end})

SemiBox2:AddLabel("ESP markers placed in world for guidance.")

-- ============================================================
-- TAB 7: Auto Duel
-- ============================================================
local DuelBox1 = Tabs.AutoDuelTab:AddLeftGroupbox("Auto Duel Bot")

local duelStatusLabel = DuelBox1:AddLabel("Status: Ready")
local duelSpeedLabel  = DuelBox1:AddLabel("Speed: --")

-- Live update the duel status labels
RunService.Heartbeat:Connect(function()
    if duelStatusLabel then pcall(function() duelStatusLabel:SetText("Status: "..duelStatusText) end) end
    if duelSpeedLabel  then pcall(function() duelSpeedLabel:SetText(duelSpeedText) end) end
end)

DuelBox1:AddToggle("AutoDuelRunning", {Text = "Start / Stop Auto Duel", Default = false}):OnChanged(function(v)
    if v then
        startAutoDuel()
        Library:Notify("Auto Duel Started!")
    else
        duelStopMoving()
        Library:Notify("Auto Duel Stopped")
    end
end)

local DuelBox2 = Tabs.AutoDuelTab:AddRightGroupbox("How It Works")
DuelBox2:AddLabel("Bot drives to duel positions automatically.")
DuelBox2:AddLabel("When paused: grab the pet from the podium.")
DuelBox2:AddLabel("Bot detects grab by speed drop below 23.")
DuelBox2:AddLabel("Works for both Left and Right duel spots.")

-- ============================================================
-- TAB 8: AP Spam
-- ============================================================
local APBox1 = Tabs.APSpamTab:AddLeftGroupbox("Auto Defense")

APBox1:AddToggle("AutoDefense", {Text = "Auto AP When Being Stolen From", Default = false}):OnChanged(function(v)
    autoDefenseEnabled = v
    Library:Notify((v and "Enabled" or "Disabled") .. " 'Auto Defense'")
end)

APBox1:AddLabel("Detects 'Someone is stealing' notification.")
APBox1:AddLabel("Auto-spams AP on closest player.")

local APBox2 = Tabs.APSpamTab:AddRightGroupbox("Manual Spam")

APBox2:AddButton({Text = "📣 Spam Nearest Player", Func = function()
    local nearest = getNearestPlayer()
    if nearest then
        apSendCommands(nearest.Name)
        Library:Notify("Spammed " .. nearest.DisplayName)
    else
        Library:Notify("No player found nearby")
    end
end, Tooltip = "Spam AP commands on nearest player"})

APBox2:AddButton({Text = "📣 Spam Selected [F]", Func = function()
    apSpamSelected()
    Library:Notify("Spammed "..#apSelectedPlayers.." selected player(s)")
end, Tooltip = "Spam all selected players (also F key)"})

local APBox3 = Tabs.APSpamTab:AddLeftGroupbox("Select Targets")

-- We manually build a scrolling player list using Obsidian labels + buttons
local apPlayerButtons = {}

local function refreshAPPlayerList()
    -- Clear old entries
    for _, btn in ipairs(apPlayerButtons) do
        pcall(function() btn:Remove() end)
    end
    apPlayerButtons = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local isSelected = apSelectedSet[plr] == true
            local label = (isSelected and "[✓] " or "[ ] ") .. plr.DisplayName
            local btn = APBox3:AddButton({Text = label, Func = function()
                if apSelectedSet[plr] then
                    apSelectedSet[plr] = nil
                    for i, p in ipairs(apSelectedPlayers) do
                        if p == plr then table.remove(apSelectedPlayers, i); break end
                    end
                else
                    apSelectedSet[plr] = true
                    table.insert(apSelectedPlayers, plr)
                end
                refreshAPPlayerList()
            end})
            table.insert(apPlayerButtons, btn)
        end
    end
end

APBox3:AddButton({Text = "🔄 Refresh Player List", Func = function()
    refreshAPPlayerList()
    Library:Notify("Player list refreshed")
end})

task.spawn(function() task.wait(2); refreshAPPlayerList() end)

Players.PlayerAdded:Connect(function() task.wait(0.5); refreshAPPlayerList() end)
Players.PlayerRemoving:Connect(function(removedPlayer)
    apSelectedSet[removedPlayer] = nil
    for i = #apSelectedPlayers, 1, -1 do
        if apSelectedPlayers[i] == removedPlayer then table.remove(apSelectedPlayers, i) end
    end
    task.wait(0.1); refreshAPPlayerList()
end)

-- ============================================================
-- FINAL NOTIFICATIONS
-- ============================================================
Library:Notify("✨ Void Hub Loaded — Obsidian UI")
Library:Notify("New: Semi TP + Auto Duel + AP Spam tabs added!")
print("✨ VOID HUB LOADED (Obsidian UI) — 8 Tabs Active")
print("⌨️  V=Speed | N=Spin | M=Galaxy | X=Aimbot | Z=AutoLeft | C=AutoRight | Q=Nuke | F=AP Spam")
