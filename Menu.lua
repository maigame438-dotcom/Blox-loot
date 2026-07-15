-- =====================================================
-- [Roblox Executor Script] Dark UI + Black Screen + Hide GUI + FPS Counter
-- Tối ưu, không lag, dành cho Mobile & PC
-- =====================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernMenuGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function createTween(object, properties, duration, style)
    style = style or Enum.EasingStyle.Quad
    local tweenInfo = TweenInfo.new(duration, style, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

-- =====================================================
-- 1. NÚT NỔI "..." (Floating Button)
-- =====================================================
local function createFloatingButton()
    local button = Instance.new("ImageButton")
    button.Name = "FloatingButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(0.5, -30, 0.5, -30)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    button.BackgroundTransparency = 0.9
    button.BorderSizePixel = 0
    button.Image = "rbxassetid://3570695787" -- transparent placeholder
    button.ImageTransparency = 1
    button.Parent = ScreenGui

    -- Bo góc hoàn hảo
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    -- Shadow (đổ bóng)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316046221" -- drop shadow
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Parent = button

    -- Label "..." với Font hiện đại
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "..."
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 28
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.Parent = button

    -- Tween hover
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundTransparency = 0.7}, 0.2):Play()
    end)
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundTransparency = 0.9}, 0.2):Play()
    end)

    return button
end

local floatingBtn = createFloatingButton()
local menuVisible = false

-- =====================================================
-- 2. MENU CHÍNH (Dark UI - Modern)
-- =====================================================
local function createMenu()
    local menu = Instance.new("ImageLabel")
    menu.Name = "MainMenu"
    menu.Size = UDim2.new(0, 340, 0, 480)
    menu.Position = UDim2.new(0.5, -170, 0.5, -240)
    menu.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    menu.BackgroundTransparency = 0.08
    menu.Image = "rbxassetid://1316046221"
    menu.ImageTransparency = 0.85
    menu.ScaleType = Enum.ScaleType.Slice
    menu.SliceCenter = Rect.new(10, 10, 10, 10)
    menu.Visible = false
    menu.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = menu

    -- Shadow cho menu
    local shadowMenu = Instance.new("ImageLabel")
    shadowMenu.Name = "Shadow"
    shadowMenu.Size = UDim2.new(1, 30, 1, 30)
    shadowMenu.Position = UDim2.new(0, -15, 0, -15)
    shadowMenu.BackgroundTransparency = 1
    shadowMenu.Image = "rbxassetid://1316046221"
    shadowMenu.ImageTransparency = 0.5
    shadowMenu.ScaleType = Enum.ScaleType.Slice
    shadowMenu.SliceCenter = Rect.new(10, 10, 10, 10)
    shadowMenu.Parent = menu

    -- Tiêu đề
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "MENU"
    title.TextColor3 = Color3.fromRGB(220, 220, 230)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = menu

    -- Dòng kẻ
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.9, 0, 0, 1)
    line.Position = UDim2.new(0.05, 0, 0, 70)
    line.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    line.BorderSizePixel = 0
    line.Parent = menu

    -- =============================================
    -- CHỨC NĂNG 1: BLACK SCREEN
    -- =============================================
    local blackScreen = Instance.new("Frame")
    blackScreen.Name = "BlackScreenOverlay"
    blackScreen.Size = UDim2.new(1, 0, 1, 0)
    blackScreen.Position = UDim2.new(0, 0, 0, 0)
    blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackScreen.BackgroundTransparency = 1
    blackScreen.BorderSizePixel = 0
    blackScreen.ZIndex = 999
    blackScreen.Parent = ScreenGui
    blackScreen.Visible = false

    local blackToggle = false
    local function toggleBlackScreen()
        blackToggle = not blackToggle
        blackScreen.Visible = true
        local target = blackToggle and 0 or 1
        createTween(blackScreen, {BackgroundTransparency = target}, 0.5):Play()
        if not blackToggle then
            task.wait(0.5)
            blackScreen.Visible = false
        end
    end

    -- Nút Black Screen
    local btnBlack = createToggleButton(menu, "Black Screen", 90, function()
        toggleBlackScreen()
    end)

    -- =============================================
    -- CHỨC NĂNG 2: HIDE ORIGINAL GUI
    -- =============================================
    local hiddenGUIs = {}
    local hideToggle = false
    local function toggleHideGUI()
        hideToggle = not hideToggle
        if hideToggle then
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "ModernMenuGUI" then
                    table.insert(hiddenGUIs, gui)
                    gui.Enabled = false
                end
            end
        else
            for _, gui in ipairs(hiddenGUIs) do
                pcall(function() gui.Enabled = true end)
            end
            table.clear(hiddenGUIs)
        end
    end

    local btnHide = createToggleButton(menu, "Hide Original GUI", 170, function()
        toggleHideGUI()
    end)

    -- =============================================
    -- CHỨC NĂNG 3: FPS COUNTER
    -- =============================================
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0, 100, 0, 40)
    fpsLabel.Position = UDim2.new(0.5, -50, 0, 250)
    fpsLabel.BackgroundTransparency = 0.2
    fpsLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fpsLabel.TextSize = 18
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextScaled = true
    fpsLabel.Parent = menu

    local fpsCorner = Instance.new("UICorner")
    fpsCorner.CornerRadius = UDim.new(0, 8)
    fpsCorner.Parent = fpsLabel

    local fpsToggle = false
    local frameCount = 0
    local lastTime = tick()
    local currentFPS = 0

    local function updateFPS()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 0.5 then
            currentFPS = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now

            local color
            if currentFPS >= 1 and currentFPS <= 10 then
                color = Color3.fromRGB(255, 50, 50)   -- Đỏ
            elseif currentFPS > 10 and currentFPS <= 30 then
                color = Color3.fromRGB(255, 200, 50)  -- Vàng
            elseif currentFPS > 30 and currentFPS <= 500 then
                color = Color3.fromRGB(50, 255, 50)   -- Xanh lá
            elseif currentFPS > 500 then
                -- Cầu vồng 7 màu (HSV xoay)
                local hue = (tick() * 0.15) % 1
                color = Color3.fromHSV(hue, 1, 1)
            else
                color = Color3.fromRGB(150, 150, 150)
            end
            fpsLabel.TextColor3 = color
            fpsLabel.Text = "FPS: " .. currentFPS
        end
    end

    local fpsConnection
    local function toggleFPS()
        fpsToggle = not fpsToggle
        if fpsToggle then
            fpsLabel.Visible = true
            fpsConnection = RunService.Heartbeat:Connect(updateFPS)
        else
            fpsLabel.Visible = false
            if fpsConnection then
                fpsConnection:Disconnect()
                fpsConnection = nil
            end
        end
    end

    local btnFPS = createToggleButton(menu, "FPS Counter", 250, function()
        toggleFPS()
    end)

    -- Nút đóng menu (X)
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -44, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.Image = "rbxassetid://169625476" -- X icon
    closeBtn.ImageColor3 = Color3.fromRGB(200, 200, 210)
    closeBtn.Parent = menu

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        toggleMenu()
    end)

    return menu, fpsLabel
end

-- =====================================================
-- HÀM TẠO NÚT TOGGLE (UI hiện đại)
-- =====================================================
function createToggleButton(parent, text, yPos, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 44)
    container.Position = UDim2.new(0.05, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    btn.BackgroundTransparency = 0.2
    btn.Image = "rbxassetid://1316046221"
    btn.ImageTransparency = 0.9
    btn.ScaleType = Enum.ScaleType.Slice
    btn.SliceCenter = Rect.new(10, 10, 10, 10)
    btn.Parent = container

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 10)
    cornerBtn.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextSize = 16
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 42, 0, 24)
    toggleIndicator.Position = UDim2.new(1, -52, 0.5, -12)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = toggleIndicator

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.Position = UDim2.new(0, 2, 0.5, -10)
    dot.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    dot.BorderSizePixel = 0
    dot.Parent = toggleIndicator

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(0, 20, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetColor = state and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(50, 50, 60)
        createTween(dot, {Position = targetPos}, 0.2):Play()
        createTween(toggleIndicator, {BackgroundColor3 = targetColor}, 0.2):Play()
        if callback then callback() end
    end)

    return btn
end

-- =====================================================
-- ĐIỀU KHIỂN MENU (MỞ/ĐÓNG + KÉO THẢ)
-- =====================================================
local menu, fpsLabel = createMenu()

local function toggleMenu()
    menuVisible = not menuVisible
    if menuVisible then
        menu.Visible = true
        menu.BackgroundTransparency = 0.08
        createTween(menu, {BackgroundTransparency = 0.06}, 0.3):Play()
        -- Fade in
        menu.ImageTransparency = 0.85
        createTween(menu, {ImageTransparency = 0.7}, 0.3):Play()
    else
        createTween(menu, {BackgroundTransparency = 0.3}, 0.2):Play()
        createTween(menu, {ImageTransparency = 1}, 0.2):Play()
        task.wait(0.25)
        menu.Visible = false
    end
end

floatingBtn.MouseButton1Click:Connect(toggleMenu)

-- =====================================================
-- KÉO THẢ NÚT NỔI (Mobile & PC)
-- =====================================================
local dragging = false
local dragStart, buttonStart

floatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        buttonStart = floatingBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newX = buttonStart.X.Offset + delta.X
        local newY = buttonStart.Y.Offset + delta.Y
        -- Giới hạn trong màn hình
        local maxX = 1 - floatingBtn.Size.X.Scale
        local maxY = 1 - floatingBtn.Size.Y.Scale
        newX = math.clamp(newX / ScreenGui.AbsoluteSize.X, 0, maxX)
        newY = math.clamp(newY / ScreenGui.AbsoluteSize.Y, 0, maxY)
        floatingBtn.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- =====================================================
-- KHỞI TẠO: FPS mặc định TẮT, menu ẩn
-- =====================================================
menu.Visible = false
fpsLabel.Visible = false

-- Giữ ScreenGui không bị xóa khi game tải lại
ScreenGui.ResetOnSpawn = false

-- =====================================================
-- DỌN DẸP KHI NGƯỜI CHƠI THOÁT
-- =====================================================
Player.PlayerRemoving:Connect(function()
    if fpsConnection then fpsConnection:Disconnect() end
    ScreenGui:Destroy()
end)heo trạng thái
    if state.menuVisible then
        toggleBtn.Image = "rbxassetid://3926305904" -- bánh răng
    else
        toggleBtn.Image = "rbxassetid://6031091554" -- icon menu (ba gạch)
    end
end)

-- Cập nhật thông tin FPS realtime
spawn(function()
    while screenGui and screenGui.Parent do
        wait(0.5)
        local infoLabel = menuFrame and menuFrame:FindFirstChildOfClass("TextLabel")
        if infoLabel and infoLabel.Text:find("FPS:") then
            infoLabel.Text = "FPS: " .. state.fps .. "\nDev: @2024nam8\nVer: 1.1.0\nYear: 2024"
        end
    end
end)
