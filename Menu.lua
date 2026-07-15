--[[
    Script hoàn chỉnh cho Roblox Executor
    Giao diện Dark UI với 3 chức năng: Black Screen, Hide Original GUI, FPS Counter
    Tối ưu hiệu suất, Tween, Fade Animation, kéo thả mượt
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

-- Kiểm tra PlayerGui tồn tại
if not PlayerGui then
    PlayerGui = Instance.new("ScreenGui")
    PlayerGui.Name = "PlayerGui"
    PlayerGui.Parent = LocalPlayer
end

-- ===== Tạo ScreenGui chính =====
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "DarkMenuGUI"
mainGui.ResetOnSpawn = false
mainGui.Parent = CoreGui
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ===== Biến toàn cục =====
local dragInfo = { isDragging = false, dragInput = nil, dragStart = nil, startPos = nil }
local menuOpen = false
local blackScreenEnabled = false
local hideGUIEnabled = false
local fpsCounterEnabled = true  -- Luôn bật
local fpsCount = 0
local lastUpdate = tick()
local frameCount = 0
local rainbowHue = 0

-- ===== Tạo nút nổi "..." =====
local floatButton = Instance.new("ImageButton")
floatButton.Name = "FloatButton"
floatButton.Size = UDim2.new(0, 60, 0, 60)
floatButton.Position = UDim2.new(0.5, -30, 0.5, -30)
floatButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
floatButton.BackgroundTransparency = 0
floatButton.BorderSizePixel = 0
floatButton.ClipsDescendants = false
floatButton.Image = "rbxassetid://0"
floatButton.ImageRectOffset = Vector2.new(0, 0)
floatButton.ImageRectSize = Vector2.new(0, 0)
floatButton.AutoButtonColor = false
floatButton.ZIndex = 1000
floatButton.Parent = mainGui

-- Shadow cho nút nổi
local floatShadow = Instance.new("ImageLabel")
floatShadow.Name = "Shadow"
floatShadow.Size = UDim2.new(1, 12, 1, 12)
floatShadow.Position = UDim2.new(0, -6, 0, -6)
floatShadow.BackgroundTransparency = 1
floatShadow.Image = "rbxassetid://13156731979"
floatShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
floatShadow.ImageTransparency = 0.6
floatShadow.ScaleType = Enum.ScaleType.Slice
floatShadow.SliceCenter = Rect.new(8, 8, 8, 8)
floatShadow.ZIndex = 999
floatShadow.Parent = floatButton

-- Corner cho nút nổi
local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatButton

-- Label "..."
local dotLabel = Instance.new("TextLabel")
dotLabel.Name = "DotLabel"
dotLabel.Size = UDim2.new(1, 0, 1, 0)
dotLabel.Position = UDim2.new(0, 0, 0, 0)
dotLabel.BackgroundTransparency = 1
dotLabel.Text = "..."
dotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
dotLabel.TextSize = 30
dotLabel.TextScaled = true
dotLabel.Font = Enum.Font.GothamBold
dotLabel.TextWrapped = true
dotLabel.ZIndex = 1001
dotLabel.Parent = floatButton

-- ===== Tạo Menu chính =====
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 380, 0, 340)
menuFrame.Position = UDim2.new(0.5, -190, 0.5, -170)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
menuFrame.BackgroundTransparency = 1
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 500
menuFrame.Parent = mainGui

-- Shadow cho menu
local menuShadow = Instance.new("ImageLabel")
menuShadow.Name = "Shadow"
menuShadow.Size = UDim2.new(1, 24, 1, 24)
menuShadow.Position = UDim2.new(0, -12, 0, -12)
menuShadow.BackgroundTransparency = 1
menuShadow.Image = "rbxassetid://13156731979"
menuShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
menuShadow.ImageTransparency = 0.5
menuShadow.ScaleType = Enum.ScaleType.Slice
menuShadow.SliceCenter = Rect.new(8, 8, 8, 8)
menuShadow.ZIndex = 499
menuShadow.Parent = menuFrame

-- Corner menu
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame

-- Stroke menu
local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(60, 60, 70)
menuStroke.Thickness = 1
menuStroke.Transparency = 0.3
menuStroke.Parent = menuFrame

-- Tiêu đề menu
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DARK MENU"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.ZIndex = 501
titleLabel.Parent = menuFrame

-- Line chia
local lineDiv = Instance.new("Frame")
lineDiv.Name = "LineDiv"
lineDiv.Size = UDim2.new(0.9, 0, 0, 2)
lineDiv.Position = UDim2.new(0.05, 0, 0, 50)
lineDiv.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
lineDiv.BackgroundTransparency = 0.5
lineDiv.BorderSizePixel = 0
lineDiv.ZIndex = 501
lineDiv.Parent = menuFrame

-- ===== Hàm tạo toggle item =====
local function createToggleItem(parent, labelText, yPos, callback)
    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(1, -40, 0, 50)
    itemFrame.Position = UDim2.new(0, 20, 0, yPos)
    itemFrame.BackgroundTransparency = 1
    itemFrame.ZIndex = 501
    itemFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 502
    label.Parent = itemFrame

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 30)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleBtn.BackgroundTransparency = 0
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 502
    toggleBtn.Parent = itemFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local toggleCircle = Instance.new("ImageLabel")
    toggleCircle.Size = UDim2.new(0, 26, 0, 26)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -13)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BackgroundTransparency = 0
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 503
    toggleCircle.Parent = toggleBtn

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle

    local state = false

    local function updateToggle()
        local targetPos = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        local targetColor = state and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(40, 40, 50)

        TweenService:Create(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()

        TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        }):Play()
    end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if callback then callback(state) end
    end)

    return {
        setState = function(newState)
            state = newState
            updateToggle()
        end,
        getState = function()
            return state
        end
    }
end

-- ===== Tạo các toggle items =====
local blackScreenToggle = createToggleItem(menuFrame, "Black Screen", 70, function(state)
    blackScreenEnabled = state
    if blackScreenScreen then
        TweenService:Create(blackScreenScreen, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = state and 0 or 1
        }):Play()
    end
end)

local hideGUIToggle = createToggleItem(menuFrame, "Hide Original GUI", 135, function(state)
    hideGUIEnabled = state
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= mainGui and gui.Name ~= "RobloxGui" then
            gui.Enabled = not state
        end
    end
    if PlayerGui then
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui.Enabled = not state
            end
        end
    end
end)

-- FPS Counter (luôn bật, không có toggle)
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(1, -40, 0, 40)
fpsLabel.Position = UDim2.new(0, 20, 0, 200)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.TextSize = 18
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
fpsLabel.ZIndex = 501
fpsLabel.Parent = menuFrame

-- ===== Tạo Black Screen =====
local blackScreenScreen = Instance.new("ImageLabel")
blackScreenScreen.Name = "BlackScreen"
blackScreenScreen.Size = UDim2.new(1, 0, 1, 0)
blackScreenScreen.Position = UDim2.new(0, 0, 0, 0)
blackScreenScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackScreenScreen.BackgroundTransparency = 1
blackScreenScreen.BorderSizePixel = 0
blackScreenScreen.Image = ""
blackScreenScreen.ZIndex = 2000
blackScreenScreen.Parent = mainGui

-- ===== Hàm cập nhật FPS =====
local function updateFPS()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 0.5 then
        fpsCount = math.floor(frameCount / (now - lastUpdate))
        frameCount = 0
        lastUpdate = now

        -- Cập nhật màu sắc
        local color
        if fpsCount >= 1 and fpsCount <= 10 then
            color = Color3.fromRGB(255, 50, 50)  -- Đỏ
        elseif fpsCount > 10 and fpsCount <= 30 then
            color = Color3.fromRGB(255, 200, 50)  -- Vàng
        elseif fpsCount > 30 and fpsCount <= 500 then
            color = Color3.fromRGB(50, 255, 50)  -- Xanh lá
        elseif fpsCount > 500 then
            -- Hiệu ứng cầu vồng
            rainbowHue = (rainbowHue + 0.02) % 1
            color = Color3.fromHSV(rainbowHue, 1, 1)
        else
            color = Color3.fromRGB(200, 200, 200)
        end

        fpsLabel.Text = "FPS: " .. fpsCount
        fpsLabel.TextColor3 = color
    end
end

-- ===== Kéo thả nút nổi =====
local function setupDragging()
    local button = floatButton

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.Touch then
                dragInfo.isDragging = true
                dragInfo.dragStart = input.Position
                dragInfo.startPos = button.Position
            else
                dragInfo.isDragging = true
                dragInfo.dragStart = input.Position
                dragInfo.startPos = button.Position
            end
        end
    end

    local function onInputChanged(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragInfo.isDragging then
                local delta = input.Position - dragInfo.dragStart
                local newPos = UDim2.new(
                    dragInfo.startPos.X.Scale,
                    dragInfo.startPos.X.Offset + delta.X,
                    dragInfo.startPos.Y.Scale,
                    dragInfo.startPos.Y.Offset + delta.Y
                )
                -- Giới hạn trong màn hình
                newPos = UDim2.new(
                    math.clamp(newPos.X.Scale, 0, 1),
                    math.clamp(newPos.X.Offset, 0, 1),
                    math.clamp(newPos.Y.Scale, 0, 1),
                    math.clamp(newPos.Y.Offset, 0, 1)
                )
                button.Position = newPos
            end
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragInfo.isDragging = false
        end
    end

    button.InputBegan:Connect(onInputBegan)
    button.InputChanged:Connect(onInputChanged)
    button.InputEnded:Connect(onInputEnded)
end

setupDragging()

-- ===== Xử lý mở/đóng menu =====
floatButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen

    if menuOpen then
        menuFrame.Visible = true
        TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        }):Play()
    else
        TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        menuFrame.Visible = false
    end
end)

-- ===== Vòng lặp cập nhật FPS =====
RunService.Heartbeat:Connect(function()
    updateFPS()
end)

-- ===== Xử lý khi game bị thoát hoặc reset =====
local function cleanup()
    if mainGui then mainGui:Destroy() end
end

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == mainGui then
        cleanup()
    end
end)

-- ===== Khởi tạo hoàn tất =====
print("Dark Menu loaded successfully.")
