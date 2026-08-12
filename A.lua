-- ============================================================
-- AUTO CLICKER PRO MOBILE V5.0
-- FULL MOBILE FIX
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================================
-- XÓA GUI CŨ
-- ============================================================

local oldGui = playerGui:FindFirstChild("AutoClickerGUI")

if oldGui then
    oldGui:Destroy()
end

-- ============================================================
-- TRẠNG THÁI
-- ============================================================

local isRunning = false
local isAutoClickOn = false

local currentCPS = 10
local currentInterval = 0.10

local clickCount = 0

local clickPosition = nil
local isPositionSet = false
local isSettingPosition = false

local targetMode = "SINGLE"

local menuVisible = true
local isMinimized = false

local loopThread = nil
local markerObject = nil

-- ============================================================
-- FORWARD DECLARATION
-- QUAN TRỌNG: FIX LỖI UPDATE UI
-- ============================================================

local mainFrame
local contentScroller
local titleBar

local statusLabel
local toggleBtn
local cpsDisplay
local cpsValueBtn
local intervalBtn
local toolLabel
local posLabel
local clickCountLabel

local singleBtn
local multiBtn

local sliderTrack
local sliderThumb

local floatBtn

local updateUI
local closeMenu
local showMenu

-- ============================================================
-- HELPER
-- ============================================================

local function create(className, props)

    local obj = Instance.new(className)

    for key, value in pairs(props) do
        obj[key] = value
    end

    return obj
end

local function round(n)
    return math.floor(n + 0.5)
end

local function formatNumber(num)

    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)

    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)

    end

    return tostring(num)
end

local function getCurrentTool()

    local character = player.Character

    if not character then
        return nil
    end

    return character:FindFirstChildWhichIsA("Tool")
end

-- ============================================================
-- GUI
-- ============================================================

local screenGui = create("ScreenGui", {
    Name = "AutoClickerGUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    Parent = playerGui
})

-- ============================================================
-- RESPONSIVE SIZE
-- ============================================================

local function getMenuSize()

    local viewport = camera.ViewportSize

    local landscape = viewport.X > viewport.Y

    if landscape then

        local width = math.min(310, viewport.X * 0.42)
        local height = math.min(370, viewport.Y * 0.78)

        return width, height

    else

        local width = math.min(310, viewport.X * 0.78)
        local height = math.min(440, viewport.Y * 0.68)

        return width, height

    end
end

local menuWidth, menuHeight = getMenuSize()

-- ============================================================
-- MAIN FRAME
-- ============================================================

mainFrame = create("Frame", {

    Size = UDim2.fromOffset(menuWidth, menuHeight),

    Position = UDim2.new(
        0.5,
        -menuWidth / 2,
        0.5,
        -menuHeight / 2
    ),

    BackgroundColor3 = Color3.fromRGB(18,18,28),

    BackgroundTransparency = 0.05,

    BorderSizePixel = 0,

    Active = true,

    Parent = screenGui
})

create("UICorner", {
    CornerRadius = UDim.new(0,12),
    Parent = mainFrame
})

create("UIStroke", {
    Color = Color3.fromRGB(80,120,200),
    Thickness = 1,
    Parent = mainFrame
})

-- ============================================================
-- HEADER
-- ============================================================

titleBar = create("Frame", {

    Size = UDim2.new(1,0,0,38),

    BackgroundColor3 = Color3.fromRGB(30,30,50),

    BorderSizePixel = 0,

    Active = true,

    Parent = mainFrame
})

create("UICorner", {
    CornerRadius = UDim.new(0,12),
    Parent = titleBar
})

local titleLabel = create("TextLabel", {

    Size = UDim2.new(1,-80,1,0),

    Position = UDim2.new(0,10,0,0),

    BackgroundTransparency = 1,

    Text = "AUTO CLICKER",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    Parent = titleBar
})

-- ============================================================
-- MINIMIZE
-- ============================================================

local minBtn = create("TextButton", {

    Size = UDim2.fromOffset(28,28),

    Position = UDim2.new(1,-64,0.5,-14),

    BackgroundColor3 = Color3.fromRGB(60,60,80),

    Text = "−",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = titleBar
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = minBtn
})

-- ============================================================
-- CLOSE
-- ============================================================

local closeBtn = create("TextButton", {

    Size = UDim2.fromOffset(28,28),

    Position = UDim2.new(1,-32,0.5,-14),

    BackgroundColor3 = Color3.fromRGB(200,45,45),

    Text = "×",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = titleBar
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = closeBtn
})

-- ============================================================
-- SCROLL
-- ============================================================

contentScroller = create("ScrollingFrame", {

    Size = UDim2.new(1,-12,1,-44),

    Position = UDim2.new(0,6,0,42),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ScrollBarThickness = 3,

    ScrollBarImageTransparency = 0.3,

    CanvasSize = UDim2.fromOffset(0,470),

    Parent = mainFrame
})

local content = create("Frame", {

    Size = UDim2.new(1,-4,0,470),

    BackgroundTransparency = 1,

    Parent = contentScroller
})

-- ============================================================
-- STATUS
-- ============================================================

statusLabel = create("TextLabel", {

    Size = UDim2.new(1,0,0,24),

    Position = UDim2.fromOffset(0,2),

    BackgroundTransparency = 1,

    Text = "● STOPPED",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

-- ============================================================
-- AUTO CLICK TOGGLE
-- ============================================================

local toggleLabel = create("TextLabel", {

    Size = UDim2.new(0.55,0,0,32),

    Position = UDim2.new(0,5,0,32),

    BackgroundTransparency = 1,

    Text = "AUTO CLICK",

    TextColor3 = Color3.fromRGB(225,225,225),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

toggleBtn = create("TextButton", {

    Size = UDim2.fromOffset(76,30),

    Position = UDim2.new(1,-82,0,33),

    BackgroundColor3 = Color3.fromRGB(70,70,90),

    Text = "OFF",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,8),
    Parent = toggleBtn
})

-- ============================================================
-- SPEED TITLE
-- ============================================================

local speedTitle = create("TextLabel", {

    Size = UDim2.new(1,0,0,20),

    Position = UDim2.fromOffset(0,70),

    BackgroundTransparency = 1,

    Text = "CLICK SPEED",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

-- ============================================================
-- CPS DISPLAY
-- ============================================================

cpsDisplay = create("TextLabel", {

    Size = UDim2.new(0.4,0,0,24),

    Position = UDim2.new(0.3,0,0,92),

    BackgroundTransparency = 1,

    Text = "CPS: 10",

    TextColor3 = Color3.fromRGB(255,220,100),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    Parent = content
})

-- ============================================================
-- CPS BUTTONS
-- ============================================================

local cpsMinus = create("TextButton", {

    Size = UDim2.fromOffset(30,30),

    Position = UDim2.new(0.5,-70,0,90),

    BackgroundColor3 = Color3.fromRGB(60,60,80),

    Text = "−",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = cpsMinus
})

cpsValueBtn = create("TextButton", {

    Size = UDim2.fromOffset(40,30),

    Position = UDim2.new(0.5,-20,0,90),

    BackgroundColor3 = Color3.fromRGB(40,40,60),

    Text = "10",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = cpsValueBtn
})

local cpsPlus = create("TextButton", {

    Size = UDim2.fromOffset(30,30),

    Position = UDim2.new(0.5,40,0,90),

    BackgroundColor3 = Color3.fromRGB(60,60,80),

    Text = "+",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = cpsPlus
})

-- ============================================================
-- SLIDER
-- ============================================================

sliderTrack = create("Frame", {

    Size = UDim2.new(0.76,0,0,7),

    Position = UDim2.new(0.12,0,0,127),

    BackgroundColor3 = Color3.fromRGB(65,65,85),

    BorderSizePixel = 0,

    Active = true,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,4),
    Parent = sliderTrack
})

sliderThumb = create("Frame", {

    Size = UDim2.fromOffset(20,20),

    Position = UDim2.new(
        (currentCPS-1)/19,
        -10,
        0.5,
        -10
    ),

    BackgroundColor3 = Color3.fromRGB(100,180,255),

    BorderSizePixel = 0,

    Active = false,

    Parent = sliderTrack
})

create("UICorner", {
    CornerRadius = UDim.new(0,10),
    Parent = sliderThumb
})

-- ============================================================
-- INTERVAL
-- ============================================================

local intervalTitle = create("TextLabel", {

    Size = UDim2.new(1,0,0,20),

    Position = UDim2.fromOffset(0,145),

    BackgroundTransparency = 1,

    Text = "INTERVAL",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

intervalBtn = create("TextButton", {

    Size = UDim2.fromOffset(90,28),

    Position = UDim2.new(0.5,-45,0,168),

    BackgroundColor3 = Color3.fromRGB(60,60,100),

    Text = "0.10s",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = intervalBtn
})

-- ============================================================
-- TARGET
-- ============================================================

local targetTitle = create("TextLabel", {

    Size = UDim2.new(1,0,0,20),

    Position = UDim2.fromOffset(0,202),

    BackgroundTransparency = 1,

    Text = "TARGET",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

singleBtn = create("TextButton", {

    Size = UDim2.new(0.38,0,0,32),

    Position = UDim2.new(0.08,0,0,226),

    BackgroundColor3 = Color3.fromRGB(100,180,255),

    Text = "SINGLE",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = singleBtn
})

multiBtn = create("TextButton", {

    Size = UDim2.new(0.38,0,0,32),

    Position = UDim2.new(0.54,0,0,226),

    BackgroundColor3 = Color3.fromRGB(60,60,80),

    Text = "MULTI",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = multiBtn
})

-- ============================================================
-- TOOL
-- ============================================================

local toolTitle = create("TextLabel", {

    Size = UDim2.new(1,0,0,20),

    Position = UDim2.fromOffset(0,264),

    BackgroundTransparency = 1,

    Text = "TOOL",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

toolLabel = create("TextLabel", {

    Size = UDim2.new(1,0,0,25),

    Position = UDim2.fromOffset(0,286),

    BackgroundTransparency = 1,

    Text = "⚔ None",

    TextColor3 = Color3.fromRGB(255,220,100),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    Parent = content
})

-- ============================================================
-- POSITION
-- ============================================================

local posTitle = create("TextLabel", {

    Size = UDim2.new(1,0,0,20),

    Position = UDim2.fromOffset(0,316),

    BackgroundTransparency = 1,

    Text = "CLICK POSITION",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

posLabel = create("TextLabel", {

    Size = UDim2.new(1,0,0,22),

    Position = UDim2.fromOffset(0,338),

    BackgroundTransparency = 1,

    Text = "X: Not Set   Y: Not Set",

    TextColor3 = Color3.fromRGB(150,180,220),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

-- ============================================================
-- POSITION BUTTONS
-- ============================================================

local setPosBtn = create("TextButton", {

    Size = UDim2.new(0.29,0,0,30),

    Position = UDim2.new(0.03,0,0,365),

    BackgroundColor3 = Color3.fromRGB(60,60,100),

    Text = "SET",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = setPosBtn
})

local testPosBtn = create("TextButton", {

    Size = UDim2.new(0.29,0,0,30),

    Position = UDim2.new(0.355,0,0,365),

    BackgroundColor3 = Color3.fromRGB(60,60,100),

    Text = "TEST",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = testPosBtn
})

local resetPosBtn = create("TextButton", {

    Size = UDim2.new(0.29,0,0,30),

    Position = UDim2.new(0.68,0,0,365),

    BackgroundColor3 = Color3.fromRGB(80,60,80),

    Text = "RESET",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,7),
    Parent = resetPosBtn
})

-- ============================================================
-- CLICKS
-- ============================================================

local clickTitle = create("TextLabel", {

    Size = UDim2.new(1,0,0,20),

    Position = UDim2.fromOffset(0,402),

    BackgroundTransparency = 1,

    Text = "CLICKS",

    TextColor3 = Color3.fromRGB(200,200,200),

    TextScaled = true,

    Font = Enum.Font.Gotham,

    Parent = content
})

clickCountLabel = create("TextLabel", {

    Size = UDim2.new(0.5,0,0,25),

    Position = UDim2.new(0.05,0,0,425),

    BackgroundTransparency = 1,

    Text = "0",

    TextColor3 = Color3.fromRGB(255,220,100),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    Parent = content
})

local resetCountBtn = create("TextButton", {

    Size = UDim2.new(0.28,0,0,25),

    Position = UDim2.new(0.67,0,0,425),

    BackgroundColor3 = Color3.fromRGB(60,60,80),

    Text = "RESET",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 0,

    Parent = content
})

create("UICorner", {
    CornerRadius = UDim.new(0,6),
    Parent = resetCountBtn
})

contentScroller.CanvasSize = UDim2.fromOffset(0,465)

-- ============================================================
-- FLOAT BUTTON
-- ============================================================

floatBtn = create("TextButton", {

    Size = UDim2.fromOffset(50,50),

    Position = UDim2.new(1,-65,0.5,-25),

    BackgroundColor3 = Color3.fromRGB(30,30,50),

    Text = "AC",

    TextColor3 = Color3.fromRGB(255,255,255),

    TextScaled = true,

    Font = Enum.Font.GothamBold,

    BorderSizePixel = 2,

    BorderColor3 = Color3.fromRGB(80,120,200),

    Visible = false,

    Active = true,

    Parent = screenGui
})

create("UICorner", {
    CornerRadius = UDim.new(0,25),
    Parent = floatBtn
})

-- ============================================================
-- UPDATE UI
-- ============================================================

updateUI = function()

    if isRunning and isAutoClickOn then

        statusLabel.Text = "● RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,100)

    else

        statusLabel.Text = "● STOPPED"
        statusLabel.TextColor3 = Color3.fromRGB(200,200,200)

    end

    if toggleBtn then

        if isAutoClickOn then

            toggleBtn.Text = "ON"
            toggleBtn.BackgroundColor3 =
                Color3.fromRGB(0,200,80)

        else

            toggleBtn.Text = "OFF"
            toggleBtn.BackgroundColor3 =
                Color3.fromRGB(70,70,90)

        end

    end

    cpsDisplay.Text = "CPS: " .. tostring(currentCPS)

    cpsValueBtn.Text = tostring(currentCPS)

    intervalBtn.Text =
        string.format("%.2fs", currentInterval)

    local tool = getCurrentTool()

    if tool then
        toolLabel.Text = "⚔ " .. tool.Name
    else
        toolLabel.Text = "⚔ None"
    end

    clickCountLabel.Text =
        formatNumber(clickCount)

    if isPositionSet and clickPosition then

        posLabel.Text =
            "✓ X: "
            .. math.floor(clickPosition.X)
            .. "   Y: "
            .. math.floor(clickPosition.Y)

        posLabel.TextColor3 =
            Color3.fromRGB(80,255,130)

    else

        posLabel.Text =
            "X: Not Set   Y: Not Set"

        posLabel.TextColor3 =
            Color3.fromRGB(150,180,220)

    end

    if targetMode == "SINGLE" then

        singleBtn.BackgroundColor3 =
            Color3.fromRGB(100,180,255)

        multiBtn.BackgroundColor3 =
            Color3.fromRGB(60,60,80)

    else

        singleBtn.BackgroundColor3 =
            Color3.fromRGB(60,60,80)

        multiBtn.BackgroundColor3 =
            Color3.fromRGB(100,180,255)

    end

end

-- ============================================================
-- START / STOP
-- ============================================================

local function autoClickLoop()

    while isRunning do

        if isAutoClickOn then

            local tool = getCurrentTool()

            if tool then

                pcall(function()

                    tool:Activate()

                    clickCount += 1

                    if clickCountLabel then
                        clickCountLabel.Text =
                            formatNumber(clickCount)
                    end

                end)

            end

            task.wait(math.max(currentInterval,0.02))

        else

            task.wait(0.1)

        end

    end

end

local function startAutoClick()

    if isRunning then
        return
    end

    isRunning = true
    isAutoClickOn = true

    if loopThread then
        task.cancel(loopThread)
    end

    loopThread =
        task.spawn(autoClickLoop)

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

-- ============================================================
-- MENU OPEN / CLOSE
-- ============================================================

closeMenu = function()

    menuVisible = false

    mainFrame.Visible = false

    floatBtn.Visible = true

end

showMenu = function()

    menuVisible = true

    mainFrame.Visible = true

    floatBtn.Visible = false

    updateUI()

end

-- ============================================================
-- BUTTON EVENTS
-- DÙNG ACTIVATED DUY NHẤT
-- ============================================================

toggleBtn.Activated:Connect(function()

    toggleAutoClick()

end)

closeBtn.Activated:Connect(function()

    closeMenu()

end)

floatBtn.Activated:Connect(function()

    showMenu()

end)

-- ============================================================
-- MINIMIZE
-- ============================================================

minBtn.Activated:Connect(function()

    isMinimized = not isMinimized

    contentScroller.Visible = not isMinimized

    if isMinimized then

        minBtn.Text = "+"

        mainFrame.Size =
            UDim2.fromOffset(menuWidth,42)

    else

        minBtn.Text = "−"

        mainFrame.Size =
            UDim2.fromOffset(menuWidth,menuHeight)

    end

end)

-- ============================================================
-- CPS -
-- ============================================================

cpsMinus.Activated:Connect(function()

    currentCPS =
        math.clamp(currentCPS - 1,1,20)

    currentInterval =
        1 / currentCPS

    updateUI()

end)

-- ============================================================
-- CPS +
-- ============================================================

cpsPlus.Activated:Connect(function()

    currentCPS =
        math.clamp(currentCPS + 1,1,20)

    currentInterval =
        1 / currentCPS

    updateUI()

end)

-- ============================================================
-- CPS VALUE
-- ============================================================

cpsValueBtn.Activated:Connect(function()

    currentCPS += 1

    if currentCPS > 20 then
        currentCPS = 1
    end

    currentInterval =
        1 / currentCPS

    updateUI()

end)

-- ============================================================
-- SLIDER
-- ============================================================

local sliderDragging = false

local function setCPSFromX(x)

    local trackX =
        sliderTrack.AbsolutePosition.X

    local trackWidth =
        sliderTrack.AbsoluteSize.X

    local percent =
        math.clamp(
            (x - trackX) / trackWidth,
            0,
            1
        )

    currentCPS =
        math.clamp(
            round(1 + percent * 19),
            1,
            20
        )

    currentInterval =
        1 / currentCPS

    sliderThumb.Position =
        UDim2.new(
            (currentCPS - 1) / 19,
            -10,
            0.5,
            -10
        )

    updateUI()

end

sliderTrack.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        sliderDragging = true

        setCPSFromX(
            input.Position.X
        )

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if sliderDragging
        and input.UserInputType ==
        Enum.UserInputType.Touch then

        setCPSFromX(
            input.Position.X
        )

    end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        sliderDragging = false

    end

end)

-- ============================================================
-- INTERVAL
-- ============================================================

local intervalOptions = {
    0.05,
    0.10,
    0.20,
    0.50,
    1.00,
    2.00
}

local intervalIndex = 2

intervalBtn.Activated:Connect(function()

    intervalIndex += 1

    if intervalIndex > #intervalOptions then
        intervalIndex = 1
    end

    currentInterval =
        intervalOptions[intervalIndex]

    currentCPS =
        math.clamp(
            round(1 / currentInterval),
            1,
            20
        )

    updateUI()

end)

-- ============================================================
-- TARGET
-- ============================================================

singleBtn.Activated:Connect(function()

    targetMode = "SINGLE"

    updateUI()

end)

multiBtn.Activated:Connect(function()

    targetMode = "MULTI"

    updateUI()

end)

-- ============================================================
-- RESET COUNT
-- ============================================================

resetCountBtn.Activated:Connect(function()

    clickCount = 0

    updateUI()

end)

-- ============================================================
-- MARKER
-- ============================================================

local function removeMarker()

    if markerObject then

        markerObject:Destroy()

        markerObject = nil

    end

end

local function createMarker(x,y)

    removeMarker()

    markerObject = create("Frame", {

        Size = UDim2.fromOffset(52,52),

        Position =
            UDim2.fromOffset(
                x - 26,
                y - 26
            ),

        BackgroundColor3 =
            Color3.fromRGB(0,255,100),

        BackgroundTransparency = 0.25,

        BorderSizePixel = 2,

        BorderColor3 =
            Color3.fromRGB(255,255,255),

        Active = false,

        Parent = screenGui

    })

    create("UICorner", {
        CornerRadius = UDim.new(0,26),
        Parent = markerObject
    })

    create("TextLabel", {

        Size = UDim2.fromScale(1,1),

        BackgroundTransparency = 1,

        Text = "●",

        TextColor3 =
            Color3.fromRGB(255,255,255),

        TextScaled = true,

        Font = Enum.Font.GothamBold,

        Parent = markerObject

    })

end

-- ============================================================
-- SET POSITION
-- ============================================================

local function beginSetPosition()

    if isSettingPosition then
        return
    end

    isSettingPosition = true

    mainFrame.Visible = false

    local overlay = create("Frame", {

        Size = UDim2.fromScale(1,1),

        BackgroundColor3 =
            Color3.fromRGB(0,0,0),

        BackgroundTransparency = 0.45,

        BorderSizePixel = 0,

        Active = true,

        Parent = screenGui

    })

    local instruction = create("TextLabel", {

        Size = UDim2.new(0.8,0,0,55),

        Position =
            UDim2.new(0.1,0,0.42,0),

        BackgroundColor3 =
            Color3.fromRGB(20,20,30),

        BackgroundTransparency = 0.1,

        Text =
            "CHẠM VÀO VỊ TRÍ MUỐN CLICK",

        TextColor3 =
            Color3.fromRGB(255,255,255),

        TextScaled = true,

        Font = Enum.Font.GothamBold,

        BorderSizePixel = 1,

        BorderColor3 =
            Color3.fromRGB(100,180,255),

        Parent = overlay

    })

    create("UICorner", {
        CornerRadius = UDim.new(0,10),
        Parent = instruction
    })

    local connection

    connection =
        UserInputService.InputBegan:Connect(function(input)

            if input.UserInputType ~=
                Enum.UserInputType.Touch then

                return

            end

            local pos =
                input.Position

            clickPosition = {
                X = pos.X,
                Y = pos.Y
            }

            isPositionSet = true
            isSettingPosition = false

            connection:Disconnect()

            overlay:Destroy()

            createMarker(
                pos.X,
                pos.Y
            )

            mainFrame.Visible = true

            updateUI()

        end)

end

setPosBtn.Activated:Connect(
    beginSetPosition
)

-- ============================================================
-- TEST
-- ============================================================

testPosBtn.Activated:Connect(function()

    if not isPositionSet
        or not clickPosition then

        return

    end

    createMarker(
        clickPosition.X,
        clickPosition.Y
    )

    local tool =
        getCurrentTool()

    if tool then

        pcall(function()
            tool:Activate()
        end)

    end

end)

-- ============================================================
-- RESET POSITION
-- ============================================================

resetPosBtn.Activated:Connect(function()

    clickPosition = nil

    isPositionSet = false

    removeMarker()

    updateUI()

end)

-- ============================================================
-- DRAG MENU MOBILE
-- ============================================================

local dragging = false
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart =
            input.Position

        startPosition =
            mainFrame.Position

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    local delta =
        input.Position - dragStart

    local viewport =
        camera.ViewportSize

    local size =
        mainFrame.AbsoluteSize

    local x =
        startPosition.X.Offset + delta.X

    local y =
        startPosition.Y.Offset + delta.Y

    x = math.clamp(
        x,
        0,
        viewport.X - size.X
    )

    y = math.clamp(
        y,
        0,
        viewport.Y - size.Y
    )

    mainFrame.Position =
        UDim2.fromOffset(x,y)

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = false

    end

end)

-- ============================================================
-- DRAG FLOAT BUTTON
-- ============================================================

local floatDragging = false
local floatStart
local floatPosition

floatBtn.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        floatDragging = true

        floatStart =
            input.Position

        floatPosition =
            floatBtn.Position

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not floatDragging then
        return
    end

    if input.UserInputType ~=
        Enum.UserInputType.Touch then

        return

    end

    local delta =
        input.Position - floatStart

    local viewport =
        camera.ViewportSize

    local size =
        floatBtn.AbsoluteSize

    local x =
        floatPosition.X.Offset + delta.X

    local y =
        floatPosition.Y.Offset + delta.Y

    x = math.clamp(
        x,
        0,
        viewport.X - size.X
    )

    y = math.clamp(
        y,
        0,
        viewport.Y - size.Y
    )

    floatBtn.Position =
        UDim2.fromOffset(x,y)

end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        floatDragging = false

    end

end)

-- ============================================================
-- CHARACTER / TOOL UPDATE
-- ============================================================

local function setupCharacter(character)

    character.ChildAdded:Connect(function(child)

        if child:IsA("Tool") then

            updateUI()

        end

    end)

    character.ChildRemoved:Connect(function(child)

        if child:IsA("Tool") then

            updateUI()

        end

    end)

    task.wait(0.2)

    updateUI()

end

if player.Character then

    setupCharacter(
        player.Character
    )

end

player.CharacterAdded:Connect(
    setupCharacter
)

-- ============================================================
-- SCREEN ROTATION
-- ============================================================

camera:GetPropertyChangedSignal(
    "ViewportSize"
):Connect(function()

    if isMinimized then
        return
    end

    menuWidth,menuHeight =
        getMenuSize()

    mainFrame.Size =
        UDim2.fromOffset(
            menuWidth,
            menuHeight
        )

end)

-- ============================================================
-- START
-- ============================================================

updateUI()

print("================================")
print("AUTO CLICKER PRO MOBILE V5.0")
print("FULL MOBILE FIX")
print("================================")
