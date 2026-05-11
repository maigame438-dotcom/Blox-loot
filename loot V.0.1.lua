local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Position = UDim2.new(0.1,0,0.2,0)
Frame.Size = UDim2.new(0,250,0,140)
Frame.Active = true
Frame.Draggable = true

TextButton.Parent = Frame
TextButton.Size = UDim2.new(0,200,0,50)
TextButton.Position = UDim2.new(0.1,0,0.3,0)
TextButton.Text = "Auto Loot"

local enabled = false

TextButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    TextButton.Text = enabled and "Auto Loot: ON" or "Auto Loot: OFF"

    while enabled do
        for _,v in pairs(workspace:GetDescendants()) do
            if v.Name == "Loot" and v:IsA("Part") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                wait(0.2)
            end
        end
        wait(1)
    end
end)
