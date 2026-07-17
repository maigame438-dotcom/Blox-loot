--[[
    REDZ HUB v2.1 - Tối ưu cho Mobile & PC
    Chức năng: SetSpawn, Auto E, Auto Click
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local CustomSpawn = nil

-- Trạng thái
local AutoE_Enabled = false
local AutoClick_Enabled = false

-- Cleanup nếu đã chạy
if game.CoreGui:FindFirstChild("RedzHub") then game.CoreGui.RedzHub:Destroy() end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "RedzHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 200)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "REDZ HUB"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.Bold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- Nút chức năng
local function CreateBtn(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, #MainFrame:GetChildren() * 45 - 20)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

CreateBtn("SET SPAWN", function()
    CustomSpawn = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.CFrame
    -- Thông báo đơn giản
    print("Redz Hub: Spawn Saved!")
end)

local eBtn = CreateBtn("Auto E: OFF", function()
    AutoE_Enabled = not AutoE_Enabled
    eBtn.Text = AutoE_Enabled and "Auto E: ON" or "Auto E: OFF"
end)

local clickBtn = CreateBtn("Auto Click: OFF", function()
    AutoClick_Enabled = not AutoClick_Enabled
    clickBtn.Text = AutoClick_Enabled and "Auto Click: ON" or "Auto Click: OFF"
end)

-- Vòng lặp chính (Tối ưu)
RunService.RenderStepped:Connect(function()
    if AutoE_Enabled then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    end
    if AutoClick_Enabled then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    end
end)

-- Respawn logic
Player.CharacterAdded:Connect(function(char)
    if CustomSpawn then
        task.wait(0.5)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then hrp.CFrame = CustomSpawn end
    end
end)

-- Kéo thả (Tối ưu cho cả chạm cảm ứng)
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
