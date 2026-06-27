local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local HubLib = {}
local activeTab = nil
local startTime = os.time()

-- Settings
local TweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    TopBar = Color3.fromRGB(30, 30, 30),
    TabContainer = Color3.fromRGB(25, 25, 25),
    Element = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(80, 120, 255)
}

-- Hàm tạo các phần tử UI cơ bản
local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function HubLib:MakeDraggable(guiToMove, dragHandle)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(guiToMove, TweenInfoFast, {Position = newPos}):Play()
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiToMove.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiToMove.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function HubLib:ShowNotification(text)
    -- Hàm giữ chỗ cho Notification, có thể phát triển thêm GUI popup ở góc màn hình
    print("[Hub Notification]: " .. text)
end

function HubLib:CreateFloatingButton(screenGui, logoId)
    local FloatBtn = Create("ImageButton", {
        Name = "FloatingToggle",
        Parent = screenGui,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, 0),
        BackgroundColor3 = Theme.TopBar,
        Image = logoId,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = FloatBtn, CornerRadius = UDim.new(1, 0)})

    -- Kéo thả trong giới hạn màn hình
    local dragging, dragInput, dragStart, startPos
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
