--[[ 
    HỆ THỐNG GIÁM SÁT GINGERBREAD 2025 - PHIÊN BẢN CHỐNG MẤT GUI
    - Chờ 15 giây khởi động.
    - ResetOnSpawn = false (Giữ GUI khi chuyển map/reset).
    - Tự động tạo lại GUI nếu bị script khác xóa.
]]

task.wait(15)

local CURRENCY_NAME = "gingerbread_2025"
local CHECK_INTERVAL = 12 * 60 
local ClientData = require(game.ReplicatedStorage.ClientModules.Core.ClientData)
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local startTime = os.time()

local lastValue = -1
local isVisible = true
local isErrorState = false -- Lưu trạng thái màu sắc

--------------------------------------------------
-- HÀM TẠO GIAO DIỆN (ĐƯỢC GỌI LẠI NẾU MẤT)
--------------------------------------------------
local screenGui, mainFrame, labelTime, labelTotal, labelDiff, toggleBtn

local function CreateGUI()
    -- Xóa GUI cũ nếu còn tồn tại để tránh rác
    local old = PlayerGui:FindFirstChild("GingerbreadMonitor_Persistent")
    if old then old:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GingerbreadMonitor_Persistent"
    screenGui.IgnoreGuiInset = true 
    screenGui.DisplayOrder = 999999999 
    screenGui.ResetOnSpawn = false -- Cực kỳ quan trọng: Không xóa khi chuyển map
    screenGui.Parent = PlayerGui

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = isErrorState and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = isVisible
    mainFrame.Parent = screenGui

    local uiList = Instance.new("UIListLayout")
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiList.VerticalAlignment = Enum.VerticalAlignment.Center
    uiList.Parent = mainFrame

    -- Dòng 1: Thời gian
    labelTime = Instance.new("TextLabel")
    labelTime.Size = UDim2.new(1, 0, 0.2, 0)
    labelTime.BackgroundTransparency = 1
    labelTime.TextColor3 = isErrorState and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    labelTime.Font = Enum.Font.GothamBold
    labelTime.TextScaled = true
    labelTime.RichText = true
    labelTime.Parent = mainFrame

    -- Dòng 2: Tổng số
    labelTotal = Instance.new("TextLabel")
    labelTotal.Size = UDim2.new(1, 0, 0.4, 0)
    labelTotal.BackgroundTransparency = 1
    labelTotal.TextColor3 = isErrorState and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    labelTotal.Font = Enum.Font.GothamBold
    labelTotal.TextScaled = true
    labelTotal.RichText = true
    labelTotal.Text = "..."
    labelTotal.Parent = mainFrame

    -- Dòng 3: Chênh lệch
    labelDiff = Instance.new("TextLabel")
    labelDiff.Size = UDim2.new(1, 0, 0.2, 0)
    labelDiff.BackgroundTransparency = 1
    labelDiff.TextColor3 = isErrorState and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    labelDiff.Font = Enum.Font.GothamBold
    labelDiff.TextScaled = true
    labelDiff.RichText = true
    labelDiff.Text = "0"
    labelDiff.Parent = mainFrame

    -- Nút Tắt/Bật
    toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 45)
    toggleBtn.Position = UDim2.new(0.01, 0, 0.98, -50)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "ẨN / HIỆN"
    toggleBtn.Parent = screenGui

    toggleBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        mainFrame.Visible = isVisible
    end)
end

--------------------------------------------------
-- LOGIC CẬP NHẬT
--------------------------------------------------

local function updateColors(isError)
    isErrorState = isError
    if not mainFrame then return end
    local bgColor = isError and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
    local txtColor = isError and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    
    mainFrame.BackgroundColor3 = bgColor
    labelTime.TextColor3 = txtColor
    labelTotal.TextColor3 = txtColor
    labelDiff.TextColor3 = txtColor
end

local function updateDisplay()
    if not labelTime then return end
    -- Cập nhật đồng hồ
    local elapsed = os.time() - startTime
    labelTime.Text = "<b>" .. math.floor(elapsed / 3600) .. " : " .. math.floor((elapsed % 3600) / 60) .. "</b>"
end

local function performCheck()
    local data = ClientData.get_data()[player.Name]
    local currentValue = nil
    if data then
        currentValue = (data.inventory and data.inventory.currencies and data.inventory.currencies[CURRENCY_NAME]) or data[CURRENCY_NAME]
    end

    if currentValue ~= nil and labelTotal then
        labelTotal.Text = "<b>" .. currentValue .. "</b>"
        
        if lastValue ~= -1 then
            local diff = currentValue - lastValue
            labelDiff.Text = "<b>" .. (diff > 0 and "+" or "") .. diff .. "</b>"
            
            if diff == 0 then
                updateColors(true)
                task.wait(2)
                player:Kick("Gingerbread đứng im 12 phút.")
                return
            else
                updateColors(false)
            end
        end
        lastValue = currentValue
    end
end

--------------------------------------------------
-- VẬN HÀNH VÀ KIỂM TRA GUI LIÊN TỤC
--------------------------------------------------

CreateGUI()

-- Vòng lặp kiểm tra nếu GUI bị xóa thì tạo lại
task.spawn(function()
    while true do
        if not screenGui or not screenGui.Parent then
            CreateGUI()
        end
        updateDisplay()
        task.wait(1)
    end
end)

-- Vòng lặp check 12 phút
task.spawn(function()
    while true do
        performCheck()
        task.wait(CHECK_INTERVAL)
    end
end)
