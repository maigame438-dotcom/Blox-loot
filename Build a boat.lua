--[[
    🚤 BUILD HUB - GIAO DIỆN HIỆN ĐẠI
    Chức năng: Giao diện Menu Hub chuyên nghiệp
    Yêu cầu: Chỉ tạo giao diện và logic bật/tắt (hoàn toàn bằng Tiếng Việt)
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 1. TẠO KHUNG GIAO DIỆN CHÍNH (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GiaoDienBuildHub"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Bảng lưu trạng thái của các nút bấm
local TrangThaiNut = {
    ["Tự Động Xây"] = false,
    ["Tự Nhặt Kho Báu"] = false,
    ["Cày Vàng"] = false,
    ["Chế Độ AFK"] = false,
    ["Màn Hình Đen"] = false,
    ["Cài Đặt"] = false,
    ["Thông Tin"] = false
}

-- 2. NÚT MỞ MENU (☰)
local nutMoMenu = Instance.new("TextButton")
nutMoMenu.Name = "NutMoMenu"
nutMoMenu.Size = UDim2.new(0, 50, 0, 50)
nutMoMenu.Position = UDim2.new(0, 10, 0.5, -25)
nutMoMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
nutMoMenu.Text = "☰"
nutMoMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
nutMoMenu.TextSize = 25
nutMoMenu.ZIndex = 10
nutMoMenu.Parent = screenGui

local boGocNutMo = Instance.new("UICorner")
boGocNutMo.CornerRadius = UDim.new(1, 0)
boGocNutMo.Parent = nutMoMenu

-- 3. KHUNG MENU CHÍNH
local khungChinh = Instance.new("Frame")
khungChinh.Name = "KhungChinh"
khungChinh.Size = UDim2.new(0, 350, 0, 450)
khungChinh.Position = UDim2.new(0.5, -175, 0.5, -225)
khungChinh.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
khungChinh.BorderSizePixel = 0
khungChinh.Visible = false
khungChinh.ClipsDescendants = true
khungChinh.Parent = screenGui

local boGocKhungChinh = Instance.new("UICorner")
boGocKhungChinh.CornerRadius = UDim.new(0, 15)
boGocKhungChinh.Parent = khungChinh

-- Thanh Tiêu Đề
local thanhTieuDe = Instance.new("Frame")
thanhTieuDe.Name = "ThanhTieuDe"
thanhTieuDe.Size = UDim2.new(1, 0, 0, 50)
thanhTieuDe.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
thanhTieuDe.Parent = khungChinh

local boGocTieuDe = Instance.new("UICorner")
boGocTieuDe.CornerRadius = UDim.new(0, 15)
boGocTieuDe.Parent = thanhTieuDe

local chuTieuDe = Instance.new("TextLabel")
chuTieuDe.Text = "🚤 Trạm Build Hub"
chuTieuDe.Size = UDim2.new(0.6, 0, 1, 0)
chuTieuDe.Position = UDim2.new(0, 15, 0, 0)
chuTieuDe.BackgroundTransparency = 1
chuTieuDe.TextColor3 = Color3.fromRGB(0, 200, 255)
chuTieuDe.TextSize = 20
chuTieuDe.Font = Enum.Font.GothamBold
chuTieuDe.TextXAlignment = Enum.TextXAlignment.Left
chuTieuDe.Parent = thanhTieuDe

-- Nút Đóng Menu (✕)
local nutDong = Instance.new("TextButton")
nutDong.Text = "✕"
nutDong.Size = UDim2.new(0, 30, 0, 30)
nutDong.Position = UDim2.new(1, -40, 0, 10)
nutDong.BackgroundTransparency = 1
nutDong.TextColor3 = Color3.fromRGB(255, 80, 80)
nutDong.TextSize = 20
nutDong.Parent = thanhTieuDe

-- Khung Hiển Thị FPS & Đồng Hồ
local hienThiThongSo = Instance.new("TextLabel")
hienThiThongSo.Size = UDim2.new(1, -20, 0, 20)
hienThiThongSo.Position = UDim2.new(0, 10, 1, -25)
hienThiThongSo.BackgroundTransparency = 1
hienThiThongSo.TextColor3 = Color3.fromRGB(150, 150, 150)
hienThiThongSo.TextSize = 12
hienThiThongSo.Font = Enum.Font.Code
hienThiThongSo.TextXAlignment = Enum.TextXAlignment.Right
hienThiThongSo.Parent = khungChinh

-- Khung Cuộn (Chứa danh sách các nút)
local khungCuon = Instance.new("ScrollingFrame")
khungCuon.Size = UDim2.new(1, -20, 1, -90)
khungCuon.Position = UDim2.new(0, 10, 0, 60)
khungCuon.BackgroundTransparency = 1
khungCuon.ScrollBarThickness = 2
khungCuon.CanvasSize = UDim2.new(0, 0, 1.2, 0)
khungCuon.Parent = khungChinh

local sapXepDanhSach = Instance.new("UIListLayout")
sapXepDanhSach.Padding = UDim.new(0, 10)
sapXepDanhSach.Parent = khungCuon

-- 4. LỚP PHỦ MÀN HÌNH ĐEN (Tiết kiệm pin khi AFK)
local lopPhuDen = Instance.new("Frame")
lopPhuDen.Size = UDim2.new(1, 0, 1, 0)
lopPhuDen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lopPhuDen.Visible = false
lopPhuDen.ZIndex = 8
lopPhuDen.Parent = screenGui

-- 5. HÀM TẠO NÚT BẬT/TẮT (TOGGLE)
local function taoNutBatTat(tenChucNang, bieuTuong)
    local khungNut = Instance.new("Frame")
    khungNut.Size = UDim2.new(1, -10, 0, 45)
    khungNut.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    khungNut.Parent = khungCuon
    
    local boGocKhungNut = Instance.new("UICorner")
    boGocKhungNut.CornerRadius = UDim.new(0, 8)
    boGocKhungNut.Parent = khungNut
    
    local chuChucNang = Instance.new("TextLabel")
    chuChucNang.Text = bieuTuong .. " " .. tenChucNang
    chuChucNang.Size = UDim2.new(0.65, 0, 1, 0)
    chuChucNang.Position = UDim2.new(0, 10, 0, 0)
    chuChucNang.BackgroundTransparency = 1
    chuChucNang.TextColor3 = Color3.fromRGB(255, 255, 255)
    chuChucNang.TextSize = 13
    chuChucNang.Font = Enum.Font.GothamMedium
    chuChucNang.TextXAlignment = Enum.TextXAlignment.Left
    chuChucNang.Parent = khungNut
    
    local khuVucBam = Instance.new("TextButton")
    khuVucBam.Name = "CongTac"
    khuVucBam.Size = UDim2.new(0, 60, 0, 25)
    khuVucBam.Position = UDim2.new(1, -70, 0.5, -12)
    khuVucBam.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    khuVucBam.Text = "TẮT"
    khuVucBam.TextColor3 = Color3.fromRGB(200, 200, 200)
    khuVucBam.TextSize = 11
    khuVucBam.Font = Enum.Font.GothamBold
    khuVucBam.Parent = khungNut
    
    local boGocCongTac = Instance.new("UICorner")
    boGocCongTac.CornerRadius = UDim.new(1, 0)
    boGocCongTac.Parent = khuVucBam

    -- Xử lý sự kiện khi nhấn nút Bật/Tắt
    khuVucBam.MouseButton1Click:Connect(function()
        TrangThaiNut[tenChucNang] = not TrangThaiNut[tenChucNang]
        
        if TrangThaiNut[tenChucNang] then
            -- Chuyển sang trạng thái BẬT
            TweenService:Create(khuVucBam, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}):Play()
            khuVucBam.Text = "BẬT"
            khuVucBam.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- Nếu là nút Màn Hình Đen thì hiển thị lớp phủ
            if tenChucNang == "Màn Hình Đen" then lopPhuDen.Visible = true end
        else
            -- Chuyển về trạng thái TẮT
            TweenService:Create(khuVucBam, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            khuVucBam.Text = "TẮT"
            khuVucBam.TextColor3 = Color3.fromRGB(200, 200, 200)
            
            -- Tắt lớp phủ nếu đang ở chức năng Màn Hình Đen
            if tenChucNang == "Màn Hình Đen" then lopPhuDen.Visible = false end
        end
    end)
end

-- Khởi tạo các nút vào danh sách
taoNutBatTat("Tự Động Xây", "🏗️")
taoNutBatTat("Tự Nhặt Kho Báu", "🏆")
taoNutBatTat("Cày Vàng", "💰")
taoNutBatTat("Chế Độ AFK", "💤")
taoNutBatTat("Màn Hình Đen", "⚫")
taoNutBatTat("Cài Đặt", "⚙️")
taoNutBatTat("Thông Tin", "ℹ️")

-- 6. LOGIC MỞ & ĐÓNG MENU CÓ HIỆU ỨNG MƯỢT MÀ
local function dieuKhienMenu(trangThai)
    if trangThai then
        -- Mở Menu
        khungChinh.Visible = true
        khungChinh.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(khungChinh, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 350, 0, 450)}):Play()
        nutMoMenu.Visible = false
    else
        -- Đóng Menu
        local hieuUngDong = TweenService:Create(khungChinh, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 0, 0)})
        hieuUngDong:Play()
        hieuUngDong.Completed:Connect(function()
            khungChinh.Visible = false
            nutMoMenu.Visible = true
        end)
    end
end

nutMoMenu.MouseButton1Click:Connect(function() dieuKhienMenu(true) end)
nutDong.MouseButton1Click:Connect(function() dieuKhienMenu(false) end)

-- 7. LOGIC KÉO THẢ MENU (Chỉ cần nắm thanh tiêu đề để kéo)
local dangKeo, viTriBatDauChot, viTriBatDauKhung

thanhTieuDe.InputBegan:Connect(function(thaoTac)
    if thaoTac.UserInputType == Enum.UserInputType.MouseButton1 or thaoTac.UserInputType == Enum.UserInputType.Touch then
        dangKeo = true
        viTriBatDauChot = thaoTac.Position
        viTriBatDauKhung = khungChinh.Position
    end
end)

UserInputService.InputChanged:Connect(function(thaoTac)
    if dangKeo and (thaoTac.UserInputType == Enum.UserInputType.MouseMovement or thaoTac.UserInputType == Enum.UserInputType.Touch) then
        local doLech = thaoTac.Position - viTriBatDauChot
        khungChinh.Position = UDim2.new(
            viTriBatDauKhung.X.Scale, viTriBatDauKhung.X.Offset + doLech.X, 
            viTriBatDauKhung.Y.Scale, viTriBatDauKhung.Y.Offset + doLech.Y
        )
    end
end)

thanhTieuDe.InputEnded:Connect(function(thaoTac)
    if thaoTac.UserInputType == Enum.UserInputType.MouseButton1 or thaoTac.UserInputType == Enum.UserInputType.Touch then
        dangKeo = false
    end
end)

-- 8. CẬP NHẬT ĐỒNG HỒ & CHỈ SỐ FPS LIÊN TỤC
local thoiGianTruoc, soKhungHinh = tick(), 0
RunService.RenderStepped:Connect(function()
    soKhungHinh = soKhungHinh + 1
    if tick() - thoiGianTruoc >= 1 then
        local fpsHienTai = soKhungHinh
        local thoiGianThuc = os.date("%H:%M:%S")
        hienThiThongSo.Text = "FPS: " .. fpsHienTai .. " | Thời gian: " .. thoiGianThuc
        soKhungHinh = 0
        thoiGianTruoc = tick()
    end
end)

print("🚤 Đã tải giao diện Build Hub thành công!")
