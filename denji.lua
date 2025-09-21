-- LocalScript: Advanced Teleport UI with Map-Specific Configuration

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

-- ====== Configuration Storage System ======
local configData = {}
local currentMapName = ""

-- Function to get current map name
local function getCurrentMapName()
    local mapName = "Unknown"
    
    -- Try to get map name from workspace folder structure
    local workspace = game.Workspace
    
    -- Method 1: Check for common map folder names
    local mapFolders = {"Map", "Maps", "Level", "Levels", "Stage", "Stages"}
    for _, folderName in pairs(mapFolders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder and folder:GetChildren()[1] then
            mapName = folder:GetChildren()[1].Name
            break
        end
    end
    
    -- Method 2: Use game place name if available
    if mapName == "Unknown" then
        local success, result = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        if success and result then
            mapName = result
        end
    end
    
    -- Method 3: Fallback to PlaceId
    if mapName == "Unknown" then
        mapName = "Place_" .. tostring(game.PlaceId)
    end
    
    return mapName
end

-- Function to save configuration to memory
local function saveConfig()
    if currentMapName == "" then return end
    
    configData[currentMapName] = {
        positions = {},
        settings = {
            interval = tonumber(timerInput.Text) or 1,
            loopMode = loopMode
        }
    }
    
    -- Deep copy positions
    for i, pos in pairs(positions) do
        table.insert(configData[currentMapName].positions, {
            x = pos.X,
            y = pos.Y,
            z = pos.Z
        })
    end
    
    -- Visual feedback
    mapLabel.Text = "🗺️ Map: " .. currentMapName .. " ✅ SAVED"
    wait(1)
    mapLabel.Text = "🗺️ Map: " .. currentMapName
end

-- Function to load configuration from memory
local function loadConfig()
    if currentMapName == "" then return end
    
    local config = configData[currentMapName]
    if not config then return end
    
    -- Load positions
    positions = {}
    for _, pos in pairs(config.positions) do
        table.insert(positions, Vector3.new(pos.x, pos.y, pos.z))
    end
    
    -- Load settings
    if config.settings then
        timerInput.Text = tostring(config.settings.interval)
        loopMode = config.settings.loopMode
        
        -- Update loop button appearance
        if loopMode then
            loopBtn.Text = "🔄 LOOP: ON"
            loopBtn.BackgroundColor3 = Color3.fromRGB(50,150,250)
        else
            loopBtn.Text = "🔂 LOOP: OFF"
            loopBtn.BackgroundColor3 = Color3.fromRGB(150,150,150)
        end
    end
    
    updatePositionList()
    
    -- Visual feedback
    mapLabel.Text = "🗺️ Map: " .. currentMapName .. " 📥 LOADED"
    wait(1)
    mapLabel.Text = "🗺️ Map: " .. currentMapName
end

-- Initialize current map
currentMapName = getCurrentMapName()

-- Storage untuk posisi dan teleport loop
local positions = {}
local teleportLoop = nil
local currentIndex = 1
local isRunning = false
local loopMode = true

-- ====== Main Frame ======
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 520, 0, 450)
frame.Position = UDim2.new(0.5, -260, 0.5, -225)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(245,245,245)
frame.BorderColor3 = Color3.fromRGB(200,200,200)
frame.BorderSizePixel = 1
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- ====== Title Bar ======
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(235,235,235)
titleBar.BorderColor3 = Color3.fromRGB(200,200,200)
titleBar.BorderSizePixel = 1
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(40,40,40)
titleLabel.Text = "Denji Teleport System - v3.0"
titleLabel.Parent = titleBar

-- ====== Window Control Buttons ======
local function makeButton(symbol, offsetX, bgColor, txtColor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 40, 0, 24)
    b.Position = UDim2.new(1, offsetX, 0.5, -12)
    b.BackgroundColor3 = bgColor
    b.Text = symbol
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.TextColor3 = txtColor
    b.BorderSizePixel = 0
    b.Parent = titleBar
    return b
end

local minBtn  = makeButton("–", -90, Color3.fromRGB(210,210,210), Color3.fromRGB(60,60,60))
local exitBtn = makeButton("X", -45, Color3.fromRGB(230,80,80),  Color3.fromRGB(255,255,255))

-- ====== Content Area ======
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

-- ====== Map Info Section ======
local mapSection = Instance.new("Frame")
mapSection.Size = UDim2.new(1, 0, 0, 50)
mapSection.BackgroundColor3 = Color3.fromRGB(240,248,255)
mapSection.BorderColor3 = Color3.fromRGB(180,200,220)
mapSection.BorderSizePixel = 1
mapSection.Parent = contentFrame

local mapLabel = Instance.new("TextLabel")
mapLabel.Size = UDim2.new(1, -120, 1, 0)
mapLabel.Position = UDim2.new(0, 10, 0, 0)
mapLabel.BackgroundTransparency = 1
mapLabel.Font = Enum.Font.GothamBold
mapLabel.TextSize = 12
mapLabel.TextXAlignment = Enum.TextXAlignment.Left
mapLabel.TextColor3 = Color3.fromRGB(40,80,120)
mapLabel.Text = "🗺️ Map: " .. currentMapName
mapLabel.Parent = mapSection

local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Size = UDim2.new(0, 50, 0, 20)
saveConfigBtn.Position = UDim2.new(1, -110, 0.5, -10)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
saveConfigBtn.BorderSizePixel = 0
saveConfigBtn.Font = Enum.Font.GothamBold
saveConfigBtn.TextSize = 10
saveConfigBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveConfigBtn.Text = "💾 SAVE"
saveConfigBtn.Parent = mapSection

local loadConfigBtn = Instance.new("TextButton")
loadConfigBtn.Size = UDim2.new(0, 50, 0, 20)
loadConfigBtn.Position = UDim2.new(1, -55, 0.5, -10)
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(50,100,200)
loadConfigBtn.BorderSizePixel = 0
loadConfigBtn.Font = Enum.Font.GothamBold
loadConfigBtn.TextSize = 10
loadConfigBtn.TextColor3 = Color3.fromRGB(255,255,255)
loadConfigBtn.Text = "📥 LOAD"
loadConfigBtn.Parent = mapSection

local configCountLabel = Instance.new("TextLabel")
configCountLabel.Size = UDim2.new(1, -10, 0, 15)
configCountLabel.Position = UDim2.new(0, 10, 1, -18)
configCountLabel.BackgroundTransparency = 1
configCountLabel.Font = Enum.Font.Gotham
configCountLabel.TextSize = 10
configCountLabel.TextXAlignment = Enum.TextXAlignment.Left
configCountLabel.TextColor3 = Color3.fromRGB(100,100,100)
configCountLabel.Text = "Configs saved: 0"
configCountLabel.Parent = mapSection

-- ====== Position Input Section ======
local inputSection = Instance.new("Frame")
inputSection.Size = UDim2.new(1, 0, 0, 80)
inputSection.Position = UDim2.new(0, 0, 0, 60)
inputSection.BackgroundColor3 = Color3.fromRGB(255,255,255)
inputSection.BorderColor3 = Color3.fromRGB(200,200,200)
inputSection.BorderSizePixel = 1
inputSection.Parent = contentFrame

local inputLabel = Instance.new("TextLabel")
inputLabel.Size = UDim2.new(1, 0, 0, 25)
inputLabel.Position = UDim2.new(0, 5, 0, 5)
inputLabel.BackgroundTransparency = 1
inputLabel.Font = Enum.Font.GothamBold
inputLabel.TextSize = 14
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.TextColor3 = Color3.fromRGB(40,40,40)
inputLabel.Text = "Tambah Posisi Baru:"
inputLabel.Parent = inputSection

-- Position inputs (X, Y, Z)
local xInput = Instance.new("TextBox")
xInput.Size = UDim2.new(0.3, -5, 0, 25)
xInput.Position = UDim2.new(0, 5, 0, 30)
xInput.BackgroundColor3 = Color3.fromRGB(250,250,250)
xInput.BorderColor3 = Color3.fromRGB(180,180,180)
xInput.BorderSizePixel = 1
xInput.Font = Enum.Font.Gotham
xInput.TextSize = 12
xInput.PlaceholderText = "X Position"
xInput.Parent = inputSection

local yInput = Instance.new("TextBox")
yInput.Size = UDim2.new(0.3, -5, 0, 25)
yInput.Position = UDim2.new(0.33, 0, 0, 30)
yInput.BackgroundColor3 = Color3.fromRGB(250,250,250)
yInput.BorderColor3 = Color3.fromRGB(180,180,180)
yInput.BorderSizePixel = 1
yInput.Font = Enum.Font.Gotham
yInput.TextSize = 12
yInput.PlaceholderText = "Y Position"
yInput.Parent = inputSection

local zInput = Instance.new("TextBox")
zInput.Size = UDim2.new(0.3, -5, 0, 25)
zInput.Position = UDim2.new(0.66, 0, 0, 30)
zInput.BackgroundColor3 = Color3.fromRGB(250,250,250)
zInput.BorderColor3 = Color3.fromRGB(180,180,180)
zInput.BorderSizePixel = 1
zInput.Font = Enum.Font.Gotham
zInput.TextSize = 12
zInput.PlaceholderText = "Z Position"
zInput.Parent = inputSection

-- Set position here button (main button)
local setPosBtn = Instance.new("TextButton")
setPosBtn.Size = UDim2.new(0.32, -2, 0, 20)
setPosBtn.Position = UDim2.new(0, 5, 0, 58)
setPosBtn.BackgroundColor3 = Color3.fromRGB(50,180,50)
setPosBtn.BorderSizePixel = 0
setPosBtn.Font = Enum.Font.GothamBold
setPosBtn.TextSize = 11
setPosBtn.TextColor3 = Color3.fromRGB(255,255,255)
setPosBtn.Text = "📍 SET POS HERE"
setPosBtn.Parent = inputSection

-- Add current position button
local addCurrentBtn = Instance.new("TextButton")
addCurrentBtn.Size = UDim2.new(0.32, -2, 0, 20)
addCurrentBtn.Position = UDim2.new(0.33, 1, 0, 58)
addCurrentBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
addCurrentBtn.BorderSizePixel = 0
addCurrentBtn.Font = Enum.Font.Gotham
addCurrentBtn.TextSize = 10
addCurrentBtn.TextColor3 = Color3.fromRGB(255,255,255)
addCurrentBtn.Text = "Pos Sekarang"
addCurrentBtn.Parent = inputSection

-- Add manual position button
local addManualBtn = Instance.new("TextButton")
addManualBtn.Size = UDim2.new(0.32, -2, 0, 20)
addManualBtn.Position = UDim2.new(0.67, 2, 0, 58)
addManualBtn.BackgroundColor3 = Color3.fromRGB(80,150,200)
addManualBtn.BorderSizePixel = 0
addManualBtn.Font = Enum.Font.Gotham
addManualBtn.TextSize = 10
addManualBtn.TextColor3 = Color3.fromRGB(255,255,255)
addManualBtn.Text = "Pos Manual"
addManualBtn.Parent = inputSection

-- ====== Timer Section ======
local timerSection = Instance.new("Frame")
timerSection.Size = UDim2.new(1, 0, 0, 90)
timerSection.Position = UDim2.new(0, 0, 0, 150)
timerSection.BackgroundColor3 = Color3.fromRGB(255,255,255)
timerSection.BorderColor3 = Color3.fromRGB(200,200,200)
timerSection.BorderSizePixel = 1
timerSection.Parent = contentFrame

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 25)
timerLabel.Position = UDim2.new(0, 5, 0, 5)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 14
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.TextColor3 = Color3.fromRGB(40,40,40)
timerLabel.Text = "Pengaturan Teleport:"
timerLabel.Parent = timerSection

local timerInput = Instance.new("TextBox")
timerInput.Size = UDim2.new(0.25, -2, 0, 25)
timerInput.Position = UDim2.new(0, 5, 0, 30)
timerInput.BackgroundColor3 = Color3.fromRGB(250,250,250)
timerInput.BorderColor3 = Color3.fromRGB(180,180,180)
timerInput.BorderSizePixel = 1
timerInput.Font = Enum.Font.Gotham
timerInput.TextSize = 12
timerInput.Text = "1"
timerInput.Parent = timerSection

local intervalLabel = Instance.new("TextLabel")
intervalLabel.Size = UDim2.new(0.15, 0, 0, 25)
intervalLabel.Position = UDim2.new(0.26, 0, 0, 30)
intervalLabel.BackgroundTransparency = 1
intervalLabel.Font = Enum.Font.Gotham
intervalLabel.TextSize = 11
intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
intervalLabel.TextColor3 = Color3.fromRGB(80,80,80)
intervalLabel.Text = "detik"
intervalLabel.Parent = timerSection

-- Loop mode switch button
local loopBtn = Instance.new("TextButton")
loopBtn.Size = UDim2.new(0.35, -2, 0, 25)
loopBtn.Position = UDim2.new(0.43, 0, 0, 30)
loopBtn.BackgroundColor3 = Color3.fromRGB(50,150,250)
loopBtn.BorderSizePixel = 0
loopBtn.Font = Enum.Font.GothamBold
loopBtn.TextSize = 11
loopBtn.TextColor3 = Color3.fromRGB(255,255,255)
loopBtn.Text = "🔄 LOOP: ON"
loopBtn.Parent = timerSection

-- Control buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.48, -2, 0, 25)
startBtn.Position = UDim2.new(0, 5, 0, 60)
startBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
startBtn.BorderSizePixel = 0
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 12
startBtn.TextColor3 = Color3.fromRGB(255,255,255)
startBtn.Text = "▶️ START"
startBtn.Parent = timerSection

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48, -2, 0, 25)
stopBtn.Position = UDim2.new(0.52, 2, 0, 60)
stopBtn.BackgroundColor3 = Color3.fromRGB(200,100,100)
stopBtn.BorderSizePixel = 0
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 12
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.Text = "⏹️ STOP"
stopBtn.Parent = timerSection

-- ====== Position List Section ======
local listSection = Instance.new("Frame")
listSection.Size = UDim2.new(1, 0, 1, -250)
listSection.Position = UDim2.new(0, 0, 0, 250)
listSection.BackgroundColor3 = Color3.fromRGB(255,255,255)
listSection.BorderColor3 = Color3.fromRGB(200,200,200)
listSection.BorderSizePixel = 1
listSection.Parent = contentFrame

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, 0, 0, 25)
listLabel.Position = UDim2.new(0, 5, 0, 5)
listLabel.BackgroundTransparency = 1
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 14
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.TextColor3 = Color3.fromRGB(40,40,40)
listLabel.Text = "Daftar Posisi:"
listLabel.Parent = listSection

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -35)
scrollFrame.Position = UDim2.new(0, 5, 0, 30)
scrollFrame.BackgroundColor3 = Color3.fromRGB(248,248,248)
scrollFrame.BorderColor3 = Color3.fromRGB(200,200,200)
scrollFrame.BorderSizePixel = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = listSection

-- ====== Functions ======

-- Update config count display
local function updateConfigCount()
    local count = 0
    for _ in pairs(configData) do
        count = count + 1
    end
    configCountLabel.Text = "Configs saved: " .. count
end

-- Update position list display
local function updatePositionList()
    -- Clear existing items
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create new items
    for i, pos in pairs(positions) do
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, -10, 0, 30)
        item.Position = UDim2.new(0, 5, 0, (i-1) * 35)
        item.BackgroundColor3 = Color3.fromRGB(240,240,240)
        item.BorderColor3 = Color3.fromRGB(200,200,200)
        item.BorderSizePixel = 1
        item.Parent = scrollFrame
        
        local posText = Instance.new("TextLabel")
        posText.Size = UDim2.new(1, -100, 1, 0)
        posText.Position = UDim2.new(0, 5, 0, 0)
        posText.BackgroundTransparency = 1
        posText.Font = Enum.Font.Gotham
        posText.TextSize = 11
        posText.TextXAlignment = Enum.TextXAlignment.Left
        posText.TextColor3 = Color3.fromRGB(60,60,60)
        posText.Text = string.format("%d. (%.1f, %.1f, %.1f)", i, pos.X, pos.Y, pos.Z)
        posText.Parent = item
        
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 40, 0, 20)
        tpBtn.Position = UDim2.new(1, -85, 0.5, -10)
        tpBtn.BackgroundColor3 = Color3.fromRGB(100,150,200)
        tpBtn.BorderSizePixel = 0
        tpBtn.Font = Enum.Font.Gotham
        tpBtn.TextSize = 10
        tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
        tpBtn.Text = "TP"
        tpBtn.Parent = item
        
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 40, 0, 20)
        delBtn.Position = UDim2.new(1, -40, 0.5, -10)
        delBtn.BackgroundColor3 = Color3.fromRGB(200,100,100)
        delBtn.BorderSizePixel = 0
        delBtn.Font = Enum.Font.Gotham
        delBtn.TextSize = 10
        delBtn.TextColor3 = Color3.fromRGB(255,255,255)
        delBtn.Text = "DEL"
        delBtn.Parent = item
        
        -- Button connections
        tpBtn.MouseButton1Click:Connect(function()
            if rootPart then
                rootPart.CFrame = CFrame.new(pos)
            end
        end)
        
        delBtn.MouseButton1Click:Connect(function()
            table.remove(positions, i)
            updatePositionList()
        end)
    end
    
    -- Update scroll canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #positions * 35)
end

-- ====== Button Connections ======

-- Save and Load Config buttons
saveConfigBtn.MouseButton1Click:Connect(function()
    saveConfig()
    updateConfigCount()
end)

loadConfigBtn.MouseButton1Click:Connect(function()
    loadConfig()
end)

-- Add position using "Set Pos Here" button (main method)
setPosBtn.MouseButton1Click:Connect(function()
    if rootPart then
        local pos = rootPart.Position
        table.insert(positions, Vector3.new(pos.X, pos.Y, pos.Z))
        updatePositionList()
        
        -- Visual feedback
        setPosBtn.Text = "✅ POS SAVED!"
        setPosBtn.BackgroundColor3 = Color3.fromRGB(30,150,30)
        wait(0.8)
        setPosBtn.Text = "📍 SET POS HERE"
        setPosBtn.BackgroundColor3 = Color3.fromRGB(50,180,50)
    end
end)

-- Add current position (alternative method)
addCurrentBtn.MouseButton1Click:Connect(function()
    if rootPart then
        local pos = rootPart.Position
        table.insert(positions, Vector3.new(pos.X, pos.Y, pos.Z))
        updatePositionList()
    end
end)

-- Add manual position
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

-- Teleport function with loop/one-time mode
local function teleportToNext()
    if #positions == 0 then return false end
    
    if currentIndex > #positions then
        if loopMode then
            currentIndex = 1  -- Reset to first position for loop
        else
            return false  -- Stop if not in loop mode
        end
    end
    
    if rootPart then
        rootPart.CFrame = CFrame.new(positions[currentIndex])
        currentIndex = currentIndex + 1
    end
    
    return true
end

-- Loop mode toggle
loopBtn.MouseButton1Click:Connect(function()
    loopMode = not loopMode
    if loopMode then
        loopBtn.Text = "🔄 LOOP: ON"
        loopBtn.BackgroundColor3 = Color3.fromRGB(50,150,250)
    else
        loopBtn.Text = "🔂 LOOP: OFF"
        loopBtn.BackgroundColor3 = Color3.fromRGB(150,150,150)
    end
end)

-- Start teleport loop with loop mode support
startBtn.MouseButton1Click:Connect(function()
    if #positions == 0 then return end
    if isRunning then return end
    
    local interval = tonumber(timerInput.Text) or 1
    isRunning = true
    currentIndex = 1
    
    teleportLoop = coroutine.create(function()
        while isRunning do
            local shouldContinue = teleportToNext()
            
            -- If not in loop mode and reached the end, stop
            if not shouldContinue and not loopMode then
                isRunning = false
                break
            end
            
            wait(interval)
        end
    end)
    
    coroutine.resume(teleportLoop)
end)

-- Stop teleport loop
stopBtn.MouseButton1Click:Connect(function()
    isRunning = false
    if teleportLoop then
        teleportLoop = nil
    end
end)

-- ====== Window Controls ======
local origHeight = frame.Size.Y.Offset
local minimized = false

exitBtn.MouseButton1Click:Connect(function()
    isRunning = false
    gui:Destroy()
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        origHeight = frame.Size.Y.Offset
        contentFrame.Visible = false
        frame:TweenSize(UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, titleBar.Size.Y.Offset),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
    else
        frame:TweenSize(UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, origHeight),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true,
            function() contentFrame.Visible = true end)
    end
end)

-- ====== Resize Handle ======
local handle = Instance.new("Frame")
handle.Size = UDim2.new(0, 16, 0, 16)
handle.Position = UDim2.new(1, -16, 1, -16)
handle.BackgroundColor3 = Color3.fromRGB(200,200,200)
handle.BorderSizePixel = 0
handle.Active = true
handle.Parent = frame

local uis = game:GetService("UserInputService")
local resizing = false
local dragStart
local startSize

handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        dragStart = uis:GetMouseLocation()
        startSize = frame.Size
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

uis.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = uis:GetMouseLocation() - dragStart
        local newW = math.max(450, startSize.X.Offset + delta.X)
        local newH = math.max(400, startSize.Y.Offset + delta.Y)
        frame.Size = UDim2.new(0, newW, 0, newH)
    end
end)

-- ====== Auto-detect Map Changes ======
local function detectMapChange()
    local newMapName = getCurrentMapName()
    if newMapName ~= currentMapName then
        -- Auto-save current config before switching
        if #positions > 0 then
            saveConfig()
        end
        
        -- Switch to new map
        currentMapName = newMapName
        mapLabel.Text = "🗺️ Map: " .. currentMapName
        
        -- Auto-load config for new map if available
        loadConfig()
        updateConfigCount()
    end
end

-- Monitor for map changes every 5 seconds
coroutine.create(function()
    while gui.Parent do
        detectMapChange()
        wait(5)
    end
end)

-- ====== Initialize ======
-- Load existing config for current map
loadConfig()
updateConfigCount()

-- Update character reference when respawned
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- Check if map changed after respawn
    detectMapChange()
end)

-- ====== Additional Features ======

-- Auto-save when positions are modified
local originalInsert = table.insert
local originalRemove = table.remove

-- Monitor position changes for auto-save
local lastPositionCount = 0
coroutine.create(function()
    while gui.Parent do
        if #positions ~= lastPositionCount then
            lastPositionCount = #positions
            -- Auto-save after 2 seconds of no changes
            wait(2)
            if #positions == lastPositionCount and #positions > 0 then
                saveConfig()
                updateConfigCount()
            end
        end
        wait(1)
    end
end)

-- Add keyboard shortcuts
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        -- Toggle GUI visibility
        frame.Visible = not frame.Visible
    elseif input.KeyCode == Enum.KeyCode.F2 then
        -- Quick save current position
        if rootPart then
            local pos = rootPart.Position
            table.insert(positions, Vector3.new(pos.X, pos.Y, pos.Z))
            updatePositionList()
        end
    elseif input.KeyCode == Enum.KeyCode.F3 then
        -- Quick save config
        saveConfig()
        updateConfigCount()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        -- Quick load config
        loadConfig()
    end
end)

-- Add status indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 15)
statusLabel.Position = UDim2.new(0, 10, 1, -18)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 9
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.TextColor3 = Color3.fromRGB(120,120,120)
statusLabel.Text = "F1:Hide F2:AddPos F3:Save F4:Load"
statusLabel.Parent = mapSection

print("Denji Teleport System v3.0 loaded successfully!")
print("Map-specific configuration system active for:", currentMapName)
print("Keyboard shortcuts: F1=Toggle, F2=Add Position, F3=Save, F4=Load")