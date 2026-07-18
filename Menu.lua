-- ============================================
-- SCRIPT BLOX LOOT - BẢN MENU CHO ĐIỆN THOẠI
-- DÙNG CHO EXECUTOR: ARCEUS X / HYDROGEN / CODEX
-- SAO CHÉP TOÀN BỘ VÀ PASTE VÀO EXECUTOR
-- ============================================

-- ====== PHẦN 1: TẠO MENU GUI (CẢM ỨNG CHẠM) ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloxLootMenu"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Tiêu đề (khu vực kéo)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
title.Text = "BLOX LOOT HACK (CHẠM ĐỂ BẬT/TẮT)"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Nút đóng (to hơn cho ngón tay)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 50, 0, 40)
closeBtn.Position = UDim2.new(1, -55, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Hàm tạo nút bật/tắt (kích thước lớn cho cảm ứng)
local function CreateToggleButton(parent, yPos, labelText, configKey, defaultValue)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
    btn.Text = labelText .. ": " .. (defaultValue and "BẬT" or "TẮT")
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        PVP_CONFIG[configKey] = not PVP_CONFIG[configKey]
        btn.BackgroundColor3 = PVP_CONFIG[configKey] and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
        btn.Text = labelText .. ": " .. (PVP_CONFIG[configKey] and "BẬT" or "TẮT")
    end)
    return btn
end

-- Tạo các nút (khoảng cách 55px cho dễ chạm)
local yOff = 60
CreateToggleButton(mainFrame, yOff, "Tự động nhặt loot", "AutoFarm", true)
CreateToggleButton(mainFrame, yOff + 55, "Tự động mở rương", "AutoOpenChest", true)
CreateToggleButton(mainFrame, yOff + 110, "Tự động bắn", "AutoShoot", true)
CreateToggleButton(mainFrame, yOff + 165, "Khóa mục tiêu", "AimLock", true)
CreateToggleButton(mainFrame, yOff + 220, "Tự động né đạn", "DodgeEnabled", true)

-- Nút Teleport về trung tâm
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 50)
tpBtn.Position = UDim2.new(0.05, 0, 0, yOff + 280)
tpBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 200)
tpBtn.Text = "📌 VỀ TRUNG TÂM"
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.TextScaled = true
tpBtn.Font = Enum.Font.GothamSemibold
tpBtn.Parent = mainFrame
tpBtn.MouseButton1Click:Connect(function()
    if rootPart then
        rootPart.CFrame = CFrame.new(0, 50, 0)
        rootPart.Velocity = Vector3.new(0,0,0)
    end
end)

-- Nút Reset nhân vật
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.9, 0, 0, 50)
resetBtn.Position = UDim2.new(0.05, 0, 0, yOff + 340)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
resetBtn.Text = "🔄 RESET NHÂN VẬT"
resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamSemibold
resetBtn.Parent = mainFrame
resetBtn.MouseButton1Click:Connect(function()
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.Health = 0
    end
end)

-- ====== PHẦN 2: CORE ENGINE ======
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local CONFIG = {
    AutoFarm = true,
    AutoOpenChest = true,
    LootRadius = 80,
    ItemBlacklist = {"Coin", "Gem"}
}

local PVP_CONFIG = {
    AutoShoot = true,
    AimLock = true,
    ShootRadius = 180,
    BulletSpeed = 3000,
    DodgeEnabled = true,
    DodgeCooldown = 0.5
}

-- Hàm lấy danh sách loot
local function GetLootItems()
    local items = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Handle") then
            local handle = v.Handle
            if handle:IsA("BasePart") and handle.Transparency < 0.5 then
                local name = v.Name:lower()
                local isBlacklisted = false
                for _, black in pairs(CONFIG.ItemBlacklist) do
                    if name:find(black:lower()) then isBlacklisted = true; break end
                end
                if not isBlacklisted then
                    table.insert(items, {Model = v, Handle = handle, Pos = handle.Position})
                end
            end
        end
    end
    return items
end

local function GetClosestLoot()
    local rootPos = rootPart.Position
    local closest = nil
    local minDist = CONFIG.LootRadius
    for _, item in pairs(GetLootItems()) do
        local dist = (item.Pos - rootPos).Magnitude
        if dist < minDist then
            minDist = dist
            closest = item
        end
    end
    return closest
end

local function TeleportTo(position)
    rootPart.CFrame = CFrame.new(position)
    rootPart.Velocity = Vector3.new(0,0,0)
    task.wait(0.05)
end

local function OpenChestsNearby()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v.Name:find("Chest") then
            local clickPart = v:FindFirstChild("ClickDetector") or v:FindFirstChild("TouchInterest")
            if clickPart then
                local chestPos = v:FindFirstChild("Handle") and v.Handle.Position or (v.PrimaryPart and v.PrimaryPart.Position)
                if chestPos then
                    local dist = (chestPos - rootPart.Position).Magnitude
                    if dist < 20 then
                        fireclickdetector(clickPart)
                        if clickPart:IsA("TouchInterest") then
                            local args = {[1] = rootPart}
                            clickPart:FireServer(unpack(args))
                        end
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end

-- Hàm PvP
local function GetClosestEnemy()
    local rootPos = rootPart.Position
    local closest = nil
    local minDist = PVP_CONFIG.ShootRadius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = plr.Character.HumanoidRootPart
            local dist = (enemyRoot.Position - rootPos).Magnitude
            if dist < minDist then
                minDist = dist
                closest = {Player = plr, Root = enemyRoot, Humanoid = plr.Character:FindFirstChild("Humanoid")}
            end
        end
    end
    return closest
end

local function ShootAt(targetPos)
    if not targetPos then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("FireWeapon")
    if remote then
        remote:FireServer(targetPos, {Hit = targetPos})
    else
        local args = {[1] = targetPos, [2] = Vector3.new(0,0,0)}
        pcall(function() tool:FireServer(unpack(args)) end)
    end
end

local function PredictPosition(targetRoot, targetVel)
    local bulletSpeed = PVP_CONFIG.BulletSpeed
    local distance = (targetRoot.Position - rootPart.Position).Magnitude
    local travelTime = distance / bulletSpeed
    return targetRoot.Position + targetVel * travelTime
end

local lastDodgeTime = 0

local function DodgeBullet()
    if not PVP_CONFIG.DodgeEnabled then return end
    if tick() - lastDodgeTime < PVP_CONFIG.DodgeCooldown then return end
    local direction = (rootPart.Position - Vector3.new(0, rootPart.Position.Y, 0)).Unit
    local dodgeDir = CFrame.new(rootPart.Position, rootPart.Position + direction + Vector3.new(math.random(-1,1), 0, math.random(-1,1))).LookVector
    rootPart.Velocity = dodgeDir * 70 + Vector3.new(0, 25, 0)
    lastDodgeTime = tick()
end

-- ====== PHẦN 3: VÒNG LẶP CHÍNH (TỐI ƯU CHO ĐIỆN THOẠI) ======
task.spawn(function()
    while task.wait(0.15) do
        if not screenGui.Enabled then task.wait(0.5) end
        
        if CONFIG.AutoFarm then
            local target = GetClosestLoot()
            if target then
                TeleportTo(target.Pos + Vector3.new(0, 4, 0))
                task.wait(0.15)
                rootPart.CFrame = CFrame.new(target.Pos)
            else
                TeleportTo(Vector3.new(0, 50, 0))
            end
        end
        
        if CONFIG.AutoOpenChest then
            OpenChestsNearby()
        end
    end
end)

task.spawn(function()
    while task.wait(0.08) do
        if not screenGui.Enabled then task.wait(0.5) end
        if not PVP_CONFIG.AutoShoot and not PVP_CONFIG.AimLock then continue end
        
        local enemy = GetClosestEnemy()
        if enemy then
            local enemyRoot = enemy.Root
            local enemyHumanoid = enemy.Humanoid
            if enemyHumanoid and enemyHumanoid.Health > 0 then
                local aimPos = PredictPosition(enemyRoot, enemyRoot.Velocity)
                
                if PVP_CONFIG.AimLock then
                    rootPart.CFrame = CFrame.new(rootPart.Position, aimPos)
                end
                
                if PVP_CONFIG.AutoShoot then
                    ShootAt(aimPos)
                end
                
                if PVP_CONFIG.DodgeEnabled and #Players:GetPlayers() > 2 then
                    DodgeBullet()
                end
            end
        end
    end
end)

-- ====== PHẦN 4: LỆNH CHAT CHO ĐIỆN THOẠI ======
player.Chatted:Connect(function(msg)
    if msg:lower() == "/menu" then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

print("BLOX LOOT MENU ĐT - GÕ /menu TRONG CHAT ĐỂ MỞ LẠI (bản chỉnh sửa bởi Doi)")
