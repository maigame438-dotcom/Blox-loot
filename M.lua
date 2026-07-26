-- Bỏ qua nếu đã load
if game.CoreGui:FindFirstChild("AutoPatrolMobileGUI") then
    game.CoreGui.AutoPatrolMobileGUI:Destroy()
end

-- Dịch vụ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Biến cấu hình trạng thái
local PointA = nil
local PointB = nil
local DelayTime = 3.0
local Mode = "LOOP" -- "LOOP" hoặc "ONE_WAY"
local IsRunning = false
local CurrentTarget = "A"
local PatrolThread = nil
local MoveConnection = nil

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoPatrolMobileGUI"
ScreenGui.ResetOnSpawn = false -- Giữ UI khi reset
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Bảng màu & Giao diện
local Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(138, 43, 226), -- Tím
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    BtnA = Color3.fromRGB(20, 100, 200),
    BtnB = Color3.fromRGB(200, 100, 20),
    Start = Color3.fromRGB(40, 150, 40),
    Stop = Color3.fromRGB(200, 40, 40),
    Success = Color3.fromRGB(40, 200, 40)
}

-- Hàm tạo UI bo góc nhanh
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

-- ================= CẤU TRÚC MENU CHÍNH =================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 12)

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Colors.Accent
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Tiêu đề & Nút X (Đóng/Thu gọn)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 40, 1, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🚶"
TitleIcon.TextSize = 18
TitleIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AUTO PATROL"
Title.TextColor3 = Colors.Text
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.SubText
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Khu vực Set Point
local PointContainer = Instance.new("Frame")
PointContainer.Size = UDim2.new(1, -30, 0, 90)
PointContainer.Position = UDim2.new(0, 15, 0, 50)
PointContainer.BackgroundTransparency = 1
PointContainer.Parent = MainFrame

local function createPointButton(name, pos, color, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = "   " .. icon .. "  " .. name
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = PointContainer
    addCorner(btn, 8)
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 60, 0, 40)
    status.Position = UDim2.new(1, -65, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "Chưa đặt ⚪"
    status.TextColor3 = Colors.SubText
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = btn
    
    return btn, status
end

local BtnSetA, StatusA = createPointButton("SET POINT A", UDim2.new(0, 0, 0, 0), Colors.BtnA, "📍")
local BtnSetB, StatusB = createPointButton("SET POINT B", UDim2.new(0, 0, 0, 50), Colors.BtnB, "📍")

-- Delay Slider
local DelayFrame = Instance.new("Frame")
DelayFrame.Size = UDim2.new(1, -30, 0, 70)
DelayFrame.Position = UDim2.new(0, 15, 0, 155)
DelayFrame.BackgroundTransparency = 1
DelayFrame.Parent = MainFrame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, 0, 0, 20)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "DELAY (THỜI GIAN ĐỨNG TẠI MỖI ĐIỂM)"
DelayLabel.TextColor3 = Colors.Text
DelayLabel.Font = Enum.Font.GothamBold
DelayLabel.TextSize = 11
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = DelayFrame

local DelayInputBg = Instance.new("Frame")
DelayInputBg.Size = UDim2.new(1, 0, 0, 30)
DelayInputBg.Position = UDim2.new(0, 0, 0, 25)
DelayInputBg.BackgroundColor3 = Colors.Panel
DelayInputBg.Parent = DelayFrame
addCorner(DelayInputBg, 6)

local DelayValueLabel = Instance.new("TextBox")
DelayValueLabel.Size = UDim2.new(0.5, -10, 1, 0)
DelayValueLabel.Position = UDim2.new(0, 10, 0, 0)
DelayValueLabel.BackgroundTransparency = 1
DelayValueLabel.Text = "3.0"
DelayValueLabel.TextColor3 = Colors.Text
DelayValueLabel.Font = Enum.Font.GothamBold
DelayValueLabel.TextSize = 14
DelayValueLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayValueLabel.ClearTextOnFocus = false
DelayValueLabel.Parent = DelayInputBg

local DelayUnit = Instance.new("TextLabel")
DelayUnit.Size = UDim2.new(0.5, -10, 1, 0)
DelayUnit.Position = UDim2.new(0.5, 0, 0, 0)
DelayUnit.BackgroundTransparency = 1
DelayUnit.Text = "giây"
DelayUnit.TextColor3 = Colors.SubText
DelayUnit.Font = Enum.Font.Gotham
DelayUnit.TextSize = 12
DelayUnit.TextXAlignment = Enum.TextXAlignment.Right
DelayUnit.Parent = DelayInputBg

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(1, -40, 0, 4)
SliderBar.Position = UDim2.new(0, 20, 0, 65)
SliderBar.BackgroundColor3 = Colors.Panel
SliderBar.Parent = DelayFrame
addCorner(SliderBar, 2)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(3/60, 0, 1, 0)
SliderFill.BackgroundColor3 = Colors.Accent
SliderFill.Parent = SliderBar
addCorner(SliderFill, 2)

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 14, 0, 14)
SliderKnob.Position = UDim2.new(3/60, -7, 0.5, -7)
SliderKnob.BackgroundColor3 = Colors.Accent
SliderKnob.Text = ""
SliderKnob.Parent = SliderBar
addCorner(SliderKnob, 7)

-- Mode Selector
local ModeFrame = Instance.new("Frame")
ModeFrame.Size = UDim2.new(1, -30, 0, 60)
ModeFrame.Position = UDim2.new(0, 15, 0, 240)
ModeFrame.BackgroundTransparency = 1
ModeFrame.Parent = MainFrame

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, 0, 0, 20)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "MODE (CHẾ ĐỘ DI CHUYỂN)"
ModeLabel.TextColor3 = Colors.Text
ModeLabel.Font = Enum.Font.GothamBold
ModeLabel.TextSize = 11
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = ModeFrame

local BtnLoop = Instance.new("TextButton")
BtnLoop.Size = UDim2.new(0.5, -5, 0, 35)
BtnLoop.Position = UDim2.new(0, 0, 0, 25)
BtnLoop.BackgroundColor3 = Colors.Background
BtnLoop.Text = "🔁 LOOP"
BtnLoop.TextColor3 = Colors.Accent
BtnLoop.Font = Enum.Font.GothamBold
BtnLoop.TextSize = 12
BtnLoop.Parent = ModeFrame
addCorner(BtnLoop, 6)
local LoopStroke = Instance.new("UIStroke")
LoopStroke.Color = Colors.Accent
LoopStroke.ApplyTo = Enum.ApplyStrokeMode.Border
LoopStroke.Parent = BtnLoop

local BtnOneWay = Instance.new("TextButton")
BtnOneWay.Size = UDim2.new(0.5, -5, 0, 35)
BtnOneWay.Position = UDim2.new(0.5, 5, 0, 25)
BtnOneWay.BackgroundColor3 = Colors.Panel
BtnOneWay.Text = "➔ ONE WAY"
BtnOneWay.TextColor3 = Colors.SubText
BtnOneWay.Font = Enum.Font.GothamBold
BtnOneWay.TextSize = 12
BtnOneWay.Parent = ModeFrame
addCorner(BtnOneWay, 6)

-- Nút Start & Stop
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(1, -30, 0, 100)
ControlFrame.Position = UDim2.new(0, 15, 0, 320)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = MainFrame

local BtnStart = Instance.new("TextButton")
BtnStart.Size = UDim2.new(1, 0, 0, 40)
BtnStart.BackgroundColor3 = Colors.Start
BtnStart.Text = "▶ START"
BtnStart.TextColor3 = Colors.Text
BtnStart.Font = Enum.Font.GothamBold
BtnStart.TextSize = 16
BtnStart.Parent = ControlFrame
addCorner(BtnStart, 8)

local BtnStop = Instance.new("TextButton")
BtnStop.Size = UDim2.new(1, 0, 0, 40)
BtnStop.Position = UDim2.new(0, 0, 0, 50)
BtnStop.BackgroundColor3 = Colors.Stop
BtnStop.Text = "⏹ STOP"
BtnStop.TextColor3 = Colors.Text
BtnStop.Font = Enum.Font.GothamBold
BtnStop.TextSize = 16
BtnStop.Parent = ControlFrame
addCorner(BtnStop, 8)

-- Nút Nổi (Floating Button)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(1, -70, 0.5, -25)
FloatBtn.BackgroundColor3 = Colors.Background
FloatBtn.Text = "..."
FloatBtn.TextColor3 = Colors.Text
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 24
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui
addCorner(FloatBtn, 25)
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Colors.Accent
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

-- ================= LOGIC KÉO THẢ (TỐI ƯU CẢM ỨNG & CHUỘT) =================
local function makeDraggable(guiObject, handle)
    handle = handle or guiObject
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(MainFrame, TopBar)
makeDraggable(FloatBtn, FloatBtn)

-- Mở/Đóng Menu
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)
FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false
    MainFrame.Visible = true
end)

-- ================= LOGIC SLIDER =================
local isDraggingSlider = false

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = input.Position.X
        local barX = SliderBar.AbsolutePosition.X
        local barSize = SliderBar.AbsoluteSize.X
        
        local percent = math.clamp((mouseX - barX) / barSize, 0, 1)
        SliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        
        DelayTime = percent * 60
        DelayValueLabel.Text = string.format("%.1f", DelayTime)
    end
end)

DelayValueLabel.FocusLost:Connect(function()
    local num = tonumber(DelayValueLabel.Text)
    if num then
        DelayTime = math.clamp(num, 0, 60)
        DelayValueLabel.Text = string.format("%.1f", DelayTime)
        local percent = DelayTime / 60
        SliderKnob.Position = UDim2.new(percent, -7, 0.5, -7)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    else
        DelayValueLabel.Text = string.format("%.1f", DelayTime)
    end
end)

-- ================= LOGIC TƯƠNG TÁC NÚT =================
BtnSetA.MouseButton1Click:Connect(function()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        PointA = Character.HumanoidRootPart.Position
        StatusA.Text = "Đã đặt 🟢"
        StatusA.TextColor3 = Colors.Success
    end
end)

BtnSetB.MouseButton1Click:Connect(function()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        PointB = Character.HumanoidRootPart.Position
        StatusB.Text = "Đã đặt 🟢"
        StatusB.TextColor3 = Colors.Success
    end
end)

BtnLoop.MouseButton1Click:Connect(function()
    Mode = "LOOP"
    BtnLoop.BackgroundColor3 = Colors.Background
    BtnLoop.TextColor3 = Colors.Accent
    LoopStroke.Parent = BtnLoop
    BtnOneWay.BackgroundColor3 = Colors.Panel
    BtnOneWay.TextColor3 = Colors.SubText
end)

BtnOneWay.MouseButton1Click:Connect(function()
    Mode = "ONE_WAY"
    BtnOneWay.BackgroundColor3 = Colors.Background
    BtnOneWay.TextColor3 = Colors.Accent
    LoopStroke.Parent = BtnOneWay
    BtnLoop.BackgroundColor3 = Colors.Panel
    BtnLoop.TextColor3 = Colors.SubText
end)

-- ================= LOGIC TÌM ĐƯỜNG & DI CHUYỂN =================
local function StopPatrol()
    IsRunning = false
    if PatrolThread then
        task.cancel(PatrolThread)
        PatrolThread = nil
    end
    if MoveConnection then
        MoveConnection:Disconnect()
        MoveConnection = nil
    end
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkToPoint = Character.HumanoidRootPart.Position
    end
end

local function PathlineTo(targetPos)
    local humanoid = Character:FindFirstChild("Humanoid")
    local rootPart = Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 4
    })

    local success, errorMessage = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPos)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for i, waypoint in ipairs(waypoints) do
            if not IsRunning then return false end
            
            -- Xử lý nhảy nếu gặp vật cản/bậc thang
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            -- Chờ đến khi đạt waypoint (với timeout để chống kẹt cứng)
            local timeOut = tick()
            local reached = false
            
            MoveConnection = humanoid.MoveToFinished:Connect(function(r)
                reached = true
                MoveConnection:Disconnect()
            end)
            
            while not reached and IsRunning do
                if tick() - timeOut > 3 then -- Kẹt quá 3 giây
                    if MoveConnection then MoveConnection:Disconnect() end
                    humanoid.Jump = true
                    break -- Thoát vòng lặp waypoint hiện tại để tính lại
                end
                task.wait(0.1)
            end
        end
        return true
    else
        -- Di chuyển thẳng dự phòng nếu không tạo được đường
        humanoid:MoveTo(targetPos)
        humanoid.MoveToFinished:Wait()
        return true
    end
end

local function StartPatrolLoop()
    if not PointA or not PointB then return end
    
    PatrolThread = task.spawn(function()
        while IsRunning do
            local targetPos = (CurrentTarget == "A") and PointA or PointB
            
            -- Tìm đường và đi đến điểm
            PathlineTo(targetPos)
            
            -- Đứng chờ Delay
            if IsRunning then
                task.wait(DelayTime)
            end
            
            if not IsRunning then break end
            
            -- Đổi mục tiêu
            if CurrentTarget == "A" then
                CurrentTarget = "B"
            else
                if Mode == "ONE_WAY" then
                    StopPatrol()
                    break
                else
                    CurrentTarget = "A"
                end
            end
        end
    end)
end

BtnStart.MouseButton1Click:Connect(function()
    if IsRunning then return end
    if not PointA or not PointB then
        -- Cảnh báo nếu chưa đặt điểm (hiệu ứng nhấp nháy đỏ nhẹ)
        BtnStart.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        BtnStart.Text = "CHƯA ĐẶT ĐIỂM!"
        task.wait(1)
        BtnStart.BackgroundColor3 = Colors.Start
        BtnStart.Text = "▶ START"
        return
    end
    IsRunning = true
    CurrentTarget = "A" -- Bắt đầu đi từ vị trí hiện tại tới A
    StartPatrolLoop()
end)

BtnStop.MouseButton1Click:Connect(function()
    StopPatrol()
end)

-- ================= QUẢN LÝ NHÂN VẬT CHẾT/RESET =================
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Character:WaitForChild("HumanoidRootPart")
    Character:WaitForChild("Humanoid")
    
    -- Tự động tiếp tục chạy nếu trước đó đang bật Start
    if IsRunning then
        -- Chờ nhân vật load hẳn rồi mới resume
        task.wait(1)
        StartPatrolLoop()
    end
end)
