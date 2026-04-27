-- [[ ULTIMATE KAITUN GUI - V1 ]]
-- [[ POWERED BY PROXY.LIB & ANTIGRAVITY ]]

local Proxy = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/Proxy.Lib/main/Source.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- [[ GLOBAL SETTINGS ]]
getgenv().Config = {
    FarmLevel = false,
    AutoStats = true,
    FastAttack = true,
    FarmHeight = 8,
    TweenSpeed = 350,
    FlyHeight = 400
}

-- [[ DATA ]]
local Quests = {
    {Level = 0, NPC = CFrame.new(1059.3, 15.4, 1550.4), QName = "BanditQuest1", Mob = "Bandit", QLevel = 1},
    {Level = 10, NPC = CFrame.new(-1598, 35.5, 153.3), QName = "JungleQuest", Mob = "Monkey", QLevel = 1},
    {Level = 15, NPC = CFrame.new(-1598, 35.5, 153.3), QName = "JungleQuest", Mob = "Gorilla", QLevel = 2},
    {Level = 30, NPC = CFrame.new(-1141, 4.1, 3831.5), QName = "BuggyQuest1", Mob = "Pirate", QLevel = 1},
    {Level = 45, NPC = CFrame.new(-1141, 4.1, 3831.5), QName = "BuggyQuest1", Mob = "Brute", QLevel = 2},
    {Level = 60, NPC = CFrame.new(894.4, 5.1, 4392.4), QName = "DesertQuest", Mob = "Desert Bandit", QLevel = 1},
    {Level = 75, NPC = CFrame.new(894.4, 5.1, 4392.4), QName = "DesertQuest", Mob = "Desert Officer", QLevel = 2},
    {Level = 90, NPC = CFrame.new(1389.7, 88.1, -1298.9), QName = "SnowQuest", Mob = "Snow Bandit", QLevel = 1},
    {Level = 105, NPC = CFrame.new(1389.7, 88.1, -1298.9), QName = "SnowQuest", Mob = "Snowman", QLevel = 2},
    {Level = 120, NPC = CFrame.new(-5039.5, 27.3, 4324.6), QName = "MarineQuest2", Mob = "Chief Petty Officer", QLevel = 1},
    {Level = 150, NPC = CFrame.new(-4839.5, 716.3, -2619.4), QName = "SkyQuest", Mob = "Sky Bandit", QLevel = 1},
    {Level = 175, NPC = CFrame.new(-4839.5, 716.3, -2619.4), QName = "SkyQuest", Mob = "Dark Master", QLevel = 2},
    {Level = 190, NPC = CFrame.new(5308.9, 1.6, 475.1), QName = "PrisonerQuest", Mob = "Prisoner", QLevel = 1},
    {Level = 210, NPC = CFrame.new(5308.9, 1.6, 475.1), QName = "PrisonerQuest", Mob = "Dangerous Prisoner", QLevel = 2},
    {Level = 250, NPC = CFrame.new(-1580, 6.3, -2986), QName = "ColosseumQuest", Mob = "Toga Warrior", QLevel = 1},
    {Level = 275, NPC = CFrame.new(-1580, 6.3, -2986), QName = "ColosseumQuest", Mob = "Gladiator", QLevel = 2},
    {Level = 300, NPC = CFrame.new(-5313.3, 10.9, 8515.2), QName = "MagmaQuest", Mob = "Military Soldier", QLevel = 1},
    {Level = 325, NPC = CFrame.new(-5313.3, 10.9, 8515.2), QName = "MagmaQuest", Mob = "Military Spy", QLevel = 2},
    {Level = 375, NPC = CFrame.new(61122.6, 18.4, 1569.3), QName = "FishmanQuest", Mob = "Fishman Warrior", QLevel = 1},
    {Level = 400, NPC = CFrame.new(61122.6, 18.4, 1569.3), QName = "FishmanQuest", Mob = "Fishman Commando", QLevel = 2},
    {Level = 450, NPC = CFrame.new(-4721.8, 843.8, -1949.9), QName = "SkyExp1Quest", Mob = "God's Guard", QLevel = 1},
    {Level = 475, NPC = CFrame.new(-7859, 5544, -381), QName = "SkyExp1Quest", Mob = "Shanda", QLevel = 2},
    {Level = 525, NPC = CFrame.new(-7906.8, 5634.6, -1411.9), QName = "SkyExp2Quest", Mob = "Royal Squad", QLevel = 1},
    {Level = 550, NPC = CFrame.new(-7906.8, 5634.6, -1411.9), QName = "SkyExp2Quest", Mob = "Royal Soldier", QLevel = 2},
    {Level = 625, NPC = CFrame.new(5259.8, 37.3, 4050), QName = "FountainQuest", Mob = "Galley Pirate", QLevel = 1},
    {Level = 650, NPC = CFrame.new(5259.8, 37.3, 4050), QName = "FountainQuest", Mob = "Galley Captain", QLevel = 2},
}

-- [[ CORE LOGIC ]]
local function FastAttack()
    if not getgenv().Config.FastAttack then return end
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
        local regAttack = net:WaitForChild("RE/RegisterAttack")
        local regHit = net:WaitForChild("RE/RegisterHit")
        local char = LocalPlayer.Character
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool.ToolTip == "Melee" then
            local targetList = {}
            for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 55 then
                    table.insert(targetList, {v, v.HumanoidRootPart})
                end
            end
            if #targetList > 0 then
                regAttack:FireServer(0.125)
                regHit:FireServer(targetList[1][2], targetList)
            end
        end
    end)
end

local function Tween(targetCF)
    local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local dist = (hrp.Position - targetCF.Position).Magnitude
    if dist < 20 then return end
    if dist > 150 then
        TweenService:Create(hrp, TweenInfo.new(1), {CFrame = CFrame.new(hrp.Position.X, getgenv().Config.FlyHeight, hrp.Position.Z)}):Play()
        task.wait(1.1)
        local tPos = targetCF.Position
        local t = TweenService:Create(hrp, TweenInfo.new((hrp.Position - Vector3.new(tPos.X, getgenv().Config.FlyHeight, tPos.Z)).Magnitude / getgenv().Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tPos.X, getgenv().Config.FlyHeight, tPos.Z)})
        t:Play() t.Completed:Wait()
    end
    TweenService:Create(hrp, TweenInfo.new(1), {CFrame = targetCF}):Play()
    task.wait(1.1)
end

local function BringMobs(name)
    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
        if v.Name == name and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            v.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -getgenv().Config.FarmHeight, 0)
            v.HumanoidRootPart.CanCollide = false
            v.HumanoidRootPart.Size = Vector3.new(35, 35, 35)
        end
    end
end

-- [[ UI INITIALIZATION ]]
local Window = Proxy:CreateWindow({
    Name = "ANTIGRAVITY KAITUN",
    ConfigName = "AntiGravityConfig",
    Theme = "Dark"
})

local MainTab = Window:CreateTab({
    Name = "Farming",
    Icon = "rbxassetid://4483345998"
})

MainTab:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().Config.FarmLevel = Value
    end
})

MainTab:CreateSlider({
    Name = "Farm Height",
    Range = {5, 15},
    Increment = 0.5,
    Suffix = " studs",
    CurrentValue = 8,
    Callback = function(Value)
        getgenv().Config.FarmHeight = Value
    end
})

MainTab:CreateSlider({
    Name = "Tween Speed",
    Range = {200, 500},
    Increment = 10,
    Suffix = " speed",
    CurrentValue = 350,
    Callback = function(Value)
        getgenv().Config.TweenSpeed = Value
    end
})

local StatsTab = Window:CreateTab({
    Name = "Stats",
    Icon = "rbxassetid://4483345998"
})

StatsTab:CreateToggle({
    Name = "Auto Stats Melee",
    CurrentValue = true,
    Callback = function(Value)
        getgenv().Config.AutoStats = Value
    end
})

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998"
})

MiscTab:CreateToggle({
    Name = "Fast Attack",
    CurrentValue = true,
    Callback = function(Value)
        getgenv().Config.FastAttack = Value
    end
})

-- [[ LOOPS ]]
task.spawn(function()
    while true do
        if getgenv().Config.FarmLevel then
            pcall(function()
                local lvl = LocalPlayer.Data.Level.Value
                local q = Quests[1]
                for _, v in pairs(Quests) do if lvl >= v.Level then q = v end end
                
                local hasQuest = LocalPlayer.PlayerGui.Main:FindFirstChild("Quest").Visible
                if not hasQuest then
                    Tween(q.NPC)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", q.QName, q.QLevel)
                else
                    local target = nil
                    for _, v in pairs(game.Workspace.Enemies:GetChildren()) do
                        if v.Name == q.Mob and v.Humanoid.Health > 0 then target = v break end
                    end
                    
                    if target then
                        -- Stabilize
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        if not hrp:FindFirstChild("AI_Clip") then
                            local bv = Instance.new("BodyVelocity", hrp)
                            bv.Name = "AI_Clip"
                            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                        
                        hrp.CFrame = CFrame.new(target.HumanoidRootPart.Position.X, target.HumanoidRootPart.Position.Y + getgenv().Config.FarmHeight, target.HumanoidRootPart.Position.Z)
                        
                        -- Equip
                        local char = LocalPlayer.Character
                        if not (char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").ToolTip == "Melee") then
                            for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if t.ToolTip == "Melee" then char.Humanoid:EquipTool(t) break end
                            end
                        end
                        
                        BringMobs(q.Mob)
                        FastAttack()
                    else
                        Tween(q.NPC * CFrame.new(0, 50, 0))
                    end
                end
            end)
        end
        task.wait(0.01)
    end
end)

task.spawn(function()
    while true do
        if getgenv().Config.AutoStats then
            local p = LocalPlayer.Data.StatsPoints.Value
            if p > 0 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", p)
            end
        end
        task.wait(1)
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("ULTIMATE KAITUN GUI LOADED!")
