-- Xóa GUI cũ nếu đã tồn tại để tránh trùng lặp
if game.CoreGui:FindFirstChild("AutoPatrolV2_GUI") then
    game.CoreGui.AutoPatrolV2_GUI:Destroy()
end

-- ================= CÁC DỊCH VỤ =================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ================= BIẾN TRẠNG THÁI =================
local PointA = nil
local PointB = nil
local DelayTime = 3.0
local Mode = "LOOP" -- "LOOP" hoặc "ONE_WAY"
local IsRunning = false
local CurrentTarget = "A"
local PatrolThread = nil
local MoveConnection = nil

-- ================= THIẾT LẬP GIAO DIỆN (UI) =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoPatrolV2_GUI"
ScreenGui.ResetOnSpawn = false -- Quan trọng: Giữ UI khi chết/reset
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Colors = {
    Background = Color3.fromRGB(18, 18, 24),
    Surface = Color3.fromRGB(28, 28, 36),
    Primary = Color3.fromRGB(147, 51, 234), -- Tím
    PointA = Color3.fromRGB(29, 78, 216),   -- Xanh dương
    PointB = Color3.fromRGB(234, 88, 12),   -- Cam
    StartBtn = Color3.fromRGB(34, 197, 94), -- Xanh lá
    StopBtn = Color3.fromRGB(220, 38, 38),  -- Đỏ
    Text = Color3.fromRGB(255, 255, 255),
    DimText = Color3.fromRGB(156, 163, 175)
}

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

-- Khung chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 480)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -240)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.Active = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Primary
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Thanh tiêu đề
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 40, 1, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🚶"
TitleIcon.TextSize = 20
TitleIcon.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AUTO PATROL"
TitleLabel.TextColor3 = Colors.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar

-- Khu vực tạo nút Point
local function createPointButton(yPos, color, text, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 45)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = "   " .. icon .. "   " .. text
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = MainFrame
    addCorner(btn, 8)
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 70, 1, 0)
    status.Position = UDim2.new(1, -80, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "Chưa đặt 🔴"
    status.TextColor3 = Colors.DimText
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = btn
    
    return btn, status
end

local BtnSetA, StatusA = createPointButton(60, Colors.PointA, "SET POINT A", "📍")
local BtnSetB, StatusB = createPointButton(115, Colors.PointB, "SET POINT B", "📍")

-- Khu vực Slider Delay
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, -30, 0, 20)
DelayLabel.Position = UDim2.new(0, 15, 0, 175)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "DELAY (THỜI GIAN ĐỨNG TẠI MỖI ĐIỂM)"
DelayLabel.TextColor3 = Colors.Text
DelayLabel.Font = Enum.Font.GothamBold
DelayLabel.TextSize = 11
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = MainFrame

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(1, -30, 0, 35)
DelayBox.Position = UDim2.new(0, 15, 0, 200)
DelayBox.BackgroundColor3 = Colors.Surface
DelayBox.Text = "3.0"
DelayBox.TextColor3 = Colors.Text
DelayBox.Font = Enum.Font.GothamBold
DelayBox.TextSize = 14
DelayBox.TextXAlignment = Enum.TextXAlignment.Left
DelayBox.Parent = MainFrame
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.Parent = DelayBox
addCorner(DelayBox, 6)

local UnitLabel = Instance.new("TextLabel")
UnitLabel.Size = UDim2.new(0, 40, 1, 0)
UnitLabel.Position = UDim2.new(1, -50, 0, 0)
UnitLabel.BackgroundTransparency = 1
UnitLabel.Text = "giây"
UnitLabel.TextColor3 = Colors.DimText
UnitLabel.Font = Enum.Font.Gotham
UnitLabel.TextSize = 12
UnitLabel.Parent = DelayBox

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, -30, 0, 4)
SliderBg.Position = UDim2.new(0, 15, 0, 255)
SliderBg.BackgroundColor3 = Colors.Surface
SliderBg.Parent = MainFrame
addCorner(SliderBg, 2)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(3/60, 0, 1, 0)
SliderFill.BackgroundColor3 = Colors.Primary
SliderFill.Parent = SliderBg
addCorner(SliderFill, 2)

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new(3/60, -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Colors.Primary
SliderKnob.Text = ""
SliderKnob.Parent = SliderBg
addCorner(SliderKnob, 8)

-- Khu vực Chọn Chế Độ (Mode)
local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, -30, 0, 20)
ModeLabel.Position = UDim2.new(0, 15, 0, 280)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "MODE (CHẾ ĐỘ DI CHUYỂN)"
ModeLabel.TextColor3 = Colors.Text
ModeLabel.Font = Enum.Font.GothamBold
ModeLabel.TextSize = 11
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = MainFrame

local BtnLoop = Instance.new("TextButton")
BtnLoop.Size = UDim2.new(0.5, -20, 0, 35)
BtnLoop.Position = UDim2.new(0, 15, 0, 305)
BtnLoop.BackgroundColor3 = Colors.Background
BtnLoop.Text = "🔁 LOOP (LẶP LẠI)"
BtnLoop.TextColor3 = Colors.Primary
BtnLoop.Font = Enum.Font.GothamBold
BtnLoop.TextSize = 11
BtnLoop.Parent = MainFrame
addCorner(BtnLoop, 6)
local LoopStroke = Instance.new("UIStroke")
LoopStroke.Color = Colors.Primary
LoopStroke.ApplyTo = Enum.ApplyStrokeMode.Border
LoopStroke.Parent = BtnLoop

local BtnOneWay = Instance.new("TextButton")
BtnOneWay.Size = UDim2.new(0.5, -20, 0, 35)
BtnOneWay.Position = UDim2.new(0.5, 5, 0, 305)
BtnOneWay.BackgroundColor3 = Colors.Surface
BtnOneWay.Text = "➔ ONE WAY (1 LẦN)"
BtnOneWay.TextColor3 = Colors.DimText
BtnOneWay.Font = Enum.Font.GothamBold
BtnOneWay.TextSize = 11
BtnOneWay.Parent = MainFrame
addCorner(BtnOneWay, 6)

-- Nút Bắt Đầu / Dừng (Start/Stop)
local BtnStart = Instance.new("TextButton")
BtnStart.Size = UDim2.new(1, -30, 0, 45)
BtnStart.Position = UDim2.new(0, 15, 0, 360)
BtnStart.BackgroundColor3 = Colors.StartBtn
BtnStart.Text = "▶ START"
BtnStart.TextColor3 = Colors.Text
BtnStart.Font = Enum.Font.GothamBold
BtnStart.TextSize = 16
BtnStart.Parent = MainFrame
addCorner(BtnStart, 8)

local BtnStop = Instance.new("TextButton")
BtnStop.Size = UDim2.new(1, -30, 0, 45)
BtnStop.Position = UDim2.new(0, 15, 0, 415)
BtnStop.BackgroundColor3 = Colors.StopBtn
BtnStop.Text = "⏹ STOP"
BtnStop.TextColor3 = Colors.Text
BtnStop.Font = Enum.Font.GothamBold
BtnStop.TextSize = 16
BtnStop.Parent = MainFrame
addCorner(BtnStop, 8)

-- Nút Nổi Mở Menu
local FloatBtn = Instance.new("TextButton")
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
FloatStroke.Color = Colors.Primary
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

-- ================= LOGIC KÉO THẢ UI =================
local function enableDragging(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
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
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

enableDragging(MainFrame, TopBar)
enableDragging(FloatBtn, FloatBtn)

-- ================= LOGIC ẨN/HIỆN MENU =================
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false
    MainFrame.Visible = true
end)

-- ================= LOGIC TƯƠNG TÁC UI =================
BtnSetA.MouseButton1Click:Connect(function()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        PointA = Character.HumanoidRootPart.Position
        StatusA.Text = "Đã đặt 🟢"
        StatusA.TextColor3 = Colors.StartBtn
    end
end)

BtnSetB.MouseButton1Click:Connect(function()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        PointB = Character.HumanoidRootPart.Position
        StatusB.Text = "Đã đặt 🟢"
        StatusB.TextColor3 = Colors.StartBtn
    end
end)

BtnLoop.MouseButton1Click:Connect(function()
    Mode = "LOOP"
    BtnLoop.BackgroundColor3 = Colors.Background
    BtnLoop.TextColor3 = Colors.Primary
    LoopStroke.Parent = BtnLoop
    BtnOneWay.BackgroundColor3 = Colors.Surface
    BtnOneWay.TextColor3 = Colors.DimText
end)

BtnOneWay.MouseButton1Click:Connect(function()
    Mode = "ONE_WAY"
    BtnOneWay.BackgroundColor3 = Colors.Background
    BtnOneWay.TextColor3 = Colors.Primary
    LoopStroke.Parent = BtnOneWay
    BtnLoop.BackgroundColor3 = Colors.Surface
    BtnLoop.TextColor3 = Colors.DimText
end)

-- Logic Kéo Slider Delay
local isSliding = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = input.Position.X - SliderBg.AbsolutePosition.X
        local percent = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0, 1)
        
        SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        
        DelayTime = percent * 60
        DelayBox.Text = string.format("%.1f", DelayTime)
    end
end)

DelayBox.FocusLost:Connect(function()
    local val = tonumber(DelayBox.Text)
    if val then
        DelayTime = math.clamp(val, 0, 60)
        local percent = DelayTime / 60
        SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    end
    DelayBox.Text = string.format("%.1f", DelayTime)
end)

-- ================= LOGIC DI CHUYỂN (PATHFINDING) =================
local function StopMovement()
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

local function WalkTo(targetPosition)
    local humanoid = Character:FindFirstChild("Humanoid")
    local rootPart = Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end

    -- Tạo đường đi
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 4
    })
    
    local success, _ = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not IsRunning then return false end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            
            humanoid:MoveTo(waypoint.Position)
            
            -- Đợi đến khi tới waypoint hoặc timeout nếu bị kẹt
            local reached = false
            local timeout = tick()
            
            MoveConnection = humanoid.MoveToFinished:Connect(function()
                reached = true
                MoveConnection:Disconnect()
            end)
            
            while not reached and IsRunning do
                if tick() - timeout > 4 then -- Kẹt quá 4 giây -> Nhảy và tính lại
                    if MoveConnection then MoveConnection:Disconnect() end
                    humanoid.Jump = true
                    return false
                end
                task.wait(0.1)
            end
        end
        return true
    else
        -- Fallback: Đi thẳng nếu không tìm được đường
        humanoid:MoveTo(targetPosition)
        humanoid.MoveToFinished:Wait()
        return true
    end
end

local function StartPatrol()
    if not PointA or not PointB then return end
    
    PatrolThread = task.spawn(function()
        while IsRunning do
            local targetPos = (CurrentTarget == "A") and PointA or PointB
            
            -- Di chuyển
            WalkTo(targetPos)
            
            -- Chờ Delay
            if IsRunning then
                task.wait(DelayTime)
            end
            
            if not IsRunning then break end
            
            -- Chuyển mục tiêu
            if CurrentTarget == "A" then
                CurrentTarget = "B"
            else
                if Mode == "ONE_WAY" then
                    StopMovement()
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
        BtnStart.Text = "CHƯA ĐẶT ĐIỂM!"
        task.wait(1)
        BtnStart.Text = "▶ START"
        return
    end
    IsRunning = true
    CurrentTarget = "A"
    StartPatrol()
end)

BtnStop.MouseButton1Click:Connect(function()
    StopMovement()
end)

-- ================= KHÔI PHỤC KHI CHẾT/RESET =================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Character:WaitForChild("HumanoidRootPart")
    Character:WaitForChild("Humanoid")
    
    if IsRunning then
        task.wait(1.5) -- Đợi nhân vật hoàn toàn load xong
        StartPatrol()
    end
end)
