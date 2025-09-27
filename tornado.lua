--[[
    Script: AbsoluteControlSystem.lua
    Lokasi: ServerScriptService

    Fungsi: Mengimplementasikan mode PULL dan TORNADO yang mutlak (menargetkan semua BasePart).
    
    Mode Akses: PUBLIK - Semua pemain dapat menggunakan kontrol.
    Fokus Executor: Pemain yang menekan tombol akan menjadi PUSAT efek untuk semua Parts di server.
    Jangkauan: Mutlak, menargetkan SEMUA BasePart di seluruh Workspace (semua map).

    *** PERINGATAN! Fungsionalitas mutlak ini dapat menyebabkan lag server parah. ***
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- PENGATURAN SERVER STATE
local TELEPORT_EVENT_NAME = "AbsoluteTeleportControl"
local ServerState = {
    Mode = "OFF", -- "OFF", "PULL", atau "TORNADO"
    TeleportDelay = 0.03, 
    MaxPartsPerBatch = 50,
    ControlledBy = nil, -- Menyimpan objek Player yang sedang mengaktifkan mode (Executor)
}

local ServerTime = 0 

--------------------------------------------------------------------------------
-- 1. SERVER LOGIC & CORE FUNCTIONS
--------------------------------------------------------------------------------

local TeleportControlEvent = Instance.new("RemoteEvent")
TeleportControlEvent.Name = TELEPORT_EVENT_NAME
TeleportControlEvent.Parent = ReplicatedStorage

-- Mengumpulkan SEMUA BasePart, tanpa filter sama sekali.
local function collectAllParts()
    local partsToMove = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(partsToMove, obj)
        end
    end
    return partsToMove
end

-- PULL MODE: Memindahkan semua bagian secara langsung ke target
local function runPull(partsToMove, targetCFrame)
    local offset = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
    local targetPosition = targetCFrame.p + offset
    for _, part in ipairs(partsToMove) do
        if part and part.Parent and part:IsA("BasePart") then
            part.CFrame = CFrame.new(targetPosition)
        end
    end
end

-- TORNADO MODE: Membuat bagian berputar dan naik di sekitar target
local function runTornado(partsToMove, targetCFrame)
    ServerTime = ServerTime + 0.1 

    for i, part in ipairs(partsToMove) do
        if part and part.Parent and part:IsA("BasePart") then
            local relativePos = part.Position - targetCFrame.p
            local distance = relativePos.Magnitude
            
            local newRadius = math.clamp(distance, 5, 30) 
            local angle = ServerTime + (i * 0.1) 
            
            local x = newRadius * math.cos(angle)
            local z = newRadius * math.sin(angle)
            
            local yLift = math.sin(ServerTime * 2) * 5 
            
            local newPosition = targetCFrame.p + Vector3.new(x, 5 + yLift, z)
            
            part.CFrame = CFrame.new(newPosition) * CFrame.Angles(0, angle, 0)
        end
    end
end

-- Loop utama yang berjalan di server
task.spawn(function()
    while task.wait(0.1) do 
        if ServerState.Mode == "OFF" then continue end

        -- Ambil pemain yang mengontrol mode (Executor)
        local player = ServerState.ControlledBy
        if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then continue end

        local rootPart = player.Character.HumanoidRootPart
        local targetCFrame = rootPart.CFrame * CFrame.new(0, 5, 0) 
        
        local partsToMove = collectAllParts()
        local totalParts = #partsToMove
        if totalParts == 0 then continue end
        
        local currentPartIndex = 1
        
        -- Proses pemindahan dalam batch
        while currentPartIndex <= totalParts and ServerState.Mode ~= "OFF" do
            local batchStart = currentPartIndex
            local batchEnd = math.min(currentPartIndex + ServerState.MaxPartsPerBatch - 1, totalParts)
            
            local currentBatch = {}
            for i = batchStart, batchEnd do
                table.insert(currentBatch, partsToMove[i])
            end

            if ServerState.Mode == "PULL" then
                runPull(currentBatch, targetCFrame)
            elseif ServerState.Mode == "TORNADO" then
                runTornado(currentBatch, targetCFrame)
            end

            currentPartIndex = batchEnd + 1
            task.wait(ServerState.TeleportDelay)
        end
    end
end)

-- Menangani event dari klien (Mode dan Kecepatan)
TeleportControlEvent.OnServerEvent:Connect(function(player, action, value)
    
    if action == "SetMode" then
        ServerState.Mode = value 
        if ServerState.Mode ~= "OFF" then
            -- Pemain yang terakhir menekan tombol akan menjadi pusat efek (Executor)
            ServerState.ControlledBy = player 
        else
            ServerState.ControlledBy = nil
        end
        print(string.format("[Server] Mode diubah oleh PEMAIN %s: %s", player.Name, ServerState.Mode))
    elseif action == "SetSpeed" then
        local speed = math.clamp(value, 1, 10)
        local newDelay = 0.5 - (speed * 0.049)
        ServerState.TeleportDelay = newDelay
        ServerState.MaxPartsPerBatch = math.floor(50 * (speed / 10)) + 1 
        print(string.format("[Server] Kecepatan diubah oleh PEMAIN %s: %d", player.Name, speed))
    end
end)


--------------------------------------------------------------------------------
-- 2. CLIENT LOGIC & UI INJECTION (Untuk Semua Pemain)
--------------------------------------------------------------------------------

local ClientScriptTemplate = [[
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportEvent = ReplicatedStorage:WaitForChild("%s") 

    local ScreenGui = script.Parent
    local Frame = ScreenGui:WaitForChild("Frame")
    local ModeStatus = Frame:WaitForChild("ModeStatus")
    local PullButton = Frame:WaitForChild("PullButton")
    local TornadoButton = Frame:WaitForChild("TornadoButton")
    local OffButton = Frame:WaitForChild("OffButton")
    local SpeedInput = Frame:WaitForChild("SpeedInput")
    local SpeedDisplay = Frame:WaitForChild("SpeedDisplay")

    local currentMode = "OFF"
    
    local OFF_COLOR = Color3.fromRGB(255, 50, 50) 
    local PULL_COLOR = Color3.fromRGB(0, 100, 200) 
    local TORNADO_COLOR = Color3.fromRGB(255, 165, 0) 

    local function updateStatus(mode)
        currentMode = mode
        ModeStatus.Text = "MODE AKTIF: " .. mode
        
        -- Reset warna tombol
        PullButton.BackgroundColor3 = PULL_COLOR * 0.5
        TornadoButton.BackgroundColor3 = TORNADO_COLOR * 0.5
        OffButton.BackgroundColor3 = OFF_COLOR * 0.5

        -- Sorot tombol yang aktif
        if mode == "PULL" then
            PullButton.BackgroundColor3 = PULL_COLOR 
        elseif mode == "TORNADO" then
            TornadoButton.BackgroundColor3 = TORNADO_COLOR
        elseif mode == "OFF" then
            OffButton.BackgroundColor3 = OFF_COLOR
        end
    end

    PullButton.MouseButton1Click:Connect(function()
        TeleportEvent:FireServer("SetMode", "PULL")
        updateStatus("PULL")
    end)
    
    TornadoButton.MouseButton1Click:Connect(function()
        TeleportEvent:FireServer("SetMode", "TORNADO")
        updateStatus("TORNADO")
    end)
    
    OffButton.MouseButton1Click:Connect(function()
        TeleportEvent:FireServer("SetMode", "OFF")
        updateStatus("OFF")
    end)

    local function updateSpeed(text)
        local speedValue = tonumber(text)
        if speedValue and speedValue >= 1 and speedValue <= 10 then
            TeleportEvent:FireServer("SetSpeed", speedValue)
            SpeedDisplay.Text = string.format("KECEPATAN TELEPORT (1-10): %d", math.round(speedValue))
            SpeedInput.Text = speedValue 
        else
            SpeedDisplay.Text = "KECEPATAN TELEPORT (1-10): Input harus antara 1-10"
        end
    end

    SpeedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed or not enterPressed then
            updateSpeed(SpeedInput.Text)
        end
    end)

    updateStatus("OFF")
    updateSpeed(10)
]]

-- Fungsi untuk membuat UI (Untuk Semua Pemain)
local function createTeleportUI(player)
    
    if player.PlayerGui:FindFirstChild("TeleportPartsSystemUI") then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TeleportPartsSystemUI"
    ScreenGui.Parent = player.PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Name = "Frame"
    Frame.Size = UDim2.new(0, 320, 0, 240)
    Frame.Position = UDim2.new(0.5, 0, 0.1, 0)
    Frame.AnchorPoint = Vector2.new(0.5, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Frame

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "KONTROL MUTLAK PUBLIK (EXECUTOR)"
    Title.Parent = Frame
    
    local ModeStatus = Instance.new("TextLabel")
    ModeStatus.Name = "ModeStatus"
    ModeStatus.Size = UDim2.new(1, -20, 0, 20)
    ModeStatus.BackgroundTransparency = 1
    ModeStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeStatus.TextScaled = true
    ModeStatus.Font = Enum.Font.SourceSansBold
    ModeStatus.Text = "MODE AKTIF: OFF"
    ModeStatus.Parent = Frame

    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, -20, 0, 40)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Parent = Frame
    
    local HorizontalLayout = Instance.new("UIListLayout")
    HorizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    HorizontalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    HorizontalLayout.Padding = UDim.new(0, 5)
    HorizontalLayout.Parent = ControlsFrame
    
    local PullButton = Instance.new("TextButton")
    PullButton.Name = "PullButton"
    PullButton.Size = UDim2.new(0.33, -10, 1, 0)
    PullButton.Font = Enum.Font.SourceSansBold
    PullButton.TextSize = 14
    PullButton.TextColor3 = Color3.new(1, 1, 1)
    PullButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200) * 0.5 
    PullButton.Text = "PULL"
    PullButton.Parent = ControlsFrame

    local BtnCorner1 = Instance.new("UICorner")
    BtnCorner1.CornerRadius = UDim.new(0, 6)
    BtnCorner1.Parent = PullButton
    
    local TornadoButton = Instance.new("TextButton")
    TornadoButton.Name = "TornadoButton"
    TornadoButton.Size = UDim2.new(0.33, -10, 1, 0)
    TornadoButton.Font = Enum.Font.SourceSansBold
    TornadoButton.TextSize = 14
    TornadoButton.TextColor3 = Color3.new(1, 1, 1)
    TornadoButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0) * 0.5
    TornadoButton.Text = "TORNADO"
    TornadoButton.Parent = ControlsFrame

    local BtnCorner2 = Instance.new("UICorner")
    BtnCorner2.CornerRadius = UDim.new(0, 6)
    BtnCorner2.Parent = TornadoButton
    
    local OffButton = Instance.new("TextButton")
    OffButton.Name = "OffButton"
    OffButton.Size = UDim2.new(0.33, -10, 1, 0)
    OffButton.Font = Enum.Font.SourceSansBold
    OffButton.TextSize = 14
    OffButton.TextColor3 = Color3.new(1, 1, 1)
    OffButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50) 
    OffButton.Text = "OFF"
    OffButton.Parent = ControlsFrame

    local BtnCorner3 = Instance.new("UICorner")
    BtnCorner3.CornerRadius = UDim.new(0, 6)
    BtnCorner3.Parent = OffButton

    local SpeedDisplay = Instance.new("TextLabel")
    SpeedDisplay.Name = "SpeedDisplay"
    SpeedDisplay.Size = UDim2.new(1, -20, 0, 20)
    SpeedDisplay.BackgroundTransparency = 1
    SpeedDisplay.TextColor3 = Color3.fromRGB(255, 200, 200) 
    SpeedDisplay.TextScaled = true
    SpeedDisplay.Font = Enum.Font.SourceSans
    SpeedDisplay.Text = "KECEPATAN TELEPORT (1-10): 10 (Sangat Berisiko)"
    SpeedDisplay.Parent = Frame

    local SpeedInput = Instance.new("TextBox")
    SpeedInput.Name = "SpeedInput"
    SpeedInput.PlaceholderText = "Input 1 (Lambat) sampai 10 (Sangat Cepat)"
    SpeedInput.Size = UDim2.new(1, -20, 0, 25)
    SpeedInput.Text = "10" 
    SpeedInput.Font = Enum.Font.SourceSans
    SpeedInput.TextSize = 14
    SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedInput.Parent = Frame

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = SpeedInput

    local LocalScript = Instance.new("LocalScript")
    LocalScript.Name = "TeleportControlClient"
    LocalScript.Source = string.format(ClientScriptTemplate, TELEPORT_EVENT_NAME)
    LocalScript.Parent = ScreenGui
    
end

-- Menghubungkan fungsi ke setiap pemain yang bergabung
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait() 
    createTeleportUI(player)
end)

-- Pasang UI untuk pemain yang sudah ada
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        createTeleportUI(player)
    end
end
