-- =========================================================================
-- SCRIPT: SPEED & JUMP MODIFIER (OPTIMIZED)
-- =========================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = CoreGui -- Ưu tiên dùng CoreGui để tránh bị game xóa
local Mouse = LocalPlayer:GetMouse()

-- Lưu giá trị hiện tại
local SpeedVal = 16
local JumpVal = 50

-- =========================================================================
-- HÀM CẬP NHẬT THÔNG SỐ NHÂN VẬT
-- =========================================================================

local function UpdateCharacterStats()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = SpeedVal
        char.Humanoid.JumpPower = JumpVal
    end
end

-- Tự động áp dụng khi hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    UpdateCharacterStats()
end)

-- =========================================================================
-- HÀM TẠO GIAO DIỆN (UI COMPONENTS)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "StatModifierUI"

local MainHolder = Instance.new("Frame", ScreenGui)
MainHolder.Size = UDim2.new(0, 350, 0, 160)
MainHolder.Position = UDim2.new(0.5, -175, 0.4, 0)
MainHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainHolder.BorderSizePixel = 0
Instance.new("UICorner", MainHolder).CornerRadius = UDim.new(0, 10)

-- Hàm tạo Slider
local function CreateSlider(parent, title, desc, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(0.95, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", Frame)
    Title.Text = title
    Title.Size = UDim2.new(0.6, 0, 0.5, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Color3.new(1,1,1)
    
    local Desc = Instance.new("TextLabel", Frame)
    Desc.Text = desc
    Desc.Position = UDim2.new(0, 5, 0.5, 0)
    Desc.Size = UDim2.new(0.6, 0, 0.5, 0)
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 10
    Desc.TextColor3 = Color3.fromRGB(200, 200, 200)

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0, 50, 0, 30)
    Input.Position = UDim2.new(0.65, 0, 0.25, 0)
    Input.Text = tostring(default)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 5)

    local SliderBg = Instance.new("Frame", Frame)
    SliderBg.Size = UDim2.new(0, 80, 0, 6)
    SliderBg.Position = UDim2.new(0.85, 0, 0.5, -3)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    local SliderBar = Instance.new("Frame", SliderBg)
    SliderBar.Size = UDim2.new(0, 0, 1, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    local Knob = Instance.new("ImageButton", SliderBar)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(1, -8, 0.5, -8)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    -- Logic xử lý
    local function UpdateVal(v)
        v = math.clamp(math.floor(v), min, max)
        Input.Text = tostring(v)
        callback(v)
    end

    Input.FocusLost:Connect(function()
        UpdateVal(tonumber(Input.Text) or default)
    end)

    Knob.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local relative = (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
                UpdateVal(min + (relative * (max - min)))
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                connection:Disconnect()
            end
        end)
    end)
    
    return {Input = Input, SliderBar = SliderBar}
end

-- =========================================================================
-- KHỞI TẠO CÁC Ô ĐIỀU KHIỂN
-- =========================================================================

local UIList = Instance.new("UIListLayout", MainHolder)
UIList.Padding = UDim.new(0, 10)

CreateSlider(MainHolder, "Walk Speed", "Chỉnh tốc độ di chuyển (16 - 350)", 16, 350, 16, function(v)
    SpeedVal = v
    UpdateCharacterStats()
end)

CreateSlider(MainHolder, "Jump Power", "Chỉnh độ cao khi nhảy (16 - 150)", 16, 150, 50, function(v)
    JumpVal = v
    UpdateCharacterStats()
end)

-- Thông báo thành công
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Success",
    Text = "Script Loaded Successfully",
    Duration = 3
})
