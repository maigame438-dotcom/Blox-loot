-- =====================================================================
-- LUXURY MODERN UI FLUID SCRIPT (Roblox Executor Compatible)
-- Hỗ trợ: PC (Mouse) & Mobile (Touch) - Tối ưu chống giật (Anti-Lag)
-- =====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Tự động chọn vùng chứa an toàn (Ưu tiên CoreGui của Executor, test trong Studio tự chuyển sang PlayerGui)
local TargetParent = (RunService:IsStudio()) and Players.LocalPlayer:WaitForChild("PlayerGui") or (gethui and gethui()) or CoreGui

-- Xóa UI cũ nếu có trùng tên để tránh tạo nhiều menu
if TargetParent:FindFirstChild("ModernFluidUI_Hub") then
    TargetParent["ModernFluidUI_Hub"]:Destroy()
end

-- =====================================================================
-- 1. KHỞI TẠO FRAMEWORK GIAO DIỆN
-- =====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernFluidUI_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- 1.1 [Chức năng 1] Màn hình đen (Black Screen Overlay)
local BlackScreen = Instance.new("Frame")
BlackScreen.Name = "BlackScreenOverlay"
BlackScreen.Size = UDim2.new(1, 0, 1, 0)
BlackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreen.BackgroundTransparency = 1 -- Mặc định ẩn
BlackScreen.ZIndex = 100
BlackScreen.Visible = false
BlackScreen.Parent = ScreenGui

-- 1.2 [Chức năng 7] Menu chính (Main UI)
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainContainer"
MainMenu.Size = UDim2.new(0, 420, 0, 260)
MainMenu.Position = UDim2.new(0.5, -210, 0.5, -130)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Màu xám đen tối giản
MainMenu.BorderSizePixel = 0
MainMenu.ClipsDescendants = true
MainMenu.ZIndex = 10
MainMenu.Visible = false -- Mặc định đóng, dùng animation mở lên lúc đầu
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 14) -- Bo góc hiện đại
MenuCorner.Parent = MainMenu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(45, 45, 45)
MenuStroke.Thickness = 1
MenuStroke.Parent = MainMenu

-- [Chức năng 6] UIScale phục vụ cho Animation thu phóng
local MenuScale = Instance.new("UIScale")
MenuScale.Scale = 0.8
MenuScale.Parent = MainMenu

-- Canvas chứa nội dung (Nơi bạn thêm chức năng/Tab sau này)
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -24, 1, -50)
ContentArea.Position = UDim2.new(0, 12, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
ContentArea.Parent = MainMenu

-- 1.3 [Chức năng 3] Nút nổi hình tròn (Floating Button)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingMenuButton"
FloatingBtn.Size = UDim2.new(0, 55, 0, 55) -- Kích thước đúng chuẩn 55x55
FloatingBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Nền đen đậm
FloatingBtn.Text = "⋯" -- Biểu tượng 3 chấm ngang theo yêu cầu
FloatingBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
FloatingBtn.TextSize = 24
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.ZIndex = 50
FloatingBtn.AutoButtonColor = false
FloatingBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0) -- Bo tròn hoàn toàn thành hình tròn
BtnCorner.Parent = FloatingBtn

-- Tạo bóng nhẹ (Drop Shadow) bằng UIStroke mờ
local BtnShadow = Instance.new("UIStroke")
BtnShadow.Color = Color3.fromRGB(255, 255, 255)
BtnShadow.Thickness = 1.5
BtnShadow.Transparency = 0.88
BtnShadow.Parent = FloatingBtn

-- =====================================================================
-- 2. ĐỊNH NGHĨA ANIMATION & BIẾN TRẠNG THÁI
-- =====================================================================

local MenuVisible = false
local IsAnimating = false -- Khóa chống lỗi khi spam click liên tục
local TweenDuration = 0.25 -- Tốc độ 0.25 giây theo yêu cầu
local SmoothInfo = TweenInfo.new(TweenDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Canvas Group để xử lý Fade In/Out toàn bộ Menu mượt mà
local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.Size = UDim2.new(1, 0, 1, 0)
CanvasGroup.BackgroundTransparency = 1
CanvasGroup.Parent = MainMenu
ContentArea.Parent = CanvasGroup

-- Title giả lập để nhìn đẹp mắt hơn
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "MODERN HUB v1.0"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TitleLabel.Position = UDim2.new(0, 12, 0, 12)
TitleLabel.Size = UDim2.new(0, 200, 0, 20)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = CanvasGroup

-- =====================================================================
-- 3. HÀM CHỨC NĂNG (CORE FUNCTIONS)
-- =====================================================================

-- [Chức năng 1] Hàm Bật/Tắt màn hình đen (Fade In/Fade Out)
local function SetBlackScreen(state)
    if state then
        BlackScreen.Visible = true
        TweenService:Create(BlackScreen, SmoothInfo, {BackgroundTransparency = 0.3}):Play() -- Màu đen mờ ảo sâu lắng
    else
        local FadeOut = TweenService:Create(BlackScreen, SmoothInfo, {BackgroundTransparency = 1})
        FadeOut:Play()
        FadeOut.Completed:Connect(function()
            if BlackScreen.BackgroundTransparency == 1 then
                BlackScreen.Visible = false
            end
        end)
    end
end

-- [Chức năng 2, 4, 6] Hàm xử lý Đóng/Mở Menu lặp lại (Toggle + Animation)
local function ToggleMenu()
    if IsAnimating then return end -- Nếu đang chạy hiệu ứng thì bỏ qua để chống lỗi bấm nhanh
    IsAnimating = true
    
    MenuVisible = not MenuVisible
    
    if MenuVisible then
        -- TRẠNG THÁI: MỞ MENU
        MainMenu.Visible = true
        MenuScale.Scale = 0.85 -- Bắt đầu từ scale nhỏ
        CanvasGroup.GroupTransparency = 1 -- Bắt đầu ẩn hoàn toàn
        
        local OpenScale = TweenService:Create(MenuScale, SmoothInfo, {Scale = 1})
        local OpenFade = TweenService:Create(CanvasGroup, SmoothInfo, {GroupTransparency = 0})
        
        OpenScale:Play()
        OpenFade:Play()
        
        OpenFade.Completed:Connect(function()
            IsAnimating = false
        end)
    else
        -- TRẠNG THÁI: ĐÓNG MENU (HIDE UI)
        local CloseScale = TweenService:Create(MenuScale, SmoothInfo, {Scale = 0.85})
        local CloseFade = TweenService:Create(CanvasGroup, SmoothInfo, {GroupTransparency = 1})
        
        CloseScale:Play()
        CloseFade:Play()
        
        CloseFade.Completed:Connect(function()
            if not MenuVisible then
                MainMenu.Visible = false
            end
            IsAnimating = false
        end)
    end
end

-- [Chức năng 5] Hệ thống Kéo thả Nút Nổi mượt mà (Hỗ trợ PC & Mobile)
local function SetupDraggableButton(button)
    local Dragging = false
    local DragInput, DragStart, StartPos
    
    local function UpdatePosition(input)
        local Delta = input.Position - DragStart
        local GoalPos = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, startPos.Y.Offset + Delta.Y
        )
        -- Sử dụng Tween nội suy tuyến tính ngắn (0.1s) để tạo cảm giác bám tay cực mượt, không bị giật lag
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = GoalPos}):Play()
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    
                    -- Đảm bảo nút không bị văng/vượt ra khỏi mép màn hình khi thả tay
                    local ScreenSize = ScreenGui.AbsoluteSize
                    local ButtonSize = button.AbsoluteSize
                    local CurrentPos = button.AbsolutePosition
                    
                    local BoundX = math.clamp(CurrentPos.X, 0, ScreenSize.X - ButtonSize.X)
                    local BoundY = math.clamp(CurrentPos.Y, 0, ScreenSize.Y - ButtonSize.Y)
                    
                    TweenService:Create(button, SmoothInfo, {
                        Position = UDim2.new(0, BoundX, 0, BoundY)
                    }):Play()
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePosition(input)
        end
    end)
end

-- =====================================================================
-- 4. HIỆU ỨNG TƯƠNG TÁC (HOVER EFFECT) & ĐIỀU KHIỂN SỰ KIỆN
-- =====================================================================

-- Kích hoạt tính năng kéo thả mượt cho nút nổi
SetupDraggableButton(FloatingBtn)

-- Hiệu ứng khi rê chuột vào / Chạm vào nút nổi
FloatingBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatingBtn, SmoothInfo, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    TweenService:Create(BtnShadow, SmoothInfo, {Transparency = 0.5}):Play()
end)

FloatingBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatingBtn, SmoothInfo, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
    TweenService:Create(BtnShadow, SmoothInfo, {Transparency = 0.88}):Play()
end)

-- Phân biệt hành vi "Click ngắn để Toggle UI" và "Giữ lâu để Kéo nút"
local TouchStartTime = 0
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TouchStartTime = tick()
        TweenService:Create(FloatingBtn, SmoothInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end
end)

FloatingBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(FloatingBtn, SmoothInfo, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
        
        -- Nếu nhấn và thả trong vòng chưa đầy 0.25 giây -> Xác định là hành động Click đổi trạng thái UI
        if tick() - TouchStartTime < 0.25 then
            ToggleMenu()
        end
    end
end)

-- Mở Menu lần đầu tiên khi chạy Script
ToggleMenu()

-- =====================================================================
-- HƯỚNG DẪN MỞ RỘNG (DÀNH CHO BẠN):
-- Để điều khiển màn hình đen từ xa, bạn chỉ cần gọi:
-- SetBlackScreen(true) -> Để bật màn hình đen
-- SetBlackScreen(false) -> Để tắt màn hình đen
-- =====================================================================
