-- Tránh trùng lặp UI khi chạy lại script
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local GUI_NAME = "ModernBrightnessController"

if CoreGui:FindFirstChild(GUI_NAME) then
    local oldGui = CoreGui:FindFirstChild(GUI_NAME)
    if oldGui:FindFirstChild("OriginalBrightness") then
        Lighting.Brightness = oldGui.OriginalBrightness.Value
    end
    oldGui:Destroy()
end

-- Lưu giá trị gốc để khôi phục khi script bị hủy
local originalBrightnessValue = Lighting.Brightness

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- Biến lưu giá trị khôi phục
local configVal = Instance.new("NumberValue")
configVal.Name = "OriginalBrightness"
configVal.Value = originalBrightnessValue
configVal.Parent = ScreenGui

-- Cấu hình màu sắc
local COLOR_MAIN = Color3.fromRGB(168, 85, 247) -- Tím (#A855F7)
local COLOR_BG = Color3.fromRGB(20, 20, 25)
local COLOR_BG_LIGHT = Color3.fromRGB(30, 30, 38)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_TEXT_DIM = Color3.fromRGB(170, 170, 180)

-- ==========================================
-- 1. TẠO NÚT FLOATING (Nổi)
-- ==========================================
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 50, 0, 50)
FloatingButton.Position = UDim2.new(0.5, -25, 0.1, 0) -- Giữa phía trên cùng lúc đầu
FloatingButton.BackgroundColor3 = COLOR_BG
FloatingButton.Text = "💡"
FloatingButton.TextColor3 = COLOR_MAIN
FloatingButton.TextSize = 24
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingButton

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = COLOR_MAIN
FloatStroke.Thickness = 1.5
FloatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FloatStroke.Parent = FloatingButton

local FloatShadow = Instance.new("ImageLabel")
FloatShadow.Name = "Shadow"
FloatShadow.AnchorPoint = Vector2.new(0.5, 0.5)
FloatShadow.BackgroundTransparency = 1
FloatShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
FloatShadow.Size = UDim2.new(1, 30, 1, 30)
FloatShadow.ZIndex = -1
FloatShadow.Image = "rbxassetid://5554831670"
FloatShadow.ImageColor3 = COLOR_MAIN
FloatShadow.ImageTransparency = 0.6
FloatShadow.Parent = FloatingButton

-- ==========================================
-- 2. TẠO MENU CHÍNH
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 200)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -100)
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.Visible = false
MainFrame.GroupTransparency = 1
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.Thickness = 1
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "Shadow"
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.BackgroundTransparency = 1
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainShadow.Size = UDim2.new(1, 60, 1, 60)
MainShadow.ZIndex = -1
MainShadow.Image = "rbxassetid://5554831670"
MainShadow.ImageColor3 = Color3.new(0, 0, 0)
MainShadow.ImageTransparency = 0.4
MainShadow.Parent = MainFrame

-- Thanh kéo menu (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "☀ BRIGHTNESS"
Title.TextColor3 = COLOR_TEXT
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = COLOR_TEXT_DIM
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Hiển thị giá trị
local ValueBox = Instance.new("Frame")
ValueBox.Size = UDim2.new(0, 120, 0, 36)
ValueBox.Position = UDim2.new(0.5, -60, 0, 55)
ValueBox.BackgroundColor3 = COLOR_BG_LIGHT
ValueBox.Parent = MainFrame

local ValueCorner = Instance.new("UICorner")
ValueCorner.CornerRadius = UDim.new(0, 8)
ValueCorner.Parent = ValueBox

local ValueStroke = Instance.new("UIStroke")
ValueStroke.Color = COLOR_MAIN
ValueStroke.Transparency = 0.5
ValueStroke.Parent = ValueBox

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(1, 0, 1, 0)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = string.format("%.2fx", Lighting.Brightness)
ValueLabel.TextColor3 = COLOR_MAIN
ValueLabel.TextSize = 18
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.Parent = ValueBox

-- Slider
local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(1, -40, 0, 30)
SliderContainer.Position = UDim2.new(0, 20, 0, 110)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = MainFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, 0, 0, 6)
SliderTrack.Position = UDim2.new(0, 0, 0.5, -3)
SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SliderTrack.Parent = SliderContainer

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(Lighting.Brightness / 5.0, 0, 1, 0)
SliderFill.BackgroundColor3 = COLOR_MAIN
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 18, 0, 18)
SliderKnob.Position = UDim2.new(Lighting.Brightness / 5.0, 0, 0.5, 0)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.BackgroundColor3 = COLOR_TEXT
SliderKnob.Parent = SliderTrack

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

local KnobStroke = Instance.new("UIStroke")
KnobStroke.Color = COLOR_MAIN
KnobStroke.Thickness = 2
KnobStroke.Parent = SliderKnob

local MinLabel = Instance.new("TextLabel")
MinLabel.Size = UDim2.new(0, 30, 0, 15)
MinLabel.Position = UDim2.new(0, 0, 1, 2)
MinLabel.BackgroundTransparency = 1
MinLabel.Text = "0.0"
MinLabel.TextColor3 = COLOR_TEXT_DIM
MinLabel.TextSize = 10
MinLabel.Font = Enum.Font.Gotham
MinLabel.TextXAlignment = Enum.TextXAlignment.Left
MinLabel.Parent = SliderContainer

local MaxLabel = Instance.new("TextLabel")
MaxLabel.Size = UDim2.new(0, 30, 0, 15)
MaxLabel.Position = UDim2.new(1, -30, 1, 2)
MaxLabel.BackgroundTransparency = 1
MaxLabel.Text = "5.0"
MaxLabel.TextColor3 = COLOR_TEXT_DIM
MaxLabel.TextSize = 10
MaxLabel.Font = Enum.Font.Gotham
MaxLabel.TextXAlignment = Enum.TextXAlignment.Right
MaxLabel.Parent = SliderContainer

-- Nút Reset
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, -40, 0, 32)
ResetBtn.Position = UDim2.new(0, 20, 1, -45)
ResetBtn.BackgroundColor3 = COLOR_BG_LIGHT
ResetBtn.Text = "↻ RESET (1.0)"
ResetBtn.TextColor3 = COLOR_TEXT_DIM
ResetBtn.TextSize = 12
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = MainFrame

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 6)
ResetCorner.Parent = ResetBtn

-- ==========================================
-- 3. LOGIC KÉO THẢ (DRAG)
-- ==========================================
local function MakeDraggable(dragArea, moveTarget)
    local dragging, dragInput, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(FloatingButton, FloatingButton)
MakeDraggable(TopBar, MainFrame)

-- ==========================================
-- 4. LOGIC TWEEN (MỞ/ĐÓNG)
-- ==========================================
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function OpenMenu()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 230, 0, 170) -- Nhỏ hơn một chút để tạo hiệu ứng phóng to
    
    local tweenCloseFloat = TweenService:Create(FloatingButton, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), TextTransparency = 1})
    local tweenOpenMain = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 260, 0, 200), GroupTransparency = 0})
    
    tweenCloseFloat:Play()
    tweenOpenMain:Play()
    
    tweenCloseFloat.Completed:Connect(function()
        if MainFrame.Visible then FloatingButton.Visible = false end
    end)
end

local function CloseMenu()
    FloatingButton.Visible = true
    
    local tweenCloseMain = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 230, 0, 170), GroupTransparency = 1})
    local tweenOpenFloat = TweenService:Create(FloatingButton, tweenInfo, {Size = UDim2.new(0, 50, 0, 50), TextTransparency = 0})
    
    tweenCloseMain:Play()
    tweenOpenFloat:Play()
    
    tweenCloseMain.Completed:Connect(function()
        if FloatingButton.Visible then MainFrame.Visible = false end
    end)
end

FloatingButton.MouseButton1Click:Connect(OpenMenu)
CloseBtn.MouseButton1Click:Connect(CloseMenu)

-- ==========================================
-- 5. LOGIC ĐIỀU CHỈNH ĐỘ SÁNG (SLIDER)
-- ==========================================
local isDraggingSlider = false

local function UpdateBrightness(input)
    local trackPos = SliderTrack.AbsolutePosition.X
    local trackSize = SliderTrack.AbsoluteSize.X
    local inputPos = input.Position.X
    
    -- Tính phần trăm từ 0 đến 1
    local percent = math.clamp((inputPos - trackPos) / trackSize, 0, 1)
    
    -- Chuyển đổi sang scale 0.0 - 5.0
    local brightnessVal = percent * 5.0
    brightnessVal = math.floor(brightnessVal * 100) / 100 -- Giữ 2 chữ số thập phân
    
    -- Cập nhật UI
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
    ValueLabel.Text = string.format("%.2fx", brightnessVal)
    
    -- Cập nhật hệ thống
    Lighting.Brightness = brightnessVal
end

SliderContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
        UpdateBrightness(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateBrightness(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = false
    end
end)

-- Nút Reset
ResetBtn.MouseButton1Click:Connect(function()
    local targetVal = 1.0
    local percent = targetVal / 5.0
    
    -- Tween slider cho mượt khi reset
    TweenService:Create(SliderFill, tweenInfo, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    TweenService:Create(SliderKnob, tweenInfo, {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
    
    ValueLabel.Text = "1.00x"
    Lighting.Brightness = targetVal
end)

-- ==========================================
-- 6. DỌN DẸP KHI HỦY SCRIPT
-- ==========================================
ScreenGui.Destroying:Connect(function()
    Lighting.Brightness = originalBrightnessValue
end)
