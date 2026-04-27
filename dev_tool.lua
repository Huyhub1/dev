local ProxyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/Proxy.Lib/refs/heads/main/Libary/main.lua"))()
local lib = ProxyLib.new()

local window = lib:CreateWindow({
    Title = "Dev Scanner",
    Subtitle = "AI-Roblox Bridge",
    Theme = "Dark", -- "Dark" or "White"
    Icon = "rbxassetid://15124016666",
    Size = Vector2.new(520, 380),
    TitleConfig = {
        Words = { "Dev", "Scanner" },
        Gradient = true, 
        Colors = { Color3.fromRGB(55, 110, 200), Color3.fromRGB(170, 120, 255) },
    },
    FloatButton = {
        Shape = "Circle",
        Color = "White",
        Size = 50,
    },
    Acrylic = {
        Enabled = false,
        Opacity = 0.5,
    },
    ConfigPanel = {
        Enabled = true,
        Fps = true,
        Ping = true,
    },
})

local Tabs = {
    Tools = window:CreateTab({ Title = "Tools", Subtitle = "Scan & Collect", Icon = "rbxassetid://15124016666" }),
    AI = window:CreateTab({ Title = "AI Bridge", Subtitle = "Command Center", Icon = "rbxassetid://15124016666" })
}

-- Hàm gửi dữ liệu về Host (IP máy tính của bạn)
local function SendToHost(data)
    local url = "https://better-nights-beg.loca.lt/save"
    local HttpService = game:GetService("HttpService")
    local body = HttpService:JSONEncode({
        filename = "collected_data.txt",
        content = tostring(data),
        mode = "append"
    })
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        pcall(req, {
            Url = url, 
            Method = "POST", 
            Headers = {
                ["Content-Type"] = "application/json",
                ["Bypass-Tunnel-Reminder"] = "true"
            }, 
            Body = body
        })
    end
end

local function GetCharacter()
    local Player = game:GetService("Players").LocalPlayer
    return Player.Character or Player.CharacterAdded:Wait()
end

-- ====================
-- TAB TOOLS
-- ====================
Tabs.Tools:CreateSection({ Text = "Data Scanning" })

Tabs.Tools:CreateButton({
    Title = "📍 Scan CFrame",
    Description = "Gửi tọa độ nhân vật về Host",
    Callback = function()
        local char = GetCharacter()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local data = "[CFRAME]: CFrame.new(" .. tostring(root.Position) .. ")"
            SendToHost(data)
            window:Notify({Title="Success", Text="Sent CFrame to Host", Duration=3})
        end
    end,
})

Tabs.Tools:CreateButton({
    Title = "🖱️ Scan GUI (Click)",
    Description = "Bật chế độ click để lấy path GUI",
    Callback = function()
        window:Notify({Title="GUI Scanner", Text="Hãy click vào một GUI trên màn hình!", Duration=3})
        local UIS = game:GetService("UserInputService")
        local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local conn
        conn = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local guis = PlayerGui:GetGuiObjectsAtPosition(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
                if #guis > 0 then
                    local info = "[GUI CLICK DATA]:"
                    for i = 1, math.min(#guis, 15) do
                        local v = guis[i]
                        info = info .. "\n" .. i .. ". " .. v.Name .. " (" .. v.ClassName .. ") | Path: " .. v:GetFullName()
                    end
                    SendToHost(info)
                    window:Notify({Title="Success", Text="Sent GUI data", Duration=3})
                end
                conn:Disconnect()
            end
        end)
    end,
})

Tabs.Tools:CreateButton({
    Title = "📦 Scan Objects",
    Description = "Scan vật thể xung quanh (25 studs)",
    Callback = function()
        local char = GetCharacter()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local mapInfo = "[OBJECT SCAN NEARBY]:\n"
            for _, v in pairs(game:GetService("Workspace"):GetPartBoundsInRadius(root.Position, 25)) do
                if not v:IsDescendantOf(char) then
                    mapInfo = mapInfo .. "- " .. v.Name .. " | " .. v:GetFullName() .. "\n"
                end
            end
            SendToHost(mapInfo)
            window:Notify({Title="Success", Text="Sent Nearby Objects", Duration=3})
        end
    end,
})

Tabs.Tools:CreateButton({
    Title = "🗺️ Full Workspace Scan",
    Description = "Lấy danh sách Workspace Children",
    Callback = function()
        local mapInfo = "[WORKSPACE SCAN]:\n"
        for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
            if not game:GetService("Players"):GetPlayerFromCharacter(v) then
                 mapInfo = mapInfo .. "- " .. v.Name .. " [" .. v.ClassName .. "]\n"
            end
        end
        SendToHost(mapInfo)
        window:Notify({Title="Success", Text="Sent Full Scan", Duration=3})
    end,
})

-- ====================
-- TAB AI STATUS
-- ====================
Tabs.AI:CreateSection({ Text = "Bridge Status" })

local AIStatusPara = Tabs.AI:CreateParagraph({
    Title = "Bridge Connection",
    Description = "🟢 Waiting for AI command...",
    Icon = "rbxassetid://15124016666"
})

local function PollCommand()
    local url = "https://better-nights-beg.loca.lt/get_command"
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        local success, response = pcall(req, {
            Url = url, 
            Method = "GET",
            Headers = {["Bypass-Tunnel-Reminder"] = "true"}
        })
        if success and response then
            if response.StatusCode == 200 and response.Body and response.Body ~= "" then
                AIStatusPara:SetTitle("🟡 Executing Command...")
                AIStatusPara:SetDescription("Receiving: " .. string.sub(response.Body, 1, 30) .. "...")
                
                local func, err = loadstring(response.Body)
                if func then
                    local execSuccess, result = pcall(func)
                    if execSuccess then
                        SendToHost("==== AI RESULT ====\n" .. tostring(result) .. "\n===================")
                        AIStatusPara:SetTitle("✅ Success!")
                        AIStatusPara:SetDescription("Executed successfully at " .. os.date("%X"))
                    else
                        SendToHost("[AI ERROR - EXECUTION]: " .. tostring(result))
                        AIStatusPara:SetTitle("❌ Execution Error")
                        AIStatusPara:SetDescription(tostring(result))
                    end
                else
                    SendToHost("[AI ERROR - PARSING]: " .. tostring(err))
                    AIStatusPara:SetTitle("❌ Parsing Error")
                    AIStatusPara:SetDescription(tostring(err))
                end
                
                task.delay(3, function()
                    AIStatusPara:SetTitle("Bridge Connection")
                    AIStatusPara:SetDescription("🟢 Waiting for AI command...")
                end)
            end
        elseif not success then
            AIStatusPara:SetTitle("❌ Connection Failed")
            AIStatusPara:SetDescription("Cannot reach https://better-nights-beg.loca.lt")
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(PollCommand)
    end
end)

window:Notify({
    Title = "Proxy.Lib Initialized",
    Text = "AI Bridge is ready on 192.168.1.4",
    Duration = 5,
})