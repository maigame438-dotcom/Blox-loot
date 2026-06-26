--// Redz Style Hub (UI ONLY)
--// By ChatGPT

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

--// UI BASE
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RedzStyleHub"
gui.ResetOnSpawn = false

--// OPEN BUTTON
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,50,0,50)
openBtn.Position = UDim2.new(0,10,0.5,-25)
openBtn.Text = "☰"
openBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
openBtn.TextColor3 = Color3.new(1,1,1)

local corner1 = Instance.new("UICorner", openBtn)
corner1.CornerRadius = UDim.new(1,0)

--// MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,450,0,300)
main.Position = UDim2.new(0.5,-225,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Visible = false

Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

--// TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "🚤 Redz Style Hub"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18

--// CLOSE BUTTON
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,40,0,40)
close.Position = UDim2.new(1,-45,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(40,40,40)
close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", close)

--// TAB BUTTONS
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(0,120,1,-40)
tabFrame.Position = UDim2.new(0,0,0,40)
tabFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)

--// CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-120,1,-40)
content.Position = UDim2.new(0,120,0,40)
content.BackgroundTransparency = 1

--////////////////////////////////////////////////////////
-- INFO TAB
--////////////////////////////////////////////////////////

local info = Instance.new("Frame", content)
info.Size = UDim2.new(1,0,1,0)
info.Visible = true

local avatar = Instance.new("ImageLabel", info)
avatar.Size = UDim2.new(0,80,0,80)
avatar.Position = UDim2.new(0,10,0,10)
avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=420&height=420&format=png"

local playTime = Instance.new("TextLabel", info)
playTime.Position = UDim2.new(0,100,0,10)
playTime.Size = UDim2.new(1,-110,0,30)
playTime.Text = "⏱ Time: 0s"
playTime.TextColor3 = Color3.new(1,1,1)
playTime.BackgroundTransparency = 1

local fpsLabel = Instance.new("TextLabel", info)
fpsLabel.Position = UDim2.new(0,100,0,40)
fpsLabel.Size = UDim2.new(1,-110,0,30)
fpsLabel.Text = "📊 FPS: ..."
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.BackgroundTransparency = 1

-- FPS CALC
local RunService = game:GetService("RunService")
local fps = 0
local last = tick()

RunService.RenderStepped:Connect(function()
	fps += 1
	if tick() - last >= 1 then
		fpsLabel.Text = "📊 FPS: "..fps
		fps = 0
		last = tick()
	end
end)

-- TIME
task.spawn(function()
	local t = 0
	while true do
		task.wait(1)
		t += 1
		playTime.Text = "⏱ Time: "..t.."s"
	end
end)

--////////////////////////////////////////////////////////
-- SETTINGS TAB (SIMPLE LOCAL CHANGES ONLY)
--////////////////////////////////////////////////////////

local settings = Instance.new("Frame", content)
settings.Size = UDim2.new(1,0,1,0)
settings.Visible = false

local speedBtn = Instance.new("TextButton", settings)
speedBtn.Size = UDim2.new(0,200,0,40)
speedBtn.Position = UDim2.new(0,10,0,10)
speedBtn.Text = "Speed + (16 → 32)"

speedBtn.MouseButton1Click:Connect(function()
	hum.WalkSpeed = 32
end)

local jumpBtn = Instance.new("TextButton", settings)
jumpBtn.Size = UDim2.new(0,200,0,40)
jumpBtn.Position = UDim2.new(0,10,0,60)
jumpBtn.Text = "Jump +"

jumpBtn.MouseButton1Click:Connect(function()
	hum.JumpPower = 80
end)

--////////////////////////////////////////////////////////
-- VISUAL TAB
--////////////////////////////////////////////////////////

local visual = Instance.new("Frame", content)
visual.Size = UDim2.new(1,0,1,0)
visual.Visible = false

local black = Instance.new("Frame", gui)
black.Size = UDim2.new(1,0,1,0)
black.BackgroundColor3 = Color3.new(0,0,0)
black.Visible = false

local blackBtn = Instance.new("TextButton", visual)
blackBtn.Size = UDim2.new(0,200,0,40)
blackBtn.Position = UDim2.new(0,10,0,10)
blackBtn.Text = "Black Screen"

blackBtn.MouseButton1Click:Connect(function()
	black.Visible = not black.Visible
end)

--////////////////////////////////////////////////////////
-- OPEN / CLOSE
--////////////////////////////////////////////////////////

openBtn.MouseButton1Click:Connect(function()
	main.Visible = true
end)

close.MouseButton1Click:Connect(function()
	main.Visible = false
end)
