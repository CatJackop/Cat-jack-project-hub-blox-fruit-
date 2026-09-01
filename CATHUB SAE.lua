-- ══════════════════════════════════════════════════════════════════════════════
-- CAT HUB-style Copy Discord Invite
-- Standalone UI — same look as the Oxide library, no external dependencies.
-- ══════════════════════════════════════════════════════════════════════════════

local DISCORD_INVITE = https://discord.gg/EYQ7XEMUpj" -- CHANGE THIS to your actual invite

-- Re-execution guard
do
    local prev = _G.CatHubDiscordInvite
    if prev and type(prev.Unload) == "function" then
        pcall(prev.Unload)
    end
end

local HUB = { conns = {}, dead = false }
_G.CatHubDiscordInvite = HUB

local function track(conn)
    table.insert(HUB.conns, conn)
    return conn
end

-- ══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService       = game:GetService("GuiService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NOTIFY_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local DEFAULT_LOGO = "rbxassetid://126031329785796"
local CLIPBOARD_ICON = "rbxassetid://10709751190"

-- Oxide dark theme palette (matches Libary.lua)
local C = {
    WindowBg     = Color3.fromRGB(20, 20, 20),
    CardBg       = Color3.fromRGB(24, 24, 24),
    Border       = Color3.fromRGB(35, 35, 35),
    Element      = Color3.fromRGB(31, 31, 31),
    ElementHover = Color3.fromRGB(38, 38, 38),
    Badge        = Color3.fromRGB(42, 42, 42),
    NavHover     = Color3.fromRGB(26, 26, 26),
    PillActive   = Color3.fromRGB(36, 36, 36),
    White        = Color3.fromRGB(255, 255, 255),
    TextGray     = Color3.fromRGB(154, 154, 154),
    TextDim      = Color3.fromRGB(139, 139, 139),
    HotbarBg     = Color3.fromRGB(24, 24, 24),
    HotbarBorder = Color3.fromRGB(35, 35, 35),
    HotbarActive = Color3.fromRGB(31, 31, 31),
    HotbarHover  = Color3.fromRGB(38, 38, 38),
    Accent       = Color3.fromRGB(167, 200, 244),
    AccentDim    = Color3.fromRGB(26, 46, 74),
    AccentText   = Color3.fromRGB(10, 16, 26),
}

local NOTIFICATION_STYLES = {
    info    = { Name = "Info",    Color = Color3.fromRGB(118, 151, 194) },
    success = { Name = "Success", Color = Color3.fromRGB(105, 166, 124) },
    warning = { Name = "Warning", Color = Color3.fromRGB(190, 154, 84)  },
    error   = { Name = "Error",   Color = Color3.fromRGB(190, 99, 99)   },
}

-- ══════════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════════════════════════
local function tween(inst, props)
    TweenService:Create(inst, TWEEN, props):Play()
end

local function make(className, props)
    local inst = Instance.new(className)
    if inst:IsA("GuiObject") then
        inst.BorderSizePixel = 0
        inst.BackgroundColor3 = C.WindowBg
    end
    if inst:IsA("GuiButton") then
        inst.AutoButtonColor = false
    end
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        inst.Font = Enum.Font.Gotham
        inst.TextColor3 = C.White
        inst.TextSize = 13
    end
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    inst.Parent = props.Parent
    return inst
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function circle(parent)
    return make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = parent })
end

local function stroke(parent, color)
    return make("UIStroke", {
        Color = color or C.Border,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function pad(parent, top, bottom, left, right)
    return make("UIPadding", {
        PaddingTop = UDim.new(0, top),
        PaddingBottom = UDim.new(0, bottom),
        PaddingLeft = UDim.new(0, left),
        PaddingRight = UDim.new(0, right),
        Parent = parent,
    })
end

local function autoOrder(inst)
    inst.LayoutOrder = #inst.Parent:GetChildren()
end

local function isInside(gui, pos)
    local p, s = gui.AbsolutePosition, gui.AbsoluteSize
    return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

local function guiVisible(gui)
    local node = gui
    while node and node:IsA("GuiObject") do
        if not node.Visible then
            return false
        end
        node = node.Parent
    end
    return true
end

local function makeDraggable(frame, blockers)
    local dragging, dragStart, startPos = false, nil, nil
    track(frame.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        for _, gui in ipairs(blockers) do
            if guiVisible(gui) and isInside(gui, pos) then
                return
            end
        end
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local function copyToClipboard(text)
    local clip = setclipboard or toclipboard or writeclipboard
    if not clip then
        return false
    end
    return pcall(clip, text)
end

local function getParent()
    local target
    pcall(function()
        target = (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if not target then
        target = LocalPlayer:WaitForChild("PlayerGui")
    end
    return target
end

-- ══════════════════════════════════════════════════════════════════════════════
-- BUILD UI
-- ══════════════════════════════════════════════════════════════════════════════
local WINDOW_W, WINDOW_H = 520, 360
local HOTBAR_H, HOTBAR_GAP = 36, 8
local LOGO = DEFAULT_LOGO

local screenGui = make("ScreenGui", {
    Name = "CatHubDiscord",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 10,
    Parent = getParent(),
})

local container = make("Frame", {
    Name = "CATHUBContainer",
    Size = UDim2.fromOffset(WINDOW_W, WINDOW_H + HOTBAR_GAP + HOTBAR_H),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    ZIndex = 2,
    Parent = screenGui,
})

local noDrag = {}

-- ── Loading screen ───────────────────────────────────────────────────────────
local loadingLayer = make("CanvasGroup", {
    Name = "StartupLoader",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    GroupTransparency = 0,
    ZIndex = 500,
    Parent = screenGui,
})

local loadingContent = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(320, 120),
    BackgroundTransparency = 1,
    ZIndex = 508,
    Parent = loadingLayer,
})

local loadingLogo = make("ImageLabel", {
    Image = LOGO,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.fromOffset(48, 48),
    ScaleType = Enum.ScaleType.Fit,
    ImageTransparency = 1,
    ZIndex = 509,
    Parent = loadingContent,
})

local loadingTitle = make("TextLabel", {
    Text = "CAT HUB : STEAL AN EGG",
    Font = Enum.Font.GothamBlack,
    TextSize = 28,
    TextColor3 = C.White,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 58),
    Size = UDim2.fromOffset(200, 32),
    TextTransparency = 1,
    ZIndex = 509,
    Parent = loadingContent,
})

local loadingSub = make("TextLabel", {
    Text = "HUB",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = C.Accent,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 92),
    Size = UDim2.fromOffset(200, 16),
    TextTransparency = 1,
    ZIndex = 509,
    Parent = loadingContent,
})

-- ── Main window ──────────────────────────────────────────────────────────────
local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
    BackgroundColor3 = C.WindowBg,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 2,
    Parent = container,
})
corner(main, 12)
stroke(main, C.Border)

local mainGlowStroke = make("UIStroke", {
    Color = C.Accent,
    Thickness = 1.6,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Transparency = 0,
    Parent = main,
})
local mainGlowGradient = make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, C.Accent),
        ColorSequenceKeypoint.new(0.42, C.Accent),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.58, C.Accent),
        ColorSequenceKeypoint.new(1.00, C.Accent),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1.0),
        NumberSequenceKeypoint.new(0.36, 1.0),
        NumberSequenceKeypoint.new(0.50, 0.0),
        NumberSequenceKeypoint.new(0.64, 1.0),
        NumberSequenceKeypoint.new(1.00, 1.0),
    }),
    Parent = mainGlowStroke,
})

local glowT = 0
track(RunService.RenderStepped:Connect(function(dt)
    if not main.Parent then return end
    glowT = (glowT + dt * 0.35) % 1
    mainGlowGradient.Offset = Vector2.new(glowT * 2 - 1, 0)
end))

-- Corner controls
local controls = make("Frame", {
    Name = "CornerControls",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -6, 0, 8),
    Size = UDim2.fromOffset(36, 16),
    BackgroundTransparency = 1,
    ZIndex = 10,
    Parent = main,
})

local closeBtn = make("TextButton", {
    Text = "",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(14, 14),
    BackgroundColor3 = Color3.fromRGB(190, 60, 60),
    ZIndex = 12,
    Parent = controls,
})
circle(closeBtn)
table.insert(noDrag, closeBtn)

local minimizeBtn = make("TextButton", {
    Text = "",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.fromOffset(14, 14),
    BackgroundColor3 = Color3.fromRGB(255, 195, 0),
    ZIndex = 12,
    Parent = controls,
})
circle(minimizeBtn)
table.insert(noDrag, minimizeBtn)

local minimized = false
local hotbar

local function setMinimized(state)
    minimized = state == true
    main.Visible = not minimized
    if hotbar then hotbar.Visible = not minimized end
end

closeBtn.MouseButton1Click:Connect(function()
    HUB.Unload()
end)
minimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(true)
end)

-- Sidebar
local sidebar = make("Frame", {
    Size = UDim2.new(0, 190, 1, 0),
    BackgroundTransparency = 1,
    Parent = main,
})

local brand = make("Frame", {
    Name = "Brand",
    Position = UDim2.fromOffset(12, 12),
    Size = UDim2.new(1, -24, 0, 54),
    BackgroundColor3 = C.CardBg,
    Parent = sidebar,
})
corner(brand, 10)
stroke(brand, C.Border)

make("ImageLabel", {
    Image = LOGO,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(9, 9),
    Size = UDim2.fromOffset(36, 36),
    ScaleType = Enum.ScaleType.Fit,
    Parent = brand,
})

make("TextLabel", {
    Text = "CAT HUB : STEAL AN EGG",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = C.White,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(54, 9),
    Size = UDim2.new(1, -62, 0, 17),
    Parent = brand,
})

make("TextLabel", {
    Text = "CAT HUB : STEAL AN EGG",
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextColor3 = C.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(54, 28),
    Size = UDim2.new(1, -62, 0, 13),
    Parent = brand,
})

local pcard = make("Frame", {
    Name = "PlayerCard",
    Position = UDim2.fromOffset(12, 78),
    Size = UDim2.new(1, -24, 0, 52),
    BackgroundColor3 = C.CardBg,
    Parent = sidebar,
})
corner(pcard, 10)
stroke(pcard, C.Border)

local avH = make("Frame", {
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = C.Element,
    Parent = pcard,
})
corner(avH, 8)

local avImg = make("ImageLabel", {
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ScaleType = Enum.ScaleType.Crop,
    Parent = avH,
})
corner(avImg, 8)
local avRing = stroke(avH, C.Accent)
avRing.Transparency = 0.4

make("TextLabel", {
    Text = LocalPlayer.DisplayName,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.White,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(52, 10),
    Size = UDim2.new(1, -60, 0, 15),
    Parent = pcard,
})

make("TextLabel", {
    Text = "@" .. LocalPlayer.Name,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = C.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(52, 28),
    Size = UDim2.new(1, -60, 0, 13),
    Parent = pcard,
})

make("ImageLabel", {
    Name = "Watermark",
    Image = LOGO,
    BackgroundTransparency = 1,
    ImageTransparency = 0.92,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 24),
    Size = UDim2.fromOffset(118, 118),
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 0,
    Parent = sidebar,
})

local statusDot = make("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 16, 1, -19),
    Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = NOTIFICATION_STYLES.success.Color,
    Parent = sidebar,
})
circle(statusDot)

make("TextLabel", {
    Text = "CAT HUB is ready",
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = C.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 28, 1, -27),
    Size = UDim2.new(1, -40, 0, 16),
    Parent = sidebar,
})

local divLine = make("Frame", {
    Position = UDim2.fromOffset(190, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = C.Accent,
    Parent = main,
})
make("UIGradient", {
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = divLine,
})

-- Content area
local content = make("Frame", {
    Position = UDim2.fromOffset(191, 0),
    Size = UDim2.new(1, -191, 1, 0),
    BackgroundTransparency = 1,
    Parent = main,
})

local page = make("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Parent = content,
})

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 88),
    BackgroundTransparency = 1,
    Parent = page,
})

make("ImageLabel", {
    Image = CLIPBOARD_ICON,
    ImageColor3 = C.White,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.fromOffset(32, 32),
    ScaleType = Enum.ScaleType.Fit,
    Parent = header,
})

make("TextLabel", {
    Text = "Social",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = C.White,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(54, 17),
    Size = UDim2.new(1, -70, 0, 14),
    Parent = header,
})

make("TextLabel", {
    Text = "Community links",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(54, 33),
    Size = UDim2.new(1, -70, 0, 12),
    Parent = header,
})

local pill = make("TextButton", {
    Text = "Discord",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = C.White,
    BackgroundColor3 = C.PillActive,
    Position = UDim2.fromOffset(16, 54),
    Size = UDim2.new(0, 0, 0, 24),
    AutomaticSize = Enum.AutomaticSize.X,
    Parent = header,
})
corner(pill, 6)
pad(pill, 0, 0, 12, 12)
table.insert(noDrag, pill)

make("Frame", {
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = C.Border,
    Parent = header,
})

local pagesHolder = make("Frame", {
    Position = UDim2.fromOffset(0, 88),
    Size = UDim2.new(1, 0, 1, -88),
    BackgroundTransparency = 1,
    Parent = page,
})

local scroll = make("ScrollingFrame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Border,
    Parent = pagesHolder,
})
pad(scroll, 12, 16, 16, 16)
table.insert(noDrag, scroll)

local card = make("Frame", {
    Size = UDim2.new(1, -32, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = C.CardBg,
    Parent = scroll,
})
corner(card, 10)
stroke(card)
pad(card, 14, 14, 16, 16)

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
    Parent = card,
})

-- Section header
local sectionRow = make("Frame", {
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Parent = card,
})
autoOrder(sectionRow)

local sectionTick = make("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, -4),
    Size = UDim2.fromOffset(3, 11),
    BackgroundColor3 = C.Accent,
    Parent = sectionRow,
})
corner(sectionTick, 2)

make("TextLabel", {
    Text = "COMMUNITY",
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextColor3 = C.TextGray,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(9, 0),
    Size = UDim2.new(1, -9, 1, -3),
    Parent = sectionRow,
})

make("Frame", {
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = C.Border,
    Parent = sectionRow,
})

-- Paragraph
local paraCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Parent = card,
})
autoOrder(paraCard)

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
    Parent = paraCard,
})

make("TextLabel", {
    Text = "Join our Discord",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = C.White,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 16),
    LayoutOrder = 1,
    Parent = paraCard,
})

make("TextLabel", {
    Text = "Click the button below to copy the invite link to your clipboard, then paste it in your browser.",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = C.TextDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    LayoutOrder = 2,
    Parent = paraCard,
})

-- Invite label
local inviteLbl = make("TextLabel", {
    Text = "Invite: " .. DISCORD_INVITE,
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = C.White,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 16),
    Parent = card,
})
autoOrder(inviteLbl)

-- Notifications
local notificationHolder = make("Frame", {
    Name = "Notifications",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 12),
    Size = UDim2.fromOffset(260, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    ZIndex = 200,
    Parent = screenGui,
})

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
    Parent = notificationHolder,
})

local notificationOrder = 0

local function Notify(opts)
    if type(opts) == "string" then
        opts = { Content = opts }
    end
    opts = opts or {}

    local styleKey = string.lower(tostring(opts.Type or "info"))
    local style = NOTIFICATION_STYLES[styleKey] or NOTIFICATION_STYLES.info
    local dur = math.max(tonumber(opts.Duration) or 2.5, 0)

    notificationOrder = notificationOrder + 1
    local title = tostring(opts.Title or style.Name)
    local body = tostring(opts.Content or opts.Message or "Notification")

    local slot = make("Frame", {
        Name = "NotificationSlot",
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
        LayoutOrder = notificationOrder,
        ZIndex = 200,
        Parent = notificationHolder,
    })

    local nCard = make("CanvasGroup", {
        Name = style.Name .. "Notification",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 12, 0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.CardBg,
        GroupTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 201,
        Parent = slot,
    })
    corner(nCard, 6)
    stroke(nCard, C.Border)

    make("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = C.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 9),
        Size = UDim2.new(1, -42, 0, 16),
        ZIndex = 202,
        Parent = nCard,
    })

    make("TextLabel", {
        Text = body,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = C.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 29),
        Size = UDim2.new(1, -24, 0, 24),
        ZIndex = 202,
        Parent = nCard,
    })

    local xb = make("TextButton", {
        Text = "×",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = C.TextDim,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -7, 0, 5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        ZIndex = 204,
        Parent = nCard,
    })

    local closed = false
    local function closeNotif()
        if closed then return end
        closed = true
        TweenService:Create(nCard, NOTIFY_TWEEN, {
            Position = UDim2.new(1, 12, 0, 0),
            GroupTransparency = 1,
        }):Play()
        task.delay(0.2, function()
            if slot and slot.Parent then
                slot:Destroy()
            end
        end)
    end

    xb.MouseEnter:Connect(function() tween(xb, { TextColor3 = C.White }) end)
    xb.MouseLeave:Connect(function() tween(xb, { TextColor3 = C.TextDim }) end)
    xb.MouseButton1Click:Connect(closeNotif)

    TweenService:Create(nCard, NOTIFY_TWEEN, {
        Position = UDim2.new(1, 0, 0, 0),
        GroupTransparency = 0,
    }):Play()

    if dur > 0 then
        task.delay(dur, closeNotif)
    end
end

-- Copy button (primary Oxide style)
local copyBtn = make("TextButton", {
    Text = "Copy Discord Invite",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.AccentText,
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = C.Accent,
    Parent = card,
})
autoOrder(copyBtn)
corner(copyBtn, 6)
table.insert(noDrag, copyBtn)

copyBtn.MouseEnter:Connect(function()
    tween(copyBtn, { BackgroundTransparency = 0.14 })
end)
copyBtn.MouseLeave:Connect(function()
    tween(copyBtn, { BackgroundTransparency = 0 })
end)
copyBtn.MouseButton1Click:Connect(function()
    local ok = copyToClipboard(DISCORD_INVITE)
    if ok then
        Notify({
            Title = "Discord",
            Content = "Invite link copied to clipboard!",
            Type = "Success",
        })
    else
        Notify({
            Title = "Discord",
            Content = "Clipboard is not available in this executor.",
            Type = "Error",
            Duration = 4,
        })
    end
end)

-- Hotbar
hotbar = make("Frame", {
    Name = "TabHotbar",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, WINDOW_H + HOTBAR_GAP),
    Size = UDim2.fromOffset(0, HOTBAR_H),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = C.HotbarBg,
    Visible = false,
    ZIndex = 3,
    Parent = container,
})
corner(hotbar, 11)
make("UIStroke", {
    Color = C.HotbarBorder,
    Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = hotbar,
})
pad(hotbar, 5, 5, 10, 10)
table.insert(noDrag, hotbar)

local hotbarInner = make("Frame", {
    Name = "HotbarInner",
    Size = UDim2.new(0, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    ZIndex = 4,
    Parent = hotbar,
})

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
    Parent = hotbarInner,
})

local hBtn = make("TextButton", {
    Text = "",
    AutomaticSize = Enum.AutomaticSize.X,
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = C.HotbarActive,
    ZIndex = 5,
    Parent = hotbarInner,
})
corner(hBtn, 7)
pad(hBtn, 0, 0, 12, 12)
table.insert(noDrag, hBtn)

local hRow = make("Frame", {
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.X,
    Size = UDim2.new(0, 0, 1, 0),
    ZIndex = 5,
    Parent = hBtn,
})

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    Parent = hRow,
})

make("ImageLabel", {
    Image = CLIPBOARD_ICON,
    ImageColor3 = C.White,
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(20, 20),
    LayoutOrder = 1,
    ZIndex = 6,
    Parent = hRow,
})

make("TextLabel", {
    Text = "Social",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = C.White,
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.X,
    Size = UDim2.new(0, 0, 1, 0),
    LayoutOrder = 2,
    ZIndex = 6,
    Parent = hRow,
})

local hDot = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 1, 4),
    Size = UDim2.fromOffset(4, 4),
    BackgroundColor3 = C.Accent,
    BackgroundTransparency = 0,
    ZIndex = 6,
    Parent = hBtn,
})
circle(hDot)

makeDraggable(container, noDrag)

-- ── Loading reveal ───────────────────────────────────────────────────────────
task.spawn(function()
    TweenService:Create(loadingLayer, TweenInfo.new(0.34, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.35,
    }):Play()
    TweenService:Create(loadingLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        ImageTransparency = 0,
    }):Play()
    task.wait(0.2)
    TweenService:Create(loadingTitle, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        TextTransparency = 0,
    }):Play()
    task.wait(0.15)
    TweenService:Create(loadingSub, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        TextTransparency = 0,
    }):Play()
    task.wait(1.4)

    TweenService:Create(loadingLayer, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
        GroupTransparency = 1,
    }):Play()
    task.wait(0.35)

    main.Visible = true
    hotbar.Visible = true
    if loadingLayer and loadingLayer.Parent then
        loadingLayer:Destroy()
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════
-- CLEANUP
-- ══════════════════════════════════════════════════════════════════════════════
function HUB.Unload()
    if HUB.dead then return end
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(HUB.conns)
    pcall(function()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end)
    _G.CatHubDiscordInvite = nil
end
