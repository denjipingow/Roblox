--[[
Script: Bring All Parts (TP Semua Bagian) dengan Kontrol Kecepatan
Peringatan: Skrip ini dirancang untuk dijalankan menggunakan Executor eksternal.
Fitur: Memindahkan SEMUA BasePart ke posisi pemain dengan kecepatan yang dapat diatur secara real-time.
--]]

-- Layanan dan Variabel Utama
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Pastikan pemain lokal ada
if not LocalPlayer then return end

-- Variabel Status & Konfigurasi
local isBringingParts = false
local PARTS_MOVE_OFFSET = CFrame.new(0, 5, 0) -- Jarak 5 stud di atas kepala
local currentDelay = 0.1 -- Kecepatan default (0.1 detik)
local MIN_DELAY = 0.01 -- Kecepatan minimum (sangat cepat)
local MAX_DELAY = 1.0  -- Kecepatan maksimum (lambat)

-- =================================================================================
-- 1. FUNGSI UI (Antarmuka Pengguna)
-- =================================================================================

local function CreateUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Hapus UI lama jika ada
    if PlayerGui:FindFirstChild("BringPartsUI") then
        PlayerGui.BringPartsUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BringPartsUI"
    ScreenGui.Parent = PlayerGui

    -- Frame Kontrol Utama
    local Frame = Instance.new("Frame")
    Frame.Name = "ControlFrame"
    Frame.Size = UDim2.new(0, 250, 0, 150) -- Ukuran lebih besar untuk slider
    Frame.Position = UDim2.new(0.5, -125, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 2
    Frame.Parent = ScreenGui

    -- Judul
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 18
    TitleLabel.Text = "Bring All Parts Control"
    TitleLabel.Parent = Frame

    -- Label Kecepatan
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Size = UDim2.new(1, 0, 0.2, 0)
    SpeedLabel.Position = UDim2.new(0, 0, 0.2, 0)
    SpeedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.Font = Enum.Font.Code
    SpeedLabel.TextSize = 16
    SpeedLabel.Text = "Kecepatan Loop: " .. string.format("%.2f", currentDelay) .. "s"
    SpeedLabel.Parent = Frame
    
    -- Slider Kecepatan
    local SpeedSlider = Instance.new("ImageLabel")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Size = UDim2.new(0.9, 0, 0.15, 0)
    SpeedSlider.Position = UDim2.new(0.05, 0, 0.45, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.BorderSizePixel = 1
    SpeedSlider.Image = "" -- Tidak perlu gambar
    SpeedSlider.Parent = Frame
    
    local SliderKnob = Instance.new("ImageLabel")
    SliderKnob.Name = "SliderKnob"
    SliderKnob.Size = UDim2.new(0, 20, 1, 0)
    -- Hitung posisi awal knob berdasarkan currentDelay
    local initialX = (MAX_DELAY - currentDelay) / (MAX_DELAY - MIN_DELAY)
    SliderKnob.Position = UDim2.new(initialX, -10, 0, 0) 
    SliderKnob.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    SliderKnob.Image = ""
    SliderKnob.Parent = SpeedSlider
    
    -- Logika Drag Slider
    local isDragging = false
    local function UpdateDelay(input)
        local relativeX = input.Position.X - SpeedSlider.AbsolutePosition.X
        local normalizedX = math.clamp(relativeX / SpeedSlider.AbsoluteSize.X, 0, 1)
        
        -- Kita ingin kecepatan rendah (lambat) saat di kanan (normalizedX=1) dan cepat saat di kiri (normalizedX=0)
        -- Formula: delay = MAX_DELAY - (normalizedX * (MAX_DELAY - MIN_DELAY))
        local newDelay = MAX_DELAY - (normalizedX * (MAX_DELAY - MIN_DELAY))
        
        currentDelay = math.clamp(newDelay, MIN_DELAY, MAX_DELAY)
        
        -- Update posisi knob di UI
        local knobX = (MAX_DELAY - currentDelay) / (MAX_DELAY - MIN_DELAY)
        SliderKnob.Position = UDim2.new(knobX, -10, 0, 0)
        
        -- Update label
        SpeedLabel.Text = "Kecepatan Loop: " .. string.format("%.2f", currentDelay) .. "s"
    end

    SliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            -- Panggil UpdateDelay saat drag dimulai untuk posisi awal
            UpdateDelay(input) 
        end
    end)

    SliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    -- Event untuk menangani pergerakan mouse/jari selama drag
    LocalPlayer:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDelay(input)
        end
    end)

    -- Tombol Toggle On/Off
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0.8, 0, 0.25, 0)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.Code
    ToggleButton.TextSize = 20
    ToggleButton.Text = "OFF (Nonaktif)"
    ToggleButton.Parent = Frame
    
    -- Awalnya merah (OFF)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    -- Fungsi Toggle
    local function ToggleBringParts()
        isBringingParts = not isBringingParts -- Ubah status
        
        if isBringingParts then
            -- Aktifkan
            ToggleButton.Text = "ON (Aktif)"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            print("Bring All Parts: AKTIF")
        else
            -- Non-aktifkan
            ToggleButton.Text = "OFF (Nonaktif)"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            print("Bring All Parts: NON-AKTIF")
        end
    end

    -- Hubungkan fungsi ke event klik
    ToggleButton.MouseButton1Click:Connect(ToggleBringParts)
end

-- =================================================================================
-- 2. LOGIKA UTAMA (Teleportasi)
-- =================================================================================

local function BringPartsLoop()
    while true do
        -- Hanya jalankan jika toggle AKTIF
        if isBringingParts then
            local Character = LocalPlayer.Character
            if Character then
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                
                if HRP then
                    local TargetCFrame = HRP.CFrame * PARTS_MOVE_OFFSET
                    
                    -- Iterasi melalui semua objek di Workspace
                    for _, Object in pairs(Workspace:GetDescendants()) do
                        -- Kami hanya tertarik pada BasePart (Part, MeshPart, dll.)
                        if Object:IsA("BasePart") then
                            -- Abaikan bagian dari karakter pemain lokal sendiri
                            if Object:IsDescendantOf(Character) then continue end
                            
                            -- Abaikan objek yang disembunyikan/diabaikan secara teknis
                            if not Object:IsDescendantOf(Workspace) then continue end

                            -- Teleportasi objek (tanpa terkecuali)
                            pcall(function()
                                Object.CFrame = TargetCFrame
                            end)
                        end
                    end
                end
            end
        end
        -- Menggunakan nilai currentDelay yang diperbarui secara real-time dari slider
        task.wait(currentDelay)
    end
end

-- =================================================================================
-- 3. EKSEKUSI
-- =================================================================================

-- 1. Buat UI di layar
CreateUI()

-- 2. Mulai loop utama dalam thread terpisah
task.spawn(BringPartsLoop)
