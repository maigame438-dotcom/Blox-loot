local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Cài đặt thông số
local MOVE_SPEED = 180 
local BASE_MENU_HEIGHT = 180 -- Đã tăng để chứa thanh Quản lý File
local MAX_MENU_HEIGHT = 450
local ITEM_HEIGHT = 45

local gameId = tostring(game.PlaceId)
local locations = {}
local currentMode = "Fast"

---------------------------------------------
-- HÀM LƯU & TẢI TỆP TIN (CONFIG SYSTEM)
---------------------------------------------
local function getFilePath(fileName)
    -- Lọc ký tự đặc biệt để tên file không bị lỗi hệ thống
    local safeName = string.gsub(fileName, "[^%w%_]", "")
    if safeName == "" then safeName = "Default" end
    return "TPMenu_" .. gameId .. "_" .. safeName .. ".json"
end

local function saveConfig(fileName)
    if writefile then
        local dataToSave = {}
        for _, loc in ipairs(locations) do
            table.insert(dataToSave, {Name = loc.Name, CFrame = {loc.CFrame:GetComponents()}})
        end
        writefile(getFilePath(fileName), HttpService:JSONEncode(dataToSave))
        return true
    end
    return false
end

local function loadConfig(fileName)
    local path = getFilePath(fileName)
    if readfile and isfile and isfile(path) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if success and type(result) == "table" then
            locations = {}
            for _, locData in ipairs(result) do
                table.insert(locations, {Name = locData.Name, CFrame = CFrame.new(unpack(locData.CFrame))})
            end
            return true
        end
    end
    return false
end

---------------------------------------------
-- TẠO GUI CHÍNH
---------------------------------------------
local guiParent = gethui and gethui() or game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("MobileTeleportMenuV3") then guiParent.MobileTeleportMenuV3:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileTeleportMenuV3"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- Nút Bật/Tắt
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 15, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleButton.Text = "🚀"
toggleButton.TextSize = 24
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", toggleButton).Color = Color3.fromRGB(80, 80, 90)

-- Khung Menu
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 290, 0, BASE_MENU_HEIGHT)
mainFrame.Position = UDim2.new(0.5, -145, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(45, 45, 55)

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.04, 0, 0, 0)
title.Text = "Teleport Menu (Tệp)"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = topBar

-- Chế Độ Di Chuyển
local modeContainer = Instance.new("Frame")
modeContainer.Size = UDim2.new(0.9, 0, 0, 32)
modeContainer.Position = UDim2.new(0.05, 0, 0, 48)
modeContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
modeContainer.Parent = mainFrame
Instance.new("UICorner", modeContainer).CornerRadius = UDim.new(0, 8)

local modeFastBtn = Instance.new("TextButton")
modeFastBtn.Size = UDim2.new(0.49, 0, 0.85, 0)
modeFastBtn.Position = UDim2.new(0.01, 0, 0.075, 0)
modeFastBtn.Text = "🚀 Bay Mượt"
modeFastBtn.Font = Enum.Font.GothamMedium
modeFastBtn.TextSize = 12
modeFastBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
modeFastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeFastBtn.Parent = modeContainer
Instance.new("UICorner", modeFastBtn).CornerRadius = UDim.new(0, 6)

local modeInstantBtn = Instance.new("TextButton")
modeInstantBtn.Size = UDim2.new(0.49, 0, 0.85, 0)
modeInstantBtn.Position = UDim2.new(0.5, 0, 0.075, 0)
modeInstantBtn.Text = "⚡ TP Tức Thì"
modeInstantBtn.Font = Enum.Font.GothamMedium
modeInstantBtn.TextSize = 12
modeInstantBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
modeInstantBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
modeInstantBtn.Parent = modeContainer
Instance.new("UICorner", modeInstantBtn).CornerRadius = UDim.new(0, 6)

-- Hệ thống Quản Lý Tệp (Mới)
local fileContainer = Instance.new("Frame")
fileContainer.Size = UDim2.new(0.9, 0, 0, 32)
fileContainer.Position = UDim2.new(0.05, 0, 0, 88)
fileContainer.BackgroundTransparency = 1
fileContainer.Parent = mainFrame

local fileNameBox = Instance.new("TextBox")
fileNameBox.Size = UDim2.new(0.5, 0, 1, 0)
fileNameBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
fileNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
fileNameBox.PlaceholderText = "Nhập tên tệp..."
fileNameBox.Font = Enum.Font.Gotham
fileNameBox.TextSize = 12
fileNameBox.Text = "MacDinh"
fileNameBox.Parent = fileContainer
Instance.new("UICorner", fileNameBox).CornerRadius = UDim.new(0, 6)

local fileSaveBtn = Instance.new("TextButton")
fileSaveBtn.Size = UDim2.new(0.23, 0, 1, 0)
fileSaveBtn.Position = UDim2.new(0.53, 0, 0, 0)
fileSaveBtn.Text = "💾 Lưu"
fileSaveBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
fileSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fileSaveBtn.Font = Enum.Font.GothamBold
fileSaveBtn.TextSize = 11
fileSaveBtn.Parent = fileContainer
Instance.new("UICorner", fileSaveBtn).CornerRadius = UDim.new(0, 6)

local fileLoadBtn = Instance.new("TextButton")
fileLoadBtn.Size = UDim2.new(0.22, 0, 1, 0)
fileLoadBtn.Position = UDim2.new(0.78, 0, 0, 0)
fileLoadBtn.Text = "📂 Tải"
fileLoadBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 50)
fileLoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fileLoadBtn.Font = Enum.Font.GothamBold
fileLoadBtn.TextSize = 11
fileLoadBtn.Parent = fileContainer
Instance.new("UICorner", fileLoadBtn).CornerRadius = UDim.new(0, 6)

-- Nút Thêm Vị Trí Hiện Tại
local addLocationBtn = Instance.new("TextButton")
addLocationBtn.Size = UDim2.new(0.9, 0, 0, 36)
addLocationBtn.Position = UDim2.new(0.05, 0, 0, 128)
addLocationBtn.Text = "+ Thêm Vị Trí Đang Đứng"
addLocationBtn.Font = Enum.Font.GothamBold
addLocationBtn.TextSize = 13
addLocationBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
addLocationBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addLocationBtn.Parent = mainFrame
Instance.new("UICorner", addLocationBtn).CornerRadius = UDim.new(0, 8)

-- Khung Cuộn Danh Sách
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 1, -175)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 170)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

---------------------------------------------
-- UI CẬP NHẬT
---------------------------------------------
local function updateUI()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for index, locData in ipairs(locations) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -6, 0, 40)
        itemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        itemFrame.Parent = scrollFrame
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        nameLabel.Position = UDim2.new(0.04, 0, 0, 0)
        nameLabel.Text = locData.Name
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.28, 0, 0.7, 0)
        tpBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
        tpBtn.Text = "Đến"
        tpBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 12
        tpBtn.Parent = itemFrame
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
        delBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
        delBtn.Text = "✕"
        delBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 12
        delBtn.Parent = itemFrame
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5)

        tpBtn.Activated:Connect(function()
            _G.TeleportPlayer(locData.CFrame)
        end)

        delBtn.Activated:Connect(function()
            table.remove(locations, index)
            updateUI()
        end)
    end

    local count = #locations
    local targetHeight = BASE_MENU_HEIGHT + (count * ITEM_HEIGHT)
    local finalHeight = math.min(targetHeight, MAX_MENU_HEIGHT)
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 290, 0, finalHeight)
    }):Play()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * ITEM_HEIGHT)
end

---------------------------------------------
-- TƯƠNG TÁC NÚT LOGIC
---------------------------------------------
local function setMode(mode)
    currentMode = mode
    if mode == "Fast" then
        modeFastBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        modeFastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        modeInstantBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        modeInstantBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    else
        modeInstantBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
        modeInstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        modeFastBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        modeFastBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    end
end
modeFastBtn.Activated:Connect(function() setMode("Fast") end)
modeInstantBtn.Activated:Connect(function() setMode("Instant") end)

fileSaveBtn.Activated:Connect(function()
    if saveConfig(fileNameBox.Text) then
        fileSaveBtn.Text = "Đã Lưu!"
        task.wait(1)
        fileSaveBtn.Text = "💾 Lưu"
    end
end)

fileLoadBtn.Activated:Connect(function()
    if loadConfig(fileNameBox.Text) then
        updateUI()
        fileLoadBtn.Text = "Đã Tải!"
    else
        fileLoadBtn.Text = "Lỗi!"
    end
    task.wait(1)
    fileLoadBtn.Text = "📂 Tải"
end)

addLocationBtn.Activated:Connect(function()
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        table.insert(locations, {
            Name = "Điểm " .. (#locations + 1),
            CFrame = rootPart.CFrame
        })
        updateUI()
    end
end)

---------------------------------------------
-- LOGIC DI CHUYỂN
---------------------------------------------
_G.TeleportPlayer = function(targetCFrame)
    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end

    if currentMode == "Instant" then
        for i = 1, 3 do
            rootPart.CFrame = targetCFrame
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.03)
        end
    else
        local runAnim = Instance.new("Animation")
        runAnim.AnimationId = "rbxassetid://180426354"
        local track = (humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)):LoadAnimation(runAnim)
        track:Play()

        local timeToTake = math.max((rootPart.Position - targetCFrame.Position).Magnitude / MOVE_SPEED, 0.15)
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero

        local tween = TweenService:Create(rootPart, TweenInfo.new(timeToTake, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        rootPart.Anchored = true
        tween:Play()

        tween.Completed:Connect(function()
            track:Stop() runAnim:Destroy()
            for i = 1, 5 do
                rootPart.CFrame = targetCFrame
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
                task.wait(0.04)
            end
            rootPart.Anchored = false
        end)
    end
end

---------------------------------------------
-- DRAG THẢ GUI
---------------------------------------------
local function enableDrag(dragFrame, handleFrame)
    local dragging, dragInput, dragStart, startPos
    (handleFrame or dragFrame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = dragFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    (handleFrame or dragFrame).InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            dragFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local btnDragged, btnDragStart = false, nil
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        btnDragged = false btnDragStart = input.Position
    end
end)
toggleButton.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not btnDragged then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragStart and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        if (input.Position - btnDragStart).Magnitude > 5 then btnDragged = true end
    end
end)

enableDrag(toggleButton)
enableDrag(mainFrame, topBar)
closeBtn.Activated:Connect(function() mainFrame.Visible = false end)

-- Khởi động tải tệp mặc định
loadConfig("MacDinh")
updateUI()
