-- ==========================================================
-- TÊN: SIMPLE HUB - SCRIPT HỖ TRỢ SPAWN VÀ LOCK POSITION
-- ==========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ==========================================================
-- BIẾN LƯU TRỮ TRẠNG THÁI (VARIABLES)
-- ==========================================================
local savedSpawnCFrame = nil
local isLocked = false
local isMenuOpen = false

-- Màu sắc chủ đạo (Dark Theme & Purple)
local COLOR_BG = Color3.fromRGB(20, 20, 20)
local COLOR_SECTION = Color3.fromRGB(30, 30, 30)
local COLOR_PURPLE = Color3.fromRGB(123, 44, 191)
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_GRAY = Color3.fromRGB(150, 150, 150)

-- ==========================================================
-- HÀM TIỆN ÍCH TẠO UI (UI BUILDER)
-- ==========================================================
local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

-- ==========================================================
-- XÂY DỰNG GIAO DIỆN (GUI CREATION)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- 1. NÚT MỞ MENU (OPEN BUTTON - TRÒN)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0.5, -25, 0, 20)
OpenButton.BackgroundColor3 = COLOR_BG
OpenButton.Text = "•••"
OpenButton.TextColor3 = COLOR_WHITE
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Parent = ScreenGui
createCorner(OpenButton, 25)

local UIStrokeBtn = Instance.new("UIStroke")
UIStrokeBtn.Color = COLOR_PURPLE
UIStrokeBtn.Thickness = 2
UIStrokeBtn.Parent = OpenButton

-- 2. KHUNG MAIN MENU (MAIN FRAME)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 380)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -190)
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.ClipsDescendants = true
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLOR_PURPLE
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Simple Hub"
Title.TextColor3 = COLOR_WHITE
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = COLOR_GRAY
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

-- Vùng chứa tính năng
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -40, 1, -60)
Content.Position = UDim2.new(0, 20, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 15)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Content

-- ==========================================================
-- HÀM TẠO CÁC HÀNG TÍNH NĂNG
-- ==========================================================
local function createFeatureRow(iconText, titleText, descText, buttonElement, layoutOrder)
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 70)
	Row.BackgroundColor3 = COLOR_SECTION
	Row.LayoutOrder = layoutOrder
	Row.Parent = Content
	createCorner(Row, 10)
	
	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(0, 40, 0, 40)
	Icon.Position = UDim2.new(0, 15, 0.5, -20)
	Icon.BackgroundColor3 = COLOR_BG
	Icon.Text = iconText
	Icon.TextSize = 20
	Icon.Parent = Row
	createCorner(Icon, 20)
	
	local LabelContainer = Instance.new("Frame")
	LabelContainer.Size = UDim2.new(1, -160, 1, 0)
	LabelContainer.Position = UDim2.new(0, 65, 0, 0)
	LabelContainer.BackgroundTransparency = 1
	LabelContainer.Parent = Row
	
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0.5, 5)
	Title.BackgroundTransparency = 1
	Title.Text = titleText
	Title.TextColor3 = COLOR_WHITE
	Title.TextSize = 16
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextYAlignment = Enum.TextYAlignment.Bottom
	Title.Parent = LabelContainer
	
	local Desc = Instance.new("TextLabel")
	Desc.Size = UDim2.new(1, 0, 0.5, -5)
	Desc.Position = UDim2.new(0, 0, 0.5, 5)
	Desc.BackgroundTransparency = 1
	Desc.Text = descText
	Desc.TextColor3 = COLOR_GRAY
	Desc.TextSize = 11
	Desc.Font = Enum.Font.Gotham
	Desc.TextWrapped = true
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.TextYAlignment = Enum.TextYAlignment.Top
	Desc.Parent = LabelContainer
	
	buttonElement.Position = UDim2.new(1, -85, 0.5, -17)
	buttonElement.Parent = Row
end

-- 3. CHỨC NĂNG: SET SPAWN
local BtnSetSpawn = Instance.new("TextButton")
BtnSetSpawn.Size = UDim2.new(0, 70, 0, 34)
BtnSetSpawn.BackgroundColor3 = COLOR_PURPLE
BtnSetSpawn.Text = "SET"
BtnSetSpawn.TextColor3 = COLOR_WHITE
BtnSetSpawn.Font = Enum.Font.GothamBold
BtnSetSpawn.TextSize = 14
createCorner(BtnSetSpawn, 6)
createFeatureRow("📍", "Set Spawn", "Đặt điểm spawn tại vị trí hiện tại", BtnSetSpawn, 1)

-- 4. CHỨC NĂNG: RESET SPAWN
local BtnResetSpawn = Instance.new("TextButton")
BtnResetSpawn.Size = UDim2.new(0, 70, 0, 34)
BtnResetSpawn.BackgroundColor3 = COLOR_PURPLE
BtnResetSpawn.Text = "RESET"
BtnResetSpawn.TextColor3 = COLOR_WHITE
BtnResetSpawn.Font = Enum.Font.GothamBold
BtnResetSpawn.TextSize = 14
createCorner(BtnResetSpawn, 6)
createFeatureRow("🔄", "Reset Spawn", "Xóa spawn đã đặt, về spawn gốc", BtnResetSpawn, 2)

-- 5. CHỨC NĂNG: LOCK POSITION (TOGGLE)
local ToggleFrame = Instance.new("TextButton")
ToggleFrame.Size = UDim2.new(0, 50, 0, 26)
ToggleFrame.BackgroundColor3 = COLOR_GRAY
ToggleFrame.Text = ""
createCorner(ToggleFrame, 13)

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
ToggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
ToggleCircle.BackgroundColor3 = COLOR_WHITE
ToggleCircle.Parent = ToggleFrame
createCorner(ToggleCircle, 10)

createFeatureRow("🔒", "Lock Position", "Khóa vị trí, không thể di chuyển, nhảy, hoặc bị đẩy", ToggleFrame, 3)

-- ==========================================================
-- HỆ THỐNG LOGIC (CORE FUNCTIONS)
-- ==========================================================
local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title;
			Text = text;
			Duration = 3;
		})
	end)
end

local function toggleMenu()
	isMenuOpen = not isMenuOpen
	if isMenuOpen then
		MainFrame.Visible = true
		local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 350, 0, 380)})
		tween:Play()
	else
		local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
		tween:Play()
		tween.Completed:Wait()
		MainFrame.Visible = false
	end
end

OpenButton.Activated:Connect(toggleMenu)
CloseButton.Activated:Connect(toggleMenu)

BtnSetSpawn.Activated:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		savedSpawnCFrame = char.HumanoidRootPart.CFrame
		notify("Simple Hub", "Spawn Saved!")
	end
end)

BtnResetSpawn.Activated:Connect(function()
	savedSpawnCFrame = nil
	notify("Simple Hub", "Spawn Reset!")
end)

local function updateLockState()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.Anchored = isLocked
	end
end

ToggleFrame.Activated:Connect(function()
	isLocked = not isLocked
	local goalColor = isLocked and COLOR_PURPLE or COLOR_GRAY
	local goalPos = isLocked and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	
	TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
	TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = goalPos}):Play()
	
	updateLockState()
end)

player.CharacterAdded:Connect(function(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local humanoid = char:WaitForChild("Humanoid", 5)
	if not hrp or not humanoid then return end
	
	task.wait(0.1)
	if savedSpawnCFrame then
		char:PivotTo(savedSpawnCFrame)
	end
	if isLocked then
		hrp.Anchored = true
	end
end)

if player.Character then
	updateLockState()
end
