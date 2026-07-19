-- ==========================================================
-- TÊN: SIMPLE HUB V2 - SPAWN, LOCK & AUTO CLICKER/PRESSER
-- PHIÊN BẢN: 1.0
-- TÁC GIẢ: 2024nam8
-- ==========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ==========================================================
-- HỆ THỐNG TRẠNG THÁI (STATE MANAGEMENT)
-- ==========================================================
local State = {
	isMenuOpen = false,
	currentTab = 1,
	
	-- Tab 1: Spawn & Lock
	spawnCFrame = nil,
	isLocked = false,
	
	-- Tab 2: Auto
	autoClickEnabled = false,
	autoEEnabled = false,
	isRunning = false,
	
	points = {}, -- Cấu trúc: {id, x, y, delay, hold, loop, mode}
	selectedPointId = nil,
	
	autoE = {
		key = Enum.KeyCode.E,
		delay = 100,
		hold = 50,
		loop = 0 -- 0 = vô hạn
	}
}

-- Tiến trình chạy nền
local clickTask = nil
local eTask = nil

-- ==========================================================
-- MÀU SẮC & GIAO DIỆN (THEME)
-- ==========================================================
local THEME = {
	Bg = Color3.fromRGB(15, 15, 18),
	Panel = Color3.fromRGB(25, 25, 30),
	Item = Color3.fromRGB(35, 35, 42),
	Purple = Color3.fromRGB(114, 47, 189),
	PurpleDark = Color3.fromRGB(75, 28, 128),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(150, 150, 150),
	Green = Color3.fromRGB(46, 204, 113),
	Red = Color3.fromRGB(231, 76, 60),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold
}

-- ==========================================================
-- HÀM TIỆN ÍCH TẠO UI (UI BUILDER)
-- ==========================================================
local UI = {}

function UI.Create(className, properties, parent)
	local inst = Instance.new(className)
	for k, v in pairs(properties) do
		inst[k] = v
	end
	if parent then inst.Parent = parent end
	return inst
end

function UI.Corner(parent, radius)
	return UI.Create("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

function UI.Stroke(parent, color, thickness)
	return UI.Create("UIStroke", {Color = color, Thickness = thickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

-- ==========================================================
-- XÂY DỰNG KHUNG GIAO DIỆN CHÍNH (MAIN GUI)
-- ==========================================================
local ScreenGui = UI.Create("ScreenGui", {Name = "SimpleHubV2", ResetOnSpawn = false}, player:WaitForChild("PlayerGui"))

-- Nút mở menu góc trái
local OpenBtn = UI.Create("TextButton", {
	Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0, 20),
	BackgroundColor3 = THEME.Bg, Text = "•••", TextColor3 = THEME.Text,
	Font = THEME.FontBold, TextSize = 20, AutoButtonColor = false
}, ScreenGui)
UI.Corner(OpenBtn, 25)
UI.Stroke(OpenBtn, THEME.Purple, 2)

-- Khung chính
local MainFrame = UI.Create("Frame", {
	Size = UDim2.new(0, 700, 0, 500), Position = UDim2.new(0.5, -350, 0.5, -250),
	BackgroundColor3 = THEME.Bg, Visible = false, ClipsDescendants = true
}, ScreenGui)
UI.Corner(MainFrame, 10)
UI.Stroke(MainFrame, THEME.Purple, 1)

-- Thanh tiêu đề
local TitleBar = UI.Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1}, MainFrame)
UI.Create("TextLabel", {
	Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0),
	BackgroundTransparency = 1, Text = "Simple Hub", TextColor3 = THEME.Text,
	Font = THEME.FontBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)

local CloseBtn = UI.Create("TextButton", {
	Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0),
	BackgroundTransparency = 1, Text = "✕", TextColor3 = THEME.TextDim,
	Font = THEME.Font, TextSize = 18
}, TitleBar)

-- Sidebar (Chứa các Tab)
local Sidebar = UI.Create("Frame", {
	Size = UDim2.new(0, 150, 1, -40), Position = UDim2.new(0, 0, 0, 40),
	BackgroundColor3 = THEME.Panel, BorderSizePixel = 0
}, MainFrame)

local Tab1Btn = UI.Create("TextButton", {
	Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 0, 10),
	BackgroundColor3 = THEME.Purple, Text = "📍 1. SPAWN
& LOCK", TextColor3 = THEME.Text,
	Font = THEME.FontBold, TextSize = 12, TextWrapped = true
}, Sidebar)
UI.Corner(Tab1Btn, 6)

local Tab2Btn = UI.Create("TextButton", {
	Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 0, 70),
	BackgroundColor3 = THEME.Item, Text = "🖱 2. AUTO CLICK
& BẤM E", TextColor3 = THEME.TextDim,
	Font = THEME.FontBold, TextSize = 12, TextWrapped = true
}, Sidebar)
UI.Corner(Tab2Btn, 6)

local FooterText = UI.Create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -30),
	BackgroundTransparency = 1, Text = "Simple Hub
v1.0", TextColor3 = THEME.TextDim,
	Font = THEME.Font, TextSize = 10
}, Sidebar)

-- Vùng nội dung Tab
local ContentArea = UI.Create("Frame", {
	Size = UDim2.new(1, -150, 1, -40), Position = UDim2.new(0, 150, 0, 40),
	BackgroundTransparency = 1
}, MainFrame)

-- ==========================================================
-- TAB 1: SPAWN & LOCK
-- ==========================================================
local Tab1Frame = UI.Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = true}, ContentArea)

local function createRow(parent, yPos, icon, title, desc, btnText)
	local row = UI.Create("Frame", {Size = UDim2.new(1, -40, 0, 70), Position = UDim2.new(0, 20, 0, yPos), BackgroundColor3 = THEME.Panel}, parent)
	UI.Corner(row, 8)
	
	UI.Create("TextLabel", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20), BackgroundTransparency = 1, Text = icon, TextSize = 20}, row)
	UI.Create("TextLabel", {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 60, 0, 15), BackgroundTransparency = 1, Text = title, TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, row)
	UI.Create("TextLabel", {Size = UDim2.new(0, 300, 0, 20), Position = UDim2.new(0, 60, 0, 35), BackgroundTransparency = 1, Text = desc, TextColor3 = THEME.TextDim, Font = THEME.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, row)
	
	local btn = UI.Create("TextButton", {Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -80, 0.5, -15), BackgroundColor3 = THEME.Purple, Text = btnText, TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 12}, row)
	UI.Corner(btn, 6)
	return btn, row
end

local SetSpawnBtn = createRow(Tab1Frame, 20, "📍", "Set Spawn", "Đặt điểm spawn tại vị trí hiện tại", "SET")
local ResetSpawnBtn = createRow(Tab1Frame, 100, "🎯", "Reset Spawn", "Xóa spawn đã đặt, về spawn gốc", "RESET")

-- Lock Toggle
local lockRow = UI.Create("Frame", {Size = UDim2.new(1, -40, 0, 70), Position = UDim2.new(0, 20, 0, 180), BackgroundColor3 = THEME.Panel}, Tab1Frame)
UI.Corner(lockRow, 8)
UI.Create("TextLabel", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20), BackgroundTransparency = 1, Text = "🔒", TextSize = 20}, lockRow)
UI.Create("TextLabel", {Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 60, 0, 15), BackgroundTransparency = 1, Text = "Lock Position", TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, lockRow)
UI.Create("TextLabel", {Size = UDim2.new(0, 300, 0, 20), Position = UDim2.new(0, 60, 0, 35), BackgroundTransparency = 1, Text = "Khóa vị trí, không thể di chuyển", TextColor3 = THEME.TextDim, Font = THEME.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, lockRow)

local LockToggle = UI.Create("TextButton", {Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(1, -70, 0.5, -13), BackgroundColor3 = THEME.Item, Text = ""}, lockRow)
UI.Corner(LockToggle, 13)
local LockCircle = UI.Create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = THEME.Text}, LockToggle)
UI.Corner(LockCircle, 10)

-- Info Box
local InfoBox = UI.Create("Frame", {Size = UDim2.new(1, -40, 0, 100), Position = UDim2.new(0, 20, 0, 270), BackgroundTransparency = 1}, Tab1Frame)
UI.Stroke(InfoBox, THEME.Panel, 2)
UI.Corner(InfoBox, 8)
UI.Create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Text = "Thông tin", TextColor3 = THEME.Purple, Font = THEME.FontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, InfoBox)

local TxtSpawnStatus = UI.Create("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 35), BackgroundTransparency = 1, Text = "• Spawn Status: CHƯA ĐẶT", TextColor3 = THEME.Text, Font = THEME.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, InfoBox)
local TxtLockStatus = UI.Create("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 55), BackgroundTransparency = 1, Text = "• Lock Status: TẮT", TextColor3 = THEME.Text, Font = THEME.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, InfoBox)
local TxtCoords = UI.Create("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 75), BackgroundTransparency = 1, Text = "• Vị trí: X: 0 | Y: 0 | Z: 0", TextColor3 = THEME.Purple, Font = THEME.FontBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, InfoBox)

-- ==========================================================
-- TAB 2: AUTO CLICK & BẤM E
-- ==========================================================
local Tab2Frame = UI.Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false}, ContentArea)

-- Header (Toggles & Start/Stop)
local Header2 = UI.Create("Frame", {Size = UDim2.new(1, -40, 0, 80), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1}, Tab2Frame)

-- Auto Click Toggle
UI.Create("TextLabel", {Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = "Auto Click", TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, Header2)
local AC_Toggle = UI.Create("TextButton", {Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(0, 100, 0, 2), BackgroundColor3 = THEME.Item, Text = ""}, Header2)
UI.Corner(AC_Toggle, 13)
local AC_Circle = UI.Create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = THEME.Text}, AC_Toggle)
UI.Corner(AC_Circle, 10)

-- Auto E Toggle
UI.Create("TextLabel", {Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0, 200, 0, 0), BackgroundTransparency = 1, Text = "Bấm E (Auto E)", TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, Header2)
local AE_Toggle = UI.Create("TextButton", {Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(0, 320, 0, 2), BackgroundColor3 = THEME.Item, Text = ""}, Header2)
UI.Corner(AE_Toggle, 13)
local AE_Circle = UI.Create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = THEME.Text}, AE_Toggle)
UI.Corner(AE_Circle, 10)

-- Start/Stop Buttons
local StartBtn = UI.Create("TextButton", {Size = UDim2.new(0.5, -5, 0, 35), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = THEME.Purple, Text = "▶ START", TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 14}, Header2)
UI.Corner(StartBtn, 6)
local StopBtn = UI.Create("TextButton", {Size = UDim2.new(0.5, -5, 0, 35), Position = UDim2.new(0.5, 5, 0, 40), BackgroundColor3 = THEME.Item, Text = "■ STOP", TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 14}, Header2)
UI.Corner(StopBtn, 6)

-- Toolbar
local Toolbar = UI.Create("Frame", {Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0, 20, 0, 100), BackgroundTransparency = 1}, Tab2Frame)
local UIListLayoutTool = UI.Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder}, Toolbar)

local function createToolBtn(text, color, order)
	local btn = UI.Create("TextButton", {Size = UDim2.new(0, 90, 1, 0), BackgroundColor3 = color, Text = text, TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 11, LayoutOrder = order}, Toolbar)
	UI.Corner(btn, 4)
	return btn
end

local AddPointBtn = createToolBtn("+ THÊM ĐIỂM", THEME.Panel, 1)
local ClearBtn = createToolBtn("🗑 XÓA TẤT CẢ", Color3.fromRGB(150, 40, 40), 2)
local SaveBtn = createToolBtn("💾 LƯU", THEME.Panel, 3)
local LoadBtn = createToolBtn("📂 TẢI", THEME.Panel, 4)
local ResetBtn = createToolBtn("🔄 RESET", THEME.Panel, 5)

-- Hai cột chính
local MainArea = UI.Create("Frame", {Size = UDim2.new(1, -40, 1, -150), Position = UDim2.new(0, 20, 0, 140), BackgroundTransparency = 1}, Tab2Frame)

-- Cột Trái (Danh sách điểm)
local ListPanel = UI.Create("ScrollingFrame", {Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, ScrollBarThickness = 4}, MainArea)
UI.Corner(ListPanel, 6)
local ListLayout = UI.Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, ListPanel)

-- Cột Phải (Thiết lập điểm)
local SettingsPanel = UI.Create("Frame", {Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), BackgroundColor3 = THEME.Panel}, MainArea)
UI.Corner(SettingsPanel, 6)

UI.Create("TextLabel", {Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = "THIẾT LẬP ĐIỂM BẤM", TextColor3 = THEME.Purple, Font = THEME.FontBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, SettingsPanel)

local function createSettingInput(parent, yPos, labelText, defaultVal)
	UI.Create("TextLabel", {Size = UDim2.new(0, 120, 0, 25), Position = UDim2.new(0, 10, 0, yPos), BackgroundTransparency = 1, Text = labelText, TextColor3 = THEME.Text, Font = THEME.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, parent)
	local box = UI.Create("TextBox", {Size = UDim2.new(0, 60, 0, 25), Position = UDim2.new(1, -70, 0, yPos), BackgroundColor3 = THEME.Item, Text = tostring(defaultVal), TextColor3 = THEME.Text, Font = THEME.Font, TextSize = 11}, parent)
	UI.Corner(box, 4)
	return box
end

local SetX = createSettingInput(SettingsPanel, 35, "Vị trí X", 0)
local SetY = createSettingInput(SettingsPanel, 65, "Vị trí Y", 0)
local SetDelay = createSettingInput(SettingsPanel, 95, "Delay (ms) (1-10000)", 100)
local SetHold = createSettingInput(SettingsPanel, 125, "Hold Time (ms)", 50)
local SetLoop = createSettingInput(SettingsPanel, 155, "Số lần lặp (0=Vô hạn)", 1)

local SavePointBtn = UI.Create("TextButton", {Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 1, -40), BackgroundColor3 = THEME.Purple, Text = "LƯU THAY ĐỔI", TextColor3 = THEME.Text, Font = THEME.FontBold, TextSize = 12}, SettingsPanel)
UI.Corner(SavePointBtn, 6)

-- Bảng phụ: Auto E Settings
local AutoEPanel = UI.Create("Frame", {Size = UDim2.new(1, -40, 0, 100), Position = UDim2.new(0, 20, 1, -110), BackgroundColor3 = THEME.Panel, Visible = false}, Tab2Frame)
UI.Corner(AutoEPanel, 6)
UI.Create("TextLabel", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = "BẤM E (AUTO E)", TextColor3 = THEME.Purple, Font = THEME.FontBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, AutoEPanel)
local E_Delay = createSettingInput(AutoEPanel, 30, "Thời gian giữa mỗi lần (ms)", 100)
local E_Hold = createSettingInput(AutoEPanel, 60, "Thời gian giữ phím (ms)", 50)

-- ==========================================================
-- HỆ THỐNG LOGIC (CORE FUNCTIONS)
-- ==========================================================

-- Chuyển Tab
local function switchTab(tabIndex)
	State.currentTab = tabIndex
	Tab1Frame.Visible = (tabIndex == 1)
	Tab2Frame.Visible = (tabIndex == 2)
	
	Tab1Btn.BackgroundColor3 = (tabIndex == 1) and THEME.Purple or THEME.Item
	Tab1Btn.TextColor3 = (tabIndex == 1) and THEME.Text or THEME.TextDim
	Tab2Btn.BackgroundColor3 = (tabIndex == 2) and THEME.Purple or THEME.Item
	Tab2Btn.TextColor3 = (tabIndex == 2) and THEME.Text or THEME.TextDim
end
Tab1Btn.Activated:Connect(function() switchTab(1) end)
Tab2Btn.Activated:Connect(function() switchTab(2) end)

-- Mở / Đóng Menu
OpenBtn.Activated:Connect(function()
	State.isMenuOpen = not State.isMenuOpen
	MainFrame.Visible = State.isMenuOpen
end)
CloseBtn.Activated:Connect(function()
	State.isMenuOpen = false
	MainFrame.Visible = false
end)

-- Tạo hiệu ứng Toggle
local function animateToggle(btn, circle, state)
	local goalColor = state and THEME.Purple or THEME.Item
	local goalPos = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
	TweenService:Create(circle, TweenInfo.new(0.2), {Position = goalPos}):Play()
end

-- --- LOGIC TAB 1: SPAWN & LOCK ---
SetSpawnBtn.Activated:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		State.spawnCFrame = char.HumanoidRootPart.CFrame
		TxtSpawnStatus.Text = "• Spawn Status: ĐÃ ĐẶT"
		TxtSpawnStatus.TextColor3 = THEME.Green
		StarterGui:SetCore("SendNotification", {Title = "Simple Hub", Text = "Đã lưu vị trí Spawn!"})
	end
end)

ResetSpawnBtn.Activated:Connect(function()
	State.spawnCFrame = nil
	TxtSpawnStatus.Text = "• Spawn Status: CHƯA ĐẶT"
	TxtSpawnStatus.TextColor3 = THEME.Text
	StarterGui:SetCore("SendNotification", {Title = "Simple Hub", Text = "Đã xóa vị trí Spawn!"})
end)

local function updateLockState()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.Anchored = State.isLocked
	end
end

LockToggle.Activated:Connect(function()
	State.isLocked = not State.isLocked
	animateToggle(LockToggle, LockCircle, State.isLocked)
	TxtLockStatus.Text = State.isLocked and "• Lock Status: BẬT" or "• Lock Status: TẮT"
	TxtLockStatus.TextColor3 = State.isLocked and THEME.Green or THEME.Text
	updateLockState()
end)

-- Cập nhật tọa độ liên tục
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local pos = char.HumanoidRootPart.Position
		TxtCoords.Text = string.format("• Vị trí: X: %d | Y: %d | Z: %d", pos.X, pos.Y, pos.Z)
	end
end)

-- Xử lý khi hồi sinh
player.CharacterAdded:Connect(function(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end
	task.wait(0.1)
	if State.spawnCFrame then char:PivotTo(State.spawnCFrame) end
	if State.isLocked then hrp.Anchored = true end
end)


-- --- LOGIC TAB 2: AUTO CLICK & E ---

AC_Toggle.Activated:Connect(function()
	State.autoClickEnabled = not State.autoClickEnabled
	animateToggle(AC_Toggle, AC_Circle, State.autoClickEnabled)
end)

AE_Toggle.Activated:Connect(function()
	State.autoEEnabled = not State.autoEEnabled
	animateToggle(AE_Toggle, AE_Circle, State.autoEEnabled)
	AutoEPanel.Visible = State.autoEEnabled
end)

-- Render UI Điểm
local function refreshPointsUI()
	for _, child in ipairs(ListPanel:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	for i, pt in ipairs(State.points) do
		local frame = UI.Create("Frame", {Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = THEME.Item}, ListPanel)
		UI.Corner(frame, 4)
		if State.selectedPointId == pt.id then
			UI.Stroke(frame, THEME.Purple, 1)
		end
		
		UI.Create("TextLabel", {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = tostring(i), TextColor3 = THEME.Purple, Font = THEME.FontBold}, frame)
		UI.Create("TextLabel", {Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, Text = string.format("X:%d Y:%d", pt.x, pt.y), TextColor3 = THEME.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, frame)
		
		local editBtn = UI.Create("TextButton", {Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Text = "✏", TextColor3 = THEME.TextDim}, frame)
		
		editBtn.Activated:Connect(function()
			State.selectedPointId = pt.id
			SetX.Text = tostring(pt.x)
			SetY.Text = tostring(pt.y)
			SetDelay.Text = tostring(pt.delay)
			SetHold.Text = tostring(pt.hold)
			SetLoop.Text = tostring(pt.loop)
			refreshPointsUI()
		end)
	end
	ListPanel.CanvasSize = UDim2.new(0, 0, 0, #State.points * 45)
end

AddPointBtn.Activated:Connect(function()
	local newPt = {
		id = tick(),
		x = math.floor(mouse.X),
		y = math.floor(mouse.Y),
		delay = 100,
		hold = 50,
		loop = 1
	}
	table.insert(State.points, newPt)
	refreshPointsUI()
end)

ClearBtn.Activated:Connect(function()
	State.points = {}
	State.selectedPointId = nil
	refreshPointsUI()
end)

SavePointBtn.Activated:Connect(function()
	if not State.selectedPointId then return end
	for _, pt in ipairs(State.points) do
		if pt.id == State.selectedPointId then
			pt.x = tonumber(SetX.Text) or pt.x
			pt.y = tonumber(SetY.Text) or pt.y
			pt.delay = tonumber(SetDelay.Text) or pt.delay
			pt.hold = tonumber(SetHold.Text) or pt.hold
			pt.loop = tonumber(SetLoop.Text) or pt.loop
			break
		end
	end
	refreshPointsUI()
	StarterGui:SetCore("SendNotification", {Title = "Simple Hub", Text = "Đã lưu cấu hình điểm!"})
end)

-- LƯU TRỮ (Gỉa lập qua ReplicatedStorage Folder)
local function getSaveFolder()
	local folder = ReplicatedStorage:FindFirstChild("AutoClickHub")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AutoClickHub"
		folder.Parent = ReplicatedStorage
	end
	return folder
end

SaveBtn.Activated:Connect(function()
	local folder = getSaveFolder()
	folder:ClearAllChildren()
	for i, pt in ipairs(State.points) do
		local str = Instance.new("StringValue")
		str.Name = "Point_" .. i
		str.Value = string.format("%d,%d,%d,%d,%d", pt.x, pt.y, pt.delay, pt.hold, pt.loop)
		str.Parent = folder
	end
	StarterGui:SetCore("SendNotification", {Title = "Simple Hub", Text = "Đã lưu vào ReplicatedStorage!"})
end)

LoadBtn.Activated:Connect(function()
	local folder = ReplicatedStorage:FindFirstChild("AutoClickHub")
	if folder then
		State.points = {}
		for _, child in ipairs(folder:GetChildren()) do
			local parts = string.split(child.Value, ",")
			if #parts == 5 then
				table.insert(State.points, {
					id = tick() + math.random(),
					x = tonumber(parts[1]), y = tonumber(parts[2]),
					delay = tonumber(parts[3]), hold = tonumber(parts[4]), loop = tonumber(parts[5])
				})
			end
		end
		refreshPointsUI()
		StarterGui:SetCore("SendNotification", {Title = "Simple Hub", Text = "Đã tải cấu hình!"})
	end
end)


-- THỰC THI AUTO (VIRTUAL INPUT)
local function executeAutoClick()
	if #State.points == 0 then return end
	while State.isRunning and State.autoClickEnabled do
		for _, pt in ipairs(State.points) do
			if not State.isRunning then break end
			
			local loops = pt.loop == 0 and 999999 or pt.loop
			for l = 1, loops do
				if not State.isRunning then break end
				
				-- Giả lập click chuột trái tại toạ độ x, y
				VirtualInputManager:SendMouseButtonEvent(pt.x, pt.y, 0, true, game, 1)
				task.wait(pt.hold / 1000)
				VirtualInputManager:SendMouseButtonEvent(pt.x, pt.y, 0, false, game, 1)
				task.wait(pt.delay / 1000)
			end
		end
		task.wait(0.05)
	end
end

local function executeAutoE()
	while State.isRunning and State.autoEEnabled do
		local delayTime = (tonumber(E_Delay.Text) or 100) / 1000
		local holdTime = (tonumber(E_Hold.Text) or 50) / 1000
		
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait(holdTime)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		task.wait(delayTime)
	end
end

StartBtn.Activated:Connect(function()
	if State.isRunning then return end
	State.isRunning = true
	StartBtn.BackgroundColor3 = THEME.Panel
	StopBtn.BackgroundColor3 = THEME.Red
	
	if State.autoClickEnabled then
		clickTask = task.spawn(executeAutoClick)
	end
	if State.autoEEnabled then
		eTask = task.spawn(executeAutoE)
	end
end)

StopBtn.Activated:Connect(function()
	State.isRunning = false
	StartBtn.BackgroundColor3 = THEME.Purple
	StopBtn.BackgroundColor3 = THEME.Item
	if clickTask then task.cancel(clickTask); clickTask = nil end
	if eTask then task.cancel(eTask); eTask = nil end
end)

-- Khởi tạo ban đầu
switchTab(1)
if player.Character then updateLockState() end
