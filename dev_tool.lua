local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Dev Scanner (Host)",
    SubTitle = "AI-Roblox Bridge",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Tools = Window:AddTab({ Title = "Công cụ Scan", Icon = "wrench" }),
    AI = Window:AddTab({ Title = "AI Status", Icon = "bot" })
}

-- Hàm gửi dữ liệu về Host
local function SendToHost(data)
    local url = "http://localhost:3000/save"
    local HttpService = game:GetService("HttpService")
    local body = HttpService:JSONEncode({
        filename = "collected_data.txt",
        content = tostring(data),
        mode = "append"
    })
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        pcall(req, {Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body})
    end
end

local function GetCharacter()
    local Player = game:GetService("Players").LocalPlayer
    return Player.Character or Player.CharacterAdded:Wait()
end

-- ====================
-- TAB CÔNG CỤ
-- ====================
Tabs.Tools:AddButton({
    Title = "📍 Lấy Tọa Độ -> Host",
    Description = "Lấy CFrame của nhân vật",
    Callback = function()
        local char = GetCharacter()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local data = "[CFRAME]: CFrame.new(" .. tostring(root.Position) .. ")"
            print(data)
            SendToHost(data)
            Fluent:Notify({Title="Thành công", Content="Đã gửi Tọa độ", Duration=2})
        end
    end
})

Tabs.Tools:AddButton({
    Title = "🖱️ Lấy GUI Info -> Host",
    Description = "Click vào màn hình để lấy tên nút/khung",
    Callback = function()
        Fluent:Notify({Title="GUI Scanner", Content="Hãy click vào một GUI bất kỳ trên màn hình!", Duration=3})
        local UIS = game:GetService("UserInputService")
        local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
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
                    Fluent:Notify({Title="Thành công", Content="Đã gửi dữ liệu GUI", Duration=2})
                end
                conn:Disconnect()
            end
        end)
    end
})

Tabs.Tools:AddButton({
    Title = "📦 Lấy Vật Thể Gần -> Host",
    Description = "Scan các part trong bán kính 25 stud",
    Callback = function()
        local char = GetCharacter()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, v in pairs(game:GetService("Workspace"):GetPartBoundsInRadius(root.Position, 25)) do
                if not v:IsDescendantOf(char) then
                    local info = "[OBJECT]: Name='" .. v.Name .. "' Path='" .. v:GetFullName() .. "'"
                    print("\n" .. info)
                    SendToHost(info)
                    Fluent:Notify({Title="Thành công", Content="Đã gửi Vật thể: " .. v.Name, Duration=2})
                    break
                end
            end
        end
    end
})

Tabs.Tools:AddButton({
    Title = "🗺️ Check Map -> Host",
    Description = "Lấy danh sách các thư mục lớn trong Workspace",
    Callback = function()
        local mapInfo = "[MAP SCAN]:\n"
        for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
            if not (v:IsA("Camera") or v:IsA("Terrain") or v.Name == "Baseplate" or v.Name == "Camera") and not game:GetService("Players"):GetPlayerFromCharacter(v) then
                 mapInfo = mapInfo .. "- " .. v.Name .. " [" .. v.ClassName .. "]\n"
            end
        end
        print("\n" .. mapInfo)
        SendToHost(mapInfo)
        Fluent:Notify({Title="Thành công", Content="Đã gửi Map Info", Duration=2})
    end
})

Tabs.Tools:AddButton({
    Title = "🗑️ Xóa Console",
    Description = "Dọn sạch F9 (Developer Console)",
    Callback = function()
        for i = 1, 50 do print(" ") end
    end
})

-- ====================
-- TAB AI STATUS
-- ====================
local AIStatusPara = Tabs.AI:AddParagraph({
    Title = "Kết nối Cầu nối AI-Roblox",
    Content = "🟢 Đang chờ lệnh từ AI..."
})

local function PollCommand()
    local url = "http://localhost:3000/get_command"
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        local success, response = pcall(req, {Url = url, Method = "GET"})
        if success and response and response.StatusCode == 200 and response.Body and response.Body ~= "" then
            AIStatusPara:SetDesc("🟡 Đang thực thi lệnh...\n" .. string.sub(response.Body, 1, 40) .. "...")
            print("[AI Command Received]: Executing...")
            
            local func, err = loadstring(response.Body)
            if func then
                local execSuccess, result = pcall(func)
                if execSuccess then
                    SendToHost("==== AI RESULT ====\n" .. tostring(result) .. "\n===================")
                    AIStatusPara:SetDesc("✅ Lệnh thực thi thành công!")
                else
                    SendToHost("[AI ERROR - EXECUTION]: " .. tostring(result))
                    AIStatusPara:SetDesc("❌ Lỗi thực thi:\n" .. tostring(result))
                end
            else
                SendToHost("[AI ERROR - PARSING]: " .. tostring(err))
                AIStatusPara:SetDesc("❌ Lỗi phân tích cú pháp:\n" .. tostring(err))
            end
            
            task.delay(2.5, function()
                AIStatusPara:SetDesc("🟢 Đang chờ lệnh từ AI...")
            end)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(PollCommand)
    end
end)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Bridge Ready",
    Content = "AI-Roblox Bridge đã sẵn sàng!\nNhấn RightControl để ẩn menu.",
    Duration = 5
})