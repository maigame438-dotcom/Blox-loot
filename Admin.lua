-- ================================================
-- BLOX LOOT ESP V1.1 - BY HBG (OPTIMIZED)
-- TÍNH NĂNG: ESP Player, Mob, Item, Menu Toggle
-- ================================================

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local espEnabled = false
local espObjects = {}

-- ================================================
-- CONSTANTS & CONFIGURATION
-- ================================================
local ESPConfig = {
    player = true,
    mob = true,
    item = false,
    name = true,
    health = true,
    colorPlayer = Color3.fromRGB(0, 200, 255),
    colorMob = Color3.fromRGB(255, 50, 50),
    colorItem = Color3.fromRGB(255, 255, 0)
}

local UITheme = {
    background = Color3.fromRGB(20, 20, 30),
    accent = Color3.fromRGB(0, 150, 255),
    textPrimary = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(200, 200, 200),
    onColor = Color3.fromRGB(0, 200, 0),
    offColor = Color3.fromRGB(200, 0, 0),
    closeColor = Color3.fromRGB(255, 0, 0)
}

local SEARCH_PATTERNS = {
    mob = {"mob", "enemy", "npc", "monster", "boss"},
    item = {"item", "chest", "loot", "pickup", "treasure"}
}

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function matchesPattern(name, patterns)
    local lowerName = name:lower()
    for _, pattern in ipairs(patterns) do
        if lowerName:find(pattern) then
            return true
        end
    end
    return false
end

-- ================================================
-- UI CREATION
-- ================================================
local screenGui = createInstance("ScreenGui", {
    Name = "BloxLootESP",
    Parent = player:WaitForChild("PlayerGui")
})

-- Toggle Button
local toggleButton = createInstance("ImageButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 2,
    BorderColor3 = Color3.fromRGB(0, 255, 255),
    Image = "rbxassetid://6031090973",
    Parent = screenGui
})

-- Menu Frame
local menuFrame = createInstance("Frame", {
    Size = UDim2.new(0, 300, 0, 400),
    Position = UDim2.new(0.5, -150, 0.5, -200),
    BackgroundColor3 = UITheme.background,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 2,
    BorderColor3 = Color3.fromRGB(0, 200, 255),
    Active = true,
    Draggable = true,
    Visible = false,
    Parent = screenGui
})

-- Menu Title
createInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = UITheme.accent,
    BackgroundTransparency = 0.3,
    TextColor3 = UITheme.textPrimary,
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Text = "⚡ BLOX LOOT ESP ⚡",
    Parent = menuFrame
})

-- Close Button
local closeButton = createInstance("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -45, 0, 0),
    BackgroundColor3 = UITheme.closeColor,
    BackgroundTransparency = 0.3,
    TextColor3 = UITheme.textPrimary,
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Text = "✕",
    Parent = menuFrame
})

-- ================================================
-- TOGGLE CREATION (OPTIMIZED)
-- ================================================
local function createToggle(labelText, yPos, defaultState, callback)
    local toggleFrame = createInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, yPos),
        BackgroundTransparency = 1,
        Parent = menuFrame
    })
    
    createInstance("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = UITheme.textSecondary,
        TextScaled = true,
        Font = Enum.Font.SourceSans,
        Text = labelText,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local state = defaultState
    local toggleBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 80, 0, 30),
        Position = UDim2.new(0.7, 0, 0.5, -15),
        BackgroundColor3 = state and UITheme.onColor or UITheme.offColor,
        TextColor3 = UITheme.textPrimary,
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        Text = state and "ON" or "OFF",
        Parent = toggleFrame
    })
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and UITheme.onColor or UITheme.offColor
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return toggleBtn
end

-- ================================================
-- MENU TOGGLES (ORGANIZED)
-- ================================================
local toggles = {
    {"🔍 ESP ENABLED", 50, false, function(state)
        espEnabled = state
        if state then enableESP() else disableESP() end
    end},
    {"👤 ESP PLAYER", 100, ESPConfig.player, function(state)
        ESPConfig.player = state
        if espEnabled then refreshESP() end
    end},
    {"👾 ESP MOB", 150, ESPConfig.mob, function(state)
        ESPConfig.mob = state
        if espEnabled then refreshESP() end
    end},
    {"💎 ESP ITEM", 200, ESPConfig.item, function(state)
        ESPConfig.item = state
        if espEnabled then refreshESP() end
    end},
    {"📛 SHOW NAME", 250, ESPConfig.name, function(state)
        ESPConfig.name = state
        if espEnabled then refreshESP() end
    end},
    {"❤️ HEALTH BAR", 300, ESPConfig.health, function(state)
        ESPConfig.health = state
        if espEnabled then refreshESP() end
    end}
}

for _, toggleData in ipairs(toggles) do
    createToggle(unpack(toggleData))
end

-- Refresh Button
local refreshBtn = createInstance("TextButton", {
    Size = UDim2.new(0.8, 0, 0, 40),
    Position = UDim2.new(0.1, 0, 0, 360),
    BackgroundColor3 = UITheme.accent,
    TextColor3 = UITheme.textPrimary,
    TextScaled = true,
    Font = Enum.Font.SourceSansBold,
    Text = "🔄 REFRESH ESP",
    Parent = menuFrame
})

refreshBtn.MouseButton1Click:Connect(function()
    if espEnabled then
        disableESP()
        task.wait(0.5)
        enableESP()
    end
end)

-- ================================================
-- MENU SHOW/HIDE LOGIC
-- ================================================
local menuVisible = false

toggleButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
    toggleButton.BackgroundColor3 = menuVisible and UITheme.accent or Color3.fromRGB(30, 30, 30)
end)

closeButton.MouseButton1Click:Connect(function()
    menuVisible = false
    menuFrame.Visible = false
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
end)

-- ================================================
-- ESP OBJECT CREATION (OPTIMIZED)
-- ================================================
local function createESPObject(target, color, name)
    if not target or not target:IsA("Model") then return nil, nil end
    
    -- Create Highlight
    local highlight = createInstance("Highlight", {
        Name = "ESP_HBG",
        Enabled = true,
        FillTransparency = 0.5,
        OutlineTransparency = 0.2,
        FillColor = color,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        Parent = target
    })
    
    -- Create BillboardGui
    local billboard = createInstance("BillboardGui", {
        Name = "ESP_Name",
        Size = UDim2.new(0, 200, 0, 40),
        AlwaysOnTop = true,
        Adornee = target,
        Parent = target
    })
    
    -- Name Label
    createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = UITheme.textPrimary,
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        Text = ESPConfig.name and (name or "Unknown") or "",
        Parent = billboard
    })
    
    -- Health Bar (only if enabled)
    if ESPConfig.health then
        local hpBackground = createInstance("Frame", {
            Name = "ESP_HP_Background",
            Size = UDim2.new(0, 100, 0, 10),
            Position = UDim2.new(0, -50, 0, 45),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 0,
            Parent = billboard
        })
        
        createInstance("Frame", {
            Name = "ESP_HP_Bar",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 200, 0),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Parent = hpBackground
        })
    end
    
    return highlight, billboard
end

-- ================================================
-- ESP MANAGEMENT (OPTIMIZED)
-- ================================================
local espData = {}

function enableESP()
    for _, data in ipairs(espData) do
        if data.highlight then data.highlight.Enabled = true end
        if data.billboard then data.billboard.Enabled = true end
    end
    print("[ESP] Đã bật ESP!")
end

function disableESP()
    for _, data in ipairs(espData) do
        if data.highlight then data.highlight.Enabled = false end
        if data.billboard then data.billboard.Enabled = false end
    end
    print("[ESP] Đã tắt ESP!")
end

function clearESP()
    for _, data in ipairs(espData) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end
    table.clear(espData)
end

function scanAndCreateESP()
    local newData = {}
    
    -- Player ESP
    if ESPConfig.player then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local highlight, billboard = createESPObject(plr.Character, ESPConfig.colorPlayer, plr.Name)
                if highlight and billboard then
                    table.insert(newData, {highlight = highlight, billboard = billboard, target = plr.Character})
                end
            end
        end
    end
    
    -- Scan workspace for mobs and items (combined for efficiency)
    if ESPConfig.mob or ESPConfig.item then
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("Model") then
                local name = descendant.Name
                
                -- Mob ESP
                if ESPConfig.mob and matchesPattern(name, SEARCH_PATTERNS.mob) then
                    local highlight, billboard = createESPObject(descendant, ESPConfig.colorMob, name)
                    if highlight and billboard then
                        table.insert(newData, {highlight = highlight, billboard = billboard, target = descendant})
                    end
                end
                
                -- Item ESP
                if ESPConfig.item and matchesPattern(name, SEARCH_PATTERNS.item) then
                    local highlight, billboard = createESPObject(descendant, ESPConfig.colorItem, name)
                    if highlight and billboard then
                        table.insert(newData, {highlight = highlight, billboard = billboard, target = descendant})
                    end
                end
            end
        end
    end
    
    return newData
end

function refreshESP()
    clearESP()
    espData = scanAndCreateESP()
    print("[ESP] Đã refresh ESP! Số lượng: " .. #espData)
end

-- ================================================
-- AUTO REFRESH SYSTEM (OPTIMIZED)
-- ================================================
local lastRefresh = tick()
local REFRESH_INTERVAL = 5

RunService.Heartbeat:Connect(function()
    if espEnabled and tick() - lastRefresh >= REFRESH_INTERVAL then
        refreshESP()
        lastRefresh = tick()
    end
end)

-- ================================================
-- PLAYER RESPAWN HANDLER
-- ================================================
player.CharacterAdded:Connect(function()
    if espEnabled then
        task.wait(1)
        refreshESP()
    end
end)

-- ================================================
-- INITIALIZATION
-- ================================================
print("[HBG] Blox Loot ESP V1.1 đã tải!")
print("Click vào icon menu để mở/đóng menu ESP")
