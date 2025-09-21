-- LocalScript: Simple clean UI with Minimize & Exit buttons (no code execution)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Hapus GUI lama bila ada
local oldGui = playerGui:FindFirstChild("CleanExecutorUI")
if oldGui then oldGui:Destroy() end

-- Root GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CleanExecutorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 260)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 30, 33)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Clean UI – Mock Executor"
titleLabel.Parent = titleBar

-- Tombol Exit
local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.new(0, 60, 0, 24)
exitBtn.Position = UDim2.new(1, -70, 0.5, -12)
exitBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
exitBtn.Text = "Exit"
exitBtn.Font = Enum.Font.Gotham
exitBtn.TextSize = 14
exitBtn.TextColor3 = Color3.fromRGB(255,255,255)
exitBtn.BorderSizePixel = 0
exitBtn.Parent = titleBar

-- Tombol Minimize
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 60, 0, 24)
minBtn.Position = UDim2.new(1, -140, 0.5, -12)
minBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
minBtn.Text = "Minimize"
minBtn.Font = Enum.Font.Gotham
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar

-- Area teks
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 1, -60)
textBox.Position = UDim2.new(0, 10, 0, 50)
textBox.BackgroundColor3 = Color3.fromRGB(20, 22, 25)
textBox.TextColor3 = Color3.fromRGB(230, 230, 230)
textBox.Font = Enum.Font.Code
textBox.TextSize = 14
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.TextWrapped = true
textBox.Text = "-- Area teks saja. Tidak mengeksekusi apapun."
textBox.Parent = mainFrame

-- Fungsi tombol
exitBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    textBox.Visible = not minimized
    -- Ganti tinggi frame agar ringkas saat minimize
    if minimized then
        mainFrame.Size = UDim2.new(0, 420, 0, 40)
        minBtn.Text = "Restore"
    else
        mainFrame.Size = UDim2.new(0, 420, 0, 260)
        minBtn.Text = "Minimize"
    end
end)
