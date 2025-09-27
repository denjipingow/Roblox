local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Pastikan LocalPlayer ada
if not LocalPlayer then
    warn("LocalPlayer not found. Script likely not running in an executor context.")
    return
end

-- Konstanta
local GUI_COLOR = Color3.fromRGB(45, 45, 45) -- Warna latar belakang gelap
local ACCENT_COLOR = Color3.fromRGB(0, 170, 255) -- Warna aksen biru cerah
local TEXT_COLOR = Color3.fromRGB(255, 255, 255) -- Warna teks putih
local TOGGLE_ON_COLOR = Color3.fromRGB(85, 255, 0) -- Hijau untuk ON
local TOGGLE_OFF_COLOR = Color3.fromRGB(255, 0, 0) -- Merah untuk OFF
local FONT_STYLE = Enum.Font.Roboto

-- Sound Effects (Fungsi ini DIBUANG, tetapi definisinya dipertahankan sebagai fungsi kosong)
-- Jika Anda ingin mengaktifkannya lagi, masukkan kode di dalamnya.
local function playSound(soundId)
    -- Dihapus sesuai permintaan user.
end

-- Play initial sound (Dihapus)
-- playSound("2865227271")

---
## GUI Setup

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanSuperRingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480) -- Ukuran yang lebih terstruktur
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = GUI_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Round the GUI
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Super Ring Parts V6"
Title.TextColor3 = TEXT_COLOR
Title.BackgroundColor3 = ACCENT_COLOR
Title.Font = FONT_STYLE
Title.TextSize = 22
Title.Parent = MainFrame

-- Round the title (hanya bagian bawah)
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Size = UDim2.new(1, 0, 0.8, -120) -- Diperkecil untuk memberi ruang di bawah
ControlsFrame.Position = UDim2.new(0, 0, 0, 40)
ControlsFrame.BackgroundColor3 = GUI_COLOR
ControlsFrame.BorderSizePixel = 0
ControlsFrame.Parent = MainFrame

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.Padding = UDim.new(0, 10)
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlsLayout.Parent = ControlsFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = ControlsFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "RingToggleButton"
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Text = "Tornado Off"
ToggleButton.BackgroundColor3 = TOGGLE_OFF_COLOR
ToggleButton.TextColor3 = TEXT_COLOR
ToggleButton.Font = FONT_STYLE
ToggleButton.TextSize = 18
ToggleButton.LayoutOrder = 1
ToggleButton.Parent = ControlsFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

---
## Configuration and Persistence

local config = {
    radius = 50,
    height = 100,
    rotationSpeed = 10,
    attractionStrength = 1000,
}

local function saveConfig()
    -- Asumsinya 'writefile' tersedia di executor
    local configStr = HttpService:JSONEncode(config)
    writefile("SuperRingPartsConfig.txt", configStr)
end

local function loadConfig()
    -- Asumsinya 'readfile' dan 'isfile' tersedia di executor
    if isfile("SuperRingPartsConfig.txt") then
        local configStr = readfile("SuperRingPartsConfig.txt")
        local success, loadedConfig = pcall(HttpService.JSONDecode, HttpService, configStr)
        if success and type(loadedConfig) == "table" then
            for k, v in pairs(loadedConfig) do
                if config[k] ~= nil and type(v) == type(config[k]) then
                    config[k] = v
                end
            end
        end
    end
end

loadConfig()

---
## Control Creation Function

local function createControl(name, labelText, defaultValue, callback, layoutOrder)
    local ControlPanel = Instance.new("Frame")
    ControlPanel.Size = UDim2.new(1, 0, 0, 90) -- Tinggi panel
    ControlPanel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ControlPanel.BorderSizePixel = 0
    ControlPanel.LayoutOrder = layoutOrder
    ControlPanel.Parent = ControlsFrame
    
    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 8)
    PanelCorner.Parent = ControlPanel
    
    local PanelPadding = Instance.new("UIPadding")
    PanelPadding.PaddingTop = UDim.new(0, 5)
    PanelPadding.PaddingBottom = UDim.new(0, 5)
    PanelPadding.PaddingLeft = UDim.new(0, 5)
    PanelPadding.PaddingRight = UDim.new(0, 5)
    PanelPadding.Parent = ControlPanel

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.Parent = ControlPanel

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = labelText .. ": " .. defaultValue
    Label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Label.TextColor3 = TEXT_COLOR
    Label.Font = FONT_STYLE
    Label.TextSize = 16
    Label.Parent = ControlPanel
    
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = ControlPanel
    
    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.Padding = UDim.new(0, 5)
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.Parent = ButtonFrame
    
    local DecreaseButton = Instance.new("TextButton")
    DecreaseButton.Size = UDim2.new(0.33, 0, 1, 0)
    DecreaseButton.Text = "–10" -- Teks yang lebih jelas
    DecreaseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    DecreaseButton.TextColor3 = TEXT_COLOR
    DecreaseButton.Font = FONT_STYLE
    DecreaseButton.TextSize = 16
    DecreaseButton.Parent = ButtonFrame
    
    local DisplayBox = Instance.new("TextLabel")
    DisplayBox.Size = UDim2.new(0.33, 0, 1, 0)
    DisplayBox.Text = tostring(defaultValue)
    DisplayBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    DisplayBox.TextColor3 = TEXT_COLOR
    DisplayBox.Font = FONT_STYLE
    DisplayBox.TextSize = 18
    DisplayBox.Parent = ButtonFrame
    
    local IncreaseButton = Instance.new("TextButton")
    IncreaseButton.Size = UDim2.new(0.33, 0, 1, 0)
    IncreaseButton.Text = "+10" -- Teks yang lebih jelas
    IncreaseButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    IncreaseButton.TextColor3 = TEXT_COLOR
    IncreaseButton.Font = FONT_STYLE
    IncreaseButton.TextSize = 16
    IncreaseButton.Parent = ButtonFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 5)
    ButtonCorner.Parent = DecreaseButton
    
    local ButtonCorner2 = Instance.new("UICorner")
    ButtonCorner2.CornerRadius = UDim.new(0, 5)
    ButtonCorner2.Parent = IncreaseButton
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, 0, 0, 25)
    TextBox.PlaceholderText = "Enter new value (0-10000)"
    TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TextBox.TextColor3 = TEXT_COLOR
    TextBox.Font = FONT_STYLE
    TextBox.TextSize = 14
    TextBox.Parent = ControlPanel
    
    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(0, 5)
    TBCorner.Parent = TextBox

    local function updateValue(newValue)
        newValue = math.clamp(newValue, 0, 10000)
        Label.Text = labelText .. ": " .. newValue
        DisplayBox.Text = tostring(newValue)
        callback(newValue)
        saveConfig()
    end

    DecreaseButton.MouseButton1Click:Connect(function()
        local value = tonumber(DisplayBox.Text) or defaultValue
        updateValue(math.max(0, value - 10))
    end)

    IncreaseButton.MouseButton1Click:Connect(function()
        local value = tonumber(DisplayBox.Text) or defaultValue
        updateValue(math.min(10000, value + 10))
    end)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newValue = tonumber(TextBox.Text)
            if newValue ~= nil then
                updateValue(newValue)
            end
            TextBox.Text = ""
        end
    end)
    
    -- Inisialisasi tampilan
    updateValue(defaultValue)
end

-- Tambahkan kontrol ke ControlsFrame dengan layoutOrder
createControl("Radius", "Radius (Studs)", config.radius, function(value) config.radius = value end, 2)
createControl("Height", "Height (Studs)", config.height, function(value) config.height = value end, 3)
createControl("RotationSpeed", "Rotation Speed (Deg)", config.rotationSpeed, function(value) config.rotationSpeed = value end, 4)
createControl("AttractionStrength", "Attraction Strength", config.attractionStrength, function(value) config.attractionStrength = value end, 5)

---
## Minimize Button (Ditingkatkan)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Text = "—"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeButton.Font = FONT_STYLE
MinimizeButton.TextSize = 18
MinimizeButton.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 15)
MinimizeCorner.Parent = MinimizeButton

local MINIMIZED_HEIGHT = 40
local FULL_HEIGHT = 480

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 320, 0, MINIMIZED_HEIGHT), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "+"
        ControlsFrame.Visible = false
        OtherFeaturesFrame.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 320, 0, FULL_HEIGHT), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "—"
        -- Tunda visibilitas agar Tweening tidak terpotong
        wait(0.3) 
        ControlsFrame.Visible = true
        OtherFeaturesFrame.Visible = true
    end
end)

---
## Draggable Functionality 
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Target == Title or input.Target == MainFrame then -- Hanya bisa didrag dari Title atau MainFrame
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

---
## Additional Features Panel

local OtherFeaturesFrame = Instance.new("Frame")
OtherFeaturesFrame.Name = "OtherFeaturesFrame"
OtherFeaturesFrame.Size = UDim2.new(1, 0, 0, 80) -- Tinggi yang lebih kecil
OtherFeaturesFrame.Position = UDim2.new(0, 0, 1, -80)
OtherFeaturesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OtherFeaturesFrame.BorderSizePixel = 0
OtherFeaturesFrame.Parent = MainFrame

local FeaturesLayout = Instance.new("UIListLayout")
FeaturesLayout.Padding = UDim.new(0, 5)
FeaturesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FeaturesLayout.VerticalAlignment = Enum.VerticalAlignment.Center
FeaturesLayout.FillDirection = Enum.FillDirection.Horizontal
FeaturesLayout.Parent = OtherFeaturesFrame

local FeaturesPadding = Instance.new("UIPadding")
FeaturesPadding.PaddingLeft = UDim.new(0, 5)
FeaturesPadding.PaddingRight = UDim.new(0, 5)
FeaturesPadding.Parent = OtherFeaturesFrame

local function createFeatureButton(name, color, callback)
    local Button = Instance.new("TextButton") 
    Button.Name = name:gsub(" ", "") .. "Button"
    Button.Size = UDim2.new(0.12, 0, 0.8, 0) -- Ukuran relatif di frame horizontal (sedikit diperkecil untuk lebih banyak tombol)
    Button.BackgroundColor3 = color
    Button.Text = name
    Button.Font = FONT_STYLE
    Button.TextColor3 = TEXT_COLOR
    Button.TextSize = 14
    Button.TextScaled = true
    Button.TextWrapped = true
    Button.Parent = OtherFeaturesFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function() 
        callback()
    end)
end

-- Definisi fitur tambahan
createFeatureButton("Fly", Color3.fromRGB(0, 100, 200), function()
    loadstring(game:HttpGet('https://pastebin.com/raw/YSL3xKYU'))()
end)

createFeatureButton("NoFallDmg", Color3.fromRGB(200, 0, 0), function()
    local runsvc = game:GetService("RunService")
    local novel = Vector3.zero
    
    local function nofalldamage(chr)
        local root = chr:WaitForChild("HumanoidRootPart")
        if root then
            local con
            con = runsvc.Heartbeat:Connect(function()
                if not root.Parent then con:Disconnect(); return end
                
                local oldvel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = novel
                
                runsvc.RenderStepped:Wait()
                root.AssemblyLinearVelocity = oldvel
            end)
        end
    end
    
    nofalldamage(LocalPlayer.Character)
    LocalPlayer.CharacterAdded:Connect(nofalldamage)
end)

createFeatureButton("Noclip", Color3.fromRGB(0, 0, 0), function()
    local NoclipToggle = false
    local NoclipConnection = nil

    if NoclipConnection then 
        NoclipConnection:Disconnect() 
        NoclipConnection = nil
        NoclipToggle = false
        if LocalPlayer.Character then
            for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') then
                    v.CanCollide = true 
                end
            end
        end
        return
    end

    NoclipToggle = true
    NoclipConnection = game:GetService('RunService').Stepped:Connect(function()
        if NoclipToggle and LocalPlayer.Character then
            for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA('BasePart') and v.CanCollide and v.Name ~= "HumanoidRootPart" then
                    v.CanCollide = false
                end
            end
        end
    end)
end)

createFeatureButton("InfJump", Color3.fromRGB(0, 200, 0), function()
    local InfiniteJumpEnabled = true 
    game:GetService("UserInputService").JumpRequest:Connect(function() 	
        if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then 		
            LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState(Enum.HumanoidStateType.Jumping) 	
        end 
    end)
end)

createFeatureButton("Yield", Color3.fromRGB(0, 200, 200), function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

createFeatureButton("NAMELESS", Color3.fromRGB(50, 50, 50), function()
    loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Nameless-Admin-FE-11243"))()
end)

createFeatureButton("FPS", Color3.fromRGB(50, 50, 50), function()
    loadstring(game:HttpGet("https://pastebin.com/raw/ySHJdZpb",true))()
end)

---
## Tornado Parts Logic

local Workspace = game:GetService("Workspace")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Parts Management
local ringPartsEnabled = false
local parts = {}

local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false 
        end

        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end

local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

RunService.Heartbeat:Connect(function(deltaTime)
    if not ringPartsEnabled then return end
    
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local centerPos = rootPart.Position
        local timeDelta = deltaTime * config.rotationSpeed * 0.1 
        
        for i = #parts, 1, -1 do
            local part = parts[i]
            
            if part and part.Parent and not part.Anchored then
                local pos = part.Position
                local horizontalDelta = Vector3.new(pos.X, centerPos.Y, pos.Z) - centerPos
                local distance = horizontalDelta.Magnitude
                
                local angle = math.atan2(horizontalDelta.Z, horizontalDelta.X)
                local newAngle = angle + math.rad(timeDelta)
                
                local targetRadius = math.min(config.radius, distance)
                
                local yOffset = (config.height / 2) * math.sin(centerPos.Y + (distance * 0.1) + (RunService.Heartbeat:Wait() * 2)) 
                local targetY = centerPos.Y + yOffset

                local targetPos = Vector3.new(
                    centerPos.X + math.cos(newAngle) * targetRadius,
                    targetY,
                    centerPos.Z + math.sin(newAngle) * targetRadius
                )
                
                local directionToTarget = (targetPos - part.Position).unit
                part.Velocity = directionToTarget * config.attractionStrength
            else
                table.remove(parts, i)
            end
        end
    end
end)

-- Toggle Button Functionality
ToggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    ToggleButton.Text = ringPartsEnabled and "Tornado ON" or "Tornado Off"
    ToggleButton.BackgroundColor3 = ringPartsEnabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
end)

---
## Visual Effects (Rainow)

-- Rainbow Background Effect (Hanya untuk MainFrame)
local hue = 0
RunService.Heartbeat:Connect(function()
    hue = (hue + 0.005) % 1 
    MainFrame.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 0.4) 
end)

-- Rainbow TextLabel (Untuk Title)
local textHue = 0
RunService.Heartbeat:Connect(function()
    textHue = (textHue + 0.01) % 1
    Title.BackgroundColor3 = Color3.fromHSV(textHue, 1, 1)
    Title.TextColor3 = Color3.fromRGB(0, 0, 0)
end)


-- Notifikasi Awal
local userId = Players:GetUserIdFromNameAsync("Robloxlukasgames") or 1 
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

StarterGui:SetCore("SendNotification", {
    Title = "Super Ring Parts V6 (Silent)",
    Text = "Script siap digunakan. Efek suara telah dinonaktifkan.",
    Icon = content,
    Duration = 5
})
