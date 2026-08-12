-- ============================================================
-- AUTO CLICKER PRO MOBILE V4.0 - FULL FIX + RESPONSIVE
-- Tác giả: HBG (Huy Báo Game)
-- ============================================================

-- ================================
-- XÓA GUI CŨ & RESET TRẠNG THÁI
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
local isRunning = false
local isAutoClickOn = false
local currentCPS = 10
local currentInterval = 0.10
local clickCount = 0
local clickPosition = nil          -- {X, Y}
local isPositionSet = false
local targetMode = "SINGLE"
local menuVisible = true
local isMinimized = false
local isSettingPosition = false
local loopThread = nil
local markerObject = nil           -- để xóa marker khi reset

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

local function formatNumber(num)
    if num >= 1000 then
        return string.format("%.1fK", num/1000)
    end
    return tostring(num)
end

-- ================================
-- AUTO CLICK LOOP (GIỮ LOGIC CŨ)
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
                        clickCountLabel.Text = formatNumber(clickCount)
                    end
                end)
            else
                -- Không có tool: cập nhật status
                if statusLabel then
                    statusLabel.Text = "● WAITING FOR TOOL"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                end
            end
            local delay = (currentInterval and currentInterval > 0) and currentInterval or (1 / currentCPS)
            if delay < 0.02 then delay = 0.02 end
            task.wait(delay)
        else
            task.wait(0.1)
        end
    end
end

-- ================================
-- HÀM START / STOP / TOGGLE
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
    if isRunning then
        stopAutoClick()
    else
        startAutoClick()
    end
end

-- ================================
-- CẬP NHẬT UI
-- ================================
local function updateUI()
    -- Status
    if statusLabel then
        if isRunning and isAutoClickOn then
            statusLabel.Text = "● RUNNING"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "● STOPPED"
            statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    -- Toggle ON/OFF
    if toggleBtn then
        toggleBtn.Text = isAutoClickOn and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = isAutoClickOn and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80, 80, 100)
    end
    -- CPS
    if cpsDisplay then
        cpsDisplay.Text = "CPS: " .. currentCPS
    end
    if cpsValueBtn then
        cpsValueBtn.Text = tostring(currentCPS)
    end
    -- Interval
    if intervalLabel then
        intervalLabel.Text = string.format("%.2fs", currentInterval)
    end
    -- Tool
    if toolLabel then
        local tool = getCurrentTool()
        toolLabel.Text = "⚔ " .. (tool and tool.Name or "None")
    end
    -- Click count
    if clickCountLabel then
        clickCountLabel.Text = formatNumber(clickCount)
    end
    -- Position
    if posLabel then
        if isPositionSet and clickPosition then
            posLabel.Text = "X: " .. math.floor(clickPosition.X) .. " Y: " .. math.floor(clickPosition.Y)
        else
            posLabel.Text = "X: Not Set  Y: Not Set"
        end
    end
    -- Target mode
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
-- XỬ LÝ ĐÓNG / MỞ MENU
-- ================================
local function closeMenu()
    menuVisible = false
    mainFrame.Visible = false
    if floatBtn then floatBtn.Visible = true end
end

local function showMenu()
    menuVisible = true
    mainFrame.Visible = true
    if floatBtn then floatBtn.Visible = false end
    updateUI()
end

-- ================================
-- TẠO GIAO DIỆN (RESPONSIVE)
-- ================================
local screenGui = create("ScreenGui", {
    Name = "AutoClickerGUI",
    Parent = player.PlayerGui,
    ResetOnSpawn = false
})

-- Lấy kích thước màn hình
local viewport = workspace.CurrentCamera.ViewportSize
local isLandscape = viewport.X > viewport.Y

-- Tính kích thước menu dựa trên tỷ lệ màn hình
local menuWidth = isLandscape and math.min(viewport.X * 0.35, 350) or math.min(viewport.X * 0.85, 320)
local menuHeight = isLandscape and math.min(viewport.Y * 0.8, 400) or math.min(viewport.Y * 0.7, 420)

-- Đảm bảo menu không vượt quá 80% chiều cao màn hình
menuHeight = math.min(menuHeight, viewport.Y * 0.8)

-- ---- FRAME CHÍNH ----
local mainFrame = create("Frame", {
    Size = UDim2.new(0, menuWidth, 0, menuHeight),
    Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(80, 120, 200),
    Active = true,
    Draggable = true,
    Visible = true,
    Parent = screenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainFrame})
create("UIStroke", {Color = Color3.fromRGB(80, 120, 200), Thickness = 1, Parent = mainFrame})

-- ---- HEADER ----
local titleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
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

-- Nút minimize (dấu -)
local minBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -56, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "−",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = titleBar
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minBtn})

-- Nút đóng (X)
local closeBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -28, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(200, 40, 40),
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = titleBar
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = closeBtn})

-- ---- SCROLLING FRAME CHO NỘI DUNG ----
local contentScroller = create("ScrollingFrame", {
    Size = UDim2.new(1, -12, 1, -42),
    Position = UDim2.new(0, 6, 0, 36),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    CanvasSize = UDim2.new(0, 0, 0, 420),
    Parent = mainFrame
})

local content = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = contentScroller
})

-- ---- STATUS ----
local statusLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundTransparency = 1,
    Text = "● STOPPED",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

-- ---- AUTO CLICK TOGGLE ----
local toggleFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 0, 26),
    BackgroundTransparency = 1,
    Parent = content
})
local toggleLabel = create("TextLabel", {
    Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "AUTO CLICK",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = toggleFrame
})
local toggleBtn = create("TextButton", {
    Size = UDim2.new(0, 70, 0, 24),
    Position = UDim2.new(0.7, 0, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(80, 80, 100),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = toggleFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleBtn})

-- ---- SPEED ----
local speedLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 60),
    BackgroundTransparency = 1,
    Text = "SPEED",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local cpsDisplay = create("TextLabel", {
    Size = UDim2.new(0.4, 0, 0, 20),
    Position = UDim2.new(0.05, 0, 0, 80),
    BackgroundTransparency = 1,
    Text = "CPS: 10",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = content
})

-- Nút − và + CPS
local cpsMinus = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0.5, -38, 0, 80),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "−",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpsMinus})

local cpsValueBtn = create("TextButton", {
    Size = UDim2.new(0, 36, 0, 28),
    Position = UDim2.new(0.5, -18, 0, 80),
    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
    Text = "10",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpsValueBtn})

local cpsPlus = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0.5, 10, 0, 80),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "+",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpsPlus})

-- Slider CPS
local sliderTrack = create("Frame", {
    Size = UDim2.new(0.7, 0, 0, 6),
    Position = UDim2.new(0.15, 0, 0, 114),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = sliderTrack})

local sliderThumb = create("TextButton", {
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8),
    BackgroundColor3 = Color3.fromRGB(100, 180, 255),
    BorderSizePixel = 0,
    Text = "",
    Parent = sliderTrack
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = sliderThumb})

-- ---- INTERVAL ----
local intervalTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 126),
    BackgroundTransparency = 1,
    Text = "INTERVAL",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local intervalBtn = create("TextButton", {
    Size = UDim2.new(0.4, 0, 0, 24),
    Position = UDim2.new(0.3, 0, 0, 146),
    BackgroundColor3 = Color3.fromRGB(60, 60, 100),
    Text = "0.10s",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = intervalBtn})
local intervalLabel = intervalBtn

-- ---- TARGET MODE ----
local targetTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 176),
    BackgroundTransparency = 1,
    Text = "TARGET",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local targetFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 0, 196),
    BackgroundTransparency = 1,
    Parent = content
})

local singleBtn = create("TextButton", {
    Size = UDim2.new(0.3, 0, 1, 0),
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
    Size = UDim2.new(0.3, 0, 1, 0),
    Position = UDim2.new(0.6, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "MULTI",
    TextColor3 = Color3.fromRGB(200,200,200),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = targetFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = multiBtn})

-- ---- TOOL ----
local toolTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 230),
    BackgroundTransparency = 1,
    Text = "TOOL",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local toolLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 250),
    BackgroundTransparency = 1,
    Text = "⚔ None",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = content
})

-- ---- CLICK POSITION ----
local posTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 276),
    BackgroundTransparency = 1,
    Text = "CLICK POSITION",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local posLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 296),
    BackgroundTransparency = 1,
    Text = "X: Not Set  Y: Not Set",
    TextColor3 = Color3.fromRGB(150, 150, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local posBtnFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 0, 316),
    BackgroundTransparency = 1,
    Parent = content
})

local setPosBtn = create("TextButton", {
    Size = UDim2.new(0.28, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 100),
    Text = "SET",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = posBtnFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = setPosBtn})

local testPosBtn = create("TextButton", {
    Size = UDim2.new(0.28, 0, 1, 0),
    Position = UDim2.new(0.34, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 100),
    Text = "TEST",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = posBtnFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = testPosBtn})

local resetPosBtn = create("TextButton", {
    Size = UDim2.new(0.28, 0, 1, 0),
    Position = UDim2.new(0.68, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(60, 60, 100),
    Text = "RESET",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = posBtnFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = resetPosBtn})

-- ---- CLICKS ----
local clickTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 350),
    BackgroundTransparency = 1,
    Text = "CLICKS",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = content
})

local clickCountLabel = create("TextLabel", {
    Size = UDim2.new(0.6, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 370),
    BackgroundTransparency = 1,
    Text = "0",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = content
})

local resetCountBtn = create("TextButton", {
    Size = UDim2.new(0.28, 0, 0, 20),
    Position = UDim2.new(0.68, 0, 0, 370),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "RESET",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    BorderSizePixel = 0,
    Parent = content
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = resetCountBtn})

-- Cập nhật CanvasSize cho ScrollingFrame
contentScroller.CanvasSize = UDim2.new(0, 0, 0, 410)

-- ---- NÚT NỔI AC ----
local floatBtn = create("TextButton", {
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(1, -56, 0.5, -22),
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
create("UICorner", {CornerRadius = UDim.new(0, 22), Parent = floatBtn})

-- ================================
-- XỬ LÝ KÉO THẢ (TOUCH)
-- ================================
local dragData = {dragging = false, object = nil, offset = nil}

local function startDrag(obj, input)
    if not obj then return end
    dragData.dragging = true
    dragData.object = obj
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

-- Gắn sự kiện kéo cho title bar và nút AC
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
            sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
            currentInterval = 1 / currentCPS
            updateUI()
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- ================================
-- XỬ LÝ SỰ KIỆN NÚT (TOUCH + CLICK)
-- ================================

-- Đóng menu
closeBtn.MouseButton1Click:Connect(closeMenu)
closeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        closeMenu()
    end
end)

-- Mở menu từ AC
floatBtn.MouseButton1Click:Connect(showMenu)
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        showMenu()
    end
end)

-- Toggle AUTO CLICK
toggleBtn.MouseButton1Click:Connect(toggleAutoClick)
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        toggleAutoClick()
    end
end)

-- CPS − và +
cpsMinus.MouseButton1Click:Connect(function()
    if currentCPS > 1 then
        currentCPS = currentCPS - 1
        sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
        currentInterval = 1 / currentCPS
        updateUI()
    end
end)
cpsMinus.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if currentCPS > 1 then
            currentCPS = currentCPS - 1
            sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
            currentInterval = 1 / currentCPS
            updateUI()
        end
    end
end)

cpsPlus.MouseButton1Click:Connect(function()
    if currentCPS < 20 then
        currentCPS = currentCPS + 1
        sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
        currentInterval = 1 / currentCPS
        updateUI()
    end
end)
cpsPlus.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if currentCPS < 20 then
            currentCPS = currentCPS + 1
            sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
            currentInterval = 1 / currentCPS
            updateUI()
        end
    end
end)

-- INTERVAL (xoay vòng các giá trị)
local intervalOptions = {0.05, 0.10, 0.20, 0.50, 1.00, 2.00}
local intervalIndex = 2
intervalBtn.MouseButton1Click:Connect(function()
    intervalIndex = (intervalIndex % #intervalOptions) + 1
    currentInterval = intervalOptions[intervalIndex]
    currentCPS = math.floor(1 / currentInterval)
    if currentCPS > 20 then currentCPS = 20 end
    if currentCPS < 1 then currentCPS = 1 end
    sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
    updateUI()
end)
intervalBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        intervalIndex = (intervalIndex % #intervalOptions) + 1
        currentInterval = intervalOptions[intervalIndex]
        currentCPS = math.floor(1 / currentInterval)
        if currentCPS > 20 then currentCPS = 20 end
        if currentCPS < 1 then currentCPS = 1 end
        sliderThumb.Position = UDim2.new((currentCPS-1)/19, -8, 0.5, -8)
        updateUI()
    end
end)

-- TARGET MODE
singleBtn.MouseButton1Click:Connect(function()
    targetMode = "SINGLE"
    updateUI()
end)
singleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        targetMode = "SINGLE"
        updateUI()
    end
end)

multiBtn.MouseButton1Click:Connect(function()
    targetMode = "MULTI"
    updateUI()
end)
multiBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        targetMode = "MULTI"
        updateUI()
    end
end)

-- RESET COUNT
resetCountBtn.MouseButton1Click:Connect(function()
    clickCount = 0
    if clickCountLabel then
        clickCountLabel.Text = "0"
    end
end)
resetCountBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        clickCount = 0
        if clickCountLabel then
            clickCountLabel.Text = "0"
        end
    end
end)

-- ================================
-- SET POSITION (TOUCH)
-- ================================
local function removeMarker()
    if markerObject then
        markerObject:Destroy()
        markerObject = nil
    end
end

local function createMarker(x, y, color)
    removeMarker()
    markerObject = create("Frame", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, x - 25, 0, y - 25),
        BackgroundColor3 = color or Color3.fromRGB(255, 200, 0),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        Visible = true,
        Parent = screenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0, 25), Parent = markerObject})
    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "CLICK",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = markerObject
    })
end

setPosBtn.MouseButton1Click:Connect(function()
    if isSettingPosition then return end
    isSettingPosition = true
    mainFrame.Visible = false
    -- Tạo overlay
    local overlay = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Visible = true,
        Parent = screenGui
    })
    local instruction = create("TextLabel", {
        Size = UDim2.new(0.8, 0, 0, 40),
        Position = UDim2.new(0.1, 0, 0.4, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Text = "CHẠM VÀO VỊ TRÍ MUỐN CLICK",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(255, 255, 255),
        Parent = overlay
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = instruction})

    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            clickPosition = {X = pos.X, Y = pos.Y}
            isPositionSet = true
            overlay:Destroy()
            connection:Disconnect()
            isSettingPosition = false
            mainFrame.Visible = true
            createMarker(pos.X, pos.Y, Color3.fromRGB(0, 255, 0))
            updateUI()
        end
    end)
end)
setPosBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        setPosBtn.MouseButton1Click:Fire()
    end
end)

-- TEST CLICK
testPosBtn.MouseButton1Click:Connect(function()
    if not isPositionSet or not clickPosition then
        -- Thông báo
        local note = create("TextLabel", {
            Size = UDim2.new(0, 200, 0, 30),
            Position = UDim2.new(0.5, -100, 0.5, -15),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Text = "POSITION NOT SET",
            TextColor3 = Color3.fromRGB(255, 0, 0),
            TextScaled = true,
            Font = Enum.Font.GothamBold,
            Parent = screenGui
        })
        create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = note})
        task.delay(1, function() note:Destroy() end)
        return
    end
    local tool = getCurrentTool()
    if tool then
        pcall(function() tool:Activate() end)
        createMarker(clickPosition.X, clickPosition.Y, Color3.fromRGB(0, 255, 0))
        task.delay(0.8, function() removeMarker() end)
    else
        createMarker(clickPosition.X, clickPosition.Y, Color3.fromRGB(255, 200, 0))
        task.delay(0.8, function() removeMarker() end)
    end
end)
testPosBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        testPosBtn.MouseButton1Click:Fire()
    end
end)

-- RESET POSITION
resetPosBtn.MouseButton1Click:Connect(function()
    clickPosition = nil
    isPositionSet = false
    removeMarker()
    updateUI()
end)
resetPosBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        resetPosBtn.MouseButton1Click:Fire()
    end
end)

-- ================================
-- CẬP NHẬT TOOL
-- ================================
local function onCharacterAdded(char)
    updateUI()
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            updateUI()
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            updateUI()
        end
    end)
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

player.CharacterAdded:Connect(function()
    task.wait(0.2)
    updateUI()
end)

-- ================================
-- RESPONSIVE: CẬP NHẬT KHI XOAY MÀN HÌNH
-- ================================
local function onViewportChanged()
    local newViewport = workspace.CurrentCamera.ViewportSize
    local isLandscapeNew = newViewport.X > newViewport.Y
    local newWidth = isLandscapeNew and math.min(newViewport.X * 0.35, 350) or math.min(newViewport.X * 0.85, 320)
    local newHeight = isLandscapeNew and math.min(newViewport.Y * 0.8, 400) or math.min(newViewport.Y * 0.7, 420)
    newHeight = math.min(newHeight, newViewport.Y * 0.8)
    mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    mainFrame.Position = UDim2.new(0.5, -newWidth/2, 0.5, -newHeight/2)
    -- Cập nhật CanvasSize nếu cần
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)

-- ================================
-- KHỞI TẠO UI
-- ================================
updateUI()
print("===== AUTO CLICKER PRO MOBILE V4.0 =====")
print("✅ Đã sẵn sàng. Nút X đóng menu, AC mở lại.")
print("🔘 Toggle AUTO CLICK để bật/tắt click.")
print("📍 SET POSITION: chạm vào màn hình để chọn vị trí.")
print("🔘 TEST: click thử một lần tại vị trí đã chọn.")
print("📱 Menu responsive, hỗ trợ touch.")
print("=========================================")
