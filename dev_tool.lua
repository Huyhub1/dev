
local _DELAY = 0.1

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local TS = game:GetService("TweenService")

local function CreateElement(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local ScreenGui = CreateElement("ScreenGui", {Name = "Gemini_Dev_Scanner", Parent = game.CoreGui, ResetOnSpawn = false})

local ToggleBtn = CreateElement("TextButton", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 80, 0, 30),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Color3.fromRGB(0, 150, 200),
    Text = "OPEN MENU",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14,
    ZIndex = 10
})
CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleBtn})

local Main = CreateElement("Frame", {
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Position = UDim2.new(0.02, 0, 0.3, 0),
    Size = UDim2.new(0, 220, 0, 400),
    Visible = false,
    Active = true,
    Draggable = true
})
CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Main})

local Title = CreateElement("TextLabel", {
    Parent = Main,
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
    Text = "DEV SCANNER (HOST)",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12
})
CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Title})

local function ToggleMenu()
    Main.Visible = not Main.Visible
    ToggleBtn.Text = Main.Visible and "CLOSE MENU" or "OPEN MENU"
    ToggleBtn.BackgroundColor3 = Main.Visible and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(0, 150, 200)
    task.wait(_DELAY)
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
        ToggleMenu()
    end
end)

local function SendToHost(data)
    local url = "http://localhost:3000/save"
    local HttpService = game:GetService("HttpService")
    local body = HttpService:JSONEncode({
        filename = "collected_data.txt",
        content = data,
        mode = "append"
    })
    
    local headers = {["Content-Type"] = "application/json"}
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if req then
        req({Url = url, Method = "POST", Headers = headers, Body = body})
    end
end

local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function AddFuncButton(text, color, pos, callback)
    local btn = CreateElement("TextButton", {
        Parent = Main,
        Text = text,
        Size = UDim2.new(0.9, 0, 0, 35),
        Position = pos,
        BackgroundColor3 = color,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 12
    })
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})

    btn.MouseButton1Click:Connect(function()
        TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        task.wait(0.1)
        TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = color, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        task.wait(_DELAY)
        callback()
    end)
end

AddFuncButton("📍 Lấy Tọa Độ -> Host", Color3.fromRGB(0, 100, 200), UDim2.new(0.05, 0, 0.12, 0), function()
    local char = GetCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local data = "[CFRAME]: CFrame.new(" .. tostring(root.Position) .. ")"
        print(data)
        SendToHost(data)
    end
end)

AddFuncButton("🕵️ Scan Team Options -> Host", Color3.fromRGB(150, 0, 150), UDim2.new(0.05, 0, 0.24, 0), function()
    local gui = PlayerGui:FindFirstChild("gui")
    if gui then
        local teamChoice = gui:FindFirstChild("teamChoice")
        if teamChoice then
            local options = teamChoice:FindFirstChild("options")
            if options then
                local info = "[TEAM OPTIONS SCAN]:"
                for _, v in pairs(options:GetChildren()) do
                    info = info .. "\n- Name: " .. v.Name .. " (" .. v.ClassName .. ")"
                end
                print("\n" .. info)
                SendToHost(info)
            else
                print("No 'options' frame found in teamChoice")
                SendToHost("[ERROR]: No 'options' frame found in teamChoice")
            end
        else
            print("No 'teamChoice' frame found")
            SendToHost("[ERROR]: No 'teamChoice' frame found")
        end
    end
end)

AddFuncButton("🖱️ Lấy GUI Info -> Host", Color3.fromRGB(130, 0, 180), UDim2.new(0.05, 0, 0.36, 0), function()
    local conn
    conn = UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local guis = PlayerGui:GetGuiObjectsAtPosition(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
            if #guis > 0 then
                local info = "[GUI CLICK DATA]:"
                for i = 1, math.min(#guis, 20) do
                    local v = guis[i]
                    info = info .. "\n" .. i .. ". " .. v.Name .. " (" .. v.ClassName .. ") | Path: " .. v:GetFullName() .. " | Text: " .. (v:IsA("TextButton") or v:IsA("TextLabel") and v.Text or "N/A")
                end
                print("\n" .. info)
                SendToHost(info)
            end
            conn:Disconnect()
        end
    end)
end)

AddFuncButton("📦 Lấy Vật Thể -> Host", Color3.fromRGB(0, 130, 80), UDim2.new(0.05, 0, 0.48, 0), function()
    local char = GetCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, v in pairs(Workspace:GetPartBoundsInRadius(root.Position, 25)) do
            if not v:IsDescendantOf(char) then
                local info = "[OBJECT]: Name='" .. v.Name .. "' Path='" .. v:GetFullName() .. "'"
                print("\n" .. info)
                SendToHost(info)
                break
            end
        end
    end
end)

AddFuncButton("🏝️ Scan IslandPoints -> Host", Color3.fromRGB(0, 150, 150), UDim2.new(0.05, 0, 0.60, 0), function()
    local folder = Workspace:FindFirstChild("islandPoints")
    if folder then
        local info = "[ISLAND POINTS SCAN]:\n"
        for _, v in pairs(folder:GetChildren()) do
            if v:IsA("BasePart") then
                 info = info .. "- Name='" .. v.Name .. "' CFrame=" .. tostring(v.CFrame) .. "\n"
            elseif v:IsA("Model") and v.PrimaryPart then
                 info = info .. "- Name='" .. v.Name .. "' (Model) CFrame=" .. tostring(v.PrimaryPart.CFrame) .. "\n"
            else
                 info = info .. "- Name='" .. v.Name .. "' [No CFrame/Part]\n"
            end
        end
        print("\n" .. info)
        SendToHost(info)
    else
        print("[ERROR]: workspace.islandPoints not found!")
        SendToHost("[ERROR]: workspace.islandPoints not found!")
    end
end)

AddFuncButton("🗺️ Check Map -> Host", Color3.fromRGB(255, 100, 0), UDim2.new(0.05, 0, 0.72, 0), function()
    local mapInfo = "[MAP SCAN]:\n"
    for _, v in pairs(Workspace:GetChildren()) do
        if not (v:IsA("Camera") or v:IsA("Terrain") or v.Name == "Baseplate" or v.Name == "Camera") and not Players:GetPlayerFromCharacter(v) then
             mapInfo = mapInfo .. "- " .. v.Name .. " [" .. v.ClassName .. "]\n"
        end
    end
    print("\n" .. mapInfo)
    SendToHost(mapInfo)
end)

AddFuncButton("🗑️ Xóa Console", Color3.fromRGB(80, 80, 80), UDim2.new(0.05, 0, 0.84, 0), function()
    for i = 1, 50 do print(" ") end
end)

-- AI-Roblox Bridge Polling
local function PollCommand()
    local url = "http://localhost:3000/get_command"
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        local success, response = pcall(req, {Url = url, Method = "GET"})
        if success and response and response.StatusCode == 200 and response.Body and response.Body ~= "" then
            print("[AI Command Received]: Executing...")
            local func, err = loadstring(response.Body)
            if func then
                local execSuccess, result = pcall(func)
                if execSuccess then
                    if result then
                        SendToHost("==== AI RESULT ====\n" .. tostring(result) .. "\n===================")
                    end
                else
                    SendToHost("[AI ERROR - EXECUTION]: " .. tostring(result))
                end
            else
                SendToHost("[AI ERROR - PARSING]: " .. tostring(err))
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(PollCommand)
    end
end)

print("--- DEV SCANNER & AI BRIDGE READY ---")