-- ==================================================
-- TÊN: MINI ADMIN FE - 10% SCREEN & SWIPEABLE
-- PHONG CÁCH: Infinite Yield
-- ==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu đã tồn tại
local guiName = "MiniAdmin10Percent"
local targetGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if targetGui:FindFirstChild(guiName) then
    targetGui[guiName]:Destroy()
end

-- ==================================================
-- 1. TẠO GIAO DIỆN (GUI)
-- ==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetGui

-- Nút Bật/Tắt (Toggle Button)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 100)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "cmd"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 14
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

-- Khung chính (Chiếm khoảng 10% màn hình: 40% rộng x 25% cao = 10% diện tích)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.4, 0, 0.25, 0) 
MainFrame.Position = UDim2.new(0.3, 0, 0.375, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Thanh Tiêu đề (Dùng để Kéo thả - Tránh xung đột với Vuốt)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0.25, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Mini Admin (Kéo ở đây)"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.Code
Title.TextSize = 12
Title.Parent = TopBar

-- Khung Vuốt (Scrolling Frame - Hỗ trợ vuốt trên điện thoại)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 0.75, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0.25, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

-- Nhóm Ô Nhập + Nút (Nằm chung 1 hàng)
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(1, -5, 0, 30)
InputContainer.BackgroundTransparency = 1
InputContainer.LayoutOrder = 1
InputContainer.Parent = ScrollFrame

local CommandBox = Instance.new("TextBox")
CommandBox.Size = UDim2.new(0.7, -5, 1, 0)
CommandBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CommandBox.PlaceholderText = "Nhập lệnh..."
CommandBox.Text = ""
CommandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
CommandBox.Font = Enum.Font.Code
CommandBox.TextSize = 13
CommandBox.ClearTextOnFocus = false
CommandBox.Parent = InputContainer

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = CommandBox

local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Size = UDim2.new(0.3, 0, 1, 0)
ExecuteBtn.Position = UDim2.new(0.7, 0, 0, 0)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ExecuteBtn.Text = "RUN"
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.Code
ExecuteBtn.TextSize = 13
ExecuteBtn.Parent = InputContainer

local ExecCorner = Instance.new("UICorner")
ExecCorner.CornerRadius = UDim.new(0, 6)
ExecCorner.Parent = ExecuteBtn

-- Nhãn Trạng thái / Kết quả lệnh (Tự động kéo dài khi text dài)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -5, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "> Gõ 'help' để xem lệnh. Vuốt lên/xuống nếu bị che."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.AutomaticSize = Enum.AutomaticSize.Y
StatusLabel.LayoutOrder = 2
StatusLabel.Parent = ScrollFrame

-- ==================================================
-- 2. HỆ THỐNG KÉO THẢ (MOBILE DRAG)
-- ==================================================

local function MakeDraggable(dragHandle, dragTarget)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Chỉ cho phép kéo thả ở TopBar để phần dưới có thể "Vuốt"
MakeDraggable(ToggleBtn, ToggleBtn)
MakeDraggable(TopBar, MainFrame)

-- ==================================================
-- 3. HIỆU ỨNG MỞ/ĐÓNG MENU
-- ==================================================

local menuOpen = false
ToggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0.4, 0, 0.25, 0)})
        tween:Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        tween:Play()
        tween.Completed:Wait()
        MainFrame.Visible = false
    end
end)

-- ==================================================
-- 4. HỆ THỐNG XỬ LÝ LỆNH
-- ==================================================

local function RunCommand()
    local inputCmd = string.lower(string.match(CommandBox.Text, "^%s*(.-)%s*$"))
    
    if inputCmd == "eat" then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = 0
            StatusLabel.Text = "> Đã reset nhân vật."
        end

    elseif inputCmd == "rejoin" then
        StatusLabel.Text = "> Đang Rejoin..."
        if #game.JobId > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end

    elseif inputCmd == "refresh" then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            StatusLabel.Text = "> Đang refresh..."
            local savedCFrame = char.HumanoidRootPart.CFrame
            char:BreakJoints()
            
            local newChar = LocalPlayer.CharacterAdded:Wait()
            local root = newChar:WaitForChild("HumanoidRootPart", 5)
            if root then
                task.wait(0.1) 
                root.CFrame = savedCFrame
                StatusLabel.Text = "> Đã refresh!"
            end
        end

    elseif inputCmd == "clear" then
        CommandBox.Text = ""
        StatusLabel.Text = "> Đã xóa ô nhập."

    elseif inputCmd == "help" then
        StatusLabel.Text = "DANH SÁCH LỆNH:\n- eat (Reset NV)\n- rejoin (Vào lại server)\n- refresh (Reset giữ vị trí)\n- clear (Xóa khung)\n- help (Xem lệnh)"

    elseif inputCmd == "" then
        StatusLabel.Text = "> Vui lòng nhập một lệnh."
    else
        StatusLabel.Text = "> Lệnh không tồn tại! Gõ 'help'."
    end
end

ExecuteBtn.MouseButton1Click:Connect(RunCommand)

CommandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        RunCommand()
    end
end)
