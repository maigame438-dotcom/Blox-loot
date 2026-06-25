local cg=game:GetService("CoreGui")
local g=Instance.new("ScreenGui",cg)
g.Name="BlackScreen"

local f=Instance.new("Frame",g)
f.Size=UDim2.new(1,0,1,0)
f.BackgroundColor3=Color3.new(0,0,0)
f.Visible=false
f.ZIndex=1

local b=Instance.new("TextButton",g)
b.Size=UDim2.new(0,50,0,50)
b.Position=UDim2.new(0,15,0.5,-25)
b.Text="🌙"
b.TextScaled=true
b.BackgroundTransparency=0.3
b.ZIndex=2

b.MouseButton1Click:Connect(function()
	f.Visible=not f.Visible
end)
