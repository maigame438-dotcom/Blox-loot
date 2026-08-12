-- ============================================================
-- AUTO CLICKER PRO MOBILE V2.0 - FULL CHỨC NĂNG
-- Dành riêng cho Roblox Mobile
-- ============================================================

-- ================================
-- XÓA GUI CŨ
-- ================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local existingGui = player.PlayerGui:FindFirstChild("AutoClickerGUI")
if existingGui then existingGui:Destroy() end

-- ================================
-- BIẾN TOÀN CỤC
-- ================================
local isAutoClickOn = false
local isRunning = false
local currentCPS = 10
local currentTool = nil
local clickCount = 0
local clickPosition = nil  -- {X, Y}
local isPositionSet = false
local targetMode = "SINGLE"  -- "SINGLE" hoặc "MULTI"
local menuOpen = true
local loopThread = nil
local isSettingPosition = false
local isMenuVisible = true

-- ================================
-- HÀM TIỆN ÍCH
-- ================================
local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function getCurrentTool()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildWhichIsA("Tool")
end

local function updateToolDisplay()
    local tool = getCurrentTool()
    currentTool = tool
    if toolLabel then
        toolLabel.Text = "⚔ " .. (tool and tool.Name or "None")
    end
end

-- ================================
-- AUTO CLICK LOOP
-- ================================
local function autoClickLoop()
    while isRunning do
        if isAutoClickOn then
            local tool = getCurrentTool()
            if tool then
                pcall(function()
                    tool:Activate()
                    clickCount = clickCount + 1
                    if clickCountLabel then
                        clickCountLabel.Text = tostring(clickCount)
                    end
                end)
            else
                -- Không có tool, vẫn chạy nhưng không click
                if statusLabel then
                    statusLabel.Text = "● WAITING FOR TOOL"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                end
            end
            local delay = 1 / currentCPS
            task.wait(delay)
        else
            task.wait(0.1)
        end
    end
end

-- ================================
-- BẬT/TẮT AUTO CLICK
-- ================================
local function startAutoClick()
    if isRunning then return end
    isRunning = true
    isAutoClickOn = true
    if loopThread then
        task.cancel(loopThread)
        loopThread = nil
    end
    loopThread = task.spawn(autoClickLoop)
    updateUI()
end

local function stopAutoClick()
    isRunning = false
    isAutoClickOn = false
    if loopThread then
        task.cancel(loopThread)
        loopThread = nil
    end
    updateUI()
end

local function toggleAutoClick()
    if isAutoClickOn then
        stopAutoClick()
    else
        startAutoClick()
    end
end

-- ================================
-- CẬP NHẬT UI
-- ================================
local function updateUI()
    if statusLabel then
        if isRunning and isAutoClickOn then
            statusLabel.Text = "● RUNNING"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "● STOPPED"
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    if toggleBtn then
        toggleBtn.Text = isAutoClickOn and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = isAutoClickOn and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 100)
    end
    if actionBtn then
        actionBtn.Text = isRunning and "■ STOP AUTO CLICK" or "▶ START AUTO CLICK"
        actionBtn.BackgroundColor3 = isRunning and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 180, 80)
    end
    if cpsDisplay then
        cpsDisplay.Text = "CPS: " .. currentCPS
    end
    if toolLabel then
        updateToolDisplay()
    end
    if clickCountLabel then
        clickCountLabel.Text = tostring(clickCount)
    end
    if posLabel then
        if isPositionSet and clickPosition then
            posLabel.Text = "X: " .. math.floor(clickPosition.X) .. " Y: " .. math.floor(clickPosition.Y)
        else
            posLabel.Text = "Not set"
        end
    end
    -- Target mode highlight
    if singleBtn and multiBtn then
        if targetMode == "SINGLE" then
            singleBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            multiBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            singleBtn.TextColor3 = Color3.fromRGB(255,255,255)
            multiBtn.TextColor3 = Color3.fromRGB(200,200,200)
        else
            multiBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            singleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            multiBtn.TextColor3 = Color3.fromRGB(255,255,255)
            singleBtn.TextColor3 = Color3.fromRGB(200,200,200)
        end
    end
end

-- ================================
-- XỬ LÝ ĐÓNG/MỞ MENU
-- ================================
local function hideMenu()
    isMenuVisible = false
    menuOpen = false
    if mainFrame then mainFrame.Visible = false end
    if floatBtn then floatBtn.Visible = true end
end

local function showMenu()
    isMenuVisible = true
    menuOpen = true
    if mainFrame then mainFrame.Visible = true end
    if floatBtn then floatBtn.Visible = false end
    updateUI()
end

-- ================================
-- TẠO GIAO DIỆN
-- ================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Dùng UIScale để tự co giãn
local mainScale = Instance.new("UIScale")
mainScale.Scale = 0.8  -- Tỷ lệ thu nhỏ cho mobile

-- ---- FRAME CHÍNH ----
local mainFrame = create("Frame", {
    Size = UDim2.new(0, 340, 0, 460),
    Position = UDim2.new(0.5, -170, 0.5, -230),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(80, 120, 200),
    Active = true,
    Draggable = true,
    Visible = true,
    Parent = screenGui
})
mainScale.Parent = mainFrame
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainFrame})
create("UIStroke", {Color = Color3.fromRGB(80, 120, 200), Thickness = 1, Parent = mainFrame})

-- ---- HEADER ----
local titleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(30, 30, 50),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = titleBar})

local titleLabel = create("TextLabel", {
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0.05, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "AUTO CLICKER",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = titleBar
})

-- Nút thu nhỏ
local minBtn = create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "−",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = titleBar
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = minBtn})

-- Nút đóng
local closeBtn = create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(200, 40, 40),
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = titleBar
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = closeBtn})

-- ---- NỘI DUNG ----
local content = create("Frame", {
    Size = UDim2.new(1, -20, 1, -50),
    Position = UDim2.new(0, 10, 0, 45),
    BackgroundTransparency = 1,
    Parent = mainFrame
})

-- STATUS
local statusLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "● STOPPED",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

-- AUTO CLICK TOGGLE
local toggleFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 28),
    BackgroundTransparency = 1,
    Parent = content
})
local toggleLabel = create("TextLabel", {
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "AUTO CLICK",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = toggleFrame
})
local toggleBtn = create("TextButton", {
    Size = UDim2.new(0, 80, 0, 26),
    Position = UDim2.new(0.7, 0, 0.5, -13),
    BackgroundColor3 = Color3.fromRGB(80, 80, 100),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = toggleFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleBtn})

-- CLICK SPEED
local speedLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 64),
    BackgroundTransparency = 1,
    Text = "CLICK SPEED",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})
local cpsDisplay = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 88),
    BackgroundTransparency = 1,
    Text = "CPS: 10",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = content
})

-- Slider + buttons
local sliderFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 114),
    BackgroundTransparency = 1,
    Parent = content
})
local minusCPS = create("TextButton", {
    Size = UDim2.new(0, 30, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "−",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = sliderFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minusCPS})
local sliderTrack = create("Frame", {
    Size = UDim2.new(0.6, 0, 0.4, 0),
    Position = UDim2.new(0.2, 0, 0.3, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    BorderSizePixel = 0,
    Parent = sliderFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = sliderTrack})
local sliderThumb = create("TextButton", {
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new((currentCPS-1)/19, -9, 0.5, -9),
    BackgroundColor3 = Color3.fromRGB(100, 180, 255),
    BorderSizePixel = 0,
    Text = "",
    Parent = sliderTrack
})
create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = sliderThumb})
local plusCPS = create("TextButton", {
    Size = UDim2.new(0, 30, 1, 0),
    Position = UDim2.new(1, -30, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "+",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = sliderFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = plusCPS})

-- TARGET MODE
local targetLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 148),
    BackgroundTransparency = 1,
    Text = "TARGET MODE",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})
local targetFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 172),
    BackgroundTransparency = 1,
    Parent = content
})
local singleBtn = create("TextButton", {
    Size = UDim2.new(0.4, 0, 1, 0),
    Position = UDim2.new(0.05, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(100, 180, 255),
    Text = "SINGLE",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = targetFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = singleBtn})
local multiBtn = create("TextButton", {
    Size = UDim2.new(0.4, 0, 1, 0),
    Position = UDim2.new(0.55, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "MULTI",
    TextColor3 = Color3.fromRGB(200,200,200),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = targetFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = multiBtn})

-- CURRENT TOOL
local toolTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 208),
    BackgroundTransparency = 1,
    Text = "CURRENT TOOL",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})
local toolLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 230),
    BackgroundTransparency = 1,
    Text = "⚔ None",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = content
})

-- CLICK POSITION
local posTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 256),
    BackgroundTransparency = 1,
    Text = "CLICK POSITION",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})
local posFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 278),
    BackgroundTransparency = 1,
    Parent = content
})
local setPosBtn = create("TextButton", {
    Size = UDim2.new(0.4, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 100),
    Text = "SET POSITION",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = posFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = setPosBtn})
local testClickBtn = create("TextButton", {
    Size = UDim2.new(0.4, 0, 1, 0),
    Position = UDim2.new(0.55, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 100),
    Text = "TEST CLICK",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = posFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = testClickBtn})
local posLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 312),
    BackgroundTransparency = 1,
    Text = "Not set",
    TextColor3 = Color3.fromRGB(150, 150, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

-- CLICKS
local clickTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 334),
    BackgroundTransparency = 1,
    Text = "CLICKS",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})
local clickCountLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 354),
    BackgroundTransparency = 1,
    Text = "0",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = content
})

-- ACTION BUTTON
local actionBtn = create("TextButton", {
    Size = UDim2.new(0.8, 0, 0, 36),
    Position = UDim2.new(0.1, 0, 0, 382),
    BackgroundColor3 = Color3.fromRGB(0, 180, 80),
    Text = "▶ START AUTO CLICK",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = actionBtn})

-- ---- NÚT NỔI AC ----
local floatBtn = create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(1, -65, 0.5, -25),
    BackgroundColor3 = Color3.fromRGB(30, 30, 50),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 2,
    BorderColor3 = Color3.fromRGB(80, 120, 200),
    Text = "AC",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Visible = false,
    Parent = screenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 25), Parent = floatBtn})

-- ================================
-- XỬ LÝ KÉO THẢ (TOUCH)
-- ================================
local dragData = {dragging = false, object = nil, startPos = nil, offset = nil}

local function startDrag(obj, input)
    if not obj then return end
    dragData.dragging = true
    dragData.object = obj
    local pos = obj.Position
    local absPos = obj.AbsolutePosition
    dragData.offset = Vector2.new(input.Position.X - absPos.X, input.Position.Y - absPos.Y)
end

local function updateDrag(input)
    if not dragData.dragging or not dragData.object then return end
    local newX = input.Position.X - dragData.offset.X
    local newY = input.Position.Y - dragData.offset.Y
    local maxX = workspace.CurrentCamera.ViewportSize.X - dragData.object.AbsoluteSize.X
    local maxY = workspace.CurrentCamera.ViewportSize.Y - dragData.object.AbsoluteSize.Y
    newX = math.clamp(newX, 0, maxX)
    newY = math.clamp(newY, 0, maxY)
    dragData.object.Position = UDim2.new(0, newX, 0, newY)
end

local function endDrag()
    dragData.dragging = false
    dragData.object = nil
end

-- Gắn sự kiện kéo cho title bar
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        startDrag(mainFrame, input)
    end
end)
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        startDrag(floatBtn, input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        endDrag()
    end
end)

-- ================================
-- XỬ LÝ SLIDER CPS (TOUCH)
-- ================================
local sliderDragging = false
sliderThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.Touch then
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackSize = sliderTrack.AbsoluteSize.X
        local touchX = input.Position.X
        local percent = math.clamp((touchX - trackPos) / trackSize, 0, 1)
        local newCPS = math.floor(1 + percent * 19)
        newCPS = math.clamp(newCPS, 1, 20)
        if newCPS ~= currentCPS then
            currentCPS = newCPS
            sliderThumb.Position = UDim2.new((currentCPS-1)/19, -9, 0.5, -9)
            updateUI()
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- Nút + và -
minusCPS.MouseButton1Click:Connect(function()
    currentCPS = math.max(1, currentCPS - 1)
    sliderThumb.Position = UDim2.new((currentCPS-1)/19, -9, 0.5, -9)
    updateUI()
end)
plusCPS.MouseButton1Click:Connect(function()
    currentCPS = math.min(20, currentCPS + 1)
    sliderThumb.Position = UDim2.new((currentCPS-1)/19, -9, 0.5, -9)
    updateUI()
end)

-- ================================
-- XỬ LÝ SỰ KIỆN NÚT
-- ================================
closeBtn.MouseButton1Click:Connect(hideMenu)
minBtn.MouseButton1Click:Connect(hideMenu)
floatBtn.MouseButton1Click:Connect(showMenu)

toggleBtn.MouseButton1Click:Connect(function()
    toggleAutoClick()
end)

actionBtn.MouseButton1Click:Connect(function()
    if isRunning then
        stopAutoClick()
    else
        startAutoClick()
    end
end)

singleBtn.MouseButton1Click:Connect(function()
    targetMode = "SINGLE"
    updateUI()
end)
multiBtn.MouseButton1Click:Connect(function()
    targetMode = "MULTI"
    updateUI()
end)

-- SET POSITION
setPosBtn.MouseButton1Click:Connect(function()
    if isSettingPosition then return end
    isSettingPosition = true
    -- Tạo vòng tròn để người dùng chạm
    local circle = create("Frame", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0.5, -20, 0.5, -20),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        Visible = true,
        Parent = screenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = circle})
    local instLabel = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "Tap anywhere",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        Parent = circle
    })
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            clickPosition = {X = pos.X, Y = pos.Y}
            isPositionSet = true
            circle:Destroy()
            connection:Disconnect()
            isSettingPosition = false
            updateUI()
            -- Hiển thị thông báo
            local note = create("TextLabel", {
                Size = UDim2.new(0, 200, 0, 30),
                Position = UDim2.new(0.5, -100, 0.5, -15),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.5,
                Text = "Position saved!",
                TextColor3 = Color3.fromRGB(0, 255, 0),
                TextScaled = true,
                Font = Enum.Font.GothamBold,
                Parent = screenGui
            })
            create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = note})
            task.delay(1, function()
                note:Destroy()
            end)
        end
    end)
end)

-- TEST CLICK (chỉ hiển thị vị trí, không thực sự click)
testClickBtn.MouseButton1Click:Connect(function()
    if not isPositionSet or not clickPosition then
        print("Chưa set vị trí!")
        return
    end
    -- Hiển thị vòng tròn xanh tại vị trí đã set để xác nhận
    local marker = create("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, clickPosition.X - 15, 0, clickPosition.Y - 15),
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        Visible = true,
        Parent = screenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = marker})
    task.delay(1, function()
        marker:Destroy()
    end)
end)

-- ================================
-- CẬP NHẬT TOOL KHI THAY ĐỔI
-- ================================
local function onCharacterAdded(char)
    updateToolDisplay()
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            updateToolDisplay()
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == currentTool then
            currentTool = nil
            updateToolDisplay()
        end
    end)
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

player.CharacterAdded:Connect(function()
    task.wait(0.2)
    updateToolDisplay()
    updateUI()
end)

-- ================================
-- KHỞI TẠO UI
-- ================================
updateUI()

-- ================================
-- THÔNG BÁO
-- ================================
print("===== AUTO CLICKER PRO MOBILE V2.0 =====")
print("✅ Đã sẵn sàng.")
print("📌 Lưu ý: Trên Roblox Mobile, không thể giả lập touch vào vị trí cụ thể.")
print("   Auto Click sử dụng Tool:Activate() để kích hoạt vũ khí.")
print("   'Set Position' và 'Test Click' chỉ để hiển thị vị trí.")
print("🔘 Nút AC để mở/đóng menu.")
print("=========================================")

-- ================================
-- GIỚI HẠN ROBLOX (THÔNG TIN)
-- ================================
--[[
    Trên Roblox Mobile, UserInputService không cho phép gửi sự kiện touch giả.
    Do đó, không thể thực sự click vào vị trí màn hình từ script.
    Auto Click hoạt động bằng cách sử dụng Tool:Activate().
    "Set Position" và "Test Click" chỉ có tác dụng hiển thị vị trí đã chọn.
    Nếu game yêu cầu click vào UI button, bạn cần tìm cách khác (ví dụ FireServer).
]]
