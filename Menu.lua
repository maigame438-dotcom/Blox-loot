bản chỉnh sửa bởi Doi
văn bản

```lua
-- // Script Red Hub Clone - Sửa lỗi màn hình đen không bao phủ hết // --
-- // Đảm bảo: Màn hình đen phủ kín 100% mọi không gian kể cả thanh công cụ // --

local NguoiChoi = game:GetService("Players").LocalPlayer
local DichVuNguoiDung = game:GetService("UserInputService")
local DichVuChay = game:GetService("RunService")

-- Biến trạng thái
local MauChuDao = Color3.fromRGB(255, 0, 0)
local TrangThaiCauVong = false
local GiaTriCauVong = 0
local MenuDangMo = false
local ManHinhDenDangBat = false
local FPSDangHien = false
local GUIGocDaAn = false
local KetNoiCauVong = nil

-- Danh sách màu
local BangMau = {
    {Ten = "Đỏ", Mau = Color3.fromRGB(255, 0, 0)},
    {Ten = "Xanh Dương", Mau = Color3.fromRGB(0, 150, 255)},
    {Ten = "Xanh Lá", Mau = Color3.fromRGB(0, 255, 0)},
    {Ten = "Tím", Mau = Color3.fromRGB(128, 0, 128)},
    {Ten = "Vàng", Mau = Color3.fromRGB(255, 255, 0)},
    {Ten = "Đen Tím", Mau = Color3.fromRGB(30, 0, 30)},
    {Ten = "Hồng", Mau = Color3.fromRGB(255, 105, 180)},
    {Ten = "Cam", Mau = Color3.fromRGB(255, 165, 0)},
    {Ten = "Trắng", Mau = Color3.fromRGB(255, 255, 255)},
    {Ten = "Xanh Mint", Mau = Color3.fromRGB(0, 255, 128)},
}

-- Tạo GUI chính trong CoreGui
local ManHinhChinh = Instance.new("ScreenGui")
ManHinhChinh.Name = "RedHub_Clone_Main"
ManHinhChinh.Parent = game.CoreGui
ManHinhChinh.IgnoreGuiInset = true -- Bỏ qua khoảng cách viền màn hình
ManHinhChinh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- =================== XÂY DỰNG MÀN HÌNH ĐEN TUYỆT ĐỐI =================== --
local ManHinhDenGUI = Instance.new("ScreenGui")
ManHinhDenGUI.Name = "ManHinhDenGUI"
ManHinhDenGUI.Parent = game.CoreGui
ManHinhDenGUI.IgnoreGuiInset = true
ManHinhDenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ManHinhDenGUI.Enabled = false

-- Lớp đen chính - kích thước tuyệt đối để chắc chắn bao phủ toàn bộ
local LopDen1 = Instance.new("Frame")
LopDen1.Name = "LopDen1"
LopDen1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LopDen1.BorderSizePixel = 0
LopDen1.Size = UDim2.new(1, 0, 1, 0)
LopDen1.Position = UDim2.new(0, 0, 0, 0)
LopDen1.ZIndex = 9999
LopDen1.Parent = ManHinhDenGUI

-- Lớp đen thứ 2 (dự phòng) - đảm bảo không có khe hở
local LopDen2 = Instance.new("Frame")
LopDen2.Name = "LopDen2"
LopDen2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LopDen2.BorderSizePixel = 0
LopDen2.Size = UDim2.new(1, 0, 1, 0)
LopDen2.Position = UDim2.new(0, 0, 0, 0)
LopDen2.ZIndex = 10000
LopDen2.Parent = ManHinhDenGUI

-- =================== NÚT MỞ MENU CHÍNH (LUÔN HIỂN THỊ) =================== --
local NutMoMenu = Instance.new("ImageButton")
NutMoMenu.Name = "NutMoMenu"
NutMoMenu.BackgroundColor3 = MauChuDao
NutMoMenu.BorderSizePixel = 0
NutMoMenu.Size = UDim2.new(0, 45, 0, 45)
NutMoMenu.Position = UDim2.new(0, 10, 0.5, -22)
NutMoMenu.ZIndex = 1001
NutMoMenu.Image = "rbxassetid://0"
NutMoMenu.Parent = ManHinhChinh

local VanBanNut = Instance.new("TextLabel")
VanBanNut.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VanBanNut.BackgroundTransparency = 0.3
VanBanNut.BorderSizePixel = 0
VanBanNut.Size = UDim2.new(1, 0, 1, 0)
VanBanNut.Font = Enum.Font.SourceSansBold
VanBanNut.Text = "RH"
VanBanNut.TextColor3 = Color3.fromRGB(255, 255, 255)
VanBanNut.TextSize = 20
VanBanNut.ZIndex = 1002
VanBanNut.Parent = NutMoMenu

-- =================== MENU CHÍNH =================== --
local KhungMenu = Instance.new("Frame")
KhungMenu.Name = "KhungMenuChinh"
KhungMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KhungMenu.BorderSizePixel = 1
KhungMenu.BorderColor3 = MauChuDao
KhungMenu.Size = UDim2.new(0, 280, 0, 400)
KhungMenu.Position = UDim2.new(0, 60, 0.5, -200)
KhungMenu.ZIndex = 1001
KhungMenu.Visible = false
KhungMenu.Parent = ManHinhChinh

-- Góc tạo điểm nhấn đỏ (style Red Hub)
local GocTraiTren = Instance.new("Frame")
GocTraiTren.BackgroundColor3 = MauChuDao
GocTraiTren.BorderSizePixel = 0
GocTraiTren.Size = UDim2.new(0, 3, 0, 30)
GocTraiTren.Position = UDim2.new(0, 0, 0, 0)
GocTraiTren.ZIndex = 1002
GocTraiTren.Parent = KhungMenu

local GocPhaiTren = Instance.new("Frame")
GocPhaiTren.BackgroundColor3 = MauChuDao
GocPhaiTren.BorderSizePixel = 0
GocPhaiTren.Size = UDim2.new(0, 3, 0, 30)
GocPhaiTren.Position = UDim2.new(1, -3, 0, 0)
GocPhaiTren.ZIndex = 1002
GocPhaiTren.Parent = KhungMenu

-- Thanh tiêu đề menu
local ThanhTieuDe = Instance.new("Frame")
ThanhTieuDe.BackgroundColor3 = MauChuDao
ThanhTieuDe.BorderSizePixel = 0
ThanhTieuDe.Size = UDim2.new(1, 0, 0, 30)
ThanhTieuDe.Position = UDim2.new(0, 0, 0, 0)
ThanhTieuDe.ZIndex = 1002
ThanhTieuDe.Parent = KhungMenu

local TieuDeChu = Instance.new("TextLabel")
TieuDeChu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TieuDeChu.BackgroundTransparency = 1
TieuDeChu.BorderSizePixel = 0
TieuDeChu.Size = UDim2.new(1, -40, 1, 0)
TieuDeChu.Position = UDim2.new(0, 10, 0, 0)
TieuDeChu.Font = Enum.Font.SourceSansBold
TieuDeChu.Text = "Red Hub V2"
TieuDeChu.TextColor3 = Color3.fromRGB(255, 255, 255)
TieuDeChu.TextSize = 16
TieuDeChu.TextXAlignment = Enum.TextXAlignment.Left
TieuDeChu.ZIndex = 1003
TieuDeChu.Parent = ThanhTieuDe

local NutDongMenu = Instance.new("TextButton")
NutDongMenu.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
NutDongMenu.BorderSizePixel = 0
NutDongMenu.Size = UDim2.new(0, 30, 0, 20)
NutDongMenu.Position = UDim2.new(1, -35, 0, 5)
NutDongMenu.Font = Enum.Font.SourceSansBold
NutDongMenu.Text = "X"
NutDongMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
NutDongMenu.TextSize = 14
NutDongMenu.ZIndex = 1003
NutDongMenu.Parent = ThanhTieuDe
NutDongMenu.MouseButton1Click:Connect(function()
    MenuDangMo = false
    KhungMenu.Visible = false
end)

-- Khung nội dung menu
local KhungNoiDung = Instance.new("ScrollingFrame")
KhungNoiDung.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
KhungNoiDung.BorderSizePixel = 0
KhungNoiDung.Size = UDim2.new(1, -6, 1, -36)
KhungNoiDung.Position = UDim2.new(0, 3, 0, 33)
KhungNoiDung.CanvasSize = UDim2.new(0, 0, 2.5, 0)
KhungNoiDung.ScrollBarThickness = 4
KhungNoiDung.ScrollBarImageColor3 = MauChuDao
KhungNoiDung.ZIndex = 1002
KhungNoiDung.Parent = KhungMenu

local BoCuc = Instance.new("UIListLayout")
BoCuc.Parent = KhungNoiDung
BoCuc.SortOrder = Enum.SortOrder.LayoutOrder
BoCuc.Padding = UDim.new(0, 4)

-- =================== CÁC HÀM XÂY DỰNG PHẦN TỬ MENU =================== --
local function TaoPhanCach(TieuDe)
    local Khung = Instance.new("Frame")
    Khung.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Khung.BorderSizePixel = 0
    Khung.Size = UDim2.new(1, -10, 0, 25)
    Khung.ZIndex = 1003
    Khung.Parent = KhungNoiDung
    
    local Chu = Instance.new("TextLabel")
    Chu.BackgroundTransparency = 1
    Chu.Size = UDim2.new(1, 0, 1, 0)
    Chu.Font = Enum.Font.SourceSansBold
    Chu.Text = TieuDe
    Chu.TextColor3 = MauChuDao
    Chu.TextSize = 13
    Chu.TextXAlignment = Enum.TextXAlignment.Left
    Chu.ZIndex = 1004
    Chu.Parent = Khung
    return Khung
end

local function TaoNutChucNang(Ten, HamGoi)
    local Nut = Instance.new("TextButton")
    Nut.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Nut.BorderSizePixel = 1
    Nut.BorderColor3 = MauChuDao
    Nut.Size = UDim2.new(1, -10, 0, 32)
    Nut.Font = Enum.Font.SourceSans
    Nut.Text = Ten
    Nut.TextColor3 = Color3.fromRGB(255, 255, 255)
    Nut.TextSize = 14
    Nut.ZIndex = 1003
    Nut.Parent = KhungNoiDung
    
    Nut.MouseButton1Click:Connect(HamGoi)
    Nut.MouseEnter:Connect(function() Nut.BackgroundColor3 = MauChuDao end)
    Nut.MouseLeave:Connect(function() Nut.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)
    return Nut
end

local function TaoThanhTruot(Ten, Min, Max, MacDinh, HamGoi)
    local Khung = Instance.new("Frame")
    Khung.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Khung.BorderSizePixel = 1
    Khung.BorderColor3 = MauChuDao
    Khung.Size = UDim2.new(1, -10, 0, 50)
    Khung.ZIndex = 1003
    Khung.Parent = KhungNoiDung
    
    local Nhan = Instance.new("TextLabel")
    Nhan.BackgroundTransparency = 1
    Nhan.Size = UDim2.new(1, 0, 0, 20)
    Nhan.Position = UDim2.new(0, 5, 0, 3)
    Nhan.Font = Enum.Font.SourceSans
    Nhan.Text = Ten .. ": " .. MacDinh
    Nhan.TextColor3 = Color3.fromRGB(255, 255, 255)
    Nhan.TextSize = 12
    Nhan.TextXAlignment = Enum.TextXAlignment.Left
    Nhan.ZIndex = 1004
    Nhan.Parent = Khung
    
    local ThanhNen = Instance.new("Frame")
    ThanhNen.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ThanhNen.BorderSizePixel = 0
    ThanhNen.Size = UDim2.new(1, -10, 0, 8)
    ThanhNen.Position = UDim2.new(0, 5, 0, 26)
    ThanhNen.ZIndex = 1004
    ThanhNen.Parent = Khung
    
    local NutKeo = Instance.new("TextButton")
    NutKeo.BackgroundColor3 = MauChuDao
    NutKeo.BorderSizePixel = 0
    NutKeo.Size = UDim2.new(0, 16, 0, 16)
    NutKeo.Position = UDim2.new(0, 0, 0.5, -8)
    NutKeo.Text = ""
    NutKeo.ZIndex = 1005
    NutKeo.Parent = ThanhNen
    
    local DangKeo = false
    NutKeo.MouseButton1Down:Connect(function() DangKeo = true end)
    DichVuNguoiDung.InputEnded:Connect(function(DauVao)
        if DauVao.UserInputType == Enum.UserInputType.MouseButton1 then DangKeo = false end
    end)
    DichVuNguoiDung.InputChanged:Connect(function(DauVao)
        if DangKeo and DauVao.UserInputType == Enum.UserInputType.MouseMovement then
            local TyLe = math.clamp((DauVao.Position.X - ThanhNen.AbsolutePosition.X) / ThanhNen.AbsoluteSize.X, 0, 1)
            local GiaTri = Min + (Max - Min) * TyLe
            NutKeo.Position = UDim2.new(TyLe, -8, 0.5, -8)
            Nhan.Text = Ten .. ": " .. math.floor(GiaTri)
            HamGoi(GiaTri)
        end
    end)
    return Khung
end

-- =================== CẬP NHẬT MÀU SẮC TOÀN BỘ GIAO DIỆN =================== --
local function CapNhatMauSac()
    ThanhTieuDe.BackgroundColor3 = MauChuDao
    GocTraiTren.BackgroundColor3 = MauChuDao
    GocPhaiTren.BackgroundColor3 = MauChuDao
    NutMoMenu.BackgroundColor3 = MauChuDao
    KhungMenu.BorderColor3 = MauChuDao
    KhungNoiDung.ScrollBarImageColor3 = MauChuDao
    
    for _, Con in ipairs(KhungNoiDung:GetChildren()) do
        if Con:IsA("TextButton") and Con.Name:find("Nut_") then
            Con.BorderColor3 = MauChuDao
        elseif Con:IsA("Frame") and Con.Name:find("Truot_") then
            Con.BorderColor3 = MauChuDao
            for _, Chau in ipairs(Con:GetChildren()) do
                if Chau.Name == "NutKeo" then Chau.BackgroundColor3 = MauChuDao end
            end
        elseif Con:IsA("Frame") and Con.Name:find("PhanCach_") then
            for _, Chau in ipairs(Con:GetChildren()) do
                if Chau:IsA("TextLabel") then Chau.TextColor3 = MauChuDao end
            end
        end
    end
end

local function BatCauVong()
    TrangThaiCauVong = true
    if KetNoiCauVong then KetNoiCauVong:Disconnect() end
    KetNoiCauVong = DichVuChay.RenderStepped:Connect(function()
        GiaTriCauVong = GiaTriCauVong + 0.005
        if GiaTriCauVong > 1 then GiaTriCauVong = 0 end
        MauChuDao = Color3.fromHSV(GiaTriCauVong, 1, 1)
        CapNhatMauSac()
    end)
end

-- =================== NỘI DUNG MENU =================== --
TaoPhanCach("⚙ Chức Năng Chính")

-- Nút màn hình đen
TaoNutChucNang("Màn Hình Đen: TẮT", function()
    ManHinhDenDangBat = not ManHinhDenDangBat
    ManHinhDenGUI.Enabled = ManHinhDenDangBat
    local Nut = KhungNoiDung:FindFirstChild("Nut_Màn Hình Đen: TẮT") or KhungNoiDung:FindFirstChild("Nut_Màn Hình Đen: BẬT")
    if Nut then Nut.Text = ManHinhDenDangBat and "Màn Hình Đen: BẬT" or "Màn Hình Đen: TẮT" end
end)

-- Nút ẩn GUI game
TaoNutChucNang("Ẩn GUI Game: TẮT", function()
    GUIGocDaAn = not GUIGocDaAn
    pcall(function()
        local PlayerGui = NguoiChoi:FindFirstChild("PlayerGui")
        if PlayerGui then
            for _, Gui in ipairs(PlayerGui:GetChildren()) do
                if Gui:IsA("ScreenGui") or Gui:IsA("SurfaceGui") then
                    Gui.Enabled = not GUIGocDaAn
                end
            end
        end
    end)
    local Nut = KhungNoiDung:FindFirstChild("Nut_Ẩn GUI Game: TẮT") or KhungNoiDung:FindFirstChild("Nut_Ẩn GUI Game: BẬT")
    if Nut then Nut.Text = GUIGocDaAn and "Ẩn GUI Game: BẬT" or "Ẩn GUI Game: TẮT" end
end)

-- Nút hiển thị FPS
local KhungFPS = nil
TaoNutChucNang("Hiện FPS: TẮT", function()
    FPSDangHien = not FPSDangHien
    local Nut = KhungNoiDung:FindFirstChild("Nut_Hiện FPS: TẮT") or KhungNoiDung:FindFirstChild("Nut_Hiện FPS: BẬT")
    if Nut then Nut.Text = FPSDangHien and "Hiện FPS: BẬT" or "Hiện FPS: TẮT" end
    
    if FPSDangHien then
        if not KhungFPS then
            KhungFPS = Instance.new("Frame")
            KhungFPS.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            KhungFPS.BackgroundTransparency = 0.4
            KhungFPS.BorderSizePixel = 1
            KhungFPS.BorderColor3 = MauChuDao
            KhungFPS.Size = UDim2.new(0, 70, 0, 25)
            KhungFPS.Position = UDim2.new(1, -80, 0, 10)
            KhungFPS.ZIndex = 1001
            KhungFPS.Parent = ManHinhChinh
            
            local ChuFPS = Instance.new("TextLabel")
            ChuFPS.BackgroundTransparency = 1
            ChuFPS.Size = UDim2.new(1, 0, 1, 0)
            ChuFPS.Font = Enum.Font.SourceSansBold
            ChuFPS.Text = "FPS: 60"
            ChuFPS.TextColor3 = Color3.fromRGB(0, 255, 0)
            ChuFPS.TextSize = 14
            ChuFPS.ZIndex = 1002
            ChuFPS.Parent = KhungFPS
            
            spawn(function()
                local LanCuoi = tick()
                local Dem = 0
                while FPSDangHien and KhungFPS do
                    Dem = Dem + 1
                    if tick() - LanCuoi >= 0.2 then
                        local FPS = math.floor(Dem / (tick() - LanCuoi))
                        ChuFPS.Text = "FPS: " .. FPS
                        LanCuoi = tick()
                        Dem = 0
                    end
                    DichVuChay.RenderStepped:Wait()
                end
            end)
        else
            KhungFPS.Visible = true
        end
    else
        if KhungFPS then KhungFPS.Visible = false end
    end
end)

TaoPhanCach("📏 Kích Thước Menu")

TaoThanhTruot("Rộng", 200, 500, 280, function(GiaTri)
    KhungMenu.Size = UDim2.new(0, GiaTri, 0, KhungMenu.Size.Y.Offset)
end)

TaoThanhTruot("Cao", 300, 600, 400, function(GiaTri)
    KhungMenu.Size = UDim2.new(0, KhungMenu.Size.X.Offset, 0, GiaTri)
end)

TaoPhanCach("🎨 Màu Sắc")

local KhungMau = Instance.new("Frame")
KhungMau.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KhungMau.BorderSizePixel = 1
KhungMau.BorderColor3 = MauChuDao
KhungMau.Size = UDim2.new(1, -10, 0, 80)
KhungMau.ZIndex = 1003
KhungMau.Parent = KhungNoiDung

for STT, Mau in ipairs(BangMau) do
    local NutMau = Instance.new("TextButton")
    NutMau.BackgroundColor3 = Mau.Mau
    NutMau.BorderSizePixel = 1
    NutMau.BorderColor3 = Color3.fromRGB(255, 255, 255)
    NutMau.Size = UDim2.new(0, 24, 0, 24)
    local Cot = (STT - 1) % 8
    local Hang = math.floor((STT - 1) / 8)
    NutMau.Position = UDim2.new(0, 5 + Cot * 29, 0, 5 + Hang * 29)
    NutMau.Text = ""
    NutMau.ZIndex = 1004
    NutMau.Parent = KhungMau
    
    NutMau.MouseButton1Click:Connect(function()
        MauChuDao = Mau.Mau
        TrangThaiCauVong = false
        if KetNoiCauVong then KetNoiCauVong:Disconnect(); KetNoiCauVong = nil end
        CapNhatMauSac()
    end)
end

TaoNutChucNang("Cầu Vồng: TẮT", function()
    if TrangThaiCauVong then
        TrangThaiCauVong = false
        if KetNoiCauVong then KetNoiCauVong:Disconnect(); KetNoiCauVong = nil end
        local Nut = KhungNoiDung:FindFirstChild("Nut_Cầu Vồng: BẬT")
        if Nut then Nut.Text = "Cầu Vồng: TẮT" end
    else
        BatCauVong()
        local Nut = KhungNoiDung:FindFirstChild("Nut_Cầu Vồng: TẮT")
        if Nut then Nut.Text = "Cầu Vồng: BẬT" end
    end
end)

-- =================== SỰ KIỆN ĐÓNG MỞ MENU =================== --
NutMoMenu.MouseButton1Click:Connect(function()
    MenuDangMo = not MenuDangMo
    KhungMenu.Visible = MenuDangMo
end)

-- Cho phép kéo menu
local DangKeoMenu = false
local ViTriLech = Vector2.new(0, 0)
ThanhTieuDe.InputBegan:Connect(function(DauVao)
    if DauVao.UserInputType == Enum.UserInputType.MouseButton1 then
        DangKeoMenu = true
        ViTriLech = Vector2.new(DauVao.Position.X - KhungMenu.AbsolutePosition.X, DauVao.Position.Y - KhungMenu.AbsolutePosition.Y)
    end
end)
DichVuNguoiDung.InputEnded:Connect(function(DauVao)
    if DauVao.UserInputType == Enum.UserInputType.MouseButton1 then DangKeoMenu = false end
end)
DichVuNguoiDung.InputChanged:Connect(function(DauVao)
    if DangKeoMenu and DauVao.UserInputType == Enum.UserInputType.MouseMovement then
        KhungMenu.Position = UDim2.new(0, DauVao.Position.X - ViTriLech.X, 0, DauVao.Position.Y - ViTriLech.Y)
    end
end)

print("Red Hub Clone đã khởi động. Màn hình đen đã được sửa lỗi.")
```
