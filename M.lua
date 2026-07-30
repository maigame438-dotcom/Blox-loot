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
local guiName = "InfiniteFollow_GUI_V2"
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

-- BẢNG MÀU CHUẨN (Dựa trên ảnh thiết kế)
local colors = {
    Bg = Color3.fromRGB(15, 15, 17),        -- Nền chính (Đen tuyền nhẹ)
    PanelBg = Color3.fromRGB(22, 22, 25),   -- Nền cột/panel
    ElementBg = Color3.fromRGB(30, 30, 35), -- Nền nút/list
    Accent = Color3.fromRGB(107, 33, 168),  -- Màu tím IY
    AccentHover = Color3.fromRGB(126, 34, 206),
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
-- 3. XÂY DỰNG GIAO DIỆN (UI COMPONENTS)
-- ==========================================

-- [ NÚT TOGGLE IY ]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = colors.Bg
ToggleBtn.Text = "IY"
ToggleBtn.TextColor3 = colors.Text
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
makeDraggable(ToggleBtn)

-- [ MAIN FRAME ]
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = colors.Bg
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(40, 40, 45)

-- [ TOPBAR ]
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = colors.Bg
Topbar.Parent = MainFrame
makeDraggable(MainFrame, Topbar)
Instance.new("UIStroke", Topbar).Color = Color3.fromRGB(40, 40, 45)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Infinite Follow"
Title.TextColor3 = colors.Text
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local IconMenu = Instance.new("TextLabel")
IconMenu.Size = UDim2.new(0, 40, 1, 0)
IconMenu.BackgroundTransparency = 1
IconMenu.Text = "≡"
IconMenu.TextColor3 = colors.Text
IconMenu.Font = Enum.Font.GothamBold
IconMenu.TextSize = 18
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

-- [ LEFT PANEL (PLAYER LIST) ]
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 270, 1, -50)
LeftPanel.Position = UDim2.new(0, 10, 0, 45)
LeftPanel.BackgroundColor3 = colors.PanelBg
LeftPanel.Parent = MainFrame
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 6)

local ListTitle = Instance.new("TextLabel")
ListTitle.Size = UDim2.new(1, -20, 0, 30)
ListTitle.Position = UDim2.new(0, 10, 0, 5)
ListTitle.BackgroundTransparency = 1
ListTitle.Text = "PLAYERS IN SERVER"
ListTitle.TextColor3 = colors.TextDim
ListTitle.Font = Enum.Font.GothamMedium
ListTitle.TextSize = 12
ListTitle.TextXAlignment = Enum.TextXAlignment.Left
ListTitle.Parent = LeftPanel

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollFrame.Position = UDim2.new(0, 10, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = LeftPanel
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

local ServerInfo = Instance.new("TextLabel")
ServerInfo.Size = UDim2.new(1, -20, 0, 20)
ServerInfo.Position = UDim2.new(0, 10, 1, -25)
ServerInfo.BackgroundTransparency = 1
ServerInfo.Text = "Online: 0 | Max: " .. Players.MaxPlayers
ServerInfo.TextColor3 = colors.TextDim
ServerInfo.Font = Enum.Font.Gotham
ServerInfo.TextSize = 12
ServerInfo.TextXAlignment = Enum.TextXAlignment.Left
ServerInfo.Parent = LeftPanel

-- [ RIGHT PANEL (CONTROLS) ]
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -300, 1, -50)
RightPanel.Position = UDim2.new(0, 290, 0, 45)
RightPanel.BackgroundTransparency = 1
RightPanel.Parent = MainFrame

local SelectedTitle = Instance.new("TextLabel")
SelectedTitle.Size = UDim2.new(1, 0, 0, 20)
SelectedTitle.BackgroundTransparency = 1
SelectedTitle.Text = "SELECTED PLAYER"
SelectedTitle.TextColor3 = colors.TextDim
SelectedTitle.Font = Enum.Font.GothamMedium
SelectedTitle.TextSize = 12
SelectedTitle.TextXAlignment = Enum.TextXAlignment.Left
SelectedTitle.Parent = RightPanel

-- Avatar & Info
local TargetAvatar = Instance.new("ImageLabel")
TargetAvatar.Size = UDim2.new(0, 50, 0, 50)
TargetAvatar.Position = UDim2.new(0, 0, 0, 25)
TargetAvatar.BackgroundColor3 = colors.ElementBg
TargetAvatar.Image = ""
TargetAvatar.Parent = RightPanel
Instance.new("UICorner", TargetAvatar).CornerRadius = UDim.new(1, 0)

local TargetDisplay = Instance.new("TextLabel")
TargetDisplay.Size = UDim2.new(1, -60, 0, 25)
TargetDisplay.Position = UDim2.new(0, 60, 0, 25)
TargetDisplay.BackgroundTransparency = 1
TargetDisplay.Text = "None"
TargetDisplay.TextColor3 = colors.Accent
TargetDisplay.Font = Enum.Font.GothamBold
TargetDisplay.TextSize = 18
TargetDisplay.TextXAlignment = Enum.TextXAlignment.Left
TargetDisplay.Parent = RightPanel

local TargetUser = Instance.new("TextLabel")
TargetUser.Size = UDim2.new(1, -60, 0, 20)
TargetUser.Position = UDim2.new(0, 60, 0, 50)
TargetUser.BackgroundTransparency = 1
TargetUser.Text = "@none"
TargetUser.TextColor3 = colors.TextDim
TargetUser.Font = Enum.Font.Gotham
TargetUser.TextSize = 13
TargetUser.TextXAlignment = Enum.TextXAlignment.Left
TargetUser.Parent = RightPanel

local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, 0, 0, 30)
StatusFrame.Position = UDim2.new(0, 0, 0, 85)
StatusFrame.BackgroundColor3 = colors.PanelBg
StatusFrame.Parent = RightPanel
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: NOT FOLLOWING"
StatusLabel.TextColor3 = colors.Red
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.Parent = StatusFrame

-- Nút Start/Stop
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(1, 0, 0, 35)
StartBtn.Position = UDim2.new(0, 0, 0, 125)
StartBtn.BackgroundColor3 = colors.Accent
StartBtn.Text = "▶ Start Follow"
StartBtn.TextColor3 = colors.Text
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = RightPanel
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, 0, 0, 35)
StopBtn.Position = UDim2.new(0, 0, 0, 165)
StopBtn.BackgroundColor3 = colors.ElementBg
StopBtn.Text = "■ Stop Follow"
StopBtn.TextColor3 = colors.Text
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.Parent = RightPanel
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

-- Slider
local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, 0, 0, 20)
SpeedTitle.Position = UDim2.new(0, 0, 0, 210)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "FOLLOW SPEED: 25"
SpeedTitle.TextColor3 = colors.Text
SpeedTitle.Font = Enum.Font.GothamMedium
SpeedTitle.TextSize = 12
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = RightPanel

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, 0, 0, 6)
SliderBg.Position = UDim2.new(0, 0, 0, 235)
SliderBg.BackgroundColor3 = colors.PanelBg
SliderBg.Parent = RightPanel
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.21, 0, 1, 0)
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
MinText.Position = UDim2.new(0, 0, 0, 245)
MinText.BackgroundTransparency = 1; MinText.Text = "5"
MinText.TextColor3 = colors.TextDim; MinText.Font = Enum.Font.Gotham; MinText.TextSize = 12
MinText.TextXAlignment = Enum.TextXAlignment.Left; MinText.Parent = RightPanel

local MaxText = Instance.new("TextLabel")
MaxText.Size = UDim2.new(0, 30, 0, 20)
MaxText.Position = UDim2.new(1, -30, 0, 245)
MaxText.BackgroundTransparency = 1; MaxText.Text = "100"
MaxText.TextColor3 = colors.TextDim; MaxText.Font = Enum.Font.Gotham; MaxText.TextSize = 12
MaxText.TextXAlignment = Enum.TextXAlignment.Right; MaxText.Parent = RightPanel

-- Hàm tạo Toggle Switch mượt mà
local function createToggle(title, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = RightPanel
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = colors.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(1, -44, 0.5, -12)
    toggleBg.BackgroundColor3 = colors.PanelBg
    toggleBg.Text = ""
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = colors.TextDim
    circle.Parent = toggleBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local isOn = false
    local function setToggle(state)
        isOn = state
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = isOn and colors.Text or colors.TextDim
        }):Play()
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and colors.Accent or colors.PanelBg
        }):Play()
    end
    
    return toggleBg, function() return isOn end, setToggle
end

local FlyToggleBtn, getFlyState, setFlyState = createToggle("✈ Fly (Bay)", 270)
local NoclipToggleBtn, getNoclipState, setNoclipState = createToggle("🏃 Noclip (Xuyên tường)", 305)

local InfoBox = Instance.new("TextLabel")
InfoBox.Size = UDim2.new(1, 0, 0, 40)
InfoBox.Position = UDim2.new(0, 0, 0, 345)
InfoBox.BackgroundColor3 = colors.PanelBg
InfoBox.Text = "ℹ Khi Follow: Script sẽ tự động dùng Fly/Noclip để đi đến và bám theo mục tiêu bằng mọi giá."
InfoBox.TextColor3 = colors.TextDim
InfoBox.Font = Enum.Font.Gotham
InfoBox.TextSize = 11
InfoBox.TextWrapped = true
InfoBox.Parent = RightPanel
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 6)

-- [ NOTIFICATION SYSTEM ]
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 260, 1, -20)
NotifContainer.Position = UDim2.new(1, -280, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotifContainer

local function Notify(title, desc, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundColor3 = colors.Bg
    frame.BackgroundTransparency = 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(40, 40, 45)
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 4, 1, 0)
    line.BackgroundColor3 = color
    line.Parent = frame
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 6)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 15, 0, 17)
    icon.BackgroundColor3 = colors.ElementBg
    icon.Text = "IY"
    icon.TextColor3 = colors.Text
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 14
    icon.Parent = frame
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -85, 0, 20)
    tLabel.Position = UDim2.new(0, 55, 0, 10)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = color
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 14
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = frame
    
    local dLabel = Instance.new("TextLabel")
    dLabel.Size = UDim2.new(1, -65, 0, 20)
    dLabel.Position = UDim2.new(0, 55, 0, 30)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = desc
    dLabel.TextColor3 = colors.TextDim
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 12
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.TextTruncate = Enum.TextTruncate.AtEnd
    dLabel.Parent = frame

    local xBtn = Instance.new("TextButton")
    xBtn.Size = UDim2.new(0, 20, 0, 20)
    xBtn.Position = UDim2.new(1, -25, 0, 10)
    xBtn.BackgroundTransparency = 1
    xBtn.Text = "X"
    xBtn.TextColor3 = colors.TextDim
    xBtn.Font = Enum.Font.Gotham
    xBtn.TextSize = 14
    xBtn.Parent = frame
    
    frame.Parent = NotifContainer
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    
    local closed = false
    local function closeNotif()
        if closed then return end
        closed = true
        local fade = TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        TweenService:Create(tLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(dLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(icon, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(xBtn, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        fade:Play()
        fade.Completed:Wait()
        frame:Destroy()
    end

    xBtn.MouseButton1Click:Connect(closeNotif)
    task.spawn(function() task.wait(4); closeNotif() end)
end

-- ==========================================
-- 4. CHỨC NĂNG LOGIC
-- ==========================================

-- Cập nhật danh sách người chơi
local playerButtons = {}

local function updatePlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    table.clear(playerButtons)
    
    local players = Players:GetPlayers()
    ServerInfo.Text = "Online: " .. #players .. " | Max: " .. Players.MaxPlayers
    
    for _, player in ipairs(players) do
        if player == LocalPlayer then continue end
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = colors.ElementBg
        btn.Text = ""
        btn.Parent = ScrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        -- Get Avatar
        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.new(0, 35, 0, 35)
        avatarImg.Position = UDim2.new(0, 5, 0, 5)
        avatarImg.BackgroundColor3 = colors.Bg
        avatarImg.Parent = btn
        Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)
        
        task.spawn(function()
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size150x150
            local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
            if isReady then avatarImg.Image = content end
        end)
        
        local dName = Instance.new("TextLabel")
        dName.Size = UDim2.new(1, -50, 0, 20)
        dName.Position = UDim2.new(0, 50, 0, 5)
        dName.BackgroundTransparency = 1
        dName.Text = player.DisplayName
        dName.TextColor3 = colors.Text
        dName.Font = Enum.Font.GothamBold
        dName.TextSize = 13
        dName.TextXAlignment = Enum.TextXAlignment.Left
        dName.Parent = btn
        
        local uName = Instance.new("TextLabel")
        uName.Size = UDim2.new(1, -50, 0, 15)
        uName.Position = UDim2.new(0, 50, 0, 25)
        uName.BackgroundTransparency = 1
        uName.Text = "@" .. player.Name
        uName.TextColor3 = colors.TextDim
        uName.Font = Enum.Font.Gotham
        uName.TextSize = 11
        uName.TextXAlignment = Enum.TextXAlignment.Left
        uName.Parent = btn

        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(playerButtons) do
                b.BackgroundColor3 = colors.ElementBg
                b:FindFirstChild("UIStroke"):Destroy()
            end
            
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = colors.Accent
            stroke.Thickness = 1
            
            targetPlayer = player
            TargetDisplay.Text = player.DisplayName
            TargetUser.Text = "@" .. player.Name
            TargetAvatar.Image = avatarImg.Image
            TargetDisplay.TextColor3 = colors.Accent
        end)
        
        table.insert(playerButtons, btn)
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
    if targetPlayer == player then
        targetPlayer = nil
        TargetDisplay.Text = "None"
        TargetUser.Text = "@none"
        TargetAvatar.Image = ""
        if isFollowing then
            StopBtn:Fire()
            Notify("Target Left Server", "Mục tiêu đã rời server.", colors.Red)
        end
    end
    updatePlayerList()
    Notify("Player Left", player.DisplayName .. " đã rời khỏi server.", Color3.fromRGB(59, 130, 246))
end)
updatePlayerList()

-- [ HỆ THỐNG NOCLIP & FLY ]
local function updateNoclip()
    if isNoclipEnabled then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local function cleanFlyMovers()
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

-- [ LOGIC THEO DÕI (HEARTBEAT) ]
local function stopFollowing()
    isFollowing = false
    StatusLabel.Text = "STATUS: NOT FOLLOWING"
    StatusLabel.TextColor3 = colors.Red
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    cleanFlyMovers()
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 
        LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
    end
end

StartBtn.MouseButton1Click:Connect(function()
    if not targetPlayer then
        Notify("Please select a player.", "Vui lòng chọn người chơi.", colors.Accent)
        return
    end
    if isFollowing then return end
    
    isFollowing = true
    StatusLabel.Text = "STATUS: FOLLOWING"
    StatusLabel.TextColor3 = colors.Green
    Notify("Follow Started", "Đang theo dõi " .. targetPlayer.DisplayName .. "!", colors.Green)
    
    followConnection = RunService.Heartbeat:Connect(function()
        if not isFollowing then return end
        
        -- Xác minh đối tượng
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            stopFollowing()
            Notify("Target Reset", "Mục tiêu đã reset hoặc biến mất.", colors.Red)
            return
        end
        
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChild("Humanoid") then return end
        
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        local myHRP = myChar.HumanoidRootPart
        local distance = (targetHRP.Position - myHRP.Position).Magnitude
        
        -- Xử lý Fly (Bay)
        if isFlyEnabled then
            if not bodyVel or not bodyVel.Parent then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.Parent = myHRP
                
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro.D = 500
                bodyGyro.Parent = myHRP
                
                myChar.Humanoid.PlatformStand = true
            end
            
            if distance > 3 then
                local direction = (targetHRP.Position - myHRP.Position).Unit
                bodyVel.Velocity = direction * followSpeed
                bodyGyro.CFrame = CFrame.new(myHRP.Position, targetHRP.Position)
            else
                bodyVel.Velocity = Vector3.zero
            end
        else
            -- Đi bộ bình thường
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
    if isFollowing then
        stopFollowing()
        Notify("Follow Stopped", "Đã dừng theo dõi.", colors.Red)
    end
end)

-- [ CÁC SỰ KIỆN TƯƠNG TÁC KHÁC ]
FlyToggleBtn.MouseButton1Click:Connect(function()
    isFlyEnabled = not isFlyEnabled
    setFlyState(isFlyEnabled)
    if not isFlyEnabled then cleanFlyMovers() end
end)

NoclipToggleBtn.MouseButton1Click:Connect(function()
    isNoclipEnabled = not isNoclipEnabled
    setNoclipState(isNoclipEnabled)
    updateNoclip()
end)

-- Xử lý thanh trượt tốc độ
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
        SpeedTitle.Text = "FOLLOW SPEED: " .. followSpeed
    end
end)

-- Ẩn / Hiện Menu
local menuOpen = true
ToggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen; MainFrame.Visible = menuOpen
end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; menuOpen = false end)
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; menuOpen = false end)

-- Xử lý khi LocalPlayer respawn
LocalPlayer.CharacterAdded:Connect(function()
    if isFollowing then
        stopFollowing()
        Notify("Reconnected", "Bạn vừa hồi sinh, đã tạm dừng script.", Color3.fromRGB(59, 130, 246))
    end
    updateNoclip()
end)

Notify("Reconnected", "Đã tải lại danh sách người chơi và GUI thành công.", colors.Green)
