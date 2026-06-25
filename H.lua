-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BatterySaverGui"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = game.CoreGui

-- Tạo nút tròn
local button = Instance.new("TextButton")
button.Name = "MoonButton"
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0, 10, 0.5, -25)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.Text = "🌙"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 25
button.ZIndex = 10
button.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = button

-- Tạo lớp phủ đen
local blackFrame = Instance.new("Frame")
blackFrame.Name = "BlackOverlay"
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BackgroundTransparency = 0
blackFrame.Visible = false
blackFrame.ZIndex = 5
blackFrame.Parent = screenGui

-- Logic Kéo thả cải tiến
local dragging = false
local dragStart
local startPos
local wasDragged = false -- Biến kiểm tra xem có phải đang kéo hay không

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        wasDragged = false
        dragStart = input.Position
        startPos = button.Position
    end
end)

button.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        -- Nếu di chuyển chuột/tay quá 5 đơn vị thì mới tính là đang kéo (tránh hiểu nhầm khi nhấn)
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            wasDragged = true
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        -- Nếu không phải đang kéo, thì thực hiện hành động Bật/Tắt
        if not wasDragged then
            blackFrame.Visible = not blackFrame.Visible
        end
    end
end)
