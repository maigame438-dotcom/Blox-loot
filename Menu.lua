-- LocalScript: SIMPLE HUB (Lock Position)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 1. TẠO GIAO DIỆN (UI CREATION)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Nút Bật/Tắt Menu dạng hình tròn "..."
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "..."
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(130, 80, 230)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Khung chính của Menu (Main Container)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(110, 60, 200)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Thanh tiêu đề Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 30, 1, 0)
TitleIcon.Position = UDim2.new(0, 10, 0, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🔒"
TitleIcon.TextSize = 18
TitleIcon.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 40, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SIMPLE HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -38, 0, 7)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Header

-- Khung chứa tính năng LOCK
local LockCard = Instance.new("Frame")
LockCard.Name = "LockCard"
LockCard.Size = UDim2.new(1, -20, 0, 85)
LockCard.Position = UDim2.new(0, 10, 0, 50)
LockCard.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
LockCard.BorderSizePixel = 0
LockCard.Parent = MainFrame

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 12)
CardCorner.Parent = LockCard

local CardIcon = Instance.new("TextLabel")
CardIcon.Size = UDim2.new(0, 35, 0, 35)
CardIcon.Position = UDim2.new(0, 10, 0, 12)
CardIcon.BackgroundColor3 = Color3.fromRGB(70, 30, 130)
CardIcon.Text = "🔒"
CardIcon.TextSize = 16
CardIcon.Parent = LockCard

local CardIconCorner = Instance.new("UICorner")
CardIconCorner.CornerRadius = UDim.new(0, 8)
CardIconCorner.Parent = CardIcon

local CardTitle = Instance.new("TextLabel")
CardTitle.Size = UDim2.new(0, 120, 0, 20)
CardTitle.Position = UDim2.new(0, 55, 0, 10)
CardTitle.BackgroundTransparency = 1
CardTitle.Text = "Lock Position"
CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CardTitle.TextSize = 14
CardTitle.Font = Enum.Font.GothamBold
CardTitle.TextXAlignment = Enum.TextXAlignment.Left
CardTitle.Parent = LockCard

local CardDesc = Instance.new("TextLabel")
CardDesc.Size = UDim2.new(0, 140, 0, 40)
CardDesc.Position = UDim2.new(0, 55, 0, 32)
CardDesc.BackgroundTransparency = 1
CardDesc.Text = "Khóa vị trí, không thể di chuyển, nhảy, hoặc bị đẩy lùi."
CardDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
CardDesc.TextSize = 10
CardDesc.Font = Enum.Font.Gotham
CardDesc.TextWrapped = true
CardDesc.TextXAlignment = Enum.TextXAlignment.Left
CardDesc.TextYAlignment = Enum.TextYAlignment.Top
CardDesc.Parent = LockCard

-- Công tắc Toggle Switch
local SwitchBg = Instance.new("TextButton")
SwitchBg.Name = "SwitchBg"
SwitchBg.Size = UDim2.new(0, 45, 0, 24)
SwitchBg.Position = UDim2.new(1, -55, 0, 18)
SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
SwitchBg.BorderSizePixel = 0
SwitchBg.Text = ""
SwitchBg.Parent = LockCard

local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(1, 0)
SwitchCorner.Parent = SwitchBg

local SwitchCircle = Instance.new("Frame")
SwitchCircle.Size = UDim2.new(0, 18, 0, 18)
SwitchCircle.Position = UDim2.new(0, 3, 0, 3)
SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchCircle.BorderSizePixel = 0
SwitchCircle.Parent = SwitchBg

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = SwitchCircle

-- Thanh hướng dẫn di chuyển menu bên dưới
local DragFooter = Instance.new("Frame")
DragFooter.Size = UDim2.new(1, -20, 0, 40)
DragFooter.Position = UDim2.new(0, 10, 0, 145)
DragFooter.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
DragFooter.BorderSizePixel = 0
DragFooter.Parent = MainFrame

local DragFooterCorner = Instance.new("UICorner")
DragFooterCorner.CornerRadius = UDim.new(0, 10)
DragFooterCorner.Parent = DragFooter

local DragText = Instance.new("TextLabel")
DragText.Size = UDim2.new(1, 0, 1, 0)
DragText.BackgroundTransparency = 1
DragText.Text = "☝️  Giữ R và kéo để di chuyển menu"
DragText.TextColor3 = Color3.fromRGB(180, 180, 200)
DragText.TextSize = 11
DragText.Font = Enum.Font.Gotham
DragText.Parent = DragFooter

--------------------------------------------------------------------------------
-- 2. ĐIỀU KHIỂN BẬT/TẮT & TWEEN ANIMATION
--------------------------------------------------------------------------------
local isOpen = true
local originalSize = UDim2.new(0, 280, 0, 220)
local closedSize = UDim2.new(0, 0, 0, 0)

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
			if not isOpen then
				MainFrame.Visible = false
			end
		end)
	end
end

ToggleButton.MouseButton1Click:Connect(toggleMenu)
CloseButton.MouseButton1Click:Connect(toggleMenu)

--------------------------------------------------------------------------------
-- 3. KÉO/VUỐT MENU (GIỮ PHÍM R)
--------------------------------------------------------------------------------
local isHoldingR = false
local dragging = false
local dragStart = nil
local startPos = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.R then
		isHoldingR = true
	end
	
	if isHoldingR and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.R then
		isHoldingR = false
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and isHoldingR and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		local newPosition = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		TweenService:Create(MainFrame, TweenInfo.new(0.05), {Position = newPosition}):Play()
	end
end)

--------------------------------------------------------------------------------
-- 4. CHỨC NĂNG LOCK POSITION (KHÓA VỊ TRÍ)
--------------------------------------------------------------------------------
local isLocked = false
local lockConnection = nil
local lockedCFrame = nil

local function toggleLockPosition()
	isLocked = not isLocked
	
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	if isLocked then
		-- Animation Switch On
		TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(140, 60, 240)}):Play()
		TweenService:Create(SwitchCircle, tweenInfo, {Position = UDim2.new(0, 24, 0, 3)}):Play()
		
		-- Lưu vị trí hiện tại
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			lockedCFrame = character.HumanoidRootPart.CFrame
			
			-- Khóa liên tục trên từng khung hình (Ngăn di chuyển, va chạm, nhảy)
			lockConnection = RunService.RenderStepped:Connect(function()
				if isLocked and character and character:FindFirstChild("HumanoidRootPart") then
					character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					
					-- Cho phép quay Camera/Xoay nhân vật nhưng giữ nguyên vị trí X, Y, Z
					local currentLook = character.HumanoidRootPart.CFrame.Rotation
					character.HumanoidRootPart.CFrame = CFrame.new(lockedCFrame.Position) * currentLook
				end
			end)
		end
	else
		-- Animation Switch Off
		TweenService:Create(SwitchBg, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 45, 65)}):Play()
		TweenService:Create(SwitchCircle, tweenInfo, {Position = UDim2.new(0, 3, 0, 3)}):Play()
		
		-- Hủy khóa
		if lockConnection then
			lockConnection:Disconnect()
			lockConnection = nil
		end
		lockedCFrame = nil
	end
end

SwitchBg.MouseButton1Click:Connect(toggleLockPosition)
