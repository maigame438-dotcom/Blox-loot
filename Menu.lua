-- =====================================================================
-- ULTIMATE FLUID UI - REWRITTEN FROM SCRATCH
-- Support: PC & Mobile | 60FPS Smooth Tweening | Full Themes
-- =====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TargetParent = (RunService:IsStudio()) and PlayerGui or (gethui and gethui()) or CoreGui

if TargetParent:FindFirstChild("UltimateFluidUI_Rewrite") then
    TargetParent.UltimateFluidUI_Rewrite:Destroy()
end

-- =====================================================================
-- 1. SCREEN GUI SETUP (Tối ưu hiển thị toàn màn hình)
-- =====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateFluidUI_Rewrite"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Đảm bảo che kín 100% không hở viền
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- Hệ thống quản lý Theme động
local ThemeObjects = {
    Backgrounds = {},
    Accents = {},
    Texts = {},
    Strokes = {},
    Gradients = {}
}

local CurrentTheme = "Blue"
local IsRainbow = false
local IsSecret = false
local ScriptVersion = "v2.0.0 (Rewrite)"

-- =====================================================================
-- 2. CORE COMPONENTS: BLACK SCREEN, FPS COUNTER, NÚT NỔI
-- =====================================================================

-- [BLACK SCREEN] (ZIndex = 1)
local BlackScreen = Instance.new("Frame")
BlackScreen.Name = "BlackScreen"
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreen.ZIndex = 1
BlackScreen.Visible = false
BlackScreen.Parent = ScreenGui

-- [FPS COUNTER] (ZIndex = 100)
local FPSCounter = Instance.new("TextLabel")
FPSCounter.Name = "FPSCounter"
FPSCounter.Size = UDim2.new(0, 100, 0, 30)
FPSCounter.Position = UDim2.new(0.5, -50, 0, 10)
FPSCounter.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FPSCounter.Text = "FPS: ..."
FPSCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSCounter.Font = Enum.Font.GothamBold
FPSCounter.TextSize = 14
FPSCounter.Visible = false
FPSCounter.ZIndex = 100
FPSCounter.Parent = ScreenGui
Instance.new("UICorner", FPSCounter).CornerRadius = UDim.new(0, 6)
local FPSStroke = Instance.new("UIStroke", FPSCounter)
FPSStroke.Thickness = 1.5
table.insert(ThemeObjects.Accents, FPSStroke)

-- [NÚT NỔI - FLOATING BUTTON] (ZIndex = 100, Kích thước 55x55)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingButton"
FloatingBtn.Size = UDim2.new(0, 55, 0, 55)
FloatingBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Text = "⋯"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 24
FloatingBtn.AutoButtonColor = false
FloatingBtn.ZIndex = 100
FloatingBtn.Parent = ScreenGui

Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Thickness = 2
table.insert(ThemeObjects.Accents, FloatStroke)
table.insert(ThemeObjects.Accents, FloatingBtn)

-- =====================================================================
-- 3. HỆ THỐNG ANIMATION & TƯƠNG TÁC (RIPPLE, DRAG)
-- =====================================================================

local function CreateRipple(parent, x, y)
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.6
    ripple.ZIndex = parent.ZIndex + 1
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    ripple.Parent = parent
    
    local isRelative = (x and y)
    local posX = isRelative and (x - parent.AbsolutePosition.X) or (parent.AbsoluteSize.X / 2)
    local posY = isRelative and (y - parent.AbsolutePosition.Y) or (parent.AbsoluteSize.Y / 2)
    
    ripple.Position = UDim2.new(0, posX, 0, posY)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    local tween = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, posX - maxSize/2, 0, posY - maxSize/2),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() ripple:Destroy() end)
end

local function MakeDraggable(guiObject, clickCallback)
    local dragging, dragInput, dragStart, startPos
    local clickThreshold = 5
    
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if clickCallback and (input.Position - dragStart).Magnitude <= clickThreshold then
                        clickCallback(input.Position.X, input.Position.Y)
                    end
                end
            end)
        end
    end)
    
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local viewport = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, viewport.X - guiObject.AbsoluteSize.X)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, viewport.Y - guiObject.AbsoluteSize.Y)
            TweenService:Create(guiObject, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0, newX, 0, newY)
            }):Play()
        end
    end)
end

-- =====================================================================
-- 4. MAIN MENU & TAB SYSTEM
-- =====================================================================

local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 450, 0, 300)
MainMenu.Position = UDim2.new(0.5, -225, 0.5, -150)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.ClipsDescendants = true
MainMenu.ZIndex = 10
MainMenu.Visible = false
MainMenu.Parent = ScreenGui
Instance.new("UICorner", MainMenu).CornerRadius = UDim.new(0, 10)
local MenuStroke = Instance.new("UIStroke", MainMenu)
table.insert(ThemeObjects.Accents, MenuStroke)
table.insert(ThemeObjects.Backgrounds, MainMenu)

local MenuScale = Instance.new("UIScale", MainMenu)
MenuScale.Scale = 0.8

-- Thanh Header & Nút X (Đóng UI)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundTransparency = 1
Header.ZIndex = 11
Header.Parent = MainMenu
MakeDraggable(Header) -- Cho phép kéo menu bằng Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FLUID UI - MAIN MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Header
table.insert(ThemeObjects.Texts, Title)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.ClipsDescendants = true

-- Khung Tab (Trái) & Nội dung (Phải)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = MainMenu

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -120, 1, -35)
ContentContainer.Position = UDim2.new(0, 120, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 11
ContentContainer.Parent = MainMenu

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 5)
TabList.Parent = Sidebar
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

-- =====================================================================
-- 5. ĐIỀU KHIỂN TOGGLE MENU
-- =====================================================================
local MenuVisible = false
local IsAnimating = false

local function ToggleMenu()
    if IsAnimating then return end
    IsAnimating = true
    MenuVisible = not MenuVisible
    if MenuVisible then
        MainMenu.Visible = true
        MenuScale.Scale = 0.8
        TweenService:Create(MenuScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        local tween = TweenService:Create(MainMenu, TweenInfo.new(0.2), {BackgroundTransparency = 0})
        tween:Play()
        tween.Completed:Connect(function() IsAnimating = false end)
    else
        TweenService:Create(MenuScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.9}):Play()
        local tween = TweenService:Create(MainMenu, TweenInfo.new(0.2), {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            MainMenu.Visible = false
            IsAnimating = false
        end)
    end
end

MakeDraggable(FloatingBtn, function(x, y)
    CreateRipple(FloatingBtn, x, y)
    ToggleMenu()
end)

CloseBtn.MouseButton1Click:Connect(function()
    CreateRipple(CloseBtn)
    if MenuVisible then ToggleMenu() end
end)

-- =====================================================================
-- 6. UI LIBRARY ENGINE (Tạo Tab, Button, Toggle động)
-- =====================================================================
local Library = { Tabs = {} }
local FirstTab = true

function Library:CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    TabBtn.ZIndex = 12
    TabBtn.Parent = Sidebar
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 20)
    Indicator.Position = UDim2.new(0, 0, 0.5, -10)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BackgroundTransparency = FirstTab and 0 or 1
    Indicator.ZIndex = 12
    Indicator.Parent = TabBtn
    table.insert(ThemeObjects.Accents, Indicator)
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.Visible = FirstTab
    Page.ZIndex = 12
    Page.Parent = ContentContainer
    
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Page
    
    table.insert(self.Tabs, {Btn = TabBtn, Page = Page, Indicator = Indicator})
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = (t.Page == Page)
            TweenService:Create(t.Indicator, TweenInfo.new(0.2), {BackgroundTransparency = (t.Page == Page) and 0 or 1}):Play()
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = (t.Page == Page) and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)}):Play()
        end
    end)
    FirstTab = false
    
    local Elements = {}
    
    function Elements:CreateToggle(text, callback)
        local state = false
        local TglFrame = Instance.new("TextButton")
        TglFrame.Size = UDim2.new(1, 0, 0, 40)
        TglFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TglFrame.Text = ""
        TglFrame.AutoButtonColor = false
        TglFrame.ClipsDescendants = true
        TglFrame.ZIndex = 13
        TglFrame.Parent = Page
        Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)
        
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -60, 1, 0)
        Lbl.Position = UDim2.new(0, 10, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 14
        Lbl.Parent = TglFrame
        
        local CheckBg = Instance.new("Frame")
        CheckBg.Size = UDim2.new(0, 40, 0, 20)
        CheckBg.Position = UDim2.new(1, -50, 0.5, -10)
        CheckBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        CheckBg.ZIndex = 14
        CheckBg.Parent = TglFrame
        Instance.new("UICorner", CheckBg).CornerRadius = UDim.new(1, 0)
        
        local CheckCircle = Instance.new("Frame")
        CheckCircle.Size = UDim2.new(0, 16, 0, 16)
        CheckCircle.Position = UDim2.new(0, 2, 0.5, -8)
        CheckCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        CheckCircle.ZIndex = 15
        CheckCircle.Parent = CheckBg
        Instance.new("UICorner", CheckCircle).CornerRadius = UDim.new(1, 0)
        
        TglFrame.MouseButton1Click:Connect(function(x, y)
            CreateRipple(TglFrame, x, y)
            state = not state
            local posX = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            TweenService:Create(CheckCircle, TweenInfo.new(0.2), {Position = posX}):Play()
            
            if state then
                -- Đổi màu background toggle thành Accent Color thay vì fixed color
                table.insert(ThemeObjects.Accents, CheckBg)
            else
                for i, v in ipairs(ThemeObjects.Accents) do
                    if v == CheckBg then table.remove(ThemeObjects.Accents, i) end
                end
                TweenService:Create(CheckBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end
            
            if callback then callback(state) end
        end)
    end
    
    function Elements:CreateButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 13
        Btn.AutoButtonColor = false
        Btn.ClipsDescendants = true
        Btn.ZIndex = 13
        Btn.Parent = Page
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        
        local Stroke = Instance.new("UIStroke", Btn)
        Stroke.Color = Color3.fromRGB(50, 50, 50)
        
        Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play() end)
        Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() end)
        
        Btn.MouseButton1Click:Connect(function(x, y)
            CreateRipple(Btn, x, y)
            if callback then callback() end
        end)
    end
    
    function Elements:CreateLabel(text)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 0, 30)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.ZIndex = 13
        Lbl.Parent = Page
        
        -- Return function để update text (Dành cho Info tab)
        return function(newText) Lbl.Text = newText end
    end
    
    return Elements
end

-- =====================================================================
-- 7. THEME & FPS MANAGER
-- =====================================================================

local ColorsList = {
    ["Black"] = Color3.fromRGB(40, 40, 40),
    ["White"] = Color3.fromRGB(240, 240, 240),
    ["Gray"] = Color3.fromRGB(120, 120, 120),
    ["Blue"] = Color3.fromRGB(0, 150, 255),
    ["Dark Blue"] = Color3.fromRGB(0, 50, 200),
    ["Red"] = Color3.fromRGB(255, 50, 50),
    ["Dark Red"] = Color3.fromRGB(150, 0, 0),
    ["Green"] = Color3.fromRGB(0, 255, 100),
    ["Lime"] = Color3.fromRGB(150, 255, 50),
    ["Yellow"] = Color3.fromRGB(255, 200, 0),
    ["Orange"] = Color3.fromRGB(255, 120, 0),
    ["Purple"] = Color3.fromRGB(150, 50, 255),
    ["Pink"] = Color3.fromRGB(255, 100, 200),
    ["Cyan"] = Color3.fromRGB(0, 200, 255)
}

local function UpdateTheme(color3)
    for _, obj in ipairs(ThemeObjects.Accents) do
        if obj:IsA("UIStroke") then
            TweenService:Create(obj, TweenInfo.new(0.3), {Color = color3}):Play()
        elseif obj:IsA("GuiObject") then
            TweenService:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color3}):Play()
        end
    end
    for _, obj in ipairs(ThemeObjects.Texts) do
        TweenService:Create(obj, TweenInfo.new(0.3), {TextColor3 = color3}):Play()
    end
end

-- Vòng lặp cập nhật FPS và Theme Động (Rainbow/Secret)
local frames = 0
local lastUpdate = tick()
local InfoThemeUpdate, InfoFPSUpdate

RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1
    local currentTime = tick()
    
    -- Cập nhật màu động
    if IsRainbow or IsSecret then
        local hue = currentTime % 5 / 5
        local rgb = Color3.fromHSV(hue, 1, 1)
        UpdateTheme(rgb)
        if InfoThemeUpdate then InfoThemeUpdate("Current Theme: " .. (IsSecret and "Secret" or "Rainbow")) end
    end
    
    -- FPS Logic (1 lần/giây)
    if currentTime - lastUpdate >= 1 then
        local fps = math.floor(frames / (currentTime - lastUpdate))
        frames = 0
        lastUpdate = currentTime
        
        FPSCounter.Text = "FPS : " .. tostring(fps)
        if InfoFPSUpdate then InfoFPSUpdate("Current FPS: " .. tostring(fps)) end
        
        local fpsColor
        if fps > 300 then
            fpsColor = Color3.fromHSV(currentTime % 2 / 2, 1, 1)
        elseif fps >= 31 then
            fpsColor = Color3.fromRGB(50, 255, 50) -- Xanh lá
        elseif fps >= 11 then
            fpsColor = Color3.fromRGB(255, 255, 50) -- Vàng
        else
            fpsColor = Color3.fromRGB(255, 50, 50) -- Đỏ
        end
        FPSCounter.TextColor3 = fpsColor
    end
end)

-- =====================================================================
-- 8. KHỞI TẠO NỘI DUNG TABS
-- =====================================================================

local TabMain = Library:CreateTab("Main")
local TabTheme = Library:CreateTab("Theme")
local TabInfo = Library:CreateTab("Info")

-- [TAB 1: MAIN]
local HiddenGUIs = {}

TabMain:CreateToggle("Black Screen", function(state)
    BlackScreen.Visible = state
end)

TabMain:CreateToggle("Hide All GUI", function(state)
    if state then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "UltimateFluidUI_Rewrite" and gui.Enabled then
                HiddenGUIs[gui] = true
                gui.Enabled = false
            end
        end
    else
        for gui, _ in pairs(HiddenGUIs) do
            if gui and gui.Parent then gui.Enabled = true end
        end
        table.clear(HiddenGUIs)
    end
end)

TabMain:CreateToggle("FPS Counter", function(state)
    FPSCounter.Visible = state
end)

TabMain:CreateButton("Destroy GUI", function()
    for gui, _ in pairs(HiddenGUIs) do
        if gui and gui.Parent then gui.Enabled = true end
    end
    ScreenGui:Destroy()
end)

-- [TAB 2: THEME]
local ThemeList = {
    "Black", "White", "Gray", "Blue", "Dark Blue", "Red", "Dark Red", 
    "Green", "Lime", "Yellow", "Orange", "Purple", "Pink", "Cyan", 
    "Rainbow", "Secret"
}

for _, tName in ipairs(ThemeList) do
    TabTheme:CreateButton("Apply Theme: " .. tName, function()
        IsRainbow = (tName == "Rainbow")
        IsSecret = (tName == "Secret")
        
        if not IsRainbow and not IsSecret then
            CurrentTheme = tName
            UpdateTheme(ColorsList[tName])
            if InfoThemeUpdate then InfoThemeUpdate("Current Theme: " .. tName) end
        end
        
        -- Hiệu ứng Glow/Gradient đặc biệt cho Secret
        if IsSecret then
            MenuStroke.Thickness = 3
        else
            MenuStroke.Thickness = 1
        end
    end)
end

-- [TAB 3: INFO]
TabInfo:CreateLabel("Script Name: FLUID UI REWRITE")
TabInfo:CreateLabel("Version: " .. ScriptVersion)
InfoFPSUpdate = TabInfo:CreateLabel("Current FPS: Calculating...")
InfoThemeUpdate = TabInfo:CreateLabel("Current Theme: " .. CurrentTheme)
TabInfo:CreateLabel("Status: Premium - Undetected")

-- Khởi chạy Theme mặc định
UpdateTheme(ColorsList["Blue"])
ToggleMenu() -- Tự động mở menu lần đầu
