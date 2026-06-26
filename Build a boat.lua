--// REDZ HUB STYLE UI (REAL LAYOUT STYLE)
--// UI ONLY (NO AUTO FARM)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")

--// SCREEN GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RedzHubStyle"
gui.ResetOnSpawn = false

--// OPEN BUTTON
local open = Instance.new("TextButton", gui)
open.Size = UDim2.new(0,45,0,45)
open.Position = UDim2.new(0,10,0.5,-22)
open.Text = "☰"
open.BackgroundColor3 = Color3.fromRGB(20,20,20)
open.TextColor3 = Color3.new(1,1,1)

Instance.new("UICorner", open).CornerRadius = UDim.new(1,0)

--// MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,520,0,320)
main.Position = UDim2.new(0.5,-260,0.5,-160)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

-- TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.Text = "🚤 REDZ HUB STYLE"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0,40,0,40)
close.Position = UDim2.new(1,-40,0,0)
close.Text = "X"
close.BackgroundTransparency = 1
close.TextColor3 = Color3.new(1,1,1)

-- LEFT TAB
local tab = Instance.new("Frame", main)
tab.Size = UDim2.new(0,120,1,-40)
tab.Position = UDim2.new(0,0,0,40)
tab.BackgroundColor3 = Color3.fromRGB(15,15,15)

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-120,1,-40)
content.Position = UDim2.new(0,120,0,40)
content.BackgroundTransparency = 1

--//////////////////////////////////////////////////////
-- PAGES
--//////////////////////////////////////////////////////

local pages = {}

function makePage(name)
	local p = Instance.new("Frame", content)
	p.Size = UDim2.new(1,0,1,0)
	p.Visible = false
	p.BackgroundTransparency = 1
	pages[name] = p
	return p
end

local info = makePage("INFO")
local set = makePage("SETTINGS")
local fam = makePage("FAM")
local misc = makePage("MISC")
local vis = makePage("VISUAL")

info.Visible = true

--//////////////////////////////////////////////////////
-- INFO TAB
--//////////////////////////////////////////////////////

local avatar = Instance.new("ImageLabel", info)
avatar.Size = UDim2.new(0,80,0,80)
avatar.Position = UDim2.new(0,10,0,10)
avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=420&height=420&format=png"

local fpsLabel = Instance.new("TextLabel", info)
fpsLabel.Position = UDim2.new(0,100,0,10)
fpsLabel.Size = UDim2.new(1,-100,0,30)
fpsLabel.Text = "FPS: ..."
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.BackgroundTransparency = 1

local timeLabel = Instance.new("TextLabel", info)
timeLabel.Position = UDim2.new(0,100,0,40)
timeLabel.Size = UDim2.new(1,-100,0,30)
timeLabel.Text = "Time: 0"
timeLabel.TextColor3 = Color3.new(1,1,1)
timeLabel.BackgroundTransparency = 1

-- FPS
local fps = 0
local last = tick()

RunService.RenderStepped:Connect(function()
	fps += 1
	if tick()-last >= 1 then
		fpsLabel.Text = "FPS: "..fps
		fps = 0
		last = tick()
	end
end)

task.spawn(function()
	local t = 0
	while task.wait(1) do
		t += 1
		timeLabel.Text = "Time: "..t
	end
end)

--//////////////////////////////////////////////////////
-- SETTINGS
--//////////////////////////////////////////////////////

local wsBtn = Instance.new("TextButton", set)
wsBtn.Size = UDim2.new(0,200,0,40)
wsBtn.Position = UDim2.new(0,10,0,10)
wsBtn.Text = "Speed 26 → 300"

wsBtn.MouseButton1Click:Connect(function()
	hum.WalkSpeed = 60
end)

local jpBtn = Instance.new("TextButton", set)
jpBtn.Size = UDim2.new(0,200,0,40)
jpBtn.Position = UDim2.new(0,10,0,60)
jpBtn.Text = "Jump Boost"

jpBtn.MouseButton1Click:Connect(function()
	hum.JumpPower = 100
end)

--//////////////////////////////////////////////////////
-- FAM (TELEPORT ZONES)
--//////////////////////////////////////////////////////

local zones = {
	{"Spawn", 50},
	{"Màn 1", 500},
	{"Màn 2", 1200},
	{"Màn 3", 1900},
	{"Màn 4", 2600},
	{"Màn 5", 3300},
	{"Màn 6", 4000},
	{"Màn 7", 4700},
	{"Màn 8", 5400},
	{"Màn 9", 6100},
	{"Màn 10", 7200},
	{"Rương", 9492}
}

for i,v in pairs(zones) do
	local b = Instance.new("TextButton", fam)
	b.Size = UDim2.new(0,200,0,30)
	b.Position = UDim2.new(0,10,0,(i-1)*35)
	b.Text = v[1]

	b.MouseButton1Click:Connect(function()
		char:MoveTo(Vector3.new(0,5,v[2]))
	end)
end

--//////////////////////////////////////////////////////
-- VISUAL
--//////////////////////////////////////////////////////

local black = Instance.new("Frame", gui)
black.Size = UDim2.new(1,0,1,0)
black.BackgroundColor3 = Color3.new(0,0,0)
black.Visible = false

local blackBtn = Instance.new("TextButton", vis)
blackBtn.Size = UDim2.new(0,200,0,40)
blackBtn.Position = UDim2.new(0,10,0,10)
blackBtn.Text = "Black Screen"

blackBtn.MouseButton1Click:Connect(function()
	black.Visible = not black.Visible
end)

--//////////////////////////////////////////////////////
-- TAB SWITCH
--//////////////////////////////////////////////////////

function show(name)
	for i,v in pairs(pages) do
		v.Visible = false
	end
	pages[name].Visible = true
end

local btns = {"INFO","SETTINGS","FAM","MISC","VISUAL"}

for i,v in pairs(btns) do
	local b = Instance.new("TextButton", tab)
	b.Size = UDim2.new(1,0,0,35)
	b.Position = UDim2.new(0,0,0,(i-1)*35)
	b.Text = v
	b.MouseButton1Click:Connect(function()
		show(v)
	end)
end

open.MouseButton1Click:Connect(function()
	main.Visible = true
end)

close.MouseButton1Click:Connect(function()
	main.Visible = false
end)
