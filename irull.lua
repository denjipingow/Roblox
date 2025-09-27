-- =============================================================
-- ==                  REVISED & IMPROVED SCRIPT              ==
-- ==             Bring Parts V2 By u0sky0u                   ==
-- ==              (Refactored for proper functionality)      ==
-- =============================================================

-- || Services ||
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- || Variables & State Management ||
local localPlayer = Players.LocalPlayer
local targetPlayer = nil -- Player yang dipilih dari text box
local descendantAddedConnection = nil
local updateAnchorsConnection = nil
local activeAnchors = {} -- Menyimpan semua titik jangkar yang aktif

-- Enum untuk mode operasi
local BringMode = {
	OFF = 0,
	SINGLE = 1,
	EVERYONE = 2
}
local currentMode = BringMode.OFF

-- || GUI Setup (Sama seperti sebelumnya, hanya dirapikan) ||
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BringPartsV2_Gui"
screenGui.Parent = gethui() or game:GetService("CoreGui") -- Fallback ke CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 320, 0, 230)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner", mainFrame)
mainFrameCorner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Name = "Label"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleLabel.Text = "Bring Parts V2 (Improved)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold

local titleLabelCorner = Instance.new("UICorner", titleLabel)
titleLabelCorner.CornerRadius = UDim.new(0, 8)

local playerTextBox = Instance.new("TextBox", mainFrame)
playerTextBox.Name = "Box"
playerTextBox.Size = UDim2.new(0.85, 0, 0, 40)
playerTextBox.Position = UDim2.new(0.075, 0, 0.3, 0)
playerTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
playerTextBox.PlaceholderText = "Player here"
playerTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
playerTextBox.TextSize = 14
playerTextBox.Font = Enum.Font.GothamSemibold

local playerTextBoxCorner = Instance.new("UICorner", playerTextBox)
playerTextBoxCorner.CornerRadius = UDim.new(0, 6)

local bringButton = Instance.new("TextButton", mainFrame)
bringButton.Name = "Button"
bringButton.Size = UDim2.new(0.85, 0, 0, 45)
bringButton.Position = UDim2.new(0.075, 0, 0.5, 0)
bringButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
bringButton.Text = "Bring To Player"
bringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bringButton.TextSize = 16
bringButton.Font = Enum.Font.GothamBold

local bringButtonCorner = Instance.new("UICorner", bringButton)
bringButtonCorner.CornerRadius = UDim.new(0, 6)

local everyoneButton = Instance.new("TextButton", mainFrame)
everyoneButton.Name = "EveryoneButton"
everyoneButton.Size = UDim2.new(0.85, 0, 0, 40)
everyoneButton.Position = UDim2.new(0.075, 0, 0.75, 5)
everyoneButton.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
everyoneButton.Text = "Bring To Everyone"
everyoneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
everyoneButton.TextSize = 16
everyoneButton.Font = Enum.Font.GothamBold

local everyoneButtonCorner = Instance.new("UICorner", everyoneButton)
everyoneButtonCorner.CornerRadius = UDim.new(0, 6)


-- || Core Functions ||

-- Fungsi untuk menghapus semua efek yang ditambahkan skrip
local function cleanupAffectedParts()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		-- Cari berdasarkan nama unik yang kita berikan
		if descendant.Name == "BringPartsV2_AlignPosition" then
			local part = descendant.Parent
			if part then
				local torque = part:FindFirstChild("BringPartsV2_Torque")
				local attachment = part:FindFirstChild("BringPartsV2_Attachment")
				if torque then torque:Destroy() end
				if attachment then attachment:Destroy() end
				descendant:Destroy() -- Hapus AlignPosition terakhir
			end
		end
	end
end

-- Fungsi untuk menghentikan semua efek "bring"
local function stopBringing()
	if currentMode == BringMode.OFF then return end

	-- Hentikan semua koneksi/loop
	if descendantAddedConnection then descendantAddedConnection:Disconnect() descendantAddedConnection = nil end
	if updateAnchorsConnection then updateAnchorsConnection:Disconnect() updateAnchorsConnection = nil end

	-- Hapus semua titik jangkar
	for _, anchorData in pairs(activeAnchors) do
		if anchorData.anchor.Parent and anchorData.anchor.Parent.Parent then
			anchorData.anchor.Parent.Parent:Destroy()
		end
	end
	activeAnchors = {}

	-- Bersihkan semua part yang terpengaruh
	cleanupAffectedParts()
	
	currentMode = BringMode.OFF
	print("Bring Parts V2: Deactivated.")
	
	-- Reset tampilan tombol
	bringButton.Text = "Bring To Player"
	bringButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	everyoneButton.Text = "Bring To Everyone"
	everyoneButton.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
end

-- Fungsi yang memanipulasi part
local function affectPart(part)
	-- Filter part yang tidak valid
	if not (part:IsA("BasePart") and not part.Anchored and not part.Parent:FindFirstChildOfClass("Humanoid")) then
		return
	end
    
    -- Hindari part yang sudah kita proses
    if part:FindFirstChild("BringPartsV2_Attachment") then return end

	-- Cari titik jangkar terdekat
	local closestAnchor = nil
	local minDistance = math.huge
	for _, anchorData in pairs(activeAnchors) do
		-- Pastikan jangkar masih valid
		if anchorData.anchor and anchorData.anchor.Parent then
			local distance = (part.Position - anchorData.anchor.WorldPosition).Magnitude
			if distance < minDistance then
				minDistance = distance
				closestAnchor = anchorData.anchor
			end
		end
	end

	if not closestAnchor then return end
    
	part.CanCollide = false

	-- Tambahkan Torque untuk efek berputar
	local torque = Instance.new("Torque", part)
	torque.Name = "BringPartsV2_Torque"
	torque.Torque = Vector3.new(math.random(-750000, 750000), math.random(-750000, 750000), math.random(-750000, 750000))
	
	-- Tambahkan AlignPosition untuk menarik part
	local partAttachment = Instance.new("Attachment", part)
    partAttachment.Name = "BringPartsV2_Attachment"
    
	local alignPosition = Instance.new("AlignPosition", part)
    alignPosition.Name = "BringPartsV2_AlignPosition"
	alignPosition.Attachment0 = partAttachment
	alignPosition.Attachment1 = closestAnchor
	alignPosition.MaxForce = math.huge
	alignPosition.MaxVelocity = math.huge
	alignPosition.Responsiveness = 200
end

-- Fungsi untuk memulai efek "bring"
local function startBringing(targets) -- `targets` adalah tabel berisi objek Player
	if #targets == 0 then
		print("No valid targets found.")
		return
	end

	-- Hentikan mode sebelumnya jika ada
	stopBringing()
    
    -- Tentukan mode baru berdasarkan jumlah target
    if #targets == 1 and targets[1] == targetPlayer then
        currentMode = BringMode.SINGLE
		bringButton.Text = "Bringing... (Click to Stop)"
		bringButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        currentMode = BringMode.EVERYONE
		everyoneButton.Text = "Bringing... (Click to Stop)"
		everyoneButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
	
	print("Bring Parts V2: Activated.")

	-- Buat titik jangkar untuk setiap target
	for _, player in ipairs(targets) do
		local anchorFolder = Instance.new("Folder", Workspace)
		anchorFolder.Name = "BringPartsV2_Anchor_" .. player.Name
		
		local anchorPart = Instance.new("Part", anchorFolder)
		anchorPart.Anchored = true
		anchorPart.CanCollide = false
		anchorPart.Transparency = 1
		anchorPart.Size = Vector3.one
		
		local anchorAttachment = Instance.new("Attachment", anchorPart)
		
		table.insert(activeAnchors, {player = player, anchor = anchorAttachment})
	end

	-- Loop untuk memperbarui posisi semua titik jangkar
	updateAnchorsConnection = RunService.Heartbeat:Connect(function()
		for i = #activeAnchors, 1, -1 do -- Iterasi mundur agar aman saat menghapus
			local anchorData = activeAnchors[i]
			local char = anchorData.player.Character
			local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
			
			if rootPart and rootPart.Parent then
				anchorData.anchor.WorldCFrame = rootPart.CFrame
			else
				-- Jika pemain tidak valid lagi (keluar/mati), hapus jangkarnya
				anchorData.anchor.Parent.Parent:Destroy()
				table.remove(activeAnchors, i)
			end
		end
        -- Jika tidak ada jangkar tersisa, hentikan efek
        if #activeAnchors == 0 then
            stopBringing()
        end
	end)

	-- Terapkan efek ke semua part yang sudah ada
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		affectPart(descendant)
	end

	-- Terapkan efek ke part baru yang muncul
	descendantAddedConnection = Workspace.DescendantAdded:Connect(affectPart)
end

-- Fungsi untuk mencari pemain
local function findPlayer(searchText)
	local lowerSearchText = string.lower(searchText)
	for _, player in pairs(Players:GetPlayers()) do
		if string.find(string.lower(player.Name), lowerSearchText) or string.find(string.lower(player.DisplayName), lowerSearchText) then
			return player
		end
	end
	return nil
end


-- || Event Connections ||

-- Tombol keyboard untuk menyembunyikan/menampilkan GUI
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessedEvent then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-- Ketika input text box kehilangan fokus
playerTextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local foundPlayer = findPlayer(playerTextBox.Text)
		if foundPlayer then
			targetPlayer = foundPlayer
			playerTextBox.Text = targetPlayer.Name
			print("Player selected:", targetPlayer.Name)
		else
			targetPlayer = nil
			print("Player not found.")
		end
	end
end)

-- Ketika tombol "Bring to Player" diklik
bringButton.MouseButton1Click:Connect(function()
	if currentMode == BringMode.SINGLE then
		stopBringing()
		return
	end
	
	if targetPlayer then
		startBringing({targetPlayer})
	else
		print("Player is not selected. Please type a name in the box.")
	end
end)

-- Ketika tombol "Bring to Everyone" diklik
everyoneButton.MouseButton1Click:Connect(function()
	if currentMode == BringMode.EVERYONE then
		stopBringing()
		return
	end
	
	local allTargets = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			table.insert(allTargets, player)
		end
	end
	
	startBringing(allTargets)
end)
