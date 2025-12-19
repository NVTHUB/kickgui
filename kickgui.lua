--[[ 
    GINGERBREAD MONITOR 2025 - PHIÊN BẢN SIÊU NHẸ (20s REFRESH)
    - Cập nhật GUI mỗi 20 giây (Tối ưu CPU tối đa).
    - Giữ nguyên: 3 dòng to bằng nhau, Chống mất GUI, Nút Ẩn/Hiện.
    - Logic 12 phút: Kick nếu số không đổi.
]]

task.wait(15)

local player = game.Players.LocalPlayer
local CURRENCY_NAME = "gingerbread_2025"
local CHECK_INTERVAL = 12 * 60
local UI_REFRESH_RATE = 60 -- 20 giây cập nhật một lần để siêu nhẹ CPU

local startTime = os.time()
local lastValue = -1
local displayDiff = 0 
local isVisible = true

-- TỐI ƯU: Require module một lần duy nhất
local ClientDataModule = require(game.ReplicatedStorage:WaitForChild("ClientModules"):WaitForChild("Core"):WaitForChild("ClientData"))

--------------------------------------------------
-- HỆ THỐNG GIAO DIỆN (BẤT TỬ)
--------------------------------------------------
local HopGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

if gethui then
    HopGui.Parent = gethui()
elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
    HopGui.Parent = game:GetService("CoreGui").RobloxGui
else
    HopGui.Parent = game:GetService("CoreGui")
end

HopGui.Name = "GingerSystem_UltraLite"
HopGui.IgnoreGuiInset = true
HopGui.DisplayOrder = 999999

MainFrame.Name = "MainFrame"
MainFrame.Parent = HopGui
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0

UIList.Parent = MainFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Center
UIList.Padding = UDim.new(0.01, 0)

local function createLabel(name)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Parent = MainFrame
    label.Size = UDim2.new(0.98, 0, 0.3, 0) 
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.FredokaOne
    label.TextColor3 = Color3.fromRGB(0, 255, 127)
    label.TextScaled = true
    label.RichText = true
    return label
end

local LTotal = createLabel("LTotal")
local LDiff  = createLabel("LDiff") 
local LTime  = createLabel("LTime")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = HopGui
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 1, -50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "HIDE GUI"
ToggleBtn.Font = Enum.Font.FredokaOne
ToggleBtn.ZIndex = 10
ToggleBtn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
end)

--------------------------------------------------
-- LOGIC DỮ LIỆU
--------------------------------------------------
local function GetValue()
    local success, data = pcall(function()
        return ClientDataModule.get_data()[player.Name]
    end)
    if success and data then
        return (data.inventory and data.inventory.currencies and data.inventory.currencies[CURRENCY_NAME]) or data[CURRENCY_NAME]
    end
    return nil
end

local function ApplyStyle(err)
    local bg = err and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 0)
    local txt = err and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(0, 255, 127)
    MainFrame.BackgroundColor3 = bg
    LTotal.TextColor3 = txt
    LDiff.TextColor3 = txt
    LTime.TextColor3 = txt
end

-- VÒNG LẶP CẬP NHẬT GUI (20 GIÂY/LẦN)
task.spawn(function()
    while true do
        -- 1. Thời gian
        local elapsed = os.time() - startTime
        LTime.Text = math.floor(elapsed / 3600) .. " : " .. math.floor((elapsed % 3600) / 60)
        
        -- 2. Số liệu
        local currentVal = GetValue()
        if currentVal then
            LTotal.Text = tostring(currentVal)
            LDiff.Text = (displayDiff > 0 and "+" or "") .. tostring(displayDiff)
        end
        task.wait(UI_REFRESH_RATE)
    end
end)

-- VÒNG LẶP KIỂM TRA KICK (12 PHÚT/LẦN)
task.spawn(function()
    repeat lastValue = GetValue() task.wait(2) until lastValue ~= nil
    
    while true do
        task.wait(CHECK_INTERVAL)
        local newVal = GetValue()
        
        if newVal ~= nil then
            if newVal == lastValue then
                ApplyStyle(true)
                task.wait(2)
                player:Kick("Gingerbread không đổi trong 12 phút!")
                return
            else
                displayDiff = newVal - lastValue
                lastValue = newVal
                ApplyStyle(false)
            end
        end
    end
end)
