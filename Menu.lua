-- LocalScript: SIMPLE HUB (Bản Cập Nhật - Kéo Thả Trực Tiếp & Khóa Tuyệt Đối)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 1. HÀM HỖ TRỢ KÉO THẢ UI (DRAGGABLE)
--------------------------------------------------------------------------------
local function MakeDraggable(guiElement, dragHandle)
	dragHandle = dragHandle or guiElement
	local dragging = false
	local dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiElement.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
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
			local delta = input.Position - dragStart
			guiElement.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--------------------------------------------------------------------------------
-- 2. TẠO GIAO DIỆN (UI CREATION)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- NÚT MỞ MENU (Draggable)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 55, 0, 55)
OpenButton.Position = UDim2.new(0.05, 0, 0.2, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
OpenButton.BorderSizePixel = 0
OpenButton.Text = ""
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 16)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(130, 80, 230)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenButton

local OpenDragIndicator = Instance.new("Frame")
OpenDragIndicator.Size = UDim2.new(0, 20, 0, 3)
OpenDragIndicator.Position = UDim2.new(0.5, -10, 0, 6)
OpenDragIndicator.BackgroundColor3 = Color3.fromRGB(130, 80, 230)
OpenDragIndicator.BorderSizePixel = 0
OpenDragIndicator.Parent = OpenButton

local OpenDragCorner = Instance.new("UICorner")
OpenDragCorner.CornerRadius = UDim.new(1, 0)
OpenDragCorner.Parent = OpenDragIndicator

local OpenIcon = Instance.new("TextLabel")
OpenIcon.Size = UDim2.new(1, 0, 1, 0)
OpenIcon.BackgroundTransparency = 1
OpenIcon.Text = "🔒"
OpenIcon.TextSize = 24
OpenIcon.Parent = OpenButton

MakeDraggable(OpenButton) -- Làm cho nút mở có thể kéo thả

-- KHUNG CHÍNH MENU
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 290, 0, 220)
MainFrame.Position = UDim2.new(0.15, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(110, 50, 200)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- THANH TIÊU ĐỀ (Dùng để kéo thả Menu)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local HeaderDragIndicator = Instance.new("Frame")
HeaderDragIndicator.Size = UDim2.new(0, 30, 0, 3)
HeaderDragIndicator.Position = UDim2.new(0.5, -15, 0, 6)
HeaderDragIndicator.BackgroundColor3 = Color3.fromRGB(130, 80, 230)
HeaderDragIndicator.BorderSizePixel = 0
HeaderDragIndicator.Parent = Header

local HeaderDragCorner = Instance.new("UICorner")
HeaderDragCorner.CornerRadius = UDim.new(1, 0)
HeaderDragCorner.Parent = HeaderDragIndicator

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 30, 0, 20)
TitleIcon.Position = UDim2.new(0, 15, 0, 15)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🔒"
TitleIcon.TextSize = 16
TitleIcon.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 0, 20)
TitleLabel.Position = UDim2.new(0, 45, 0, 15)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SIMPLE HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

MakeDraggable(MainFrame, Header) -- Cho phép kéo thả Menu bằng thanh Header

-- KHUNG LOCK POSITION
local LockCard = Instance.new("Frame")
LockCard.Name = "LockCard"
LockCard.Size = UDim2.new(1, -30, 0, 75)
LockCard.Position = UDim2.new(0, 15, 0, 55)
LockCard.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
LockCard.BorderSizePixel = 0
LockCard.Parent = MainFrame

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 10)
CardCorner.Parent = LockCard

local CardIcon = Instance.new("TextLabel")
CardIcon.Size = UDim2.new(0, 30, 0, 30)
CardIcon.Position = UDim2.new(0, 12, 0, 12)
CardIcon.BackgroundColor3 = Color3.fromRGB(70, 30, 130)
CardIcon.Text = "🔒"
CardIcon.TextSize = 14
CardIcon.Parent = LockCard

local CardIconCorner = Instance.new("UICorner")
CardIconCorner.CornerRadius = UDim.new(0, 8)
CardIconCorner.Parent = CardIcon

local CardTitle = Instance.new("TextLabel")
CardTitle.Size = UDim2.new(0, 120, 0, 18)
CardTitle.Position = UDim2.new(0, 55, 0, 10)
CardTitle.BackgroundTransparency = 1
CardTitle.Text = "Lock Position"
CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CardTitle.TextSize = 14
CardTitle.Font = Enum.Font.GothamBold
CardTitle.TextXAlignment = Enum.TextXAlignment.Left
CardTitle.Parent = LockCard

local CardDesc = Instance.new("TextLabel")
CardDesc.Size = UDim2.new(0, 140, 0, 30)
CardDesc.Position = UDim2.new(0, 55, 0, 30)
CardDesc.BackgroundTransparency = 1
CardDesc.Text = "Khóa vị trí hiện tại, không thể di chuyển"
CardDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
CardDesc.TextSize = 11
CardDesc.Font = Enum.Font.Gotham
CardDesc.TextWrapped = true
CardDesc.TextXAlignment = Enum.TextXAlignment.Left
CardDesc.TextYAlignment = Enum.TextYAlignment.Top
CardDesc.Parent = LockCard

-- CÔNG TẮC (TOGGLE SWITCH)
local SwitchBg = Instance.new("TextButton")
SwitchBg.Name = "SwitchBg"
SwitchBg.Size = UDim2.new(0, 42, 0, 22)
SwitchBg.Position = UDim2.new(1, -55, 0, 26)
SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
SwitchBg.BorderSizePixel = 0
SwitchBg.Text = ""
SwitchBg.AutoButtonColor = false
SwitchBg.Parent = LockCard

local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(1, 0)
SwitchCorner.Parent = SwitchBg

local SwitchCircle = Instance.new("Frame")
SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
SwitchCircle.Position = UDim2.new(0, 3, 0, 3)
SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchCircle.BorderSizePixel = 0
SwitchCircle.Parent = SwitchBg

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = SwitchCircle

-- HƯỚNG DẪN DI CHUYỂN BÊN DƯỚI
local DragFooter = Instance.new("Frame")
DragFooter.Size = UDim2.new(1, -30, 0, 50)
DragFooter.Position = UDim2.new(0, 15, 0, 140)
DragFooter.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
DragFooter.BorderSizePixel = 0
DragFooter.Parent = MainFrame

local DragFooterCorner = Instance.new("UICorner")
DragFooterCorner.CornerRadius = UDim.new(0, 10)
DragFooterCorner.Parent = DragFooter

local DragIcon = Instance.new("TextLabel")
DragIcon.Size = UDim2.new(0, 30, 0, 30)
DragIcon.Position = UDim2.new(0, 12, 0, 10)
DragIcon.BackgroundTransparency = 1
DragIcon.Text = "💡"
DragIcon.TextSize = 16
DragIcon.Parent = DragFooter

local DragText = Instance.new("TextLabel")
DragText.Size = UDim2.new(1, -55, 1, 0)
DragText.Position = UDim2.new(0, 50, 0, 0)
DragText.BackgroundTransparency = 1
DragText.Text = "Giữ vào thanh trên cùng của menu và vuốt để di chuyển"
DragText.TextColor3 = Color3.fromRGB(150, 150, 170)
DragText.TextSize = 11
DragText.Font = Enum.Font.Gotham
DragText.TextWrapped = true
DragText.TextXAlignment = Enum.TextXAlignment.Left
DragText.Parent = DragFooter

--------------------------------------------------------------------------------
-- 3. ANIMATION MỞ/ĐÓNG MENU
--------------------------------------------------------------------------------
local isOpen = false
local originalSize = MainFrame.Size
local closedSize = UDim2.new(0, 0, 0, 0)
MainFrame.Size = closedSize

local function toggleMenu()
	isOpen = not isOpen
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	if isOpen then
		MainFrame.Visible = true
		TweenService:Create(MainFrame, tweenInfo, {Size = originalSize}):Play()
	else
		local tween = TweenService:Create(MainFrame, tweenInfo, {Size = closedSize})
		tween:Play()
		tween.Completed:Connect(function()
			if not isOpen then MainFrame.Visible = false end
		end)
	end
end

OpenButton.MouseButton1Click:Connect(toggleMenu)
CloseButton.MouseButton1Click:Connect(toggleMenu)

--------------------------------------------------------------------------------
-- 4. TÍNH NĂNG LOCK POSITION (KHÓA TUYỆT ĐỐI)
--------------------------------------------------------------------------------
local isLocked = false
local defaultWalkSpeed = 16
local defaultJumpPower = 50

local function applyLockState()
	local character = LocalPlayer.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if humanoid and rootPart then
		if isLocked then
			-- Trạng thái BẬT LOCK: Đóng băng tuyệt đối
			defaultWalkSpeed = humanoid.WalkSpeed
			defaultJumpPower = humanoid.JumpPower
			
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.AutoRotate = false
			humanoid.PlatformStand = true
			rootPart.Anchored = true -- Chống bị đẩy/kéo, đứng yên như tượng
		else
			-- Trạng thái TẮT LOCK: Khôi phục bình thường
			humanoid.WalkSpeed = defaultWalkSpeed
			humanoid.JumpPower = defaultJumpPower
			humanoid.AutoRotate = true
			humanoid.PlatformStand = false
			rootPart.Anchored = false
		end
	end
end

local function toggleLockPosition()
	isLocked = not isLocked
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	if isLocked then
		TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(140, 60, 240)}):Play()
		TweenService:Create(SwitchCircle, tweenInfo, {Position = UDim2.new(0, 23, 0, 3)}):Play()
	else
		TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 45, 65)}):Play()
		TweenService:Create(SwitchCircle, tweenInfo, {Position = UDim2.new(0, 3, 0, 3)}):Play()
	end
	
	applyLockState()
end

SwitchBg.MouseButton1Click:Connect(toggleLockPosition)

-- Tự động áp dụng lại trạng thái Lock nếu người chơi reset/chết
LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.5) -- Đợi character load xong
	if isLocked then
		applyLockState()
	end
end)
