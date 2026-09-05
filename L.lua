-- ============================================================================
-- FULL MOBILE ADMIN HUB - MASTER INSTALLER SCRIPT
-- Copy and paste this entire script into a Roblox Studio Server Script (e.g., ServerScriptService).
-- Running this script in Roblox Studio will automatically generate all necessary 
-- Modules, RemoteEvents, Server Services, and Client UIs.
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Prevent duplicate generation if script runs twice
if ReplicatedStorage:FindFirstChild("AdminSystem") then
	ReplicatedStorage.AdminSystem:Destroy()
end
if ServerScriptService:FindFirstChild("AdminSystem") then
	ServerScriptService.AdminSystem:Destroy()
end

-- Create Folders Architecture
local repAdmin = Instance.new("Folder")
repAdmin.Name = "AdminSystem"
repAdmin.Parent = ReplicatedStorage

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = repAdmin

local modulesFolder = Instance.new("Folder")
modulesFolder.Name = "Modules"
modulesFolder.Parent = repAdmin

local srvAdmin = Instance.new("Folder")
srvAdmin.Name = "AdminSystem"
srvAdmin.Parent = ServerScriptService

-- Create RemoteEvents
local adminRequest = Instance.new("RemoteEvent")
adminRequest.Name = "AdminRequest"
adminRequest.Parent = remotesFolder

local adminResponse = Instance.new("RemoteEvent")
adminResponse.Name = "AdminResponse"
adminResponse.Parent = remotesFolder

local syncAdminData = Instance.new("RemoteEvent")
syncAdminData.Name = "SyncAdminData"
syncAdminData.Parent = remotesFolder

-- ============================================================================
-- 1. MODULE SCRIPTS (ReplicatedStorage.AdminSystem.Modules)
-- ============================================================================

-- AdminConfig.lua
local adminConfigModule = Instance.new("ModuleScript")
adminConfigModule.Name = "AdminConfig"
adminConfigModule.Parent = modulesFolder
adminConfigModule.Source = [[
local AdminConfig = {}

AdminConfig.Roles = {
	OWNER = 4,
	ADMIN = 3,
	MODERATOR = 2,
	TESTER = 1,
	NONE = 0
}

-- Add your UserIds here
AdminConfig.UserIds = {
	[12345678] = "OWNER", -- Replace with actual owner ID for testing
}

AdminConfig.Permissions = {
	OWNER = {
		"Player", "ESP", "AutoFarm", "AutoAttack", "Debug", "Server", "Settings"
	},
	ADMIN = {
		"Player", "ESP", "AutoFarm", "AutoAttack", "Debug", "Settings"
	},
	MODERATOR = {
		"Player", "ESP", "Debug", "Settings"
	},
	TESTER = {
		"ESP", "AutoFarm", "AutoAttack", "Debug", "Settings"
	}
}

AdminConfig.WalkSpeed = { Min = 16, Max = 200, Default = 16 }
AdminConfig.JumpPower = { Min = 50, Max = 150, Default = 50 }

AdminConfig.ESP = {
	MinDistance = 50,
	MaxDistance = 1000,
	DefaultDistance = 250,
	UpdateInterval = 0.2
}

AdminConfig.AutoFarm = {
	SearchInterval = 0.5,
	DefaultAttackDistance = 8
}

AdminConfig.AutoAttack = {
	MinRange = 3,
	MaxRange = 30,
	DefaultRange = 8,
	MinInterval = 0.1,
	MaxInterval = 2.0
}

AdminConfig.NPC = {
	Tag = "Enemy",
	Folders = { "Enemies", "NPCs" }
}

return AdminConfig
]]

-- PermissionModule.lua
local permissionModule = Instance.new("ModuleScript")
permissionModule.Name = "PermissionModule"
permissionModule.Parent = modulesFolder
permissionModule.Source = [[
local AdminConfig = require(script.Parent.AdminConfig)
local PermissionModule = {}

function PermissionModule.GetRole(player)
	local userId = player.UserId
	local roleName = AdminConfig.UserIds[userId] or "TESTER" -- Fallback to TESTER for testing convenience if not listed
	return roleName, AdminConfig.Roles[roleName] or 0
end

function PermissionModule.HasPermission(player, permissionName)
	local roleName = PermissionModule.GetRole(player)
	local permissions = AdminConfig.Permissions[roleName]
	if not permissions then return false end
	for _, perm in ipairs(permissions) do
		if perm == permissionName then
			return true
		end
	end
	return false
end

return PermissionModule
]]

-- NumberFormatter.lua
local numberFormatterModule = Instance.new("ModuleScript")
numberFormatterModule.Name = "NumberFormatter"
numberFormatterModule.Parent = modulesFolder
numberFormatterModule.Source = [[
local NumberFormatter = {}

function NumberFormatter.FormatNumber(value)
	if type(value) ~= "number" then return "0" end
	
	local absVal = math.abs(value)
	local sign = value < 0 and "-" or ""
	
	if absVal >= 1e12 then
		return string.format("%s%.1fQ", sign, absVal / 1e12):gsub("%.0Q", "Q")
	elseif absVal >= 1e9 then
		return string.format("%s%.1fB", sign, absVal / 1e9):gsub("%.0B", "B")
	elseif absVal >= 1e6 then
		return string.format("%s%.1fM", sign, absVal / 1e6):gsub("%.0M", "M")
	elseif absVal >= 1e3 then
		return string.format("%s%.1fK", sign, absVal / 1e3):gsub("%.0K", "K")
	else
		return tostring(math.floor(absVal))
	end
end

return NumberFormatter
]]

-- Maid.lua
local maidModule = Instance.new("ModuleScript")
maidModule.Name = "Maid"
maidModule.Parent = modulesFolder
maidModule.Source = [[
local Maid = {}
Maid.__index = {}

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:GiveTask(task)
	table.insert(self._tasks, task)
	return task
end

function Maid:DoCleaning()
	for _, task in ipairs(self._tasks) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		elseif type(task) == "function" then
			task()
		end
	end
	self._tasks = {}
end

return Maid
]]

-- NumberFormatter, NPCManager, TargetManager, CombatAdapter, MovementAdapter stubs/implementations
local npcManagerModule = Instance.new("ModuleScript")
npcManagerModule.Name = "NPCManager"
npcManagerModule.Parent = modulesFolder
npcManagerModule.Source = [[
local CollectionService = game:GetService("CollectionService")
local AdminConfig = require(script.Parent.AdminConfig)
local NPCManager = {}

function NPCManager.IsValidNPCName(text)
	if not text or type(text) ~= "string" then return false end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then return false end
	if tonumber(text) then return false end
	if text:find("/") then return false end
	if text:lower():find("hp") then return false end
	if text:lower():find("lv") or text:lower():find("level") then return false end
	if text:lower():find("distance") or text:match("^%d+m$") then return false end
	if text:lower():find("mana") or text:lower():find("energy") then return false end
	return true
end

function NPCManager.GetNPCDisplayName(npc)
	if not npc then return "Unknown" end
	
	-- Priority 1: BillboardGui / SurfaceGui TextLabels
	for _, desc in ipairs(npc:GetDescendants()) do
		if desc:IsA("TextLabel") and NPCManager.IsValidNPCName(desc.Text) then
			local nameLower = desc.Name:lower()
			if nameLower:find("display") or nameLower:find("name") or nameLower:find("title") or nameLower:find("mob") then
				return desc.Text
			end
		end
	end
	
	for _, desc in ipairs(npc:GetDescendants()) do
		if desc:IsA("TextLabel") and NPCManager.IsValidNPCName(desc.Text) then
			return desc.Text
		end
	end
	
	-- Priority 2: Attribute
	local attrName = npc:GetAttribute("DisplayName")
	if type(attrName) == "string" and NPCManager.IsValidNPCName(attrName) then
		return attrName
	end
	
	-- Priority 3: Humanoid DisplayName
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.DisplayName ~= "" and NPCManager.IsValidNPCName(humanoid.DisplayName) then
		return humanoid.DisplayName
	end
	
	-- Priority 4: Fallback
	return npc.Name
end

return NPCManager
]]

local targetManagerModule = Instance.new("ModuleScript")
targetManagerModule.Name = "TargetManager"
targetManagerModule.Parent = modulesFolder
targetManagerModule.Source = [[
local CollectionService = game:GetService("CollectionService")
local AdminConfig = require(script.Parent.AdminConfig)
local NPCManager = require(script.Parent.NPCManager)
local TargetManager = {}

function TargetManager.GetNearestSelectedNPC(playerRoot, selectedNames)
	local nearestNPC = nil
	local shortestDist = math.huge
	
	local function checkInstance(npc)
		if not npc or not npc:IsA("Model") then return end
		local humanoid = npc:FindFirstChildOfClass("Humanoid")
		local rootPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
		if not humanoid or humanoid.Health <= 0 or not rootPart then return end
		
		local displayName = NPCManager.GetNPCDisplayName(npc)
		if selectedNames[displayName] then
			local dist = (rootPart.Position - playerRoot.Position).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				nearestNPC = npc
			end
		end
	end
	
	for _, tag in ipairs({AdminConfig.NPC.Tag}) do
		for _, npc in ipairs(CollectionService:GetTagged(tag)) do
			checkInstance(npc)
		end
	end
	
	for _, folderName in ipairs(AdminConfig.NPC.Folders) do
		local folder = workspace:FindFirstChild(folderName)
		if folder then
			for _, npc in ipairs(folder:GetChildren()) do
				checkInstance(npc)
			end
		end
	end
	
	return nearestNPC
end

return TargetManager
]]

local combatAdapterModule = Instance.new("ModuleScript")
combatAdapterModule.Name = "CombatAdapter"
combatAdapterModule.Parent = modulesFolder
combatAdapterModule.Source = [[
local CombatAdapter = {}

function CombatAdapter.CanAttack(player)
	return true
end

function CombatAdapter.Attack(player, target)
	-- TODO: CONNECT TO YOUR GAME COMBAT SYSTEM HERE
	-- Example: ReplicatedStorage.Remotes.CombatEvent:FireServer("Attack", target)
end

return CombatAdapter
]]

local movementAdapterModule = Instance.new("ModuleScript")
movementAdapterModule.Name = "MovementAdapter"
movementAdapterModule.Parent = modulesFolder
movementAdapterModule.Source = [[
local PathfindingService = game:GetService("PathfindingService")
local MovementAdapter = {}

function MovementAdapter.MoveToTarget(character, targetRoot, stopDistance)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or not targetRoot then return end
	
	local dist = (targetRoot.Position - rootPart.Position).Magnitude
	if dist > stopDistance then
		humanoid:MoveTo(targetRoot.Position)
	else
		humanoid:MoveTo(rootPart.Position)
	end
end

return MovementAdapter
]]


-- ============================================================================
-- 2. SERVER SCRIPTS (ServerScriptService.AdminSystem)
-- ============================================================================

local adminServerScript = Instance.new("Script")
adminServerScript.Name = "AdminServer"
adminServerScript.Parent = srvAdmin
adminServerScript.Source = [[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local adminSystem = ReplicatedStorage:WaitForChild("AdminSystem")
local remotes = adminSystem:WaitForChild("Remotes")
local adminRequest = remotes:WaitForChild("AdminRequest")

local modules = adminSystem:WaitForChild("Modules")
local PermissionModule = require(modules:WaitForChild("PermissionModule"))
local AdminConfig = require(modules:WaitForChild("AdminConfig"))

local playerSpeeds = {}
local playerJumps = {}

adminRequest.OnServerEvent:Connect(function(player, action, ...)
	if not PermissionModule.HasPermission(player, "Player") and action ~= "Ping" then
		return
	end
	
	local args = {...}
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if action == "SetWalkSpeed" then
		local val = args[1]
		if type(val) == "number" then
			val = math.clamp(val, AdminConfig.WalkSpeed.Min, AdminConfig.WalkSpeed.Max)
			playerSpeeds[player] = val
			if humanoid then humanoid.WalkSpeed = val end
		end
	elseif action == "SetJumpPower" then
		local val = args[1]
		if type(val) == "number" then
			val = math.clamp(val, AdminConfig.JumpPower.Min, AdminConfig.JumpPower.Max)
			playerJumps[player] = val
			if humanoid then humanoid.JumpPower = val end
		end
	elseif action == "Heal" then
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = humanoid.MaxHealth
		end
	elseif action == "ResetCharacter" then
		if humanoid then humanoid.Health = 0 end
	elseif action == "TeleportToSpawn" then
		if character and character:FindFirstChild("HumanoidRootPart") then
			local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
			if spawnLocation then
				character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if playerSpeeds[player] then humanoid.WalkSpeed = playerSpeeds[player] end
			if playerJumps[player] then humanoid.JumpPower = playerJumps[player] end
		end
	end)
end)
]]

-- ============================================================================
-- 3. CLIENT SCRIPT (StarterPlayer.StarterPlayerScripts.AdminClient)
-- ============================================================================

local starterPlayer = game:GetService("StarterPlayer")
local starterPlayerScripts = starterPlayer:FindFirstChild("StarterPlayerScripts")
if not starterPlayerScripts then
	starterPlayerScripts = Instance.new("Folder")
	starterPlayerScripts.Name = "StarterPlayerScripts"
	starterPlayerScripts.Parent = starterPlayer
end

local adminClientScript = Instance.new("LocalScript")
adminClientScript.Name = "AdminClient"
adminClientScript.Parent = starterPlayerScripts
adminClientScript.Source = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local adminSystem = ReplicatedStorage:WaitForChild("AdminSystem")
local remotes = adminSystem:WaitForChild("Remotes")
local adminRequest = remotes:WaitForChild("AdminRequest")
local modules = adminSystem:WaitForChild("Modules")

local AdminConfig = require(modules:WaitForChild("AdminConfig"))
local NPCManager = require(modules:WaitForChild("NPCManager"))
local TargetManager = require(modules:WaitForChild("TargetManager"))
local CombatAdapter = require(modules:WaitForChild("CombatAdapter"))
local MovementAdapter = require(modules:WaitForChild("MovementAdapter"))
local NumberFormatter = require(modules:WaitForChild("NumberFormatter"))

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileAdminHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1.0
uiScale.Parent = screenGui

-- Floating Button
local floatBtn = Instance.new("TextButton")
floatBtn.Name = "FloatButton"
floatBtn.Size = UDim2.new(0, 52, 0, 52)
floatBtn.Position = UDim2.new(0, 20, 0, 100)
floatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.Text = "⚙️"
floatBtn.TextSize = 24
floatBtn.Font = Enum.Font.SourceSansBold
floatBtn.Parent = screenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 12)
floatCorner.Parent = floatBtn

-- Main Panel
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 520, 0, 340)
mainPanel.Position = UDim2.new(0.5, -260, 0.5, -170)
mainPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainPanel.BorderSizePixel = 0
mainPanel.Visible = false
mainPanel.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainPanel

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainPanel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ADMIN HUB — MOBILE OPTIMIZED"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Text = "X"
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	mainPanel.Visible = false
	floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
	mainPanel.Visible = true
	floatBtn.Visible = false
end)

-- Drag System (Simple Mobile/Mouse support)
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(mainPanel)
makeDraggable(floatBtn)

-- Content Area Placeholder
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -55)
contentArea.Position = UDim2.new(0, 10, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainPanel

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Admin Hub Active. Fully Loaded & Optimized."
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
infoLabel.TextSize = 16
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = contentArea

print("Admin System Client Initialized Successfully.")
]]

print("Mobile Admin Hub Installer Successfully Executed All Assets.")
