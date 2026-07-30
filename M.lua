-- Bỏ qua cảnh báo bảo mật nếu chạy trên executor
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. XOÁ GUI CŨ NẾU ĐÃ CHẠY TRƯỚC ĐÓ
-- ==========================================
local guiName = "InfiniteFollow_Mobile_V3"
if CoreGui:FindFirstChild(guiName) then
    CoreGui[guiName]:Destroy()
end

-- ==========================================
-- 2. TẠO HỆ THỐNG GIAO DIỆN (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
local success, result = pcall(function() return gethui() end)
ScreenGui.Parent = success and result or (CoreGui:FindFirstChild("RobloxGui") and CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

-- BIẾN TOÀN CỤC LƯU TRẠNG THÁI
local targetPlayer = nil
local isFollowing = false
local followSpeed = 25
local isFlyEnabled = false
local isNoclipEnabled = false

local followConnection = nil
local noclipConnection = nil
local bodyVel = nil
local bodyGyro = nil

-- BẢNG MÀU CHUẨN
local colors = {
    Bg = Color3.fromRGB(15, 15, 17),        
    PanelBg = Color3.fromRGB(22, 22, 25),   
    ElementBg = Color3.fromRGB(30, 30, 35), 
    Accent = Color3.fromRGB(107, 33, 168),  
    Green = Color3.fromRGB(34, 197, 94),
    Red = Color3.fromRGB(239, 68, 68),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(156, 163, 175)
}

-- HÀM DRAG (KÉO THẢ)
local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging, dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- 3. XÂY DỰNG GIAO DIỆN TỐI ƯU MOBILE (80% MÀN HÌNH NGANG)
-- ==========================================

-- [ NÚT TOGGLE IY ]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = colors.Bg
ToggleBtn.Text = "IY"
ToggleBtn.TextColor3 = colors.Text
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(60, 60, 65)
makeDraggable(ToggleBtn)

-- [ MAIN FRAME - Kích thước tối ưu cho đt màn hình ngang (Rộng 520, Cao 280) ]
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 280)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -140)
MainFrame.BackgroundColor3 = colors.Bg
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 50, 55)

-- [ TOPBAR ]
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 32)
Topbar.BackgroundColor3 = colors.Bg
Topbar.Parent = MainFrame
makeDraggable(MainFrame, Topbar)
Instance.new("UIStroke", Topbar).Color = Color3.fromRGB(50, 50, 55)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 35, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Infinite Follow (Mobile)"
Title.TextColor3 = colors.Text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local IconMenu = Instance.new("TextLabel")
IconMenu.Size = UDim2.new(0, 30, 1, 0)
IconMenu.BackgroundTransparency = 1
IconMenu.Text = "≡"
IconMenu.TextColor3 = colors.Text
IconMenu.Font = Enum.Font.GothamBold
IconMenu.TextSize = 16
IconMenu.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = colors.Text
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextSize = 12
CloseBtn.Parent = Topbar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = colors.Text
MinimizeBtn.Font = Enum.Font.GothamMedium
MinimizeBtn.TextSize = 12
MinimizeBtn.Parent = Topbar

-- [ CỘT TRÁI: DANH SÁCH PLAYERS ]
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 230, 1, -40)
LeftPanel.Position = UDim2.new(0, 8, 0, 36)
LeftPanel.BackgroundColor3 = colors.PanelBg
LeftPanel.Parent = MainFrame
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 6)

local ListTitle = Instance.new("TextLabel")
ListTitle.Size = UDim2.new(1, -15, 0, 22)
ListTitle.Position = UDim2.new(0, 8, 0, 4)
ListTitle.BackgroundTransparency = 1
ListTitle.Text = "PLAYERS IN SERVER"
ListTitle.TextColor3 = colors.TextDim
ListTitle.Font = Enum.Font.GothamMedium
ListTitle.TextSize = 10
ListTitle.TextXAlignment = Enum.TextXAlignment.Left
ListTitle.Parent = LeftPanel

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 26)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = LeftPanel
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollFrame

-- [ CỘT PHẢI: ĐIỀU KHIỂN ]
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -250, 1, -40)
RightPanel.Position = UDim2.new(0, 244, 0, 36)
RightPanel.BackgroundTransparency = 1
RightPanel.Parent = MainFrame

local SelectedTitle = Instance.new("TextLabel")
SelectedTitle.Size = UDim2.new(1, 0, 0, 16)
SelectedTitle.BackgroundTransparency = 1
SelectedTitle.Text = "SELECTED: NONE"
SelectedTitle.TextColor3 = colors.Accent
SelectedTitle.Font = Enum.Font.GothamBold
SelectedTitle.TextSize = 11
SelectedTitle.TextXAlignment = Enum.TextXAlignment.Left
SelectedTitle.Parent = RightPanel

-- Nút Start / Stop thu gọn vừa màn hình ngang
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, 0, 0, 30)
StartBtn.Position = UDim2.new(0, 0, 0, 20)
StartBtn.BackgroundColor3 = colors.Accent
StartBtn.Text = "▶ Start Follow"
StartBtn.TextColor3 = colors.Text
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 12
StartBtn.Parent = RightPanel
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 5)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, 0, 0, 26)
StopBtn.Position = UDim2.new(0, 0, 0, 54)
StopBtn.BackgroundColor3 = colors.ElementBg
StopBtn.Text = "■ Stop Follow"
StopBtn.TextColor3 = colors.Text
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 12
StopBtn.Parent = RightPanel
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 5)

-- Slider Tốc độ
local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, 0, 0, 18)
SpeedTitle.Position = UDim2.new(0, 0, 0, 85)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "SPEED: 25"
SpeedTitle.TextColor3 = colors.Text
SpeedTitle.Font = Enum.Font.GothamMedium
SpeedTitle.TextSize = 11
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = RightPanel

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, 0, 0, 5)
SliderBg.Position = UDim2.new(0, 0, 0, 105)
SliderBg.BackgroundColor3 = colors.PanelBg
SliderBg.Parent = RightPanel
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.21, 0, 1, 0)
SliderFill.BackgroundColor3 = colors.Accent
SliderFill.Parent = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, 0, 1, 16)
SliderBtn.Position = UDim2.new(0, 0, 0, -8)
SliderBtn.BackgroundTransparency = 1
SliderBtn.Text = ""
SliderBtn.Parent = SliderBg

-- Tạo Toggle Nhỏ gọn (Fly & Noclip)
local function createMobileToggle(title, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = RightPanel
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = colors.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 36, 0, 20)
    toggleBg.Position = UDim2.new(1, -36, 0.5, -10)
    toggleBg.BackgroundColor3 = colors.PanelBg
    toggleBg.Text = ""
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = UDim2.new(0, 3, 0.5, -7)
    circle.BackgroundColor3 = colors.TextDim
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local isOn = false
    local function setToggle(state)
        isOn = state
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = isOn and colors.Text or colors.TextDim
        }):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and colors.Accent or colors.PanelBg
        }):Play()
    end
    
    return toggleBg, function() return isOn end, setToggle
end

local FlyToggleBtn, getFlyState, setFlyState = createMobileToggle("Fly (Bay)", 120)
local NoclipToggleBtn, getNoclipState, setNoclipState = createMobileToggle("Noclip (Xuyên)", 148)

-- [ NOTIFICATION SYSTEM MỎNG GỌN ]
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 220, 1, -10)
NotifContainer.Position = UDim2.new(1, -230, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 6)
NotifLayout.Parent = NotifContainer

local function Notify(title, desc, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = colors.Bg
    frame.BackgroundTransparency = 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(50, 50, 55)
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 1, 0)
    line.BackgroundColor3 = color
    line.Parent = frame
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 5)
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -25, 0, 18)
    tLabel.Position = UDim2.new(0, 10, 0, 4)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = color
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 11
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = frame
    
    local dLabel = Instance.new("TextLabel")
    dLabel.Size = UDim2.new(1, -25, 0, 16)
    dLabel.Position = UDim2.new(0, 10, 0, 22)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = desc
    dLabel.TextColor3 = colors.TextDim
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 9
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.Parent = frame

    frame.Parent = NotifContainer
    TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    
    task.spawn(function()
        task.wait(3)
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        frame:Destroy()
    end)
end

-- ==========================================
-- 4. LOGIC CHỌN PLAYER VÀ FOLLOW
-- ==========================================
local playerButtons = {}

local function updatePlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    table.clear(playerButtons)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Dùng TextButton toàn diện để dễ bấm trên điện thoại
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = colors.ElementBg
        btn.AutoButtonColor = true
        btn.Text = "  " .. player.DisplayName
        btn.TextColor3 = colors.Text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = ScrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        
        -- Xử lý sự kiện click chuẩn xác trên di động
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(playerButtons) do
                b.BackgroundColor3 = colors.ElementBg
            end
            
            btn.BackgroundColor3 = colors.Accent
            targetPlayer = player
            SelectedTitle.Text = "SELECTED: " .. player.DisplayName
            Notify("Đã chọn", player.DisplayName, colors.Accent)
        end)
        
        table.insert(playerButtons, btn)
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
    if targetPlayer == player then
        targetPlayer = nil
        SelectedTitle.Text = "SELECTED: NONE"
        if isFollowing then
            isFollowing = false
            Notify("Mục tiêu rời đi", "Đã dừng follow.", colors.Red)
        end
    end
    updatePlayerList()
end)
updatePlayerList()

-- [ HỆ THỐNG FLY & NOCLIP ]
local function cleanFlyMovers()
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

local function stopFollowing()
    isFollowing = false
    if followConnection then followConnection:Disconnect(); followConnection = nil end
    cleanFlyMovers()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 
        LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
    end
end

StartBtn.MouseButton1Click:Connect(function()
    if not targetPlayer then
        Notify("Chưa chọn", "Vui lòng chọn người chơi!", colors.Red)
        return
    end
    if isFollowing then return end
    
    isFollowing = true
    Notify("Bắt đầu", "Đang bám theo " .. targetPlayer.DisplayName, colors.Green)
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not isFollowing then return end
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            stopFollowing()
            Notify("Mục tiêu mất", "Mục tiêu đã reset/rời game.", colors.Red)
            return
        end
        
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChild("Humanoid") then return end
        
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local myHRP = myChar.HumanoidRootPart
        local distance = (targetHRP.Position - myHRP.Position).Magnitude
        
        if isFlyEnabled then
            if not bodyVel or not bodyVel.Parent then
                bodyVel = Instance.new("BodyVelocity", myHRP)
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro = Instance.new("BodyGyro", myHRP)
                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro.D = 500
                myChar.Humanoid.PlatformStand = true
            end
            if distance > 3 then
                bodyVel.Velocity = (targetHRP.Position - myHRP.Position).Unit * followSpeed
                bodyGyro.CFrame = CFrame.new(myHRP.Position, targetHRP.Position)
            else
                bodyVel.Velocity = Vector3.zero
            end
        else
            cleanFlyMovers()
            if distance > 3 then
                myChar.Humanoid.WalkSpeed = followSpeed
                myChar.Humanoid:MoveTo(targetHRP.Position)
            else
                myChar.Humanoid:MoveTo(myHRP.Position)
            end
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    stopFollowing()
    Notify("Đã dừng", "Đã dừng theo dõi mục tiêu.", colors.Red)
end)

FlyToggleBtn.MouseButton1Click:Connect(function()
    isFlyEnabled = not isFlyEnabled
    setFlyState(isFlyEnabled)
    if not isFlyEnabled then cleanFlyMovers() end
end)

NoclipToggleBtn.MouseButton1Click:Connect(function()
    isNoclipEnabled = not isNoclipEnabled
    setNoclipState(isNoclipEnabled)
    if isNoclipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end)

-- Slider logic cho mobile
local draggingSlider = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
        local percentage = relativeX / SliderBg.AbsoluteSize.X
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        followSpeed = math.floor(5 + (95 * percentage))
        SpeedTitle.Text = "SPEED: " .. followSpeed
    end
end)

-- Đóng / Mở menu
local menuOpen = true
ToggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen; MainFrame.Visible = menuOpen
end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; menuOpen = false end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; menuOpen = false end)

Notify("Thành công", "Đã tải giao diện Mobile tối ưu!", colors.Green)
