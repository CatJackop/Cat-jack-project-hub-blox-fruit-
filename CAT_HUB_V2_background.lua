--//==================================================
--// CAT HUB
--// Created by @catjack.gg
--// Roblox Studio - LocalScript
--//==================================================

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Blox Fruits Place ID Detection
local World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
local World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
local World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089

--// Get Game Name
local gameName = "Unknown Game"
pcall(function()
	gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

--// Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CAT_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

--// Background Image
local Background = Instance.new("ImageLabel")
Background.Name = "Background"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.Position = UDim2.new(0, 0, 0, 0)
Background.BackgroundTransparency = 1
Background.Image = "rbxassetid://115846406610270"
Background.ScaleType = Enum.ScaleType.Crop
Background.ZIndex = 0
Background.Parent = ScreenGui


--// Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 360, 0, 300)
Main.Position = UDim2.new(0.5, -180, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(30, 18, 42)
Main.BackgroundTransparency = 0.06
Main.BorderSizePixel = 0
Main.ZIndex = 1
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = Main

--// Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 72)
TopBar.BackgroundColor3 = Color3.fromRGB(105, 55, 155)
TopBar.BackgroundTransparency = 0.08
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 20)
TopCorner.Parent = TopBar

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "CAT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 25
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

--// Creator
local Creator = Instance.new("TextLabel")
Creator.Size = UDim2.new(1, -30, 0, 20)
Creator.Position = UDim2.new(0, 15, 0, 43)
Creator.BackgroundTransparency = 1
Creator.Text = "Created by @catjack.gg"
Creator.TextColor3 = Color3.fromRGB(225, 205, 240)
Creator.TextSize = 12
Creator.Font = Enum.Font.Gotham
Creator.TextXAlignment = Enum.TextXAlignment.Left
Creator.Parent = TopBar

--// Profile Avatar
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 75, 0, 75)
Avatar.Position = UDim2.new(0, 20, 0, 88)
Avatar.BackgroundTransparency = 1
Avatar.Parent = Main

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = Avatar

pcall(function()
	Avatar.Image = Players:GetUserThumbnailAsync(
		player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size150x150
	)
end)

--// Username
local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(1, -115, 0, 30)
Username.Position = UDim2.new(0, 110, 0, 90)
Username.BackgroundTransparency = 1
Username.Text = "@" .. player.Name
Username.TextColor3 = Color3.fromRGB(255, 255, 255)
Username.TextSize = 19
Username.Font = Enum.Font.GothamBold
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.Parent = Main

--// Display Name
local DisplayName = Instance.new("TextLabel")
DisplayName.Size = UDim2.new(1, -115, 0, 25)
DisplayName.Position = UDim2.new(0, 110, 0, 120)
DisplayName.BackgroundTransparency = 1
DisplayName.Text = player.DisplayName
DisplayName.TextColor3 = Color3.fromRGB(180, 170, 190)
DisplayName.TextSize = 14
DisplayName.Font = Enum.Font.Gotham
DisplayName.TextXAlignment = Enum.TextXAlignment.Left
DisplayName.Parent = Main

--// Current Game
local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(1, -40, 0, 30)
GameLabel.Position = UDim2.new(0, 20, 0, 170)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Playing: " .. gameName
GameLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
GameLabel.TextSize = 16
GameLabel.Font = Enum.Font.GothamMedium
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.TextTruncate = Enum.TextTruncate.AtEnd
GameLabel.Parent = Main

--// World
local WorldName = "Unsupported"
if World1 then
	WorldName = "World 1"
elseif World2 then
	WorldName = "World 2"
elseif World3 then
	WorldName = "World 3"
end

local WorldLabel = Instance.new("TextLabel")
WorldLabel.Size = UDim2.new(1, -40, 0, 30)
WorldLabel.Position = UDim2.new(0, 20, 0, 198)
WorldLabel.BackgroundTransparency = 1
WorldLabel.Text = "Blox Fruits: " .. WorldName
WorldLabel.TextColor3 = Color3.fromRGB(205, 180, 225)
WorldLabel.TextSize = 15
WorldLabel.Font = Enum.Font.GothamMedium
WorldLabel.TextXAlignment = Enum.TextXAlignment.Left
WorldLabel.Parent = Main

--// Execute Button
local Execute = Instance.new("TextButton")
Execute.Name = "Execute"
Execute.Size = UDim2.new(1, -40, 0, 48)
Execute.Position = UDim2.new(0, 20, 1, -62)
Execute.BackgroundColor3 = Color3.fromRGB(125, 65, 185)
Execute.BackgroundTransparency = 0.03
Execute.BorderSizePixel = 0
Execute.Text = "EXECUTE"
Execute.TextColor3 = Color3.fromRGB(255, 255, 255)
Execute.TextSize = 17
Execute.Font = Enum.Font.GothamBold
Execute.Parent = Main

local ExecuteCorner = Instance.new("UICorner")
ExecuteCorner.CornerRadius = UDim.new(0, 14)
ExecuteCorner.Parent = Execute

--// Execute by Place ID
Execute.MouseButton1Click:Connect(function()
	-- Hide the entire CAT HUB GUI after clicking Execute
	ScreenGui.Enabled = false
	if World1 then
		-- Add your own World 1 code here.
		print("CAT HUB: World 1 selected")
	elseif World2 then
		-- Add your own World 2 code here.
		print("CAT HUB: World 2 selected")
	elseif World3 then
		-- Add your own World 3 code here.
		print("CAT HUB: World 3 selected")
	else
		warn("CAT HUB: Unsupported Place ID")
	end
end)

--// Draggable GUI
local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)
