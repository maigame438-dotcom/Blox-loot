-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BatterySaverGui"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = game.CoreGui -- Hoặc thay bằng game.Players.LocalPlayer:WaitForChild("PlayerGui") nếu game chặn CoreGui

-- Tạo nút tròn hình mặt trăng
local button = Instance.new("TextButton")
button.Name = "MoonButton"
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0, 10, 0.5, -25)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.Text = "🌙"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 25
button.ZIndex = 10 -- Đảm bảo nút luôn nằm trên
button.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = button

-- Tạo lớp phủ màu đen tối nhất (BackgroundTransparency = 0)
local blackFrame = Instance.new("Frame")
blackFrame.Name = "BlackOverlay"
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BackgroundTransparency = 0 -- Tối đen hoàn toàn
blackFrame.Visible = false
blackFrame.ZIndex = 5 -- Nằm dưới nút
blackFrame.Parent = screenGui

-- Logic Kéo thả (Di chuyển nút 360 độ)
local dragging, dragStart, startPos

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

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Logic Bật/Tắt màn hình (Chỉ kích hoạt nếu di chuyển rất ít)
button.MouseButton1Click:Connect(function()
    if not dragging then
        blackFrame.Visible = not blackFrame.Visible
    end
end)
