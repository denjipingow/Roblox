-- LocalScript: Ultra Modern Teleport UI with Gradient Design

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Hapus GUI lama jika ada
local old = playerGui:FindFirstChild("DenjiExecutor")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DenjiExecutor"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Storage untuk posisi dan teleport loop
local positions = {}
local teleportLoop = nil
local currentIndex = 1
local isRunning = false
local loopMode = true

-- ====== Helper Functions ======
local function createGradient(colors, rotation)
    local gradient = Instance.new("UIGradient")
    local colorSequence = ColorSequence.new(colors)
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    return gradient
end

local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function createStroke(thickness, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Color3.fromRGB(200,200,200)
    stroke.Transparency = transparency or 0
    return stroke
end

local function createShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = parent.ZIndex - 1
    createCorner(12).Parent = shadow
    shadow.Parent = parent.Parent
    return shadow
end

-- ====== Main Frame ======
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 450)
frame.Position = UDim2.new(0.5, -260, 0.5, -225)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Active = true
frame.Draggable = true
frame.ZIndex = 2
frame.Parent = gui

createCorner(16).Parent = frame
createStroke(2, Color3.fromRGB(70, 130, 255), 0.3).Parent = frame
local mainGradient = createGradient({
    Color3.fromRGB(35, 35, 45),
    Color3.fromRGB(25, 25, 30)
}, 45)
mainGradient.Parent = frame
createShadow(frame)

-- ====== Header Section ======
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
header.Parent = frame

createCorner(16).Parent = header
local headerGradient = createGradient({
    Color3.fromRGB(100, 150, 255),
    Color3.fromRGB(70, 130, 255),
    Color3.fromRGB(50, 100, 200)
}, 135)
headerGradient.Parent = header

-- Header top corners only
local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 0, 30)
headerMask.Position = UDim2.new(0, 0, 1, -30)
headerMask.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
headerMask.BorderSizePixel = 0
headerMask.Parent = header

-- Title with icon
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, -120, 1, 0)
titleContainer.Position = UDim2.new(0, 20, 0, 0)
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = header

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 40, 0, 40)
titleIcon.Position = UDim2.new(0, 0, 0.5, -20)
titleIcon.BackgroundTransparency = 1
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextSize = 24
titleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
titleIcon.Text = "🚀"
titleIcon.Parent = titleContainer

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 50, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "DENJI TELEPORT PRO"
titleLabel.Parent = titleContainer

-- Version badge
local versionBadge = Instance.new("TextLabel")
versionBadge.Size = UDim2.new(0, 50, 0, 18)
versionBadge.Position = UDim2.new(1, -120, 0, 5)
versionBadge.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
versionBadge.Font = Enum.Font.GothamBold
versionBadge.TextSize = 10
versionBadge.TextColor3 = Color3.fromRGB(0, 0, 0)
versionBadge.Text = "v3.0"
versionBadge.Parent = header

createCorner(9).Parent = versionBadge

-- Window Control Buttons
local function createControlButton(icon, offsetX, bgColor, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 35, 0, 35)
    btn.Position = UDim2.new(1, offsetX, 0.5, -17.5)
    btn.BackgroundColor3 = bgColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = icon
    btn.Parent = header
    
    createCorner(17).Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = hoverColor
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = bgColor
    end)
    
    return btn
end

local minimizeBtn = createControlButton("–", -75, Color3.fromRGB(255, 180, 50), Color3.fromRGB(255, 160, 30))
local closeBtn = createControlButton("✕", -35, Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 60, 60))

-- ====== Content Container ======
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, -30, 1, -90)
contentContainer.Position = UDim2.new(0, 15, 0, 75)
contentContainer.BackgroundTransparency = 1
contentContainer.ScrollBarThickness = 6
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
contentContainer.Parent = frame

-- ====== Position Input Card ======
local inputCard = Instance.new("Frame")
inputCard.Size = UDim2.new(1, 0, 0, 110)
inputCard.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
inputCard.Parent = contentContainer

createCorner(12).Parent = inputCard
createStroke(1, Color3.fromRGB(80, 80, 90), 0.5).Parent = inputCard
local inputGradient = createGradient({
    Color3.fromRGB(50, 50, 60),
    Color3.fromRGB(40, 40, 50)
}, 90)
inputGradient.Parent = inputCard

local inputTitle = Instance.new("TextLabel")
inputTitle.Size = UDim2.new(1, -20, 0, 30)
inputTitle.Position = UDim2.new(0, 10, 0, 5)
inputTitle.BackgroundTransparency = 1
inputTitle.Font = Enum.Font.GothamBold
inputTitle.TextSize = 14
inputTitle.TextXAlignment = Enum.TextXAlignment.Left
inputTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
inputTitle.Text = "📍 TAMBAH POSISI BARU"
inputTitle.Parent = inputCard

-- Position Input Fields
local function createInputField(placeholder, position)
    local field = Instance.new("TextBox")
    field.Size = UDim2.new(0.3, -5, 0, 28)
    field.Position = position
    field.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    field.Font = Enum.Font.Gotham
    field.TextSize = 12
    field.TextColor3 = Color3.fromRGB(255, 255, 255)
    field.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    field.PlaceholderText = placeholder
    field.Parent = inputCard
    
    createCorner(6).Parent = field
    createStroke(1, Color3.fromRGB(70, 130, 255), 0.7).Parent = field
    
    return field
end

local xInput = createInputField("X Position", UDim2.new(0, 10, 0, 40))
local yInput = createInputField("Y Position", UDim2.new(0.33, 2.5, 0, 40))
local zInput = createInputField("Z Position", UDim2.new(0.66, 5, 0, 40))

-- Action Buttons
local function createActionButton(text, position, bgColor, textColor, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, -3, 0, 25)
    btn.Position = position
    btn.BackgroundColor3 = bgColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = textColor
    btn.Text = icon .. " " .. text
    btn.Parent = inputCard
    
    createCorner(6).Parent = btn
    local btnGradient = createGradient({bgColor, Color3.fromRGB(
        math.max(0, bgColor.R * 255 - 20),
        math.max(0, bgColor.G * 255 - 20),
        math.max(0, bgColor.B * 255 - 20)
    )}, 90)
    btnGradient.Parent = btn
    
    return btn
end

local setPosBtn = createActionButton("SET HERE", UDim2.new(0, 10, 0, 75), Color3.fromRGB(50, 200, 100), Color3.fromRGB(255, 255, 255), "🎯")
local addCurrentBtn = createActionButton("CURRENT", UDim2.new(0.33, 2.5, 0, 75), Color3.fromRGB(100, 180, 255), Color3.fromRGB(255, 255, 255), "📌")
local addManualBtn = createActionButton("MANUAL", UDim2.new(0.66, 5, 0, 75), Color3.fromRGB(180, 100, 255), Color3.fromRGB(255, 255, 255), "✏️")

-- ====== Control Panel Card ======
local controlCard = Instance.new("Frame")
controlCard.Size = UDim2.new(1, 0, 0, 120)
controlCard.Position = UDim2.new(0, 0, 0, 120)
controlCard.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
controlCard.Parent = contentContainer

createCorner(12).Parent = controlCard
createStroke(1, Color3.fromRGB(80, 80, 90), 0.5).Parent = controlCard
local controlGradient = createGradient({
    Color3.fromRGB(50, 50, 60),
    Color3.fromRGB(40, 40, 50)
}, 90)
controlGradient.Parent = controlCard

local controlTitle = Instance.new("TextLabel")
controlTitle.Size = UDim2.new(1, -20, 0, 30)
controlTitle.Position = UDim2.new(0, 10, 0, 5)
controlTitle.BackgroundTransparency = 1
controlTitle.Font = Enum.Font.GothamBold
controlTitle.TextSize = 14
controlTitle.TextXAlignment = Enum.TextXAlignment.Left
controlTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
controlTitle.Text = "⚡ KONTROL TELEPORT"
controlTitle.Parent = controlCard

-- Timer Input with Label
local timerContainer = Instance.new("Frame")
timerContainer.Size = UDim2.new(0.4, 0, 0, 30)
timerContainer.Position = UDim2.new(0, 10, 0, 40)
timerContainer.BackgroundTransparency = 1
timerContainer.Parent = controlCard

local timerInput = Instance.new("TextBox")
timerInput.Size = UDim2.new(0.7, -5, 1, 0)
timerInput.Position = UDim2.new(0, 0, 0, 0)
timerInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
timerInput.Font = Enum.Font.GothamBold
timerInput.TextSize = 14
timerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
timerInput.Text = "1.0"
timerInput.Parent = timerContainer

createCorner(6).Parent = timerInput
createStroke(1, Color3.fromRGB(70, 130, 255), 0.7).Parent = timerInput

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.3, 0, 1, 0)
timerLabel.Position = UDim2.new(0.7, 5, 0, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.Gotham
timerLabel.TextSize = 12
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.TextYAlignment = Enum.TextYAlignment.Center
timerLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
timerLabel.Text = "detik"
timerLabel.Parent = timerContainer

-- Loop Toggle Switch
local loopBtn = Instance.new("TextButton")
loopBtn.Size = UDim2.new(0.5, -10, 0, 30)
loopBtn.Position = UDim2.new(0.5, 0, 0, 40)
loopBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
loopBtn.Font = Enum.Font.GothamBold
loopBtn.TextSize = 12
loopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopBtn.Text = "🔄 LOOP: AKTIF"
loopBtn.Parent = controlCard

createCorner(15).Parent = loopBtn
local loopGradient = createGradient({
    Color3.fromRGB(70, 170, 255),
    Color3.fromRGB(50, 150, 255)
}, 90)
loopGradient.Parent = loopBtn

-- Control Buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48, -5, 0, 35)
startBtn.Position = UDim2.new(0, 10, 0, 78)
startBtn.BackgroundColor3 = Color3.fromRGB(100, 220, 100)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Text = "▶️ START"
startBtn.Parent = controlCard

createCorner(8).Parent = startBtn
local startGradient = createGradient({
    Color3.fromRGB(120, 240, 120),
    Color3.fromRGB(100, 220, 100)
}, 90)
startGradient.Parent = startBtn

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48, -5, 0, 35)
stopBtn.Position = UDim2.new(0.52, 5, 0, 78)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "⏹️ STOP"
stopBtn.Parent = controlCard

createCorner(8).Parent = stopBtn
local stopGradient = createGradient({
    Color3.fromRGB(255, 120, 120),
    Color3.fromRGB(255, 100, 100)
}, 90)
stopGradient.Parent = stopBtn

-- ====== Position List Card ======
local listCard = Instance.new("Frame")
listCard.Size = UDim2.new(1, 0, 0, 280)
listCard.Position = UDim2.new(0, 0, 0, 250)
listCard.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
listCard.Parent = contentContainer

createCorner(12).Parent = listCard
createStroke(1, Color3.fromRGB(80, 80, 90), 0.5).Parent = listCard
local listGradient = createGradient({
    Color3.fromRGB(50, 50, 60),
    Color3.fromRGB(40, 40, 50)
}, 90)
listGradient.Parent = listCard

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -20, 0, 35)
listTitle.Position = UDim2.new(0, 10, 0, 5)
listTitle.BackgroundTransparency = 1
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 14
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
listTitle.Text = "📋 DAFTAR POSISI TERSIMPAN"
listTitle.Parent = listCard

local positionScroll = Instance.new("ScrollingFrame")
positionScroll.Size = UDim2.new(1, -20, 1, -50)
positionScroll.Position = UDim2.new(0, 10, 0, 40)
positionScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
positionScroll.ScrollBarThickness = 4
positionScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)
positionScroll.Parent = listCard

createCorner(8).Parent = positionScroll
createStroke(1, Color3.fromRGB(60, 60, 70), 0.8).Parent = positionScroll

-- ====== Functions ======

-- Update position list display with modern design
local function updatePositionList()
    for _, child in pairs(positionScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for i, pos in pairs(positions) do
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, -10, 0, 40)
        item.Position = UDim2.new(0, 5, 0, (i-1) * 45)
        item.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        item.Parent = positionScroll
        
        createCorner(8).Parent = item
        createStroke(1, Color3.fromRGB(70, 130, 255), 0.3).Parent = item
        local itemGradient = createGradient({
            Color3.fromRGB(60, 60, 70),
            Color3.fromRGB(50, 50, 60)
        }, 45)
        itemGradient.Parent = item
        
        local indexLabel = Instance.new("TextLabel")
        indexLabel.Size = UDim2.new(0, 30, 1, 0)
        indexLabel.Position = UDim2.new(0, 10, 0, 0)
        indexLabel.BackgroundTransparency = 1
        indexLabel.Font = Enum.Font.GothamBold
        indexLabel.TextSize = 14
        indexLabel.TextColor3 = Color3.fromRGB(70, 130, 255)
        indexLabel.Text = tostring(i)
        indexLabel.Parent = item
        
        local posText = Instance.new("TextLabel")
        posText.Size = UDim2.new(1, -140, 1, 0)
        posText.Position = UDim2.new(0, 45, 0, 0)
        posText.BackgroundTransparency = 1
        posText.Font = Enum.Font.Gotham
        posText.TextSize = 11
        posText.TextXAlignment = Enum.TextXAlignment.Left
        posText.TextColor3 = Color3.fromRGB(220, 220, 220)
        posText.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
        posText.Parent = item
        
        local function createItemButton(text, offsetX, bgColor, icon)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 45, 0, 25)
            btn.Position = UDim2.new(1, offsetX, 0.5, -12.5)
            btn.BackgroundColor3 = bgColor
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = icon
            btn.Parent = item
            
            createCorner(4).Parent = btn
            local btnGradient = createGradient({bgColor, Color3.fromRGB(
                math.max(0, bgColor.R * 255 - 30),
                math.max(0, bgColor.G * 255 - 30),
                math.max(0, bgColor.B * 255 - 30)
            )}, 90)
            btnGradient.Parent = btn
            
            return btn
        end
        
        local tpBtn = createItemButton("TP", -95, Color3.fromRGB(70, 130, 255), "🚀")
        local delBtn = createItemButton("DEL", -45, Color3.fromRGB(255, 80, 80), "🗑️")
        
        -- Button connections with animations
        tpBtn.MouseButton1Click:Connect(function()
            if rootPart then
                rootPart.CFrame = CFrame.new(pos)
                tpBtn.Text = "✅"
                wait(0.5)
                tpBtn.Text = "🚀"
            end
        end)
        
        delBtn.MouseButton1Click:Connect(function()
            table.remove(positions, i)
            updatePositionList()
        end)
        
        -- Hover effects
        item.MouseEnter:Connect(function()
            item.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
        end)
        item.MouseLeave:Connect(function()
            item.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        end)
    end
    
    positionScroll.CanvasSize = UDim2.new(0, 0, 0, #positions * 45)
end

-- Enhanced teleport function
local function teleportToNext()
    if #positions == 0 then return false end
    
    if currentIndex > #positions then
        if loopMode then
            currentIndex = 1
        else
            return false
        end
    end
    
    if rootPart then
        rootPart.CFrame = CFrame.new(positions[currentIndex])
        currentIndex = currentIndex + 1
    end
    
    return true
end

-- ====== Button Event Handlers ======

-- Set position here with enhanced feedback
setPosBtn.MouseButton1Click:Connect(function()
    if rootPart then
        local pos = rootPart.Position
        table.insert(positions, Vector3.new(pos.X, pos.Y, pos.Z))
        updatePositionList()
        
        setPosBtn.Text = "✅ TERSIMPAN!"
        setPosBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 30)
        wait(1)
        setPosBtn.Text = "🎯 SET HERE"
        setPosBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    end
end)

addCurrentBtn.MouseButton1Click:Connect(function()
    if rootPart then
        local pos = rootPart.Position
        table.insert(positions, Vector3.new(pos.X, pos.Y, pos.Z))
        updatePositionList()
    end
end)

addManualBtn.MouseButton1Click:Connect(function()
    local x = tonumber(xInput.Text)
    local y = tonumber(yInput.Text)
    local z = tonumber(zInput.Text)
    
    if x and y and z then
        table.insert(positions, Vector3.new(x, y, z))
        xInput.Text = ""
        yInput.Text = ""
        zInput.Text = ""
        updatePositionList()
    end
end)

-- Loop mode toggle with enhanced visuals
loopBtn.MouseButton1Click:Connect(function()
    loopMode = not loopMode
    if loopMode then
        loopBtn.Text = "🔄 LOOP: AKTIF"
        loopBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        loopGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
        })
    else
        loopBtn.Text = "🔂 LOOP: NONAKTIF"
        loopBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        loopGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 140, 140)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
        })
    end
end)

-- Start teleport with status indication
startBtn.MouseButton1Click:Connect(function()
    if #positions == 0 then return end
    if isRunning then return end
    
    local interval = tonumber(timerInput.Text) or 1
    isRunning = true
    currentIndex = 1
    
    startBtn.Text = "⏸️ RUNNING..."
    startBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    
    teleportLoop = coroutine.create(function()
        while isRunning do
            local shouldContinue = teleportToNext()
            
            if not shouldContinue and not loopMode then
                isRunning = false
                break
            end
            
            wait(interval)
        end
        
        -- Reset button when stopped
        startBtn.Text = "▶️ START"
        startBtn.BackgroundColor3 = Color3.fromRGB(100, 220, 100)
    end)
    
    coroutine.resume(teleportLoop)
end)

stopBtn.MouseButton1Click:Connect(function()
    isRunning = false
    if teleportLoop then
        teleportLoop = nil
    end
    startBtn.Text = "▶️ START"
    startBtn.BackgroundColor3 = Color3.fromRGB(100, 220, 100)
end)

-- ====== Window Controls ======
local origHeight = frame.Size.Y.Offset
local minimized = false

closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    frame:TweenSizeAndPosition(
        UDim2.new(0, 0, 0, 0),
        UDim2.new(0.5, 0, 0.5, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Back,
        0.3,
        true,
        function() gui:Destroy() end
    )
end)

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        origHeight = frame.Size.Y.Offset
        contentContainer.Visible = false
        minimizeBtn.Text = "+"
        frame:TweenSize(
            UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 60),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.4,
            true
        )
    else
        minimizeBtn.Text = "–"
        frame:TweenSize(
            UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, origHeight),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.4,
            true,
            function()
                contentContainer.Visible = true
            end
        )
    end
end)

-- ====== Resize Handle with Modern Design ======
local resizeHandle = Instance.new("Frame")
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
resizeHandle.Active = true
resizeHandle.Parent = frame

createCorner(10).Parent = resizeHandle

local resizeIcon = Instance.new("TextLabel")
resizeIcon.Size = UDim2.new(1, 0, 1, 0)
resizeIcon.BackgroundTransparency = 1
resizeIcon.Font = Enum.Font.GothamBold
resizeIcon.TextSize = 12
resizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
resizeIcon.Text = "⤡"
resizeIcon.Parent = resizeHandle

-- Enhanced resize functionality
local uis = game:GetService("UserInputService")
local resizing = false
local dragStart
local startSize

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        dragStart = uis:GetMouseLocation()
        startSize = frame.Size
        resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 160, 255)
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        resizeHandle.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    end
end)

uis.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = uis:GetMouseLocation() - dragStart
        local newW = math.max(480, startSize.X.Offset + delta.X)
        local newH = math.max(400, startSize.Y.Offset + delta.Y)
        frame.Size = UDim2.new(0, newW, 0, newH)
        
        -- Update canvas size for content
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
    end
end)

-- ====== Startup Animation ======
frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)

frame:TweenSizeAndPosition(
    UDim2.new(0, 520, 0, 450),
    UDim2.new(0.5, -260, 0.5, -225),
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Back,
    0.6,
    true
)

-- ====== Character Update Handler ======
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ====== Status Bar ======
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 25)
statusBar.Position = UDim2.new(0, 0, 1, -25)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
statusBar.Parent = frame

createCorner(16).Parent = statusBar
-- Only bottom corners rounded
local statusMask = Instance.new("Frame")
statusMask.Size = UDim2.new(1, 0, 0, 13)
statusMask.Position = UDim2.new(0, 0, 0, 0)
statusMask.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
statusMask.BorderSizePixel = 0
statusMask.Parent = statusBar

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
statusText.Text = "📡 Ready • Positions: 0 • Status: Idle"
statusText.Parent = statusBar

-- Update status text function
local function updateStatus()
    local status = isRunning and "Running" or "Idle"
    local mode = loopMode and "Loop" or "Single"
    statusText.Text = string.format("📡 %s • Positions: %d • Mode: %s", status, #positions, mode)
end

-- Call update status periodically
spawn(function()
    while gui.Parent do
        updateStatus()
        wait(1)
    end
end)

-- Initial position list update
updatePositionList()

print("🚀 Denji Teleport Pro v3.0 loaded successfully!")