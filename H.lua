local g=Instance.new("ScreenGui",game:GetService("CoreGui"))
g.Name="BlackScreenGUI"
g.DisplayOrder=999999

local f=Instance.new("Frame",g)
f.Size=UDim2.new(1,0,1,0)
f.BackgroundColor3=Color3.new(0,0,0)
f.Visible=false

local b=Instance.new("TextButton",g)
b.Size=UDim2.new(0,120,0,40)
b.Position=UDim2.new(0,10,0.5,-20)
b.Text="Black Screen"

b.MouseButton1Click:Connect(function()
	f.Visible=not f.Visible
end)
