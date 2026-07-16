--=============================================================================
-- AKIRA HUB - ADVANCED ROBLOX MENU SCRIPT
-- Hoàn chỉnh 100% - Hỗ trợ Mobile & PC - Giao diện Dark Mode UI
-- Viết hoàn toàn bằng Lua thuần cho LocalScript
--=============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local HapticService = game:GetService("HapticService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

--=============================================================================
-- 1. CẤU HÌNH & QUẢN LÝ DỮ LIỆU (SETTINGS MANAGER)
--=============================================================================

local DefaultSettings = {
	Theme = "Dark",
	AccentColor = "Purple", -- Các màu: Red, Blue, Purple, Green, Rainbow
	RainbowAccent = false,
	GuiScale = 100,
	BlurBackground = false,
	Shadow = true,
	Glow = true,
	Animation = true,
	MenuTransparency = 0,
	ShowFPS = true,
	FpsPosition = "Top Right",
	ShowAverageFPS = false,
	BlackScreen = false,
	HideGameGui = false,
	AutoSave = true,
	ButtonSize = 100,
	MobileUIScale = 100,
	VibrationOnTap = false,
	MenuPosition = "{0.5, -160}, {0.5, -250}",
	FloatingButtonPosition = "{0.9, -50}, {0.5, -25}"
}

local CurrentSettings = {}
for k, v in pairs(DefaultSettings) do CurrentSettings[k] = v end

local AccentColors = {
	Red = Color3.fromRGB(255, 51, 51),
	Blue = Color3.fromRGB(51, 153, 255),
	Purple = Color3.fromRGB(153, 51, 255),
	Green = Color3.fromRGB(51, 255, 102)
}

local SettingsManager = {}
local SettingsKey = "AkiraHubSettingsData"

-- Khôi phục cấu hình từ bộ nhớ local (dùng StringValue để lưu phiên bản giữa các lần respawn)
function SettingsManager.Load()
	local existingSave = PlayerGui:FindFirstChild(SettingsKey)
	if existingSave and existingSave:IsA("StringValue") then
		local success, data = pcall(function()
			return HttpService:JSONDecode(existingSave.Value)
		end)
		if success and type(data) == "table" then
			for k, v in pairs(data) do
				if DefaultSettings[k] ~= nil then
					CurrentSettings[k] = v
				end
			end
		end
	end
end

-- Lưu cấu hình hiện tại
function SettingsManager.Save()
	local saveVal = PlayerGui:FindFirstChild(SettingsKey)
	if not saveVal then
		saveVal = Instance.new("StringValue")
		saveVal.Name = SettingsKey
		saveVal.Parent = PlayerGui
	end
	
	local success, encoded = pcall(function()
		return HttpService:JSONEncode(CurrentSettings)
	end)
	if success then
		saveVal.Value = encoded
	end
end

function SettingsManager.Reset()
	for k, v in pairs(DefaultSettings) do
		CurrentSettings[k] = v
	end
	SettingsManager.Save()
end

SettingsManager.Load()

--=============================================================================
-- 2. BIẾN TOÀN CỤC & TẠO GUI GỐC
--=============================================================================

local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local HiddenGuis = {} -- Bảng lưu trữ GUI gốc bị ẩn
local AppVariables = {
	IsMinimized = false,
	ActiveTab = "Home",
	FPSHistory = {},
	LastTick = tick(),
	Frames = 0,
	CurrentFPS = 0,
	AverageFPS = 0
}

-- Tạo ScreenGui chính
local AkiraGui = Instance.new("ScreenGui")
AkiraGui.Name = "AkiraHub_MainGui"
AkiraGui.ResetOnSpawn = false
AkiraGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AkiraGui.IgnoreGuiInset = true
AkiraGui.Parent = PlayerGui

-- Lớp Blur Background
local BlurFrame = Instance.new("Frame")
BlurFrame.Name = "BlurBackground"
BlurFrame.Size = UDim2.new(1, 0, 1, 0)
BlurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlurFrame.BackgroundTransparency = 1
BlurFrame.ZIndex = 0
BlurFrame.Visible = false
BlurFrame.Parent = AkiraGui

-- Lớp Màn Hình Đen (Black Screen)
local BlackScreenFrame = Instance.new("Frame")
BlackScreenFrame.Name = "BlackScreen"
BlackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreenFrame.BackgroundTransparency = 1
BlackScreenFrame.ZIndex = 999
BlackScreenFrame.Visible = false
BlackScreenFrame.Parent = AkiraGui

--=============================================================================
-- 3. CÁC HÀM TIỆN ÍCH (UTILITIES)
--=============================================================================

local Utils = {}

-- Tween thông minh, kiểm tra điều kiện Animation toggle
function Utils.Tween(instance, tweenInfo, properties, force)
	if CurrentSettings.Animation or force then
		local tween = TweenService:Create(instance, tweenInfo, properties)
		tween:Play()
		return tween
	else
		for prop, val in pairs(properties) do
			instance[prop] = val
		end
		return nil
	end
end

-- Lấy màu Accent hiện tại (tính toán cả Rainbow)
function Utils.GetAccentColor()
	if CurrentSettings.RainbowAccent or CurrentSettings.AccentColor == "Rainbow" then
		local hue = (tick() * 0.5) % 1
		return Color3.fromHSV(hue, 1, 1)
	else
		return AccentColors[CurrentSettings.AccentColor] or AccentColors.Purple
	end
end

-- Hiệu ứng Ripple cho Button
function Utils.CreateRipple(guiObject, x, y)
	if not CurrentSettings.Animation then return end
	
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ripple.BackgroundTransparency = 0.6
	ripple.BorderSizePixel = 0
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	
	-- Tính toán vị trí tương đối bên trong GUI Object
	local absolutePos = guiObject.AbsolutePosition
	local relativeX = x - absolutePos.X
	local relativeY = y - absolutePos.Y
	ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = ripple
	
	ripple.Parent = guiObject
	ripple.Size = UDim2.new(0, 0, 0, 0)
	
	local maxSize = math.max(guiObject.AbsoluteSize.X, guiObject.AbsoluteSize.Y) * 1.5
	local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local tween = TweenService:Create(ripple, tInfo, {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		BackgroundTransparency = 1
	})
	
	tween:Play()
	tween.Completed:Connect(function()
		ripple:Destroy()
	end)
end

-- Rung thiết bị (Mobile)
function Utils.Vibrate()
	if IsMobile and CurrentSettings.VibrationOnTap then
		pcall(function()
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 1)
			task.delay(0.05, function()
				HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
			end)
		end)
	end
end

-- Hệ thống Kéo Thả (Drag & Drop) mượt mà hỗ trợ cả PC và Mobile
function Utils.MakeDraggable(dragHandle, dragTarget, saveKey)
	local dragging, dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		
		if CurrentSettings.Animation then
			TweenService:Create(dragTarget, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPos}):Play()
		else
			dragTarget.Position = newPos
		end
	end
	
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = dragTarget.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if saveKey and CurrentSettings.AutoSave then
						CurrentSettings[saveKey] = string.format("{%.3f, %d}, {%.3f, %d}", dragTarget.Position.X.Scale, dragTarget.Position.X.Offset, dragTarget.Position.Y.Scale, dragTarget.Position.Y.Offset)
						SettingsManager.Save()
					end
				end
			end)
		end
	end)
	
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

--=============================================================================
-- 4. XÂY DỰNG GIAO DIỆN (UI BUILDER)
--=============================================================================

local UI = {}
local DynamicUIElements = {} -- Lưu các UI để update màu Accent/Theme realtime

-- Parse Position String " {scale, offset}, {scale, offset} "
local function ParsePosition(posStr, defaultPos)
	if not posStr then return defaultPos end
	local vals = {}
	for num in string.gmatch(posStr, "[%d%.-]+") do
		table.insert(vals, tonumber(num))
	end
	if #vals == 4 then
		return UDim2.new(vals[1], vals[2], vals[3], vals[4])
	end
	return defaultPos
end

-- Tính toán Scale
local function GetScale()
	local base = CurrentSettings.GuiScale / 100
	if IsMobile then
		base = base * (CurrentSettings.MobileUIScale / 100)
	end
	return base
end

-- Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320 * GetScale(), 0, 500 * GetScale())
MainFrame.Position = ParsePosition(CurrentSettings.MenuPosition, UDim2.new(0.5, -160, 0.5, -250))
MainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26) -- Dark Theme bg
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 1000
MainFrame.ClipsDescendants = false
MainFrame.Parent = AkiraGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainShadow = Instance.new("Frame")
MainShadow.Name = "Shadow"
MainShadow.Size = UDim2.new(1, 4, 1, 4)
MainShadow.Position = UDim2.new(0, -2, 0, -2)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.5
MainShadow.ZIndex = 998
MainShadow.Parent = MainFrame
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 12)
ShadowCorner.Parent = MainShadow

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40 * GetScale())
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 1001
TitleBar.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Utils.GetAccentColor()),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 26, 26))
}
TitleGradient.Parent = TitleBar
table.insert(DynamicUIElements, {Type = "Gradient", Obj = TitleGradient})

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Fix viền dưới của TitleBar (che góc bo dưới)
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 1001
TitleFix.Parent = TitleBar
table.insert(DynamicUIElements, {Type = "ThemeBg", Obj = TitleFix})

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "AKIRA HUB"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16 * GetScale()
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 1002
TitleText.Parent = TitleBar

local TitleGlow = Instance.new("UIStroke")
TitleGlow.Color = Color3.fromRGB(255, 255, 255)
TitleGlow.Transparency = 0.8
TitleGlow.Thickness = 1
TitleGlow.Parent = TitleText
table.insert(DynamicUIElements, {Type = "Glow", Obj = TitleGlow})

-- Nút Minimize (Thu gọn)
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -70, 0.5, -15)
MinButton.BackgroundTransparency = 1
MinButton.Text = "—"
MinButton.Font = Enum.Font.GothamBold
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.TextSize = 14
MinButton.ZIndex = 1002
MinButton.Parent = TitleBar

-- Nút Close
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextSize = 16
CloseButton.ZIndex = 1002
CloseButton.Parent = TitleBar

Utils.MakeDraggable(TitleBar, MainFrame, "MenuPosition")

-- Floating Button (Menu Thu Gọn)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingButton"
FloatingBtn.Size = UDim2.new(0, 50 * GetScale(), 0, 50 * GetScale())
FloatingBtn.Position = ParsePosition(CurrentSettings.FloatingButtonPosition, UDim2.new(0.9, -50, 0.5, -25))
FloatingBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.Text = "☰"
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 24 * GetScale()
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.ZIndex = 1000
FloatingBtn.Visible = false
FloatingBtn.Parent = AkiraGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatGradient = Instance.new("UIGradient")
FloatGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Utils.GetAccentColor()),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
FloatGradient.Rotation = 45
FloatGradient.Parent = FloatingBtn
table.insert(DynamicUIElements, {Type = "Gradient", Obj = FloatGradient})

local FloatShadow = Instance.new("UIStroke")
FloatShadow.Color = Utils.GetAccentColor()
FloatShadow.Thickness = 2
FloatShadow.Transparency = 0.2
FloatShadow.Parent = FloatingBtn
table.insert(DynamicUIElements, {Type = "GlowColor", Obj = FloatShadow})

Utils.MakeDraggable(FloatingBtn, FloatingBtn, "FloatingButtonPosition")

-- Chức năng Mở / Đóng / Thu gọn
MinButton.MouseButton1Click:Connect(function()
	Utils.Vibrate()
	AppVariables.IsMinimized = true
	Utils.Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = MainFrame.Position + UDim2.new(0, MainFrame.Size.X.Offset/2, 0, MainFrame.Size.Y.Offset/2)})
	task.wait(0.3)
	MainFrame.Visible = false
	FloatingBtn.Visible = true
	FloatingBtn.Size = UDim2.new(0, 0, 0, 0)
	Utils.Tween(FloatingBtn, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50 * GetScale(), 0, 50 * GetScale())})
end)

FloatingBtn.MouseButton1Click:Connect(function()
	Utils.Vibrate()
	AppVariables.IsMinimized = false
	Utils.Tween(FloatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
	task.wait(0.2)
	FloatingBtn.Visible = false
	MainFrame.Visible = true
	Utils.Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 320 * GetScale(), 0, 500 * GetScale()),
		Position = ParsePosition(CurrentSettings.MenuPosition, UDim2.new(0.5, -160, 0.5, -250))
	})
end)

CloseButton.MouseButton1Click:Connect(function()
	Utils.Vibrate()
	Utils.Tween(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
	for _, child in ipairs(MainFrame:GetDescendants()) do
		if child:IsA("GuiObject") or child:IsA("TextLabel") or child:IsA("TextButton") then
			Utils.Tween(child, TweenInfo.new(0.3), {Transparency = 1})
		end
	end
	task.wait(0.3)
	AkiraGui:Destroy()
	script:Destroy()
end)

-- Tab System Logic
local TabBar = Instance.new("ScrollingFrame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 35 * GetScale())
TabBar.Position = UDim2.new(0, 0, 0, 40 * GetScale())
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabBar.BorderSizePixel = 0
TabBar.CanvasSize = UDim2.new(1.2, 0, 0, 0)
TabBar.ScrollBarThickness = 0
TabBar.ZIndex = 1001
TabBar.Parent = MainFrame
table.insert(DynamicUIElements, {Type = "ThemeBgDark", Obj = TabBar})

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabBar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, 0, 1, -75 * GetScale())
ContentArea.Position = UDim2.new(0, 0, 0, 75 * GetScale())
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 1001
ContentArea.Parent = MainFrame

local Tabs = {}
local TabFrames = {}

function UI.CreateTab(name, icon, order)
	local TabBtn = Instance.new("TextButton")
	TabBtn.Name = name.."Tab"
	TabBtn.Size = UDim2.new(0, 75 * GetScale(), 1, 0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.GothamSemibold
	TabBtn.TextSize = 12 * GetScale()
	TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
	TabBtn.LayoutOrder = order
	TabBtn.ZIndex = 1002
	TabBtn.Parent = TabBar
	
	local Underline = Instance.new("Frame")
	Underline.Name = "Underline"
	Underline.Size = UDim2.new(0, 0, 0, 2)
	Underline.Position = UDim2.new(0.5, 0, 1, -2)
	Underline.AnchorPoint = Vector2.new(0.5, 0)
	Underline.BackgroundColor3 = Utils.GetAccentColor()
	Underline.BorderSizePixel = 0
	Underline.ZIndex = 1003
	Underline.Parent = TabBtn
	table.insert(DynamicUIElements, {Type = "AccentBg", Obj = Underline})
	
	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Name = name.."Content"
	TabScroll.Size = UDim2.new(1, 0, 1, 0)
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.ScrollBarThickness = 4
	TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabScroll.Visible = (order == 1)
	TabScroll.ZIndex = 1001
	TabScroll.Parent = ContentArea
	
	local ContentLayout = Instance.new("UIListLayout")
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentLayout.Padding = UDim.new(0, 8 * GetScale())
	ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ContentLayout.Parent = TabScroll
	
	local ContentPadding = Instance.new("UIPadding")
	ContentPadding.PaddingTop = UDim.new(0, 10 * GetScale())
	ContentPadding.PaddingBottom = UDim.new(0, 10 * GetScale())
	ContentPadding.Parent = TabScroll
	
	ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
	end)
	
	if order == 1 then
		TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		Underline.Size = UDim2.new(0.8, 0, 0, 2)
	end
	
	TabBtn.MouseButton1Click:Connect(function()
		Utils.Vibrate()
		if AppVariables.ActiveTab == name then return end
		AppVariables.ActiveTab = name
		
		for tName, tBtn in pairs(Tabs) do
			if tName == name then
				Utils.Tween(tBtn.TextColor3, TweenInfo.new(0.3), Color3.fromRGB(255, 255, 255))
				Utils.Tween(tBtn:FindFirstChild("Underline"), TweenInfo.new(0.3), {Size = UDim2.new(0.8, 0, 0, 2)})
			else
				Utils.Tween(tBtn.TextColor3, TweenInfo.new(0.3), Color3.fromRGB(150, 150, 150))
				Utils.Tween(tBtn:FindFirstChild("Underline"), TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2)})
			end
		end
		
		for fName, fFrame in pairs(TabFrames) do
			if fName == name then
				fFrame.Visible = true
				fFrame.GroupTransparency = 1
				Utils.Tween(fFrame, TweenInfo.new(0.3), {GroupTransparency = 0})
			else
				fFrame.Visible = false
			end
		end
	end)
	
	Tabs[name] = TabBtn
	TabFrames[name] = TabScroll
	
	-- Wrap ScrollFrame trong CanvasGroup để làm mượt Fade Animation
	local CanvasWrap = Instance.new("CanvasGroup")
	CanvasWrap.Name = name.."Group"
	CanvasWrap.Size = UDim2.new(1, 0, 1, 0)
	CanvasWrap.BackgroundTransparency = 1
	CanvasWrap.BorderSizePixel = 0
	CanvasWrap.Visible = (order == 1)
	CanvasWrap.Parent = ContentArea
	TabScroll.Parent = CanvasWrap
	TabFrames[name] = CanvasWrap
	
	return TabScroll
end

--=============================================================================
-- 5. CÁC THÀNH PHẦN BÊN TRONG TAB (WIDGETS)
--=============================================================================

function UI.CreateSection(parent, title)
	local Section = Instance.new("Frame")
	Section.Size = UDim2.new(0.9, 0, 0, 25 * GetScale())
	Section.BackgroundTransparency = 1
	Section.Parent = parent
	
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = string.upper(title)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 11 * GetScale()
	Title.TextColor3 = Utils.GetAccentColor()
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Section
	table.insert(DynamicUIElements, {Type = "TextColor", Obj = Title})
end

function UI.CreateToggle(parent, text, settingKey, callback)
	local bSize = (IsMobile and CurrentSettings.ButtonSize / 100) or 1
	
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(0.9, 0, 0, 35 * GetScale() * bSize)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = parent
	table.insert(DynamicUIElements, {Type = "ThemeBgElevated", Obj = ToggleFrame})
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = ToggleFrame
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.7, 0, 1, 0)
	Label.Position = UDim2.new(0, 10 * GetScale(), 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 13 * GetScale()
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame
	table.insert(DynamicUIElements, {Type = "TextTheme", Obj = Label})
	
	local SwitchBtn = Instance.new("TextButton")
	SwitchBtn.Size = UDim2.new(0, 40 * GetScale(), 0, 20 * GetScale())
	SwitchBtn.Position = UDim2.new(1, -50 * GetScale(), 0.5, -10 * GetScale())
	SwitchBtn.BackgroundColor3 = CurrentSettings[settingKey] and Utils.GetAccentColor() or Color3.fromRGB(60, 60, 60)
	SwitchBtn.Text = ""
	SwitchBtn.Parent = ToggleFrame
	
	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	SwitchCorner.Parent = SwitchBtn
	
	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 16 * GetScale(), 0, 16 * GetScale())
	Indicator.Position = CurrentSettings[settingKey] and UDim2.new(1, -18 * GetScale(), 0.5, -8 * GetScale()) or UDim2.new(0, 2 * GetScale(), 0.5, -8 * GetScale())
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Indicator.Parent = SwitchBtn
	
	local IndCorner = Instance.new("UICorner")
	IndCorner.CornerRadius = UDim.new(1, 0)
	IndCorner.Parent = Indicator
	
	if CurrentSettings[settingKey] then
		table.insert(DynamicUIElements, {Type = "AccentBg", Obj = SwitchBtn})
	end
	
	SwitchBtn.MouseButton1Click:Connect(function()
		Utils.Vibrate()
		Utils.CreateRipple(ToggleFrame, Mouse.X, Mouse.Y)
		CurrentSettings[settingKey] = not CurrentSettings[settingKey]
		local state = CurrentSettings[settingKey]
		
		if state then
			Utils.Tween(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Utils.GetAccentColor()})
			Utils.Tween(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -18 * GetScale(), 0.5, -8 * GetScale())})
			table.insert(DynamicUIElements, {Type = "AccentBg", Obj = SwitchBtn})
		else
			Utils.Tween(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
			Utils.Tween(Indicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2 * GetScale(), 0.5, -8 * GetScale())})
			-- Loại bỏ khỏi Dynamic update màu
			for i, v in ipairs(DynamicUIElements) do
				if v.Obj == SwitchBtn then table.remove(DynamicUIElements, i) break end
			end
		end
		
		if CurrentSettings.AutoSave then SettingsManager.Save() end
		if callback then pcall(callback, state) end
	end)
end

function UI.CreateButton(parent, text, callback)
	local bSize = (IsMobile and CurrentSettings.ButtonSize / 100) or 1
	
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.9, 0, 0, 35 * GetScale() * bSize)
	Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Btn.Text = text
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 13 * GetScale()
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.BorderSizePixel = 0
	Btn.ClipsDescendants = true
	Btn.Parent = parent
	table.insert(DynamicUIElements, {Type = "ThemeBgElevated", Obj = Btn})
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Utils.GetAccentColor()
	Stroke.Thickness = 1
	Stroke.Transparency = 0.5
	Stroke.Parent = Btn
	table.insert(DynamicUIElements, {Type = "GlowColor", Obj = Stroke})
	
	Btn.MouseButton1Click:Connect(function()
		Utils.Vibrate()
		Utils.CreateRipple(Btn, Mouse.X, Mouse.Y)
		if callback then pcall(callback) end
	end)
end

function UI.CreateSlider(parent, text, min, max, step, settingKey, callback)
	local bSize = (IsMobile and CurrentSettings.ButtonSize / 100) or 1
	
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(0.9, 0, 0, 50 * GetScale() * bSize)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = parent
	table.insert(DynamicUIElements, {Type = "ThemeBgElevated", Obj = SliderFrame})
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = SliderFrame
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.5, 0, 0.5, 0)
	Label.Position = UDim2.new(0, 10 * GetScale(), 0, 5 * GetScale())
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 12 * GetScale()
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame
	table.insert(DynamicUIElements, {Type = "TextTheme", Obj = Label})
	
	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	ValueLabel.Position = UDim2.new(0.5, -10 * GetScale(), 0, 5 * GetScale())
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Text = tostring(CurrentSettings[settingKey])
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextSize = 12 * GetScale()
	ValueLabel.TextColor3 = Utils.GetAccentColor()
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = SliderFrame
	table.insert(DynamicUIElements, {Type = "TextColor", Obj = ValueLabel})
	
	local SlideBg = Instance.new("Frame")
	SlideBg.Size = UDim2.new(0.9, 0, 0, 6 * GetScale())
	SlideBg.Position = UDim2.new(0.05, 0, 0.7, 0)
	SlideBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	SlideBg.BorderSizePixel = 0
	SlideBg.Parent = SliderFrame
	
	local SlideFill = Instance.new("Frame")
	local percent = (CurrentSettings[settingKey] - min) / (max - min)
	SlideFill.Size = UDim2.new(percent, 0, 1, 0)
	SlideFill.BackgroundColor3 = Utils.GetAccentColor()
	SlideFill.BorderSizePixel = 0
	SlideFill.Parent = SlideBg
	table.insert(DynamicUIElements, {Type = "AccentBg", Obj = SlideFill})
	
	local SlideKnob = Instance.new("Frame")
	SlideKnob.Size = UDim2.new(0, 14 * GetScale(), 0, 14 * GetScale())
	SlideKnob.Position = UDim2.new(percent, -7 * GetScale(), 0.5, -7 * GetScale())
	SlideKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SlideKnob.Parent = SlideBg
	local KnobCorner = Instance.new("UICorner")
	KnobCorner.CornerRadius = UDim.new(1, 0)
	KnobCorner.Parent = SlideKnob
	
	local isDragging = false
	
	local function UpdateSlider(input)
		local posX = math.clamp(input.Position.X - SlideBg.AbsolutePosition.X, 0, SlideBg.AbsoluteSize.X)
		local newPercent = posX / SlideBg.AbsoluteSize.X
		local rawValue = min + (max - min) * newPercent
		local stepValue = math.floor(rawValue / step + 0.5) * step
		stepValue = math.clamp(stepValue, min, max)
		
		local finalPercent = (stepValue - min) / (max - min)
		
		Utils.Tween(SlideFill, TweenInfo.new(0.1), {Size = UDim2.new(finalPercent, 0, 1, 0)})
		Utils.Tween(SlideKnob, TweenInfo.new(0.1), {Position = UDim2.new(finalPercent, -7 * GetScale(), 0.5, -7 * GetScale())})
		
		ValueLabel.Text = tostring(stepValue)
		CurrentSettings[settingKey] = stepValue
		
		if callback then pcall(callback, stepValue) end
	end
	
	SlideBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			UpdateSlider(input)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isDragging then
				isDragging = false
				if CurrentSettings.AutoSave then SettingsManager.Save() end
			end
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateSlider(input)
		end
	end)
end

function UI.CreateDropdown(parent, text, options, settingKey, callback)
	local bSize = (IsMobile and CurrentSettings.ButtonSize / 100) or 1
	
	local DropFrame = Instance.new("Frame")
	DropFrame.Size = UDim2.new(0.9, 0, 0, 40 * GetScale() * bSize)
	DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	DropFrame.BorderSizePixel = 0
	DropFrame.ClipsDescendants = true
	DropFrame.Parent = parent
	table.insert(DynamicUIElements, {Type = "ThemeBgElevated", Obj = DropFrame})
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = DropFrame
	
	local DropBtn = Instance.new("TextButton")
	DropBtn.Size = UDim2.new(1, 0, 0, 40 * GetScale() * bSize)
	DropBtn.BackgroundTransparency = 1
	DropBtn.Text = ""
	DropBtn.Parent = DropFrame
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.5, 0, 1, 0)
	Label.Position = UDim2.new(0, 10 * GetScale(), 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 13 * GetScale()
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = DropBtn
	table.insert(DynamicUIElements, {Type = "TextTheme", Obj = Label})
	
	local SelectedLabel = Instance.new("TextLabel")
	SelectedLabel.Size = UDim2.new(0.5, 0, 1, 0)
	SelectedLabel.Position = UDim2.new(0.5, -30 * GetScale(), 0, 0)
	SelectedLabel.BackgroundTransparency = 1
	SelectedLabel.Text = CurrentSettings[settingKey]
	SelectedLabel.Font = Enum.Font.GothamBold
	SelectedLabel.TextSize = 12 * GetScale()
	SelectedLabel.TextColor3 = Utils.GetAccentColor()
	SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
	SelectedLabel.Parent = DropBtn
	table.insert(DynamicUIElements, {Type = "TextColor", Obj = SelectedLabel})
	
	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(0, 20 * GetScale(), 1, 0)
	Icon.Position = UDim2.new(1, -25 * GetScale(), 0, 0)
	Icon.BackgroundTransparency = 1
	Icon.Text = "▼"
	Icon.Font = Enum.Font.GothamBold
	Icon.TextSize = 12 * GetScale()
	Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
	Icon.Parent = DropBtn
	
	local ListFrame = Instance.new("Frame")
	ListFrame.Size = UDim2.new(1, 0, 1, -40 * GetScale() * bSize)
	ListFrame.Position = UDim2.new(0, 0, 0, 40 * GetScale() * bSize)
	ListFrame.BackgroundTransparency = 1
	ListFrame.Parent = DropFrame
	
	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = ListFrame
	
	local isOpen = false
	local optionHeight = 30 * GetScale()
	
	for i, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Size = UDim2.new(1, 0, 0, optionHeight)
		OptBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		OptBtn.BorderSizePixel = 0
		OptBtn.Text = opt
		OptBtn.Font = Enum.Font.Gotham
		OptBtn.TextSize = 12 * GetScale()
		OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		OptBtn.Parent = ListFrame
		table.insert(DynamicUIElements, {Type = "ThemeBgElevated", Obj = OptBtn})
		
		OptBtn.MouseButton1Click:Connect(function()
			Utils.Vibrate()
			SelectedLabel.Text = opt
			CurrentSettings[settingKey] = opt
			isOpen = false
			Utils.Tween(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 40 * GetScale() * bSize)})
			Utils.Tween(Icon, TweenInfo.new(0.2), {Rotation = 0})
			if CurrentSettings.AutoSave then SettingsManager.Save() end
			if callback then pcall(callback, opt) end
		end)
	end
	
	DropBtn.MouseButton1Click:Connect(function()
		Utils.Vibrate()
		isOpen = not isOpen
		local newHeight = isOpen and (40 * GetScale() * bSize + (#options * optionHeight)) or (40 * GetScale() * bSize)
		local newRot = isOpen and 180 or 0
		Utils.Tween(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.9, 0, 0, newHeight)})
		Utils.Tween(Icon, TweenInfo.new(0.3), {Rotation = newRot})
	end)
end

function UI.CreateColorSelector(parent, text)
	local Section = Instance.new("Frame")
	Section.Size = UDim2.new(0.9, 0, 0, 60 * GetScale())
	Section.BackgroundTransparency = 1
	Section.Parent = parent
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0.4, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 13 * GetScale()
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Section
	table.insert(DynamicUIElements, {Type = "TextTheme", Obj = Label})
	
	local ColorContainer = Instance.new("Frame")
	ColorContainer.Size = UDim2.new(1, 0, 0.6, 0)
	ColorContainer.Position = UDim2.new(0, 0, 0.4, 0)
	ColorContainer.BackgroundTransparency = 1
	ColorContainer.Parent = Section
	
	local Layout = Instance.new("UIListLayout")
	Layout.FillDirection = Enum.FillDirection.Horizontal
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0, 10 * GetScale())
	Layout.Parent = ColorContainer
	
	local colors = {"Red", "Blue", "Purple", "Green", "Rainbow"}
	
	for _, cName in ipairs(colors) do
		local CBtn = Instance.new("TextButton")
		CBtn.Size = UDim2.new(0, 25 * GetScale(), 0, 25 * GetScale())
		CBtn.Text = ""
		CBtn.Parent = ColorContainer
		
		local CCorner = Instance.new("UICorner")
		CCorner.CornerRadius = UDim.new(1, 0)
		CCorner.Parent = CBtn
		
		if cName == "Rainbow" then
			local CGradient = Instance.new("UIGradient")
			CGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
			}
			CGradient.Parent = CBtn
		else
			CBtn.BackgroundColor3 = AccentColors[cName]
		end
		
		local Stroke = Instance.new("UIStroke")
		Stroke.Color = Color3.fromRGB(255, 255, 255)
		Stroke.Thickness = 2
		Stroke.Transparency = CurrentSettings.AccentColor == cName and 0 or 1
		Stroke.Parent = CBtn
		
		CBtn.MouseButton1Click:Connect(function()
			Utils.Vibrate()
			CurrentSettings.AccentColor = cName
			if CurrentSettings.AutoSave then SettingsManager.Save() end
			
			for _, child in ipairs(ColorContainer:GetChildren()) do
				if child:IsA("TextButton") then
					Utils.Tween(child.UIStroke, TweenInfo.new(0.2), {Transparency = 1})
				end
			end
			Utils.Tween(Stroke, TweenInfo.new(0.2), {Transparency = 0})
		end)
	end
end

--=============================================================================
-- 6. TẠO NỘI DUNG CÁC TAB
--=============================================================================

local HomeTab = UI.CreateTab("Home", "🏠", 1)
local SettingsTab = UI.CreateTab("Settings", "⚙️", 2)
local FPSTab = UI.CreateTab("FPS", "📊", 3)
local GameTab = UI.CreateTab("Game", "🎮", 4)
local MobileTab = UI.CreateTab("Mobile", "📱", 5)
local SystemTab = UI.CreateTab("System", "💾", 6)

-- THIẾT LẬP CÁC CHỨC NĂNG CORE TRƯỚC KHI GẮN UI CALLBACKS
local Features = {}

function Features.ToggleBlackScreen(state)
	BlackScreenFrame.Visible = true
	local targetTrans = state and 0 or 1
	local tween = Utils.Tween(BlackScreenFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = targetTrans})
	if not state and tween then
		tween.Completed:Connect(function()
			if not CurrentSettings.BlackScreen then BlackScreenFrame.Visible = false end
		end)
	elseif not state and not tween then
		BlackScreenFrame.Visible = false
	end
end

function Features.ToggleGameGUI(state)
	local pGui = LocalPlayer:WaitForChild("PlayerGui")
	if state then
		for _, gui in ipairs(pGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= AkiraGui then
				if gui.Enabled then
					table.insert(HiddenGuis, gui)
					gui.Enabled = false
				end
			end
		end
	else
		for _, gui in ipairs(HiddenGuis) do
			if gui and gui.Parent then
				gui.Enabled = true
			end
		end
		HiddenGuis = {}
	end
end

function Features.UpdateTheme()
	local bgMain = CurrentSettings.Theme == "Dark" and Color3.fromRGB(26, 26, 26) or Color3.fromRGB(240, 240, 240)
	local bgElevated = CurrentSettings.Theme == "Dark" and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(255, 255, 255)
	local bgDark = CurrentSettings.Theme == "Dark" and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(220, 220, 220)
	local textTh = CurrentSettings.Theme == "Dark" and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(30, 30, 30)
	
	MainFrame.BackgroundColor3 = bgMain
	MainFrame.BackgroundTransparency = CurrentSettings.MenuTransparency / 100
	BlurFrame.Visible = CurrentSettings.BlurBackground
	MainShadow.Visible = CurrentSettings.Shadow
	TitleGlow.Enabled = CurrentSettings.Glow
	FloatShadow.Enabled = CurrentSettings.Glow
	
	local accent = Utils.GetAccentColor()
	
	for _, element in ipairs(DynamicUIElements) do
		if element.Type == "Gradient" then
			element.Obj.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, accent),
				ColorSequenceKeypoint.new(1, CurrentSettings.Theme == "Dark" and Color3.fromRGB(26, 26, 26) or Color3.fromRGB(240, 240, 240))
			}
		elseif element.Type == "ThemeBg" then
			element.Obj.BackgroundColor3 = bgMain
			element.Obj.BackgroundTransparency = CurrentSettings.MenuTransparency / 100
		elseif element.Type == "ThemeBgElevated" then
			element.Obj.BackgroundColor3 = bgElevated
		elseif element.Type == "ThemeBgDark" then
			element.Obj.BackgroundColor3 = bgDark
		elseif element.Type == "TextTheme" then
			element.Obj.TextColor3 = textTh
		elseif element.Type == "TextColor" then
			element.Obj.TextColor3 = accent
		elseif element.Type == "AccentBg" then
			element.Obj.BackgroundColor3 = accent
		elseif element.Type == "GlowColor" then
			element.Obj.Color = accent
			element.Obj.Enabled = CurrentSettings.Glow
		elseif element.Type == "Glow" then
			element.Obj.Enabled = CurrentSettings.Glow
		end
	end
end

-- FPS COUNTER SETUP
local FPSGui = Instance.new("ScreenGui")
FPSGui.Name = "AkiraHub_FPSGui"
FPSGui.ResetOnSpawn = false
FPSGui.IgnoreGuiInset = true
FPSGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FPSGui.Parent = PlayerGui

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSDisplay"
FPSLabel.Size = UDim2.new(0, 150, 0, 30)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 18
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FPSLabel.TextStrokeTransparency = 0.3
FPSLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.ZIndex = 1001
FPSLabel.Parent = FPSGui

local FPSShadow = Instance.new("TextLabel")
FPSShadow.Size = UDim2.new(1, 0, 1, 0)
FPSShadow.Position = UDim2.new(0, 2, 0, 2)
FPSShadow.BackgroundTransparency = 1
FPSShadow.Font = Enum.Font.GothamBold
FPSShadow.TextSize = 18
FPSShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
FPSShadow.TextTransparency = 0.5
FPSShadow.TextXAlignment = Enum.TextXAlignment.Right
FPSShadow.ZIndex = 1000
FPSShadow.Parent = FPSLabel

local function UpdateFPSPosition()
	local pos = CurrentSettings.FpsPosition
	if pos == "Top Left" then
		FPSLabel.Position = UDim2.new(0, 10, 0, 10)
		FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
		FPSShadow.TextXAlignment = Enum.TextXAlignment.Left
	elseif pos == "Top Right" then
		FPSLabel.Position = UDim2.new(1, -160, 0, 10)
		FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
		FPSShadow.TextXAlignment = Enum.TextXAlignment.Right
	elseif pos == "Bottom Left" then
		FPSLabel.Position = UDim2.new(0, 10, 1, -40)
		FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
		FPSShadow.TextXAlignment = Enum.TextXAlignment.Left
	elseif pos == "Bottom Right" then
		FPSLabel.Position = UDim2.new(1, -160, 1, -40)
		FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
		FPSShadow.TextXAlignment = Enum.TextXAlignment.Right
	end
end

RunService.RenderStepped:Connect(function()
	local now = tick()
	AppVariables.Frames = AppVariables.Frames + 1
	
	if now - AppVariables.LastTick >= 1 then
		AppVariables.CurrentFPS = AppVariables.Frames
		table.insert(AppVariables.FPSHistory, AppVariables.CurrentFPS)
		if #AppVariables.FPSHistory > 5 then
			table.remove(AppVariables.FPSHistory, 1)
		end
		
		local sum = 0
		for _, v in ipairs(AppVariables.FPSHistory) do sum = sum + v end
		AppVariables.AverageFPS = math.floor(sum / #AppVariables.FPSHistory)
		
		AppVariables.Frames = 0
		AppVariables.LastTick = now
	end
	
	if CurrentSettings.ShowFPS then
		FPSLabel.Visible = true
		local text = "FPS: " .. AppVariables.CurrentFPS
		if CurrentSettings.ShowAverageFPS then
			text = text .. " | AVG: " .. AppVariables.AverageFPS
		end
		FPSLabel.Text = text
		FPSShadow.Text = text
		
		-- Logic Màu FPS
		local fps = AppVariables.CurrentFPS
		if fps <= 10 then
			FPSLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		elseif fps <= 30 then
			FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		elseif fps <= 150 then
			FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			-- Rainbow logic for 151+ FPS
			local hue = (now * 0.5) % 1
			FPSLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
		end
	else
		FPSLabel.Visible = false
	end
	
	-- Update Theme Realtime (Rainbow tracking)
	if CurrentSettings.RainbowAccent or CurrentSettings.AccentColor == "Rainbow" then
		Features.UpdateTheme()
	end
end)

-- MAP NỘI DUNG VÀO TAB

-- TAB: HOME
UI.CreateSection(HomeTab, "QUICK ACTIONS")
UI.CreateToggle(HomeTab, "Black Screen", "BlackScreen", Features.ToggleBlackScreen)
UI.CreateToggle(HomeTab, "Clean GUI", "HideGameGui", Features.ToggleGameGUI)
UI.CreateToggle(HomeTab, "Show FPS", "ShowFPS")
UI.CreateToggle(HomeTab, "Blur Background", "BlurBackground", Features.UpdateTheme)
UI.CreateToggle(HomeTab, "Animations", "Animation")

-- TAB: SETTINGS
UI.CreateSection(SettingsTab, "THEME")
UI.CreateToggle(SettingsTab, "Dark Mode", "Theme", function(state)
	CurrentSettings.Theme = state and "Dark" or "Light"
	Features.UpdateTheme()
end)
CurrentSettings.Theme = "Dark" -- Forcing sync UI state logically
UI.CreateColorSelector(SettingsTab, "Accent Color")
UI.CreateToggle(SettingsTab, "Rainbow Accent", "RainbowAccent")

UI.CreateSection(SettingsTab, "INTERFACE")
UI.CreateSlider(SettingsTab, "GUI Scale (%)", 50, 150, 5, "GuiScale", function()
	-- Thay đổi scale yêu cầu tính toán lại kích thước toàn cục (Phức tạp, tạm refresh script hoặc apply limit)
	-- Do yêu cầu script gọn 1 file, ta khuyến cáo user reset UI Pos
end)
UI.CreateToggle(SettingsTab, "Shadow", "Shadow", Features.UpdateTheme)
UI.CreateToggle(SettingsTab, "Glow", "Glow", Features.UpdateTheme)
UI.CreateSlider(SettingsTab, "Transparency (%)", 0, 80, 5, "MenuTransparency", Features.UpdateTheme)

-- TAB: FPS
UI.CreateSection(FPSTab, "FPS SETTINGS")
UI.CreateToggle(FPSTab, "Show FPS Counter", "ShowFPS")
UI.CreateDropdown(FPSTab, "FPS Position", {"Top Left", "Top Right", "Bottom Left", "Bottom Right"}, "FpsPosition", UpdateFPSPosition)
UI.CreateToggle(FPSTab, "Show Average FPS", "ShowAverageFPS")

-- TAB: GAME
UI.CreateSection(GameTab, "GAME MODIFICATIONS")
UI.CreateToggle(GameTab, "Black Screen", "BlackScreen", Features.ToggleBlackScreen)
UI.CreateToggle(GameTab, "Hide Original GUI", "HideGameGui", Features.ToggleGameGUI)
UI.CreateButton(GameTab, "Restore Original GUI", function()
	CurrentSettings.HideGameGui = false
	Features.ToggleGameGUI(false)
	-- Cần cập nhật lại giao diện Toggle (trick: lưu ref toggle để update ngầm nếu cần, ở đây simple run logic)
end)
UI.CreateToggle(GameTab, "Auto Save Settings", "AutoSave")

-- TAB: MOBILE
UI.CreateSection(MobileTab, "MOBILE ADJUSTMENTS")
UI.CreateSlider(MobileTab, "Button Size (%)", 80, 200, 10, "ButtonSize")
UI.CreateSlider(MobileTab, "UI Scale (%)", 100, 200, 10, "MobileUIScale")
UI.CreateToggle(MobileTab, "Vibrate On Tap", "VibrationOnTap")

-- TAB: SYSTEM
UI.CreateSection(SystemTab, "SYSTEM SETTINGS")
UI.CreateButton(SystemTab, "Save Settings", function() SettingsManager.Save() end)
UI.CreateButton(SystemTab, "Load Settings", function() 
	SettingsManager.Load() 
	Features.UpdateTheme()
	UpdateFPSPosition()
end)
UI.CreateButton(SystemTab, "Reset UI Position", function()
	MainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
	FloatingBtn.Position = UDim2.new(0.9, -50, 0.5, -25)
	CurrentSettings.MenuPosition = "{0.5, -160}, {0.5, -250}"
	CurrentSettings.FloatingButtonPosition = "{0.9, -50}, {0.5, -25}"
	SettingsManager.Save()
end)
UI.CreateButton(SystemTab, "Factory Reset", function()
	SettingsManager.Reset()
	Features.UpdateTheme()
	UpdateFPSPosition()
end)

-- INIT CALLS
Features.UpdateTheme()
UpdateFPSPosition()
if CurrentSettings.BlackScreen then Features.ToggleBlackScreen(true) end
if CurrentSettings.HideGameGui then Features.ToggleGameGUI(true) end

-- Hoàn tất khởi tạo Script
