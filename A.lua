-- ============================================================
-- AUTO CLICKER PRO MOBILE V6.0
-- COMPLETE SCRIPT - UI REDESIGN + FULL FUNCTION
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================================
-- CLEAN OLD GUI
-- ============================================================

local old = playerGui:FindFirstChild("AutoClickerGUI")
if old then
    old:Destroy()
end

-- ============================================================
-- STATE
-- ============================================================

local running = false
local cps = 10
local interval = 0.10
local clicks = 0

local targetMode = "SINGLE"
local clickPosition = nil
local positionSet = false
local marker = nil

local menuVisible = true
local minimized = false
local loopThread = nil

-- ============================================================
-- COLORS
-- ============================================================

local C = {
    bg = Color3.fromRGB(10,11,18),
    panel = Color3.fromRGB(18,19,29),
    card = Color3.fromRGB(24,25,38),
    card2 = Color3.fromRGB(31,32,48),
    text = Color3.fromRGB(245,245,250),
    sub = Color3.fromRGB(145,148,165),
    purple = Color3.fromRGB(145,85,255),
    purple2 = Color3.fromRGB(185,110,255),
    green = Color3.fromRGB(55,220,125),
    red = Color3.fromRGB(235,70,85),
    yellow = Color3.fromRGB(255,205,85),
    blue = Color3.fromRGB(75,165,255),
    stroke = Color3.fromRGB(55,57,78)
}

-- ============================================================
-- HELPERS
-- ============================================================

local function new(class, props, parent)
    local x = Instance.new(class)
    for k,v in pairs(props or {}) do
        x[k] = v
    end
    x.Parent = parent
    return x
end

local function round(obj, radius)
    new("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, obj)
end

local function outline(obj, color, thickness, transparency)
    new("UIStroke", {
        Color = color or C.stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, obj)
end

local function text(parent, value, size, color, font)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = color or C.text,
        Font = font or Enum.Font.Gotham,
        TextSize = size or 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
end

local function fmt(n)
    if n >= 1000000 then
        return string.format("%.1fM", n/1000000)
    elseif n >= 1000 then
        return string.format("%.1fK", n/1000)
    end
    return tostring(n)
end

local function getTool()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildWhichIsA("Tool")
end

-- ============================================================
-- GUI
-- ============================================================

local gui = new("ScreenGui", {
    Name = "AutoClickerGUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

-- ============================================================
-- RESPONSIVE SIZE
-- ============================================================

local function menuSize()
    local v = camera.ViewportSize
    if v.X > v.Y then
        return math.min(340, v.X*0.42), math.min(410, v.Y*0.82)
    end
    return math.min(330, v.X*0.86), math.min(500, v.Y*0.76)
end

local mw,mh = menuSize()

local main = new("Frame", {
    Size = UDim2.fromOffset(mw,mh),
    Position = UDim2.new(0.5,-mw/2,0.5,-mh/2),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Active = true
}, gui)
round(main,16)
outline(main,C.purple,1,0.45)

-- ============================================================
-- HEADER
-- ============================================================

local header = new("Frame", {
    Size = UDim2.new(1,0,0,54),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Active = true
}, main)
round(header,16)

local logo = new("TextLabel", {
    Size = UDim2.fromOffset(34,34),
    Position = UDim2.fromOffset(10,10),
    BackgroundColor3 = C.purple,
    Text = "⚡",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 18
}, header)
round(logo,10)

local title = text(header,"AUTO CLICKER",14,C.text,Enum.Font.GothamBold)
title.Size = UDim2.new(1,-135,0,20)
title.Position = UDim2.fromOffset(52,7)

local sub = text(header,"PRO  •  MOBILE",9,C.sub,Enum.Font.GothamMedium)
sub.Size = UDim2.new(1,-135,0,14)
sub.Position = UDim2.fromOffset(53,28)

local minBtn = new("TextButton", {
    Size = UDim2.fromOffset(30,30),
    Position = UDim2.new(1,-70,0,12),
    BackgroundColor3 = C.card2,
    Text = "−",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, header)
round(minBtn,8)
outline(minBtn)

local closeBtn = new("TextButton", {
    Size = UDim2.fromOffset(30,30),
    Position = UDim2.new(1,-36,0,12),
    BackgroundColor3 = Color3.fromRGB(55,25,38),
    Text = "×",
    TextColor3 = C.red,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, header)
round(closeBtn,8)

-- ============================================================
-- SCROLLER
-- ============================================================

local scroll = new("ScrollingFrame", {
    Size = UDim2.new(1,-14,1,-62),
    Position = UDim2.fromOffset(7,58),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.purple,
    CanvasSize = UDim2.fromOffset(0,650)
}, main)

local content = new("Frame", {
    Size = UDim2.new(1,-4,0,650),
    BackgroundTransparency = 1
}, scroll)

-- ============================================================
-- STATUS
-- ============================================================

local status = new("TextLabel", {
    Size = UDim2.new(1,0,0,30),
    Position = UDim2.fromOffset(0,0),
    BackgroundColor3 = C.card,
    Text = "●  STOPPED",
    TextColor3 = C.sub,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    TextXAlignment = Enum.TextXAlignment.Center
}, content)
round(status,9)
outline(status)

-- ============================================================
-- AUTO CLICK ROW
-- ============================================================

local autoCard = new("Frame", {
    Size = UDim2.new(1,0,0,48),
    Position = UDim2.fromOffset(0,38),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0
}, content)
round(autoCard,10)
outline(autoCard)

local autoText = text(autoCard,"AUTO CLICK",13,C.text,Enum.Font.GothamBold)
autoText.Size = UDim2.new(1,-100,1,0)
autoText.Position = UDim2.fromOffset(13,0)

local toggle = new("TextButton", {
    Size = UDim2.fromOffset(72,30),
    Position = UDim2.new(1,-82,0.5,-15),
    BackgroundColor3 = C.card2,
    Text = "OFF",
    TextColor3 = C.sub,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, autoCard)
round(toggle,9)
outline(toggle)

-- ============================================================
-- SECTION LABEL
-- ============================================================

local speedLabel = text(content,"CLICK SPEED",10,C.sub,Enum.Font.GothamBold)
speedLabel.Size = UDim2.new(1,0,0,18)
speedLabel.Position = UDim2.fromOffset(2,94)

-- ============================================================
-- CPS CARD
-- ============================================================

local cpsCard = new("Frame", {
    Size = UDim2.new(1,0,0,58),
    Position = UDim2.fromOffset(0,116),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0
}, content)
round(cpsCard,10)
outline(cpsCard)

local cpsDisplay = text(cpsCard,"⚡ 10 CPS",18,C.purple2,Enum.Font.GothamBold)
cpsDisplay.Size = UDim2.new(1,0,0,28)
cpsDisplay.Position = UDim2.fromOffset(0,5)
cpsDisplay.TextXAlignment = Enum.TextXAlignment.Center

local minus = new("TextButton", {
    Size = UDim2.fromOffset(32,28),
    Position = UDim2.new(0.5,-72,0,28),
    BackgroundColor3 = C.card2,
    Text = "−",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, cpsCard)
round(minus,7)

local cpsValue = new("TextButton", {
    Size = UDim2.fromOffset(42,28),
    Position = UDim2.new(0.5,-21,0,28),
    BackgroundColor3 = C.purple,
    Text = "10",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, cpsCard)
round(cpsValue,7)

local plus = new("TextButton", {
    Size = UDim2.fromOffset(32,28),
    Position = UDim2.new(0.5,40,0,28),
    BackgroundColor3 = C.card2,
    Text = "+",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, cpsCard)
round(plus,7)

-- ============================================================
-- SLIDER
-- ============================================================

local slider = new("Frame", {
    Size = UDim2.new(1,-24,0,6),
    Position = UDim2.fromOffset(12,184),
    BackgroundColor3 = Color3.fromRGB(48,49,65),
    BorderSizePixel = 0,
    Active = true
}, content)
round(slider,5)

local thumb = new("Frame", {
    Size = UDim2.fromOffset(20,20),
    Position = UDim2.new((cps-1)/19,-10,0.5,-10),
    BackgroundColor3 = C.purple2,
    BorderSizePixel = 0
}, slider)
round(thumb,10)
outline(thumb,C.purple,2,0.2)

-- ============================================================
-- INTERVAL
-- ============================================================

local intervalTitle = text(content,"INTERVAL",10,C.sub,Enum.Font.GothamBold)
intervalTitle.Size = UDim2.new(1,0,0,18)
intervalTitle.Position = UDim2.fromOffset(2,199)

local intervalBtn = new("TextButton", {
    Size = UDim2.fromOffset(100,32),
    Position = UDim2.new(0.5,-50,0,219),
    BackgroundColor3 = C.card2,
    Text = "0.10s",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(intervalBtn,8)
outline(intervalBtn)

-- ============================================================
-- TARGET
-- ============================================================

local targetTitle = text(content,"TARGET MODE",10,C.sub,Enum.Font.GothamBold)
targetTitle.Size = UDim2.new(1,0,0,18)
targetTitle.Position = UDim2.fromOffset(2,258)

local single = new("TextButton", {
    Size = UDim2.new(0.47,0,0,34),
    Position = UDim2.new(0.01,0,0,280),
    BackgroundColor3 = C.purple,
    Text = "SINGLE",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(single,8)

local multi = new("TextButton", {
    Size = UDim2.new(0.47,0,0,34),
    Position = UDim2.new(0.52,0,0,280),
    BackgroundColor3 = C.card2,
    Text = "MULTI",
    TextColor3 = C.sub,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(multi,8)

-- ============================================================
-- TOOL
-- ============================================================

local toolTitle = text(content,"CURRENT TOOL",10,C.sub,Enum.Font.GothamBold)
toolTitle.Size = UDim2.new(1,0,0,18)
toolTitle.Position = UDim2.fromOffset(2,324)

local toolLabel = new("TextLabel", {
    Size = UDim2.new(1,0,0,34),
    Position = UDim2.fromOffset(0,345),
    BackgroundColor3 = C.card,
    Text = "⚔  None",
    TextColor3 = C.yellow,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    TextXAlignment = Enum.TextXAlignment.Center
}, content)
round(toolLabel,9)
outline(toolLabel)

-- ============================================================
-- POSITION
-- ============================================================

local posTitle = text(content,"CLICK POSITION",10,C.sub,Enum.Font.GothamBold)
posTitle.Size = UDim2.new(1,0,0,18)
posTitle.Position = UDim2.fromOffset(2,388)

local posLabel = new("TextLabel", {
    Size = UDim2.new(1,0,0,32),
    Position = UDim2.fromOffset(0,409),
    BackgroundColor3 = C.card,
    Text = "X: Not Set   •   Y: Not Set",
    TextColor3 = C.sub,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    BorderSizePixel = 0,
    TextXAlignment = Enum.TextXAlignment.Center
}, content)
round(posLabel,9)
outline(posLabel)

local setPos = new("TextButton", {
    Size = UDim2.new(0.31,0,0,32),
    Position = UDim2.new(0.01,0,0,449),
    BackgroundColor3 = C.purple,
    Text = "SET",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(setPos,8)

local testPos = new("TextButton", {
    Size = UDim2.new(0.31,0,0,32),
    Position = UDim2.new(0.345,0,0,449),
    BackgroundColor3 = C.card2,
    Text = "TEST",
    TextColor3 = C.blue,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(testPos,8)

local resetPos = new("TextButton", {
    Size = UDim2.new(0.31,0,0,32),
    Position = UDim2.new(0.68,0,0,449),
    BackgroundColor3 = Color3.fromRGB(55,35,45),
    Text = "RESET",
    TextColor3 = C.red,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(resetPos,8)

-- ============================================================
-- COUNTER
-- ============================================================

local countTitle = text(content,"TOTAL CLICKS",10,C.sub,Enum.Font.GothamBold)
countTitle.Size = UDim2.new(1,0,0,18)
countTitle.Position = UDim2.fromOffset(2,490)

local countLabel = new("TextLabel", {
    Size = UDim2.new(0.64,0,0,42),
    Position = UDim2.fromOffset(0,511),
    BackgroundColor3 = C.card,
    Text = "0",
    TextColor3 = C.purple2,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    BorderSizePixel = 0,
    TextXAlignment = Enum.TextXAlignment.Center
}, content)
round(countLabel,9)
outline(countLabel)

local resetCount = new("TextButton", {
    Size = UDim2.new(0.32,0,0,42),
    Position = UDim2.new(0.67,0,0,511),
    BackgroundColor3 = C.card2,
    Text = "RESET",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    BorderSizePixel = 0,
    AutoButtonColor = false
}, content)
round(resetCount,9)

-- ============================================================
-- FLOAT BUTTON
-- ============================================================

local float = new("TextButton", {
    Size = UDim2.fromOffset(54,54),
    Position = UDim2.new(1,-70,0.5,-27),
    BackgroundColor3 = C.bg,
    Text = "⚡",
    TextColor3 = C.purple2,
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
    AutoButtonColor = false
}, gui)
round(float,27)
outline(float,C.purple2,2,0.15)

-- ============================================================
-- UPDATE UI
-- ============================================================

local function update()
    if running then
        status.Text = "●  RUNNING"
        status.TextColor3 = C.green
        toggle.Text = "ON"
        toggle.BackgroundColor3 = C.green
        toggle.TextColor3 = Color3.new(1,1,1)
    else
        status.Text = "●  STOPPED"
        status.TextColor3 = C.sub
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = C.card2
        toggle.TextColor3 = C.sub
    end

    cpsDisplay.Text = "⚡ "..cps.." CPS"
    cpsValue.Text = tostring(cps)
    intervalBtn.Text = string.format("%.2fs",interval)
    countLabel.Text = fmt(clicks)

    local tool = getTool()
    toolLabel.Text = tool and ("⚔  "..tool.Name) or "⚔  None"

    if positionSet and clickPosition then
        posLabel.Text = "✓  X: "..math.floor(clickPosition.X).."   •   Y: "..math.floor(clickPosition.Y)
        posLabel.TextColor3 = C.green
    else
        posLabel.Text = "X: Not Set   •   Y: Not Set"
        posLabel.TextColor3 = C.sub
    end

    if targetMode == "SINGLE" then
        single.BackgroundColor3 = C.purple
        single.TextColor3 = Color3.new(1,1,1)
        multi.BackgroundColor3 = C.card2
        multi.TextColor3 = C.sub
    else
        single.BackgroundColor3 = C.card2
        single.TextColor3 = C.sub
        multi.BackgroundColor3 = C.purple
        multi.TextColor3 = Color3.new(1,1,1)
    end

    thumb.Position = UDim2.new((cps-1)/19,-10,0.5,-10)
end

-- ============================================================
-- AUTO CLICK
-- ============================================================

local function stop()
    running = false
    if loopThread then
        task.cancel(loopThread)
        loopThread = nil
    end
    update()
end

local function start()
    if running then return end

    running = true

    loopThread = task.spawn(function()
        while running do
            local tool = getTool()

            if tool then
                pcall(function()
                    tool:Activate()
                    clicks += 1
                end)
                countLabel.Text = fmt(clicks)
            end

            task.wait(math.max(interval,0.02))
        end
    end)

    update()
end

toggle.Activated:Connect(function()
    if running then
        stop()
    else
        start()
    end
end)

-- ============================================================
-- CPS
-- ============================================================

local function setCPS(value)
    cps = math.clamp(math.floor(value + 0.5),1,20)
    interval = 1/cps
    update()
end

minus.Activated:Connect(function()
    setCPS(cps-1)
end)

plus.Activated:Connect(function()
    setCPS(cps+1)
end)

cpsValue.Activated:Connect(function()
    setCPS(cps >= 20 and 1 or cps+1)
end)

-- ============================================================
-- SLIDER
-- ============================================================

local sliderDrag = false

local function sliderSet(x)
    local sx = slider.AbsolutePosition.X
    local sw = slider.AbsoluteSize.X
    local p = math.clamp((x-sx)/sw,0,1)
    setCPS(1+p*19)
end

slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDrag = true
        sliderSet(input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDrag and input.UserInputType == Enum.UserInputType.Touch then
        sliderSet(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        sliderDrag = false
    end
end)

-- ============================================================
-- INTERVAL
-- ============================================================

local intervals = {0.05,0.10,0.20,0.50,1.00,2.00}
local intervalIndex = 2

intervalBtn.Activated:Connect(function()
    intervalIndex = intervalIndex + 1
    if intervalIndex > #intervals then intervalIndex = 1 end

    interval = intervals[intervalIndex]
    cps = math.clamp(math.floor(1/interval+0.5),1,20)
    update()
end)

-- ============================================================
-- TARGET
-- ============================================================

single.Activated:Connect(function()
    targetMode = "SINGLE"
    update()
end)

multi.Activated:Connect(function()
    targetMode = "MULTI"
    update()
end)

-- ============================================================
-- COUNTER RESET
-- ============================================================

resetCount.Activated:Connect(function()
    clicks = 0
    update()
end)

-- ============================================================
-- MARKER
-- ============================================================

local function removeMarker()
    if marker then
        marker:Destroy()
        marker = nil
    end
end

local function makeMarker(x,y)
    removeMarker()

    marker = new("Frame", {
        Size = UDim2.fromOffset(50,50),
        Position = UDim2.fromOffset(x-25,y-25),
        BackgroundColor3 = C.green,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 2,
        BorderColor3 = Color3.new(1,1,1),
        ZIndex = 20
    }, gui)
    round(marker,25)

    new("TextLabel", {
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Text = "●",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        ZIndex = 21
    }, marker)
end

-- ============================================================
-- SET POSITION
-- ============================================================

setPos.Activated:Connect(function()
    main.Visible = false

    local overlay = new("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.42,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 50
    }, gui)

    local hint = new("TextLabel", {
        Size = UDim2.new(0.82,0,0,54),
        Position = UDim2.new(0.09,0,0.43,0),
        BackgroundColor3 = C.panel,
        Text = "CHẠM VÀO VỊ TRÍ MUỐN CLICK",
        TextColor3 = C.text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        BorderSizePixel = 0,
        ZIndex = 51
    }, overlay)
    round(hint,11)
    outline(hint,C.purple,1)

    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        clickPosition = {
            X = input.Position.X,
            Y = input.Position.Y
        }
        positionSet = true

        connection:Disconnect()
        overlay:Destroy()
        makeMarker(clickPosition.X,clickPosition.Y)

        main.Visible = true
        update()
    end)
end)

-- ============================================================
-- TEST POSITION
-- ============================================================

testPos.Activated:Connect(function()
    if not positionSet or not clickPosition then return end

    makeMarker(clickPosition.X,clickPosition.Y)

    local tool = getTool()
    if tool then
        pcall(function()
            tool:Activate()
        end)
    end
end)

resetPos.Activated:Connect(function()
    clickPosition = nil
    positionSet = false
    removeMarker()
    update()
end)

-- ============================================================
-- CLOSE / FLOAT
-- ============================================================

closeBtn.Activated:Connect(function()
    menuVisible = false
    main.Visible = false
    float.Visible = true
end)

float.Activated:Connect(function()
    menuVisible = true
    main.Visible = true
    float.Visible = false
end)

-- ============================================================
-- MINIMIZE
-- ============================================================

minBtn.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        scroll.Visible = false
        minBtn.Text = "+"
        main.Size = UDim2.fromOffset(mw,54)
    else
        scroll.Visible = true
        minBtn.Text = "−"
        main.Size = UDim2.fromOffset(mw,mh)
    end
end)

-- ============================================================
-- DRAG MENU
-- ============================================================

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end

    local delta = input.Position-dragStart
    local viewport = camera.ViewportSize
    local size = main.AbsoluteSize

    local x = math.clamp(startPos.X.Offset+delta.X,0,viewport.X-size.X)
    local y = math.clamp(startPos.Y.Offset+delta.Y,0,viewport.Y-size.Y)

    main.Position = UDim2.fromOffset(x,y)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- DRAG FLOAT
-- ============================================================

local floatDrag = false
local floatStart
local floatPos

float.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        floatDrag = true
        floatStart = input.Position
        floatPos = float.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not floatDrag then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end

    local delta = input.Position-floatStart
    local viewport = camera.ViewportSize
    local size = float.AbsoluteSize

    local x = math.clamp(floatPos.X.Offset+delta.X,0,viewport.X-size.X)
    local y = math.clamp(floatPos.Y.Offset+delta.Y,0,viewport.Y-size.Y)

    float.Position = UDim2.fromOffset(x,y)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        floatDrag = false
    end
end)

-- ============================================================
-- CHARACTER / TOOL UPDATE
-- ============================================================

local function setupCharacter(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            update()
        end
    end)

    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            update()
        end
    end)

    task.delay(0.2,update)
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- ============================================================
-- VIEWPORT
-- ============================================================

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if minimized then return end

    mw,mh = menuSize()
    main.Size = UDim2.fromOffset(mw,mh)

    local v = camera.ViewportSize
    if v.X > v.Y then
        main.Position = UDim2.new(0.5,-mw/2,0.5,-mh/2)
    end
end)

-- ============================================================
-- START
-- ============================================================

update()

print("AUTO CLICKER PRO MOBILE V6.0 LOADED")
