-- ==============================================================================
-- BLOX LOOT MONSTER ESP (MOBILE OPTIMIZED)
-- ==============================================================================
-- Features: Auto Detect, Filtering, Tracers, Highlights, Billboard, Draggable UI
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Configurations
local Config = {
    Master = true,
    ShowName = true,
    ShowHP = true,
    ShowDistance = true,
    ShowLevel = true,
    Highlight = true,
    Billboard = true,
    Tracer = false,
    MaxDistance = 2000,
    SelectedMonsters = {}, 
    DetectedTypes = {}
}

local Cache = {} -- Stores active ESP objects

-- ==============================================================================
-- UI CREATION (NO EXTERNAL LIBS)
-- ==============================================================================

local function ProtectUI(gui)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
    pcall(function()
        gui.Parent = CoreGui
    end)
    if not gui.Parent then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxLootMonsterESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ProtectUI(ScreenGui)

-- Dragging Function (Supports Mobile Touch & Mouse)
local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Floating Button
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 40, 0, 40)
FloatBtn.Position = UDim2.new(0, 10, 0.5, -20)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
FloatBtn.Text = "👁"
FloatBtn.TextScaled = true
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.UICorner = Instance.new("UICorner", FloatBtn)
FloatBtn.UICorner.CornerRadius = UDim.new(1, 0)
FloatBtn.UIStroke = Instance.new("UIStroke", FloatBtn)
FloatBtn.UIStroke.Color = Color3.fromRGB(0, 255, 150)
FloatBtn.UIStroke.Thickness = 2
FloatBtn.Parent = ScreenGui
MakeDraggable(FloatBtn, FloatBtn)

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
MakeDraggable(Header, MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👁 BLOX LOOT MONSTER ESP"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
CollapseBtn.Position = UDim2.new(1, -65, 0, 2)
CollapseBtn.BackgroundTransparency = 1
CollapseBtn.Text = "_"
CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 16
CollapseBtn.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 0, 20)
StatusText.Position = UDim2.new(0, 10, 0, 40)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Scanning... | Found: 0"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = MainFrame

-- Tab System
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -65)
TabContainer.Position = UDim2.new(0, 0, 0, 65)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local SettingsTab = Instance.new("ScrollingFrame")
SettingsTab.Size = UDim2.new(0.5, 0, 1, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.ScrollBarThickness = 3
SettingsTab.Parent = TabContainer

local UIListSettings = Instance.new("UIListLayout", SettingsTab)
UIListSettings.SortOrder = Enum.SortOrder.LayoutOrder
UIListSettings.Padding = UDim.new(0, 5)

local MonsterTab = Instance.new("Frame")
MonsterTab.Size = UDim2.new(0.5, 0, 1, 0)
MonsterTab.Position = UDim2.new(0.5, 0, 0, 0)
MonsterTab.BackgroundTransparency = 1
MonsterTab.Parent = TabContainer

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 25)
SearchBox.Position = UDim2.new(0, 5, 0, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "Search Monster..."
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.Parent = MonsterTab
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

local SelectAllBtn = Instance.new("TextButton")
SelectAllBtn.Size = UDim2.new(0.5, -7, 0, 20)
SelectAllBtn.Position = UDim2.new(0, 5, 0, 30)
SelectAllBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SelectAllBtn.TextColor3 = Color3.new(1, 1, 1)
SelectAllBtn.Text = "Select All"
SelectAllBtn.Font = Enum.Font.Gotham
SelectAllBtn.TextSize = 10
SelectAllBtn.Parent = MonsterTab
Instance.new("UICorner", SelectAllBtn)

local ClearAllBtn = Instance.new("TextButton")
ClearAllBtn.Size = UDim2.new(0.5, -7, 0, 20)
ClearAllBtn.Position = UDim2.new(0.5, 2, 0, 30)
ClearAllBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ClearAllBtn.TextColor3 = Color3.new(1, 1, 1)
ClearAllBtn.Text = "Clear All"
ClearAllBtn.Font = Enum.Font.Gotham
ClearAllBtn.TextSize = 10
ClearAllBtn.Parent = MonsterTab
Instance.new("UICorner", ClearAllBtn)

local MonsterScroll = Instance.new("ScrollingFrame")
MonsterScroll.Size = UDim2.new(1, 0, 1, -60)
MonsterScroll.Position = UDim2.new(0, 0, 0, 55)
MonsterScroll.BackgroundTransparency = 1
MonsterScroll.ScrollBarThickness = 3
MonsterScroll.Parent = MonsterTab
local UIListMonsters = Instance.new("UIListLayout", MonsterScroll)
UIListMonsters.SortOrder = Enum.SortOrder.Name
UIListMonsters.Padding = UDim.new(0, 3)

-- UI Helpers
local function CreateToggle(parent, text, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -30, 0.5, -10)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    ToggleBtn.MouseButton1Click:Connect(function()
        if type(Config[configKey]) == "boolean" then
            Config[configKey] = not Config[configKey]
            ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
            if callback then callback(Config[configKey]) end
        end
    end)
    return ToggleBtn
end

local function CreateSlider(parent, text, min, max, configKey)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 15)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. Config[configKey]
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBG = Instance.new("TextButton")
    SliderBG.Size = UDim2.new(1, -20, 0, 10)
    SliderBG.Position = UDim2.new(0, 10, 0, 25)
    SliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderBG.Text = ""
    SliderBG.Parent = Frame
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    Fill.Parent = SliderBG
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        Config[configKey] = val
        Label.Text = text .. ": " .. val
    end

    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Populate Settings
CreateToggle(SettingsTab, "Master ESP", "Master")
CreateToggle(SettingsTab, "Show Name", "ShowName")
CreateToggle(SettingsTab, "Show HP", "ShowHP")
CreateToggle(SettingsTab, "Show Distance", "ShowDistance")
CreateToggle(SettingsTab, "Show Level", "ShowLevel")
CreateToggle(SettingsTab, "Use Highlight", "Highlight")
CreateToggle(SettingsTab, "Use Billboard", "Billboard")
CreateToggle(SettingsTab, "Show Tracers", "Tracer")
CreateSlider(SettingsTab, "Max Distance", 100, 10000, "MaxDistance")

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -20, 0, 25)
RefreshBtn.Position = UDim2.new(0, 10, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.Text = "Manual Refresh"
RefreshBtn.Font = Enum.Font.Gotham
RefreshBtn.TextSize = 12
RefreshBtn.Parent = SettingsTab
Instance.new("UICorner", RefreshBtn)

-- UI Interactions
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)

local collapsed = false
CollapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    MainFrame.Size = collapsed and UDim2.new(0, 320, 0, 35) or UDim2.new(0, 320, 0, 450)
    TabContainer.Visible = not collapsed
end)

-- Monster List Logic
local MonsterToggles = {}

local function UpdateMonsterListUI()
    for _, child in pairs(MonsterScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    MonsterToggles = {}
    
    local filter = string.lower(SearchBox.Text)
    local sortedNames = {}
    for name, _ in pairs(Config.DetectedTypes) do
        if filter == "" or string.find(string.lower(name), filter) then
            table.insert(sortedNames, name)
        end
    end
    table.sort(sortedNames)
    
    for _, name in ipairs(sortedNames) do
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 25)
        Frame.Position = UDim2.new(0, 5, 0, 0)
        Frame.BackgroundTransparency = 1
        Frame.Name = name
        Frame.Parent = MonsterScroll
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -30, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = " " .. name
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextTruncate = Enum.TextTruncate.AtEnd
        Label.Parent = Frame
        
        local Check = Instance.new("TextButton")
        Check.Size = UDim2.new(0, 15, 0, 15)
        Check.Position = UDim2.new(1, -20, 0.5, -7.5)
        Check.BackgroundColor3 = Config.SelectedMonsters[name] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
        Check.Text = ""
        Check.Parent = Frame
        Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 3)
        
        Check.MouseButton1Click:Connect(function()
            Config.SelectedMonsters[name] = not Config.SelectedMonsters[name]
            Check.BackgroundColor3 = Config.SelectedMonsters[name] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
        end)
        MonsterToggles[name] = Check
    end
end

SearchBox.Changed:Connect(function(prop)
    if prop == "Text" then UpdateMonsterListUI() end
end)

SelectAllBtn.MouseButton1Click:Connect(function()
    for name, _ in pairs(Config.DetectedTypes) do Config.SelectedMonsters[name] = true end
    UpdateMonsterListUI()
end)

ClearAllBtn.MouseButton1Click:Connect(function()
    for name, _ in pairs(Config.DetectedTypes) do Config.SelectedMonsters[name] = false end
    UpdateMonsterListUI()
end)

-- ==============================================================================
-- ESP CORE LOGIC
-- ==============================================================================

local function GetHealthInfo(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    local hpVal = model:FindFirstChild("Health") or model:FindFirstChild("HP")
    local maxHpVal = model:FindFirstChild("MaxHealth") or model:FindFirstChild("MaxHP")
    if hpVal and hpVal:IsA("NumberValue") then
        local max = (maxHpVal and maxHpVal:IsA("NumberValue")) and maxHpVal.Value or hpVal.Value
        return hpVal.Value, max
    end
    -- Fallback via attributes
    local attrHp = model:GetAttribute("Health") or model:GetAttribute("HP")
    if attrHp then
        local attrMax = model:GetAttribute("MaxHealth") or model:GetAttribute("MaxHP") or attrHp
        return attrHp, attrMax
    end
    return nil, nil
end

local function GetLevel(model)
    local lvVal = model:FindFirstChild("Level") or model:FindFirstChild("Lv")
    if lvVal and (lvVal:IsA("NumberValue") or lvVal:IsA("IntValue")) then return lvVal.Value end
    local attrLv = model:GetAttribute("Level") or model:GetAttribute("Lv")
    if attrLv then return attrLv end
    -- Check Name for level e.g. "[Lv. 50] Bandit"
    local match = string.match(model.Name, "%d+")
    if match then return match end
    return "??"
end

local function GetColorByHP(current, max)
    if not current or not max or max == 0 then return Color3.fromRGB(0, 255, 150) end
    local pct = current / max
    if pct > 0.6 then return Color3.fromRGB(0, 255, 150) -- Green
    elseif pct > 0.3 then return Color3.fromRGB(255, 200, 0) -- Yellow
    else return Color3.fromRGB(255, 50, 50) -- Red
    end
end

-- Create ESP for a specific Monster
local function AddESP(model)
    if Cache[model] then return end
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local cleanName = string.gsub(model.Name, "%[.-%]%s*", "") -- Remove level tags from name for cleaner sorting
    
    if not Config.DetectedTypes[cleanName] then
        Config.DetectedTypes[cleanName] = true
        Config.SelectedMonsters[cleanName] = true -- Auto select new types
        UpdateMonsterListUI()
    end

    -- BillboardGui
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP_BB"
    bg.Adornee = root
    bg.Size = UDim2.new(0, 200, 0, 60)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = CoreGui -- Safer from deletion than model

    local textLabel = Instance.new("TextLabel", bg)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
    textLabel.TextStrokeTransparency = 0
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.RichText = true

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.2
    hl.Parent = CoreGui

    -- Tracer (GUI Line)
    local tracer = Instance.new("Frame")
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.BorderSizePixel = 0
    tracer.BackgroundColor3 = Color3.new(1,1,1)
    tracer.Visible = false
    tracer.Parent = ScreenGui

    local conn
    conn = model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if Cache[model] then
                pcall(function() Cache[model].bg:Destroy() end)
                pcall(function() Cache[model].hl:Destroy() end)
                pcall(function() Cache[model].tracer:Destroy() end)
                conn:Disconnect()
                Cache[model] = nil
            end
        end
    end)

    Cache[model] = {
        model = model,
        root = root,
        bg = bg,
        textLabel = textLabel,
        hl = hl,
        tracer = tracer,
        conn = conn,
        cleanName = cleanName
    }
end

-- Detection Logic
local function CheckAndAddMonster(obj)
    if not obj:IsA("Model") then return end
    if obj == LocalPlayer.Character then return end
    
    -- Filter out players
    if Players:GetPlayerFromCharacter(obj) then return end
    
    -- Needs a body part
    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
    if not root then return end
    
    -- Needs signs of being a monster (Humanoid or Health value)
    local hum = obj:FindFirstChildOfClass("Humanoid")
    local hpVal = obj:FindFirstChild("Health") or obj:FindFirstChild("HP")
    
    if hum or hpVal then
        -- Avoid dead monsters
        local hp, max = GetHealthInfo(obj)
        if hp and hp <= 0 then return end
        
        AddESP(obj)
    end
end

local function ScanWorkspace()
    for _, obj in pairs(Workspace:GetDescendants()) do
        CheckAndAddMonster(obj)
    end
end

-- Refresh Button
RefreshBtn.MouseButton1Click:Connect(function()
    StatusText.Text = "Scanning manually..."
    task.spawn(ScanWorkspace)
end)

-- Auto Detect New Spawns
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.5) -- wait for model to fully load its parts
    pcall(function() CheckAndAddMonster(obj) end)
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    local count = 0
    local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    for model, data in pairs(Cache) do
        -- Check validity
        if not model.Parent or not data.root or not data.root.Parent then
            pcall(function() data.bg:Destroy() end)
            pcall(function() data.hl:Destroy() end)
            pcall(function() data.tracer:Destroy() end)
            if data.conn then data.conn:Disconnect() end
            Cache[model] = nil
            continue
        end

        local hp, maxHp = GetHealthInfo(model)
        if hp and hp <= 0 then
            data.bg.Enabled = false
            data.hl.Enabled = false
            data.tracer.Visible = false
            continue 
        end

        local dist = (Camera.CFrame.Position - data.root.Position).Magnitude
        local isSelected = Config.SelectedMonsters[data.cleanName] == true
        
        if Config.Master and isSelected and dist <= Config.MaxDistance then
            count = count + 1
            local color = GetColorByHP(hp, maxHp)
            local hexColor = string.format("#%02X%02X%02X", color.R*255, color.G*255, color.B*255)

            -- Billboard Update
            if Config.Billboard then
                data.bg.Enabled = true
                local lines = {}
                if Config.ShowName then table.insert(lines, string.format("<font color='%s'>[%s]</font>", hexColor, data.cleanName)) end
                if Config.ShowHP and hp and maxHp then 
                    table.insert(lines, string.format("HP: %d/%d", math.floor(hp), math.floor(maxHp))) 
                end
                if Config.ShowLevel then table.insert(lines, "Lv: " .. tostring(GetLevel(model))) end
                if Config.ShowDistance then table.insert(lines, string.format("%d studs", math.floor(dist))) end
                
                data.textLabel.Text = table.concat(lines, "\n")
                data.textLabel.TextColor3 = color
            else
                data.bg.Enabled = false
            end

            -- Highlight Update
            if Config.Highlight then
                data.hl.Enabled = true
                data.hl.FillColor = color
                data.hl.OutlineColor = color
            else
                data.hl.Enabled = false
            end

            -- Tracer Update
            if Config.Tracer then
                local vector, onScreen = Camera:WorldToViewportPoint(data.root.Position)
                if onScreen then
                    local targetPos = Vector2.new(vector.X, vector.Y)
                    local distance = (targetPos - screenBottom).Magnitude
                    data.tracer.Visible = true
                    data.tracer.Size = UDim2.new(0, 2, 0, distance)
                    data.tracer.Position = UDim2.new(0, (vector.X + screenBottom.X) / 2, 0, (vector.Y + screenBottom.Y) / 2)
                    data.tracer.Rotation = math.deg(math.atan2(vector.Y - screenBottom.Y, vector.X - screenBottom.X)) - 90
                    data.tracer.BackgroundColor3 = color
                else
                    data.tracer.Visible = false
                end
            else
                data.tracer.Visible = false
            end
        else
            -- Hide if outside distance, not selected, or ESP off
            data.bg.Enabled = false
            data.hl.Enabled = false
            data.tracer.Visible = false
        end
    end
    
    StatusText.Text = string.format("Active ESP: %d/%d", count, #Cache)
end)

-- Initial Scan
task.spawn(function()
    StatusText.Text = "Initial Scanning..."
    ScanWorkspace()
    UpdateMonsterListUI()
end)
