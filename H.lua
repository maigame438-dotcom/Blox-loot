-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BatterySaverGui"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999 -- Đảm bảo luôn nằm trên cùng
screenGui.Parent = game.CoreGui

-- Tạo nút tròn hình mặt trăng
local button = Instance.new("TextButton")
button.Name = "MoonButton"
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0, 10, 0.5, -25)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.Text = "🌙"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 25
button.AutoButtonColor = true
button.Parent = screenGui

-- Bo tròn nút
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = button

-- Tạo lớp phủ màu đen (Black Screen)
local blackFrame = Instance.new("Frame")
blackFrame.Name = "BlackOverlay"
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BackgroundTransparency = 1 -- Độ đen (0.2 = rất tối)
blackFrame.Visible = false
blackFrame.Parent = screenGui

-- Xử lý sự kiện nhấn nút
local isBlack = false
button.MouseButton1Click:Connect(function()
    isBlack = not isBlack
    blackFrame.Visible = isBlack
    
    if isBlack then
        button.BackgroundTransparency = 0.5
        button.TextTransparency = 0.5
    else
        button.BackgroundTransparency = 0
        button.TextTransparency = 0
    end
end)

-- Đảm bảo nút luôn nằm trên lớp phủ
button.ZIndex = 10
blackFrame.ZIndex = 1
