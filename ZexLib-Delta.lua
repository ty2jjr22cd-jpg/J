-- language: Lua, file: ZexLib-Delta.lua
-- target: Delta Executor (mobile) — Android / iOS
-- Chilli Library API-uyumlu. macOS/cloud estetiği, dokunmatik optimize.

local ZexLib = {}

-- ═══════════════════════════════════════════════════════════
--  TEMA
-- ═══════════════════════════════════════════════════════════

local Theme = {
    Backdrop      = Color3.fromRGB(11, 16, 22),
    Glass         = Color3.fromRGB(20, 30, 42),
    GlassLight    = Color3.fromRGB(28, 42, 56),
    GlassBright   = Color3.fromRGB(38, 56, 72),

    Accent        = Color3.fromRGB(64, 224, 208),
    AccentSoft    = Color3.fromRGB(130, 245, 232),
    AccentDeep    = Color3.fromRGB(28, 168, 160),
    AccentGlow    = Color3.fromRGB(0, 255, 230),

    Text          = Color3.fromRGB(242, 250, 254),
    TextDim       = Color3.fromRGB(160, 180, 195),
    TextMuted     = Color3.fromRGB(100, 122, 138),

    Success       = Color3.fromRGB(96, 232, 168),
    Warning       = Color3.fromRGB(255, 205, 100),
    Danger        = Color3.fromRGB(255, 118, 118),

    RadiusWindow  = 22,
    RadiusPanel   = 16,
    RadiusCard    = 14,
    RadiusButton  = 12,
    RadiusPill    = 999,

    TweenFast     = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    TweenSoft     = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FontFaceBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
pcall(function()
    FontFace = Font.fromEnum(Enum.Font.Gotham)
    FontFaceBold = Font.fromEnum(Enum.Font.GothamBold)
end)

-- ═══════════════════════════════════════════════════════════
--  UTIL
-- ═══════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer

local function GuiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then return hui end
    end
    if type(getgenv) == "function" then
        local genv = getgenv()
        if genv and genv.__DeltaHui then return genv.__DeltaHui end
    end
    return CoreGui
end

local function New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function Corner(r, p) return New("UICorner", { CornerRadius = UDim.new(0, r), Parent = p }) end

local function Stroke(color, thickness, transparency, parent)
    return New("UIStroke", {
        Color = color, Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function Gradient(a, b, rot, parent)
    return New("UIGradient", {
        Color = ColorSequence.new(a, b),
        Rotation = rot or 90,
        Parent = parent,
    })
end

local function Padding(px, parent)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, px), PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px), PaddingRight = UDim.new(0, px),
        Parent = parent,
    })
end

local function Tween(inst, info, goal)
    local t = TweenService:Create(inst, info, goal)
    t:Play()
    return t
end

-- soft haptic click
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6042053626"
clickSound.Volume = 0.12
clickSound.Parent = SoundService

local function Tap()
    pcall(function()
        local c = clickSound:Clone()
        c.Parent = SoundService
        c:Play()
        game:GetService("Debris"):AddItem(c, 1)
    end)
    pcall(function()
        if type(haptic) == "function" then haptic(Enum.HapticStyle.Light) end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  STATE
-- ═══════════════════════════════════════════════════════════

local State = {
    Gui = nil,
    Shell = nil,
    Tabs = {},
    ActiveTab = nil,
    SideScroll = nil,
    Content = nil,
    SearchBox = nil,
    MiniMode = false,
    UIScale = 1,
}

-- ═══════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════

local function BuildWindow(cfg)
    cfg = cfg or {}
    local gui = New("ScreenGui", {
        Name = "ZexHub_Delta_" .. tostring(math.random(1e6, 9e6)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 100,
        Parent = GuiParent(),
    })

    -- Responsive size: mobil ekrana göre ölçekle
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
    local targetW = math.clamp(vp.X * 0.94, 320, 720)
    local targetH = math.clamp(vp.Y * 0.72, 380, 560)

    -- UIScale ile tüm arayüz ölçeği
    local uiScale = New("UIScale", { Scale = 1, Parent = gui })

    local shell = New("Frame", {
        Name = "Shell",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(targetW, targetH),
        BackgroundColor3 = Theme.Glass,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = gui,
    })
    Corner(Theme.RadiusWindow, shell)

    local glow = Stroke(Theme.Accent, 1.4, 0.5, shell)
    Gradient(Theme.AccentSoft, Theme.AccentDeep, 45, glow)
    Stroke(Color3.new(1, 1, 1), 1, 0.88, shell)
    Gradient(Color3.fromRGB(26, 40, 54), Color3.fromRGB(14, 22, 32), 120, shell)

    -- ── macOS traffic lights (mobil için biraz büyük) ──
    local traffic = New("Frame", {
        Position = UDim2.fromOffset(18, 16),
        Size = UDim2.fromOffset(66, 14),
        BackgroundTransparency = 1,
        Parent = shell,
    })

    local function dot(color, x, name)
        local b = New("TextButton", {
            Name = name,
            Position = UDim2.fromOffset(x, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
            Parent = traffic,
        })
        Corner(Theme.RadiusPill, b)
        return b
    end

    local closeBtn = dot(Color3.fromRGB(255, 95, 87), 0, "Close")
    local minBtn = dot(Color3.fromRGB(255, 189, 46), 22, "Min")
    local maxBtn = dot(Color3.fromRGB(39, 201, 63), 44, "Max")

    -- Başlık
    local title = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(96, 12),
        Size = UDim2.new(1, -180, 0, 20),
        FontFace = FontFaceBold,
        Text = cfg.Name or "ZexHub",
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = shell,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(96, 30),
        Size = UDim2.new(1, -180, 0, 14),
        FontFace = FontFace,
        Text = "cloud · delta",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = shell,
    })

    -- ── Mobil için arama pill'i tam satıra indir ──
    local searchPill = New("Frame", {
        Position = UDim2.fromOffset(14, 52),
        Size = UDim2.new(1, -28, 0, 32),
        BackgroundColor3 = Theme.GlassBright,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Parent = shell,
    })
    Corner(Theme.RadiusPill, searchPill)
    Stroke(Color3.new(1, 1, 1), 1, 0.9, searchPill)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.fromOffset(18, 32),
        FontFace = FontFace,
        Text = "⌕",
        TextColor3 = Theme.TextDim,
        TextSize = 16,
        Parent = searchPill,
    })

    local searchBox = New("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(38, 0),
        Size = UDim2.new(1, -50, 1, 0),
        FontFace = FontFace,
        Text = "",
        PlaceholderText = "Ara…",
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = searchPill,
    })

    -- ── Yatay tab şeridi (mobil dostu) ──
    local tabBar = New("Frame", {
        Name = "TabBar",
        Position = UDim2.fromOffset(14, 94),
        Size = UDim2.new(1, -28, 0, 40),
        BackgroundColor3 = Theme.GlassLight,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = shell,
    })
    Corner(Theme.RadiusPanel, tabBar)
    Stroke(Color3.new(1, 1, 1), 1, 0.92, tabBar)

    local tabScroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.new(1, -8, 1, -8),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
        Parent = tabBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = tabScroll,
    })

    -- ── İçerik ──
    local content = New("Frame", {
        Position = UDim2.fromOffset(14, 142),
        Size = UDim2.new(1, -28, 1, -156),
        BackgroundColor3 = Theme.GlassLight,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = shell,
    })
    Corner(Theme.RadiusPanel, content)
    Stroke(Color3.new(1, 1, 1), 1, 0.92, content)

    local contentScroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
        Parent = content,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = contentScroll,
    })

    -- ── Sürükleme (dokunmatik için tüm üst bant) ──
    local dragging, dragStart, startPos = false, nil, nil
    local handle = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -180, 0, 48),
        Text = "",
        ZIndex = 5,
        Parent = shell,
    })

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = shell.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            shell.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Pencere kontrolleri ──
    closeBtn.MouseButton1Click:Connect(function()
        Tap()
        Tween(shell, Theme.TweenSoft, { Size = UDim2.fromOffset(shell.AbsoluteSize.X, 0), BackgroundTransparency = 1 })
        task.wait(0.28)
        gui:Destroy()
    end)
    minBtn.MouseButton1Click:Connect(function()
        Tap()
        State.MiniMode = not State.MiniMode
        if State.MiniMode then
            content.Visible = false
            tabBar.Visible = false
            searchPill.Visible = false
            Tween(shell, Theme.TweenSoft, { Size = UDim2.fromOffset(shell.AbsoluteSize.X, 52) })
        else
            content.Visible = true
            tabBar.Visible = true
            searchPill.Visible = true
            Tween(shell, Theme.TweenSoft, { Size = UDim2.fromOffset(targetW, targetH) })
        end
    end)
    maxBtn.MouseButton1Click:Connect(function()
        Tap()
        local full = shell.AbsoluteSize.X >= vp.X * 0.85
        if full then
            Tween(shell, Theme.TweenSoft, { Size = UDim2.fromOffset(targetW, targetH) })
        else
            Tween(shell, Theme.TweenSoft, {
                Size = UDim2.fromOffset(vp.X * 0.96, vp.Y * 0.82),
            })
        end
    end)

    State.Gui = gui
    State.Shell = shell
    State.TabScroll = tabScroll
    State.Content = contentScroll
    State.SearchBox = searchBox
    State.Scale = uiScale

    return {
        Gui = gui,
        Shell = shell,
        TabScroll = tabScroll,
        Content = contentScroll,
        SearchBox = searchBox,
    }
end

-- ═══════════════════════════════════════════════════════════
--  TAB — yatay pill
-- ═══════════════════════════════════════════════════════════

local function BuildTab(win, cfg)
    local name = type(cfg) == "table" and cfg.Name or cfg

    local btn = New("TextButton", {
        Name = name,
        Size = UDim2.fromOffset(0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.GlassBright,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #State.Tabs + 1,
        Parent = win.TabScroll,
    })
    Corner(Theme.RadiusPill, btn)
    Stroke(Color3.new(1, 1, 1), 1, 0.9, btn)

    local lbl = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -32, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        FontFace = FontFace,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = btn,
    })

    local page = New("Frame", {
        Name = "Page_" .. name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        LayoutOrder = 1,
        Parent = win.Content,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    local tab = {
        Name = name, Button = btn, Label = lbl, Page = page,
        Sections = {}, Active = false,
    }

    local function setActive(state)
        tab.Active = state
        if state then
            Tween(btn, Theme.TweenSoft, { BackgroundTransparency = 0.15 })
            Tween(lbl, Theme.TweenSoft, { TextColor3 = Theme.Backdrop, FontFace = FontFaceBold })
        else
            Tween(btn, Theme.TweenSoft, { BackgroundTransparency = 1 })
            Tween(lbl, Theme.TweenSoft, { TextColor3 = Theme.TextDim, FontFace = FontFace })
        end
    end

    btn.MouseButton1Click:Connect(function()
        Tap()
        if State.ActiveTab then State.ActiveTab:SetActive(false) end
        State.ActiveTab = tab
        setActive(true)
        for _, t in ipairs(State.Tabs) do t.Page.Visible = (t == tab) end
    end)

    tab.SetActive = setActive
    table.insert(State.Tabs, tab)

    if #State.Tabs == 1 then
        State.ActiveTab = tab
        setActive(true)
        page.Visible = true
    end

    return tab
end

-- ═══════════════════════════════════════════════════════════
--  SECTION
-- ═══════════════════════════════════════════════════════════

local function BuildSection(tab, cfg)
    cfg = cfg or {}
    local expanded = cfg.Expanded ~= false

    local card = New("Frame", {
        BackgroundColor3 = Theme.GlassBright,
        BackgroundTransparency = 0.72,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = #tab.Sections + 1,
        Parent = tab.Page,
    })
    Corner(Theme.RadiusCard, card)
    Stroke(Color3.new(1, 1, 1), 1, 0.9, card)

    local head = New("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Text = "", AutoButtonColor = false,
        Parent = card,
    })

    local arrow = New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromOffset(16, 21),
        Size = UDim2.fromOffset(12, 12),
        FontFace = FontFaceBold,
        Text = "▾",
        TextColor3 = Theme.Accent,
        TextSize = 13,
        Rotation = expanded and 0 or -90,
        Parent = head,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(36, 0),
        Size = UDim2.new(1, -46, 1, 0),
        FontFace = FontFaceBold,
        Text = cfg.Name or "Section",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = head,
    })

    New("Frame", {
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 42),
        Size = UDim2.new(1, -28, 0, 1),
        Parent = card,
    })

    local body = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = expanded,
        Parent = card,
    })
    Padding(8, body)
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })

    head.MouseButton1Click:Connect(function()
        Tap()
        expanded = not expanded
        body.Visible = expanded
        Tween(arrow, Theme.TweenSoft, { Rotation = expanded and 0 or -90 })
    end)

    local sec = { Name = cfg.Name, Frame = card, Body = body, Expanded = expanded }
    table.insert(tab.Sections, sec)
    return sec
end

-- ═══════════════════════════════════════════════════════════
--  COMPONENTS — dokunmatik boyutlar
-- ═══════════════════════════════════════════════════════════

local function ToggleRow(parent, cfg)
    local on = cfg.Default == true

    local row = New("Frame", {
        BackgroundColor3 = Theme.GlassLight,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, cfg.Note and 54 or 46),
        LayoutOrder = cfg.LayoutOrder or 0,
        Parent = parent,
    })
    Corner(Theme.RadiusButton, row)
    Stroke(Color3.new(1, 1, 1), 1, 0.94, row)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, cfg.Note and 8 or 0),
        Size = UDim2.new(1, -110, cfg.Note and 16 or 1, 0),
        FontFace = FontFace,
        Text = cfg.Name or "Toggle",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    if cfg.Note then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 28),
            Size = UDim2.new(1, -110, 0, 14),
            FontFace = FontFace,
            Text = cfg.Note,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = row,
        })
    end

    -- dokunmatik switch — 48x28, iOS tarzı
    local switch = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(48, 28),
        BackgroundColor3 = on and Theme.Accent or Theme.GlassBright,
        BorderSizePixel = 0,
        Text = "", AutoButtonColor = false,
        Parent = row,
    })
    Corner(Theme.RadiusPill, switch)
    local swStroke = Stroke(on and Theme.AccentSoft or Color3.new(1, 1, 1), 1, on and 0.2 or 0.88, switch)

    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = on and UDim2.new(1, -23, 0.5, 0) or UDim2.fromOffset(4, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = switch,
    })
    Corner(Theme.RadiusPill, knob)

    local function apply(state, silent)
        on = state
        Tween(switch, Theme.TweenSoft, { BackgroundColor3 = on and Theme.Accent or Theme.GlassBright })
        Tween(knob, Theme.TweenSoft, { Position = on and UDim2.new(1, -23, 0.5, 0) or UDim2.fromOffset(4, 0) })
        Tween(swStroke, Theme.TweenSoft, {
            Color = on and Theme.AccentSoft or Color3.new(1, 1, 1),
            Transparency = on and 0.2 or 0.88,
        })
        if not silent and cfg.Callback then
            task.spawn(function()
                local ok, err = pcall(cfg.Callback, on)
                if not ok then warn("[ZexHub] Toggle error:", err) end
            end)
        end
    end

    switch.MouseButton1Click:Connect(function()
        Tap()
        apply(not on)
    end)

    return {
        _type = "Toggle", _name = cfg.Name, _row = row,
        Get = function() return on end,
        Set = function(v, s) apply(v == true, s) end,
    }
end

local function ButtonRow(parent, cfg)
    local row = New("Frame", {
        BackgroundColor3 = Theme.GlassLight,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        LayoutOrder = cfg.LayoutOrder or 0,
        Parent = parent,
    })
    Corner(Theme.RadiusButton, row)
    Stroke(Color3.new(1, 1, 1), 1, 0.94, row)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -140, 1, 0),
        FontFace = FontFace,
        Text = cfg.Name or "Button",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local btn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(104, 34),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        FontFace = FontFaceBold,
        Text = cfg.ButtonText or "Çalıştır",
        TextColor3 = Theme.Backdrop,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = row,
    })
    Corner(Theme.RadiusButton, btn)
    Stroke(Theme.AccentSoft, 1, 0.3, btn)
    Gradient(Theme.AccentSoft, Theme.AccentDeep, 90, btn)

    btn.MouseButton1Click:Connect(function()
        Tap()
        if cfg.Callback then
            task.spawn(function()
                local ok, err = pcall(cfg.Callback)
                if not ok then warn("[ZexHub] Button error:", err) end
            end)
        end
    end)

    btn.MouseButton1Down:Connect(function()
        Tween(btn, Theme.TweenFast, { BackgroundTransparency = 0, Size = UDim2.fromOffset(100, 32) })
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, Theme.TweenFast, { BackgroundTransparency = 0.08, Size = UDim2.fromOffset(104, 34) })
    end)

    return { _type = "Button", _name = cfg.Name }
end

local function SliderRow(parent, cfg)
    local min = tonumber(cfg.Min) or 0
    local max = tonumber(cfg.Max) or 100
    local value = tonumber(cfg.Default) or min
    local decimals = cfg.AllowDecimals == true
    local increment = tonumber(cfg.Increment) or (decimals and 0.1 or 1)

    local row = New("Frame", {
        BackgroundColor3 = Theme.GlassLight,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 62),
        LayoutOrder = cfg.LayoutOrder or 0,
        Parent = parent,
    })
    Corner(Theme.RadiusButton, row)
    Stroke(Color3.new(1, 1, 1), 1, 0.94, row)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -100, 0, 16),
        FontFace = FontFace,
        Text = cfg.Name or "Slider",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valLbl = New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 8),
        Size = UDim2.fromOffset(80, 16),
        FontFace = FontFaceBold,
        Text = tostring(value) .. (type(cfg.Unit) == "string" and cfg.Unit or ""),
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    -- dokunmatik için daha kalın track + büyük knob
    local track = New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 16, 1, -18),
        Size = UDim2.new(1, -32, 0, 6),
        BackgroundColor3 = Theme.GlassBright,
        BorderSizePixel = 0,
        Parent = row,
    })
    Corner(Theme.RadiusPill, track)

    local fill = New("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    Corner(Theme.RadiusPill, fill)
    Gradient(Theme.AccentSoft, Theme.AccentDeep, 0, fill)

    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = track,
    })
    Corner(Theme.RadiusPill, knob)
    Stroke(Theme.AccentSoft, 2, 0.2, knob)

    -- dokunmatik hitbox — track'in üstünde büyük görünmez buton
    local hitbox = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, -10),
        Size = UDim2.new(1, 0, 1, 20),
        Text = "",
        ZIndex = 4,
        Parent = track,
    })

    local function quantize(v)
        v = math.clamp(v, min, max)
        if not decimals then
            v = math.floor(v / increment + 0.5) * increment
        else
            v = math.floor(v / increment + 0.5) * increment
        end
        return v
    end

    local dragging = false
    local function updateFromInput(input)
        local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        local v = quantize(min + rel * (max - min))
        if v ~= value then
            value = v
            Tween(fill, Theme.TweenFast, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) })
            Tween(knob, Theme.TweenFast, { Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0) })
            local txt = decimals and string.format("%.2f", value) or tostring(math.floor(value))
            valLbl.Text = txt .. (type(cfg.Unit) == "string" and cfg.Unit or "")
            if cfg.Callback then
                task.spawn(function()
                    pcall(cfg.Callback, value)
                end)
            end
        end
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
            Tween(knob, Theme.TweenFast, { Size = UDim2.fromOffset(26, 26) })
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateFromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false
                Tween(knob, Theme.TweenFast, { Size = UDim2.fromOffset(22, 22) })
            end
        end
    end)

    return {
        _type = "Slider", _name = cfg.Name,
        Get = function() return value end,
        Set = function(v, silent)
            value = quantize(tonumber(v) or value)
            Tween(fill, Theme.TweenFast, { Size = UDim2.new((value - min) / (max - min), 0, 1, 0) })
            Tween(knob, Theme.TweenFast, { Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0) })
            local txt = decimals and string.format("%.2f", value) or tostring(math.floor(value))
            valLbl.Text = txt .. (type(cfg.Unit) == "string" and cfg.Unit or "")
            if not silent and cfg.Callback then
                task.spawn(function() pcall(cfg.Callback, value) end)
            end
        end,
        SetRange = function(nmin, nmax)
            min = nmin; max = nmax
            value = math.clamp(value, min, max)
        end,
        GetUnit = function() return type(cfg.Unit) == "string" and cfg.Unit or "" end,
    }
end

-- ═══════════════════════════════════════════════════════════
--  PUBLIC API — Chilli Library uyumu
-- ═══════════════════════════════════════════════════════════

local Window = nil

local TabAPI = {}
TabAPI.__index = TabAPI

function TabAPI:CreateSection(cfg)
    return BuildSection(self._tab, cfg)
end

local function BindSectionMethods(sec, tab)
    function sec:CreateToggle(cfg)
        cfg.LayoutOrder = cfg.LayoutOrder or 0
        return ToggleRow(self.Body, cfg)
    end
    function sec:CreateButton(cfg)
        cfg.LayoutOrder = cfg.LayoutOrder or 0
        return ButtonRow(self.Body, cfg)
    end
    function sec:CreateSlider(cfg)
        cfg.LayoutOrder = cfg.LayoutOrder or 0
        return SliderRow(self.Body, cfg)
    end
    function sec:CreateDropdown(cfg)
        -- basit placeholder: dropdown -> buton seti olarak düşür
        return ButtonRow(self.Body, {
            Name = cfg.Name or "Dropdown",
            ButtonText = tostring(cfg.Default or "Seç"),
            LayoutOrder = cfg.LayoutOrder or 0,
            Callback = function()
                if cfg.Callback then cfg.Callback(cfg.Default) end
            end,
        })
    end
    function sec:CreateMultiDropdown(cfg)
        return ButtonRow(self.Body, {
            Name = cfg.Name or "Multi",
            ButtonText = "Seç",
            LayoutOrder = cfg.LayoutOrder or 0,
            Callback = function()
                if cfg.Callback then cfg.Callback(cfg.Default or {}) end
            end,
        })
    end
    function sec:CreateInput(cfg)
        return ButtonRow(self.Body, {
            Name = cfg.Name or "Input",
            ButtonText = "Uygula",
            LayoutOrder = cfg.LayoutOrder or 0,
            Callback = function()
                if cfg.Callback then cfg.Callback(cfg.Default or "") end
            end,
        })
    end
    function sec:CreateText(cfg)
        local lbl = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            FontFace = FontFace,
            Text = cfg.Text or cfg.Name or "",
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = cfg.LayoutOrder or 0,
            Parent = self.Body,
        })
        return lbl
    end
    return sec
end

local function BuildTabAPI(win, cfg)
    local tab = BuildTab(win, cfg)
    local api = setmetatable({ _tab = tab }, TabAPI)
    function api:GetDefaultTab() return tab end
    return api
end

-- ZexLib ana API
function ZexLib.CreateWindow(cfg)
    local win = BuildWindow(cfg)
    Window = win

    local api = {}
    function api:CreateTab(cfg)
        return BuildTabAPI(win, cfg)
    end
    function api:GetDefaultTab()
        return State.ActiveTab
    end
    function api:CreateState(cfg)
        local val = cfg and cfg.Default
        return {
            Get = function() return val end,
            Set = function(v) val = v end,
        }
    end
    function api:GetState(name)
        return api:CreateState({ Default = nil })
    end
    return api
end

function ZexLib.Notify(title, text, duration)
    -- basit toast
    if not State.Shell then return end
    local toast = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 20),
        Size = UDim2.fromOffset(300, 60),
        BackgroundColor3 = Theme.Glass,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 200,
        Parent = State.Gui,
    })
    Corner(Theme.RadiusCard, toast)
    local s = Stroke(Theme.Accent, 1.4, 0.35, toast)
    Gradient(Theme.AccentSoft, Theme.AccentDeep, 45, s)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 10),
        Size = UDim2.new(1, -32, 0, 18),
        FontFace = FontFaceBold,
        Text = title or "Bildirim",
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 201,
        Parent = toast,
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 30),
        Size = UDim2.new(1, -32, 0, 20),
        FontFace = FontFace,
        Text = text or "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 201,
        Parent = toast,
    })

    toast.Position = UDim2.new(0.5, 0, 0, -80)
    Tween(toast, Theme.TweenSoft, { Position = UDim2.new(0.5, 0, 0, 20) })
    task.delay(duration or 5, function()
        Tween(toast, Theme.TweenSoft, { Position = UDim2.new(0.5, 0, 0, -80), BackgroundTransparency = 1 })
        task.wait(0.3)
        toast:Destroy()
    end)
end

function ZexLib.Finalize(cfg)
    -- Chilli Finalize stub
end

return ZexLib
