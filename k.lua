-- =========================================================================
-- SCRIPT FULL HOÀN CHỈNH: TỐC ĐỘ, NHẢY, CHỐNG RESET VÀ MENU MOBILE
-- =========================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 1. XÁC ĐỊNH VỊ TRÍ LƯU GUI AN TOÀN NHẤT
local targetGui = nil
local success, result = pcall(function() return CoreGui end)
if success and result then
    targetGui = result
else
    targetGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Xóa UI cũ nếu có để không bị đè lên nhau
if targetGui:FindFirstChild("FullStatMenu") then
    targetGui.FullStatMenu:Destroy()
end

-- Biến lưu thông số mục tiêu
local TargetWalkSpeed = 16
local TargetJumpPower = 50
local speedConn = nil
local jumpConn = nil

-- =========================================================================
-- 2. HÀM CHỐNG GAME TỰ ĐỘNG RESET THÔNG SỐ (KHI CẦM ĐỒ, VŨ KHÍ)
-- =========================================================================
local function ApplyAndLockStats(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    -- Ngắt kết nối cũ để chống lag
    if speedConn then speedConn:Disconnect() end
    if jumpConn then jumpConn:Disconnect() end

    -- Bắt sự kiện: Game đổi tốc độ -> Ép lại số của mình
    speedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed ~= TargetWalkSpeed then
            hum.WalkSpeed = TargetWalkSpeed
        end
    end)

    -- Bắt sự kiện: Game đổi độ cao nhảy -> Ép lại số của mình
    jumpConn = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if hum.JumpPower ~= TargetJumpPower then
            hum.JumpPower = TargetJumpPower
        end
    end)

    -- Cài đặt số ngay lập tức
    hum.WalkSpeed = TargetWalkSpeed
    hum.JumpPower = TargetJumpPower
end

LocalPlayer.CharacterAdded:Connect(ApplyAndLockStats)
if LocalPlayer.Character then ApplyAndLockStats(LocalPlayer.Character) end

-- =========================================================================
-- 3. HÀM KÉO THẢ TỐI ƯU CHO MOBILE (CẢM ỨNG) & PC
-- =========================================================================
local function MakeDraggable(guiObject)
    local dragging = false
    local dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)

    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
end

-- =========================================================================
-- 4. KHỞI TẠO GIAO DIỆN CHÍNH
-- =========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FullStatMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetGui

-- Nút Tròn Mở Menu (Thu nhỏ)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 11
OpenBtn.Visible = false -- Ẩn lúc đầu vì Menu chính đang hiện
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 255, 255)
MakeDraggable(OpenBtn) -- Cho phép kéo nút tròn

-- Khung Menu Chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 130)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.35
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(MainFrame) -- Cho phép kéo menu chính bằng cảm ứng mobile

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "CONTROL PANEL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Nút X Đóng Menu
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

-- Lệnh chuyển đổi Đóng / Mở
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- =========================================================================
-- 5. TẠO CÁC Ô NHẬP SỐ
-- =========================================================================
local function CreateInputField(posY, labelName, defaultNumber, isWalkSpeed)
    local Frame = Instance.new("Frame", MainFrame)
    Frame.Size = UDim2.new(0.9, 0, 0, 35)
    Frame.Position = UDim2.new(0.05, 0, 0, posY)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Text = labelName
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(0.45, 0, 0.8, 0)
    Box.Position = UDim2.new(0.55, 0, 0.1, 0)
    Box.Text = tostring(defaultNumber)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 5)

    -- Khi người dùng nhập xong và bấm ra ngoài
    Box.FocusLost:Connect(function()
        local num = tonumber(Box.Text)
        if num then
            if isWalkSpeed then
                TargetWalkSpeed = math.clamp(num, 16, 350)
                Box.Text = tostring(TargetWalkSpeed)
            else
                TargetJumpPower = math.clamp(num, 16, 150)
                Box.Text = tostring(TargetJumpPower)
            end
            -- Cập nhật ngay lập tức
            if LocalPlayer.Character then ApplyAndLockStats(LocalPlayer.Character) end
        else
            -- Nếu nhập chữ linh tinh, trả về số hiện tại
            Box.Text = tostring(isWalkSpeed and TargetWalkSpeed or TargetJumpPower)
        end
    end)
end

-- Tạo ô nhập Tốc độ (WalkSpeed)
CreateInputField(35, "Walk Speed:", 16, true)

-- Tạo ô nhập Độ cao nhảy (JumpPower)
CreateInputField(75, "Jump Power:", 50, false)

-- Thông báo chạy xong góc màn hình
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Thành Công",
        Text = "Script đã load hoàn tất 100%!",
        Duration = 3
    })
end)
