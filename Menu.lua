-- [[ SCRIPT CHÍNH - LocalScript đặt trong StarterGui ]]
-- Viết cho Roblox, đáp ứng tất cả yêu cầu.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- ====== BIẾN TOÀN CỤC ======
local state = {
    noclip = false,
    fly = false,
    flySpeed = 50,
    esp = false,
    fps = false,
    infiniteJump = false,
    theme = "Dark",
    accentColor = Color3.fromRGB(128, 0, 255),
    transparency = 0.9,
    effects = true,
    dragEnabled = true,
    autoCollapse = false,
    menuPosition = "TopLeft",
    notifications = true,
    soundNotifications = true,
    showPlayers = true,
    showDistance = true,
    showBox = true,
}

-- Lưu cài đặt vào Player Attributes
local function saveSettings()
    for k, v in pairs(state) do
        if typeof(v) == "boolean" then
            player:SetAttribute(k, v)
        elseif typeof(v) == "number" then
            player:SetAttribute(k, v)
        elseif typeof(v) == "string" then
            player:SetAttribute(k, v)
        elseif typeof(v) == "Color3" then
            player:SetAttribute(k .. "_R", v.R)
            player:SetAttribute(k .. "_G", v.G)
            player:SetAttribute(k .. "_B", v.B)
        end
    end
end

local function loadSettings()
    for k, v in pairs(state) do
        local attr = player:GetAttribute(k)
        if attr ~= nil then
            if typeof(v) == "boolean" then
                state[k] = attr
            elseif typeof(v) == "number" then
                state[k] = attr
            elseif typeof(v) == "string" then
                state[k] = attr
            elseif typeof(v) == "Color3" then
                local r = player:GetAttribute(k .. "_R") or v.R
                local g = player:GetAttribute(k .. "_G") or v.G
                local b = player:GetAttribute(k .. "_B") or v.B
                state[k] = Color3.new(r, g, b)
            end
        end
    end
end
loadSettings()

-- ====== HÀM TIỆN ÍCH ======
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char:WaitForChild("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

-- Tạo GUI chính
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VNProHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ====== TẠO MENU CHÍNH ======
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = state.theme == "Dark" and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(240, 240, 245)
mainFrame.BackgroundTransparency = 1 - state.transparency
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

-- Shadow & góc bo
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local shadow = Instance.new("UIShadow")
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Transparency = 0.5
shadow.Size = UDim.new(0, 10)
shadow.Parent = mainFrame

-- ====== THANH TIÊU ĐỀ ======
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = state.accentColor
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "VN PRO HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Nút đóng
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 1, -4)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Nút thu gọn
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 25, 1, -4)
collapseBtn.Position = UDim2.new(1, -60, 0, 2)
collapseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
collapseBtn.BorderSizePixel = 0
collapseBtn.Text = "−"
collapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collapseBtn.TextSize = 16
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.Parent = titleBar

local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -15)
        collapseBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 600, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
        collapseBtn.Text = "−"
    end
end)

-- Kéo thả
local dragEnabled = state.dragEnabled
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and dragEnabled then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ====== SIDEBAR (tabs) ======
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = state.theme == "Dark" and Color3.fromRGB(20, 20, 28) or Color3.fromRGB(220, 220, 230)
sidebar.BackgroundTransparency = 0.5
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local tabButtons = {}
local tabContents = {}

-- Hàm tạo tab
local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, #tabButtons * 40)
    btn.BackgroundColor3 = state.accentColor
    btn.BackgroundTransparency = 0.85
    btn.BorderSizePixel = 0
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = sidebar
    table.insert(tabButtons, btn)

    -- Container nội dung
    local container = Instance.new("Frame")
    container.Name = name .. "Content"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Position = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = mainFrame
    table.insert(tabContents, container)

    btn.MouseButton1Click:Connect(function()
        for i, b in ipairs(tabButtons) do
            b.BackgroundTransparency = 0.85
        end
        btn.BackgroundTransparency = 0.2
        for i, c in ipairs(tabContents) do
            c.Visible = (i == #tabContents)
        end
    end)

    return container
end

-- Tạo các tab
local mainTab = createTab("Main", "🏠")
local flyJumpTab = createTab("Fly Jump", "🪂")
local playerTab = createTab("Player", "👤")
local settingsTab = createTab("Settings", "⚙️")

-- Mặc định hiển thị Main
tabButtons[1].BackgroundTransparency = 0.2
tabContents[1].Visible = true

-- ====== NỘI DUNG TAB MAIN ======
local mainContent = tabContents[1]

-- Nút Settings
local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 150, 0, 40)
settingsBtn.Position = UDim2.new(0.5, -75, 0.3, 0)
settingsBtn.BackgroundColor3 = state.accentColor
settingsBtn.BackgroundTransparency = 0.3
settingsBtn.BorderSizePixel = 0
settingsBtn.Text = "⚙️ Settings"
settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsBtn.TextSize = 18
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.Parent = mainContent
settingsBtn.MouseButton1Click:Connect(function()
    -- Chuyển sang tab Settings
    for i, b in ipairs(tabButtons) do
        b.BackgroundTransparency = 0.85
    end
    tabButtons[4].BackgroundTransparency = 0.2
    for i, c in ipairs(tabContents) do
        c.Visible = (i == 4)
    end
end)

-- Nút Info
local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(0, 150, 0, 40)
infoBtn.Position = UDim2.new(0.5, -75, 0.5, 0)
infoBtn.BackgroundColor3 = state.accentColor
infoBtn.BackgroundTransparency = 0.3
infoBtn.BorderSizePixel = 0
infoBtn.Text = "ℹ️ Info"
infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.TextSize = 18
infoBtn.Font = Enum.Font.GothamBold
infoBtn.Parent = mainContent
infoBtn.MouseButton1Click:Connect(function()
    print("VN PRO HUB - Best Script, Best Experience")
end)

-- ====== NỘI DUNG TAB FLY JUMP ======
local flyJumpContent = tabContents[2]

-- Hàm tạo toggle
local function createToggle(parent, label, stateKey, onToggle)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 35)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamMedium
    lbl.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBtn.BackgroundColor3 = state[stateKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = state[stateKey] and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = container

    toggleBtn.MouseButton1Click:Connect(function()
        state[stateKey] = not state[stateKey]
        toggleBtn.BackgroundColor3 = state[stateKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
        toggleBtn.Text = state[stateKey] and "ON" or "OFF"
        if onToggle then onToggle(state[stateKey]) end
        saveSettings()
    end)

    return container
end

-- Fly Toggle
createToggle(flyJumpContent, "🪁 Fly", "fly", function(val)
    if val then
        -- Bật fly
        local root = getRoot()
        root.Velocity = Vector3.new(0, 0, 0)
        -- Sẽ xử lý trong vòng lặp
    else
        -- Tắt fly
    end
end)

-- Speed Slider
local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(1, -20, 0, 30)
speedContainer.Position = UDim2.new(0, 10, 0, #flyJumpContent:GetChildren() * 35)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = flyJumpContent

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Tốc độ bay: " .. state.flySpeed
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 15
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.Parent = speedContainer

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(0, 60, 1, 0)
speedSlider.Position = UDim2.new(1, -70, 0, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedSlider.BorderSizePixel = 0
speedSlider.Text = tostring(state.flySpeed)
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.TextSize = 14
speedSlider.Font = Enum.Font.GothamBold
speedSlider.Parent = speedContainer

speedSlider.FocusLost:Connect(function()
    local val = tonumber(speedSlider.Text)
    if val then
        val = math.clamp(val, 0, 200)
        state.flySpeed = val
        speedSlider.Text = tostring(val)
        speedLabel.Text = "Tốc độ bay: " .. val
        saveSettings()
    else
        speedSlider.Text = tostring(state.flySpeed)
    end
end)

-- ESP Toggle
createToggle(flyJumpContent, "👁️ ESP", "esp", function(val)
    if val then
        -- Khởi tạo ESP
        setupESP()
    else
        -- Xóa ESP
        clearESP()
    end
end)

-- FPS Toggle
createToggle(flyJumpContent, "📊 FPS Counter", "fps", function(val)
    if val then
        createFPSCounter()
    else
        if fpsLabel then fpsLabel:Destroy() end
    end
end)

-- Các checkbox: Hiển thị người chơi, khoảng cách, hộp
local function createCheckbox(parent, label, stateKey)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 25)
    container.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 35)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local chk = Instance.new("TextButton")
    chk.Size = UDim2.new(0, 20, 0, 20)
    chk.Position = UDim2.new(0, 0, 0.5, -10)
    chk.BackgroundColor3 = state[stateKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 100)
    chk.BorderSizePixel = 0
    chk.Text = state[stateKey] and "✔" or ""
    chk.TextColor3 = Color3.fromRGB(255, 255, 255)
    chk.TextSize = 14
    chk.Font = Enum.Font.GothamBold
    chk.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -25, 1, 0)
    lbl.Position = UDim2.new(0, 25, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamMedium
    lbl.Parent = container

    chk.MouseButton1Click:Connect(function()
        state[stateKey] = not state[stateKey]
        chk.BackgroundColor3 = state[stateKey] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 100)
        chk.Text = state[stateKey] and "✔" or ""
        saveSettings()
        -- Cập nhật ESP nếu đang bật
        if state.esp then
            clearESP()
            setupESP()
        end
    end)
end

createCheckbox(flyJumpContent, "Hiển thị người chơi", "showPlayers")
createCheckbox(flyJumpContent, "Hiển thị khoảng cách", "showDistance")
createCheckbox(flyJumpContent, "Hiển thị hộp", "showBox")

-- Infinite Jump Toggle
createToggle(flyJumpContent, "🌀 Nhảy vô hạn", "infiniteJump", function(val)
    -- Xử lý trong vòng lặp
end)

-- ====== NỘI DUNG TAB PLAYER ======
local playerContent = tabContents[3]
-- Tương tự như Fly Jump nhưng có thể thêm các chức năng khác
-- Ở đây tôi copy các chức năng chính
local pFlyToggle = createToggle(playerContent, "🪁 Fly", "fly")
local pSpeedContainer = speedContainer:Clone()
pSpeedContainer.Position = UDim2.new(0, 10, 0, #playerContent:GetChildren() * 35)
pSpeedContainer.Parent = playerContent
local pSpeedLabel = pSpeedContainer:FindFirstChild("TextLabel")
local pSpeedSlider = pSpeedContainer:FindFirstChild("TextBox")
pSpeedSlider.FocusLost:Connect(function()
    local val = tonumber(pSpeedSlider.Text)
    if val then
        val = math.clamp(val, 0, 200)
        state.flySpeed = val
        pSpeedSlider.Text = tostring(val)
        pSpeedLabel.Text = "Tốc độ bay: " .. val
        saveSettings()
    else
        pSpeedSlider.Text = tostring(state.flySpeed)
    end
end)

createToggle(playerContent, "👁️ ESP", "esp")
createToggle(playerContent, "📊 FPS Counter", "fps")

-- ====== NỘI DUNG TAB SETTINGS ======
local settingsContent = tabContents[4]
settingsContent.BackgroundTransparency = 0
settingsContent.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

-- Giao diện
local uiFrame = Instance.new("Frame")
uiFrame.Size = UDim2.new(1, -20, 0, 200)
uiFrame.Position = UDim2.new(0, 10, 0, 10)
uiFrame.BackgroundTransparency = 1
uiFrame.Parent = settingsContent

local uiLabel = Instance.new("TextLabel")
uiLabel.Size = UDim2.new(1, 0, 0, 25)
uiLabel.BackgroundTransparency = 1
uiLabel.Text = "GIAO DIỆN"
uiLabel.TextColor3 = state.accentColor
uiLabel.TextSize = 18
uiLabel.Font = Enum.Font.GothamBold
uiLabel.TextXAlignment = Enum.TextXAlignment.Left
uiLabel.Parent = uiFrame

-- Chế độ giao diện (Dark/Light)
local themeContainer = Instance.new("Frame")
themeContainer.Size = UDim2.new(1, 0, 0, 30)
themeContainer.Position = UDim2.new(0, 0, 0, 30)
themeContainer.BackgroundTransparency = 1
themeContainer.Parent = uiFrame

local themeLbl = Instance.new("TextLabel")
themeLbl.Size = UDim2.new(0.5, 0, 1, 0)
themeLbl.BackgroundTransparency = 1
themeLbl.Text = "Chế độ: "
themeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
themeLbl.TextSize = 14
themeLbl.TextXAlignment = Enum.TextXAlignment.Left
themeLbl.Font = Enum.Font.GothamMedium
themeLbl.Parent = themeContainer

local themeDropdown = Instance.new("TextButton")
themeDropdown.Size = UDim2.new(0, 100, 1, 0)
themeDropdown.Position = UDim2.new(0.5, 0, 0, 0)
themeDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
themeDropdown.BorderSizePixel = 0
themeDropdown.Text = state.theme
themeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
themeDropdown.TextSize = 14
themeDropdown.Font = Enum.Font.GothamMedium
themeDropdown.Parent = themeContainer

themeDropdown.MouseButton1Click:Connect(function()
    state.theme = state.theme == "Dark" and "Light" or "Dark"
    themeDropdown.Text = state.theme
    -- Cập nhật màu sắc
    local bg = state.theme == "Dark" and Color3.fromRGB(30,30,40) or Color3.fromRGB(240,240,245)
    mainFrame.BackgroundColor3 = bg
    sidebar.BackgroundColor3 = state.theme == "Dark" and Color3.fromRGB(20,20,28) or Color3.fromRGB(220,220,230)
    saveSettings()
end)

-- Màu chủ đạo
local colorContainer = Instance.new("Frame")
colorContainer.Size = UDim2.new(1, 0, 0, 30)
colorContainer.Position = UDim2.new(0, 0, 0, 65)
colorContainer.BackgroundTransparency = 1
colorContainer.Parent = uiFrame

local colorLbl = Instance.new("TextLabel")
colorLbl.Size = UDim2.new(0.5, 0, 1, 0)
colorLbl.BackgroundTransparency = 1
colorLbl.Text = "Màu chủ đạo: "
colorLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLbl.TextSize = 14
colorLbl.TextXAlignment = Enum.TextXAlignment.Left
colorLbl.Font = Enum.Font.GothamMedium
colorLbl.Parent = colorContainer

local colorPicker = Instance.new("TextBox")
colorPicker.Size = UDim2.new(0, 100, 1, 0)
colorPicker.Position = UDim2.new(0.5, 0, 0, 0)
colorPicker.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
colorPicker.BorderSizePixel = 0
colorPicker.Text = string.format("%.3f,%.3f,%.3f", state.accentColor.R, state.accentColor.G, state.accentColor.B)
colorPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
colorPicker.TextSize = 14
colorPicker.Font = Enum.Font.GothamMedium
colorPicker.Parent = colorContainer

colorPicker.FocusLost:Connect(function()
    local vals = {}
    for v in string.gmatch(colorPicker.Text, "[^,]+") do
        table.insert(vals, tonumber(v))
    end
    if #vals == 3 then
        state.accentColor = Color3.new(vals[1], vals[2], vals[3])
        colorPicker.Text = string.format("%.3f,%.3f,%.3f", vals[1], vals[2], vals[3])
        -- Cập nhật các thành phần
        titleBar.BackgroundColor3 = state.accentColor
        for _, btn in ipairs(tabButtons) do
            btn.BackgroundColor3 = state.accentColor
        end
        saveSettings()
    end
end)

-- Độ trong suốt
local transContainer = Instance.new("Frame")
transContainer.Size = UDim2.new(1, 0, 0, 30)
transContainer.Position = UDim2.new(0, 0, 0, 100)
transContainer.BackgroundTransparency = 1
transContainer.Parent = uiFrame

local transLbl = Instance.new("TextLabel")
transLbl.Size = UDim2.new(0.5, 0, 1, 0)
transLbl.BackgroundTransparency = 1
transLbl.Text = "Độ trong suốt: " .. math.floor(state.transparency * 100) .. "%"
transLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
transLbl.TextSize = 14
transLbl.TextXAlignment = Enum.TextXAlignment.Left
transLbl.Font = Enum.Font.GothamMedium
transLbl.Parent = transContainer

local transSlider = Instance.new("TextBox")
transSlider.Size = UDim2.new(0, 60, 1, 0)
transSlider.Position = UDim2.new(1, -70, 0, 0)
transSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
transSlider.BorderSizePixel = 0
transSlider.Text = tostring(math.floor(state.transparency * 100))
transSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
transSlider.TextSize = 14
transSlider.Font = Enum.Font.GothamBold
transSlider.Parent = transContainer

transSlider.FocusLost:Connect(function()
    local val = tonumber(transSlider.Text)
    if val then
        val = math.clamp(val, 0, 100) / 100
        state.transparency = val
        transSlider.Text = tostring(math.floor(val * 100))
        transLbl.Text = "Độ trong suốt: " .. math.floor(val * 100) .. "%"
        mainFrame.BackgroundTransparency = 1 - val
        saveSettings()
    else
        transSlider.Text = tostring(math.floor(state.transparency * 100))
    end
end)

-- Menu settings
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(1, -20, 0, 150)
menuFrame.Position = UDim2.new(0, 10, 0, 230)
menuFrame.BackgroundTransparency = 1
menuFrame.Parent = settingsContent

local menuLabel = Instance.new("TextLabel")
menuLabel.Size = UDim2.new(1, 0, 0, 25)
menuLabel.BackgroundTransparency = 1
menuLabel.Text = "MENU"
menuLabel.TextColor3 = state.accentColor
menuLabel.TextSize = 18
menuLabel.Font = Enum.Font.GothamBold
menuLabel.TextXAlignment = Enum.TextXAlignment.Left
menuLabel.Parent = menuFrame

-- Kéo thả toggle
local dragToggle = createToggle(menuFrame, "Kéo thả menu", "dragEnabled")

-- Tự động thu gọn
local autoCollapseToggle = createToggle(menuFrame, "Thu gọn sau 10s", "autoCollapse")

-- Vị trí mặc định
local posContainer = Instance.new("Frame")
posContainer.Size = UDim2.new(1, 0, 0, 30)
posContainer.Position = UDim2.new(0, 0, 0, 100)
posContainer.BackgroundTransparency = 1
posContainer.Parent = menuFrame

local posLbl = Instance.new("TextLabel")
posLbl.Size = UDim2.new(0.5, 0, 1, 0)
posLbl.BackgroundTransparency = 1
posLbl.Text = "Vị trí mặc định: "
posLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
posLbl.TextSize = 14
posLbl.TextXAlignment = Enum.TextXAlignment.Left
posLbl.Font = Enum.Font.GothamMedium
posLbl.Parent = posContainer

local posDropdown = Instance.new("TextButton")
posDropdown.Size = UDim2.new(0, 120, 1, 0)
posDropdown.Position = UDim2.new(0.5, 0, 0, 0)
posDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
posDropdown.BorderSizePixel = 0
posDropdown.Text = state.menuPosition
posDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
posDropdown.TextSize = 14
posDropdown.Font = Enum.Font.GothamMedium
posDropdown.Parent = posContainer

posDropdown.MouseButton1Click:Connect(function()
    local positions = {"TopLeft", "TopRight", "BottomLeft", "BottomRight", "Center"}
    local idx = table.find(positions, state.menuPosition) or 1
    idx = idx % #positions + 1
    state.menuPosition = positions[idx]
    posDropdown.Text = state.menuPosition
    -- Áp dụng vị trí
    local scaleX, scaleY, offsetX, offsetY
    if state.menuPosition == "TopLeft" then
        scaleX, scaleY, offsetX, offsetY = 0, 0, 20, 50
    elseif state.menuPosition == "TopRight" then
        scaleX, scaleY, offsetX, offsetY = 1, 0, -620, 50
    elseif state.menuPosition == "BottomLeft" then
        scaleX, scaleY, offsetX, offsetY = 0, 1, 20, -450
    elseif state.menuPosition == "BottomRight" then
        scaleX, scaleY, offsetX, offsetY = 1, 1, -620, -450
    else -- Center
        scaleX, scaleY, offsetX, offsetY = 0.5, 0.5, -300, -200
    end
    mainFrame.Position = UDim2.new(scaleX, offsetX, scaleY, offsetY)
    saveSettings()
end)

-- ====== CHỨC NĂNG NOCLIP ======
local function toggleNoclip(val)
    state.noclip = val
    if val then
        local char = getCharacter()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        local char = getCharacter()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Tự động bật/tắt Noclip khi respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    if state.noclip then
        toggleNoclip(true)
    end
end)

-- Noclip liên tục
RunService.Heartbeat:Connect(function()
    if state.noclip then
        local char = getCharacter()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ====== CHỨC NĂNG FLY ======
local flyActive = false
local flyVelocity = Vector3.new(0, 0, 0)

local function updateFly()
    if not state.fly then
        flyActive = false
        return
    end
    flyActive = true
    local root = getRoot()
    if not root then return end

    local moveDirection = Vector3.new(0, 0, 0)
    -- PC: WASD, Space, Shift
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + camera.CFrame.LookVector * Vector3.new(1,0,1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - camera.CFrame.LookVector * Vector3.new(1,0,1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - camera.CFrame.RightVector * Vector3.new(1,0,1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + camera.CFrame.RightVector * Vector3.new(1,0,1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end

    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit * state.flySpeed
    else
        moveDirection = Vector3.new(0, 0, 0)
    end

    root.Velocity = moveDirection
    humanoid.PlatformStand = true
end

-- Mobile controls
local function setupMobileControls()
    local mobileFrame = Instance.new("Frame")
    mobileFrame.Name = "MobileControls"
    mobileFrame.Size = UDim2.new(0, 200, 0, 100)
    mobileFrame.Position = UDim2.new(0, 10, 1, -120)
    mobileFrame.BackgroundTransparency = 0.5
    mobileFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    mobileFrame.BorderSizePixel = 0
    mobileFrame.Parent = screenGui

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 50, 0, 40)
    upBtn.Position = UDim2.new(0.5, -25, 0, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    upBtn.BorderSizePixel = 0
    upBtn.Text = "▲"
    upBtn.TextColor3 = Color3.fromRGB(255,255,255)
    upBtn.TextSize = 24
    upBtn.Font = Enum.Font.GothamBold
    upBtn.Parent = mobileFrame

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 50, 0, 40)
    downBtn.Position = UDim2.new(0.5, -25, 1, -40)
    downBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    downBtn.BorderSizePixel = 0
    downBtn.Text = "▼"
    downBtn.TextColor3 = Color3.fromRGB(255,255,255)
    downBtn.TextSize = 24
    downBtn.Font = Enum.Font.GothamBold
    downBtn.Parent = mobileFrame

    local leftBtn = Instance.new("TextButton")
    leftBtn.Size = UDim2.new(0, 50, 0, 40)
    leftBtn.Position = UDim2.new(0, 0, 0.5, -20)
    leftBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    leftBtn.BorderSizePixel = 0
    leftBtn.Text = "◀"
    leftBtn.TextColor3 = Color3.fromRGB(255,255,255)
    leftBtn.TextSize = 24
    leftBtn.Font = Enum.Font.GothamBold
    leftBtn.Parent = mobileFrame

    local rightBtn = Instance.new("TextButton")
    rightBtn.Size = UDim2.new(0, 50, 0, 40)
    rightBtn.Position = UDim2.new(1, -50, 0.5, -20)
    rightBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    rightBtn.BorderSizePixel = 0
    rightBtn.Text = "▶"
    rightBtn.TextColor3 = Color3.fromRGB(255,255,255)
    rightBtn.TextSize = 24
    rightBtn.Font = Enum.Font.GothamBold
    rightBtn.Parent = mobileFrame

    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(0, 40, 0, 40)
    speedBtn.Position = UDim2.new(0, 60, 0.5, -20)
    speedBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    speedBtn.BorderSizePixel = 0
    speedBtn.Text = "⚡"
    speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
    speedBtn.TextSize = 24
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.Parent = mobileFrame

    local function setFlyDir(dir)
        if state.fly then
            local root = getRoot()
            if root then
                root.Velocity = dir * state.flySpeed
            end
        end
    end

    upBtn.MouseButton1Hold:Connect(function() setFlyDir(Vector3.new(0,1,0)) end)
    downBtn.MouseButton1Hold:Connect(function() setFlyDir(Vector3.new(0,-1,0)) end)
    leftBtn.MouseButton1Hold:Connect(function() setFlyDir(-camera.CFrame.RightVector * Vector3.new(1,0,1)) end)
    rightBtn.MouseButton1Hold:Connect(function() setFlyDir(camera.CFrame.RightVector * Vector3.new(1,0,1)) end)
    speedBtn.MouseButton1Click:Connect(function()
        state.flySpeed = math.min(state.flySpeed + 10, 200)
    end)

    mobileFrame.Visible = state.fly
end

-- Gọi khi bật fly
local function toggleFly(val)
    state.fly = val
    if val then
        flyActive = true
        humanoid.PlatformStand = true
        setupMobileControls()
    else
        flyActive = false
        humanoid.PlatformStand = false
        local root = getRoot()
        if root then root.Velocity = Vector3.new(0,0,0) end
        local mobile = screenGui:FindFirstChild("MobileControls")
        if mobile then mobile:Destroy() end
    end
end

-- Vòng lặp fly
RunService.Heartbeat:Connect(function()
    if flyActive and state.fly then
        updateFly()
    end
end)

-- ====== CHỨC NĂNG INFINITE JUMP ======
local function toggleInfiniteJump(val)
    state.infiniteJump = val
end

UserInputService.JumpRequest:Connect(function()
    if state.infiniteJump then
        local human = getHumanoid()
        if human then
            human.Jump = true
        end
    end
end)

-- ====== CHỨC NĂNG ESP ======
local espObjects = {}

local function setupESP()
    if not state.esp then return end
    clearESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                addESP(plr)
            end
        end
    end
end

local function addESP(plr)
    if not state.esp then return end
    if espObjects[plr] then return end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local espGroup = Instance.new("Model")
    espGroup.Name = plr.Name .. "_ESP"
    espGroup.Parent = char

    -- Box
    if state.showBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 5, 1.5)
        box.Adornee = root
        box.Color3 = Color3.fromRGB(0, 255, 0)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.Parent = espGroup
    end

    -- Name + Distance
    if state.showPlayers or state.showDistance then
        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 200, 0, 50)
        bill.Adornee = root
        bill.AlwaysOnTop = true
        bill.Parent = espGroup

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = plr.Name
        nameLabel.Parent = bill

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.GothamMedium
        distLabel.Text = ""
        distLabel.Parent = bill

        espObjects[plr] = {group = espGroup, name = nameLabel, dist = distLabel}
    end
end

local function clearESP()
    for plr, data in pairs(espObjects) do
        if data.group then data.group:Destroy() end
    end
    espObjects = {}
end

-- Cập nhật ESP
RunService.Heartbeat:Connect(function()
    if state.esp then
        for plr, data in pairs(espObjects) do
            if data.dist and state.showDistance then
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local dist = (rootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    data.dist.Text = string.format("%.1f m", dist)
                end
            end
        end
    end
end)

-- Thêm ESP khi có người chơi mới
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        if state.esp then
            task.wait(0.5)
            addESP(plr)
        end
    end)
end)

-- ====== CHỨC NĂNG FPS COUNTER ======
local fpsLabel = nil
local fpsValues = {}

local function createFPSCounter()
    if fpsLabel then fpsLabel:Destroy() end
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 80, 0, 30)
    fpsLabel.Position = UDim2.new(1, -90, 0, 10)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextSize = 18
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.Parent = screenGui
end

local fpsTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if state.fps then
        if not fpsLabel then createFPSCounter() end
        table.insert(fpsValues, 1/dt)
        if #fpsValues > 10 then table.remove(fpsValues, 1) end
        local avg = 0
        for _, v in ipairs(fpsValues) do avg = avg + v end
        avg = avg / #fpsValues
        local fps = math.floor(avg)

        if fps <= 10 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        elseif fps <= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        elseif fps <= 500 then
            fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            local r = math.sin(tick() * 2) * 0.5 + 0.5
            local g = math.sin(tick() * 2 + 2) * 0.5 + 0.5
            local b = math.sin(tick() * 2 + 4) * 0.5 + 0.5
            fpsLabel.TextColor3 = Color3.new(r, g, b)
        end
        fpsLabel.Text = "FPS: " .. fps
    else
        if fpsLabel then fpsLabel:Destroy() end
        fpsValues = {}
    end
end)

-- ====== TỰ ĐỘNG THU GỌN ======
local collapseTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if state.autoCollapse and not collapsed then
        collapseTimer = collapseTimer + dt
        if collapseTimer > 10 then
            collapsed = true
            mainFrame.Size = UDim2.new(0, 300, 0, 30)
            mainFrame.Position = UDim2.new(0.5, -150, 0.5, -15)
            collapseBtn.Text = "+"
            collapseTimer = 0
        end
    else
        collapseTimer = 0
    end
end)

-- Reset timer khi tương tác
mainFrame.InputBegan:Connect(function()
    collapseTimer = 0
end)

-- ====== KHỞI TẠO BAN ĐẦU ======
-- Nếu đã bật ESP thì setup
if state.esp then
    task.wait(1)
    setupESP()
end
if state.fps then
    createFPSCounter()
end
if state.fly then
    toggleFly(true)
end
if state.infiniteJump then
    toggleInfiniteJump(true)
end
if state.noclip then
    toggleNoclip(true)
end

-- Lưu cài đặt khi thoát
game:BindToClose(function()
    saveSettings()
end)

-- ====== THÔNG BÁO (ví dụ) ======
local function showNotification(text)
    if not state.notifications then return end
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 20)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.5
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.TextSize = 16
    notif.Font = Enum.Font.GothamMedium
    notif.Parent = screenGui
    if state.soundNotifications then
        -- Play sound (có thể thêm)
    end
    task.wait(3)
    notif:Destroy()
end

-- Thông báo khởi động
showNotification("VN PRO HUB đã tải! Chúc bạn chơi vui!")

-- ====== PHÍM TẮT ======
ContextActionService:BindAction("ToggleMenu", function()
    mainFrame.Visible = not mainFrame.Visible
end, false, Enum.KeyCode.RightControl)

print("VN PRO HUB - Script đã chạy thành công!")
