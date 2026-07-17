--[[
    REDZ HUB - Custom UI Script
    Tối ưu cho Mobile & PC
    Chức năng: Noclip, FlyJump, SetSpawn
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Biến lưu trạng thái
local NoclipEnabled = false
local FlyJumpEnabled = false
local CustomSpawn = nil

-- Xóa UI cũ nếu có
if game.CoreGui:FindFirstChild("RedzHub") then
    game.CoreGui.RedzHub:Destroy()
end

-- Tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RedzHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Nút mở menu (Nút tròn nhỏ)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 20, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.Text = "☰"
OpenButton.TextColor3 = Color3.fromRGB(255, 0, 0)
OpenButton.TextSize = 25
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)

-- Menu chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Chức năng kéo thả
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Tạo các hàm UI (đơn giản hóa)
local function CreateToggle(name, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", frame)
    btn.Text = "OFF"
    btn.Position = UDim2.new(0.7, 0, 0.1, 0)
    btn.Size = UDim2.new(0.2, 0, 0.8, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
end

-- Logic Noclip
RunService.Stepped:Connect(function()
    if NoclipEnabled and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Logic FlyJump (Infinite Jump)
UserInputService.JumpRequest:Connect(function()
    if FlyJumpEnabled then
        Player.Character:FindFirstChild("Humanoid"):ChangeState("Jumping")
    end
end)

-- Logic SetSpawn
local function SetSpawnLocation()
    CustomSpawn = Player.Character.HumanoidRootPart.CFrame
    game.StarterGui:SetCore("SendNotification", {Title = "Redz Hub", Text = "Đã lưu vị trí hồi sinh!"})
end

Player.CharacterAdded:Connect(function(char)
    if CustomSpawn then
        task.wait(0.5)
        char:WaitForChild("HumanoidRootPart").CFrame = CustomSpawn
    end
end)

-- Xây dựng UI
CreateToggle("Noclip", function(btn)
    NoclipEnabled = not NoclipEnabled
    btn.Text = NoclipEnabled and "ON" or "OFF"
    btn.BackgroundColor3 = NoclipEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

CreateToggle("FlyJump", function(btn)
    FlyJumpEnabled = not FlyJumpEnabled
    btn.Text = FlyJumpEnabled and "ON" or "OFF"
end)

local SpawnBtn = Instance.new("TextButton", MainFrame)
SpawnBtn.Text = "SET SPAWN"
SpawnBtn.Size = UDim2.new(0.4, 0, 0, 30)
SpawnBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
SpawnBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
SpawnBtn.MouseButton1Click:Connect(SetSpawnLocation)

-- Nút đóng menu
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
