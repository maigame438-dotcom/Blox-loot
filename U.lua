-- ==============================================================================
-- ALL-IN-ONE ADMIN HUB & MOBILE ESP (FIXED NAME & FORMATTED HP: K, M, B, T, Q)
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Configurations
local Config = {
    MasterESP = true,
    ShowName = true,
    ShowHP = true,
    ShowDistance = true,
    Highlight = true,
    Billboard = true,
    MaxDistance = 2000,
    WalkSpeed = 16,
    JumpPower = 50,
}

local ESPCache = {}

-- Format number function (K, M, B, T, Q)
local function FormatNumber(value)
    if not value then return "0" end
    if value >= 1e15 then
        return string.format("%.1fQ", value / 1e15)
    elseif value >= 1e12 then
        return string.format("%.1fT", value / 1e12)
    elseif value >= 1e9 then
        return string.format("%.1fB", value / 1e9)
    elseif value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fK", value / 1e3)
    else
        return tostring(math.floor(value))
    end
end

-- Lấy tên chuẩn của NPC (Loại bỏ các tag số hoặc khoảng trắng thừa nếu có)
local function GetCleanName(model)
    local name = model.Name
    -- Nếu tên toàn là số hoặc có dạng đặc biệt, cố gắng lấy từ HumanoidDisplayDistanceType hoặc Attribute nếu có
    if tonumber(name) then
        local customName = model:GetAttribute("DisplayName") or model:GetAttribute("MonsterName")
        if customName then return tostring(customName) end
    end
    return name
end

-- ==============================================================================
-- SAFE GUI PARENTING
-- ==============================================================================
local function ProtectUI(gui)
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
    end)
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AllInOneAdminHub"
ScreenGui.ResetOnSpawn = false
ProtectUI(ScreenGui)

-- Draggable Function (Mobile + PC)
local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Floating Button (Mở lại Menu)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -22)
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FloatBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
FloatBtn.Text = "🛡️"
FloatBtn.TextSize = 20
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Color3.fromRGB(0, 255, 150)
FloatStroke.Thickness = 2
MakeDraggable(FloatBtn, FloatBtn)

-- Main Hub Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 320)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Thickness = 1

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
MakeDraggable(Header, MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🛡️ UNIVERSAL ADMIN & ESP"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

-- Tab View System
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Sidebar.Parent = TabContainer

local UIListSidebar = Instance.new("UIListLayout", Sidebar)
UIListSidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListSidebar.Padding = UDim.new(0, 2)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -100, 1, 0)
ContentArea.Position = UDim2.new(0, 100, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = TabContainer

local function CreateTab(name, active)
	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Size = UDim2.new(1, 0, 1, 0)
	TabScroll.BackgroundTransparency = 1
	TabScroll.ScrollBarThickness = 3
	TabScroll.Visible = active
	TabScroll.Parent = ContentArea
	
	local UIList = Instance.new("UIListLayout", TabScroll)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 6)
	
	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(1, 0, 0, 35)
	TabBtn.BackgroundColor3 = active and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(25, 25, 32)
	TabBtn.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.GothamBold
	TabBtn.TextSize = 11
	TabBtn.Parent = Sidebar
	
	TabBtn.MouseButton1Click:Connect(function()
		for _, child in pairs(ContentArea:GetChildren()) do
			if child:IsA("ScrollingFrame") then child.Visible = false end
		end
		for _, child in pairs(Sidebar:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
				child.TextColor3 = Color3.fromRGB(180, 180, 180)
			end
		end
		TabScroll.Visible = true
		TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		TabBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
	end)
	
	return TabScroll
end

local PlayerTab = CreateTab("PLAYER", true)
local ESPTab = CreateTab("ESP", false)

-- UI Interactions (Open / Close)
FloatBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	FloatBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	FloatBtn.Visible = true
end)

-- Helper UI Builders
local function AddButton(parent, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	btn.MouseButton1Click:Connect(callback)
end

local function AddToggle(parent, text, configKey, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 30)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 5, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 20, 0, 20)
	toggleBtn.Position = UDim2.new(1, -25, 0.5, -10)
	toggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
	toggleBtn.Text = ""
	toggleBtn.Parent = frame
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
	
	toggleBtn.MouseButton1Click:Connect(function()
		Config[configKey] = not Config[configKey]
		toggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 70)
		if callback then callback(Config[configKey]) end
	end)
end

-- ==============================================================================
-- PLAYER TAB FEATURES
-- ==============================================================================
AddButton(PlayerTab, "Speed Boost (50)", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = 50
	end
end)

AddButton(PlayerTab, "Reset Speed (16)", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = 16
	end
end)

AddButton(PlayerTab, "Heal Character", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.Health = char.Humanoid.MaxHealth
	end
end)

AddButton(PlayerTab, "Kill / Respawn", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.Health = 0
	end
end)

-- ==============================================================================
-- ESP TAB FEATURES (Universal NPC / Monster Finder)
-- ==============================================================================
AddToggle(ESPTab, "Enable ESP", "MasterESP")
AddToggle(ESPTab, "Show Name", "ShowName")
AddToggle(ESPTab, "Show HP", "ShowHP")
AddToggle(ESPTab, "Show Distance", "ShowDistance")
AddToggle(ESPTab, "Highlight Model", "Highlight")

local function CreateESP(model)
	if ESPCache[model] then return end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not root then return end
	
	local hl = Instance.new("Highlight")
	hl.Adornee = model
	hl.FillColor = Color3.fromRGB(0, 255, 150)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.5
	hl.Parent = CoreGui
	
	local bg = Instance.new("BillboardGui")
	bg.Adornee = root
	bg.Size = UDim2.new(0, 150, 0, 40)
	bg.StudsOffset = Vector3.new(0, 3, 0)
	bg.AlwaysOnTop = true
	bg.Parent = CoreGui
	
	local txt = Instance.new("TextLabel", bg)
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 12
	txt.TextColor3 = Color3.fromRGB(255, 255, 255)
	txt.TextStrokeTransparency = 0
	
	ESPCache[model] = {hl = hl, bg = bg, txt = txt, root = root}
end

-- Tự tìm NPC / Quái vật trong Workspace (Bỏ qua Player)
local function ScanWorkspaceForNPCs()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			if not Players:GetPlayerFromCharacter(obj) then
				if obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("Health") then
					CreateESP(obj)
				end
			end
		end
	end
end

Workspace.DescendantAdded:Connect(function(obj)
	task.wait(0.5)
	pcall(function()
		if obj:IsA("Model") and obj ~= LocalPlayer.Character then
			if not Players:GetPlayerFromCharacter(obj) then
				if obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("Health") then
					CreateESP(obj)
				end
			end
		end
	end)
end)

-- Render Loop cho ESP
RunService.RenderStepped:Connect(function()
	local camPos = Camera.CFrame.Position
	for model, data in pairs(ESPCache) do
		if not model.Parent or not data.root or not data.root.Parent then
			pcall(function() data.hl:Destroy() end)
			pcall(function() data.bg:Destroy() end)
			ESPCache[model] = nil
		else
			local dist = (camPos - data.root.Position).Magnitude
			if Config.MasterESP and dist <= Config.MaxDistance then
				local hum = model:FindFirstChildOfClass("Humanoid")
				local hp = hum and FormatNumber(hum.Health) or "?"
				local maxHp = hum and FormatNumber(hum.MaxHealth) or "?"
				local monsterName = GetCleanName(model)
				
				local textLines = {}
				if Config.ShowName then table.insert(textLines, "[" .. monsterName .. "]") end
				if Config.ShowHP then table.insert(textLines, "HP: " .. hp .. "/" .. maxHp) end
				if Config.ShowDistance then table.insert(textLines, math.floor(dist) .. " studs") end
				
				data.txt.Text = table.concat(textLines, "\n")
				data.bg.Enabled = true
				data.hl.Enabled = Config.Highlight
			else
				data.bg.Enabled = false
				data.hl.Enabled = false
			end
		end
	end
end)

-- Khởi chạy quét lần đầu
task.spawn(ScanWorkspaceForNPCs)
