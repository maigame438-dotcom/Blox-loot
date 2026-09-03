repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local MOVE_SPEED = 180 
local gameId = tostring(game.PlaceId)

-- Dữ liệu lưu trữ
local masterFileName = "TPMenu_Master_" .. gameId .. ".json"
local savedFiles = {} 
local currentFile = nil
local currentLocations = {}
local currentMode = "Fast"

---------------------------------------------
-- HỆ THỐNG QUẢN LÝ TỆP (FILE SYSTEM)
---------------------------------------------
local function loadMaster()
    if readfile and isfile and isfile(masterFileName) then
        local s, r = pcall(function() return HttpService:JSONDecode(readfile(masterFileName)) end)
        if s and type(r) == "table" then savedFiles = r end
    end
end

local function saveMaster()
    if writefile then
        writefile(masterFileName, HttpService:JSONEncode(savedFiles))
    end
end

local function getFilePath(fileName)
    local safeName = string.gsub(fileName, "[^%w%_]", "")
    return "TPMenu_Data_" .. gameId .. "_" .. safeName .. ".json"
end

local function loadFileData(fileName)
    local path = getFilePath(fileName)
    currentLocations = {}
    if readfile and isfile and isfile(path) then
        local s, r = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if s and type(r) == "table" then
            for _, loc in ipairs(r) do
                table.insert(currentLocations, {Name = loc.Name, CFrame = CFrame.new(unpack(loc.CFrame))})
            end
        end
    end
end

local function saveFileData()
    if not currentFile or not writefile then return end
    local data = {}
    for _, loc in ipairs(currentLocations) do
        table.insert(data, {Name = loc.Name, CFrame = {loc.CFrame:GetComponents()}})
    end
    writefile(getFilePath(currentFile), HttpService:JSONEncode(data))
end

---------------------------------------------
-- KHỞI TẠO GUI CHÍNH
---------------------------------------------
local guiParent
local s, core = pcall(function() return game:GetService("CoreGui") end)
guiParent = gethui and gethui() or (s and core) or player:WaitForChild("PlayerGui")

if guiParent:FindFirstChild("MobileTP_MasterUI") then 
    guiParent.MobileTP_MasterUI:Destroy() 
end

local screen = Instance.new("ScreenGui")
screen.Name = "MobileTP_MasterUI"
screen.ResetOnSpawn = false
screen.Parent = guiParent

-- Nút Kích hoạt nổi (Kéo thả được)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "🚀"
toggleBtn.TextSize = 20
toggleBtn.Parent = screen
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", toggleBtn).Color = Color3.fromRGB(50, 50, 50)

---------------------------------------------
-- TẠO STYLE CHUNG (Tối giản / Dark Mode)
---------------------------------------------
local function createStyleWindow(name, size, pos)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Visible = false
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = screen
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    topBar.BorderSizePixel = 0
    topBar.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.04, 0, 0, 0)
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    return frame, topBar, title
end

---------------------------------------------
-- GIAO DIỆN MAIN (Quản lý File)
---------------------------------------------
local mainUI, mainTop, mainTitle = createStyleWindow("MainMenu", UDim2.new(0, 300, 0, 320), UDim2.new(0.5, -150, 0.5, -160))
mainTitle.Text = "Main - Quản Lý Tệp"

local mainClose = Instance.new("TextButton")
mainClose.Size = UDim2.new(0, 30, 1, 0)
mainClose.Position = UDim2.new(1, -30, 0, 0)
mainClose.Text = "✕"
mainClose.TextColor3 = Color3.fromRGB(150, 150, 150)
mainClose.BackgroundTransparency = 1
mainClose.Parent = mainTop

local addFileBox = Instance.new("TextBox")
addFileBox.Size = UDim2.new(0.7, 0, 0, 35)
addFileBox.Position = UDim2.new(0.05, 0, 0, 40)
addFileBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
addFileBox.TextColor3 = Color3.fromRGB(255, 255, 255)
addFileBox.PlaceholderText = "Nhập tên tệp mới..."
addFileBox.Font = Enum.Font.Gotham
addFileBox.TextSize = 12
addFileBox.Parent = mainUI
Instance.new("UICorner", addFileBox).CornerRadius = UDim.new(0, 6)

local addFileBtn = Instance.new("TextButton")
addFileBtn.Size = UDim2.new(0.2, 0, 0, 35)
addFileBtn.Position = UDim2.new(0.77, 0, 0, 40)
addFileBtn.Text = "Tạo"
addFileBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
addFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addFileBtn.Font = Enum.Font.GothamBold
addFileBtn.TextSize = 12
addFileBtn.Parent = mainUI
Instance.new("UICorner", addFileBtn).CornerRadius = UDim.new(0, 6)

local fileScroll = Instance.new("ScrollingFrame")
fileScroll.Size = UDim2.new(0.9, 0, 1, -95)
fileScroll.Position = UDim2.new(0.05, 0, 0, 85)
fileScroll.BackgroundTransparency = 1
fileScroll.BorderSizePixel = 0
fileScroll.ScrollBarThickness = 3
fileScroll.Parent = mainUI
local fileListLayout = Instance.new("UIListLayout", fileScroll)
fileListLayout.Padding = UDim.new(0, 5)

---------------------------------------------
-- GIAO DIỆN SUBMENU (Điểm dịch chuyển)
---------------------------------------------
local subUI, subTop, subTitle = createStyleWindow("SubMenu", UDim2.new(0, 280, 0, 360), UDim2.new(0.5, 160, 0.5, -160))

local subMinimize = Instance.new("TextButton")
subMinimize.Size = UDim2.new(0, 30, 1, 0)
subMinimize.Position = UDim2.new(1, -60, 0, 0)
subMinimize.Text = "—"
subMinimize.TextColor3 = Color3.fromRGB(150, 150, 150)
subMinimize.BackgroundTransparency = 1
subMinimize.Parent = subTop

local subClose = Instance.new("TextButton")
subClose.Size = UDim2.new(0, 30, 1, 0)
subClose.Position = UDim2.new(1, -30, 0, 0)
subClose.Text = "✕"
subClose.TextColor3 = Color3.fromRGB(150, 150, 150)
subClose.BackgroundTransparency = 1
subClose.Parent = subTop

-- Content bên trong SubMenu
local subContent = Instance.new("Frame")
subContent.Size = UDim2.new(1, 0, 1, -30)
subContent.Position = UDim2.new(0, 0, 0, 30)
subContent.BackgroundTransparency = 1
subContent.Parent = subUI

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.9, 0, 0, 30)
modeBtn.Position = UDim2.new(0.05, 0, 0, 10)
modeBtn.Text = "Chế độ: Bay Tốc Độ (Fast)"
modeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
modeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
modeBtn.Font = Enum.Font.GothamMedium
modeBtn.TextSize = 12
modeBtn.Parent = subContent
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 6)

local addLocBtn = Instance.new("TextButton")
addLocBtn.Size = UDim2.new(0.9, 0, 0, 35)
addLocBtn.Position = UDim2.new(0.05, 0, 0, 48)
addLocBtn.Text = "+ Lưu Vị Trí Đang Đứng"
addLocBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
addLocBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addLocBtn.Font = Enum.Font.GothamBold
addLocBtn.TextSize = 12
addLocBtn.Parent = subContent
Instance.new("UICorner", addLocBtn).CornerRadius = UDim.new(0, 6)

local locScroll = Instance.new("ScrollingFrame")
locScroll.Size = UDim2.new(0.9, 0, 1, -100)
locScroll.Position = UDim2.new(0.05, 0, 0, 90)
locScroll.BackgroundTransparency = 1
locScroll.BorderSizePixel = 0
locScroll.ScrollBarThickness = 3
locScroll.Parent = subContent
local locListLayout = Instance.new("UIListLayout", locScroll)
locListLayout.Padding = UDim.new(0, 5)

---------------------------------------------
-- LOGIC & CHỨC NĂNG CẬP NHẬT GIAO DIỆN
---------------------------------------------
local isMinimized = false

local function updateLocUI()
    for _, child in pairs(locScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for index, loc in ipairs(currentLocations) do
        local item = Instance.new("Frame", locScroll)
        item.Size = UDim2.new(1, -5, 0, 35)
        item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 5)

        local name = Instance.new("TextLabel", item)
        name.Size = UDim2.new(0.5, 0, 1, 0)
        name.Position = UDim2.new(0.05, 0, 0, 0)
        name.Text = loc.Name
        name.BackgroundTransparency = 1
        name.TextColor3 = Color3.fromRGB(220, 220, 220)
        name.Font = Enum.Font.Gotham
        name.TextSize = 12
        name.TextXAlignment = Enum.TextXAlignment.Left

        local tp = Instance.new("TextButton", item)
        tp.Size = UDim2.new(0.25, 0, 0.7, 0)
        tp.Position = UDim2.new(0.55, 0, 0.15, 0)
        tp.Text = "Đến"
        tp.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        tp.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)

        local del = Instance.new("TextButton", item)
        del.Size = UDim2.new(0.12, 0, 0.7, 0)
        del.Position = UDim2.new(0.83, 0, 0.15, 0)
        del.Text = "✕"
        del.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        del.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4)

        tp.Activated:Connect(function() _G.TPPlayer(loc.CFrame) end)
        del.Activated:Connect(function()
            table.remove(currentLocations, index)
            saveFileData() updateLocUI()
        end)
    end
    locScroll.CanvasSize = UDim2.new(0, 0, 0, #currentLocations * 40)
end

local function updateMainUI()
    for _, child in pairs(fileScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for index, fName in ipairs(savedFiles) do
        local item = Instance.new("Frame", fileScroll)
        item.Size = UDim2.new(1, -5, 0, 40)
        item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 5)

        local name = Instance.new("TextLabel", item)
        name.Size = UDim2.new(0.5, 0, 1, 0)
        name.Position = UDim2.new(0.05, 0, 0, 0)
        name.Text = "📁 " .. fName
        name.BackgroundTransparency = 1
        name.TextColor3 = Color3.fromRGB(220, 220, 220)
        name.Font = Enum.Font.GothamMedium
        name.TextSize = 13
        name.TextXAlignment = Enum.TextXAlignment.Left

        local openBtn = Instance.new("TextButton", item)
        openBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
        openBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
        openBtn.Text = "Mở"
        openBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 50)
        openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 4)

        local delBtn = Instance.new("TextButton", item)
        delBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
        delBtn.Position = UDim2.new(0.83, 0, 0.15, 0)
        delBtn.Text = "✕"
        delBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

        openBtn.Activated:Connect(function()
            currentFile = fName
            subTitle.Text = "Tệp: " .. fName
            loadFileData(fName)
            updateLocUI()
            subUI.Visible = true
            if isMinimized then subMinimize.Activated:Fire() end
        end)
        
        delBtn.Activated:Connect(function()
            if delfile and isfile and isfile(getFilePath(fName)) then delfile(getFilePath(fName)) end
            table.remove(savedFiles, index)
            saveMaster() updateMainUI()
            if currentFile == fName then subUI.Visible = false currentFile = nil end
        end)
    end
    fileScroll.CanvasSize = UDim2.new(0, 0, 0, #savedFiles * 45)
end

---------------------------------------------
-- TƯƠNG TÁC NÚT CƠ BẢN
---------------------------------------------
addFileBtn.Activated:Connect(function()
    local text = addFileBox.Text
    if text ~= "" then
        table.insert(savedFiles, text)
        saveMaster()
        updateMainUI()
        addFileBox.Text = ""
    end
end)

addLocBtn.Activated:Connect(function()
    if not currentFile then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        table.insert(currentLocations, {Name = "Điểm " .. (#currentLocations + 1), CFrame = root.CFrame})
        saveFileData()
        updateLocUI()
    end
end)

modeBtn.Activated:Connect(function()
    if currentMode == "Fast" then
        currentMode = "Instant"
        modeBtn.Text = "Chế độ: TP Tức Thì (TP)"
    else
        currentMode = "Fast"
        modeBtn.Text = "Chế độ: Bay Tốc Độ (Fast)"
    end
end)

-- Thu gọn SubMenu
subMinimize.Activated:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(subUI, TweenInfo.new(0.2), {Size = UDim2.new(0, 280, 0, 30)}):Play()
        subContent.Visible = false
    else
        TweenService:Create(subUI, TweenInfo.new(0.2), {Size = UDim2.new(0, 280, 0, 360)}):Play()
        subContent.Visible = true
    end
end)

mainClose.Activated:Connect(function() mainUI.Visible = false end)
subClose.Activated:Connect(function() subUI.Visible = false currentFile = nil end)

---------------------------------------------
-- DI CHUYỂN CHỐNG ANTI-CHEAT
---------------------------------------------
_G.TPPlayer = function(targetCFrame)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if currentMode == "Instant" then
        for i = 1, 3 do
            root.CFrame = targetCFrame
            root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
            task.wait(0.05)
        end
    else
        local runAnim = Instance.new("Animation")
        runAnim.AnimationId = "rbxassetid://180426354"
        local track = (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)):LoadAnimation(runAnim)
        track:Play()

        local timeToTake = math.max((root.Position - targetCFrame.Position).Magnitude / MOVE_SPEED, 0.15)
        root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero

        local tween = TweenService:Create(root, TweenInfo.new(timeToTake, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        root.Anchored = true
        tween:Play()

        tween.Completed:Connect(function()
            track:Stop() runAnim:Destroy()
            for i = 1, 5 do
                root.CFrame = targetCFrame
                root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
                task.wait(0.05)
            end
            root.Anchored = false
        end)
    end
end

---------------------------------------------
-- HỆ THỐNG KÉO THẢ GIAO DIỆN
---------------------------------------------
local function makeDraggable(frame, topBar)
    local dragToggle, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(mainUI, mainTop)
makeDraggable(subUI, subTop)

-- Nút nổi bật tắt Main Menu
local btnDragged, btnDragStart = false, nil
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        btnDragged = false 
        btnDragStart = input.Position
    end
end)
toggleBtn.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not btnDragged then
        mainUI.Visible = not mainUI.Visible
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragStart and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        if (input.Position - btnDragStart).Magnitude > 5 then btnDragged = true end
    end
end)
makeDraggable(toggleBtn, toggleBtn)

---------------------------------------------
-- KHỞI ĐỘNG
---------------------------------------------
loadMaster()
updateMainUI()
