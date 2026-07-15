-- fulluid uru - main menu | by:@2024nam8
-- Phiên bản 1.1.0 - Hỗ trợ đóng/mở bằng click, tối ưu mobile 80% màn hình

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Biến trạng thái
local state = {
    blackScreen = false,
    hideGUI = false,
    destroyGUI = false,
    fpsCounter = true,
    theme = "Rainbow",
    fps = 0,
    frameCount = 0,
    lastTime = tick(),
    menuVisible = true
}

-- Lấy kích thước màn hình
local viewportSize = workspace.CurrentCamera.ViewportSize
local screenW, screenH = viewportSize.X, viewportSize.Y

-- Tạo ScreenGui chính
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FulluidUruMainMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Hàm tạo FPS Counter
local function createFPSCounter()
    local frame = Instance.new("Frame")
    frame.Name = "FPSCounter"
    frame.Size = UDim2.new(0, 100, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Visible = state.fpsCounter

    local label = Instance.new("TextLabel")
    label.Name = "FPSLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "FPS: 0"
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    return frame
end

local fpsFrame = createFPSCounter()
local fpsLabel = fpsFrame:FindFirstChild("FPSLabel")

-- Cập nhật FPS
RunService.Heartbeat:Connect(function()
    state.frameCount = state.frameCount + 1
    local currentTime = tick()
    if currentTime - state.lastTime >= 0.2 then
        state.fps = math.floor(state.frameCount / (currentTime - state.lastTime))
        state.frameCount = 0
        state.lastTime = currentTime
        if fpsLabel then
            fpsLabel.Text = "FPS: " .. state.fps
            if state.fps > 300 then
                fpsLabel.TextColor3 = Color3.fromHSV(tick() % 1, 1, 1)
            elseif state.fps >= 31 then
                fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif state.fps >= 11 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end)

-- Nút toggle (hình tròn) để đóng/mở menu
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "ToggleMenuBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(1, -60, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BackgroundTransparency = 0.8
toggleBtn.BorderSizePixel = 0
toggleBtn.Image = "rbxassetid://3926305904" -- icon bánh răng
toggleBtn.Parent = screenGui

-- Biến lưu menuFrame
local menuFrame = nil

-- Hàm tạo menu chính
local function createMainMenu()
    -- Frame nền menu - chiếm 80% màn hình
    menuFrame = Instance.new("Frame")
    menuFrame.Name = "MainMenu"
    menuFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    menuFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menuFrame.BorderSizePixel = 0
    menuFrame.Parent = screenGui
    menuFrame.Active = true
    menuFrame.Draggable = true
    menuFrame.Visible = state.menuVisible

    -- Tiêu đề
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "fulluid uru - main menu | by:@2024nam8"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = menuFrame

    -- Danh sách tính năng (cuộn)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -140)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
    scroll.ScrollBarThickness = 8
    scroll.Parent = menuFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = scroll

    -- Hàm tạo nút (mobile-friendly, to hơn)
    local function createButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, math.min(screenW * 0.6, 350), 0, 50)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextScaled = true
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Cập nhật trạng thái nút
    local function updateButtonText(btn, isActive)
        if isActive then
            btn.Text = "[x] " .. btn.Text:sub(5)
        else
            btn.Text = "[ ] " .. btn.Text:sub(5)
        end
    end

    -- Nút Black Screen
    local btnBlack = createButton("[ ] Black Screen", function()
        state.blackScreen = not state.blackScreen
        updateButtonText(btnBlack, state.blackScreen)
        if state.blackScreen then
            local black = Instance.new("Frame")
            black.Name = "BlackScreenOverlay"
            black.Size = UDim2.new(1, 0, 1, 0)
            black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            black.BorderSizePixel = 0
            black.Parent = screenGui
        else
            local black = screenGui:FindFirstChild("BlackScreenOverlay")
            if black then black:Destroy() end
        end
    end)

    -- Nút Hide All GUI
    local btnHide = createButton("[ ] Hide All GUI", function()
        state.hideGUI = not state.hideGUI
        updateButtonText(btnHide, state.hideGUI)
        for _, v in pairs(screenGui:GetChildren()) do
            if v.Name ~= "MainMenu" and v.Name ~= "FPSCounter" and v.Name ~= "ToggleMenuBtn" then
                v.Visible = not state.hideGUI
            end
        end
    end)

    -- Nút FPS Counter
    local btnFPS = createButton("[x] FPS Counter", function()
        state.fpsCounter = not state.fpsCounter
        updateButtonText(btnFPS, state.fpsCounter)
        if fpsFrame then fpsFrame.Visible = state.fpsCounter end
    end)

    -- Nút Destroy GUI
    createButton("Destroy GUI", function()
        state.destroyGUI = true
        screenGui:Destroy()
    end)

    -- Theme Selector
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(0, math.min(screenW * 0.6, 350), 0, 35)
    themeLabel.Text = "Theme: Rainbow (click để đổi)"
    themeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Font = Enum.Font.Gotham
    themeLabel.TextScaled = true
    themeLabel.Parent = scroll

    local themes = {"Black","White","Gray","Blue","Dark Blue","Red","Dark Red","Green","Lime","Yellow","Orange","Purple","Pink","Cyan","Rainbow","Secret"}
    local themeIndex = 15
    local rainbowCoroutine = nil

    local function applyTheme(col)
        if rainbowCoroutine then
            coroutine.close(rainbowCoroutine)
            rainbowCoroutine = nil
        end
        if state.theme == "Rainbow" then
            rainbowCoroutine = coroutine.create(function()
                while state.theme == "Rainbow" and menuFrame and menuFrame.Parent do
                    local hue = tick() % 1
                    menuFrame.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.5)
                    wait(0.05)
                end
            end)
            coroutine.resume(rainbowCoroutine)
        elseif state.theme == "Secret" then
            menuFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
            menuFrame.BackgroundTransparency = 1
        else
            menuFrame.BackgroundColor3 = col
            menuFrame.BackgroundTransparency = 0
        end
    end

    themeLabel.MouseButton1Click:Connect(function()
        themeIndex = themeIndex % #themes + 1
        state.theme = themes[themeIndex]
        themeLabel.Text = "Theme: " .. state.theme .. " (click để đổi)"
        local colors = {
            Black = Color3.fromRGB(10,10,10),
            White = Color3.fromRGB(240,240,240),
            Gray = Color3.fromRGB(128,128,128),
            Blue = Color3.fromRGB(0,100,255),
            ["Dark Blue"] = Color3.fromRGB(0,0,139),
            Red = Color3.fromRGB(255,0,0),
            ["Dark Red"] = Color3.fromRGB(139,0,0),
            Green = Color3.fromRGB(0,200,0),
            Lime = Color3.fromRGB(0,255,0),
            Yellow = Color3.fromRGB(255,255,0),
            Orange = Color3.fromRGB(255,165,0),
            Purple = Color3.fromRGB(128,0,128),
            Pink = Color3.fromRGB(255,105,180),
            Cyan = Color3.fromRGB(0,255,255),
            Rainbow = Color3.fromRGB(255,0,0),
            Secret = Color3.fromRGB(0,0,0)
        }
        applyTheme(colors[state.theme] or Color3.fromRGB(30,30,30))
    end)

    -- Thông tin
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 80)
    info.Position = UDim2.new(0, 0, 1, -80)
    info.BackgroundTransparency = 1
    info.Text = "FPS: " .. state.fps .. "\nDev: @2024nam8\nVer: 1.1.0\nYear: 2024"
    info.TextColor3 = Color3.fromRGB(180,180,180)
    info.TextScaled = true
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = menuFrame
end

createMainMenu()

-- Xử lý toggle đóng/mở bằng click vào nút tròn
toggleBtn.MouseButton1Click:Connect(function()
    state.menuVisible = not state.menuVisible
    if menuFrame then
        menuFrame.Visible = state.menuVisible
    end
    -- Đổi icon theo trạng thái
    if state.menuVisible then
        toggleBtn.Image = "rbxassetid://3926305904" -- bánh răng
    else
        toggleBtn.Image = "rbxassetid://6031091554" -- icon menu (ba gạch)
    end
end)

-- Cập nhật thông tin FPS realtime
spawn(function()
    while screenGui and screenGui.Parent do
        wait(0.5)
        local infoLabel = menuFrame and menuFrame:FindFirstChildOfClass("TextLabel")
        if infoLabel and infoLabel.Text:find("FPS:") then
            infoLabel.Text = "FPS: " .. state.fps .. "\nDev: @2024nam8\nVer: 1.1.0\nYear: 2024"
        end
    end
end)
