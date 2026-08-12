-- ============================================================
-- BLOX LOOT ESP V24.0 - FIX ESP SAU KHI CHẾT
-- Tác giả: HBG (Huy Báo Game)
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local espEnabled = false
local espList = {}
local updateConnections = {}
local charAddedConnections = {}  -- Lưu kết nối CharacterAdded của từng player

-- Cấu hình màu
local nameColor = Color3.fromRGB(255, 255, 255)
local hpColor = Color3.fromRGB(255, 255, 255)
local distColor = Color3.fromRGB(255, 255, 255)

local showHP = true
local showDist = true
local rainbowEnabled = false
local rainbowConnection = nil

local showFPS = false
local fpsLabel = nil
local fpsConnection = nil
local renderDistance = 300

-- Font style
local boldFont = true

-- Scale
local currentScale = 0.3
local minScale = 0.01
local maxScale = 0.5

-- ================================
-- TIỆN ÍCH
-- ================================
local function create(className, properties)
    local obj = Instance.new(className)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    return obj
end

local function round(num)
    return math.floor(num + 0.5)
end

local function formatNumber(num)
    if num >= 1e15 then return string.format("%.2fQ", num / 1e15)
    elseif num >= 1e12 then return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then return string.format("%.2fK", num / 1e3)
    else return tostring(math.floor(num))
    end
end

-- ================================
-- GIAO DIỆN CHÍNH
-- ================================
local screenGui = create("ScreenGui", {
    Name = "HBG_ESP_Menu_Pro",
    Parent = player:WaitForChild("PlayerGui"),
    ResetOnSpawn = false
})

-- Nút mở menu
local menuButton = create("TextButton", {
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(1, -54, 0, 10),
    BackgroundColor3 = Color3.fromRGB(20, 20, 35),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Text = "⚡",
    TextColor3 = Color3.fromRGB(0, 220, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = screenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = menuButton})
create("UIStroke", {Color = Color3.fromRGB(0, 180, 255), Thickness = 1.5, Parent = menuButton})

-- ================================
-- MENU CHÍNH
-- ================================
local mainFrame = create("Frame", {
    Size = UDim2.new(0, 360, 0, 500),
    Position = UDim2.new(1, -380, 0, 65),
    BackgroundColor3 = Color3.fromRGB(10, 10, 25),
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Visible = false,
    Parent = screenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainFrame})
create("UIStroke", {Color = Color3.fromRGB(0, 200, 255), Thickness = 2, Parent = mainFrame})

local mainScale = create("UIScale", {Scale = currentScale, Parent = mainFrame})

-- Tiêu đề
local titleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = Color3.fromRGB(0, 130, 255),
    BorderSizePixel = 0,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = titleBar})
local titleFill = create("Frame", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0,0,0,18),
    BackgroundColor3 = Color3.fromRGB(0, 130, 255),
    BorderSizePixel = 0,
    Parent = titleBar
})
create("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 40, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚡ BLOX LOOT ESP",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = titleBar
})

local closeBtn = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -34, 0, 4),
    BackgroundColor3 = Color3.fromRGB(200, 0, 0),
    BorderSizePixel = 0,
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = closeBtn})

-- ================================
-- THANH SCALE (FIX)
-- ================================
local scaleFrame = create("Frame", {
    Size = UDim2.new(0.9, 0, 0, 32),
    Position = UDim2.new(0.05, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(30, 30, 50),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = scaleFrame})

local scaleLabel = create("TextLabel", {
    Size = UDim2.new(0.3, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "Size: 30%",
    TextColor3 = Color3.fromRGB(220, 220, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = scaleFrame
})

local minusBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 1, 0),
    Position = UDim2.new(0.32, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(70, 70, 100),
    BorderSizePixel = 0,
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = scaleFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = minusBtn})
minusBtn.MouseButton1Click:Connect(function()
    setScale(currentScale - 0.02)
end)

local plusBtn = create("TextButton", {
    Size = UDim2.new(0, 24, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(70, 70, 100),
    BorderSizePixel = 0,
    Text = "+",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = scaleFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = plusBtn})
plusBtn.MouseButton1Click:Connect(function()
    setScale(currentScale + 0.02)
end)

local sliderTrack = create("Frame", {
    Size = UDim2.new(0.35, 0, 0.4, 0),
    Position = UDim2.new(0.6, 0, 0.3, 0),
    BackgroundColor3 = Color3.fromRGB(50, 50, 70),
    BorderSizePixel = 0,
    Parent = scaleFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = sliderTrack})

local sliderThumb = create("TextButton", {
    Size = UDim2.new(0, 16, 1.4, 0),
    Position = UDim2.new((currentScale - minScale) / (maxScale - minScale), -8, -0.2, 0),
    BackgroundColor3 = Color3.fromRGB(0, 230, 255),
    BorderSizePixel = 0,
    Text = "",
    Parent = sliderTrack
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = sliderThumb})

local colorScale = nil
local function setScale(newScale)
    currentScale = math.clamp(newScale, minScale, maxScale)
    mainScale.Scale = currentScale
    if colorScale then
        colorScale.Scale = currentScale
    end
    scaleLabel.Text = "Size: " .. round(currentScale * 100) .. "%"
    local percent = (currentScale - minScale) / (maxScale - minScale)
    sliderThumb.Position = UDim2.new(percent, -8, -0.2, 0)
end

local dragging = false
sliderThumb.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackSize = sliderTrack.AbsoluteSize.X
        local mouseX = input.Position.X
        local percent = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local newScale = minScale + percent * (maxScale - minScale)
        setScale(newScale)
    end
end)

-- ================================
-- NHÓM CÀI ĐẶT ESP
-- ================================
local function addGroupLabel(y, text)
    return create("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, 18),
        Position = UDim2.new(0.05, 0, 0, y),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(150, 200, 255),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        Parent = mainFrame
    })
end

local function createToggle(parent, text, yPos, defaultState, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(0.85, 0, 0, 28),
        Position = UDim2.new(0.075, 0, 0, yPos),
        BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0),
        BorderSizePixel = 0,
        Text = defaultState and (text .. " ✅") or (text .. " ❌"),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        Parent = parent
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        btn.Text = state and (text .. " ✅") or (text .. " ❌")
        callback(state)
    end)
    return btn
end

addGroupLabel(80, "— ESP Settings —")

local yStart = 102
local spacing = 34

local espToggle = createToggle(mainFrame, "🔍 ESP", yStart, false, function(state)
    espEnabled = state
    if espEnabled then enableESP() else disableESP() end
end)

local hpToggle = createToggle(mainFrame, "❤️ HP", yStart + spacing, true, function(state)
    showHP = state
    updateAllESP()
end)

local distToggle = createToggle(mainFrame, "📏 DIST", yStart + spacing*2, true, function(state)
    showDist = state
    updateAllESP()
end)

-- ================================
-- NHÓM FONT (BOLD ON / OFF)
-- ================================
addGroupLabel(yStart + spacing*3 + 5, "— Font —")
local fontY = yStart + spacing*3 + 25

local boldOnBtn = create("TextButton", {
    Size = UDim2.new(0.38, 0, 0, 28),
    Position = UDim2.new(0.075, 0, 0, fontY),
    BackgroundColor3 = boldFont and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(80, 80, 80),
    BorderSizePixel = 0,
    Text = "🔤 Bold ON",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = boldOnBtn})
boldOnBtn.MouseButton1Click:Connect(function()
    boldFont = true
    boldOnBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    boldOffBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    updateAllFonts()
end)

local boldOffBtn = create("TextButton", {
    Size = UDim2.new(0.38, 0, 0, 28),
    Position = UDim2.new(0.52, 0, 0, fontY),
    BackgroundColor3 = boldFont and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(0, 180, 0),
    BorderSizePixel = 0,
    Text = "🔤 Bold OFF",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = boldOffBtn})
boldOffBtn.MouseButton1Click:Connect(function()
    boldFont = false
    boldOffBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    boldOnBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    updateAllFonts()
end)

-- ================================
-- NHÓM HIỆU NĂNG
-- ================================
local perfY = fontY + 40
addGroupLabel(perfY, "— Performance —")
perfY = perfY + 20

local fpsToggle = createToggle(mainFrame, "📊 FPS Counter", perfY, false, function(state)
    showFPS = state
    if state then
        if not fpsLabel then
            fpsLabel = create("TextLabel", {
                Size = UDim2.new(0, 100, 0, 30),
                Position = UDim2.new(0.5, -50, 0.92, 0),
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 0.35,
                TextColor3 = Color3.fromRGB(0,255,0),
                TextScaled = true,
                Font = Enum.Font.SourceSansBold,
                Text = "FPS: 0",
                Parent = screenGui
            })
            create("UICorner", {CornerRadius = UDim.new(0,6), Parent = fpsLabel})
        end
        fpsLabel.Visible = true
        startFPS()
    else
        if fpsLabel then fpsLabel.Visible = false end
        if fpsConnection then fpsConnection:Disconnect(); fpsConnection = nil end
    end
end)

local distLabelY = perfY + spacing
local distLabel = create("TextLabel", {
    Size = UDim2.new(0.85, 0, 0, 18),
    Position = UDim2.new(0.075, 0, 0, distLabelY),
    BackgroundTransparency = 1,
    Text = "📡 Render Dist: 300m",
    TextColor3 = Color3.fromRGB(220, 220, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSans,
    Parent = mainFrame
})

local distOptions = {"300m", "Full Map"}
local distValues = {300, 99999}
local currentDistIndex = 1
local distBtns = {}

for i = 1, 2 do
    local btn = create("TextButton", {
        Size = UDim2.new(0.4, 0, 0, 26),
        Position = UDim2.new(0.05 + (i-1)*0.45, 0, 0, distLabelY + 24),
        BackgroundColor3 = (i == currentDistIndex) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 70),
        BorderSizePixel = 0,
        Text = distOptions[i],
        TextColor3 = Color3.fromRGB(255,255,255),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        Parent = mainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})
    btn.MouseButton1Click:Connect(function()
        currentDistIndex = i
        renderDistance = distValues[i]
        distLabel.Text = "📡 Render Dist: " .. distOptions[i]
        for j, b in pairs(distBtns) do
            b.BackgroundColor3 = (j == i) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 70)
        end
        updateAllESP()
    end)
    table.insert(distBtns, btn)
end

local actionY = distLabelY + 60
local refreshBtn = create("TextButton", {
    Size = UDim2.new(0.35, 0, 0, 30),
    Position = UDim2.new(0.1, 0, 0, actionY),
    BackgroundColor3 = Color3.fromRGB(0, 100, 200),
    BorderSizePixel = 0,
    Text = "🔄 REFRESH",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0,8), Parent = refreshBtn})
refreshBtn.MouseButton1Click:Connect(function()
    if espEnabled then refreshESP() end
end)

local colorBtn = create("TextButton", {
    Size = UDim2.new(0.35, 0, 0, 30),
    Position = UDim2.new(0.55, 0, 0, actionY),
    BackgroundColor3 = Color3.fromRGB(120, 60, 220),
    BorderSizePixel = 0,
    Text = "🎨 MÀU",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0,8), Parent = colorBtn})

-- ================================
-- MENU MÀU SẮC (GIỮ NGUYÊN)
-- ================================
local colorSubMenu = create("Frame", {
    Size = UDim2.new(0, 500, 0, 640),
    Position = UDim2.new(0.5, -250, 0.15, 0),
    BackgroundColor3 = Color3.fromRGB(8, 8, 22),
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Visible = false,
    Parent = screenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = colorSubMenu})
create("UIStroke", {Color = Color3.fromRGB(180, 120, 255), Thickness = 2, Parent = colorSubMenu})

colorScale = create("UIScale", {Scale = currentScale, Parent = colorSubMenu})

local subTitleBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(120, 60, 220),
    BorderSizePixel = 0,
    Parent = colorSubMenu
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = subTitleBar})
local subTitleFill = create("Frame", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0,0,0,16),
    BackgroundColor3 = Color3.fromRGB(120, 60, 220),
    BorderSizePixel = 0,
    Parent = subTitleBar
})
create("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 40, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎨 BẢNG MÀU",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = subTitleBar
})

local subClose = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -34, 0, 2),
    BackgroundColor3 = Color3.fromRGB(200, 0, 0),
    BorderSizePixel = 0,
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = colorSubMenu
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = subClose})
subClose.MouseButton1Click:Connect(function() colorSubMenu.Visible = false end)

-- Chọn thành phần
local selectedComponent = "Tên"
local compFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundTransparency = 1,
    Parent = colorSubMenu
})

local compBtns = {}
local compNames = {"Tên", "HP", "Khoảng cách"}
for i, name in ipairs(compNames) do
    local btn = create("TextButton", {
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new((i-1)*0.33, 0, 0, 0),
        BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 70),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        Parent = compFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})
    btn.MouseButton1Click:Connect(function()
        selectedComponent = name
        for j, b in ipairs(compBtns) do
            b.BackgroundColor3 = (j == i) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 50, 70)
        end
        updateColorBorders()
    end)
    table.insert(compBtns, btn)
end

local function getSelectedColor()
    if selectedComponent == "Tên" then return nameColor
    elseif selectedComponent == "HP" then return hpColor
    else return distColor end
end

local function setSelectedColor(color)
    if selectedComponent == "Tên" then nameColor = color
    elseif selectedComponent == "HP" then hpColor = color
    else distColor = color end
    updateAllESP()
    updateColorBorders()
end

local colorButtons = {}
function updateColorBorders()
    local currentColor = getSelectedColor()
    for _, btn in ipairs(colorButtons) do
        local stroke = btn:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = (btn.BackgroundColor3 == currentColor) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 80)
        end
    end
end

local colorGroups = {
    {name = "PRIMARY", colors = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0), Color3.fromRGB(255,0,255)}},
    {name = "COOL COLORS", colors = {Color3.fromRGB(0,150,255), Color3.fromRGB(0,255,200), Color3.fromRGB(0,200,255), Color3.fromRGB(150,100,255), Color3.fromRGB(200,150,255)}},
    {name = "WARMTHY", colors = {Color3.fromRGB(255,100,0), Color3.fromRGB(255,150,0), Color3.fromRGB(255,200,0), Color3.fromRGB(200,50,0), Color3.fromRGB(200,150,0)}},
    {name = "BEAUTIFUL", colors = {Color3.fromRGB(255,180,200), Color3.fromRGB(180,255,200), Color3.fromRGB(200,180,255), Color3.fromRGB(255,255,180), Color3.fromRGB(255,200,150)}},
    {name = "SMOOTH WAVES", colors = {Color3.fromRGB(0,50,150), Color3.fromRGB(0,100,200), Color3.fromRGB(0,200,180), Color3.fromRGB(50,150,255), Color3.fromRGB(150,220,255)}},
    {name = "ALMOST", colors = {Color3.fromRGB(250,250,240), Color3.fromRGB(200,200,200), Color3.fromRGB(150,150,150), Color3.fromRGB(50,50,50), Color3.fromRGB(20,20,20)}},
    {name = "DECORATED", colors = {Color3.fromRGB(255,215,0), Color3.fromRGB(192,192,192), Color3.fromRGB(184,115,51), Color3.fromRGB(255,200,100), Color3.fromRGB(255,180,150)}},
}

local function createColorPalette()
    local startY = 75
    local cellSize = 30
    local gap = 5
    local cols = 6

    for _, group in ipairs(colorGroups) do
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, startY),
            BackgroundTransparency = 1,
            Text = group.name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            Font = Enum.Font.SourceSansBold,
            Parent = colorSubMenu
        })
        startY = startY + 20

        local totalWidth = cols * (cellSize + gap) - gap
        local startX = (colorSubMenu.Size.X.Offset - totalWidth) / 2

        for i, col in ipairs(group.colors) do
            local colIndex = (i-1) % cols
            local x = startX + colIndex * (cellSize + gap)
            local y = startY + math.floor((i-1) / cols) * (cellSize + gap)

            local btn = create("TextButton", {
                Size = UDim2.new(0, cellSize, 0, cellSize),
                Position = UDim2.new(0, x, 0, y),
                BackgroundColor3 = col,
                BorderSizePixel = 0,
                Text = "",
                Parent = colorSubMenu
            })
            create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
            local stroke = create("UIStroke", {Color = Color3.fromRGB(80,80,80), Thickness = 1.5, Parent = btn})
            
            btn.MouseButton1Click:Connect(function()
                setSelectedColor(col)
                updateColorBorders()
            end)
            table.insert(colorButtons, btn)
        end
        startY = startY + math.ceil(#group.colors / cols) * (cellSize + gap) + 10
    end
    updateColorBorders()
end

createColorPalette()

local rainbowBtn = create("TextButton", {
    Size = UDim2.new(0, 110, 0, 24),
    Position = UDim2.new(0.1, 0, 0, 605),
    BackgroundColor3 = Color3.fromRGB(150, 0, 200),
    BorderSizePixel = 0,
    Text = "🌈 RAINBOW OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = colorSubMenu
})
create("UICorner", {CornerRadius = UDim.new(0,6), Parent = rainbowBtn})
rainbowBtn.MouseButton1Click:Connect(function()
    rainbowEnabled = not rainbowEnabled
    rainbowBtn.Text = rainbowEnabled and "🌈 RAINBOW ON" or "🌈 RAINBOW OFF"
    rainbowBtn.BackgroundColor3 = rainbowEnabled and Color3.fromRGB(200, 0, 255) or Color3.fromRGB(150, 0, 200)
    if rainbowEnabled then
        if rainbowConnection then rainbowConnection:Disconnect() end
        rainbowConnection = RunService.Heartbeat:Connect(function()
            if rainbowEnabled then
                local hue = (tick() * 0.1) % 1
                nameColor = Color3.fromHSV(hue, 1, 1)
                hpColor = Color3.fromHSV((hue + 0.33) % 1, 1, 1)
                distColor = Color3.fromHSV((hue + 0.66) % 1, 1, 1)
                updateAllESP()
            end
        end)
    else
        if rainbowConnection then rainbowConnection:Disconnect(); rainbowConnection = nil end
    end
end)

local resetBtn = create("TextButton", {
    Size = UDim2.new(0, 120, 0, 24),
    Position = UDim2.new(0.55, 0, 0, 605),
    BackgroundColor3 = Color3.fromRGB(80, 80, 80),
    BorderSizePixel = 0,
    Text = "🔄 Đặt lại (trắng)",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Parent = colorSubMenu
})
create("UICorner", {CornerRadius = UDim.new(0,6), Parent = resetBtn})
resetBtn.MouseButton1Click:Connect(function()
    nameColor = Color3.fromRGB(255,255,255)
    hpColor = Color3.fromRGB(255,255,255)
    distColor = Color3.fromRGB(255,255,255)
    rainbowEnabled = false
    rainbowBtn.Text = "🌈 RAINBOW OFF"
    rainbowBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    if rainbowConnection then rainbowConnection:Disconnect(); rainbowConnection = nil end
    updateColorBorders()
    updateAllESP()
end)

colorBtn.MouseButton1Click:Connect(function()
    colorSubMenu.Visible = not colorSubMenu.Visible
    if colorSubMenu.Visible then updateColorBorders() end
end)

-- ================================
-- ĐÓNG/MỞ MENU CHÍNH
-- ================================
local menuOpen = false
menuButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
    menuButton.BackgroundColor3 = menuOpen and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(20, 20, 35)
    if not menuOpen then
        colorSubMenu.Visible = false
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    mainFrame.Visible = false
    menuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    colorSubMenu.Visible = false
end)

-- ================================
-- HỆ THỐNG ESP (FIX KHI CHẾT)
-- ================================
local function startFPS()
    if fpsConnection then fpsConnection:Disconnect() end
    local count = 0
    local lastTime = tick()
    fpsConnection = RunService.Heartbeat:Connect(function()
        count = count + 1
        local now = tick()
        if now - lastTime >= 1 then
            local fps = count
            count = 0
            lastTime = now
            if fpsLabel then
                fpsLabel.Text = "FPS: " .. fps
                fpsLabel.TextColor3 = fps > 60 and Color3.fromRGB(0, 255, 0) or (fps > 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
            end
        end
    end)
end

local function updateAllFonts()
    local font = boldFont and Enum.Font.SourceSansBold or Enum.Font.SourceSans
    for _, d in ipairs(espList) do
        if d.label then
            d.label.Font = font
        end
    end
end

local function updateESPForPlayer(targetPlayer)
    if targetPlayer == player then return end
    local data = nil
    for _, d in ipairs(espList) do
        if d.player == targetPlayer then data = d break end
    end
    if not data then return end

    local char = targetPlayer.Character
    if not char then
        -- Nếu không có character, tắt billboard (nếu tồn tại)
        if data.billboard then data.billboard.Enabled = false end
        return
    end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then
        if data.billboard then data.billboard.Enabled = false end
        return
    end

    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then
        if data.billboard then data.billboard.Enabled = false end
        return
    end

    local dist = (myRoot.Position - targetRoot.Position).Magnitude
    if dist > renderDistance then
        data.billboard.Enabled = false
        return
    else
        data.billboard.Enabled = true
    end

    local hp = humanoid.Health
    local hpStr = formatNumber(hp)
    local distStr = tostring(math.floor(dist))

    local function rgbToHex(c)
        return string.format("rgb(%d,%d,%d)", c.R*255, c.G*255, c.B*255)
    end

    local nameHex = rgbToHex(nameColor)
    local hpHex = rgbToHex(hpColor)
    local distHex = rgbToHex(distColor)

    local text = ""
    if showHP and showDist then
        text = string.format('<font color="%s">%s</font> | <font color="%s">%s</font> | <font color="%s">%s</font>',
            nameHex, targetPlayer.Name, hpHex, hpStr, distHex, distStr)
    elseif showHP then
        text = string.format('<font color="%s">%s</font> | <font color="%s">%s</font>',
            nameHex, targetPlayer.Name, hpHex, hpStr)
    elseif showDist then
        text = string.format('<font color="%s">%s</font> | <font color="%s">%s</font>',
            nameHex, targetPlayer.Name, distHex, distStr)
    else
        text = string.format('<font color="%s">%s</font>', nameHex, targetPlayer.Name)
    end
    data.label.Text = text
end

function updateAllESP()
    for _, d in ipairs(espList) do
        updateESPForPlayer(d.player)
    end
end

-- Tạo ESP cho một player và lắng nghe CharacterAdded
local function createESPForPlayer(targetPlayer)
    if targetPlayer == player then return end

    -- Xóa ESP cũ nếu có
    local oldData = nil
    for i, d in ipairs(espList) do
        if d.player == targetPlayer then
            oldData = d
            break
        end
    end
    if oldData then
        if oldData.billboard then oldData.billboard:Destroy() end
        table.remove(espList, table.find(espList, oldData))
    end

    -- Tạo mới nếu có Character
    local char = targetPlayer.Character
    if not char or not char:FindFirstChild("Head") then
        -- Chưa có Character (đang chết hoặc chưa spawn), vẫn lắng nghe CharacterAdded
        -- Nhưng không tạo billboard ngay
        local billboard = nil
        local label = nil
        -- Chỉ tạo khi có Character, nhưng vẫn lưu vào danh sách để khi hồi sinh sẽ tạo lại
        -- Để đơn giản, ta sẽ tạo billboard ngay khi Character xuất hiện
        -- Vậy ta sẽ lắng nghe và tạo khi CharacterAdded
        -- Nhưng nếu đã có Character, tạo luôn
    end

    -- Tạo Billboard mới
    local newChar = targetPlayer.Character
    if newChar and newChar:FindFirstChild("Head") then
        local billboard = create("BillboardGui", {
            Name = "HBG_ESP_Billboard",
            Size = UDim2.new(0, 450, 0, 25),
            AlwaysOnTop = true,
            Adornee = newChar.Head,
            StudsOffset = Vector3.new(0, 2.8, 0),
            Parent = newChar
        })

        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 14,
            Font = boldFont and Enum.Font.SourceSansBold or Enum.Font.SourceSans,
            RichText = true,
            Text = targetPlayer.Name,
            Parent = billboard
        })

        table.insert(espList, {player = targetPlayer, billboard = billboard, label = label})
        updateESPForPlayer(targetPlayer)

        -- Kết nối HealthChanged
        local humanoid = newChar:FindFirstChild("Humanoid")
        if humanoid then
            local conn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                updateESPForPlayer(targetPlayer)
            end)
            table.insert(updateConnections, conn)
        end
    else
        -- Nếu không có Character, vẫn lưu một bản ghi trống để khi CharacterAdded sẽ xử lý
        table.insert(espList, {player = targetPlayer, billboard = nil, label = nil})
    end

    -- Lắng nghe CharacterAdded cho player này (để tạo lại ESP khi hồi sinh)
    -- Nếu đã có kết nối thì không tạo mới
    if not charAddedConnections[targetPlayer] then
        local conn = targetPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.2) -- đợi character load
            -- Tạo ESP mới cho player này (xóa cũ rồi tạo mới)
            createESPForPlayer(targetPlayer)
        end)
        charAddedConnections[targetPlayer] = conn
    end
end

function enableESP()
    disableESP() -- dọn dẹp sạch sẽ

    -- Tạo ESP cho tất cả player hiện tại
    for _, plr in ipairs(Players:GetPlayers()) do
        createESPForPlayer(plr)
    end

    -- Lắng nghe player mới thêm
    Players.PlayerAdded:Connect(function(newPlayer)
        task.wait(0.5)
        if espEnabled then
            createESPForPlayer(newPlayer)
        end
    end)

    print("[ESP] Đã bật ESP (" .. #espList .. " người chơi)")
end

function disableESP()
    -- Xóa billboard
    for _, d in ipairs(espList) do
        if d.billboard then d.billboard:Destroy() end
    end
    espList = {}

    -- Ngắt kết nối HealthChanged
    for _, conn in ipairs(updateConnections) do
        conn:Disconnect()
    end
    updateConnections = {}

    -- Ngắt kết nối CharacterAdded
    for _, conn in pairs(charAddedConnections) do
        conn:Disconnect()
    end
    charAddedConnections = {}

    print("[ESP] Đã tắt ESP")
end

function refreshESP()
    if espEnabled then
        disableESP()
        task.wait(0.3)
        enableESP()
    end
end

-- Sự kiện PlayerRemoving: xóa khỏi danh sách và ngắt kết nối
Players.PlayerRemoving:Connect(function(removedPlayer)
    -- Xóa khỏi espList
    for i, d in ipairs(espList) do
        if d.player == removedPlayer then
            if d.billboard then d.billboard:Destroy() end
            table.remove(espList, i)
            break
        end
    end
    -- Ngắt CharacterAdded
    if charAddedConnections[removedPlayer] then
        charAddedConnections[removedPlayer]:Disconnect()
        charAddedConnections[removedPlayer] = nil
    end
end)

-- Vòng lặp cập nhật ESP (khoảng cách, HP)
RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _, d in ipairs(espList) do
            updateESPForPlayer(d.player)
        end
    end
end)

-- ================================
-- KHỞI ĐỘNG
-- ================================
print("[HBG] Blox Loot ESP V24.0 - Fix ESP sau khi chết đã tải!")
print("⚡ Click nút ⚡ để mở menu.")
print("🔄 Khi player chết và hồi sinh, ESP sẽ tự động hiện lại.")
