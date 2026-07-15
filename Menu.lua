-- =====================================================================
-- FULLUID ƯU - MAIN MENU (REMASTERED)
-- Tối ưu: PC & Mobile | Dynamic Themes | 60FPS Smooth
-- =====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TargetParent = (RunService:IsStudio()) and PlayerGui or (gethui and gethui()) or CoreGui

if TargetParent:FindFirstChild("FulluidMainMenu") then
    TargetParent.FulluidMainMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FulluidMainMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Đảm bảo che kín 100% màn hình
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- =====================================================================
-- THEME & STATE MANAGEMENT
-- =====================================================================
local Colors = {
    Black = Color3.fromRGB(20, 20, 20), White = Color3.fromRGB(240, 240, 240),
    Gray = Color3.fromRGB(100, 100, 100), Blue = Color3.fromRGB(0, 120, 255),
    DarkBlue = Color3.fromRGB(0, 50, 150), Red = Color3.fromRGB(255, 50, 50),
    DarkRed = Color3.fromRGB(150, 0, 0), Green = Color3.fromRGB(0, 255, 100),
    Lime = Color3.fromRGB(150, 255, 50), Yellow = Color3.fromRGB(255, 220, 0),
    Orange = Color3.fromRGB(255, 120, 0), Purple = Color3.fromRGB(150, 50, 255),
    Pink = Color3.fromRGB(255, 100, 200), Cyan = Color3.fromRGB(0, 200, 255)
}

local ThemeObjects = { Accents = {}, Texts = {}, Gradients = {} }
local CurrentTheme = "Green"
local IsRainbow = false
local IsSecret = false
local ActiveColor = Colors.Green

local function UpdateTheme(color)
    ActiveColor = color
    for _, obj in ipairs(ThemeObjects.Accents) do
        if obj:IsA("UIStroke") then
            TweenService:Create(obj, TweenInfo.new(0.2), {Color = color}):Play()
        elseif obj:IsA("GuiObject") then
            TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end
    end
    for _, obj in ipairs(ThemeObjects.Texts) do
        TweenService:Create(obj, TweenInfo.new(0.2), {TextColor3 = color}):Play()
    end
end

-- =====================================================================
-- 1. OVERLAYS & HUD (BLACK SCREEN, FPS, FLOATING BUTTON)
-- =====================================================================

-- [BLACK SCREEN]
local BlackScreen = Instance.new("Frame")
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreen.Visible = false
BlackScreen.ZIndex = 1
BlackScreen.Parent = ScreenGui

-- [HUD FPS COUNTER]
local HUD_FPS = Instance.new("Frame")
HUD_FPS.Size = UDim2.new(0, 120, 0, 35)
HUD_FPS.Position = UDim2.new(1, -140, 0, 20)
HUD_FPS.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HUD_FPS.ZIndex = 100
HUD_FPS.Parent = ScreenGui
Instance.new("UICorner", HUD_FPS).CornerRadius = UDim.new(0, 8)
local HUDFPS_Stroke = Instance.new("UIStroke", HUD_FPS)
HUDFPS_Stroke.Color = Color3.fromRGB(50, 50, 50)

local HUD_FPS_Text = Instance.new("TextLabel")
HUD_FPS_Text.Size = UDim2.new(1, 0, 1, 0)
HUD_FPS_Text.BackgroundTransparency = 1
HUD_FPS_Text.Text = "📊 FPS : ..."
HUD_FPS_Text.TextColor3 = Color3.fromRGB(0, 255, 100)
HUD_FPS_Text.Font = Enum.Font.GothamBold
HUD_FPS_Text.TextSize = 14
HUD_FPS_Text.ZIndex = 101
HUD_FPS_Text.Parent = HUD_FPS

-- [FLOATING BUTTON]
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatBtn.Text = "⋯"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 24
FloatBtn.AutoButtonColor = false
FloatBtn.ZIndex = 999
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 1.5
table.insert(ThemeObjects.Accents, FloatStroke)

-- =====================================================================
-- DRAG & RIPPLE LOGIC
-- =====================================================================
local function CreateRipple(btn)
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.ZIndex = btn.ZIndex + 1
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    ripple.Parent = btn
    
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.5
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local t = TweenService:Create(ripple, TweenInfo.new(0.4), {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0.5, -size/2, 0.5, -size/2),
        BackgroundTransparency = 1
    })
    t:Play()
    t.Completed:Connect(function() ripple:Destroy() end)
end

local function MakeDraggable(obj, dragHandle, clickCallback)
    local dragging, dragStart, startPos
    local threshold = 5
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if clickCallback and (input.Position - dragStart).Magnitude <= threshold then
                        clickCallback()
                    end
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local viewport = workspace.CurrentCamera.ViewportSize
            local nX = math.clamp(startPos.X.Offset + delta.X, 0, viewport.X - obj.AbsoluteSize.X)
            local nY = math.clamp(startPos.Y.Offset + delta.Y, 0, viewport.Y - obj.AbsoluteSize.Y)
            TweenService:Create(obj, TweenInfo.new(0.05), {Position = UDim2.new(0, nX, 0, nY)}):Play()
        end
    end)
end

-- =====================================================================
-- 2. MAIN MENU UI
-- =====================================================================
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 680, 0, 420)
MainMenu.Position = UDim2.new(0.5, -340, 0.5, -210)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Visible = false
MainMenu.ZIndex = 10
MainMenu.Parent = ScreenGui
Instance.new("UICorner", MainMenu).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainMenu)
MainStroke.Thickness = 1.5
table.insert(ThemeObjects.Accents, MainStroke)

local MenuScale = Instance.new("UIScale", MainMenu)
MenuScale.Scale = 0.85

-- [HEADER]
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.ZIndex = 11
Header.Parent = MainMenu
MakeDraggable(MainMenu, Header)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.RichText = true
Title.Text = "<font color='#ffffff'>fulluid ưu - main menu | </font><font color='#00ff00'>by:@2024nam8</font>"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Header

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, 0, 0, 1)
Line.Position = UDim2.new(0, 0, 1, 0)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Line.ZIndex = 11
Line.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header

-- [SIDEBAR & CONTENT AREA]
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -46)
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.BackgroundTransparency = 1
Sidebar.ZIndex = 11
Sidebar.Parent = MainMenu

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, -20)
SidebarLine.Position = UDim2.new(1, 0, 0, 10)
SidebarLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SidebarLine.ZIndex = 11
SidebarLine.Parent = Sidebar

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 55, 0, 55)
Logo.Position = UDim2.new(0.5, -27.5, 0, 20)
Logo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Logo.ZIndex = 12
Logo.Parent = Sidebar
Instance.new("UICorner", Logo).CornerRadius = UDim.new(1, 0)
local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(1, 0, 1, 0)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "🥷"
LogoIcon.TextSize = 35
LogoIcon.ZIndex = 13
LogoIcon.Parent = Logo

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -100)
TabContainer.Position = UDim2.new(0, 10, 0, 90)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 11
TabContainer.Parent = Sidebar
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabContainer

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -151, 1, -46)
ContentArea.Position = UDim2.new(0, 151, 0, 46)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 11
ContentArea.Parent = MainMenu

-- =====================================================================
-- TOGGLE MENU LOGIC
-- =====================================================================
local MenuOpen = false
local Animating = false

local function ToggleMenu()
    if Animating then return end
    Animating = true
    MenuOpen = not MenuOpen
    
    if MenuOpen then
        MainMenu.Visible = true
        TweenService:Create(MenuScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        local t = TweenService:Create(MainMenu, TweenInfo.new(0.2), {BackgroundTransparency = 0})
        t:Play()
        t.Completed:Connect(function() Animating = false end)
    else
        TweenService:Create(MenuScale, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Scale = 0.9}):Play()
        local t = TweenService:Create(MainMenu, TweenInfo.new(0.2), {BackgroundTransparency = 1})
        t:Play()
        t.Completed:Connect(function() 
            MainMenu.Visible = false
            Animating = false 
        end)
    end
end

MakeDraggable(FloatBtn, FloatBtn, function()
    CreateRipple(FloatBtn)
    ToggleMenu()
end)

CloseBtn.MouseButton1Click:Connect(function()
    CreateRipple(CloseBtn)
    if MenuOpen then ToggleMenu() end
end)

-- =====================================================================
-- 3. UI LIBRARY FACTORY (TABS, SECTIONS, TOGGLES)
-- =====================================================================
local Tabs = {}
local FirstTab = true

local function CreateTab(icon, name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = FirstTab and Color3.fromRGB(20, 255, 100) or Color3.fromRGB(25, 25, 25)
    TabBtn.BackgroundTransparency = FirstTab and 0.85 or 1
    TabBtn.Text = "  " .. icon .. "  " .. name
    TabBtn.TextColor3 = FirstTab and Color3.fromRGB(20, 255, 100) or Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 12
    TabBtn.Parent = TabContainer
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local TabStroke = Instance.new("UIStroke", TabBtn)
    TabStroke.Color = Color3.fromRGB(20, 255, 100)
    TabStroke.Transparency = FirstTab and 0 or 1
    
    if FirstTab then 
        table.insert(ThemeObjects.Accents, TabStroke)
        table.insert(ThemeObjects.Texts, TabBtn)
    end

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.Visible = FirstTab
    Page.ZIndex = 12
    Page.Parent = ContentArea
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 15)
    PageLayout.Parent = Page
    
    table.insert(Tabs, {Btn = TabBtn, Stroke = TabStroke, Page = Page})
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do
            t.Page.Visible = (t.Page == Page)
            if t.Page == Page then
                t.Btn.BackgroundTransparency = 0.85
                t.Stroke.Transparency = 0
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = ActiveColor}):Play()
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = ActiveColor}):Play()
                TweenService:Create(t.Stroke, TweenInfo.new(0.2), {Color = ActiveColor}):Play()
                table.insert(ThemeObjects.Accents, t.Stroke)
                table.insert(ThemeObjects.Texts, t.Btn)
            else
                t.Btn.BackgroundTransparency = 1
                t.Stroke.Transparency = 1
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200,200,200)}):Play()
                for i, v in ipairs(ThemeObjects.Accents) do if v == t.Stroke then table.remove(ThemeObjects.Accents, i) end end
                for i, v in ipairs(ThemeObjects.Texts) do if v == t.Btn then table.remove(ThemeObjects.Texts, i) end end
            end
        end
    end)
    FirstTab = false
    return Page
end

local function CreateSection(parent, title, icon, height)
    local Sec = Instance.new("Frame")
    Sec.Size = UDim2.new(1, 0, 0, height or 200)
    Sec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Sec.ZIndex = 13
    Sec.Parent = parent
    Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Sec)
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -30, 0, 35)
    TitleLbl.Position = UDim2.new(0, 15, 0, 5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = icon .. " " .. title
    TitleLbl.TextColor3 = Color3.fromRGB(20, 255, 100)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 14
    TitleLbl.Parent = Sec
    table.insert(ThemeObjects.Texts, TitleLbl)
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -30, 1, -45)
    Content.Position = UDim2.new(0, 15, 0, 40)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 14
    Content.Parent = Sec
    
    return Content, Sec
end

local function CreateToggle(parent, title, desc, icon, callback)
    local state = false
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundTransparency = 1
    Frame.Text = ""
    Frame.ZIndex = 15
    Frame.Parent = parent
    
    local IconLbl = Instance.new("TextLabel")
    IconLbl.Size = UDim2.new(0, 30, 0, 30)
    IconLbl.Position = UDim2.new(0, 0, 0.5, -15)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text = icon
    IconLbl.TextSize = 16
    IconLbl.ZIndex = 16
    IconLbl.Parent = Frame
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -100, 0, 20)
    TitleLbl.Position = UDim2.new(0, 35, 0, 5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 16
    TitleLbl.Parent = Frame
    
    local DescLbl = Instance.new("TextLabel")
    DescLbl.Size = UDim2.new(1, -100, 0, 20)
    DescLbl.Position = UDim2.new(0, 35, 0, 25)
    DescLbl.BackgroundTransparency = 1
    DescLbl.Text = desc
    DescLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextSize = 11
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    DescLbl.ZIndex = 16
    DescLbl.Parent = Frame
    
    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 40, 0, 22)
    SwitchBg.Position = UDim2.new(1, -40, 0.5, -11)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchBg.ZIndex = 16
    SwitchBg.Parent = Frame
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    
    local SwitchCircle = Instance.new("Frame")
    SwitchCircle.Size = UDim2.new(0, 18, 0, 18)
    SwitchCircle.Position = UDim2.new(0, 2, 0.5, -9)
    SwitchCircle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SwitchCircle.ZIndex = 17
    SwitchCircle.Parent = SwitchBg
    Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)
    
    local function UpdateToggleVisuals(isSetup)
        local endPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        if state then
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = ActiveColor}):Play()
            table.insert(ThemeObjects.Accents, SwitchBg)
        else
            for i, v in ipairs(ThemeObjects.Accents) do if v == SwitchBg then table.remove(ThemeObjects.Accents, i) end end
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end
        TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = endPos}):Play()
    end
    UpdateToggleVisuals(true)
    
    Frame.MouseButton1Click:Connect(function()
        CreateRipple(Frame)
        state = not state
        UpdateToggleVisuals(false)
        if callback then callback(state) end
    end)
    
    -- API để ép đổi trạng thái từ ngoài (ví dụ gán default = true)
    return function(newState)
        state = newState
        UpdateToggleVisuals(false)
        if callback then callback(state) end
    end
end

-- =====================================================================
-- 4. BUILDING TAB CONTENTS
-- =====================================================================

-- [TAB 1: MAIN]
local Tab1 = CreateTab("🏠", "Main")

local MainLayout = Instance.new("Frame")
MainLayout.Size = UDim2.new(1, 0, 1, 0)
MainLayout.BackgroundTransparency = 1
MainLayout.ZIndex = 12
MainLayout.Parent = Tab1

local LeftCol, SecMain = CreateSection(MainLayout, "Main Features", "🟢", 260)
SecMain.Size = UDim2.new(0.55, -5, 0, 260)
local LayoutLeft = Instance.new("UIListLayout", LeftCol)
LayoutLeft.Padding = UDim.new(0, 5)

local RightCol, SecFPS = CreateSection(MainLayout, "FPS Counter", "📊", 260)
SecFPS.Size = UDim2.new(0.45, -5, 0, 260)
SecFPS.Position = UDim2.new(0.55, 10, 0, 0)
local LayoutRight = Instance.new("UIListLayout", RightCol)
LayoutRight.Padding = UDim.new(0, 10)

-- Logic Variables
local HiddenGUIs = {}

local SetBlackScreen = CreateToggle(LeftCol, "Black Screen", "Bật / Tắt màn hình đen toàn bộ", "⬛", function(state)
    BlackScreen.Visible = state
end)

local SetHideGUI = CreateToggle(LeftCol, "Hide All GUI", "Ẩn tất cả GUI của game", "👁️", function(state)
    if state then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "FulluidMainMenu" and gui.Enabled then
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

local SetFPS = CreateToggle(LeftCol, "FPS Counter", "Hiển thị FPS ở góc màn hình", "⏱️", function(state)
    HUD_FPS.Visible = state
end)

local SetWatermark = CreateToggle(LeftCol, "Show Watermark", "Hiển thị logo của script", "🏷️", function(state)
    -- Giả lập chức năng Watermark
end)

-- Button Destroy
local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(1, 0, 0, 45)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
DestroyBtn.Text = "🗑️ Destroy GUI"
DestroyBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextSize = 14
DestroyBtn.ZIndex = 15
DestroyBtn.Parent = LeftCol
Instance.new("UICorner", DestroyBtn).CornerRadius = UDim.new(0, 8)
local DestStroke = Instance.new("UIStroke", DestroyBtn)
DestStroke.Color = Color3.fromRGB(150, 40, 40)

DestroyBtn.MouseButton1Click:Connect(function()
    CreateRipple(DestroyBtn)
    for gui, _ in pairs(HiddenGUIs) do
        if gui and gui.Parent then gui.Enabled = true end
    end
    ScreenGui:Destroy()
end)

-- Right Column (FPS Info Legend)
local FPSDisplay = Instance.new("TextLabel")
FPSDisplay.Size = UDim2.new(1, 0, 0, 30)
FPSDisplay.BackgroundTransparency = 1
FPSDisplay.RichText = true
FPSDisplay.Text = "<font color='#ffffff'>FPS : </font><font color='#00ff00'>...</font>"
FPSDisplay.Font = Enum.Font.GothamBold
FPSDisplay.TextSize = 24
FPSDisplay.TextXAlignment = Enum.TextXAlignment.Left
FPSDisplay.ZIndex = 15
FPSDisplay.Parent = RightCol

local FPSDesc = Instance.new("TextLabel")
FPSDesc.Size = UDim2.new(1, 0, 0, 15)
FPSDesc.BackgroundTransparency = 1
FPSDesc.Text = "Cập nhật mỗi 0.2s"
FPSDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
FPSDesc.Font = Enum.Font.Gotham
FPSDesc.TextSize = 11
FPSDesc.TextXAlignment = Enum.TextXAlignment.Left
FPSDesc.ZIndex = 15
FPSDesc.Parent = RightCol

local LegendData = {
    {"🌈", "> 300 FPS", "Rainbow"},
    {"🟢", "31 - 300 FPS", "Xanh lá"},
    {"🟡", "11 - 30 FPS", "Vàng"},
    {"🔴", "≤ 10 FPS", "Đỏ"}
}
for _, d in ipairs(LegendData) do
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = d[1] .. "  " .. d[2] .. "   →   " .. d[3]
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 15
    Lbl.Parent = RightCol
end

-- Bật sẵn FPS Counter theo ảnh mẫu
SetFPS(true)

-- [TAB 2: THEME]
local Tab2 = CreateTab("🎨", "Theme")
local ThemeContent, SecTheme = CreateSection(Tab2, "Theme Selector", "🎨", 310)

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0, 110, 0, 35)
Grid.CellPadding = UDim2.new(0, 10, 0, 10)
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = ThemeContent

local ThemeList = {
    {"Black", Colors.Black}, {"White", Colors.White}, {"Gray", Colors.Gray}, {"Blue", Colors.Blue},
    {"Dark Blue", Colors.DarkBlue}, {"Red", Colors.Red}, {"Dark Red", Colors.DarkRed}, {"Green", Colors.Green},
    {"Lime", Colors.Lime}, {"Yellow", Colors.Yellow}, {"Orange", Colors.Orange}, {"Purple", Colors.Purple},
    {"Pink", Colors.Pink}, {"Cyan", Colors.Cyan}, {"Rainbow", nil}, {"Secret", nil}
}

for i, tData in ipairs(ThemeList) do
    local name = tData[1]
    local color = tData[2]
    
    local TBtn = Instance.new("TextButton")
    TBtn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    TBtn.Text = name
    TBtn.TextColor3 = (name == "White" or name == "Yellow") and Color3.fromRGB(0,0,0) or Color3.fromRGB(255, 255, 255)
    TBtn.Font = Enum.Font.GothamBold
    TBtn.TextSize = 12
    TBtn.ZIndex = 15
    TBtn.Parent = ThemeContent
    Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 6)
    
    if name == "Rainbow" or name == "Secret" then
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,255))
        }
        grad.Parent = TBtn
    end
    
    TBtn.MouseButton1Click:Connect(function()
        CreateRipple(TBtn)
        IsRainbow = (name == "Rainbow")
        IsSecret = (name == "Secret")
        
        if not IsRainbow and not IsSecret then
            CurrentTheme = name
            UpdateTheme(color)
        else
            CurrentTheme = name
        end
        
        if IsSecret then
            MainStroke.Thickness = 3
        else
            MainStroke.Thickness = 1.5
        end
    end)
end

-- [TAB 3: INFO]
local Tab3 = CreateTab("ℹ️", "Info")
local InfoContent, SecInfo = CreateSection(Tab3, "Information", "ℹ️", 200)

local InfoGrid = Instance.new("UIGridLayout")
InfoGrid.CellSize = UDim2.new(0, 150, 0, 50)
InfoGrid.CellPadding = UDim2.new(0, 15, 0, 15)
InfoGrid.SortOrder = Enum.SortOrder.LayoutOrder
InfoGrid.Parent = InfoContent

local function CreateInfoCard(title, val)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Card.ZIndex = 15
    Card.Parent = InfoContent
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    
    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(1, -20, 0, 20)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.Text = title
    T.TextColor3 = Color3.fromRGB(150, 150, 150)
    T.Font = Enum.Font.Gotham
    T.TextSize = 11
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.ZIndex = 16
    T.Parent = Card
    
    local V = Instance.new("TextLabel")
    V.Size = UDim2.new(1, -20, 0, 20)
    V.Position = UDim2.new(0, 10, 0, 25)
    V.BackgroundTransparency = 1
    V.Text = val
    V.TextColor3 = Color3.fromRGB(255, 255, 255)
    V.Font = Enum.Font.GothamBold
    V.TextSize = 13
    V.TextXAlignment = Enum.TextXAlignment.Left
    V.ZIndex = 16
    V.Parent = Card
    
    return V
end

CreateInfoCard("Script Name", "fulluid ưu - main menu")
CreateInfoCard("Version", "1.0.0")
CreateInfoCard("Developer", "@2024nam8")
CreateInfoCard("Year", "2024")
local InfoFPSVal = CreateInfoCard("FPS Hiện Tại", "...")
local InfoThemeVal = CreateInfoCard("Theme Hiện Tại", "Green")

-- =====================================================================
-- 5. ENGINE LOOPS (FPS & THEME ANIMATION)
-- =====================================================================
local frames = 0
local lastUpdate = tick()

RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1
    local now = tick()
    
    -- Dynamic Theme Updater
    if IsRainbow or IsSecret then
        local hue = now % 3 / 3
        local dynamicColor = Color3.fromHSV(hue, 1, 1)
        UpdateTheme(dynamicColor)
        InfoThemeVal.Text = CurrentTheme
    else
        InfoThemeVal.Text = CurrentTheme
    end
    
    -- FPS Counter Logic (Update every 0.2s for smoothness)
    if now - lastUpdate >= 0.2 then
        local fps = math.floor(frames / (now - lastUpdate))
        frames = 0
        lastUpdate = now
        
        local colorHex = "#00ff00"
        local fpsColor = Color3.fromRGB(0, 255, 100)
        
        if fps > 300 then 
            colorHex = "#ff00ff" -- Magenta/Rainbow mock
            fpsColor = Color3.fromHSV(now % 2 / 2, 1, 1)
        elseif fps >= 31 then 
            colorHex = "#00ff00" 
            fpsColor = Color3.fromRGB(0, 255, 100)
        elseif fps >= 11 then 
            colorHex = "#ffff00"
            fpsColor = Color3.fromRGB(255, 255, 0)
        else 
            colorHex = "#ff0000"
            fpsColor = Color3.fromRGB(255, 50, 50)
        end
        
        local txt = tostring(fps)
        FPSDisplay.RichText = true
        FPSDisplay.Text = string.format("<font color='#ffffff'>FPS : </font><font color='%s'>%s</font>", colorHex, txt)
        HUD_FPS_Text.Text = "📊 FPS : " .. txt
        HUD_FPS_Text.TextColor3 = fpsColor
        InfoFPSVal.Text = txt .. " FPS"
    end
end)

-- Initialize Default State
UpdateTheme(Colors.Green)
ToggleMenu()

