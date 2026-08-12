-- ============================================================
-- AUTO CLICKER PRO MOBILE - ROBLOX LOCALSCRIPT
-- Dành riêng cho thiết bị di động, hỗ trợ TOUCH, kéo thả,
-- Tool:Activate(), CPS, START/STOP.
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ================================
-- XÓA GUI CŨ NẾU CÓ
-- ================================
local existingGui = player.PlayerGui:FindFirstChild("AutoClickerGUI")
if existingGui then existingGui:Destroy() end

local oldThread = nil
local clickRunning = false
local currentCPS = 10
local currentTargetMode = "SINGLE" -- "SINGLE" hoặc "MULTI"
local currentTool = nil
local clickCount = 0
local isMenuOpen = true
local isAutoClickOn = false
local isPaused = false

-- ================================
-- TẠO SCREENGUI
-- ================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- ================================
-- HÀM TIỆN ÍCH (TẠO OBJECT)
-- ================================
local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- ================================
-- HÀM CẬP NHẬT TOOL HIỆN TẠI
-- ================================
local function updateCurrentTool()
    local char = player.Character
    if not char then
        currentTool = nil
        return
    end
    local tool = char:FindFirstChildWhichIsA("Tool")
    currentTool = tool
end

-- Hàm lấy tên tool
local function getToolName()
    if currentTool then
        return currentTool.Name
    else
        return "None"
    end
end

-- ================================
-- HÀM AUTO CLICK
-- ================================
local function autoClickLoop()
    while clickRunning do
        if not isAutoClickOn then
            break
        end
        -- Kiểm tra tool
        updateCurrentTool()
        if currentTool then
            -- Kích hoạt tool
            pcall(function()
                currentTool:Activate()
            end)
            -- Tăng số lần click
            clickCount = clickCount + 1
            -- Cập nhật label click count nếu tồn tại
            if clickCountLabel then
                clickCountLabel.Text = tostring(clickCount)
            end
        end
        -- Đợi theo CPS
        local delay = 1 / currentCPS
        task.wait(delay)
    end
end

-- ================================
-- BẬT/TẮT AUTO CLICK
-- ================================
local function startAutoClick()
    if isAutoClickOn then return end
    isAutoClickOn = true
    clickRunning = true
    -- Cập nhật trạng thái hiển thị
    updateUI()
    -- Bắt đầu loop nếu chưa có
    if not oldThread then
        oldThread = task.spawn(autoClickLoop)
    end
end

local function stopAutoClick()
    if not isAutoClickOn then return end
    isAutoClickOn = false
    clickRunning = false
    -- Hủy thread cũ
    if oldThread then
        task.cancel(oldThread)
        oldThread = nil
    end
    updateUI()
end

-- ================================
-- TẠO GIAO DIỆN
-- ================================

-- ---- FRAME CHÍNH (MENU) ----
local mainFrame = create("Frame", {
    Size = UDim2.new(0, 340, 0, 440),
    Position = UDim2.new(0.5, -170, 0.5, -220),
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

-- ---- THANH TIÊU ĐỀ (CÓ THỂ KÉO) ----
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

-- Nút thu nhỏ (-)
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

-- Nút đóng (✕)
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

-- ---- KHU VỰC NỘI DUNG ----
local contentFrame = create("Frame", {
    Size = UDim2.new(1, -20, 1, -50),
    Position = UDim2.new(0, 10, 0, 45),
    BackgroundTransparency = 1,
    Parent = mainFrame
})

-- ---- DÒNG STATUS ----
local statusLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "● STATUS: STOPPED",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

-- ---- AUTO CLICK ON/OFF (TOGGLE) ----
local toggleFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = contentFrame
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

-- ---- CLICK SPEED ----
local speedLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 66),
    BackgroundTransparency = 1,
    Text = "CLICK SPEED",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

local cpsDisplay = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 90),
    BackgroundTransparency = 1,
    Text = "CPS: 10",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = contentFrame
})

-- Slider track
local sliderTrack = create("Frame", {
    Size = UDim2.new(0.8, 0, 0, 6),
    Position = UDim2.new(0.1, 0, 0, 118),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    BorderSizePixel = 0,
    Parent = contentFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = sliderTrack})

local sliderThumb = create("TextButton", {
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new((currentCPS-1)/19, -10, 0.5, -10),
    BackgroundColor3 = Color3.fromRGB(100, 180, 255),
    BorderSizePixel = 0,
    Text = "",
    Parent = sliderTrack
})
create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = sliderThumb})

-- Min/max label
local minLabel = create("TextLabel", {
    Size = UDim2.new(0.1, 0, 0, 14),
    Position = UDim2.new(0.05, 0, 0, 126),
    BackgroundTransparency = 1,
    Text = "1",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})
local maxLabel = create("TextLabel", {
    Size = UDim2.new(0.1, 0, 0, 14),
    Position = UDim2.new(0.85, 0, 0, 126),
    BackgroundTransparency = 1,
    Text = "20",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

-- ---- TARGET MODE ----
local targetLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 148),
    BackgroundTransparency = 1,
    Text = "TARGET MODE",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

local singleBtn = create("TextButton", {
    Size = UDim2.new(0, 80, 0, 28),
    Position = UDim2.new(0.1, 0, 0, 174),
    BackgroundColor3 = Color3.fromRGB(100, 180, 255),
    Text = "SINGLE",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = contentFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = singleBtn})

local multiBtn = create("TextButton", {
    Size = UDim2.new(0, 80, 0, 28),
    Position = UDim2.new(0.55, 0, 0, 174),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    Text = "MULTI",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = contentFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = multiBtn})

-- ---- CURRENT TOOL ----
local toolLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 208),
    BackgroundTransparency = 1,
    Text = "CURRENT TOOL",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

local toolNameLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 0, 230),
    BackgroundTransparency = 1,
    Text = "⚔ None",
    TextColor3 = Color3.fromRGB(255, 220, 100),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    Parent = contentFrame
})

-- ---- CLICK COUNT ----
local clickCountLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 256),
    BackgroundTransparency = 1,
    Text = "0",
    TextColor3 = Color3.fromRGB(150, 200, 255),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

local clickCountTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 0, 278),
    BackgroundTransparency = 1,
    Text = "CLICKS",
    TextColor3 = Color3.fromRGB(120, 120, 120),
    TextScaled = true,
    Font = Enum.Font.Gotham,
    Parent = contentFrame
})

-- ---- START / STOP BUTTON ----
local actionBtn = create("TextButton", {
    Size = UDim2.new(0.8, 0, 0, 36),
    Position = UDim2.new(0.1, 0, 0, 300),
    BackgroundColor3 = Color3.fromRGB(0, 180, 80),
    Text = "▶ START AUTO CLICK",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Parent = contentFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = actionBtn})

-- ---- NÚT NỔI (AC) ----
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
-- HÀM CẬP NHẬT UI
-- ================================
local function updateUI()
    -- Cập nhật trạng thái
    if isAutoClickOn then
        statusLabel.Text = "● STATUS: RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        actionBtn.Text = "■ STOP AUTO CLICK"
        actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- Cập nhật tool
        updateCurrentTool()
        toolNameLabel.Text = "⚔ " .. getToolName()
        if not currentTool then
            statusLabel.Text = "● STATUS: WAITING FOR TOOL"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        end
    else
        statusLabel.Text = "● STATUS: STOPPED"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        actionBtn.Text = "▶ START AUTO CLICK"
        actionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        toolNameLabel.Text = "⚔ " .. getToolName()
    end
    -- Cập nhật CPS display
    cpsDisplay.Text = "CPS: " .. currentCPS
    -- Cập nhật click count
    clickCountLabel.Text = tostring(clickCount)
end

-- ================================
-- XỬ LÝ SỰ KIỆN KÉO THẢ (MOBILE)
-- ================================
do
    local dragging = false
    local dragStart = nil
    local dragObj = nil

    local function startDrag(obj, input)
        if not obj then return end
        dragging = true
        dragObj = obj
        dragStart = Vector2.new(input.Position.X - obj.AbsolutePosition.X, input.Position.Y - obj.AbsolutePosition.Y)
    end

    local function updateDrag(input)
        if not dragging or not dragObj then return end
        local newX = input.Position.X - dragStart.X
        local newY = input.Position.Y - dragStart.Y
        -- Giới hạn trong màn hình
        local maxX = workspace.CurrentCamera.ViewportSize.X - dragObj.AbsoluteSize.X
        local maxY = workspace.CurrentCamera.ViewportSize.Y - dragObj.AbsoluteSize.Y
        newX = math.clamp(newX, 0, maxX)
        newY = math.clamp(newY, 0, maxY)
        dragObj.Position = UDim2.new(0, newX, 0, newY)
    end

    local function endDrag()
        dragging = false
        dragStart = nil
        dragObj = nil
    end

    -- Hỗ trợ touch cho menu
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            startDrag(mainFrame, input)
        end
    end)

    -- Hỗ trợ touch cho nút nổi
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
end

-- ================================
-- XỬ LÝ SỰ KIỆN NÚT
-- ================================

-- Nút đóng menu
closeBtn.MouseButton1Click:Connect(function()
    isMenuOpen = false
    mainFrame.Visible = false
    floatBtn.Visible = true
    -- Khi menu đóng, auto click vẫn chạy nếu đang ON
end)

-- Nút thu nhỏ (ẩn menu)
minBtn.MouseButton1Click:Connect(function()
    isMenuOpen = false
    mainFrame.Visible = false
    floatBtn.Visible = true
end)

-- Nút nổi mở lại menu
floatBtn.MouseButton1Click:Connect(function()
    isMenuOpen = true
    mainFrame.Visible = true
    floatBtn.Visible = false
end)

-- Toggle AUTO CLICK
toggleBtn.MouseButton1Click:Connect(function()
    if isAutoClickOn then
        -- Nếu đang ON, tắt
        stopAutoClick()
    else
        -- Nếu OFF, bật
        startAutoClick()
    end
end)

-- Action START/STOP
actionBtn.MouseButton1Click:Connect(function()
    if isAutoClickOn then
        stopAutoClick()
    else
        startAutoClick()
    end
end)

-- Slider CPS
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
        local newCPS = math.floor(1 + percent * 19) -- 1-20
        newCPS = math.clamp(newCPS, 1, 20)
        if newCPS ~= currentCPS then
            currentCPS = newCPS
            sliderThumb.Position = UDim2.new((currentCPS-1)/19, -10, 0.5, -10)
            updateUI()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- Target mode SINGLE
singleBtn.MouseButton1Click:Connect(function()
    if currentTargetMode == "SINGLE" then return end
    currentTargetMode = "SINGLE"
    singleBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    multiBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    singleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    multiBtn.TextColor3 = Color3.fromRGB(200,200,200)
end)

-- Target mode MULTI
multiBtn.MouseButton1Click:Connect(function()
    if currentTargetMode == "MULTI" then return end
    currentTargetMode = "MULTI"
    multiBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    singleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    multiBtn.TextColor3 = Color3.fromRGB(255,255,255)
    singleBtn.TextColor3 = Color3.fromRGB(200,200,200)
end)

-- ================================
-- THEO DÕI THAY ĐỔI CHARACTER / TOOL
-- ================================
local function onCharacterAdded(char)
    -- Reset tool khi nhân vật mới
    currentTool = nil
    -- Lắng nghe tool thay đổi
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            updateCurrentTool()
            updateUI()
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == currentTool then
            currentTool = nil
            updateUI()
        end
    end)
    updateCurrentTool()
    updateUI()
end

-- Lắng nghe sự kiện nhân vật
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ================================
-- KHỞI TẠO UI LẦN ĐẦU
-- ================================
updateUI()

-- ================================
-- XỬ LÝ RESPAWN / RESET
-- ================================
player.CharacterAdded:Connect(function()
    -- Khi respawn, nếu auto click đang ON, vẫn giữ ON
    -- Chỉ cần cập nhật tool
    task.wait(0.2)
    updateCurrentTool()
    updateUI()
end)

-- ================================
-- THÔNG BÁO
-- ================================
print("===== AUTO CLICKER PRO MOBILE =====")
print("✅ Đã tải thành công.")
print("🖱️ Menu hiển thị ở giữa màn hình.")
print("▶ Bấm START để bắt đầu auto click.")
print("⚡ Tool:Activate() được sử dụng để kích hoạt vũ khí.")
print("📌 Chế độ SINGLE/MULTI (đa mục tiêu đang phát triển).")
print("🔒 Bấm đóng (X) để thu nhỏ menu, vẫn chạy nếu đang ON.")
print("=====================================")
