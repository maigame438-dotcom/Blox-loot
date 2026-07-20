-- =========================================================================
-- SCRIPT: TỐI ƯU HÓA KHÓA DI CHUYỂN (MOVEMENT LOCK) - HỖ TRỢ MOBILE
-- =========================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local isLocked = false
local anchorConnection = nil

-- =========================================================================
-- HÀM XỬ LÝ KHÓA/MỞ KHÓA DI CHUYỂN
-- =========================================================================

-- Ngăn chặn các script khác trong game cố tình gỡ Anchored
local function EnforceAnchor(hrp)
    if anchorConnection then
        anchorConnection:Disconnect()
        anchorConnection = nil
    end

    anchorConnection = hrp:GetPropertyChangedSignal("Anchored"):Connect(function()
        if isLocked and not hrp.Anchored then
            hrp.Anchored = true
        end
    end)
end

-- Hàm áp dụng trạng thái Lock/Unlock lên Character hiện tại
local function ApplyLockState(character, state)
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = state
        if state then
            EnforceAnchor(hrp)
        else
            if anchorConnection then
                anchorConnection:Disconnect()
                anchorConnection = nil
            end
        end
    end
end

-- Tự động áp dụng lại trạng thái nếu người chơi Reset/Chết và hồi sinh
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart", 5)
    ApplyLockState(character, isLocked)
end)

-- =========================================================================
-- HÀM TẠO GIAO DIỆN VÀ KÉO THẢ (HỖ TRỢ MOBILE TOUCH VÀ MOUSE)
-- =========================================================================

local function MakeDraggable(gui)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X, 
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- =========================================================================
-- KHỞI TẠO GIAO DIỆN (UI)
-- =========================================================================

local function CreateUI()
    -- Xác định vị trí chứa GUI an toàn nhất
    local targetGui = CoreGui
    local success = pcall(function() local _ = targetGui.Name end)
    if not success then
        targetGui = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Tránh trùng lặp UI nếu chạy script nhiều lần
    if targetGui:FindFirstChild("MovementLockUI") then
        targetGui.MovementLockUI:Destroy()
    end

    -- Tạo ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MovementLockUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetGui

    -- Main Frame (Bảng kéo thả)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 160, 0, 50)
    MainFrame.Position = UDim2.new(0.5, -80, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Kích hoạt tính năng kéo thả
    MakeDraggable(MainFrame)

    -- Text
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 90, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Lock Move"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    -- Background của nút Toggle
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 46, 0, 24)
    ToggleBg.Position = UDim2.new(1, -56, 0.5, -12)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(120, 120, 120) -- Mặc định OFF là màu xám
    ToggleBg.Parent = MainFrame

    local ToggleBgCorner = Instance.new("UICorner")
    ToggleBgCorner.CornerRadius = UDim.new(1, 0) -- Bo tròn hoàn toàn
    ToggleBgCorner.Parent = ToggleBg

    -- Nút tròn bên trong (Knob)
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10) -- Mặc định bên trái
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = ToggleBg

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0) -- Bo tròn thành hình tròn
    CircleCorner.Parent = ToggleCircle

    -- Nút bấm tàng hình phủ lên để nhận thao tác Click/Touch
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleBg

    -- =========================================================================
    -- HIỆU ỨNG & LOGIC CHUYỂN ĐỔI (TOGGLE EVENT)
    -- =========================================================================
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    ToggleButton.MouseButton1Click:Connect(function()
        isLocked = not isLocked
        
        -- Cài đặt Tween cho nút gạt
        local targetPosition = isLocked and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetColor = isLocked and Color3.fromHex("#8A2BE2") or Color3.fromRGB(120, 120, 120)

        local moveTween = TweenService:Create(ToggleCircle, tweenInfo, {Position = targetPosition})
        local colorTween = TweenService:Create(ToggleBg, tweenInfo, {BackgroundColor3 = targetColor})

        moveTween:Play()
        colorTween:Play()

        -- Áp dụng trạng thái vật lý
        ApplyLockState(LocalPlayer.Character, isLocked)
    end)
end

-- =========================================================================
-- KHỞI CHẠY VÀ THÔNG BÁO THÀNH CÔNG
-- =========================================================================

-- Chạy Script tạo UI
CreateUI()

-- Hiển thị thông báo "Loading script Success" ở góc màn hình
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Hệ thống",
        Text = "Loading script Success",
        Duration = 5, -- Thời gian hiển thị (giây)
    })
end)
