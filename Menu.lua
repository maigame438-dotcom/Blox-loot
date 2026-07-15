--[[
    Akira Hub - Complete Lua Script
    Designed with Dark UI, Advanced Animations, and High Performance
    Supports both PC and Mobile with Auto-saving, FPS Counter, and Clean GUI.
--]]

--===================================================================================
-- SERVICES & CONSTANTS
--===================================================================================
local Players = game:GetService("Players")
local TweetService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HapticService = game:GetService("HapticService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local SCREEN_ZINDEX = 1000
local BLACK_SCREEN_ZINDEX = 999

--===================================================================================
-- DEFAULT SETTINGS TABLE
--===================================================================================
local DefaultSettings = {
    Theme = "Dark",
    AccentColor = "Purple",
    RainbowAccent = false,
    GuiScale = 100,
    BlurBackground = false,
    Shadow = true,
    Glow = true,
    Animation = true,
    MenuTransparency = 0,
    ShowFPS = true,
    FpsPosition = "TopRight",
    ShowAverageFPS = false,
    BlackScreen = false,
    HideGameGui = false,
    AutoSave = true,
    ButtonSize = 100,
    MobileUIScale = 100,
    VibrationOnTap = false,
    MenuPosition = nil,
    FloatingButtonPosition = nil
}

-- Current active settings
local Settings = {}
for k, v in pairs(DefaultSettings) do
    Settings[k] = v
end

--===================================================================================
-- THEME & COLOR CONFIGURATIONS
--===================================================================================
local ColorThemes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 15),
        Header = Color3.fromRGB(22, 22, 22),
        Sidebar = Color3.fromRGB(18, 18, 18),
        Card = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(240, 240, 240),
        TextMuted = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(40, 40, 40)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Header = Color3.fromRGB(230, 230, 230),
        Sidebar = Color3.fromRGB(235, 235, 235),
        Card = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(20, 20, 20),
        TextMuted = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(210, 210, 210)
    }
}

local AccentColors = {
    Red = Color3.fromRGB(255, 51, 51),
    Blue = Color3.fromRGB(51, 153, 255),
    Purple = Color3.fromRGB(153, 51, 255),
    Green = Color3.fromRGB(51, 255, 102)
}

-- Dynamic Accent Color Tracking
local CurrentAccentColor = AccentColors.Purple

--===================================================================================
-- MODULES SETUP
--===================================================================================
local SettingsManager = {}
local ThemeManager = {}
local UIEffects = {}
local AnimationManager = {}
local BlackScreen = {}
local CleanGUI = {}
local FPSCounter = {}
local MenuBuilder = {}

--===================================================================================
-- SETTINGS MANAGER (Local Storage Mock using unique Folder)
--===================================================================================
local StorageFolder = LocalPlayer:FindFirstChild("AkiraHubSettings")
if not StorageFolder then
    StorageFolder = Instance.new("Folder")
    StorageFolder.Name = "AkiraHubSettings"
    StorageFolder.Parent = LocalPlayer
end

function SettingsManager.Save()
    for key, value in pairs(Settings) do
        local valName = tostring(key)
        local valObj = StorageFolder:FindFirstChild(valName)
        if not valObj then
            if type(value) == "boolean" then
                valObj = Instance.new("BoolValue")
            elseif type(value) == "number" then
                valObj = Instance.new("NumberValue")
            elseif type(value) == "string" then
                valObj = Instance.new("StringValue")
            elseif type(value) == "userdata" then
                valObj = Instance.new("StringValue") -- for UDim2 strings
            end
            if valObj then
                valObj.Name = valName
                valObj.Parent = StorageFolder
            end
        end
        if valObj then
            if type(value) == "userdata" then
                valObj.Value = tostring(value)
            else
                valObj.Value = value
            end
        end
    end
end

function SettingsManager.Load()
    for key, val in pairs(DefaultSettings) do
        local stored = StorageFolder:FindFirstChild(tostring(key))
        if stored then
            if type(val) == "userdata" then
                -- Parse UDim2 from string if needed
                local s, e = pcall(function()
                    local parts = {}
                    for num in string.gmatch(stored.Value, "[%d%.%-]+") do
                        table.insert(parts, tonumber(num))
                    end
                    if #parts == 4 then
                        Settings[key] = UDim2.new(parts[1], parts[2], parts[3], parts[4])
                    end
                end)
            else
                Settings[key] = stored.Value
            end
        end
    end
end

--===================================================================================
-- ANIMATION MANAGER (Tween with Fallback)
--===================================================================================
function AnimationManager.Tween(instance, info, propertyTable)
    if Settings.Animation then
        local tween = TweetService:Create(instance, info, propertyTable)
        tween:Play()
        return tween
    else
        for prop, val in pairs(propertyTable) do
            instance[prop] = val
        end
        return nil
    end
end

--===================================================================================
-- UI EFFECTS (Shadow, Glow, Ripple, Gradient)
--===================================================================================
function UIEffects.AddGradient(parent, color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = 45
    gradient.Parent = parent
    return gradient
end

function UIEffects.AddHorizontalGradient(parent, color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = 0
    gradient.Parent = parent
    return gradient
end

function UIEffects.AddRoundCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

function UIEffects.AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function UIEffects.CreateShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = parent.ZIndex - 1
    UIEffects.AddRoundCorner(shadow, 12)
    shadow.Visible = Settings.Shadow
    shadow.Parent = parent
    return shadow
end

function UIEffects.ApplyRipple(button, clickPos)
    if not Settings.Animation then return end
    
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.6
    ripple.ZIndex = button.ZIndex + 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local x = clickPos.X - button.AbsolutePosition.X
    local y = clickPos.Y - button.AbsolutePosition.Y
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Parent = button
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    AnimationManager.Tween(ripple, tweenInfo, {
        Size = UDim2.new(0, math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2, 0, math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2),
        BackgroundTransparency = 1
    })
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Vibration implementation for mobile
function UIEffects.Vibrate()
    if Settings.VibrationOnTap then
        pcall(function()
            HapticService:Vibrate(Enum.VibrationMotor.Large, 1)
            task.wait(0.05)
            HapticService:StopVibration(Enum.VibrationMotor.Large)
        end)
    end
end

--===================================================================================
-- THEME MANAGER
--===================================================================================
local ThemeElements = {
    Backgrounds = {},
    Cards = {},
    Texts = {},
    TextsMuted = {},
    Borders = {},
    Accents = {},
    Shadows = {}
}

function ThemeManager.RegisterElement(element, group)
    if ThemeElements[group] then
        table.insert(ThemeElements[group], element)
    end
end

function ThemeManager.UpdateUI()
    local theme = ColorThemes[Settings.Theme] or ColorThemes.Dark
    
    -- Backgrounds
    for _, elem in ipairs(ThemeElements.Backgrounds) do
        if elem:IsA("GuiObject") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { BackgroundColor3 = theme.Background })
        end
    end
    -- Cards
    for _, elem in ipairs(ThemeElements.Cards) do
        if elem:IsA("GuiObject") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { BackgroundColor3 = theme.Card })
        end
    end
    -- Borders
    for _, elem in ipairs(ThemeElements.Borders) do
        if elem:IsA("UIStroke") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { Color = theme.Border })
        end
    end
    -- Texts
    for _, elem in ipairs(ThemeElements.Texts) do
        if elem:IsA("TextLabel") or elem:IsA("TextBox") or elem:IsA("TextButton") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { TextColor3 = theme.Text })
        end
    end
    -- Muted Texts
    for _, elem in ipairs(ThemeElements.TextsMuted) do
        if elem:IsA("TextLabel") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { TextColor3 = theme.TextMuted })
        end
    end
    -- Accents
    for _, elem in ipairs(ThemeElements.Accents) do
        if elem:IsA("GuiObject") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { BackgroundColor3 = CurrentAccentColor })
        elseif elem:IsA("UIStroke") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { Color = CurrentAccentColor })
        elseif elem:IsA("TextLabel") then
            AnimationManager.Tween(elem, TweenInfo.new(0.3), { TextColor3 = CurrentAccentColor })
        end
    end
    -- Shadows
    for _, elem in ipairs(ThemeElements.Shadows) do
        elem.Visible = Settings.Shadow
    end
end

-- Rainbow Accent Routine
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if Settings.RainbowAccent then
            local hue = (os.clock() * 0.1) % 1
            CurrentAccentColor = Color3.fromHSV(hue, 0.8, 1)
            -- Instant updates for items marked as Accent
            for _, elem in ipairs(ThemeElements.Accents) do
                if elem:IsA("GuiObject") then
                    elem.BackgroundColor3 = CurrentAccentColor
                elseif elem:IsA("UIStroke") then
                    elem.Color = CurrentAccentColor
                elseif elem:IsA("TextLabel") then
                    elem.TextColor3 = CurrentAccentColor
                elseif elem:IsA("UIGradient") then
                    elem.Color = ColorSequence.new(CurrentAccentColor, Color3.fromRGB(0, 0, 0))
                end
            end
        end
    end
end)

--===================================================================================
-- BLACK SCREEN FUNCTIONALITY
--===================================================================================
local BlackScreenFrame = nil

function BlackScreen.Setup(screenGui)
    BlackScreenFrame = Instance.new("Frame")
    BlackScreenFrame.Name = "BlackScreenFrame"
    BlackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
    BlackScreenFrame.Position = UDim2.new(0, 0, 0, 0)
    BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackScreenFrame.BackgroundTransparency = 1
    BlackScreenFrame.ZIndex = BLACK_SCREEN_ZINDEX
    BlackScreenFrame.Parent = screenGui
end

function BlackScreen.Set(state)
    if not BlackScreenFrame then return end
    Settings.BlackScreen = state
    local target = state and 0 or 1
    AnimationManager.Tween(BlackScreenFrame, TweenInfo.new(0.5), { BackgroundTransparency = target })
end

--===================================================================================
-- CLEAN GUI (HIDE ORIGINAL GAME GUI)
--===================================================================================
local HiddenGuis = {}

function CleanGUI.Set(state)
    Settings.HideGameGui = state
    if state then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "AkiraHubGui" and gui.Enabled == true then
                table.insert(HiddenGuis, gui)
                gui.Enabled = false
            end
        end
    else
        for _, gui in ipairs(HiddenGuis) do
            if gui and gui.Parent then
                gui.Enabled = true
            end
        end
        table.clear(HiddenGuis)
    end
end

function CleanGUI.ForceRestore()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "AkiraHubGui" then
            gui.Enabled = true
        end
    end
    table.clear(HiddenGuis)
    Settings.HideGameGui = false
end

--===================================================================================
-- FPS COUNTER
--===================================================================================
local FPSLabel = nil
local FPSElementFrame = nil
local FPSFrameCount = 0
local FPSLastTime = os.clock()
local FPSHistory = {}

function FPSCounter.Setup(screenGui)
    FPSElementFrame = Instance.new("Frame")
    FPSElementFrame.Name = "FPSCounterFrame"
    FPSElementFrame.Size = UDim2.new(0, 180, 0, 40)
    FPSElementFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    FPSElementFrame.BackgroundTransparency = 0.3
    UIEffects.AddRoundCorner(FPSElementFrame, 8)
    local stroke = UIEffects.AddStroke(FPSElementFrame, Color3.fromRGB(40, 40, 40), 1.5)
    ThemeManager.RegisterElement(stroke, "Borders")
    
    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(1, -10, 1, 0)
    FPSLabel.Position = UDim2.new(0, 5, 0, 0)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextSize = 14
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
    FPSLabel.TextYAlignment = Enum.TextYAlignment.Center
    FPSLabel.Parent = FPSElementFrame
    
    FPSCounter.UpdatePosition()
    FPSElementFrame.Parent = screenGui
    FPSElementFrame.Visible = Settings.ShowFPS
end

function FPSCounter.UpdatePosition()
    if not FPSElementFrame then return end
    local pos = Settings.FpsPosition
    if pos == "TopLeft" then
        FPSElementFrame.Position = UDim2.new(0, 15, 0, 15)
    elseif pos == "TopRight" then
        FPSElementFrame.Position = UDim2.new(1, -195, 0, 15)
    elseif pos == "BottomLeft" then
        FPSElementFrame.Position = UDim2.new(0, 15, 1, -55)
    elseif pos == "BottomRight" then
        FPSElementFrame.Position = UDim2.new(1, -195, 1, -55)
    end
end

-- Thread running FPS ticks
RunService.RenderStepped:Connect(function()
    FPSFrameCount = FPSFrameCount + 1
    local now = os.clock()
    local elapsed = now - FPSLastTime
    
    if elapsed >= 0.1 then
        local currentFPS = math.round(FPSFrameCount / elapsed)
        FPSFrameCount = 0
        FPSLastTime = now
        
        table.insert(FPSHistory, currentFPS)
        if #FPSHistory > 50 then -- approx 5 seconds
            table.remove(FPSHistory, 1)
        end
        
        local avgFPS = 0
        for _, v in ipairs(FPSHistory) do
            avgFPS = avgFPS + v
        end
        avgFPS = math.round(avgFPS / #FPSHistory)
        
        if FPSLabel and FPSElementFrame then
            -- Determine Color
            local fpsColor = Color3.fromRGB(0, 255, 0)
            if currentFPS <= 10 then
                fpsColor = Color3.fromRGB(255, 0, 0)
            elseif currentFPS <= 30 then
                fpsColor = Color3.fromRGB(255, 255, 0)
            elseif currentFPS <= 150 then
                fpsColor = Color3.fromRGB(0, 255, 0)
            else
                local rHue = (os.clock() * 0.5) % 1
                fpsColor = Color3.fromHSV(rHue, 0.8, 1)
            end
            
            FPSLabel.TextColor3 = fpsColor
            
            if Settings.ShowAverageFPS then
                FPSLabel.Text = string.format("FPS: %d | AVG: %d", currentFPS, avgFPS)
            else
                FPSLabel.Text = string.format("FPS: %d", currentFPS)
            end
        end
    end
end)

--===================================================================================
-- DRAG & DROP UTILITY
--===================================================================================
local function MakeDraggable(dragFrame, parentFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parentFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--===================================================================================
-- MENU BUILDER (UI generation)
--===================================================================================
function MenuBuilder.Build()
    -- Root GUI Setup
    local oldGui = PlayerGui:FindFirstChild("AkiraHubGui")
    if oldGui then oldGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AkiraHubGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    BlackScreen.Setup(ScreenGui)
    FPSCounter.Setup(ScreenGui)
    
    -- Responsive calculation for Main Window size
    local isMobile = UserInputService.TouchEnabled
    local uiScaleVal = isMobile and (Settings.MobileUIScale / 100) or (Settings.GuiScale / 100)
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, math.floor(580 * uiScaleVal), 0, math.floor(380 * uiScaleVal))
    MainFrame.Position = Settings.MenuPosition or UDim2.new(0.5, -math.floor(290 * uiScaleVal), 0.5, -math.floor(190 * uiScaleVal))
    MainFrame.BackgroundColor3 = ColorThemes.Dark.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    ThemeManager.RegisterElement(MainFrame, "Backgrounds")
    UIEffects.AddRoundCorner(MainFrame, 12)
    local shadow = UIEffects.CreateShadow(MainFrame)
    ThemeManager.RegisterElement(shadow, "Shadows")
    
    local mainStroke = UIEffects.AddStroke(MainFrame, ColorThemes.Dark.Border, 1.5)
    ThemeManager.RegisterElement(mainStroke, "Borders")
    
    -- Title Bar Setup
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = ColorThemes.Dark.Header
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    ThemeManager.RegisterElement(TitleBar, "Backgrounds")
    UIEffects.AddRoundCorner(TitleBar, 12)
    
    -- Clip bottom corners of the header using a visual hack or just relying on layout
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "Akira Hub"
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextColor3 = CurrentAccentColor
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    ThemeManager.RegisterElement(TitleText, "Accents")
    
    MakeDraggable(TitleBar, MainFrame)
    
    -- Minimize / Close Buttons
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    UIEffects.AddRoundCorner(CloseBtn, 6)
    CloseBtn.Parent = TitleBar
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Position = UDim2.new(1, -64, 0.5, -12)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeBtn.Text = "−"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 12
    UIEffects.AddRoundCorner(MinimizeBtn, 6)
    MinimizeBtn.Parent = TitleBar
    
    -- Navigation Sidebar Setup
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 130, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundColor3 = ColorThemes.Dark.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    ThemeManager.RegisterElement(Sidebar, "Cards")
    
    local sideStroke = Instance.new("Frame")
    sideStroke.Size = UDim2.new(0, 1, 1, 0)
    sideStroke.Position = UDim2.new(1, -1, 0, 0)
    sideStroke.BackgroundColor3 = ColorThemes.Dark.Border
    sideStroke.BorderSizePixel = 0
    sideStroke.Parent = Sidebar
    ThemeManager.RegisterElement(sideStroke, "Borders")
    
    -- Content Container
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -130, 1, -42)
    ContentFrame.Position = UDim2.new(0, 130, 0, 42)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Floating Button (Minimize state representation)
    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Name = "FloatingButton"
    FloatBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatBtn.Position = Settings.FloatingButtonPosition or UDim2.new(0.9, -25, 0.2, -25)
    FloatBtn.BackgroundColor3 = CurrentAccentColor
    FloatBtn.Visible = false
    FloatBtn.Parent = ScreenGui
    
    UIEffects.AddRoundCorner(FloatBtn, 25)
    local floatShadow = UIEffects.CreateShadow(FloatBtn)
    ThemeManager.RegisterElement(floatShadow, "Shadows")
    ThemeManager.RegisterElement(FloatBtn, "Accents")
    MakeDraggable(FloatBtn, FloatBtn)
    
    local FloatLabel = Instance.new("TextLabel")
    FloatLabel.Size = UDim2.new(1, 0, 1, 0)
    FloatLabel.BackgroundTransparency = 1
    FloatLabel.Text = "☰"
    FloatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatLabel.Font = Enum.Font.GothamBold
    FloatLabel.TextSize = 22
    FloatLabel.Parent = FloatBtn
    
    -- Window Toggle Animations
    local isMinimized = false
    
    local function SetMinimized(state)
        isMinimized = state
        UIEffects.Vibrate()
        
        if isMinimized then
            -- Animate Menu disappearing
            local t = AnimationManager.Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = FloatBtn.Position
            })
            if t then t.Completed:Wait() end
            MainFrame.Visible = false
            FloatBtn.Visible = true
            FloatBtn.Size = UDim2.new(0, 10, 0, 10)
            AnimationManager.Tween(FloatBtn, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            })
        else
            -- Open Menu Frame
            FloatBtn.Visible = false
            MainFrame.Visible = true
            AnimationManager.Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, math.floor(580 * uiScaleVal), 0, math.floor(380 * uiScaleVal)),
                Position = Settings.MenuPosition or UDim2.new(0.5, -math.floor(290 * uiScaleVal), 0.5, -math.floor(190 * uiScaleVal))
            })
        end
    end
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        SetMinimized(true)
    end)
    
    FloatBtn.MouseButton1Click:Connect(function()
        SetMinimized(false)
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        UIEffects.Vibrate()
        ScreenGui:Destroy()
    end)
    
    -- Setup Scroll Containers per Tab
    local Tabs = { "Home", "Settings", "FPS", "Game", "Mobile", "System" }
    local TabFrames = {}
    local TabButtons = {}
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = Sidebar
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = Sidebar
    
    -- Active states indicator line
    local ActiveIndicator = Instance.new("Frame")
    ActiveIndicator.Size = UDim2.new(0, 4, 0, 24)
    ActiveIndicator.BackgroundColor3 = CurrentAccentColor
    ActiveIndicator.Parent = Sidebar
    ActiveIndicator.Visible = false
    ThemeManager.RegisterElement(ActiveIndicator, "Accents")
    
    local function SwitchTab(tabName)
        UIEffects.Vibrate()
        for name, frame in pairs(TabFrames) do
            if name == tabName then
                frame.Visible = true
                frame.GroupTransparency = 1
                AnimationManager.Tween(frame, TweenInfo.new(0.25), { GroupTransparency = 0 })
            else
                frame.Visible = false
            end
        end
        
        for name, btn in pairs(TabButtons) do
            if name == tabName then
                AnimationManager.Tween(btn, TweenInfo.new(0.25), { TextColor3 = CurrentAccentColor })
                ActiveIndicator.Visible = true
                ActiveIndicator.Position = UDim2.new(0, -6, 0, btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y)
            else
                AnimationManager.Tween(btn, TweenInfo.new(0.25), { TextColor3 = ColorThemes.Dark.TextMuted })
            end
        end
    end
    
    for i, tName in ipairs(Tabs) do
        -- Register Content frames
        local canvas = Instance.new("CanvasGroup")
        canvas.Name = tName .. "Tab"
        canvas.Size = UDim2.new(1, 0, 1, 0)
        canvas.BackgroundTransparency = 1
        canvas.Visible = false
        canvas.Parent = ContentFrame
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -12, 1, -12)
        scroll.Position = UDim2.new(0, 6, 0, 6)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = CurrentAccentColor
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Auto adjusts with UIListLayout
        scroll.Parent = canvas
        ThemeManager.RegisterElement(scroll, "Accents")
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = scroll
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        
        TabFrames[tName] = canvas
        
        -- Generate Tab Selection Buttons
        local btn = Instance.new("TextButton")
        btn.Name = tName .. "Btn"
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundTransparency = 1
        btn.Text = tName
        btn.Font = Enum.Font.GothamSemibold
        btn.TextColor3 = ColorThemes.Dark.TextMuted
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = Sidebar
        
        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, 10)
        btnPadding.Parent = btn
        
        ThemeManager.RegisterElement(btn, "TextsMuted")
        TabButtons[tName] = btn
        
        btn.MouseButton1Click:Connect(function(x, y)
            UIEffects.ApplyRipple(btn, Vector2.new(x, y))
            SwitchTab(tName)
        end)
    end
    
    -- Helper UI element constructors
    local function CreateSection(parent, title)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 24)
        frame.BackgroundTransparency = 1
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = title:upper()
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = CurrentAccentColor
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        ThemeManager.RegisterElement(lbl, "Accents")
        
        frame.Parent = parent
    end
    
    local function CreateToggle(parent, labelText, defaultValue, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -10, 0, 36)
        toggleFrame.BackgroundColor3 = ColorThemes.Dark.Card
        UIEffects.AddRoundCorner(toggleFrame, 6)
        ThemeManager.RegisterElement(toggleFrame, "Cards")
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamSemibold
        label.TextColor3 = ColorThemes.Dark.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        ThemeManager.RegisterElement(label, "Texts")
        
        local switch = Instance.new("Frame")
        switch.Size = UDim2.new(0, 38, 0, 20)
        switch.Position = UDim2.new(1, -48, 0.5, -10)
        switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        UIEffects.AddRoundCorner(switch, 10)
        switch.Parent = toggleFrame
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = defaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        circle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        UIEffects.AddRoundCorner(circle, 8)
        circle.Parent = switch
        
        local active = defaultValue
        if active then
            switch.BackgroundColor3 = CurrentAccentColor
            ThemeManager.RegisterElement(switch, "Accents")
        end
        
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = toggleFrame
        
        clickBtn.MouseButton1Click:Connect(function()
            active = not active
            UIEffects.Vibrate()
            if active then
                AnimationManager.Tween(circle, TweenInfo.new(0.2), { Position = UDim2.new(1, -18, 0.5, -8) })
                AnimationManager.Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = CurrentAccentColor })
            else
                AnimationManager.Tween(circle, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -8) })
                AnimationManager.Tween(switch, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(50, 50, 50) })
            end
            callback(active)
        end)
        
        toggleFrame.Parent = parent
    end
    
    local function CreateSlider(parent, labelText, min, max, defaultVal, suffix, step, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 54)
        frame.BackgroundColor3 = ColorThemes.Dark.Card
        UIEffects.AddRoundCorner(frame, 6)
        ThemeManager.RegisterElement(frame, "Cards")
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 0, 24)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamSemibold
        label.TextColor3 = ColorThemes.Dark.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        ThemeManager.RegisterElement(label, "Texts")
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0.4, 0, 0, 24)
        valLabel.Position = UDim2.new(1, -10, 0, 4)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(defaultVal) .. (suffix or "")
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextColor3 = CurrentAccentColor
        valLabel.TextSize = 12
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = frame
        ThemeManager.RegisterElement(valLabel, "Accents")
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 6)
        track.Position = UDim2.new(0, 10, 1, -14)
        track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        UIEffects.AddRoundCorner(track, 3)
        track.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = CurrentAccentColor
        UIEffects.AddRoundCorner(fill, 3)
        fill.Parent = track
        ThemeManager.RegisterElement(fill, "Accents")
        
        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 12, 0, 12)
        handle.Position = UDim2.new((defaultVal - min) / (max - min), -6, 0.5, -6)
        handle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        UIEffects.AddRoundCorner(handle, 6)
        handle.Parent = track
        
        local function UpdateValue(inputPos)
            local scale = math.clamp((inputPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local rawVal = min + (scale * (max - min))
            local roundedVal = math.round(rawVal / step) * step
            roundedVal = math.clamp(roundedVal, min, max)
            
            fill.Size = UDim2.new((roundedVal - min) / (max - min), 0, 1, 0)
            handle.Position = UDim2.new((roundedVal - min) / (max - min), -6, 0.5, -6)
            valLabel.Text = tostring(roundedVal) .. (suffix or "")
            callback(roundedVal)
        end
        
        local isSliding = false
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                UpdateValue(input.Position.X)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateValue(input.Position.X)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)
        
        frame.Parent = parent
    end
    
    local function CreateButton(parent, labelText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 36)
        btn.BackgroundColor3 = ColorThemes.Dark.Card
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = ColorThemes.Dark.Text
        btn.TextSize = 13
        btn.Text = labelText
        UIEffects.AddRoundCorner(btn, 6)
        ThemeManager.RegisterElement(btn, "Cards")
        ThemeManager.RegisterElement(btn, "Texts")
        
        local btnStroke = UIEffects.AddStroke(btn, ColorThemes.Dark.Border, 1)
        ThemeManager.RegisterElement(btnStroke, "Borders")
        
        btn.MouseButton1Click:Connect(function(x, y)
            UIEffects.ApplyRipple(btn, Vector2.new(x, y))
            UIEffects.Vibrate()
            callback()
        end)
        
        btn.Parent = parent
    end
    
    local function CreateSelector(parent, labelText, options, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 36)
        frame.BackgroundColor3 = ColorThemes.Dark.Card
        UIEffects.AddRoundCorner(frame, 6)
        ThemeManager.RegisterElement(frame, "Cards")
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamSemibold
        label.TextColor3 = ColorThemes.Dark.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        ThemeManager.RegisterElement(label, "Texts")
        
        local display = Instance.new("TextButton")
        display.Size = UDim2.new(0.4, 0, 0.7, 0)
        display.Position = UDim2.new(1, -10, 0.5, 0)
        display.AnchorPoint = Vector2.new(1, 0.5)
        display.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        display.Text = tostring(defaultVal)
        display.TextColor3 = Color3.fromRGB(240, 240, 240)
        display.Font = Enum.Font.GothamSemibold
        display.TextSize = 12
        UIEffects.AddRoundCorner(display, 4)
        display.Parent = frame
        
        local activeIdx = table.find(options, defaultVal) or 1
        
        display.MouseButton1Click:Connect(function()
            UIEffects.Vibrate()
            activeIdx = activeIdx + 1
            if activeIdx > #options then activeIdx = 1 end
            display.Text = tostring(options[activeIdx])
            callback(options[activeIdx])
        end)
        
        frame.Parent = parent
    end
    
    local function ShowConfirmPopup(msg, onConfirm)
        local popupBg = Instance.new("Frame")
        popupBg.Size = UDim2.new(1, 0, 1, 0)
        popupBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        popupBg.BackgroundTransparency = 0.5
        popupBg.ZIndex = 2000
        popupBg.Parent = ScreenGui
        
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 260, 0, 130)
        popup.Position = UDim2.new(0.5, -130, 0.5, -65)
        popup.BackgroundColor3 = ColorThemes.Dark.Background
        UIEffects.AddRoundCorner(popup, 10)
        ThemeManager.RegisterElement(popup, "Backgrounds")
        popup.Parent = popupBg
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 60)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.BackgroundTransparency = 1
        label.Text = msg
        label.TextColor3 = ColorThemes.Dark.Text
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextWrapped = true
        label.Parent = popup
        ThemeManager.RegisterElement(label, "Texts")
        
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0, 100, 0, 32)
        yesBtn.Position = UDim2.new(0.5, -110, 1, -42)
        yesBtn.BackgroundColor3 = CurrentAccentColor
        yesBtn.Text = "Yes"
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesBtn.TextSize = 12
        UIEffects.AddRoundCorner(yesBtn, 6)
        yesBtn.Parent = popup
        ThemeManager.RegisterElement(yesBtn, "Accents")
        
        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0, 100, 0, 32)
        noBtn.Position = UDim2.new(0.5, 10, 1, -42)
        noBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        noBtn.Text = "No"
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
        noBtn.TextSize = 12
        UIEffects.AddRoundCorner(noBtn, 6)
        noBtn.Parent = popup
        
        yesBtn.MouseButton1Click:Connect(function()
            onConfirm()
            popupBg:Destroy()
        end)
        
        noBtn.MouseButton1Click:Connect(function()
            popupBg:Destroy()
        end)
    end

    --===================================================================================
    -- POPULATING TABS
    --===================================================================================
    
    -- 1. HOME TAB
    local homeScroll = TabFrames.Home:FindFirstChildOfClass("ScrollingFrame")
    CreateSection(homeScroll, "Quick Actions")
    CreateToggle(homeScroll, "Black Screen", Settings.BlackScreen, function(v)
        BlackScreen.Set(v)
    end)
    CreateToggle(homeScroll, "Clean GUI", Settings.HideGameGui, function(v)
        CleanGUI.Set(v)
    end)
    CreateToggle(homeScroll, "Show FPS Counter", Settings.ShowFPS, function(v)
        Settings.ShowFPS = v
        if FPSElementFrame then FPSElementFrame.Visible = v end
    end)
    CreateButton(homeScroll, "Quick Save Settings", function()
        SettingsManager.Save()
    end)
    
    -- 2. SETTINGS TAB
    local setScroll = TabFrames.Settings:FindFirstChildOfClass("ScrollingFrame")
    CreateSection(setScroll, "Theme Settings")
    CreateSelector(setScroll, "Active Theme", { "Dark", "Light" }, Settings.Theme, function(v)
        Settings.Theme = v
        ThemeManager.UpdateUI()
    end)
    CreateSelector(setScroll, "Accent Color", { "Red", "Blue", "Purple", "Green" }, Settings.AccentColor, function(v)
        Settings.AccentColor = v
        Settings.RainbowAccent = false
        CurrentAccentColor = AccentColors[v]
        ThemeManager.UpdateUI()
    end)
    CreateToggle(setScroll, "Rainbow Accent", Settings.RainbowAccent, function(v)
        Settings.RainbowAccent = v
        if not v then
            CurrentAccentColor = AccentColors[Settings.AccentColor]
            ThemeManager.UpdateUI()
        end
    end)
    
    CreateSection(setScroll, "Interface Customization")
    CreateSlider(setScroll, "GUI Scaling", 50, 150, Settings.GuiScale, "%", 5, function(v)
        Settings.GuiScale = v
        if not isMobile then
            local scale = v / 100
            MainFrame.Size = UDim2.new(0, math.floor(580 * scale), 0, math.floor(380 * scale))
        end
    end)
    CreateToggle(setScroll, "Background Shadow", Settings.Shadow, function(v)
        Settings.Shadow = v
        ThemeManager.UpdateUI()
    end)
    CreateSlider(setScroll, "Menu Transparency", 0, 80, Settings.MenuTransparency, "%", 5, function(v)
        Settings.MenuTransparency = v
        MainFrame.BackgroundTransparency = v / 100
    end)
    CreateToggle(setScroll, "Toggle All Animations", Settings.Animation, function(v)
        Settings.Animation = v
    end)

    -- 3. FPS TAB
    local fpsScroll = TabFrames.FPS:FindFirstChildOfClass("ScrollingFrame")
    CreateSection(fpsScroll, "Display Properties")
    CreateToggle(fpsScroll, "Enable Indicator", Settings.ShowFPS, function(v)
        Settings.ShowFPS = v
        if FPSElementFrame then FPSElementFrame.Visible = v end
    end)
    CreateSelector(fpsScroll, "Anchor Position", { "TopLeft", "TopRight", "BottomLeft", "BottomRight" }, Settings.FpsPosition, function(v)
        Settings.FpsPosition = v
        FPSCounter.UpdatePosition()
    end)
    CreateToggle(fpsScroll, "Show Average (5s)", Settings.ShowAverageFPS, function(v)
        Settings.ShowAverageFPS = v
    end)

    -- 4. GAME TAB
    local gameScroll = TabFrames.Game:FindFirstChildOfClass("ScrollingFrame")
    CreateSection(gameScroll, "Overlays & Displays")
    CreateToggle(gameScroll, "Fullscreen Black", Settings.BlackScreen, function(v)
        BlackScreen.Set(v)
    end)
    CreateToggle(gameScroll, "Hide Default UI", Settings.HideGameGui, function(v)
        CleanGUI.Set(v)
    end)
    CreateButton(gameScroll, "Restore All Native UI", function()
        CleanGUI.ForceRestore()
    end)

    -- 5. MOBILE TAB
    local mobScroll = TabFrames.Mobile:FindFirstChildOfClass("ScrollingFrame")
    CreateSection(mobScroll, "Touch Optimization")
    CreateSlider(mobScroll, "Mobile UI Scaling", 100, 200, Settings.MobileUIScale, "%", 10, function(v)
        Settings.MobileUIScale = v
        if isMobile then
            local scale = v / 100
            MainFrame.Size = UDim2.new(0, math.floor(580 * scale), 0, math.floor(380 * scale))
        end
    end)
    CreateToggle(mobScroll, "Haptic Vibe-on-Tap", Settings.VibrationOnTap, function(v)
        Settings.VibrationOnTap = v
    end)

    -- 6. SYSTEM TAB
    local sysScroll = TabFrames.System:FindFirstChildOfClass("ScrollingFrame")
    CreateSection(sysScroll, "System Profile")
    CreateButton(sysScroll, "Save Active Profile", function()
        SettingsManager.Save()
    end)
    CreateButton(sysScroll, "Reload Settings", function()
        SettingsManager.Load()
        MenuBuilder.Build() -- Rebuild entire menu with parsed configurations
    end)
    CreateButton(sysScroll, "Reset Settings Default", function()
        ShowConfirmPopup("Reset config parameters back to factory settings?", function()
            Settings = {}
            for k, v in pairs(DefaultSettings) do Settings[k] = v end
            SettingsManager.Save()
            MenuBuilder.Build()
        end)
    end)
    CreateButton(sysScroll, "Reset UI Center", function()
        MainFrame.Position = UDim2.new(0.5, -math.floor(290 * uiScaleVal), 0.5, -math.floor(190 * uiScaleVal))
        FloatBtn.Position = UDim2.new(0.9, -25, 0.2, -25)
    end)

    -- Auto Save Process loop
    task.spawn(function()
        while task.wait(5) do
            if Settings.AutoSave then
                Settings.MenuPosition = MainFrame.Position
                Settings.FloatingButtonPosition = FloatBtn.Position
                SettingsManager.Save()
            end
        end
    end)

    -- Active Tab Init
    SwitchTab("Home")
    ThemeManager.UpdateUI()
end

-- Run initialization
SettingsManager.Load()
MenuBuilder.Build()
