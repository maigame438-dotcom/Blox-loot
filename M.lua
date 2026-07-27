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
local guiName = "InfiniteFollow_GUI_V1"
if CoreGui:FindFirstChild(guiName) then
    CoreGui[guiName]:Destroy()
end

-- ==========================================
-- 2. TẠO HỆ THỐNG GIAO DIỆN (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
-- Sử dụng gethui() nếu hỗ trợ, nếu không dùng CoreGui, fallback PlayerGui
local success, result = pcall(function() return gethui() end)
ScreenGui.Parent = success and result or (CoreGui:FindFirstChild("RobloxGui") and CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

-- BIẾN TOÀN CỤC CỦA CHỨC NĂNG
local targetPlayer = nil
local isFollowing = false
local followSpeed = 25
local heartbeatConnection = nil

-- MÀU SẮC CHỦ ĐẠO
local colors = {
    Bg = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(15, 15, 15),
    ElementBg = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(107, 33, 168), -- Màu tím mộng mơ (Purple)
    Green = Color3.fromRGB(34, 197, 94),
    Red = Color3.fromRGB(239, 68, 68),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 170)
}

-- HÀM HỖ TRỢ KÉO THẢ (DRAG)
local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- ==========================================
-- 3. XÂY DỰNG GIAO DIỆN (UI COMPONENTS)
-- ==========================================

-- [ NÚT TOGGLE IY ]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = colors.Bg
ToggleBtn.Text = "IY"
ToggleBtn.TextColor3 = colors.Text
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn
makeDraggable(ToggleBtn)

-- [ MAIN MENU ]
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
MainFrame.BackgroundColor3 = colors.Bg
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- [ TOPBAR ]
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = colors.Topbar
Topbar.Parent = MainFrame
makeDraggable(MainFrame, Topbar)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Infinite Follow"
Title.TextColor3 = colors.Text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 16
Title.Parent = Topbar

local IconMenu = Instance.new("TextLabel")
IconMenu.Size = UDim2.new(0, 40, 1, 0)
IconMenu.BackgroundTransparency = 1
IconMenu.Text = "≡"
IconMenu.TextColor3 = colors.Text
IconMenu.Font = Enum.Font.GothamBold
IconMenu.TextSize = 20
IconMenu.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = colors.Text
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextSize = 14
CloseBtn.Parent = Topbar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -80, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = colors.Text
MinimizeBtn.Font = Enum.Font.GothamMedium
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = Topbar

-- [ CONTENT AREA ]
local PlayersLabel = Instance.new("TextLabel")
PlayersLabel.Size = UDim2.new(1, -20, 0, 20)
PlayersLabel.Position = UDim2.new(0, 10, 0, 45)
PlayersLabel.BackgroundTransparency = 1
PlayersLabel.Text = "PLAYERS IN SERVER"
PlayersLabel.TextColor3 = colors.TextDim
PlayersLabel.Font = Enum.Font.Gotham
PlayersLabel.TextSize = 12
PlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayersLabel.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 0, 150)
ScrollFrame.Position = UDim2.new(0, 10, 0, 70)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1, -20, 0, 20)
SelectedLabel.Position = UDim2.new(0, 10, 0, 230)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "SELECTED: None"
SelectedLabel.TextColor3 = colors.TextDim
SelectedLabel.Font = Enum.Font.GothamMedium
SelectedLabel.TextSize = 13
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = MainFrame

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, -20, 0, 35)
StartBtn.Position = UDim2.new(0, 10, 0, 260)
StartBtn.BackgroundColor3 = colors.Accent
StartBtn.Text = "Start Follow"
StartBtn.TextColor3 = colors.Text
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, -20, 0, 35)
StopBtn.Position = UDim2.new(0, 10, 0, 305)
StopBtn.BackgroundColor3 = colors.ElementBg
StopBtn.Text = "Stop Follow"
StopBtn.TextColor3 = colors.Text
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = MainFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 350)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "FOLLOW SPEED: 25"
SpeedLabel.TextColor3 = colors.TextDim
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

-- [ SLIDER COMPONENT ]
local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, -20, 0, 6)
SliderBg.Position = UDim2.new(0, 10, 0, 375)
SliderBg.BackgroundColor3 = colors.ElementBg
SliderBg.Parent = MainFrame
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.21, 0, 1, 0) -- (25-5)/95 ≈ 21%
SliderFill.BackgroundColor3 = colors.Accent
SliderFill.Parent = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, 0, 1, 20)
SliderBtn.Position = UDim2.new(0, 0, 0, -10)
SliderBtn.BackgroundTransparency = 1
SliderBtn.Text = ""
SliderBtn.Parent = SliderBg

local MinText = Instance.new("TextLabel")
MinText.Size = UDim2.new(0, 20, 0, 20)
MinText.Position = UDim2.new(0, 10, 0, 385)
MinText.BackgroundTransparency = 1
MinText.Text = "5"
MinText.TextColor3 = colors.TextDim
MinText.Font = Enum.Font.Gotham
MinText.TextSize = 12
MinText.TextXAlignment = Enum.TextXAlignment.Left
MinText.Parent = MainFrame

local MaxText = Instance.new("TextLabel")
MaxText.Size = UDim2.new(0, 30, 0, 20)
MaxText.Position = UDim2.new(1, -40, 0, 385)
MaxText.BackgroundTransparency = 1
MaxText.Text = "100"
MaxText.TextColor3 = colors.TextDim
MaxText.Font = Enum.Font.Gotham
MaxText.TextSize = 12
MaxText.TextXAlignment = Enum.TextXAlignment.Right
MaxText.Parent = MainFrame

-- [ NOTIFICATION SYSTEM ]
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 1, -20)
NotifContainer.Position = UDim2.new(1, -270, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotifContainer

local function Notify(title, desc, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = colors.Bg
    frame.BackgroundTransparency = 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 4, 1, 0)
    line.BackgroundColor3 = color
    line.Parent = frame
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 6)
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -50, 0, 25)
    tLabel.Position = UDim2.new(0, 45, 0, 5)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = color
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 14
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = frame
    
    local dLabel = Instance.new("TextLabel")
    dLabel.Size = UDim2.new(1, -50, 0, 20)
    dLabel.Position = UDim2.new(0, 45, 0, 30)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = desc
    dLabel.TextColor3 = colors.TextDim
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 12
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.Parent = frame
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 15)
    icon.BackgroundColor3 = colors.Topbar
    icon.Text = "IY"
    icon.TextColor3 = colors.Text
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 14
    icon.Parent = frame
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
    
    frame.Parent = NotifContainer
    
    -- Animation
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    
    task.spawn(function()
        task.wait(3.5)
        local fade = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        TweenService:Create(tLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(dLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(icon, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        fade:Play()
        fade.Completed:Wait()
        frame:Destroy()
    end)
end

-- ==========================================
-- 4. CHỨC NĂNG LOGIC SCRIPT
-- ==========================================

-- [ QUẢN LÝ DANH SÁCH PLAYERS ]
local playerButtons = {}

local function updatePlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    table.clear(playerButtons)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = colors.ElementBg
        btn.Text = "   " .. player.Name
        btn.TextColor3 = colors.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = ScrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local icon = Instance.new("Frame")
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, 8, 0.5, -8)
        icon.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        icon.Parent = btn
        Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
        
        btn.MouseButton1Click:Connect(function()
            -- Reset các nút khác
            for _, b in pairs(playerButtons) do
                b.BackgroundColor3 = colors.ElementBg
                b:FindFirstChildOfClass("Frame").BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end
            -- Đánh dấu nút được chọn
            btn.BackgroundColor3 = colors.Accent
            icon.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            
            targetPlayer = player
            SelectedLabel.Text = "SELECTED: " .. player.Name
            SelectedLabel.TextColor3 = colors.Accent
            Notify("Target Selected", "Đã chọn mục tiêu mới.", Color3.fromRGB(59, 130, 246))
        end)
        
        table.insert(playerButtons, btn)
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
    if targetPlayer == player then
        targetPlayer = nil
        SelectedLabel.Text = "SELECTED: None"
        SelectedLabel.TextColor3 = colors.TextDim
        if isFollowing then
            StopBtn:Fire()
            Notify("Player Left Server", "Mục tiêu đã rời server.", Color3.fromRGB(234, 179, 8))
        end
    end
    updatePlayerList()
end)

updatePlayerList()

-- [ HÀM DỪNG THEO DÕI ]
local function stopFollowing()
    isFollowing = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    StartBtn.Text = "Start Follow"
    StartBtn.BackgroundColor3 = colors.Accent
    
    -- Reset WalkSpeed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 
        LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
    end
end

-- [ LOGIC THEO DÕI (HEARTBEAT) ]
StartBtn.MouseButton1Click:Connect(function()
    if not targetPlayer then
        Notify("Please select a player.", "Vui lòng chọn người chơi.", colors.Accent)
        return
    end
    
    if isFollowing then return end
    isFollowing = true
    
    StartBtn.Text = "Start Follow (Đang theo dõi)"
    StartBtn.BackgroundColor3 = colors.Green
    Notify("Follow Started", "Đang theo dõi người chơi!", colors.Green)
    
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not isFollowing then return end
        
        -- Kiểm tra Target
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Nếu character target biến mất (reset chết)
            stopFollowing()
            Notify("Target Left Server", "Mục tiêu đã reset hoặc rời.", colors.Red)
            return
        end
        
        -- Kiểm tra LocalPlayer
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = targetPlayer.Character.HumanoidRootPart.Position
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            local distance = (targetPos - myPos).Magnitude
            
            local humanoid = LocalPlayer.Character.Humanoid
            
            -- Giữ khoảng cách 2-3 stud
            if distance > 3 then
                humanoid.WalkSpeed = followSpeed
                humanoid:MoveTo(targetPos)
            else
                humanoid:MoveTo(myPos) -- Đứng yên khi đã tới gần
            end
        end
    end)
end)

StopBtn.MouseButton1Click:Connect(function()
    if isFollowing then
        stopFollowing()
        Notify("Follow Stopped", "Đã dừng theo dõi.", colors.Red)
    end
end)

-- [ SLIDER LOGIC ]
local draggingSlider = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp(input.Position.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
        local percentage = relativeX / SliderBg.AbsoluteSize.X
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        followSpeed = math.floor(5 + (95 * percentage))
        SpeedLabel.Text = "FOLLOW SPEED: " .. followSpeed
    end
end)

-- [ TOGGLE & CLOSE MENU LOGIC ]
local menuOpen = true

local function toggleMenu()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
end

ToggleBtn.MouseButton1Click:Connect(toggleMenu)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; menuOpen = false end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; menuOpen = false end)

-- Tự động reconnect menu khi LocalPlayer reset (ResetOnSpawn = false đã giải quyết phần giữ UI)
LocalPlayer.CharacterAdded:Connect(function()
    -- Nếu đang follow mà reset bản thân thì tạm dừng để tránh lỗi
    if isFollowing then
        stopFollowing()
        Notify("Follow Stopped", "Bạn vừa respawn, theo dõi đã dừng.", colors.Red)
    end
end)
