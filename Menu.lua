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
    
    -- Responsive calculation for Main Window
