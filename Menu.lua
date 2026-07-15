-- Khởi tạo các biến toàn cục
local MauNen = Color3.fromRGB(0, 0, 0) -- Màu nền đen mặc định
local DanhSachMau = {
    {"Xanh", Color3.fromRGB(0, 255, 0)},
    {"Đỏ", Color3.fromRGB(255, 0, 0)},
    {"Tím", Color3.fromRGB(128, 0, 128)},
    {"Vàng", Color3.fromRGB(255, 255, 0)},
    {"Đen Tím", Color3.fromRGB(30, 0, 30)},
    {"Trắng", Color3.fromRGB(255, 255, 255)},
    {"Cam", Color3.fromRGB(255, 165, 0)},
    {"Hồng", Color3.fromRGB(255, 105, 180)}
}
local TrangThaiCauVong = false -- Trạng thái màu cầu vồng
local GiaTriCauVong = 0 -- Giá trị màu cho hiệu ứng cầu vồng
local KichThuocMenu = Vector2.new(250, 300) -- Kích thước menu mặc định
local ViTriMenu = Vector2.new(50, 100) -- Vị trí menu
local MenuMo = false -- Trạng thái mở/đóng menu
local AnGuiGoc = false -- Trạng thái ẩn GUI gốc của game
local HienThiFPS = false -- Trạng thái hiển thị FPS
local ManHinhDen = nil -- Màn hình đen che phủ

-- Tạo giao diện người dùng chính
local HinhAnhManHinhDen = Instance.new("ScreenGui")
HinhAnhManHinhDen.Name = "ManHinhDenGUI"
HinhAnhManHinhDen.Parent = game.CoreGui -- Sử dụng CoreGui để tránh bị phát hiện dễ dàng
HinhAnhManHinhDen.Enabled = false -- Mặc định tắt

local KhungManHinhDen = Instance.new("Frame")
KhungManHinhDen.Name = "KhungDen"
KhungManHinhDen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KhungManHinhDen.BorderSizePixel = 0
KhungManHinhDen.Size = UDim2.new(1, 0, 1, 0) -- Bao phủ 100% màn hình
KhungManHinhDen.Position = UDim2.new(0, 0, 0, 0)
KhungManHinhDen.ZIndex = 10 -- Đặt ZIndex cao để che phủ mọi thứ
KhungManHinhDen.Active = true -- Cho phép tương tác để chặn click xuyên qua
KhungManHinhDen.Parent = HinhAnhManHinhDen

-- Tạo GUI chứa menu chính
local MenuGUI = Instance.new("ScreenGui")
MenuGUI.Name = "MenuChinhGUI"
MenuGUI.Parent = game.CoreGui
MenuGUI.Enabled = false -- Mặc định tắt

-- Tạo khung menu chính
local KhungMenu = Instance.new("Frame")
KhungMenu.Name = "KhungMenuChinh"
KhungMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Màu đen xám nền menu
KhungMenu.BorderColor3 = Color3.fromRGB(60, 60, 60) -- Viền xám đậm
KhungMenu.BorderSizePixel = 1
KhungMenu.Size = UDim2.new(0, KichThuocMenu.X, 0, KichThuocMenu.Y)
KhungMenu.Position = UDim2.new(0, ViTriMenu.X, 0, ViTriMenu.Y)
KhungMenu.Active = true -- Cho phép kéo thả
KhungMenu.Draggable = true -- Cho phép kéo menu
KhungMenu.ZIndex = 5
KhungMenu.Parent = MenuGUI

-- Tạo thanh tiêu đề của menu
local ThanhTieuDe = Instance.new("TextLabel")
ThanhTieuDe.Name = "ThanhTieuDe"
ThanhTieuDe.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Màu đen
ThanhTieuDe.BorderSizePixel = 0
ThanhTieuDe.Size = UDim2.new(1, 0, 0, 30) -- Chiều cao cố định 30px
ThanhTieuDe.Position = UDim2.new(0, 0, 0, 0)
ThanhTieuDe.Font = Enum.Font.SourceSansBold
ThanhTieuDe.Text = "Menu Chỉnh Sửa"
ThanhTieuDe.TextColor3 = Color3.fromRGB(255, 255, 255)
ThanhTieuDe.TextSize = 16
ThanhTieuDe.ZIndex = 6
ThanhTieuDe.Parent = KhungMenu

-- Tạo vùng chứa có thể cuộn cho các tùy chọn
local KhungCuon = Instance.new("ScrollingFrame")
KhungCuon.Name = "KhungCuon"
KhungCuon.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Nền xám đen cho vùng cuộn
KhungCuon.BorderSizePixel = 0
KhungCuon.Size = UDim2.new(1, -10, 1, -40) -- Chừa chỗ cho thanh tiêu đề và lề
KhungCuon.Position = UDim2.new(0, 5, 0, 35)
KhungCuon.CanvasSize = UDim2.new(0, 0, 2, 0) -- Kích thước canvas gấp đôi để chứa hết nội dung
KhungCuon.ScrollBarThickness = 5
KhungCuon.ZIndex = 6
KhungCuon.Parent = KhungMenu

-- Tạo danh sách bố cục cho khung cuộn
local BoCucDanhSach = Instance.new("UIListLayout")
BoCucDanhSach.Parent = KhungCuon
BoCucDanhSach.SortOrder = Enum.SortOrder.LayoutOrder
BoCucDanhSach.Padding = UDim.new(0, 5)

-- Hàm tạo nút bấm trong menu
local function TaoNut(Ten, ViTriY, HamChucNang)
    local Nut = Instance.new("TextButton")
    Nut.Name = Ten
    Nut.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Màu đen cho nút
    Nut.BorderColor3 = Color3.fromRGB(80, 80, 80) -- Viền xám nhạt
    Nut.BorderSizePixel = 1
    Nut.Size = UDim2.new(1, -10, 0, 30) -- Chiều cao cố định 30px
    Nut.Position = UDim2.new(0, 5, 0, ViTriY)
    Nut.Font = Enum.Font.SourceSans
    Nut.Text = Ten
    Nut.TextColor3 = Color3.fromRGB(255, 255, 255)
    Nut.TextSize = 14
    Nut.ZIndex = 7
    Nut.Parent = KhungCuon
    -- Kết nối sự kiện khi nhấn nút
    Nut.MouseButton1Click:Connect(HamChucNang)
    return Nut
end

-- Hàm tạo nhãn văn bản trong menu
local function TaoNhan(Ten, ViTriY, VanBan)
    local Nhan = Instance.new("TextLabel")
    Nhan.Name = Ten
    Nhan.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Nền xám đen cho nhãn
    Nhan.BorderSizePixel = 0
    Nhan.Size = UDim2.new(1, -10, 0, 20) -- Chiều cao nhỏ hơn nút
    Nhan.Position = UDim2.new(0, 5, 0, ViTriY)
    Nhan.Font = Enum.Font.SourceSans
    Nhan.Text = VanBan
    Nhan.TextColor3 = Color3.fromRGB(200, 200, 200)
    Nhan.TextSize = 12
    Nhan.ZIndex = 7
    Nhan.Parent = KhungCuon
    return Nhan
end

-- Hàm tạo thanh trượt cho menu
local function TaoThanhTruot(Ten, ViTriY, GiaTriMin, GiaTriMax, GiaTriMacDinh, HamThayDoi)
    local ThanhTruot = Instance.new("Frame")
    ThanhTruot.Name = Ten .. "_Khung"
    ThanhTruot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ThanhTruot.BorderSizePixel = 0
    ThanhTruot.Size = UDim2.new(1, -10, 0, 40)
    ThanhTruot.Position = UDim2.new(0, 5, 0, ViTriY)
    ThanhTruot.ZIndex = 7
    ThanhTruot.Parent = KhungCuon

    local NhanThanhTruot = Instance.new("TextLabel")
    NhanThanhTruot.Name = "Nhan"
    NhanThanhTruot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    NhanThanhTruot.BorderSizePixel = 0
    NhanThanhTruot.Size = UDim2.new(1, 0, 0, 20)
    NhanThanhTruot.Position = UDim2.new(0, 0, 0, 0)
    NhanThanhTruot.Font = Enum.Font.SourceSans
    NhanThanhTruot.Text = Ten .. ": " .. tostring(GiaTriMacDinh)
    NhanThanhTruot.TextColor3 = Color3.fromRGB(255, 255, 255)
    NhanThanhTruot.TextSize = 12
    NhanThanhTruot.ZIndex = 8
    NhanThanhTruot.Parent = ThanhTruot

    local NutTruot = Instance.new("TextButton")
    NutTruot.Name = "NutTruot"
    NutTruot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    NutTruot.BorderColor3 = Color3.fromRGB(80, 80, 80)
    NutTruot.BorderSizePixel = 1
    NutTruot.Size = UDim2.new(0, 20, 0, 20)
    NutTruot.Position = UDim2.new(0, 0, 0, 20) -- Đặt bên dưới nhãn
    NutTruot.Font = Enum.Font.SourceSans
    NutTruot.Text = ""
    NutTruot.TextColor3 = Color3.fromRGB(255, 255, 255)
    NutTruot.TextSize = 14
    NutTruot.ZIndex = 8
    NutTruot.Parent = ThanhTruot
    -- Xử lý kéo thanh trượt
    local DangKeo = false
    NutTruot.MouseButton1Down:Connect(function()
        DangKeo = true
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(DauVao)
        if DauVao.UserInputType == Enum.UserInputType.MouseButton1 then
            DangKeo = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(DauVao)
        if DangKeo and DauVao.UserInputType == Enum.UserInputType.MouseMovement then
            local ViTriChuot = DauVao.Position
            local ViTriTuyetDoi = ThanhTruot.AbsolutePosition
            local KichThuocTuyetDoi = ThanhTruot.AbsoluteSize
            local TiLe = math.clamp((ViTriChuot.X - ViTriTuyetDoi.X) / KichThuocTuyetDoi.X, 0, 1)
            local GiaTri = GiaTriMin + (GiaTriMax - GiaTriMin) * TiLe
            NhanThanhTruot.Text = Ten .. ": " .. tostring(math.floor(GiaTri))
            HamThayDoi(GiaTri)
        end
    end)
    return ThanhTruot
end

-- Hàm tạo nút chọn màu sắc
local function TaoNutChonMau(TenMau, Mau, ViTriY)
    local NutMau = Instance.new("TextButton")
    NutMau.Name = "Mau_" .. TenMau
    NutMau.BackgroundColor3 = Mau
    NutMau.BorderColor3 = Color3.fromRGB(255, 255, 255) -- Viền trắng để phân biệt
    NutMau.BorderSizePixel = 1
    NutMau.Size = UDim2.new(0, 25, 0, 25) -- Nút vuông nhỏ
    NutMau.Position = UDim2.new(0, 5, 0, ViTriY)
    NutMau.Font = Enum.Font.SourceSans
    NutMau.Text = ""
    NutMau.TextColor3 = Color3.fromRGB(255, 255, 255)
    NutMau.TextSize = 8
    NutMau.ZIndex = 8
    NutMau.Parent = KhungCuon
    -- Sự kiện khi nhấn chọn màu
    NutMau.MouseButton1Click:Connect(function()
        MauNen = Mau
        TrangThaiCauVong = false -- Tắt cầu vồng khi chọn màu cố định
        -- Cập nhật màu cho tất cả các thành phần liên quan
        KhungMenu.BackgroundColor3 = Mau
        ThanhTieuDe.BackgroundColor3 = Mau
    end)
    return NutMau
end

-- Biến lưu trữ tham chiếu đến các thành phần GUI để thay đổi màu
local TatCaCacThanhPhan = {}

-- Hàm cập nhật màu sắc cho tất cả thành phần
local function CapNhatMauSac(MauMoi)
    for _, ThanhPhan in ipairs(TatCaCacThanhPhan) do
        if ThanhPhan:IsA("TextButton") or ThanhPhan:IsA("Frame") then
            ThanhPhan.BackgroundColor3 = MauMoi
        elseif ThanhPhan:IsA("TextLabel") then
            ThanhPhan.TextColor3 = MauMoi
        end
    end
end

-- Hàm tạo hiệu ứng màu cầu vồng
local function BatDauCauVong()
    TrangThaiCauVong = true
    spawn(function()
        while TrangThaiCauVong do
            GiaTriCauVong = GiaTriCauVong + 0.01
            if GiaTriCauVong > 1 then GiaTriCauVong = 0 end
            local MauCauVong = Color3.fromHSV(GiaTriCauVong, 1, 1)
            KhungMenu.BackgroundColor3 = MauCauVong
            ThanhTieuDe.BackgroundColor3 = MauCauVong
            wait(0.05) -- Cập nhật mỗi 0.05 giây để có hiệu ứng mượt
        end
    end)
end

-- Xây dựng nội dung menu
-- Số thứ tự vị trí Y để sắp xếp các phần tử
local ChiSoY = 0

-- Nút bật/tắt màn hình đen
local NutManHinhDen = TaoNut("Bật/Tắt Màn Hình Đen", ChiSoY, function()
    HinhAnhManHinhDen.Enabled = not HinhAnhManHinhDen.Enabled
    if HinhAnhManHinhDen.Enabled then
        NutManHinhDen.Text = "Tắt Màn Hình Đen"
    else
        NutManHinhDen.Text = "Bật Màn Hình Đen"
    end
end)
ChiSoY = ChiSoY + 35

-- Nút ẩn/hiện GUI gốc của game
local NutAnGui = TaoNut("Ẩn GUI Gốc Game", ChiSoY, function()
    AnGuiGoc = not AnGuiGoc
    if AnGuiGoc then
        NutAnGui.Text = "Hiện GUI Gốc Game"
        -- Tìm và ẩn tất cả GUI trong PlayerGui
        pcall(function()
            local PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                for _, Gui in ipairs(PlayerGui:GetChildren()) do
                    if Gui:IsA("ScreenGui") or Gui:IsA("SurfaceGui") then
                        Gui.Enabled = false
                    end
                end
            end
        end)
    else
        NutAnGui.Text = "Ẩn GUI Gốc Game"
        -- Hiện lại tất cả GUI trong PlayerGui
        pcall(function()
            local PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                for _, Gui in ipairs(PlayerGui:GetChildren()) do
                    if Gui:IsA("ScreenGui") or Gui:IsA("SurfaceGui") then
                        Gui.Enabled = true
                    end
                end
            end
        end)
    end
end)
ChiSoY = ChiSoY + 35

-- Nút bật/tắt hiển thị FPS
local NutFPS = TaoNut("Bật Hiển Thị FPS", ChiSoY, function()
    HienThiFPS = not HienThiFPS
    if HienThiFPS then
        NutFPS.Text = "Tắt Hiển Thị FPS"
        -- Tạo khung hiển thị FPS nếu chưa tồn tại
        if not KhungFPS then
            KhungFPS = Instance.new("Frame")
            KhungFPS.Name = "KhungFPS"
            KhungFPS.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            KhungFPS.BackgroundTransparency = 0.5 -- Trong suốt một phần
            KhungFPS.BorderSizePixel = 0
            KhungFPS.Size = UDim2.new(0, 80, 0, 30)
            KhungFPS.Position = UDim2.new(1, -90, 0, 10) -- Góc trên bên phải
            KhungFPS.ZIndex = 20
            KhungFPS.Parent = MenuGUI
            
            NhanFPS = Instance.new("TextLabel")
            NhanFPS.Name = "NhanFPS"
            NhanFPS.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NhanFPS.BackgroundTransparency = 0.5
            NhanFPS.BorderSizePixel = 0
            NhanFPS.Size = UDim2.new(1, 0, 1, 0)
            NhanFPS.Font = Enum.Font.SourceSansBold
            NhanFPS.Text = "FPS: 0"
            NhanFPS.TextColor3 = Color3.fromRGB(0, 255, 0)
            NhanFPS.TextSize = 18
            NhanFPS.ZIndex = 21
            NhanFPS.Parent = KhungFPS
            
            -- Cập nhật FPS liên tục
            spawn(function()
                while HienThiFPS do
                    local FPS = math.floor(1 / game:GetService("RunService").Heartbeat:Wait())
                    NhanFPS.Text = "FPS: " .. tostring(FPS)
                    wait(0.1)
                end
            end)
        else
            KhungFPS.Visible = true
        end
    else
        NutFPS.Text = "Bật Hiển Thị FPS"
        if KhungFPS then
            KhungFPS.Visible = false
        end
    end
end)
ChiSoY = ChiSoY + 35

-- Nhãn phần điều chỉnh kích thước
local NhanKichThuoc = TaoNhan("NhanKichThuoc", ChiSoY, "--- Điều Chỉnh Kích Thước Menu ---")
ChiSoY = ChiSoY + 25

-- Thanh trượt điều chỉnh chiều rộng menu
local ThanhTruotRong = TaoThanhTruot("Chiều Rộng", ChiSoY, 150, 500, KichThuocMenu.X, function(GiaTri)
    KichThuocMenu = Vector2.new(GiaTri, KichThuocMenu.Y)
    KhungMenu.Size = UDim2.new(0, KichThuocMenu.X, 0, KichThuocMenu.Y)
end)
ChiSoY = ChiSoY + 45

-- Thanh trượt điều chỉnh chiều cao menu
local ThanhTruotCao = TaoThanhTruot("Chiều Cao", ChiSoY, 200, 600, KichThuocMenu.Y, function(GiaTri)
    KichThuocMenu = Vector2.new(KichThuocMenu.X, GiaTri)
    KhungMenu.Size = UDim2.new(0, KichThuocMenu.X, 0, KichThuocMenu.Y)
end)
ChiSoY = ChiSoY + 45

-- Nhãn phần chọn màu
local NhanChonMau = TaoNhan("NhanChonMau", ChiSoY, "--- Chọn Màu Sắc ---")
ChiSoY = ChiSoY + 25

-- Tạo các nút chọn màu, xếp thành hàng ngang (4 nút mỗi hàng)
local CotMau = 0
local HangMau = 0
for _, ThongTinMau in ipairs(DanhSachMau) do
    local TenMau = ThongTinMau[1]
    local GiaTriMau = ThongTinMau[2]
    local NutMau = TaoNutChonMau(TenMau, GiaTriMau, ChiSoY + HangMau * 30)
    NutMau.Position = UDim2.new(0, 5 + CotMau * 30, 0, ChiSoY + HangMau * 30)
    CotMau = CotMau + 1
    if CotMau >= 5 then -- Xuống dòng sau 5 nút
        CotMau = 0
        HangMau = HangMau + 1
    end
end
ChiSoY = ChiSoY + (HangMau + 1) * 30 + 10

-- Nút bật/tắt màu cầu vồng
local NutCauVong = TaoNut("Bật Màu Cầu Vồng", ChiSoY, function()
    if TrangThaiCauVong then
        TrangThaiCauVong = false
        NutCauVong.Text = "Bật Màu Cầu Vồng"
    else
        BatDauCauVong()
        NutCauVong.Text = "Tắt Màu Cầu Vồng"
    end
end)
ChiSoY = ChiSoY + 35

-- Cập nhật kích thước canvas của khung cuộn sau khi thêm tất cả phần tử
KhungCuon.CanvasSize = UDim2.new(0, 0, 0, ChiSoY + 50)

-- Tạo nút mở/đóng menu (nút nhỏ luôn hiển thị)
local NutMoMenu = Instance.new("TextButton")
NutMoMenu.Name = "NutMoMenu"
NutMoMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Màu đen
NutMoMenu.BorderColor3 = Color3.fromRGB(60, 60, 60)
NutMoMenu.BorderSizePixel = 1
NutMoMenu.Size = UDim2.new(0, 40, 0, 40) -- Nút vuông nhỏ 40x40
NutMoMenu.Position = UDim2.new(0, 5, 0.5, -20) -- Giữa bên trái màn hình
NutMoMenu.Font = Enum.Font.SourceSansBold
NutMoMenu.Text = "M" -- Chữ M viết tắt cho Menu
NutMoMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
NutMoMenu.TextSize = 18
NutMoMenu.ZIndex = 100 -- ZIndex cao nhất để luôn nổi trên cùng
NutMoMenu.Active = true
NutMoMenu.Draggable = true -- Cho phép kéo nút đến vị trí khác
NutMoMenu.Parent = MenuGUI

-- Xử lý sự kiện click vào nút mở menu
NutMoMenu.MouseButton1Click:Connect(function()
    MenuMo = not MenuMo
    if MenuMo then
        MenuGUI.Enabled = true
        KhungMenu.Visible = true
        NutMoMenu.Text = "Đ" -- Chữ Đ viết tắt cho Đóng
    else
        MenuGUI.Enabled = false
        KhungMenu.Visible = false
        if KhungFPS then
            KhungFPS.Visible = false
        end
        HinhAnhManHinhDen.Enabled = false
        NutMoMenu.Text = "M"
    end
end)

-- Ẩn menu ban đầu
MenuGUI.Enabled = false
KhungMenu.Visible = false

-- Hiển thị nút mở menu ban đầu
MenuGUI.Enabled = true
NutMoMenu.Visible = true

-- Kết thúc script - Tất cả chức năng đã được thiết lập
print("Script hack menu đã được tải thành công.")
