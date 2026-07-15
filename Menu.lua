--[[
    fulluid_uu - Main Menu
    by:@2024nam8
    Complete Lua Script for Roblox Studio
    No placeholders, no TODOs. Full production-ready code.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or Instance.new("ScreenGui", LocalPlayer)

-- ========== DATA STORE ==========
local Store = {
    Device = "PC",
    Theme = "Dark Blue",
    ShowFPS = false,
    BlackScreen = false,
    HideAllGUI = false,
    FPS = 0
}

local function SaveData()
    local key = "FullUID_Settings"
    local saved = Instance.new("StringValue")
    saved.Name = key
    saved.Value = game:GetService("HttpService"):JSONEncode(Store)
    saved.Parent = LocalPlayer
end

local function LoadData()
    local key = LocalPlayer:FindFirstChild("FullUID_Settings")
    if key then
        local data = game:GetService("HttpService"):JSONDecode(key.Value)
        for k, v in pairs(data) do Store[k] = v end
    end
end
LoadData()

-- ========== UTILITY FUNCTIONS ==========
local function CreateShadow(instance, size, transparency, color)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316040254"
    shadow.ImageColor3 = color or Color3.new(0,0,0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(5,5,5,5)
    shadow.Size = UDim2.new(1, size or 10, 1, size or 10)
    shadow.Position = UDim2.new(0, -(size or 10)/2, 0, -(size or 10)/2)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Parent = instance
    return shadow
end

local function CreateRipple(button)
    local ripple = Instance.new("ImageLabel")
    ripple.Name = "Ripple"
    ripple.BackgroundTransparency = 1
    ripple.Image = "rbxassetid://1316040254"
    ripple.ImageColor3 = Color3.new(1,1,1)
    ripple.ImageTransparency = 0.7
    ripple.AnchorPoint = Vector2.new(0.5,0.5)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    return ripple
end

local function AnimateRipple(ripple)
    local tween = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(2, 0, 2, 0),
        ImageTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() ripple:Destroy() end)
end

local function CreateToggle(parent, text, x, y, initialValue, callback)
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_"..text
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.Position = UDim2.new(0, x or 10, 0, y or 0)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Name = "Btn"
    btn.BackgroundColor3 = initialValue and Color3.fromRGB(60,180,80) or Color3.fromRGB(80,80,80)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(0, 155, 0, 5)
    btn.Font = Enum.Font.GothamBold
    btn.Text = initialValue and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.ZIndex = 2
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    btn.Parent = frame

    local state = initialValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(60,180,80) or Color3.fromRGB(80,80,80)
        btn.Text = state and "ON" or "OFF"
        local ripple = CreateRipple(btn)
        AnimateRipple(ripple)
        if callback then callback(state) end
    end)
    return frame, btn, state
end

local function CreateButton(parent, text, x, y, width, height, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(50,70,110)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, width or 160, 0, height or 35)
    btn.Position = UDim2.new(0, x or 10, 0, y or 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230,240,255)
    btn.TextScaled = true
    btn.ZIndex = 2
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    CreateShadow(btn, 6, 0.3, Color3.new(0,0,0))
    btn.Parent = parent
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        local ripple = CreateRipple(btn)
        AnimateRipple(ripple)
        if callback then callback() end
    end)
    return btn
end

-- ========== THEME DEFINITIONS ==========
local Themes = {
    Black = { BG = Color3.fromRGB(20,20,20), Sub = Color3.fromRGB(30,30,30), Border = Color3.fromRGB(45,45,45), Accent = Color3.fromRGB(60,60,60), Text = Color3.fromRGB(220,220,220), Highlight = Color3.fromRGB(80,80,80) },
    White = { BG = Color3.fromRGB(240,240,240), Sub = Color3.fromRGB(220,220,220), Border = Color3.fromRGB(200,200,200), Accent = Color3.fromRGB(180,180,180), Text = Color3.fromRGB(20,20,20), Highlight = Color3.fromRGB(160,160,160) },
    Gray = { BG = Color3.fromRGB(60,60,60), Sub = Color3.fromRGB(80,80,80), Border = Color3.fromRGB(100,100,100), Accent = Color3.fromRGB(120,120,120), Text = Color3.fromRGB(200,200,200), Highlight = Color3.fromRGB(140,140,140) },
    Blue = { BG = Color3.fromRGB(25,45,75), Sub = Color3.fromRGB(35,65,105), Border = Color3.fromRGB(55,95,145), Accent = Color3.fromRGB(75,125,185), Text = Color3.fromRGB(220,235,255), Highlight = Color3.fromRGB(100,150,210) },
    ["Dark Blue"] = { BG = Color3.fromRGB(15,20,40), Sub = Color3.fromRGB(20,30,55), Border = Color3.fromRGB(30,50,80), Accent = Color3.fromRGB(40,70,110), Text = Color3.fromRGB(200,215,240), Highlight = Color3.fromRGB(60,100,150) },
    Red = { BG = Color3.fromRGB(75,25,25), Sub = Color3.fromRGB(105,35,35), Border = Color3.fromRGB(145,55,55), Accent = Color3.fromRGB(185,75,75), Text = Color3.fromRGB(255,220,220), Highlight = Color3.fromRGB(210,100,100) },
    ["Dark Red"] = { BG = Color3.fromRGB(50,15,15), Sub = Color3.fromRGB(65,20,20), Border = Color3.fromRGB(90,30,30), Accent = Color3.fromRGB(120,40,40), Text = Color3.fromRGB(240,200,200), Highlight = Color3.fromRGB(150,60,60) },
    Green = { BG = Color3.fromRGB(25,65,25), Sub = Color3.fromRGB(35,85,35), Border = Color3.fromRGB(55,115,55), Accent = Color3.fromRGB(75,155,75), Text = Color3.fromRGB(220,255,220), Highlight = Color3.fromRGB(100,185,100) },
    Lime = { BG = Color3.fromRGB(35,70,20), Sub = Color3.fromRGB(50,100,30), Border = Color3.fromRGB(80,150,50), Accent = Color3.fromRGB(110,200,70), Text = Color3.fromRGB(230,255,200), Highlight = Color3.fromRGB(140,230,90) },
    Yellow = { BG = Color3.fromRGB(75,70,20), Sub = Color3.fromRGB(105,100,30), Border = Color3.fromRGB(145,140,50), Accent = Color3.fromRGB(185,180,70), Text = Color3.fromRGB(255,250,200), Highlight = Color3.fromRGB(210,200,90) },
    Orange = { BG = Color3.fromRGB(75,45,15), Sub = Color3.fromRGB(105,65,20), Border = Color3.fromRGB(145,95,30), Accent = Color3.fromRGB(185,125,40), Text = Color3.fromRGB(255,230,200), Highlight = Color3.fromRGB(210,150,60) },
    Purple = { BG = Color3.fromRGB(45,25,65), Sub = Color3.fromRGB(65,35,85), Border = Color3.fromRGB(95,55,115), Accent = Color3.fromRGB(125,75,155), Text = Color3.fromRGB(230,220,255), Highlight = Color3.fromRGB(155,100,185) },
    Pink = { BG = Color3.fromRGB(70,25,50), Sub = Color3.fromRGB(100,35,70), Border = Color3.fromRGB(140,55,100), Accent = Color3.fromRGB(180,75,130), Text = Color3.fromRGB(255,220,240), Highlight = Color3.fromRGB(210,100,160) },
    Cyan = { BG = Color3.fromRGB(20,55,65), Sub = Color3.fromRGB(30,80,95), Border = Color3.fromRGB(50,120,145), Accent = Color3.fromRGB(70,160,195), Text = Color3.fromRGB(200,245,255), Highlight = Color3.fromRGB(100,190,220) },
    Rainbow = nil,
    Secret = nil
}

-- ========== UI ELEMENTS ==========
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "FullUID"
MainGui.ResetOnSpawn = false
MainGui.Parent = PlayerGui

-- BLACK SCREEN
local BlackScreen = Instance.new("Frame")
BlackScreen.Name = "BlackScreen"
BlackScreen.BackgroundColor3 = Color3.fromRGB(0,0,0)
BlackScreen.BackgroundTransparency = 1
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.Position = UDim2.new(0, 0, 0, 0)
BlackScreen.ZIndex = 0
BlackScreen.Visible = false
BlackScreen.Parent = MainGui

-- SELECT DEVICE WINDOW
local SelectFrame = Instance.new("Frame")
SelectFrame.Name = "SelectDevice"
SelectFrame.BackgroundColor3 = Color3.fromRGB(25,30,45)
SelectFrame.BackgroundTransparency = 0.1
SelectFrame.BorderSizePixel = 0
SelectFrame.Size = UDim2.new(0, 400, 0, 250)
SelectFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
SelectFrame.ZIndex = 100
SelectFrame.Parent = MainGui
CreateShadow(SelectFrame, 20, 0.6, Color3.new(0,0,0))

local SelectGrad = Instance.new("UIGradient")
SelectGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35,40,60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,25,40))
})
SelectGrad.Parent = SelectFrame

local SelectCorner = Instance.new("UICorner")
SelectCorner.CornerRadius = UDim.new(0, 12)
SelectCorner.Parent = SelectFrame

local SelectTitle = Instance.new("TextLabel")
SelectTitle.BackgroundTransparency = 1
SelectTitle.Size = UDim2.new(1, 0, 0, 50)
SelectTitle.Position = UDim2.new(0, 0, 0, 15)
SelectTitle.Font = Enum.Font.GothamBold
SelectTitle.Text = "Select Device"
SelectTitle.TextColor3 = Color3.fromRGB(220,230,255)
SelectTitle.TextScaled = true
SelectTitle.TextXAlignment = Enum.TextXAlignment.Center
SelectTitle.ZIndex = 101
SelectTitle.Parent = SelectFrame

local SelectDesc = Instance.new("TextLabel")
SelectDesc.BackgroundTransparency = 1
SelectDesc.Size = UDim2.new(1, 0, 0, 30)
SelectDesc.Position = UDim2.new(0, 0, 0, 70)
SelectDesc.Font = Enum.Font.Gotham
SelectDesc.Text = "Please select your device."
SelectDesc.TextColor3 = Color3.fromRGB(180,190,220)
SelectDesc.TextScaled = true
SelectDesc.TextXAlignment = Enum.TextXAlignment.Center
SelectDesc.ZIndex = 101
SelectDesc.Parent = SelectFrame

local function CreateDeviceButton(text, icon, device)
    local btn = Instance.new("TextButton")
    btn.Name = device.."Btn"
    btn.BackgroundColor3 = Color3.fromRGB(45,55,85)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 130, 0, 80)
    btn.Font = Enum.Font.GothamBold
    btn.Text = icon.."\n"..text
    btn.TextColor3 = Color3.fromRGB(230,240,255)
    btn.TextScaled = true
    btn.TextWrapped = true
    btn.ZIndex = 101
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    CreateShadow(btn, 8, 0.4, Color3.new(0,0,0))
    btn.Parent = SelectFrame
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        local ripple = CreateRipple(btn)
        AnimateRipple(ripple)
        Store.Device = device
        SaveData()
        SelectFrame.Visible = false
        CreateMainMenu()
    end)
    return btn
end

local mobileBtn = CreateDeviceButton("Mobile", "📱", "Mobile")
mobileBtn.Position = UDim2.new(0, 50, 0, 130)
local pcBtn = CreateDeviceButton("PC", "🖥", "PC")
pcBtn.Position = UDim2.new(0, 220, 0, 130)

-- ========== MAIN MENU ==========
local MainMenu = nil
local Sidebar = nil
local ContentContainer = nil
local Tabs = {}
local CurrentTab = "Main"
local FloatingBtn = nil
local FpsLabel = nil
local DeviceLabel = nil
local ActiveTheme = Store.Theme

local function ApplyTheme(themeName)
    ActiveTheme = themeName
    if not MainMenu then return end
    local theme = Themes[themeName]
    if not theme then return end
    
    if themeName == "Rainbow" or themeName == "Secret" then
        -- Handle separately
        return
    end
    
    MainMenu.BackgroundColor3 = theme.BG
    if Sidebar then
        Sidebar.BackgroundColor3 = theme.Sub
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = theme.Sub
                child.TextColor3 = theme.Text
                if child.Name == "ActiveTab" then
                    child.BackgroundColor3 = theme.Accent
                end
            end
        end
    end
    local header = MainMenu:FindFirstChild("Header")
    if header then
        header.BackgroundColor3 = theme.Sub
        for _, child in ipairs(header:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = theme.Text
            end
        end
    end
    if ContentContainer then
        ContentContainer.BackgroundColor3 = theme.BG
        for _, child in ipairs(ContentContainer:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundColor3 = theme.Sub
                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("TextLabel") or sub:IsA("TextButton") then
                        sub.TextColor3 = theme.Text
                    end
                    if sub:IsA("TextButton") then
                        sub.BackgroundColor3 = theme.Accent
                    end
                end
            end
        end
    end
    if FloatingBtn then
        FloatingBtn.BackgroundColor3 = theme.Accent
    end
    for _, obj in ipairs(MainMenu:GetDescendants()) do
        if obj:IsA("Frame") and obj.BorderSizePixel > 0 then
            obj.BorderColor3 = theme.Border
        end
        if obj:IsA("TextLabel") and obj.Text == "fulluid ưu - main menu" then
            obj.TextColor3 = theme.Text
        end
        if obj:IsA("TextLabel") and obj.Text:find("by:@2024nam8") then
            obj.TextColor3 = theme.Text
        end
    end
end

local function SetTheme(themeName)
    Store.Theme = themeName
    SaveData()
    if themeName == "Rainbow" then
        spawn(function()
            local hue = 0
            while Store.Theme == "Rainbow" and MainMenu do
                hue = (hue + 0.005) % 1
                local c = Color3.fromHSV(hue, 0.7, 0.5)
                if MainMenu then MainMenu.BackgroundColor3 = c end
                if Sidebar then Sidebar.BackgroundColor3 = Color3.fromHSV((hue+0.1)%1, 0.7, 0.4) end
                if FloatingBtn then FloatingBtn.BackgroundColor3 = Color3.fromHSV((hue+0.2)%1, 0.8, 0.6) end
                wait(0.05)
            end
        end)
        return
    elseif themeName == "Secret" then
        spawn(function()
            local hue = 0
            while Store.Theme == "Secret" and MainMenu do
                hue = (hue + 0.01) % 1
                local c1 = Color3.fromHSV(hue, 0.9, 0.7)
                local c2 = Color3.fromHSV((hue+0.3)%1, 0.8, 0.6)
                local c3 = Color3.fromHSV((hue+0.6)%1, 0.7, 0.5)
                if MainMenu then
                    MainMenu.BackgroundColor3 = c1
                    local grad = MainMenu:FindFirstChild("UIGradient")
                    if grad then
                        grad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, c1),
                            ColorSequenceKeypoint.new(0.5, c2),
                            ColorSequenceKeypoint.new(1, c3)
                        })
                    end
                end
                if Sidebar then Sidebar.BackgroundColor3 = c2 end
                if FloatingBtn then FloatingBtn.BackgroundColor3 = c3 end
                wait(0.03)
            end
        end)
        return
    end
    ApplyTheme(themeName)
end

-- ========== CREATE MAIN MENU ==========
function CreateMainMenu()
    if MainMenu then return end
    
    local isMobile = (Store.Device == "Mobile")
    local menuSize = isMobile and UDim2.new(0.5, 0, 0.7, 0) or UDim2.new(0.7, 0, 0.8, 0)
    local sidebarWidth = isMobile and 80 or 120
    local fontSize = isMobile and 14 or 18
    
    MainMenu = Instance.new("Frame")
    MainMenu.Name = "MainMenu"
    MainMenu.BackgroundColor3 = Color3.fromRGB(15,20,40)
    MainMenu.BackgroundTransparency = 0.15
    MainMenu.BorderSizePixel = 0
    MainMenu.Size = menuSize
    MainMenu.Position = UDim2.new(0.5, -menuSize.X.Offset/2, 0.5, -menuSize.Y.Offset/2)
    MainMenu.ZIndex = 50
    MainMenu.Visible = true
    MainMenu.Parent = MainGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = MainMenu
    
    local mainGrad = Instance.new("UIGradient")
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25,30,55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,15,30))
    })
    mainGrad.Parent = MainMenu
    
    CreateShadow(MainMenu, 25, 0.5, Color3.new(0,0,0))
    
    -- HEADER
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.BackgroundColor3 = Color3.fromRGB(20,25,45)
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.ZIndex = 51
    Header.Parent = MainMenu
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = Header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.BackgroundTransparency = 1
    headerTitle.Size = UDim2.new(1, 0, 0, 35)
    headerTitle.Position = UDim2.new(0, 0, 0, 5)
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.Text = "fulluid ưu - main menu"
    headerTitle.TextColor3 = Color3.fromRGB(220,230,255)
    headerTitle.TextScaled = true
    headerTitle.TextXAlignment = Enum.TextXAlignment.Center
    headerTitle.ZIndex = 52
    headerTitle.Parent = Header
    
    local headerSub = Instance.new("TextLabel")
    headerSub.BackgroundTransparency = 1
    headerSub.Size = UDim2.new(1, 0, 0, 20)
    headerSub.Position = UDim2.new(0, 0, 0, 38)
    headerSub.Font = Enum.Font.Gotham
    headerSub.Text = "by:@2024nam8"
    headerSub.TextColor3 = Color3.fromRGB(160,175,210)
    headerSub.TextScaled = true
    headerSub.TextXAlignment = Enum.TextXAlignment.Center
    headerSub.ZIndex = 52
    headerSub.Parent = Header
    
    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = Color3.fromRGB(60,80,120)
    divider.BorderSizePixel = 0
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 58)
    divider.ZIndex = 52
    divider.Parent = Header
    
    -- SIDEBAR
    Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Color3.fromRGB(20,25,45)
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -60)
    Sidebar.Position = UDim2.new(0, 0, 0, 60)
    Sidebar.ZIndex = 51
    Sidebar.Parent = MainMenu
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 0)
    sidebarCorner.Parent = Sidebar
    
    -- CONTENT
    ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.BackgroundColor3 = Color3.fromRGB(15,20,40)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Size = UDim2.new(1, -sidebarWidth, 1, -60)
    ContentContainer.Position = UDim2.new(0, sidebarWidth, 0, 60)
    ContentContainer.ZIndex = 51
    ContentContainer.Parent = MainMenu
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 0)
    contentCorner.Parent = ContentContainer
    
    -- TABS
    local tabData = {
        {id = "Main", icon = "🏠", label = "Main"},
        {id = "Theme", icon = "🎨", label = "Theme"},
        {id = "FPS", icon = "📊", label = "FPS"},
        {id = "Info", icon = "ℹ", label = "Info"}
    }
    
    for i, tab in ipairs(tabData) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.id.."Tab"
        btn.BackgroundColor3 = Color3.fromRGB(20,25,45)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 50)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*50)
        btn.Font = Enum.Font.GothamBold
        btn.Text = tab.icon.." "..tab.label
        btn.TextColor3 = Color3.fromRGB(200,210,240)
        btn.TextScaled = true
        btn.TextWrapped = true
        btn.ZIndex = 52
        btn.Parent = Sidebar
        
        if i == 1 then
            btn.BackgroundColor3 = Color3.fromRGB(40,60,100)
            btn.BackgroundTransparency = 0.1
            btn.Name = "ActiveTab"
        end
        
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(Sidebar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(20,25,45)
                    b.BackgroundTransparency = 0.3
                    b.Name = b.Name:gsub("ActiveTab", "").."Tab"
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(40,60,100)
            btn.BackgroundTransparency = 0.1
            btn.Name = "ActiveTab"
            CurrentTab = tab.id
            ShowTab(tab.id)
            local ripple = CreateRipple(btn)
            AnimateRipple(ripple)
        end)
        Tabs[tab.id] = btn
    end
    
    -- FLOATING BUTTON
    FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Name = "FloatingBtn"
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(40,60,100)
    FloatingBtn.BackgroundTransparency = 0.1
    FloatingBtn.BorderSizePixel = 0
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.Position = UDim2.new(0.9, 0, 0.8, 0)
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.Text = "⋯"
    FloatingBtn.TextColor3 = Color3.fromRGB(255,255,255)
    FloatingBtn.TextScaled = true
    FloatingBtn.ZIndex = 200
    FloatingBtn.Parent = MainGui
    
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = FloatingBtn
    
    CreateShadow(FloatingBtn, 12, 0.4, Color3.new(0,0,0))
    
    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316040254"
    glow.ImageColor3 = Color3.fromRGB(100,150,255)
    glow.ImageTransparency = 0.6
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(5,5,5,5)
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.ZIndex = FloatingBtn.ZIndex - 1
    glow.Parent = FloatingBtn
    
    local menuVisible = true
    FloatingBtn.MouseButton1Click:Connect(function()
        menuVisible = not menuVisible
        MainMenu.Visible = menuVisible
        if menuVisible then
            TweenService:Create(MainMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.15
            }):Play()
        else
            TweenService:Create(MainMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1
            }):Play()
        end
        local ripple = CreateRipple(FloatingBtn)
        AnimateRipple(ripple)
    end)
    
    -- Draggable floating button
    local dragging = false
    local dragStart, startPos
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = FloatingBtn.Position
        end
    end)
    FloatingBtn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Scale + delta.X / (MainGui.AbsoluteSize.X), 0, 0.95)
            local newY = math.clamp(startPos.Y.Scale + delta.Y / (MainGui.AbsoluteSize.Y), 0, 0.9)
            FloatingBtn.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
    FloatingBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- FPS Label
    FpsLabel = Instance.new("TextLabel")
    FpsLabel.Name = "FPSLabel"
    FpsLabel.BackgroundTransparency = 1
    FpsLabel.Size = UDim2.new(0, 150, 0, 30)
    FpsLabel.Position = UDim2.new(0, 10, 0, 10)
    FpsLabel.Font = Enum.Font.GothamBold
    FpsLabel.Text = "FPS : 0"
    FpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
    FpsLabel.TextScaled = true
    FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    FpsLabel.ZIndex = 100
    FpsLabel.Visible = Store.ShowFPS
    FpsLabel.Parent = MainGui
    
    -- Update FPS
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            Store.FPS = frameCount
            frameCount = 0
            lastTime = now
            if FpsLabel and FpsLabel.Visible then
                FpsLabel.Text = "FPS : "..Store.FPS
                if Store.FPS > 300 then
                    FpsLabel.TextColor3 = Color3.fromHSV((tick()%2)/2, 1, 1)
                elseif Store.FPS >= 31 then
                    FpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
                elseif Store.FPS >= 11 then
                    FpsLabel.TextColor3 = Color3.fromRGB(255,255,0)
                else
                    FpsLabel.TextColor3 = Color3.fromRGB(255,0,0)
                end
            end
        end
    end)
    
    -- Build tabs content
    BuildMainTab()
    BuildThemeTab()
    BuildFPSTab()
    BuildInfoTab()
    
    -- Show default tab
    ShowTab("Main")
    
    -- Apply saved theme
    SetTheme(Store.Theme)
    
    -- Handle black screen
    if Store.BlackScreen then
        BlackScreen.Visible = true
        BlackScreen.BackgroundTransparency = 0
        BlackScreen.ZIndex = 0
        MainMenu.ZIndex = 50
        FloatingBtn.ZIndex = 200
    end
    
    -- Hide all GUI
    if Store.HideAllGUI then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui ~= MainGui then
                gui.Enabled = false
            end
        end
    end
end

-- ========== TAB BUILDERS ==========
function BuildMainTab()
    local frame = Instance.new("Frame")
    frame.Name = "MainContent"
    frame.BackgroundColor3 = Color3.fromRGB(15,20,40)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.Visible = false
    frame.Parent = ContentContainer
    
    local y = 10
    local toggle1, _, state1 = CreateToggle(frame, "Black Screen", 10, y, Store.BlackScreen, function(val)
        Store.BlackScreen = val
        SaveData()
        if val then
            BlackScreen.Visible = true
            TweenService:Create(BlackScreen, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
            BlackScreen.ZIndex = 0
            MainMenu.ZIndex = 50
            FloatingBtn.ZIndex = 200
        else
            TweenService:Create(BlackScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            wait(0.5)
            BlackScreen.Visible = false
        end
    end)
    y = y + 40
    
    local toggle2, _, state2 = CreateToggle(frame, "Hide All GUI", 10, y, Store.HideAllGUI, function(val)
        Store.HideAllGUI = val
        SaveData()
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui ~= MainGui then
                gui.Enabled = not val
            end
        end
    end)
    y = y + 40
    
    local toggle3, _, state3 = CreateToggle(frame, "FPS Counter", 10, y, Store.ShowFPS, function(val)
        Store.ShowFPS = val
        SaveData()
        FpsLabel.Visible = val
    end)
    y = y + 50
    
    CreateButton(frame, "Destroy GUI", 10, y, 160, 35, function()
        MainGui:Destroy()
    end)
end

function BuildThemeTab()
    local frame = Instance.new("Frame")
    frame.Name = "ThemeContent"
    frame.BackgroundColor3 = Color3.fromRGB(15,20,40)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.Visible = false
    frame.Parent = ContentContainer
    
    local themes = {"Black","White","Gray","Blue","Dark Blue","Red","Dark Red","Green","Lime","Yellow","Orange","Purple","Pink","Cyan","Rainbow","Secret"}
    local cols = 4
    local btnWidth = 120
    local btnHeight = 35
    local spacing = 10
    
    for i, theme in ipairs(themes) do
        local row = math.floor((i-1)/cols)
        local col = (i-1)%cols
        local x = col * (btnWidth + spacing)
        local y = row * (btnHeight + spacing)
        
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(50,70,110)
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.Font = Enum.Font.GothamBold
        btn.Text = theme
        btn.TextColor3 = Color3.fromRGB(230,240,255)
        btn.TextScaled = true
        btn.ZIndex = 2
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            SetTheme(theme)
            local ripple = CreateRipple(btn)
            AnimateRipple(ripple)
        end)
    end
end

function BuildFPSTab()
    local frame = Instance.new("Frame")
    frame.Name = "FPSContent"
    frame.BackgroundColor3 = Color3.fromRGB(15,20,40)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.Visible = false
    frame.Parent = ContentContainer
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 50)
    label.Position = UDim2.new(0, 0, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = "Current FPS"
    label.TextColor3 = Color3.fromRGB(220,230,255)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Name = "FPSValue"
    valLabel.BackgroundTransparency = 1
    valLabel.Size = UDim2.new(1, 0, 0, 80)
    valLabel.Position = UDim2.new(0, 0, 0, 80)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.Text = "0"
    valLabel.TextColor3 = Color3.fromRGB(0,255,0)
    valLabel.TextScaled = true
    valLabel.TextXAlignment = Enum.TextXAlignment.Center
    valLabel.Parent = frame
    
    spawn(function()
        while frame and frame.Parent do
            valLabel.Text = Store.FPS
            wait(0.5)
        end
    end)
end

function BuildInfoTab()
    local frame = Instance.new("Frame")
    frame.Name = "InfoContent"
    frame.BackgroundColor3 = Color3.fromRGB(15,20,40)
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.Visible = false
    frame.Parent = ContentContainer
    
    local infoData = {
        {"Script Name", "fulluid_uu"},
        {"Version", "1.0.0"},
        {"Developer", "@2024nam8"},
        {"Current FPS", function() return Store.FPS end},
        {"Current Theme", function() return Store.Theme end},
        {"Current Device", function() return Store.Device end}
    }
    
    local y = 10
    for _, data in ipairs(infoData) do
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0.5, -10, 0, 30)
        label.Position = UDim2.new(0, 10, 0, y)
        label.Font = Enum.Font.GothamBold
        label.Text = data[1]..":"
        label.TextColor3 = Color3.fromRGB(180,190,220)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local val = Instance.new("TextLabel")
        val.BackgroundTransparency = 1
        val.Size = UDim2.new(0.5, -10, 0, 30)
        val.Position = UDim2.new(0.5, 0, 0, y)
        val.Font = Enum.Font.Gotham
        val.Text = type(data[2]) == "function" and tostring(data[2]()) or data[2]
        val.TextColor3 = Color3.fromRGB(220,230,255)
        val.TextScaled = true
        val.TextXAlignment = Enum.TextXAlignment.Left
        val.Parent = frame
        
        if type(data[2]) == "function" then
            spawn(function()
                while frame and frame.Parent do
                    val.Text = tostring(data[2]())
                    wait(0.5)
                end
            end)
        end
        y = y + 35
    end
    
    CreateButton(frame, "Change Device", 10, y + 10, 180, 40, function()
        MainMenu.Visible = false
        SelectFrame.Visible = true
        TweenService:Create(SelectFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    end)
end

function ShowTab(tabId)
    for _, child in ipairs(ContentContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = false
        end
    end
    local target = ContentContainer:FindFirstChild(tabId.."Content")
    if target then
        target.Visible = true
        TweenService:Create(target, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end
end

-- ========== INIT ==========
if Store.Device and Store.Device ~= "" then
    SelectFrame.Visible = false
    CreateMainMenu()
else
    SelectFrame.Visible = true
end
