-- =========================================================================
-- SCRIPT: SPEED & JUMP MODIFIER (TEXTBOX INPUT - TRANSPARENT UI)
-- =========================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = CoreGui 

-- Lưu giá trị
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

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    UpdateCharacterStats()
end)

-- =========================================================================
-- HÀM TẠO GIAO DIỆN (UI)
-- =========================================================================

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "StatModifierUI"

-- Main Frame (Nền đen trong suốt)
local MainHolder = Instance.new("Frame", ScreenGui)
MainHolder.Size = UDim2.new(0, 250, 0, 160)
MainHolder.Position = UDim2.new(0.5, -125, 0.4, 0)
MainHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainHolder.BackgroundTransparency = 0.3 -- Độ trong suốt
MainHolder.BorderSizePixel = 0
Instance.new("UICorner", MainHolder).CornerRadius = UDim.new(0, 10)

-- Thanh di chuyển (Handle)
local Handle = Instance.new("Frame", MainHolder)
Handle.Size = UDim2.new(1, 0, 0, 30)
Handle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", Handle).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel", Handle)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "Menu Chỉnh Số"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- Tính năng kéo thả menu
local dragging, dragStart, startPos
Handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainHolder.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- Hàm tạo ô nhập số
local function CreateInput(parent, title, min, max, initial, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(0.9, 0, 0, 50)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Text = title
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1
    
    local Box = Instance.new("TextBox", Container)
    Box.Size = UDim2.new(0.35, 0, 0.7, 0)
    Box.Position = UDim2.new(0.65, 0, 0.15, 0)
    Box.Text = tostring(initial)
    Box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 5)
    Box.TextColor3 = Color3.new(1, 1, 1)
    
    Box.FocusLost:Connect(function()
        local val = tonumber(Box.Text)
        if val then
            val = math.clamp(math.floor(val), min, max)
            Box.Text = tostring(val)
            callback(val)
        else
            Box.Text = tostring(initial)
        end
    end)
end

local UIList = Instance.new("UIListLayout", MainHolder)
UIList.Padding = UDim.new(0, 5)
UIList.Padding = UDim.new(0, 10)
UIList.Padding = UDim.new(0, 10)

-- Tạo các ô nhập
CreateInput(MainHolder, "Walk Speed", 16, 350, 16, function(v) SpeedVal = v; UpdateCharacterStats() end)
CreateInput(MainHolder, "Jump Power", 16, 150, 50, function(v) JumpVal = v; UpdateCharacterStats() end)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Success", Text = "Menu Ready!", Duration = 3})
