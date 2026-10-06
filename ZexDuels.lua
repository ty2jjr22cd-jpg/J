--══════════════════════════════════════════════════════════════════════
--  ZEXHUB — Mobile / Delta Executor Build
--  Discord: .gg/Z2AxF4yZY
--══════════════════════════════════════════════════════════════════════

-- ============================================================
--  ZEXHUB BRANDING LAYER
--  Yüklenmeden önce tüm Printed/deobf/leaked izlerini temizler,
--  çalışma sırasında da tüm print/GUI metinlerini ZexHub yapar.
-- ============================================================
_G.ZEXHUB_BRANDING = true

do
    -- 1) PRINT'LERİ ELE GEÇİR — "Printed" geçen print mesajlarını ZexHub yap
    local _realPrint = print
    local function _zexPrint(...)
        local args = {...}
        for i, a in ipairs(args) do
            if type(a) == "string" then
                a = a:gsub("[Pp]rinted[%s]*[Dd]uels", "ZexHub")
                a = a:gsub("[Pp]rinted", "ZexHub")
                a = a:gsub("[Dd]eobf by [^\n]*", "")
                a = a:gsub("[Ll]eaked by [^\n]*", "")
                a = a:gsub("discord%.gg/speedhub", ".gg/Z2AxF4yZY")
                a = a:gsub("speedhub", "Z2AxF4yZY")
                a = a:gsub("@ironl", "")
                a = a:gsub("@d1v1ne", "")
                a = a:gsub("@hb0u", "")
                a = a:gsub("@aggredire", "")
                args[i] = a
            end
        end
        _realPrint(table.unpack(args))
    end
    print = _zexPrint
    _realPrint("")
    _realPrint("═══════════════════════════════════════════════════════════════")
    _realPrint("                    ZexHub — Loading                            ")
    _realPrint("                    Discord: .gg/Z2AxF4yZY                      ")
    _realPrint("═══════════════════════════════════════════════════════════════")
    _realPrint("")
end

-- ============================================================
--  2) STRING METOTLARINI ELE GEÇİR — GUI ve config stringlerini temizle
-- ============================================================
do
    local _origGsub = string.gsub
    -- Not: global gsub override etmek riskli, o yüzden sadece Print ve
    -- GUI text setter override ediyoruz.
end

-- ============================================================
--  3) GUI TEXT SETTER OVERRIDE — Yeni oluşturulan her TextLabel'ın
--  metnini otomatik temizler
-- ============================================================
do
    local _origNew = Instance.new
    local function _cleanText(s)
        if type(s) ~= "string" then return s end
        s = s:gsub("[Pp]rinted[%s]*[Dd]uels", "ZexHub")
        s = s:gsub("[Pp]rinted[%s]*[Hh]ub", "ZexHub")
        s = s:gsub("[Pp]rinted", "ZexHub")
        s = s:gsub("[Dd]eobf by [^\n]*", "")
        s = s:gsub("[Ll]eaked by [^\n]*", "")
        s = s:gsub("#1 deobf by [^\n]*", "")
        s = s:gsub("discord%.gg/speedhub", ".gg/Z2AxF4yZY")
        s = s:gsub("speedhub", "Z2AxF4yZY")
        s = s:gsub(".gg/uraniumm", ".gg/Z2AxF4yZY")
        s = s:gsub("uraniumm", "Z2AxF4yZY")
        s = s:gsub("@ironl%s*", "")
        s = s:gsub("@d1v1ne%s*", "")
        s = s:gsub("@hb0u%s*", "")
        s = s:gsub("@aggredire%s*", "")
        s = s:gsub("@aggredire%.", "")
        s = s:gsub("Made [Bb]y%s*", "")
        s = s:gsub("|%s*|", "|")
        s = s:gsub("^%s*|%s*", "")
        s = s:gsub("%s*|%s*$", "")
        s = s:gsub("%s+", " ")
        s = s:gsub("^%s+", "")
        s = s:gsub("%s+$", "")
        return s
    end

    -- Instance.new'ı sarmala — TextLabel / TextButton / TextBox
    -- oluşturulunca Text alanını otomatik temizle
    local function _wrapNew(className, parent)
        local obj = _origNew(className, parent)
        if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
            local mt = getrawmetatable and getrawmetatable(obj)
            if mt then
                local oldNewIndex = mt.__newindex
                if oldNewIndex then
                    pcall(function()
                        mt.__newindex = function(t, k, v)
                            if k == "Text" then v = _cleanText(v) end
                            return oldNewIndex(t, k, v)
                        end
                    end)
                end
            end
        end
        return obj
    end
    -- Bu override opsiyonel ve riskli, o yüzden sadece pcall içinde dene
    pcall(function()
        Instance.new = _wrapNew
    end)
end

-- ============================================================
--  4) GUI CHILD OVERRIDE — ScreenGui/Folder altına ZexHub isimli
--  çocuk eklenince Printed isimlerini temizle
-- ============================================================
do
    local function _fixName(obj)
        if not obj or not obj.Name then return end
        local n = obj.Name
        n = n:gsub("[Pp]rinted[%s]*[Dd]uels", "ZexHub")
        n = n:gsub("[Pp]rinted", "ZexHub")
        n = n:gsub("[Pp]rinted[%s]*[Mm]obile", "ZexMobile")
        n = n:gsub("Printed", "Zex")
        if n ~= obj.Name then
            pcall(function() obj.Name = n end)
        end
    end

    local _origDestroy = Instance.new("Folder").Destroy
    -- Not: Destroy override etmek tehlikeli, o yüzden atlıyoruz.
    -- Bunun yerine CoreGui'deki isimleri temizleyen bir heartbeat loop
    -- kuracağız aşağıda.
end

-- ============================================================
--  5) SCREENGUI İSİM TEMİZLEME — CoreGui'de "Printed" geçen
--  her şeyi "Zex" yap
-- ============================================================
do
    local function _cleanGuiNames()
        local parents = {}
        pcall(function() if gethui then table.insert(parents, gethui()) end end)
        pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
        pcall(function() table.insert(parents, game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")) end)

        for _, p in ipairs(parents) do
            if p then
                local kids = p:GetChildren()
                for _, k in ipairs(kids) do
                    local n = k.Name
                    local cleaned = n
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Dd]uels", "ZexHub")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Mm]obile", "ZexMobile")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Ss]teal", "ZexSteal")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Tt]racer", "ZexTracer")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Ii]ntro", "ZexIntro")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Mm]edusa", "ZexMedusa")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Tt]p", "ZexTp")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Aa]nti", "ZexAnti")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Ss]afe", "ZexSafe")
                    cleaned = cleaned:gsub("[Pp]rinted[%s]*[Cc]onfirm", "ZexConfirm")
                    cleaned = cleaned:gsub("[Pp]rinted", "Zex")
                    if cleaned ~= n then
                        pcall(function() k.Name = cleaned end)
                    end
                end
            end
        end
    end

    -- İlk temizlik
    task.defer(_cleanGuiNames)
    task.delay(0.5, _cleanGuiNames)
    task.delay(2, _cleanGuiNames)

    -- Sürekli kontrol (yeni GUI açıldığında yakala)
    task.spawn(function()
        while _G.ZEXHUB_BRANDING do
            task.wait(1.5)
            pcall(_cleanGuiNames)
        end
    end)
end

-- ============================================================
--  6) CONFIG DOSYA İSİMLERİNİ ELE GEÇİR — Printed Duels config
--  dosyası varsa ZexHub'a taşı
-- ============================================================
do
    task.defer(function()
        if type(isfile) ~= "function" or type(readfile) ~= "function"
           or type(writefile) ~= "function" then return end
        pcall(function()
            local oldConfig = "PrintedDuels_MainGUI_Config_V1.json"
            local newConfig = "ZexHub_config.json"
            if isfile(oldConfig) and not isfile(newConfig) then
                writefile(newConfig, readfile(oldConfig))
            end
        end)
    end)
end

-- ============================================================
--  7) HATA MESAJLARINI BASTIR — Kod patlarsa "Printed" geçmesin
-- ============================================================
do
    local _realWarn = warn
    local function _zexWarn(...)
        local args = {...}
        for i, a in ipairs(args) do
            if type(a) == "string" then
                a = a:gsub("[Pp]rinted", "ZexHub")
                a = a:gsub("[Dd]eobf by [^\n]*", "")
                args[i] = a
            end
        end
        _realWarn(table.unpack(args))
    end
    warn = _zexWarn
end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- GLOBAL STATE
-- ============================================================
NS = 60
CS = 30
LAGGER_SPEED = 15
LAGGER_CARRY_SPEED = 24.5
AIMBOT_SPEED = 58
LAGGER_AIMBOT_SPEED = 90
AUTO_BAT_SPEED = 82
AUTO_BAT_VERT_SPEED = 52
AUTO_BAT_DIST = -10
AUTO_BAT_HEIGHT = 4.75
AUTO_BAT_V_OFF = 1
AUTO_BAT_TURN_SPEED = 200
AUTO_BAT_MAX_TURN_RATE = 28

speedMode = false
laggerToggled = false
laggerPhase = 0
antiRagdollEnabled = false
infJumpEnabled = false
infJumpMode = "manual"
jumpMode = "Manual"
holdToJumpEnabled = false
holdInfJumpConn = nil
medusaCounterEnabled = false
batCounterEnabled = false
unwalkEnabled = false
medusaDebounce = false
medusaLastUsed = 0
dropActive = false
autoLeftEnabled = false
autoRightEnabled = false
autoBatEnabled = false
autoSwingEnabled = false
tpBatEnabled = false
tpBatCamShake = false
tpBatAutoSwing = false
tpBatHittingCD = false
autoTPEnabled = false
autoTPHeight = 20
autoTPConn = nil
mirrorTPDownEnabled = false
antiDieEnabled = false
antiVoidEnabled = false
antiVoidConn = nil
antiVoidSteppedConn = nil
antiVoidSafeCFrame = nil
antiVoidLastGround = 0
bodyLockEnabled = false
bodyLockRadius = 12
bodyLockConn = nil
espEnabled = false
tracersEnabled = false
safeModeEnabled = true
antiLagEnabled = false
removeAccessoriesEnabled = false
antiLagDescConn = nil
stretchRezEnabled = false
stretchRezConn = nil
stretchFOV = 120
uiLocked = false
visible = false
hideMobileButtons = false
currentBackground = 0
skyTheme = "Off"
printedFOVEnabled = false
printedFOVValue = 70
autoCarryEnabled = false
autoPlayAfterCountdown = false
aimbotMode = "V1"
selectedIntroMusic = 1
animPack = "Hit Harder"
animPackEnabled = false
harderHitAnimEnabled = false
headless = false
korblox = false
_introEnabled = true

-- Steal state
tbl19 = { AutoStealEnabled = false, StealRadius = 60, StealDuration = 1.3, Data = {} }
str7 = "Semi"
n32 = 60
flag18 = false
autoGrabStopEnabled = true
autoGrabStopTime = 0.96
autoGrabSetDelayRadius = 9
ENVY_STEAL_RADIUS = 61
ENVY_STEAL_DURATION = 1.3

-- Jump state
JumpState = {
    holdPressed = false,
    holdActive = false,
    controllerActive = false,
    mobilePressed = false,
    mobileActive = false,
    hooked = {},
}

-- Anti-Die state
PrintedAntiDie = {
    enabled = false,
    loop = nil,
    stepLoop = nil,
    healthConn = nil,
    diedConn = nil,
    removeConn = nil,
    charConn = nil,
    invincibleUntil = 0,
    config = {
        healthThreshold = 50,
        invincibilityFrames = 1.5,
        ragdollProtection = true,
        autoRevive = true,
    },
}

-- Desync state
PrintedDesync = {
    alive = true,
    enabled = false,
    fakeRoot = nil,
    repRootOwner = nil,
    stepConnection = nil,
    antiBatConn = nil,
    lastSafeCFrame = nil,
    lastCheckTime = 0,
    FAKE_ROOT_NAME = "DavidDesyncRoot",
    FAKE_ROOT_Y = -1000,
    FAKE_ROOT_VELOCITY = Vector3.new(0, -1000, 0),
    ANTI_BAT_RANGE = 5,
}

-- ESP state
PrintedESP = { enabled = false, data = {}, conns = {} }
PrintedTracer = { enabled = false, data = {}, conn = nil }

-- Medusa
_medusaStoneUntil = 0
_medusaGrabResumeAt = 0
_medusaStealWasOn = false

-- Body lock
_printedBodyLockSuspended = false

-- Keybinds
tbl17 = {
    AutoLeft = { kb = Enum.KeyCode.Z, gp = nil },
    AutoRight = { kb = Enum.KeyCode.C, gp = nil },
    AutoBat = { kb = Enum.KeyCode.E, gp = nil },
    CarrySpeed = { kb = Enum.KeyCode.Q, gp = nil },
    DropBrainrot = { kb = Enum.KeyCode.X, gp = nil },
    TPDown = { kb = Enum.KeyCode.F, gp = nil },
    LaggerCarry = { kb = Enum.KeyCode.R, gp = nil },
    LaggerSpeed = { kb = Enum.KeyCode.T, gp = nil },
    TPBat = { kb = Enum.KeyCode.V, gp = nil },
}

tbl18 = {
    { id = "AutoLeft", label = "Auto Left" },
    { id = "AutoRight", label = "Auto Right" },
    { id = "AutoBat", label = "Aimbot" },
    { id = "CarrySpeed", label = "Carry" },
    { id = "DropBrainrot", label = "Drop Brainrot" },
    { id = "TPDown", label = "TP Down" },
    { id = "LaggerCarry", label = "Lagger Carry" },
    { id = "LaggerSpeed", label = "Lagger Normal" },
    { id = "TPBat", label = "TP Bat" },
}

-- Mobile button state (bigger default size + scale)
mobileButtonPositions = mobileButtonPositions or {}
mobileButtonScaleValue = mobileButtonScaleValue or 1.0
mobileButtonFrames = mobileButtonFrames or {}
mobileGroupPosition = mobileGroupPosition or { xs = 0.5, x = 0, ys = 0.5, y = 0 }
MobileButtonActions = MobileButtonActions or {}
buttonsAsPanel = nil
_printedBtnSeq = 0
uiScale = nil
visible = false
v88 = nil
v90 = nil
MOBILE_BTN_SIZE = 52  -- slightly smaller (was 64)

-- Config
PRINTED_CONFIG_FILE = "PrintedDuels_MainGUI_Config_V1.json"
PRINTED_KEYBINDS_FILE = "PrintedDuels_Keybinds_V1.json"
_printedConfigLoadedAt = 0
_printed_canSaveConfig = false
_printed_readfile = readfile or (syn and syn.readfile) or (getgenv and getgenv().readfile)
_printed_writefile = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile)
_printed_isfile = isfile or (syn and syn.isfile) or (getgenv and getgenv().isfile)
_printed_canSaveConfig = type(_printed_readfile) == "function" and type(_printed_writefile) == "function"
_printedConfigDirty = false
_printedConfigSaveTask = nil
-- force re-detect after a short delay (some executors inject funcs late)
task.defer(function()
    task.wait(0.1)
    _printed_readfile = _printed_readfile or readfile or (syn and syn.readfile)
    _printed_writefile = _printed_writefile or writefile or (syn and syn.writefile)
    _printed_isfile = _printed_isfile or isfile or (syn and syn.isfile)
    _printed_canSaveConfig = type(_printed_readfile) == "function" and type(_printed_writefile) == "function"
end)

local function printedPosOf(gui)
    if not gui then return nil end
    local ok, pos = pcall(function() return gui.Position end)
    if not ok or not pos then return nil end
    return {
        xs = pos.X.Scale, x = pos.X.Offset,
        ys = pos.Y.Scale, y = pos.Y.Offset,
    }
end

local function printedApplyPos(gui, data, fallback)
    if not gui or type(data) ~= "table" then return end
    local xs = tonumber(data.xs)
    local x = tonumber(data.x)
    local ys = tonumber(data.ys)
    local y = tonumber(data.y)
    if xs == nil or x == nil or ys == nil or y == nil then
        if fallback then gui.Position = fallback end
        return
    end
    pcall(function()
        gui.Position = UDim2.new(xs, x, ys, y)
    end)
end

local function printedCollectConfig()
    local kb = {}
    for id, bind in pairs(tbl17 or {}) do
        kb[id] = {
            kb = bind.kb and tostring(bind.kb.Name) or nil,
            gp = bind.gp and tostring(bind.gp.Name) or nil,
        }
    end

    -- live positions from UI
    local stealPos = printedPosOf(_G.__PrintedBarFrame)
    local mainPos = printedPosOf(_G.__PrintedMainFrame or _G.__PrintedMain)
    local miniPos = printedPosOf(_G.__PrintedMiniBtn or _G.__PrintedMini)
    local stealDragged = false
    pcall(function()
        if _G.__PrintedBarFrame then
            stealDragged = _G.__PrintedBarFrame:GetAttribute("UserDragged") == true
        end
    end)

    -- snapshot mobile positions from frames if present
    local mbPos = {}
    if type(mobileButtonPositions) == "table" then
        for k, v in pairs(mobileButtonPositions) do mbPos[k] = v end
    end
    for name, d in pairs(mobileButtonFrames or {}) do
        if d and d.frame then
            local p = printedPosOf(d.frame)
            if p then mbPos[name] = p end
        end
    end
    local groupPos = mobileGroupPosition
    local liveBtnScale = tonumber(mobileButtonScaleValue) or tonumber(_G.PrintedBtnScale) or 1.0
    pcall(function()
        if _G.__PrintedBtnScaleObj and _G.__PrintedBtnScaleObj.Parent then
            liveBtnScale = tonumber(_G.__PrintedBtnScaleObj.Scale) or liveBtnScale
            local cont = _G.__PrintedBtnScaleObj.Parent
            if cont and cont:IsA("GuiObject") then
                groupPos = {
                    xs = cont.Position.X.Scale, x = cont.Position.X.Offset,
                    ys = cont.Position.Y.Scale, y = cont.Position.Y.Offset,
                }
            end
        end
    end)
    -- keep globals in sync with live values so next re-execute is correct
    mobileButtonScaleValue = liveBtnScale
    _G.PrintedBtnScale = liveBtnScale
    if groupPos then mobileGroupPosition = groupPos end

    return {
        version = 2,
        NS = NS, CS = CS,
        LAGGER_SPEED = LAGGER_SPEED, LAGGER_CARRY_SPEED = LAGGER_CARRY_SPEED,
        AIMBOT_SPEED = AIMBOT_SPEED, LAGGER_AIMBOT_SPEED = LAGGER_AIMBOT_SPEED,
        speedMode = speedMode, laggerToggled = laggerToggled, laggerPhase = laggerPhase,
        antiRagdollEnabled = antiRagdollEnabled,
        infJumpEnabled = infJumpEnabled, infJumpMode = infJumpMode, jumpMode = jumpMode,
        medusaCounterEnabled = medusaCounterEnabled, batCounterEnabled = batCounterEnabled,
        unwalkEnabled = unwalkEnabled,
        autoSwingEnabled = autoSwingEnabled, tpBatCamShake = tpBatCamShake, tpBatAutoSwing = tpBatAutoSwing,
        mirrorTPDownEnabled = mirrorTPDownEnabled,
        antiDieEnabled = antiDieEnabled, antiVoidEnabled = antiVoidEnabled,
        bodyLockEnabled = bodyLockEnabled, bodyLockRadius = bodyLockRadius,
        espEnabled = espEnabled, tracersEnabled = tracersEnabled,
        safeModeEnabled = safeModeEnabled, antiLagEnabled = antiLagEnabled,
        stretchRezEnabled = stretchRezEnabled,
        hideMobileButtons = hideMobileButtons == true,
        uiLocked = uiLocked == true,
        currentBackground = currentBackground, skyTheme = skyTheme,
        printedFOVEnabled = printedFOVEnabled, printedFOVValue = printedFOVValue,
        aimbotMode = aimbotMode, selectedIntroMusic = selectedIntroMusic,
        animPack = animPack, animPackEnabled = animPackEnabled,
        headless = headless, korblox = korblox, _introEnabled = _introEnabled,
        AutoStealEnabled = tbl19 and tbl19.AutoStealEnabled or false,
        StealRadius = tbl19 and tbl19.StealRadius or 60,
        StealMode = str7 or "Semi",
        autoGrabStopEnabled = autoGrabStopEnabled,
        accentTheme = _G.PrintedAccentTheme or "Blue",
        buttonMode = _G.PrintedButtonMode or "Gradient",
        btnTheme = _G.PrintedBtnTheme or 0,
        guiScale = _G.PrintedGuiScale or 0.82,
        btnScale = liveBtnScale,
        barScale = _G.PrintedBarScale or 1,
        mobileButtonsPanel = _G.PrintedMobileButtonsPanel == true,
        mobileButtonPositions = mbPos,
        mobileGroupPosition = groupPos or {},
        mobileButtonScaleValue = liveBtnScale,
        language = PrintedI18n and PrintedI18n.code or "en",
        toggleSound = _G.PrintedToggleSoundVersion or "V1",
        keybinds = kb,
        -- positions
        stealBarPosition = stealPos,
        stealBarDragged = stealDragged,
        mainGuiPosition = mainPos,
        miniBtnPosition = miniPos,
    }
end

local function printedApplyConfig(data)
    if type(data) ~= "table" then return end
    local function n(v, d) local t = tonumber(v); return t or d end
    local function b(v, d) if v == nil then return d end return v and true or false end
    NS = n(data.NS, NS or 60)
    CS = clampCarrySpeed(data.CS or CS)
    LAGGER_SPEED = n(data.LAGGER_SPEED, LAGGER_SPEED or 15)
    LAGGER_CARRY_SPEED = n(data.LAGGER_CARRY_SPEED, LAGGER_CARRY_SPEED or 24.5)
    AIMBOT_SPEED = n(data.AIMBOT_SPEED, AIMBOT_SPEED or 58)
    LAGGER_AIMBOT_SPEED = n(data.LAGGER_AIMBOT_SPEED, LAGGER_AIMBOT_SPEED or 90)
    antiRagdollEnabled = b(data.antiRagdollEnabled, false)
    pcall(function() if antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end end)
    infJumpEnabled = b(data.infJumpEnabled, false)
    if data.infJumpMode or data.jumpMode then
        pcall(setInfJumpMode, data.infJumpMode or (data.jumpMode == "Hold" and "hold" or "manual"))
    end
    medusaCounterEnabled = b(data.medusaCounterEnabled, false)
    batCounterEnabled = b(data.batCounterEnabled, false)
    pcall(function() if batCounterEnabled then startBatCounter() else stopBatCounter() end end)
    unwalkEnabled = b(data.unwalkEnabled, false)
    autoSwingEnabled = b(data.autoSwingEnabled, false)
    tpBatCamShake = b(data.tpBatCamShake, false)
    tpBatAutoSwing = b(data.tpBatAutoSwing, false)
    mirrorTPDownEnabled = b(data.mirrorTPDownEnabled, false)
    antiDieEnabled = b(data.antiDieEnabled, false)
    pcall(function() if antiDieEnabled and startAntiDie then startAntiDie() elseif stopAntiDie then stopAntiDie() end end)
    antiVoidEnabled = b(data.antiVoidEnabled, false)
    pcall(function() if antiVoidEnabled then startAntiVoid() else stopAntiVoid() end end)
    bodyLockEnabled = b(data.bodyLockEnabled, false)
    bodyLockRadius = math.clamp(n(data.bodyLockRadius, 12), 9, 20)
    pcall(function() if bodyLockEnabled then startBodyLock() else stopBodyLock() end end)
    espEnabled = b(data.espEnabled, false)
    pcall(function() if espEnabled and startPrintedESP then startPrintedESP() elseif stopPrintedESP then stopPrintedESP() end end)
    tracersEnabled = b(data.tracersEnabled, false)
    pcall(function() if tracersEnabled and startPrintedTracers then startPrintedTracers() elseif stopPrintedTracers then stopPrintedTracers() end end)
    safeModeEnabled = b(data.safeModeEnabled, true)
    antiLagEnabled = b(data.antiLagEnabled, false)
    pcall(function() if antiLagEnabled and enableAntiLag then enableAntiLag() elseif disableAntiLag then disableAntiLag() end end)
    stretchRezEnabled = b(data.stretchRezEnabled, false)
    pcall(function() if stretchRezEnabled and enableStretchRez then enableStretchRez() elseif disableStretchRez then disableStretchRez() end end)
    hideMobileButtons = b(data.hideMobileButtons, false)
    uiLocked = b(data.uiLocked, false)
    currentBackground = n(data.currentBackground, currentBackground or 1)
    aimbotMode = tostring(data.aimbotMode or aimbotMode or "V1")
    selectedIntroMusic = n(data.selectedIntroMusic, 1)
    animPack = tostring(data.animPack or animPack or "Hit Harder")
    animPackEnabled = b(data.animPackEnabled, false)
    headless = b(data.headless, false)
    korblox = b(data.korblox, false)
    _introEnabled = b(data._introEnabled, true)
    if tbl19 then
        tbl19.AutoStealEnabled = b(data.AutoStealEnabled, false)
        tbl19.StealRadius = n(data.StealRadius, 60)
    end
    str7 = tostring(data.StealMode or str7 or "Semi")
    autoGrabStopEnabled = b(data.autoGrabStopEnabled, true)
    _G.PrintedAccentTheme = tostring(data.accentTheme or "Blue")
    _G.PrintedButtonMode = tostring(data.buttonMode or "Gradient")
    _G.PrintedBtnTheme = n(data.btnTheme, 0)
    _G.PrintedGuiScale = n(data.guiScale, 0.82)
    _G.PrintedBtnScale = n(data.btnScale, mobileButtonScaleValue or 1.0)
    _G.PrintedBarScale = n(data.barScale, 1)
    _G.PrintedMobileButtonsPanel = b(data.mobileButtonsPanel, false)
    _G.PrintedToggleSoundVersion = tostring(data.toggleSound or "V1")
    if type(data.mobileButtonPositions) == "table" then
        mobileButtonPositions = data.mobileButtonPositions
    end
    if type(data.mobileGroupPosition) == "table" then
        mobileGroupPosition = data.mobileGroupPosition
    end
    mobileButtonScaleValue = n(data.mobileButtonScaleValue, mobileButtonScaleValue or 1.0)
    _G.PrintedBtnScale = mobileButtonScaleValue
    if type(data.keybinds) == "table" and tbl17 then
        for id, bind in pairs(data.keybinds) do
            if tbl17[id] and type(bind) == "table" then
                if bind.kb and Enum.KeyCode[bind.kb] then tbl17[id].kb = Enum.KeyCode[bind.kb] else tbl17[id].kb = nil end
                if bind.gp and Enum.KeyCode[bind.gp] then tbl17[id].gp = Enum.KeyCode[bind.gp] else tbl17[id].gp = nil end
            end
        end
    end
    if data.language and printedApplyLanguage then pcall(printedApplyLanguage, data.language) end
    if _G.__PrintedSetGuiScale then pcall(_G.__PrintedSetGuiScale, _G.PrintedGuiScale) end
    if _G.__PrintedBarScaleObj then _G.__PrintedBarScaleObj.Scale = math.clamp(_G.PrintedBarScale, 0.1, 1.5) end
    if _G.__PrintedBtnScaleObj then
        _G.__PrintedBtnScaleObj.Scale = mobileButtonScaleValue
    end
    if _G.PrintedRefreshLockBtn then pcall(_G.PrintedRefreshLockBtn) end
    -- force mobile panel + positions to match saved config right after load
    if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end

    -- restore positions
    _G.__PrintedSavedStealPos = data.stealBarPosition
    _G.__PrintedSavedStealDragged = data.stealBarDragged == true
    _G.__PrintedSavedMainPos = data.mainGuiPosition
    _G.__PrintedSavedMiniPos = data.miniBtnPosition

    if _G.__PrintedBarFrame and type(data.stealBarPosition) == "table" then
        printedApplyPos(_G.__PrintedBarFrame, data.stealBarPosition)
        if data.stealBarDragged then
            pcall(function() _G.__PrintedBarFrame:SetAttribute("UserDragged", true) end)
        end
    end
    if _G.__PrintedMainFrame and type(data.mainGuiPosition) == "table" then
        printedApplyPos(_G.__PrintedMainFrame, data.mainGuiPosition)
    elseif _G.__PrintedMain and type(data.mainGuiPosition) == "table" then
        printedApplyPos(_G.__PrintedMain, data.mainGuiPosition)
    end
    if (_G.__PrintedMiniBtn or _G.__PrintedMini) and type(data.miniBtnPosition) == "table" then
        printedApplyPos(_G.__PrintedMiniBtn or _G.__PrintedMini, data.miniBtnPosition)
    end

    if tbl19 and tbl19.AutoStealEnabled and startAutoSteal then pcall(startAutoSteal) end
    pcall(refreshSpeedModeLabel)
    if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
    if fn41 then pcall(fn41) end
end

local function flushMobileStateLive()
    pcall(function()
        if _G.__PrintedBtnScaleObj and _G.__PrintedBtnScaleObj.Parent then
            mobileButtonScaleValue = tonumber(_G.__PrintedBtnScaleObj.Scale) or mobileButtonScaleValue or 1.0
            _G.PrintedBtnScale = mobileButtonScaleValue
            local cont = _G.__PrintedBtnScaleObj.Parent
            if cont and cont:IsA("GuiObject") then
                mobileGroupPosition = {
                    xs = cont.Position.X.Scale, x = cont.Position.X.Offset,
                    ys = cont.Position.Y.Scale, y = cont.Position.Y.Offset,
                }
            end
        end
        if type(mobileButtonFrames) == "table" then
            for name, d in pairs(mobileButtonFrames) do
                if d and d.frame and d.frame.Parent then
                    local p = d.frame.Position
                    mobileButtonPositions[name] = {
                        xs = p.X.Scale, x = p.X.Offset,
                        ys = p.Y.Scale, y = p.Y.Offset,
                    }
                end
            end
        end
    end)
end

function printedSaveConfig()
    -- re-detect writefile every save (some executors load late)
    if not _printed_writefile then
        _printed_writefile = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile)
        _printed_readfile = _printed_readfile or readfile or (syn and syn.readfile)
        _printed_isfile = _printed_isfile or isfile or (syn and syn.isfile)
        _printed_canSaveConfig = type(_printed_writefile) == "function"
    end
    if not _printed_canSaveConfig or not _printed_writefile then return false end
    flushMobileStateLive()
    local ok, err = pcall(function()
        local data = printedCollectConfig()
        data.uiLocked = uiLocked == true
        data.hideMobileButtons = hideMobileButtons == true
        data.mobileButtonsPanel = _G.PrintedMobileButtonsPanel == true
        data.mobileButtonScaleValue = tonumber(mobileButtonScaleValue) or 1.0
        data.btnScale = data.mobileButtonScaleValue
        data.mobileGroupPosition = mobileGroupPosition or {}
        data.mobileButtonPositions = mobileButtonPositions or {}
        local json = HttpService:JSONEncode(data)
        _printed_writefile(PRINTED_CONFIG_FILE, json)
        if PRINTED_KEYBINDS_FILE then
            pcall(function()
                _printed_writefile(PRINTED_KEYBINDS_FILE, HttpService:JSONEncode(data.keybinds or {}))
            end)
        end
    end)
    if ok then
        _printedConfigDirty = false
        _printedConfigLoadedAt = tick()
        return true
    end
    warn("[Printed] save config failed: " .. tostring(err))
    return false
end
_G.PrintedSaveConfig = printedSaveConfig

function printedLoadConfig()
    if not _printed_readfile then
        _printed_readfile = readfile or (syn and syn.readfile) or (getgenv and getgenv().readfile)
        _printed_writefile = _printed_writefile or writefile or (syn and syn.writefile)
        _printed_isfile = _printed_isfile or isfile or (syn and syn.isfile)
        _printed_canSaveConfig = type(_printed_writefile) == "function"
    end
    if not _printed_readfile then return false end
    local ok, data = pcall(function()
        if _printed_isfile and not _printed_isfile(PRINTED_CONFIG_FILE) then return nil end
        local raw = _printed_readfile(PRINTED_CONFIG_FILE)
        if not raw or raw == "" then return nil end
        return HttpService:JSONDecode(raw)
    end)
    if ok and type(data) == "table" then
        pcall(printedApplyConfig, data)
        -- force lock / hide / panel / scale after apply so re-execute never resets
        if data.uiLocked ~= nil then
            uiLocked = data.uiLocked and true or false
        end
        if data.hideMobileButtons ~= nil then
            hideMobileButtons = data.hideMobileButtons and true or false
        end
        if data.mobileButtonsPanel ~= nil then
            _G.PrintedMobileButtonsPanel = data.mobileButtonsPanel and true or false
        end
        if data.mobileButtonScaleValue ~= nil or data.btnScale ~= nil then
            mobileButtonScaleValue = tonumber(data.mobileButtonScaleValue or data.btnScale) or 1.0
            _G.PrintedBtnScale = mobileButtonScaleValue
        end
        if type(data.mobileGroupPosition) == "table" then
            mobileGroupPosition = data.mobileGroupPosition
        end
        if type(data.mobileButtonPositions) == "table" then
            mobileButtonPositions = data.mobileButtonPositions
        end
        _printedConfigLoadedAt = tick()
        return true
    end
    return false
end
_G.PrintedLoadConfig = printedLoadConfig

function printedMarkDirty()
    _printedConfigDirty = true
    if not _printed_canSaveConfig and not _printed_writefile then
        _printed_writefile = writefile or (syn and syn.writefile)
        _printed_canSaveConfig = type(_printed_writefile) == "function"
    end
    if not _printed_canSaveConfig then return end
    -- save almost instantly (was 0.2, now 0.05)
    if _printedConfigSaveTask then return end
    _printedConfigSaveTask = task.delay(0.05, function()
        _printedConfigSaveTask = nil
        if _printedConfigDirty then
            pcall(printedSaveConfig)
        end
    end)
end
_G.PrintedMarkDirty = printedMarkDirty

function printedSavePositionsNow()
    -- flush live UI positions into tables then save immediately
    pcall(function()
        if _G.__PrintedBarFrame then
            local p = _G.__PrintedBarFrame.Position
            _G.__PrintedSavedStealPos = { xs = p.X.Scale, x = p.X.Offset, ys = p.Y.Scale, y = p.Y.Offset }
            _G.__PrintedSavedStealDragged = _G.__PrintedBarFrame:GetAttribute("UserDragged") == true
        end
        local main = _G.__PrintedMainFrame or _G.__PrintedMain
        if main then
            local p = main.Position
            _G.__PrintedSavedMainPos = { xs = p.X.Scale, x = p.X.Offset, ys = p.Y.Scale, y = p.Y.Offset }
        end
        local mini = _G.__PrintedMiniBtn or _G.__PrintedMini
        if mini then
            local p = mini.Position
            _G.__PrintedSavedMiniPos = { xs = p.X.Scale, x = p.X.Offset, ys = p.Y.Scale, y = p.Y.Offset }
        end
        for name, d in pairs(mobileButtonFrames or {}) do
            if d and d.frame then
                local p = d.frame.Position
                mobileButtonPositions[name] = { xs = p.X.Scale, x = p.X.Offset, ys = p.Y.Scale, y = p.Y.Offset }
            end
        end
        pcall(function()
            if v88 then
                local cont = v88:FindFirstChild("ButtonContainer")
                if cont then
                    mobileGroupPosition = {
                        xs = cont.Position.X.Scale, x = cont.Position.X.Offset,
                        ys = cont.Position.Y.Scale, y = cont.Position.Y.Offset,
                    }
                end
            end
        end)
    end)
    _printedConfigDirty = true
    pcall(printedSaveConfig)
end
_G.PrintedSavePositionsNow = printedSavePositionsNow


-- Intro
INTRO_MUSIC_LINKS = {
    "https://litter.catbox.moe/un88ni.mp3",
    "https://litter.catbox.moe/cnscqt.mp3",
    "https://litter.catbox.moe/yl5qct.mp3",
    "https://litter.catbox.moe/gmy92t.mp3",
    "https://litter.catbox.moe/61rdbi.mp3",
    "https://litter.catbox.moe/2pk71b.mp3",
    "https://litter.catbox.moe/kmszgk.mp3",
    "https://litter.catbox.moe/2kck1d.mp3",
    "https://litter.catbox.moe/lga6r5.mp3",
    "https://litter.catbox.moe/d4vv6y.mp3",
}
INTRO_MUSIC_DURATION = 15
_currentIntroSound = nil
_introAssetCache = {}
stopIntroPreview = nil
stopIntroPlayback = nil
createIntroSound = nil
previewIntroMusic = nil
playIntroSequence = nil
getIntroAsset = nil
_safeNotify = nil

-- Misc state
local tbl20 = {
    autoSteal = nil, antiRag = nil, batCounter = nil,
    anchor = {}, progress = nil, medusaScan = nil,
}
local tbl22 = {}
local now2 = nil
local n33 = 0
local _tpFloorLast = 0
local _PrintedMirrorTPConn = nil
local vector = Vector3.new(-476.47, -6.28, 92.73)
local vector2 = Vector3.new(-483.12, -4.95, -6.28)
local vector3 = Vector3.new(-476.16, -6.52, 7.11)
local vector4 = Vector3.new(-476.75, -4.95, 25.48)
local autoLeftConn = nil
local autoRightConn = nil
local autoLeftPhase = 1
local autoRightPhase = 1
local batCounterLastUse = 0
local aimbotConnection = nil
local autoRotateSaved = nil
local swingCooldown = false
local _v2PrevAutoRotate = nil
local _larpAimTarget = nil
local _autoBatTarget = nil
local unwalkSavedAnimate = nil
local _antiRagLastReset = 0
local unblacklistURL = "https://unblacklist-buddy.lovable.app/api/unblacklist"
local unblacklistPassword = "printed12344"
local _printedSpyWatch = true
local _printedGuiBuildSections = nil
local _printedGuiBuildFunctions = nil

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function clampCarrySpeed(v)
    local n = tonumber(v) or CS or 30
    if n < 1 then n = 28.9 end
    return n
end

local function getActiveMoveSpeed()
    if laggerToggled then
        return laggerPhase == 2 and LAGGER_CARRY_SPEED or LAGGER_SPEED
    elseif speedMode then
        return clampCarrySpeed(CS)
    end
    return NS
end

local function getAutoPathSpeed()
    return laggerToggled and LAGGER_SPEED or NS
end

local function isRagdollState(humanoid)
    if not humanoid then return true end
    local state = humanoid:GetState()
    return humanoid.PlatformStand
        or state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
end

local function isCarrySpeedMode()
    if speedMode and not laggerToggled then return true end
    return laggerToggled and laggerPhase == 2
end

local function destroyCarryForce() end

local function applyVelocitySpeed(hrp, humanoid, speed, moveDir)
    if not hrp or not humanoid or humanoid.Health <= 0 then return end
    if isRagdollState(humanoid) then return end
    moveDir = moveDir or humanoid.MoveDirection
    local y = hrp.AssemblyLinearVelocity and hrp.AssemblyLinearVelocity.Y or 0
    if moveDir and moveDir.Magnitude > 0.05 then
        local vec = Vector3.new(moveDir.X, 0, moveDir.Z)
        if vec.Magnitude < 0.05 then return end
        local unit = vec.Unit
        pcall(function()
            if hrp.SetNetworkOwner then hrp:SetNetworkOwner(localPlayer) end
        end)
        hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, y, unit.Z * speed)
    end
end

local function isHoldingBrainrotNow()
    return _G.PrintedSafeModeHoldingBrainrot and _G.PrintedSafeModeHoldingBrainrot() or false
end

local function detectMyPlotSidePrinted()
    local side = checkMyPlot()
    if side == "left" then return "left" end
    if side == "right" then return "right" end
    local char = localPlayer.Character
    char = char and char:FindFirstChild("HumanoidRootPart")
    if char then
        return char.Position.Z < 60 and "left" or "right"
    end
    return nil
end

-- ============================================================
-- I18N
-- ============================================================
PrintedI18n = {
    code = "en",
    order = { "en", "es", "fr", "de", "pt", "ru", "zh", "ja", "ko", "it", "tr", "nl", "pl", "vi", "id", "ar", "hi", "th" },
    names = {
        en = "English", es = "Español", fr = "Français", de = "Deutsch",
        pt = "Português", ru = "Русский", zh = "中文", ja = "日本語",
        ko = "한국어", it = "Italiano", tr = "Türkçe", nl = "Nederlands",
        pl = "Polski", vi = "Tiếng Việt", id = "Indonesia", ar = "العربية",
        hi = "हिन्दी", th = "ไทย",
    },
    registry = {},
    tabLabels = {},
    orderTabs = { "SPEED", "COMBAT", "VISUAL", "MISC", "BINDS" },
    packs = {
        en = {
            SPEED = "SPEED", VISUAL = "VISUAL", MISC = "MISC", BINDS = "BINDS",
            Combat = "Combat", Steal = "Steal", Misc = "Misc", Visual = "Visual",
            ["Accent Color"] = "Accent Color", ["Button Mode"] = "Button Mode",
            Background = "Background", INTRO = "INTRO", Interface = "Interface",
            KEYBINDS = "KEYBINDS", MOVEMENT = "MOVEMENT", CHARTER = "CHARTER",
            ["Body Lock"] = "Body Lock", ["Body Lock Range (9-20)"] = "Body Lock Range (9-20)",
            ["Anti Void"] = "Anti Void", ["Aimbot Mode"] = "Aimbot Mode",
            ["Auto Swing"] = "Auto Swing", ["TP Auto Swing"] = "TP Auto Swing",
            ["Mirror TP Down"] = "Mirror TP Down", ["Bat Counter"] = "Bat Counter",
            ["Auto Grab"] = "Auto Grab", ["Grab Radius"] = "Grab Radius",
            ["Infinite Jump"] = "Infinite Jump", ["Jump Mode"] = "Jump Mode",
            ["Anti Ragdoll"] = "Anti Ragdoll", ["Medusa Counter"] = "Medusa Counter",
            Unwalk = "Unwalk", ["Anti Lag"] = "Anti Lag", ["Stretch Rez"] = "Stretch Rez",
            Tracers = "Tracers", Theme = "Theme",
            ["Auto TP Height"] = "Auto TP Height", ["Lock GUI"] = "Lock GUI",
            ["Controller Overlay"] = "Controller Overlay", ["Keyboard Overlay"] = "Keyboard Overlay",
            ["Hide Mobile Buttons"] = "Hide Mobile Buttons", ["Edit Mobile Buttons"] = "Edit Mobile Buttons",
            ["GUI Scale"] = "GUI Scale", ["Buttons Scale"] = "Buttons Scale",
            ["Steal Bar Scale"] = "Steal Bar Scale", ["Controller Scale"] = "Controller Scale",
            ["Keyboard Scale"] = "Keyboard Scale", ["Toggle Sound"] = "Toggle Sound",
            ["Normal Speed"] = "Normal Speed", ["Carry Speed"] = "Carry Speed",
            ["Lagger Normal Speed"] = "Lagger Normal Speed", ["Lagger Carry Speed"] = "Lagger Carry Speed",
            ["Auto Carry Speed"] = "Auto Carry Speed", Mode = "Mode",
            ["Animation Pack"] = "Animation Pack", Pack = "Pack",
            ["Reset All Settings"] = "Reset All Settings", Hold = "Hold", Manual = "Manual",
            V1 = "V1", V2 = "V2", AntiBypass = "AntiBypass", ON = "ON", OFF = "OFF",
            ["STATUS: ON"] = "STATUS: ON", ["STATUS: OFF"] = "STATUS: OFF",
        },
    },
}

function printedT(key)
    if key == nil then return "" end
    local str = tostring(key)
    local pack = PrintedI18n.packs[PrintedI18n.code] or PrintedI18n.packs.en
    return (pack and pack[str]) or (PrintedI18n.packs.en and PrintedI18n.packs.en[str]) or str
end
_G.PrintedT = printedT

local function fn29(obj, key)
    if not obj or not key then return obj end
    table.insert(PrintedI18n.registry, { obj = obj, key = tostring(key) })
    return obj
end

function printedApplyLanguage(code)
    if not code or not PrintedI18n.packs[code] then return end
    PrintedI18n.code = code
    _G.PrintedLanguage = code
    for _, entry in ipairs(PrintedI18n.registry) do
        if entry.obj and entry.obj.Parent and entry.key then
            pcall(function()
                if entry.obj:IsA("TextLabel") or entry.obj:IsA("TextButton") or entry.obj:IsA("TextBox") then
                    local text = printedT(entry.key)
                    if entry.obj.Font == Enum.Font.GothamBlack and entry.obj.TextSize >= 15 then
                        text = string.upper(text)
                    end
                    entry.obj.Text = text
                end
            end)
        end
    end
    for k, tabLabel in pairs(PrintedI18n.tabLabels) do
        if tabLabel and tabLabel.Parent then
            local orderTab = PrintedI18n.orderTabs and PrintedI18n.orderTabs[k]
            if orderTab then
                pcall(function() tabLabel.Text = printedT(orderTab) end)
            end
        end
    end
end
_G.PrintedApplyLanguage = printedApplyLanguage

-- ============================================================
-- ACCENT THEMES
-- ============================================================
ACCENT_THEMES = {}
ACCENT_THEMES.Blue = {
    title = Color3.fromRGB(40, 140, 255),
    stroke = Color3.fromRGB(120, 190, 255),
    grad = {
        Color3.fromRGB(30, 100, 255),
        Color3.fromRGB(180, 230, 255),
        Color3.fromRGB(80, 170, 255),
        Color3.fromRGB(160, 240, 255),
        Color3.fromRGB(40, 120, 255),
    },
    tab = Color3.fromRGB(28, 90, 180),
    sect = Color3.fromRGB(140, 120, 220),
}
ACCENT_THEMES.Silver = {
    title = Color3.fromRGB(200, 210, 225),
    stroke = Color3.fromRGB(220, 200, 215),
    grad = {
        Color3.fromRGB(140, 150, 170),
        Color3.fromRGB(230, 235, 245),
        Color3.fromRGB(170, 190, 205),
        Color3.fromRGB(240, 200, 255),
        Color3.fromRGB(150, 160, 175),
    },
    tab = Color3.fromRGB(70, 75, 90),
    sect = Color3.fromRGB(160, 180, 210),
}
ACCENT_THEMES.Pink = {
    title = Color3.fromRGB(255, 110, 180),
    stroke = Color3.fromRGB(255, 140, 190),
    grad = {
        Color3.fromRGB(255, 110, 140),
        Color3.fromRGB(255, 160, 220),
        Color3.fromRGB(200, 100, 180),
        Color3.fromRGB(255, 220, 240),
        Color3.fromRGB(220, 50, 190),
    },
    tab = Color3.fromRGB(160, 40, 140),
    sect = Color3.fromRGB(220, 80, 150),
}
ACCENT_THEMES.Green = {
    title = Color3.fromRGB(70, 220, 140),
    stroke = Color3.fromRGB(90, 240, 150),
    grad = {
        Color3.fromRGB(80, 200, 90),
        Color3.fromRGB(200, 255, 160),
        Color3.fromRGB(60, 200, 120),
        Color3.fromRGB(180, 255, 210),
        Color3.fromRGB(40, 170, 100),
    },
    tab = Color3.fromRGB(30, 120, 70),
    sect = Color3.fromRGB(120, 180, 140),
}
ACCENT_THEMES.Gold = {
    title = Color3.fromRGB(255, 200, 140),
    stroke = Color3.fromRGB(255, 180, 100),
    grad = {
        Color3.fromRGB(200, 140, 20),
        Color3.fromRGB(255, 240, 160),
        Color3.fromRGB(240, 190, 50),
        Color3.fromRGB(255, 200, 180),
        Color3.fromRGB(255, 150, 80),
    },
    tab = Color3.fromRGB(140, 100, 60),
    sect = Color3.fromRGB(220, 170, 110),
}

local function getAccent()
    return ACCENT_THEMES[_G.PrintedAccentTheme] or ACCENT_THEMES.Blue
end

_G.PrintedThemeIds = { 135988097101926, 122809280617698, 90207534864065, 75753198764412 }
_G.PrintedBtnTheme = _G.PrintedBtnTheme or 0
_G.PrintedMenuOpenAssets = {
    Blue = 127912104692615,
    Silver = 98581633454219,
    Pink = 109844708419597,
    Green = 98581633454219,
    Gold = 90522270011044,
}

-- ============================================================
-- SOUND
-- ============================================================
local TOGGLE_SOUND_PACKS = {
    V1 = {
        name = "Bubble",
        toggle = { "rbxassetid://6042053626", "rbxassetid://3398620867", "rbxassetid://255881176", "rbxassetid://12222208" },
        tab = { "rbxassetid://3398620867", "rbxassetid://6042053626", "rbxassetid://12222200" },
        pitch = 1, volume = 2,
    },
    V2 = {
        name = "Blip",
        toggle = { "rbxassetid://9113822143", "rbxassetid://6895079853", "rbxassetid://12222208" },
        tab = { "rbxassetid://9113821597", "rbxassetid://6895079733", "rbxassetid://12222200" },
        pitch = 1.15, volume = 1.6,
    },
}
_G.PrintedToggleSoundPacks = TOGGLE_SOUND_PACKS
local soundCache = {}

local function getMenuSound(idList)
    local key = table.concat(idList, "|")
    local cached = soundCache[key]
    if cached and cached.Parent then return cached end
    for _, id in ipairs(idList) do
        local ok, sound = pcall(function()
            local s = Instance.new("Sound")
            s.Name = "PrintedMenuSound"
            s.SoundId = id
            s.Parent = SoundService
            pcall(function() ContentProvider:PreloadAsync({ s }) end)
            return s
        end)
        if ok and sound then
            if sound.IsLoaded then soundCache[key] = sound return sound end
            pcall(function() sound:Destroy() end)
        end
    end
    return nil
end

function playMenuSound(kind)
    pcall(function()
        local pack = TOGGLE_SOUND_PACKS[_G.PrintedToggleSoundVersion or "V1"] or TOGGLE_SOUND_PACKS.V1
        local sound = getMenuSound(kind == "tab" and pack.tab or pack.toggle)
        if not sound then return end
        local clone = sound:Clone()
        clone.Volume = pack.volume or 1.5
        local pitch = pack.pitch or 1
        if kind == "tab" then pitch = pitch * 0.94 end
        clone.PlaybackSpeed = pitch
        clone.Parent = SoundService
        clone:Play()
        task.delay(3, function() pcall(function() clone:Destroy() end) end)
    end)
end
_G.PrintedPlayMenuSound = playMenuSound
local function fn52() playMenuSound("toggle") end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local v89, v90Notif, v91, flag21Notif, fn44Notif
local v92Notif = nil
flag21Notif = false
flag20Notif = false

local function ensureMedusaNotify()
    if v92Notif and v92Notif.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedMedusaNotify"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    local ok = false
    pcall(function() if gethui then sg.Parent = gethui() ok = true end end)
    if not ok then pcall(function() sg.Parent = CoreGui ok = true end) end
    if not ok then pcall(function() sg.Parent = localPlayer:WaitForChild("PlayerGui", 5) end) end
    v92Notif = sg
    local banner = Instance.new("Frame", sg)
    banner.Name = "Banner"
    banner.AnchorPoint = Vector2.new(0.5, 0)
    banner.Position = UDim2.new(0.5, 0, 0, 18)
    banner.Size = UDim2.new(0, 320, 0, 52)
    banner.BackgroundColor3 = Color3.fromRGB(60, 12, 16)
    banner.BorderSizePixel = 0
    banner.Visible = false
    banner.ZIndex = 50
    Instance.new("UICorner", banner).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", banner)
    stroke.Color = Color3.fromRGB(90, 16, 18)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    local icon = Instance.new("TextLabel", banner)
    icon.Size = UDim2.new(0, 36, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚠"
    icon.TextColor3 = Color3.fromRGB(255, 200, 50)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 22
    icon.ZIndex = 51
    local title = Instance.new("TextLabel", banner)
    title.Size = UDim2.new(1, -56, 0, 24)
    title.Position = UDim2.new(0, 46, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "USER HAS MEDUSA OUT!"
    title.TextColor3 = Color3.fromRGB(255, 140, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 51
    local sub = Instance.new("TextLabel", banner)
    sub.Size = UDim2.new(1, -56, 0, 16)
    sub.Position = UDim2.new(0, 46, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = "put it away before steal"
    sub.TextColor3 = Color3.fromRGB(255, 210, 210)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 51
    v89 = banner
    v90Notif = title
    v91 = sub
end

local hideMedNotify
hideMedNotify = function()
    if not flag21Notif or not v89 then return end
    flag21Notif = false
    local tween = TweenService:Create(v89, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -70) })
    tween:Play()
    tween.Completed:Connect(function()
        if not flag21Notif and v89 then v89.Visible = false end
    end)
end

fn44Notif = function(msg)
    ensureMedusaNotify()
    if not v89 then return end
    v90Notif.Text = "USER HAS MEDUSA OUT!"
    v91.Text = tostring(msg or "enemy")
    if not flag21Notif then
        flag21Notif = true
        v89.Visible = true
        v89.Position = UDim2.new(0.5, 0, 0, -60)
        TweenService:Create(v89, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 18) }):Play()
    end
    v92Notif = v92Notif or 0
    local id = (v92Notif or 0) + 1
    v92Notif = id
    task.delay(1.5, function()
        if id == v92Notif and flag21Notif then hideMedNotify() end
    end)
end

local function isMedusaTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local n = string.lower(tool.Name)
    return n:find("medusa", 1, true) ~= nil or n:find("medusa's head", 1, true) ~= nil or n:find("medusa head", 1, true) ~= nil
end

local function playerHasMedusa(player)
    if not player or player == localPlayer then return false, nil end
    local char = player.Character
    if not char then return false, nil end
    for _, child in ipairs(char:GetChildren()) do
        if isMedusaTool(child) then return true, child end
    end
    return false, nil
end

-- TP Bat notify
local v89Tp, v90Tp, v91Tp, flag21Tp, flag20Tp
local v92Tp = nil
local function ensureTpBatNotify()
    if v92Tp and v92Tp.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedTpBatNotify"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999998
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    local ok = false
    pcall(function() if gethui then sg.Parent = gethui() ok = true end end)
    if not ok then pcall(function() sg.Parent = CoreGui ok = true end) end
    if not ok then pcall(function() sg.Parent = localPlayer:WaitForChild("PlayerGui", 5) end) end
    v92Tp = sg
    local banner = Instance.new("Frame", sg)
    banner.Name = "Banner"
    banner.AnchorPoint = Vector2.new(0.5, 0)
    banner.Position = UDim2.new(0.5, 0, 0, 18)
    banner.Size = UDim2.new(0, 320, 0, 52)
    banner.BackgroundColor3 = Color3.fromRGB(140, 28, 32)
    banner.BorderSizePixel = 0
    banner.Visible = false
    banner.ZIndex = 50
    Instance.new("UICorner", banner).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", banner)
    stroke.Color = Color3.fromRGB(90, 16, 18)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    local icon = Instance.new("TextLabel", banner)
    icon.Size = UDim2.new(0, 36, 1, 0)
    icon.Position = UDim2.new(0, 10, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "⚠"
    icon.TextColor3 = Color3.fromRGB(255, 200, 50)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 22
    icon.ZIndex = 51
    local title = Instance.new("TextLabel", banner)
    title.Size = UDim2.new(1, -56, 0, 24)
    title.Position = UDim2.new(0, 46, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "USER IS USING TP BAT!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 51
    local sub = Instance.new("TextLabel", banner)
    sub.Size = UDim2.new(1, -56, 0, 16)
    sub.Position = UDim2.new(0, 46, 0, 28)
    sub.BackgroundTransparency = 1
    sub.Text = "opponent speed 100+"
    sub.TextColor3 = Color3.fromRGB(255, 210, 210)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 51
    local dismiss = Instance.new("TextButton", banner)
    dismiss.Name = "Dismiss"
    dismiss.Size = UDim2.new(1, 0, 1, 0)
    dismiss.BackgroundTransparency = 1
    dismiss.Text = ""
    dismiss.AutoButtonColor = false
    dismiss.ZIndex = 52
    dismiss.Activated:Connect(function()
        flag20Tp = true
        if hideTpBatNotify then hideTpBatNotify() end
    end)
    v89Tp = banner
    v90Tp = title
    v91Tp = sub
end

local hideTpBatNotify
hideTpBatNotify = function()
    if not flag21Tp or not v89Tp then return end
    flag21Tp = false
    local tween = TweenService:Create(v89Tp, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -70) })
    tween:Play()
    tween.Completed:Connect(function()
        if not flag21Tp and v89Tp then v89Tp.Visible = false end
    end)
end

local n33Tp = 0
local showTpBatNotify
showTpBatNotify = function(name, speed)
    ensureTpBatNotify()
    if not v89Tp then return end
    if flag21Tp then return end
    if flag20Tp then return end
    v90Tp.Text = "USER IS USING TP BAT!"
    v91Tp.Text = tostring(name or "enemy") .. "  ·  " .. tostring(math.floor(speed or 0)) .. " speed"
    flag21Tp = true
    v89Tp.Visible = true
    v89Tp.Position = UDim2.new(0.5, 0, 0, -60)
    TweenService:Create(v89Tp, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 78) }):Play()
    n33Tp = n33Tp + 1
    local id = n33Tp
    task.delay(1.5, function()
        if id ~= n33Tp then return end
        if hideTpBatNotify then hideTpBatNotify() end
        flag20Tp = true
        task.delay(2.5, function()
            if id == n33Tp then flag20Tp = false end
        end)
    end)
end

-- Safe mode notify
local v88Sm, v89Sm, v90Sm, v91Sm, v92Sm = nil, nil, nil, nil, 0

local function ensureSafeModeGui()
    if v88Sm and v88Sm.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedSafeMode"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 80
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    if not pcall(function() sg.Parent = CoreGui end) then
        sg.Parent = localPlayer:WaitForChild("PlayerGui", 5)
    end
    local frame = Instance.new("Frame", sg)
    frame.Name = "Banner"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Size = UDim2.new(0, 340, 0, 58)
    frame.Position = UDim2.new(0.5, 0, 0, -70)
    frame.BackgroundColor3 = Color3.fromRGB(18, 8, 12)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 50
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(180, 50, 60)
    stroke.Thickness = 1.6
    stroke.Transparency = 0.15
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(0, 4, 1, -12)
    bar.Position = UDim2.new(0, 8, 0, 6)
    bar.BackgroundColor3 = Color3.fromRGB(255, 55, 65)
    bar.BorderSizePixel = 0
    bar.ZIndex = 51
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local icon = Instance.new("TextLabel", frame)
    icon.Size = UDim2.new(0, 28, 1, 0)
    icon.Position = UDim2.new(0, 20, 0.5, -14)
    icon.BackgroundTransparency = 1
    icon.Text = "!"
    icon.TextColor3 = Color3.fromRGB(255, 120, 80)
    icon.Font = Enum.Font.GothamBlack
    icon.TextSize = 22
    icon.ZIndex = 52
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -60, 0, 22)
    title.Position = UDim2.new(0, 50, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "SAFE MODE : BLOCKED"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 52
    local sub = Instance.new("TextLabel", frame)
    sub.Size = UDim2.new(1, -60, 0, 18)
    sub.Position = UDim2.new(0, 50, 0, 30)
    sub.BackgroundTransparency = 1
    sub.Text = ""
    sub.TextColor3 = Color3.fromRGB(255, 160, 130)
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 12
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 52
    v88Sm = sg
    v89Sm = frame
    v90Sm = title
    v91Sm = sub
end

_G.PrintedSafeModeNotify = function(msg)
    ensureSafeModeGui()
    if not v89Sm then return end
    v92Sm = v92Sm + 1
    local id = v92Sm
    v90Sm.Text = "SAFE MODE : BLOCKED"
    v91Sm.Text = tostring(msg or "Action blocked while holding")
    v89Sm.Visible = true
    v89Sm.Position = UDim2.new(0.5, 0, 0, -70)
    TweenService:Create(v89Sm, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 20) }):Play()
    task.delay(1.5, function()
        if id ~= v92Sm then return end
        local tween = TweenService:Create(v89Sm, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -50) })
        tween:Play()
        tween.Completed:Connect(function()
            if id == v92Sm and v89Sm then v89Sm.Visible = false end
        end)
    end)
end

-- Anti-E01 notify
loadstring(game:HttpGet("https://raw.githubusercontent.com/Argian-dotcom/Jdkffkfo/refs/heads/main/Coding"))()
local v89Ae, v90Ae, v91Ae = nil, nil, nil
local n33Ae = 0

local function ensureAntiE01Gui()
    if v89Ae and v89Ae.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedAntiE01"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 120
    sg.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    if not pcall(function() sg.Parent = CoreGui end) then
        sg.Parent = localPlayer:WaitForChild("PlayerGui", 5)
    end
    local frame = Instance.new("Frame", sg)
    frame.Name = "Banner"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, -70)
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(18, 8, 10)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 50
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Name = "Stroke"
    stroke.Color = Color3.fromRGB(200, 55, 65)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.15
    local title = Instance.new("TextLabel", frame)
    title.Name = "Title"
    title.Size = UDim2.new(1, -12, 0, 14)
    title.Position = UDim2.new(0, 6, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "ANTI E01"
    title.TextColor3 = Color3.fromRGB(255, 80, 130)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 52
    local sub = Instance.new("TextLabel", frame)
    sub.Name = "Sub"
    sub.Size = UDim2.new(1, -12, 0, 28)
    sub.Position = UDim2.new(0, 6, 0, 22)
    sub.BackgroundTransparency = 1
    sub.Text = "DONT WIN"
    sub.TextColor3 = Color3.fromRGB(255, 140, 255)
    sub.Font = Enum.Font.GothamBlack
    sub.TextSize = 16
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.ZIndex = 53
    v89Ae = frame
    v90Ae = title
    v91Ae = sub
end

_G.PrintedAntiE01Notify = function()
    ensureAntiE01Gui()
    if not v89Ae then return end
    n33Ae = n33Ae + 1
    local id = n33Ae
    local stroke = v89Ae:FindFirstChild("Stroke") or v89Ae:FindFirstChildOfClass("UIStroke")
    v89Ae.BackgroundColor3 = Color3.fromRGB(52, 8, 12)
    if stroke then stroke.Color = Color3.fromRGB(200, 55, 65) end
    v90Ae.Text = "ANTI E01"
    v90Ae.TextColor3 = Color3.fromRGB(255, 120, 80)
    v91Ae.Text = "DONT WIN"
    v91Ae.TextColor3 = Color3.fromRGB(255, 140, 255)
    v89Ae.Visible = true
    v89Ae.Position = UDim2.new(0.5, 0, 0, -60)
    TweenService:Create(v89Ae, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 16) }):Play()
    task.spawn(function()
        local remain = 2
        while remain > 0 do
            if id ~= n33Ae then return end
            local holding = false
            pcall(function() if _G.PrintedSafeModeHoldingBrainrot then holding = _G.PrintedSafeModeHoldingBrainrot() == true end end)
            if not holding then
                local tween = TweenService:Create(v89Ae, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -60) })
                tween:Play()
                tween.Completed:Connect(function()
                    if id == n33Ae and v89Ae then v89Ae.Visible = false end
                end)
                return
            end
            v90Ae.Text = "DONT WIN"
            v91Ae.Text = string.format("%.1f", remain)
            v91Ae.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.wait(0.1)
            remain = remain - 0.1
        end
        if id ~= n33Ae then return end
        local holding = false
        pcall(function() if _G.PrintedSafeModeHoldingBrainrot then holding = _G.PrintedSafeModeHoldingBrainrot() == true end end)
        if holding then
            v89Ae.BackgroundColor3 = Color3.fromRGB(32, 22, 12)
            if stroke then stroke.Color = Color3.fromRGB(90, 210, 100) end
            v90Ae.Text = "ANTI E01"
            v90Ae.TextColor3 = Color3.fromRGB(80, 255, 160)
            v91Ae.Text = "SAFE"
            v91Ae.TextColor3 = Color3.fromRGB(90, 255, 140)
            task.wait(1.1)
        end
        if id ~= n33Ae then return end
        local tween = TweenService:Create(v89Ae, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -70) })
        tween:Play()
        tween.Completed:Connect(function()
            if id == n33Ae and v89Ae then
                v89Ae.Visible = false
                v89Ae.BackgroundColor3 = Color3.fromRGB(18, 8, 10)
                if stroke then stroke.Color = Color3.fromRGB(200, 55, 65) end
            end
        end)
    end)
end

-- ============================================================
-- CONFIRM DIALOG
-- ============================================================
_G.printedConfirm = function(text, onYes)
    local hui = nil
    pcall(function() if gethui then hui = gethui() end end)
    local usedCore = not hui
    if usedCore then pcall(function() hui = CoreGui end) end
    if usedCore then hui = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 3) end
    if not hui then if onYes then pcall(onYes) end return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedConfirm"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999
    sg.ResetOnSpawn = false
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    sg.Parent = hui

    local overlay = Instance.new("Frame", sg)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 50

    local dialog = Instance.new("Frame", sg)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.Size = UDim2.new(0, 280, 0, 130)
    dialog.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 11
    Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", dialog).Color = Color3.fromRGB(60, 60, 70)

    local title = Instance.new("TextLabel", dialog)
    title.Size = UDim2.new(1, -20, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 16)
    title.BackgroundTransparency = 1
    title.Text = text or "ARE U SURE?"
    title.TextColor3 = Color3.fromRGB(255, 255, 140)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.ZIndex = 12

    local sub = Instance.new("TextLabel", dialog)
    sub.Size = UDim2.new(1, -20, 0, 16)
    sub.Position = UDim2.new(0, 10, 0, 46)
    sub.BackgroundTransparency = 1
    sub.Text = "This cannot be undone"
    sub.TextColor3 = Color3.fromRGB(160, 160, 170)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.ZIndex = 12

    local function mkBtn(x, txt, bg, fg, cb)
        local b = Instance.new("TextButton", dialog)
        b.Size = UDim2.new(0, 110, 0, 34)
        b.Position = UDim2.new(0, x, 0, 80)
        b.BackgroundColor3 = bg
        b.BorderSizePixel = 0
        b.Text = txt
        b.TextColor3 = fg
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 13
        b.AutoButtonColor = false
        b.ZIndex = 12
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.Activated:Connect(function()
            pcall(function() sg:Destroy() end)
            if cb then pcall(cb) end
        end)
        return b
    end
    mkBtn(20, "NO", Color3.fromRGB(140, 40, 48), Color3.fromRGB(220, 180, 170), nil)
    mkBtn(150, "YES", Color3.fromRGB(255, 70, 80), Color3.fromRGB(255, 255, 255), onYes)

    task.delay(5, function()
        if sg and sg.Parent then pcall(function() sg:Destroy() end) end
    end)
end

-- ============================================================
-- SPEED / CARRY / LAGGER
-- ============================================================
local instance_speed = nil
speedLabel = nil

function refreshSpeedModeLabel()
    if instance_speed then
        if laggerToggled then
            instance_speed.Text = (laggerPhase == 2) and "Lagger Carry" or "Lagger Normal"
        elseif speedMode then
            instance_speed.Text = "Carry"
        else
            instance_speed.Text = "Normal"
        end
    end
end

local function blockTurnOffSpeed(msg, btnId)
    if _G.PrintedSafeModeNotify then _G.PrintedSafeModeNotify(msg or "Can't turn off speed while holding") end
    if btnId and _G.PrintedFlashBlockedButton then pcall(_G.PrintedFlashBlockedButton, btnId) end
end

function toggleCarryMode()
    local holding = safeModeEnabled and isHoldingBrainrotNow()
    if laggerToggled then
        laggerToggled = false; laggerPhase = 0; speedMode = true
    elseif speedMode then
        if holding then blockTurnOffSpeed("Can't turn off Carry while holding", "CarrySpeed") return end
        speedMode = false
    else
        speedMode = true
    end
    refreshSpeedModeLabel()
end

function toggleLaggerMode()
    local holding = safeModeEnabled and isHoldingBrainrotNow()
    if laggerToggled then
        if holding then blockTurnOffSpeed("Can't turn off Lagger while holding", "LaggerCarry") return end
        laggerToggled = false; laggerPhase = 0; speedMode = false
    else
        speedMode = false; laggerToggled = true; laggerPhase = 2
    end
    refreshSpeedModeLabel()
end

-- ============================================================
-- ANTI-RAGDOLL
-- ============================================================
local function _antiRagForceReset()
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("Motor6D") then d.Enabled = true end
            if d:IsA("Constraint") then d.Enabled = true end
        end
        workspace.CurrentCamera.CameraSubject = hum
        local pm = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if pm then
            local CM = require(pm:FindFirstChild("ControlModule"))
            if CM then CM:Enable() end
        end
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

function startAntiRagdoll()
    if tbl20.antiRag then return end
    tbl20.antiRag = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = localPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
            local now = tick()
            if now - _antiRagLastReset > 0.15 then
                _antiRagLastReset = now
                _antiRagForceReset()
            end
        end
    end)
end

function stopAntiRagdoll()
    if tbl20.antiRag then
        tbl20.antiRag:Disconnect()
        tbl20.antiRag = nil
    end
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================
local function applyInfJumpBoost(force)
    if not infJumpEnabled then return end
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, force or 50, vel.Z)
end

function setInfJumpMode(mode)
    local str = tostring(mode or ""):lower() == "hold" and "hold" or "manual"
    infJumpMode = str
    jumpMode = str == "hold" and "Hold" or "Manual"
    if str == "hold" then
        holdToJumpEnabled = true
        stopJumpHoldState()
        startHoldInfJump()
    else
        holdToJumpEnabled = false
        stopJumpHoldState()
        stopHoldInfJump()
    end
    if setHoldToJumpVisual then pcall(setHoldToJumpVisual, holdToJumpEnabled) end
    if setJumpModeLabel then pcall(setJumpModeLabel, jumpMode) end
    return jumpMode
end

function startHoldInfJump()
    if holdInfJumpConn then pcall(function() holdInfJumpConn:Disconnect() end) end
    JumpState.holdPressed = false
    JumpState.holdActive = false
    JumpState.mobilePressed = false
    JumpState.mobileActive = false
    JumpState.controllerActive = false
    holdInfJumpConn = RunService.Heartbeat:Connect(function()
        if not infJumpEnabled or infJumpMode ~= "hold" then return end
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        local spaceDown = false
        pcall(function() spaceDown = UserInputService:IsKeyDown(Enum.KeyCode.Space) end)
        local mobileDown = JumpState and JumpState.mobilePressed == true
        local gamepadDown = false
        pcall(function()
            gamepadDown = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)
                or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad2, Enum.KeyCode.ButtonA)
        end)
        if not (spaceDown or mobileDown or gamepadDown) then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y < 40 then hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 55, vel.Z) end
        local vel2 = hrp.AssemblyLinearVelocity
        if vel2.Y < -45 then hrp.AssemblyLinearVelocity = Vector3.new(vel2.X, -45, vel2.Z) end
    end)
end

function stopHoldInfJump()
    if holdInfJumpConn then
        pcall(function() holdInfJumpConn:Disconnect() end)
        holdInfJumpConn = nil
    end
end

function stopJumpHoldState()
    JumpState.holdPressed = false
    JumpState.holdActive = false
    JumpState.controllerActive = false
    JumpState.mobilePressed = false
    JumpState.mobileActive = false
end

function startHoldToJump()
    holdToJumpEnabled = true
    infJumpEnabled = true
    infJumpMode = "hold"
    jumpMode = "Hold"
    if setJumpModeLabel then pcall(setJumpModeLabel, "Hold") end
    stopJumpHoldState()
    startHoldInfJump()
end

function stopHoldToJump()
    holdToJumpEnabled = false
    stopJumpHoldState()
    stopHoldInfJump()
end

pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if not infJumpEnabled then return end
        if infJumpMode == "manual" or infJumpMode == "hold" then applyInfJumpBoost(50) end
    end)
    UserInputService.InputBegan:Connect(function(input)
        if UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
            JumpState.holdPressed = true
            if infJumpEnabled and infJumpMode == "hold" then
                task.delay(0.18, function()
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then JumpState.holdActive = true end
                end)
            end
        elseif input.KeyCode == Enum.KeyCode.ButtonA and tostring(input.UserInputType):find("Gamepad") then
            JumpState.controllerActive = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
            JumpState.holdPressed = false
            JumpState.holdActive = false
        end
        if input.KeyCode == Enum.KeyCode.ButtonA then JumpState.controllerActive = false end
    end)
end)

_G.PrintedHookMobileJumpButton = function(btn)
    if not btn or btn.Name ~= "JumpButton" or not btn:IsA("GuiButton") or JumpState.hooked[btn] then return end
    JumpState.hooked[btn] = true
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch or not infJumpEnabled then return end
        JumpState.mobilePressed = true
        task.delay(0.12, function()
            if JumpState.mobilePressed and infJumpEnabled and infJumpMode == "hold" then JumpState.mobileActive = true end
        end)
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            JumpState.mobilePressed = false
            JumpState.mobileActive = false
        end
    end)
end

task.spawn(function()
    local pg = localPlayer:WaitForChild("PlayerGui", 10)
    if not pg then return end
    for _, d in ipairs(pg:GetDescendants()) do pcall(_G.PrintedHookMobileJumpButton, d) end
    pg.DescendantAdded:Connect(function(d) task.defer(_G.PrintedHookMobileJumpButton, d) end)
end)

-- ============================================================
-- UNWALK
-- ============================================================
function startUnwalk()
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop() end end
    local animate = char:FindFirstChild("Animate")
    if animate then
        unwalkSavedAnimate = animate:Clone()
        animate:Destroy()
    end
end

function stopUnwalk()
    local char = localPlayer.Character
    if char and unwalkSavedAnimate then
        unwalkSavedAnimate:Clone().Parent = char
        unwalkSavedAnimate = nil
    end
end

-- ============================================================
-- DROP BRAINROT
-- ============================================================
function runDrop()
    if dropActive then return end
    if autoBatEnabled then
        autoBatEnabled = false
        if resetAutoBatMotion then resetAutoBatMotion() end
        if autoBatSetVisual then autoBatSetVisual(false) end
        if disableAutoBat then pcall(disableAutoBat) end
    end
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    dropActive = true
    local startTime = tick()
    local conn = nil
    conn = RunService.Heartbeat:Connect(function()
        local c2 = localPlayer.Character
        local hrp = c2 and c2:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if conn then conn:Disconnect() end
            dropActive = false
            return
        end
        if tick() - startTime >= 0.2 then
            if conn then conn:Disconnect() end
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = { c2 }
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -2000, 0), rp)
            if hit then
                local hum = c2:FindFirstChildOfClass("Humanoid")
                hrp.CFrame = CFrame.new(hrp.Position.X, hit.Position.Y + (hum and hum.HipHeight or 2) + hrp.Size.Y / 2, hrp.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            dropActive = false
            return
        end
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 150, hrp.AssemblyLinearVelocity.Z)
    end)
end

-- ============================================================
-- TP DOWN / MIRROR TP
-- ============================================================
_tpFloorLast = 0

function doAutoTPDown(force)
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if hrp.Position.Y < autoTPHeight then return end
    end
    local _, y = hrp.CFrame:ToEulerAnglesYXZ()
    hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z) * CFrame.Angles(0, y, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function startAutoTP()
    if autoTPConn then task.cancel(autoTPConn) autoTPConn = nil end
    autoTPConn = task.spawn(function()
        while autoTPEnabled do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
    end)
end

function stopAutoTP(keepEnabled)
    if autoTPConn then task.cancel(autoTPConn) autoTPConn = nil end
    if not keepEnabled then autoTPEnabled = false end
end

function runTPFloor()
    if suspendBodyLock then pcall(suspendBodyLock) end
    pcall(function() doAutoTPDown(true) end)
    task.delay(0.6, function()
        if not autoBatEnabled and not tpBatEnabled then
            if restoreBodyLock then pcall(restoreBodyLock) end
        end
    end)
end

if not _PrintedMirrorTPConn then
    _PrintedMirrorTPConn = RunService.Heartbeat:Connect(function()
        local active = mirrorTPDownEnabled and (autoBatEnabled == true or tpBatEnabled == true)
        if not active then
            if next(tbl22) then table.clear(tbl22) end
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local y = hrp.Position.Y
                    local last = tbl22[player.UserId]
                    if last and last - y >= 3 then
                        pcall(function()
                            local lc = localPlayer.Character
                            local lhrp = lc and lc:FindFirstChild("HumanoidRootPart")
                            lc = lc and lc:FindFirstChildOfClass("Humanoid")
                            if lhrp and lc and lc.Health > 0 then
                                local _, ly = lhrp.CFrame:ToEulerAnglesYXZ()
                                lhrp.CFrame = CFrame.new(lhrp.Position.X, -7, lhrp.Position.Z) * CFrame.Angles(0, ly, 0)
                                lhrp.AssemblyLinearVelocity = Vector3.zero
                            end
                        end)
                        table.clear(tbl22)
                        return
                    end
                    tbl22[player.UserId] = y
                end
            end
        end
    end)
end

-- ============================================================
-- ANTI-VOID
-- ============================================================
local function voidRaycast(pos)
    local origin = pos + Vector3.new(0, 2, 0)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local char = localPlayer.Character
    if char then rp.FilterDescendantsInstances = { char } end
    rp.IgnoreWater = true
    return workspace:Raycast(origin, Vector3.new(0, -80, 0), rp)
end

local function antiVoidRestore(hrp, hum)
    if not antiVoidSafeCFrame then return end
    hrp.CFrame = antiVoidSafeCFrame + Vector3.new(0, 5, 0)
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.zero
    hum.PlatformStand = false
    hum.Sit = false
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    pcall(function() if sethiddenproperty then sethiddenproperty(hrp, "NetworkIsSleeping", false) end end)
end

function stopAntiVoid()
    if antiVoidConn then pcall(function() antiVoidConn:Disconnect() end) antiVoidConn = nil end
    if antiVoidSteppedConn then pcall(function() antiVoidSteppedConn:Disconnect() end) antiVoidSteppedConn = nil end
    antiVoidEnabled = false
end

function startAntiVoid()
    stopAntiVoid()
    antiVoidEnabled = true
    antiVoidConn = RunService.Heartbeat:Connect(function()
        if not antiVoidEnabled then return end
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        char = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not char or hum.Health <= 0 then return end
        local threshold = (workspace.FallenPartsDestroyHeight or -500) + 30
        local y = char.Position.Y
        local vel = char.AssemblyLinearVelocity
        if hum.FloorMaterial ~= Enum.Material.Air and y > threshold + 15 then
            antiVoidSafeCFrame = char.CFrame
            antiVoidLastGround = tick()
        else
            local hit = voidRaycast(char)
            if hit and y > threshold + 12 then
                local rot = char.CFrame - char.CFrame.Position
                antiVoidSafeCFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) * rot
                antiVoidLastGround = tick()
            end
        end
        if (y <= threshold or (y <= threshold + 8 and vel.Y < -90) or y < threshold - 20) and antiVoidSafeCFrame then
            antiVoidRestore(char, hum)
        end
    end)
    antiVoidSteppedConn = RunService.Stepped:Connect(function()
        if not antiVoidEnabled then return end
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        char = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not char then return end
        if hrp.Position.Y <= (workspace.FallenPartsDestroyHeight or -500) + 30 and antiVoidSafeCFrame then
            antiVoidRestore(hrp, char)
        end
    end)
end

function setAntiVoid(enabled)
    if enabled then startAntiVoid() else stopAntiVoid() end
    if setAntiVoidVisual then pcall(setAntiVoidVisual, antiVoidEnabled) end
end

-- ============================================================
-- BODY LOCK
-- ============================================================
local function findBodyLockTarget()
    local char = localPlayer.Character
    char = char and char:FindFirstChild("HumanoidRootPart")
    if not char then return nil end
    local closest, minDist = nil, math.huge
    local radius = math.clamp(tonumber(bodyLockRadius) or 12, 9, 20)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - char.Position).Magnitude
                if d <= radius and d < minDist then
                    minDist = d
                    closest = player
                end
            end
        end
    end
    return closest
end

function startBodyLock()
    if bodyLockConn then return end
    bodyLockEnabled = true
    bodyLockConn = RunService.Heartbeat:Connect(function()
        if not bodyLockEnabled then return end
        if autoBatEnabled or tpBatEnabled then
            local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
            return
        end
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        local target = findBodyLockTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local tp = target.Character.HumanoidRootPart.Position
            local sp = hrp.Position
            local look = Vector3.new(tp.X, sp.Y, tp.Z)
            if (look - sp).Magnitude > 0.1 then
                hum.AutoRotate = false
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(sp, look), 0.22)
                hrp.AssemblyAngularVelocity = hrp.AssemblyAngularVelocity * Vector3.new(0.5, 0.25, 0.5)
            end
        else
            hum.AutoRotate = true
        end
    end)
end

function stopBodyLock()
    bodyLockEnabled = false
    if bodyLockConn then
        pcall(function() bodyLockConn:Disconnect() end)
        bodyLockConn = nil
    end
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end

_printedBodyLockSuspended = false

function forceBodyLockOffForAimbot()
    if bodyLockEnabled or _G.PrintedBodyLockEnabled then
        _printedBodyLockSuspended = true
        bodyLockEnabled = false
        _G.PrintedBodyLockEnabled = false
        pcall(stopBodyLock)
        if setBodyLockVisual then pcall(setBodyLockVisual, false) end
    end
end

function suspendBodyLock() forceBodyLockOffForAimbot() end

function restoreBodyLock()
    if not _printedBodyLockSuspended then return end
    _printedBodyLockSuspended = false
    bodyLockEnabled = true
    _G.PrintedBodyLockEnabled = true
    pcall(startBodyLock)
    if setBodyLockVisual then pcall(setBodyLockVisual, true) end
end

-- ============================================================
-- MEDUSA COUNTER
-- ============================================================
local function findMedusa()
    local char = localPlayer.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local n = child.Name:lower()
            if n:find("medusa") or n:find("head") or n:find("stone") then return child end
        end
    end
    local bp = localPlayer:FindFirstChild("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("medusa") or n:find("head") or n:find("stone") then return child end
            end
        end
    end
    return nil
end

function useMedusaCounter()
    if medusaDebounce then return end
    if tick() - medusaLastUsed < 25 then return end
    local char = localPlayer.Character
    if not char then return end
    medusaDebounce = true
    local tool = findMedusa()
    if not tool then medusaDebounce = false return end
    if tool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool) end
    end
    pcall(function() tool:Activate() end)
    medusaLastUsed = tick()
    medusaDebounce = false
end

function onMedusaStoned()
    local now = tick()
    if now < (_medusaStoneUntil or 0) - 2.5 then return end
    _medusaStoneUntil = now + 3
    _medusaGrabResumeAt = now + 1.7
    if flag18 then
        flag18 = false
        if tbl20.progress then pcall(function() tbl20.progress:Disconnect() end) tbl20.progress = nil end
        if _G.resetProgressBar then _G.resetProgressBar() end
        if textLabel2 then textLabel2.Text = "75%" end
        if frame then frame.Size = UDim2.new(0.75, 0, 1, 0) end
    end
    if tbl19.AutoStealEnabled then
        _medusaStealWasOn = true
        if stopNormalSteal then pcall(stopNormalSteal) end
    end
    task.delay(1.7, function()
        if tick() < (_medusaGrabResumeAt or 0) - 0.05 then return end
        if _medusaStealWasOn or tbl19.AutoStealEnabled then
            _medusaStealWasOn = false
            tbl19.AutoStealEnabled = true
            if startAutoSteal then pcall(startAutoSteal) end
            if textLabel2 then textLabel2.Text = "0%" end
            if frame then frame.Size = UDim2.new(0, 0, 1, 0) end
        end
    end)
end

function isMedusaStoneLocked() return tick() < (_medusaGrabResumeAt or 0) end

function setupMedusa(character)
    for _, c in pairs(tbl20.anchor) do pcall(function() c:Disconnect() end) end
    tbl20.anchor = {}
    if not character then return end
    local function hook(part)
        if not part:IsA("BasePart") then return end
        local function check()
            if part and part.Parent and part.Anchored and part.Transparency >= 0.9 then
                pcall(onMedusaStoned)
                if medusaCounterEnabled then useMedusaCounter() end
            end
        end
        table.insert(tbl20.anchor, part:GetPropertyChangedSignal("Anchored"):Connect(check))
        table.insert(tbl20.anchor, part:GetPropertyChangedSignal("Transparency"):Connect(check))
    end
    for _, d in ipairs(character:GetDescendants()) do hook(d) end
    table.insert(tbl20.anchor, character.DescendantAdded:Connect(hook))
end

function stopMedusaCounter()
    for _, c in pairs(tbl20.anchor) do pcall(function() c:Disconnect() end) end
    tbl20.anchor = {}
    if tbl20.medusaScan then pcall(function() tbl20.medusaScan:Disconnect() end) tbl20.medusaScan = nil end
end

-- ============================================================
-- BAT COUNTER
-- ============================================================
local batTools = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap",
    "Galaxy Slap", "Glitched Slap",
}

local function findBatForCounter()
    local char = localPlayer.Character
    if not char then return nil end
    local bp = localPlayer:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(batTools) do
        local t = char:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t and t:IsA("Tool") then return t end
    end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then
            local n = c.Name:lower()
            if n:find("bat") or n:find("slap") then return c end
        end
    end
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            if c:IsA("Tool") then
                local n = c.Name:lower()
                if n:find("bat") or n:find("slap") then return c end
            end
        end
    end
    return nil
end

local function swingBatForCounter(tool, char)
    if not tool or not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if tool.Parent ~= char and hum then pcall(function() hum:EquipTool(tool) end) end
    local re = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteEvent")
    if re then
        pcall(function() re:FireServer() end)
        pcall(function() re:FireServer() end)
    end
    pcall(function() tool:Activate() end)
    pcall(function() tool:Activate() end)
end

local function tryBatCounter()
    if not batCounterEnabled then return end
    local now = tick()
    if now - batCounterLastUse < 0.08 then return end
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
        or hum.PlatformStand then
        batCounterLastUse = now
        local tool = findBatForCounter()
        if tool then swingBatForCounter(tool, char) end
    end
end

function startBatCounter()
    if tbl20.batCounter then return end
    tbl20.batCounter = RunService.Heartbeat:Connect(tryBatCounter)
    local function hookChar(char)
        char = char and char:FindFirstChildOfClass("Humanoid")
        if not char then return end
        local c = char.StateChanged:Connect(function(_, new)
            if not batCounterEnabled then return end
            if new == Enum.HumanoidStateType.Physics
                or new == Enum.HumanoidStateType.Ragdoll
                or new == Enum.HumanoidStateType.FallingDown then
                tryBatCounter()
            end
        end)
        tbl20.batStateConns = tbl20.batStateConns or {}
        table.insert(tbl20.batStateConns, c)
    end
    if localPlayer.Character then hookChar(localPlayer.Character) end
    if not tbl20.batCharAdded then
        tbl20.batCharAdded = localPlayer.CharacterAdded:Connect(function(c) task.defer(hookChar, c) end)
    end
end

function stopBatCounter()
    if tbl20.batCounter then tbl20.batCounter:Disconnect() tbl20.batCounter = nil end
    if tbl20.batStateConns then
        for _, c in ipairs(tbl20.batStateConns) do pcall(function() c:Disconnect() end) end
        tbl20.batStateConns = {}
    end
    if tbl20.batCharAdded then pcall(function() tbl20.batCharAdded:Disconnect() end) tbl20.batCharAdded = nil end
    batCounterLastUse = 0
end

-- ============================================================
-- AIMBOT
-- ============================================================
local function getAceAimbotSpeed()
    if laggerToggled then return tonumber(LAGGER_AIMBOT_SPEED) or 90 end
    return tonumber(AIMBOT_SPEED) or 58
end

local function envyGetBat()
    local char = localPlayer.Character
    if not char then return nil end
    for _, name in ipairs(batTools) do
        local t = char:FindFirstChild(name)
        if t and t:IsA("Tool") then return t end
    end
    local bp = localPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(batTools) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(t) end) end
                return t
            end
        end
    end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") and (c.Name:lower():find("bat") or c.Name:lower():find("slap")) then return c end
    end
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            if c:IsA("Tool") and (c.Name:lower():find("bat") or c.Name:lower():find("slap")) then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(c) end) end
                return c
            end
        end
    end
    return nil
end

local function envyTrySwing()
    if swingCooldown or not autoSwingEnabled then return end
    swingCooldown = true
    pcall(function()
        local char = localPlayer.Character
        if not char then return end
        local tool = envyGetBat()
        if tool then
            if tool.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(tool) end) end
            end
            pcall(function() tool:Activate() end)
        end
    end)
    task.delay(0.25, function() swingCooldown = false end)
end

local function getClosestTarget()
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    local closest, minDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local phrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if phrp and hum and hum.Health > 0 then
                local d = (phrp.Position - hrp.Position).Magnitude
                if d < minDist then
                    minDist = d
                    closest = player
                end
            end
        end
    end
    return closest, minDist
end

function resetAutoBatMotion()
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y * 0.3, 0)
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then
        hum.AutoRotate = autoRotateSaved == nil and true or autoRotateSaved
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    autoRotateSaved = nil
end

function stopEnvoyOrV1Aimbot()
    if aimbotConnection then
        pcall(function() aimbotConnection:Disconnect() end)
        aimbotConnection = nil
    end
    _larpAimTarget = nil
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    char = char and char:FindFirstChildOfClass("Humanoid")
    if char then char.AutoRotate = autoRotateSaved == nil and true or autoRotateSaved end
    autoRotateSaved = nil
end

function startEnvoyOrV1Aimbot()
    stopEnvoyOrV1Aimbot()
    forceBodyLockOffForAimbot()
    aimbotMode = "V1"
    if autoLeftEnabled then autoLeftEnabled = false if autoLeftSetVisual then autoLeftSetVisual(false) end pcall(stopAutoLeft) end
    if autoRightEnabled then autoRightEnabled = false if autoRightSetVisual then autoRightSetVisual(false) end pcall(stopAutoRight) end
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if autoRotateSaved == nil then autoRotateSaved = hum.AutoRotate end
        hum.AutoRotate = false
    end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled or aimbotMode ~= "V1" then return end
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local tool = envyGetBat()
            if tool then pcall(function() hum:EquipTool(tool) end) end
        end
        local target = getClosestTarget()
        if not target or not target.Character then return end
        local phrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not phrp then return end
        _larpAimTarget = phrp
        local pvel = phrp.AssemblyLinearVelocity
        local sp = hrp.Position
        local tp = phrp.Position
        local delta = tp + pvel * 0.14 + phrp.CFrame.LookVector * 0.3 - sp
        local unit = Vector3.new(delta.X, 0, delta.Z).Unit
        local speed = getAceAimbotSpeed()
        local yForce = (tp.Y + 3.7 - sp.Y) * 19.5 + pvel.Y * 0.8
        local finalY = hum.FloorMaterial == Enum.Material.Air and yForce or math.max(yForce, 13)
        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity:Lerp(Vector3.new(unit.X * speed, math.clamp(finalY, -70, 110), unit.Z * speed), 0.8)
        local aimAt = tp + pvel * math.clamp(pvel.Magnitude / 120, 0.05, 0.2)
        if (aimAt - sp).Magnitude > 0.1 then
            local cframe = CFrame.lookAt(sp, aimAt)
            local rx, ry, rz = (hrp.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
            hrp.AssemblyAngularVelocity = hrp.CFrame:VectorToWorldSpace(Vector3.new(
                math.clamp(rx, -2.5, 2.5) * 42,
                math.clamp(ry, -2.5, 2.5) * 42,
                math.clamp(rz, -2.5, 2.5) * 42
            ))
        end
        if autoSwingEnabled then envyTrySwing() end
    end)
end

function stopAntiBypassAimbotConn()
    if aimbotConnection then
        pcall(function() aimbotConnection:Disconnect() end)
        aimbotConnection = nil
    end
    swingCooldown = false
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = autoRotateSaved == nil and true or autoRotateSaved
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    autoRotateSaved = nil
end

function startAntiBypassAimbotConn()
    stopAntiBypassAimbotConn()
    forceBodyLockOffForAimbot()
    if aimbotMode ~= "AntiBypass" then aimbotMode = "V2" end
    if autoLeftEnabled then autoLeftEnabled = false if autoLeftSetVisual then autoLeftSetVisual(false) end pcall(stopAutoLeft) end
    if autoRightEnabled then autoRightEnabled = false if autoRightSetVisual then autoRightSetVisual(false) end pcall(stopAutoRight) end
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if autoRotateSaved == nil then autoRotateSaved = hum.AutoRotate end
        hum.AutoRotate = false
    end
    swingCooldown = false
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        if aimbotMode ~= "V2" and aimbotMode ~= "AntiBypass" then return end
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local tool = envyGetBat()
            if tool then pcall(function() hum:EquipTool(tool) end) end
        end
        local target, dist = getClosestTarget()
        if not target or not target.Character then return end
        local phrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not phrp then return end
        local sp = hrp.Position
        local tp = phrp.Position
        local delta = tp - sp
        local flat = Vector3.new(delta.X, 0, delta.Z)
        local unit = flat.Magnitude > 0 and flat.Unit or Vector3.zero
        local speed = getAceAimbotSpeed()
        local yForce = (tp.Y + 3.7 - sp.Y) * 19.5
        local finalY = hum.FloorMaterial == Enum.Material.Air and yForce or math.max(yForce, 13)
        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity:Lerp(Vector3.new(unit.X * speed, math.clamp(finalY, -70, 110), unit.Z * speed), 0.8)
        if (tp - sp).Magnitude > 0.1 then
            local cframe = CFrame.lookAt(sp, tp)
            local rx, ry, rz = (hrp.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
            hrp.AssemblyAngularVelocity = hrp.CFrame:VectorToWorldSpace(Vector3.new(
                math.clamp(rx, -2.5, 2.5) * 42,
                math.clamp(ry, -2.5, 2.5) * 42,
                math.clamp(rz, -2.5, 2.5) * 42
            ))
        end
        if dist <= 8 then envyTrySwing() end
    end)
end

function applyAimbotMode()
    local mode = tostring(aimbotMode or "V1")
    if mode == "AntiBypass" or mode == "Anti Bypass" or mode == "V2" or mode == "Kawatan" then
        aimbotMode = "V2"
        _G.PrintedAntiBypassAimbot = false
    else
        aimbotMode = "V1"
        _G.PrintedAntiBypassAimbot = false
    end
    AUTO_BAT_SPEED = tonumber(AIMBOT_SPEED) or 58
    if fn44 then pcall(fn44, aimbotMode) end
end

function stopKawatanAimbotConn() stopAntiBypassAimbotConn() end
function startKawatanAimbotConn() startAntiBypassAimbotConn() end

function enableAutoBat()
    if autoLeftEnabled then autoLeftEnabled = false if autoLeftSetVisual then autoLeftSetVisual(false) end stopAutoLeft() end
    if autoRightEnabled then autoRightEnabled = false if autoRightSetVisual then autoRightSetVisual(false) end stopAutoRight() end
    if autoTPEnabled then stopAutoTP() if setAutoTPVisual then setAutoTPVisual(false) end end
    autoBatEnabled = true
    pcall(function()
        local char = localPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local tool = envyGetBat()
        if tool and tool.Parent ~= char then pcall(function() hum:EquipTool(tool) end) end
    end)
    pcall(stopAntiBypassAimbotConn)
    pcall(stopEnvoyOrV1Aimbot)
    applyAimbotMode()
    if aimbotMode == "V1" then
        startEnvoyOrV1Aimbot()
    else
        aimbotMode = "V2"
        startAntiBypassAimbotConn()
    end
end

function disableAutoBat()
    autoBatEnabled = false
    pcall(stopEnvoyOrV1Aimbot)
    pcall(stopAntiBypassAimbotConn)
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    char = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * 0.3
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if char then char.AutoRotate = _v2PrevAutoRotate == nil and true or _v2PrevAutoRotate end
    _v2PrevAutoRotate = nil
    if restoreBodyLock then pcall(restoreBodyLock) end
end

function queueAutoBatStart()
    if _G.PrintedSafeModeTryStart and not _G.PrintedSafeModeTryStart("You clicked Aimbot / Auto Bat", "AutoBat") then
        if autoBatSetVisual then autoBatSetVisual(false) end
        return
    end
    if autoLeftEnabled then autoLeftEnabled = false if autoLeftSetVisual then autoLeftSetVisual(false) end stopAutoLeft() end
    if autoRightEnabled then autoRightEnabled = false if autoRightSetVisual then autoRightSetVisual(false) end stopAutoRight() end
    enableAutoBat()
end

-- ============================================================
-- AUTO LEFT / RIGHT
-- ============================================================
function stopAutoLeft()
    if autoLeftConn then autoLeftConn:Disconnect() autoLeftConn = nil end
    autoLeftPhase = 1
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:Move(Vector3.zero, false) end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if _updateMobileAutoLeft then _updateMobileAutoLeft(false) end
end

function stopAutoRight()
    if autoRightConn then autoRightConn:Disconnect() autoRightConn = nil end
    autoRightPhase = 1
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:Move(Vector3.zero, false) end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if _updateMobileAutoRight then _updateMobileAutoRight(false) end
end

function startAutoLeft()
    if autoLeftConn then autoLeftConn:Disconnect() end
    autoLeftPhase = 1
    autoLeftConn = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero, false) return end
        local speed = getAutoPathSpeed()
        if autoLeftPhase == 1 then
            local pos = hrp.Position
            if (Vector3.new(vector.X, hrp.Position.Y, vector.Z) - pos).Magnitude < 1 then
                autoLeftPhase = 2
                local d = vector2 - hrp.Position
                local unit = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(unit, false)
                hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, hrp.AssemblyLinearVelocity.Y, unit.Z * speed)
                return
            end
            local d = vector - hrp.Position
            local unit = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(unit, false)
            hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, hrp.AssemblyLinearVelocity.Y, unit.Z * speed)
        elseif autoLeftPhase == 2 then
            local pos = hrp.Position
            if (Vector3.new(vector2.X, hrp.Position.Y, vector2.Z) - pos).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                autoLeftEnabled = false
                if autoLeftConn then autoLeftConn:Disconnect() autoLeftConn = nil end
                autoLeftPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if _updateMobileAutoLeft then _updateMobileAutoLeft(false) end
                return
            end
            local d = vector2 - hrp.Position
            local unit = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(unit, false)
            hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, hrp.AssemblyLinearVelocity.Y, unit.Z * speed)
        end
    end)
end

function startAutoRight()
    if autoRightConn then autoRightConn:Disconnect() end
    autoRightPhase = 1
    autoRightConn = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero, false) return end
        local speed = getAutoPathSpeed()
        if autoRightPhase == 1 then
            local pos = hrp.Position
            if (Vector3.new(vector3.X, hrp.Position.Y, vector3.Z) - pos).Magnitude < 1 then
                autoRightPhase = 2
                local d = vector4 - hrp.Position
                local unit = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(unit, false)
                hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, hrp.AssemblyLinearVelocity.Y, unit.Z * speed)
                return
            end
            local d = vector3 - hrp.Position
            local unit = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(unit, false)
            hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, hrp.AssemblyLinearVelocity.Y, unit.Z * speed)
        elseif autoRightPhase == 2 then
            local pos = hrp.Position
            if (Vector3.new(vector4.X, hrp.Position.Y, vector4.Z) - pos).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                autoRightEnabled = false
                if autoRightConn then autoRightConn:Disconnect() autoRightConn = nil end
                autoRightPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if _updateMobileAutoRight then _updateMobileAutoRight(false) end
                return
            end
            local d = vector4 - hrp.Position
            local unit = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(unit, false)
            hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, hrp.AssemblyLinearVelocity.Y, unit.Z * speed)
        end
    end)
end

function queueAutoLeftStart()
    if _G.PrintedSafeModeTryStart and not _G.PrintedSafeModeTryStart("You clicked Auto Left", "AutoLeft") then
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        return
    end
    autoLeftEnabled = true
    if autoRightEnabled then autoRightEnabled = false if autoRightSetVisual then autoRightSetVisual(false) end stopAutoRight() end
    if autoBatEnabled then disableAutoBat() if autoBatSetVisual then autoBatSetVisual(false) end end
    startAutoLeft()
end

function queueAutoRightStart()
    if _G.PrintedSafeModeTryStart and not _G.PrintedSafeModeTryStart("You clicked Auto Right", "AutoRight") then
        if autoRightSetVisual then autoRightSetVisual(false) end
        return
    end
    autoRightEnabled = true
    if autoLeftEnabled then autoLeftEnabled = false if autoLeftSetVisual then autoLeftSetVisual(false) end stopAutoLeft() end
    if autoBatEnabled then disableAutoBat() if autoBatSetVisual then autoBatSetVisual(false) end end
    startAutoRight()
end

-- ============================================================
-- AUTO STEAL (Semi + Timing)
-- ============================================================
local function isMedusaLocked() return tick() < (_medusaGrabResumeAt or 0) end

function isMyPlotByName(name)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(name)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

function checkMyPlot()
    for k, pos in pairs({ left = Vector3.new(-476.75, 10.46, 7.11), right = Vector3.new(-476.75, 10.46, 114.11) }) do
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and d.Name == "PlotSign" then
                if (d.Position - pos).Magnitude < 20 then
                    local parent = d.Parent or d
                    for _, sg in ipairs(parent:GetDescendants()) do
                        if sg:IsA("SurfaceGui") then
                            for _, t in ipairs(sg:GetDescendants()) do
                                if t:IsA("TextLabel") and t.Text ~= "" then
                                    if t.Text:find(localPlayer.Name) or (localPlayer.DisplayName and t.Text:find(localPlayer.DisplayName)) then
                                        return k
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function findNearestPrompt()
    local char = localPlayer.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil, nil end
    local closest, minDist, name = nil, math.huge, nil
    local radius = tonumber(tbl19 and tbl19.StealRadius) or ENVY_STEAL_RADIUS or 60

    local function isStealPrompt(p)
        if not p or not p:IsA("ProximityPrompt") then return false end
        local a = string.lower(tostring(p.ActionText or ""))
        local o = string.lower(tostring(p.ObjectText or ""))
        if a:find("steal", 1, true) or o:find("steal", 1, true) then return true end
        -- fallback: any enabled proximity prompt under animal podium
        return p.Enabled ~= false and a ~= "" 
    end

    for _, plot in ipairs(plots:GetChildren()) do
        if not isMyPlotByName(plot.Name) then
            local podiums = plot:FindFirstChild("AnimalPodiums") or plot:FindFirstChild("Podiums")
            if podiums then
                for _, podium in ipairs(podiums:GetChildren()) do
                    -- deep search for prompts
                    for _, d in ipairs(podium:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and isStealPrompt(d) then
                            local part = d.Parent
                            if part and part:IsA("Attachment") then part = part.Parent end
                            local pos = nil
                            if part and part:IsA("BasePart") then pos = part.Position
                            elseif d.Parent and d.Parent:IsA("BasePart") then pos = d.Parent.Position
                            elseif d.Parent and d.Parent:IsA("Attachment") and d.Parent.Parent and d.Parent.Parent:IsA("BasePart") then
                                pos = d.Parent.Parent.Position
                            end
                            if pos then
                                local dist = (pos - hrp.Position).Magnitude
                                if dist <= radius and dist < minDist then
                                    minDist = dist
                                    closest = d
                                    name = podium.Name
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest, name
end

local function firePromptHold(p)
    pcall(function() if p.InputHoldBegin then p:InputHoldBegin() end end)
end

local function firePromptTrigger(p)
    pcall(function() if p.InputHoldEnd then p:InputHoldEnd() end end)
    pcall(function() if fireproximityprompt then fireproximityprompt(p) end end)
end

local function fn40()
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and isRagdollState(hum) then n33 = tick() + 2 return true end
    if tick() < (n33 or 0) then return true end
    return false
end

function executeSteal(prompt, animalName)
    if flag18 then return end
    if fn40() then return end
    if not prompt or not prompt.Parent then return end
    if isMedusaLocked() then return end
    if not tbl19.Data[prompt] then
        tbl19.Data[prompt] = { hold = {}, trigger = {}, ready = true }
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(tbl19.Data[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(tbl19.Data[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = tbl19.Data[prompt]
    if not data.ready then return end
    data.ready = false
    flag18 = true
    now2 = tick()

    -- make sure steal bar UI exists and is visible
    if not (_G.__PrintedStealGui and _G.__PrintedStealGui.Parent) then
        pcall(function()
            if type(_G.PrintedRebuildStealBar) == "function" then
                _G.PrintedRebuildStealBar()
            elseif _G._PrintedBG and _G._PrintedBG.gui then
                buildStealBar(_G._PrintedBG.gui)
            end
        end)
    end
    if _G.__PrintedBarFrame then
        pcall(function()
            _G.__PrintedBarFrame.Visible = true
            if _G.__PrintedStealGui then _G.__PrintedStealGui.Enabled = true end
        end)
    end
    if _G.setStealProgress then
        _G.setStealProgress(0.02)
    else
        warn("[Printed] setStealProgress missing — steal bar not built")
    end

    local function getPromptPos()
        local part = prompt and prompt.Parent
        if part and part:IsA("Attachment") then part = part.Parent end
        if part and part:IsA("BasePart") then return part.Position end
        if prompt and prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent:IsA("BasePart") then
            return prompt.Parent.Parent.Position
        end
        return nil
    end

    local function doTrigger()
        pcall(function()
            for _, f in ipairs(data.trigger) do task.spawn(f) end
            local sa = ReplicatedStorage:FindFirstChild("StealAnimal")
            if sa and animalName then sa:FireServer(animalName) end
            if prompt then
                pcall(function() prompt:Fire() end)
                firePromptTrigger(prompt)
            end
        end)
    end

    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        if #data.hold == 0 then firePromptHold(prompt) end

        local start = tick()
        autoGrabStopTime = 0.96
        autoGrabSetDelayRadius = 9
        local duration = tonumber(tbl19.StealDuration) or 1.3
        local radius = tonumber(tbl19.StealRadius) or ENVY_STEAL_RADIUS or 60

        local function finish()
            data.ready = true
            flag18 = false
            if _G.resetProgressBar then pcall(_G.resetProgressBar) end
            if frame then pcall(function() frame.Size = UDim2.new(0, 0, 1, 0) end) end
            if textLabel2 then pcall(function() textLabel2.Text = "0%" end) end
        end

        -- ===== clean progress loop (bar fills live on steal UI) =====
        while flag18 and tbl19.AutoStealEnabled do
            if not prompt or not prompt.Parent then break end

            local elapsed = tick() - start
            local t = math.clamp(elapsed / duration, 0, 1)
            if _G.setStealProgress then
                _G.setStealProgress(t)
            end

            local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local ppos = getPromptPos()
            if hrp and ppos then
                local dist = (hrp.Position - ppos).Magnitude
                if dist > radius then
                    -- walked away — cancel this steal
                    break
                end
            end

            if elapsed >= duration then
                doTrigger()
                break
            end

            -- Semi mode: when close enough near the end, finish a bit early
            if autoGrabStopEnabled and elapsed >= autoGrabStopTime and hrp and ppos then
                local dist = (hrp.Position - ppos).Magnitude
                if dist <= autoGrabSetDelayRadius then
                    if _G.setStealProgress then _G.setStealProgress(1) end
                    doTrigger()
                    break
                end
            end

            task.wait()
        end

        finish()
    end)
end

function startNormalSteal()
    if tbl20.autoSteal then return end
    tbl19.StealRadius = ENVY_STEAL_RADIUS
    tbl19.StealDuration = ENVY_STEAL_DURATION
    tbl20.autoSteal = RunService.Heartbeat:Connect(function()
        if not tbl19.AutoStealEnabled then
            if flag18 == false and _G.resetProgressBar then pcall(_G.resetProgressBar) end
            return
        end
        if flag18 then return end
        if fn40() then return end
        local p, n = findNearestPrompt()
        if p then
            pcall(executeSteal, p, n)
        end
    end)
end

function stopNormalSteal()
    if tbl20.autoSteal then tbl20.autoSteal:Disconnect() tbl20.autoSteal = nil end
    if tbl20.progress then tbl20.progress:Disconnect() tbl20.progress = nil end
    flag18 = false
    if _G.resetProgressBar then _G.resetProgressBar() end
end

function startAutoSteal()
    tbl19.AutoStealEnabled = true
    if tostring(str7) == "Timing" then autoGrabStopEnabled = false else autoGrabStopEnabled = true end
    stopNormalSteal()
    startNormalSteal()
    -- ensure steal UI layer is alive
    if not (_G.__PrintedStealGui and _G.__PrintedStealGui.Parent) then
        pcall(function()
            if _G._PrintedBG and _G._PrintedBG.gui then
                buildStealBar(_G._PrintedBG.gui)
            end
        end)
    end
end

function stopAutoSteal()
    tbl19.AutoStealEnabled = false
    stopNormalSteal()
    if _G.resetProgressBar then _G.resetProgressBar() end
end

function applyStealMode()
    local s = tostring(str7 or "Semi")
    if s == "Timing" or s == "Envy" or s == "Timed" then
        str7 = "Timing"
        _G.PrintedStealMode = "Timing"
        _G.PrintedSemiStealActive = false
        _G.PrintedNormalSteal = false
        _G.PrintedTimingSteal = true
        tbl19.StealDuration = tonumber(tbl19.StealDuration) or 1.4
        tbl19.StealRadius = tonumber(n32) or tbl19.StealRadius or 60
        if radInput then radInput.Text = tostring(tbl19.StealRadius) end
        if tbl19.AutoStealEnabled then
            if stopAutoSteal then pcall(stopAutoSteal) end
            if _G.PrintedStartTimingSteal then pcall(_G.PrintedStartTimingSteal) end
        elseif _G.PrintedStopTimingSteal then
            pcall(_G.PrintedStopTimingSteal)
        end
    else
        str7 = "Semi"
        _G.PrintedStealMode = "Semi"
        _G.PrintedSemiStealActive = true
        _G.PrintedNormalSteal = true
        _G.PrintedTimingSteal = false
        tbl19.StealDuration = 1.3
        tbl19.StealRadius = tonumber(n32) or tbl19.StealRadius or 60
        if radInput then radInput.Text = tostring(tbl19.StealRadius) end
        if _G.PrintedStopTimingSteal then pcall(_G.PrintedStopTimingSteal) end
        if tbl19.AutoStealEnabled and startAutoSteal then pcall(startAutoSteal) else stopAutoSteal() end
    end
end

_G.PrintedStartTimingSteal = function()
    str7 = "Timing"
    tbl19.AutoStealEnabled = true
    autoGrabStopEnabled = false
    stopNormalSteal()
    startNormalSteal()
end

_G.PrintedStopTimingSteal = function()
    autoGrabStopEnabled = true
    if not tbl19.AutoStealEnabled then stopNormalSteal() end
end

_G.PrintedSafeModeHoldingBrainrot = function()
    local ok, res = pcall(function() return localPlayer:GetAttribute("Stealing") end)
    if ok and res == true then return true end
    local char = localPlayer.Character
    if not char then return false end
    local ok2, res2 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok2 and res2 == true then return true end
    for _, n in ipairs({ "Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab" }) do
        local v = char:FindFirstChild(n, true)
        if v then
            if v:IsA("BoolValue") and v.Value == true then return true end
            if v:IsA("ObjectValue") and v.Value ~= nil then return true end
            if v:IsA("StringValue") and v.Value ~= "" then return true end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") then
            local n = string.lower(child.Name)
            if (n:find("brainrot", 1, true) or n:find("animal", 1, true) or n:find("carry", 1, true)) and child:FindFirstChildWhichIsA("BasePart", true) then
                return true
            end
        end
    end
    return false
end

_G.PrintedSafeModeIsLocked = function()
    if safeModeEnabled and _G.PrintedSafeModeHoldingBrainrot() then return true end
    return false
end

_G.PrintedSafeModeForceStop = function()
    if autoLeftEnabled then
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if stopAutoLeft then pcall(stopAutoLeft) end
    end
    if autoRightEnabled then
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(false) end
        if stopAutoRight then pcall(stopAutoRight) end
    end
    if autoBatEnabled then
        autoBatEnabled = false
        if autoBatSetVisual then autoBatSetVisual(false) end
        if disableAutoBat then pcall(disableAutoBat) end
    end
    if autoSwingEnabled then
        autoSwingEnabled = false
        if setAutoSwingVisual then setAutoSwingVisual(false) end
    end
end

_G.PrintedSafeModeTryStart = function(msg, btnId)
    if _G.PrintedSafeModeIsLocked() then
        _G.PrintedSafeModeForceStop("SAFE MODE LOCK")
        if _G.PrintedSafeModeHoldingBrainrot and _G.PrintedSafeModeHoldingBrainrot() then
            if _G.PrintedSafeModeNotify then _G.PrintedSafeModeNotify(msg or "Holding brainrot") end
            if btnId and _G.PrintedFlashBlockedButton then pcall(_G.PrintedFlashBlockedButton, btnId) end
        end
        return false
    end
    return true
end

task.spawn(function()
    while task.wait(1.25) do
        if safeModeEnabled and _G.PrintedSafeModeHoldingBrainrot and _G.PrintedSafeModeHoldingBrainrot() then
            if autoLeftEnabled or autoRightEnabled or autoBatEnabled then
                pcall(_G.PrintedSafeModeForceStop, "HOLDING BRAINROT")
            end
        end
    end
end)

-- ============================================================
-- ESP / TRACERS
-- ============================================================
local espColor = Color3.fromRGB(255, 255, 255)

local function _espCleanup(player)
    local d = PrintedESP.data[player]
    if not d then return end
    pcall(function() if d.highlight then d.highlight:Destroy() end end)
    pcall(function() if d.billboard then d.billboard:Destroy() end end)
    for _, c in ipairs(d.conns or {}) do pcall(function() c:Disconnect() end) end
    PrintedESP.data[player] = nil
end

local function _espSetup(player, character)
    if not PrintedESP.enabled or player == localPlayer or not character then return end
    _espCleanup(player)
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
    if not hrp or not head or not PrintedESP.enabled then return end
    local hl = Instance.new("Highlight")
    hl.Name = "PrintedESP"
    hl.Adornee = character
    hl.FillColor = Color3.fromRGB(255, 140, 255)
    hl.FillTransparency = 0.35
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = character
    local bb = Instance.new("BillboardGui")
    bb.Name = "PrintedESPBillboard"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 92, 0, 22)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Parent = head
    bb.Size = UDim2.new(0, 92, 0, 36)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    local nameLbl = Instance.new("TextLabel", bb)
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.Position = UDim2.new(0, 0, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = Color3.new(1, 1, 1)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 14
    nameLbl.TextStrokeTransparency = 0.3
    nameLbl.Text = player.DisplayName or player.Name
    local speedLbl = Instance.new("TextLabel", bb)
    speedLbl.Size = UDim2.new(1, 0, 0, 14)
    speedLbl.Position = UDim2.new(0, 0, 0, 16)
    speedLbl.BackgroundTransparency = 1
    speedLbl.TextColor3 = Color3.fromRGB(200, 210, 255)
    speedLbl.Font = Enum.Font.Gotham
    speedLbl.TextSize = 11
    speedLbl.TextStrokeTransparency = 0.2
    speedLbl.Text = "0 speed"
    local acc = 0
    local conn = RunService.Heartbeat:Connect(function(dt)
        if not PrintedESP.enabled or not hrp.Parent then return end
        acc = acc + dt
        if acc < 0.1 then return end
        acc = 0
        local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
        speedLbl.Text = string.format("%d speed", math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude + 0.5))
    end)
    PrintedESP.data[player] = { highlight = hl, billboard = bb, conns = { conn } }
end

function startPrintedESP()
    if PrintedESP.enabled then return end
    PrintedESP.enabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if player.Character then task.spawn(_espSetup, player, player.Character) end
            table.insert(PrintedESP.conns, player.CharacterAdded:Connect(function(c)
                task.defer(_espSetup, player, c)
            end))
        end
    end
    table.insert(PrintedESP.conns, Players.PlayerAdded:Connect(function(player)
        if player == localPlayer then return end
        table.insert(PrintedESP.conns, player.CharacterAdded:Connect(function(c)
            task.defer(_espSetup, player, c)
        end))
    end))
    table.insert(PrintedESP.conns, Players.PlayerRemoving:Connect(_espCleanup))
end

function stopPrintedESP()
    PrintedESP.enabled = false
    for _, c in ipairs(PrintedESP.conns) do pcall(function() c:Disconnect() end) end
    PrintedESP.conns = {}
    for k in pairs(PrintedESP.data) do _espCleanup(k) end
    PrintedESP.data = {}
end

local tracerGui = nil
local function _tracerEnsureGui()
    if tracerGui and tracerGui.Parent then return tracerGui end
    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedTracers"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 2000000
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    local ok = false
    pcall(function() if gethui then sg.Parent = gethui() ok = true end end)
    if not ok then pcall(function() sg.Parent = CoreGui ok = true end) end
    if not ok then pcall(function() sg.Parent = localPlayer:WaitForChild("PlayerGui", 5) end) end
    tracerGui = sg
    return sg
end

local function _tracerClear(player)
    local line = PrintedTracer.data[player]
    if not line then return end
    pcall(function() line:Destroy() end)
    PrintedTracer.data[player] = nil
end

local function _tracerClearAll()
    for k in pairs(PrintedTracer.data) do _tracerClear(k) end
    PrintedTracer.data = {}
end

local function _tracerMakeLine()
    local line = Instance.new("Frame")
    line.Name = "PrintedTracerLine"
    line.BorderSizePixel = 0
    line.BackgroundColor3 = espColor
    line.BackgroundTransparency = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Size = UDim2.fromOffset(0, 2)
    line.ZIndex = 10
    line.Visible = false
    line.Parent = _tracerEnsureGui()
    return line
end

local function _tracerStep()
    if not PrintedTracer.enabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local gui = _tracerEnsureGui()
    local vp = cam.ViewportSize
    local cx = vp.X * 0.5
    local cy = vp.Y - 60
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then char = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") end
            local line = PrintedTracer.data[player]
            if not char then
                if line then line.Visible = false end
            else
                if not line or not line.Parent then
                    line = _tracerMakeLine()
                    PrintedTracer.data[player] = line
                elseif line.Parent ~= gui then
                    line.Parent = gui
                end
                local sp = cam:WorldToViewportPoint(char.Position - Vector3.new(0, 2, 0))
                local x, y = sp.X, sp.Y
                if sp.Z <= 0 then
                    x = vp.X * 0.5 - x - vp.X * 0.5
                    y = vp.Y * 0.5 - y - vp.Y * 0.5
                    local dx = x - vp.X * 0.5
                    local dy = y - vp.Y * 0.5
                    local m = math.max(math.abs(dx), math.abs(dy))
                    if m > 0.001 then
                        local sc = math.max(vp.X, vp.Y) / m
                        x = vp.X * 0.5 + dx * sc
                        y = vp.Y * 0.5 + dy * sc
                    end
                end
                local fx = math.clamp(x, 6, vp.X - 6)
                local fy = math.clamp(y, 6, vp.Y - 6)
                local dx = fx - cx
                local dy = fy - cy
                local len = math.sqrt(dx * dx + dy * dy)
                if len >= 2 then
                    line.Size = UDim2.fromOffset(math.floor(len), 2)
                    line.Position = UDim2.fromOffset((cx + fx) * 0.5, (cy + fy) * 0.5)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.BackgroundColor3 = espColor
                    line.BackgroundTransparency = 0
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end
    end
end

function startPrintedTracers()
    PrintedTracer.enabled = true
    _tracerEnsureGui()
    if PrintedTracer.conn then pcall(function() PrintedTracer.conn:Disconnect() end) end
    PrintedTracer.conn = RunService.RenderStepped:Connect(function()
        pcall(_tracerStep)
    end)
end

function stopPrintedTracers()
    PrintedTracer.enabled = false
    if PrintedTracer.conn then pcall(function() PrintedTracer.conn:Disconnect() end) PrintedTracer.conn = nil end
    _tracerClearAll()
end

Players.PlayerRemoving:Connect(_tracerClear)

-- ============================================================
-- ANTI-LAG
-- ============================================================
local antiLagSavedBrightness, antiLagSavedClock, antiLagSavedOutdoor = nil, nil, nil

local function applyAntiLagDerender(obj)
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _, t in ipairs(obj:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end
        end
    end)
end

function enableAntiLag()
    removeAccessoriesEnabled = true
    antiLagEnabled = true
    if not antiLagSavedBrightness then antiLagSavedBrightness = Lighting.Brightness end
    antiLagSavedClock = antiLagSavedClock or Lighting.ClockTime
    antiLagSavedOutdoor = antiLagSavedOutdoor or Lighting.OutdoorAmbient
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, c in pairs(Lighting:GetChildren()) do
        pcall(function()
            if c:IsA("BlurEffect") or c:IsA("SunRaysEffect") or c:IsA("ColorCorrectionEffect")
                or c:IsA("BloomEffect") or c:IsA("DepthOfFieldEffect") then
                c.Enabled = false
            end
        end)
    end
    for _, d in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(d) end
    if antiLagDescConn then antiLagDescConn:Disconnect() end
    antiLagDescConn = workspace.DescendantAdded:Connect(function(d)
        if removeAccessoriesEnabled then applyAntiLagDerender(d) end
    end)
end

function disableAntiLag()
    removeAccessoriesEnabled = false
    antiLagEnabled = false
    if antiLagDescConn then antiLagDescConn:Disconnect() antiLagDescConn = nil end
    pcall(function()
        if antiLagSavedBrightness then Lighting.Brightness = antiLagSavedBrightness end
        if antiLagSavedClock then Lighting.ClockTime = antiLagSavedClock end
        if antiLagSavedOutdoor then Lighting.OutdoorAmbient = antiLagSavedOutdoor end
        Lighting.ExposureCompensation = 0
    end)
end

-- ============================================================
-- STRETCH REZ / FOV
-- ============================================================
local stretchRezConn2 = nil

function enableStretchRez()
    stretchRezEnabled = true
    if not workspace.CurrentCamera then return end
    if stretchRezConn then pcall(function() stretchRezConn:Disconnect() end) stretchRezConn = nil end
    if stretchRezConn2 then pcall(function() stretchRezConn2:Disconnect() end) stretchRezConn2 = nil end
    stretchRezConn2 = RunService.RenderStepped:Connect(function()
        if not stretchRezEnabled then return end
        if printedFOVEnabled then return end
        local cam = workspace.CurrentCamera
        if cam then pcall(function() cam.FieldOfView = stretchFOV or 120 end) end
    end)
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not stretchRezEnabled then
            if stretchRezConn then stretchRezConn:Disconnect() stretchRezConn = nil end
            return
        end
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.7, 0, 0, 0, 1)
        end
    end)
end

function disableStretchRez()
    stretchRezEnabled = false
    if stretchRezConn then pcall(function() stretchRezConn:Disconnect() end) stretchRezConn = nil end
    if stretchRezConn2 then pcall(function() stretchRezConn2:Disconnect() end) stretchRezConn2 = nil end
    pcall(function()
        local cam = workspace.CurrentCamera
        if printedFOVEnabled then
            applyPrintedFOV()
        elseif cam then
            cam.FieldOfView = 70
        end
    end)
end

function applyPrintedFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if printedFOVEnabled then
        cam.FieldOfView = math.clamp(tonumber(printedFOVValue) or 70, 30, 120)
    end
end

local printedFOVConn = nil

function startPrintedFOV()
    printedFOVEnabled = true
    pcall(function()
        if printedFOVConn then
            if typeof(printedFOVConn) == "RBXScriptConnection" then printedFOVConn:Disconnect() end
            printedFOVConn = nil
        end
        pcall(function() RunService:UnbindFromRenderStep("PrintedFOV") end)
    end)
    local function upd()
        if not printedFOVEnabled then return end
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = math.clamp(tonumber(printedFOVValue) or 70, 30, 120) end
    end
    pcall(function() RunService:BindToRenderStep("PrintedFOV", Enum.RenderPriority.Camera.Value + 1, upd) end)
    printedFOVConn = RunService.RenderStepped:Connect(upd)
    applyPrintedFOV()
end

function stopPrintedFOV()
    printedFOVEnabled = false
    pcall(function() RunService:UnbindFromRenderStep("PrintedFOV") end)
    if printedFOVConn then pcall(function() printedFOVConn:Disconnect() end) printedFOVConn = nil end
end

-- ============================================================
-- ANIMATION PACKS
-- ============================================================
local animPacks = {
    ["Hit Harder"] = { WalkAnim = 707897309, RunAnim = 707861613, JumpAnim = 116936326516985, FallAnim = 116936326516985, SwimIdle = 116936326516985, Swim = 116936326516985, Animation1 = 133806214992291, Animation2 = 94970088341563, ClimbAnim = 116936326516985 },
    ["Try Hard"] = { WalkAnim = 707897309, RunAnim = 707861613, JumpAnim = 116936326516985, FallAnim = 116936326516985, SwimIdle = 116936326516985, Swim = 116936326516985, Animation1 = 133806214992291, Animation2 = 94970088341563, ClimbAnim = 116936326516985 },
    Zombie = { WalkAnim = 616168032, RunAnim = 616163682, JumpAnim = 616161997, FallAnim = 616157476, SwimIdle = 616166655, Swim = 616165109, ClimbAnim = 616156119, Animation1 = 616160636, Animation2 = 616160636 },
    Ninja = { WalkAnim = 656121766, RunAnim = 656118852, JumpAnim = 656117878, FallAnim = 656114359, ClimbAnim = 656114359, Animation1 = 656117400, Animation2 = 656117400 },
    Knight = { WalkAnim = 657552124, RunAnim = 657564596, JumpAnim = 658409194, FallAnim = 658360781, ClimbAnim = 658360781, Animation1 = 657595757, Animation2 = 657595757 },
    Elder = { WalkAnim = 845397739, RunAnim = 845386501, JumpAnim = 845398858, FallAnim = 845397673, ClimbAnim = 845392038, Animation1 = 845392038, Animation2 = 845392038 },
    Levitate = { WalkAnim = 616013216, RunAnim = 616013216, JumpAnim = 616008936, FallAnim = 616003713, ClimbAnim = 616003713, Animation1 = 616008936, Animation2 = 616008936 },
    Astronaut = { WalkAnim = 891636393, RunAnim = 891627522, JumpAnim = 891627522, FallAnim = 891617961, ClimbAnim = 891609353, Animation1 = 891621366, Animation2 = 891621366 },
    Pirate = { WalkAnim = 750785693, RunAnim = 750783738, JumpAnim = 750783738, FallAnim = 750780242, ClimbAnim = 750779899, Animation1 = 750781874, Animation2 = 750781874 },
    Toy = { WalkAnim = 782843345, RunAnim = 782842708, JumpAnim = 782847020, FallAnim = 782846423, ClimbAnim = 782843869, Animation1 = 782841498, Animation2 = 782841498 },
    Vampire = { WalkAnim = 1083473930, RunAnim = 1083473930, JumpAnim = 1083443587, FallAnim = 1083443587, ClimbAnim = 1083439238, Animation1 = 1083445855, Animation2 = 1083445855 },
    Werewolf = { WalkAnim = 1083178339, RunAnim = 1083178339, JumpAnim = 1083218792, FallAnim = 1083189019, ClimbAnim = 1083182000, Animation1 = 1083195517, Animation2 = 1083195517 },
    Rthro = { WalkAnim = 2510202577, RunAnim = 2510202577, JumpAnim = 2510197830, FallAnim = 2510195892, ClimbAnim = 2510192778, Animation1 = 2510196951, Animation2 = 2510196951 },
    Robot = { WalkAnim = 616136790, RunAnim = 616138447, JumpAnim = 616133594, FallAnim = 616134815, ClimbAnim = 616133594, Animation1 = 616136790, Animation2 = 616136790 },
    Cartoony = { WalkAnim = 742638842, RunAnim = 742640026, JumpAnim = 742637942, FallAnim = 742637151, ClimbAnim = 742636889, Animation1 = 742637544, Animation2 = 742637544 },
    SuperHero = { WalkAnim = 616117103, RunAnim = 616117103, JumpAnim = 616111295, FallAnim = 616108001, ClimbAnim = 616104706, Animation1 = 616110783, Animation2 = 616110783 },
    Bubbly = { WalkAnim = 910034870, RunAnim = 910025107, JumpAnim = 910030921, FallAnim = 910025007, ClimbAnim = 910028807, Animation1 = 910029840, Animation2 = 910029840 },
    Mage = { WalkAnim = 707876397, RunAnim = 707861613, JumpAnim = 707853694, FallAnim = 707855813, ClimbAnim = 707858698, Animation1 = 707855380, Animation2 = 707855380 },
    OldSchool = { WalkAnim = 531992217, RunAnim = 531992217, JumpAnim = 531984432, FallAnim = 531983976, ClimbAnim = 531981469, Animation1 = 531982996, Animation2 = 531982996 },
    Stylish = { WalkAnim = 616146177, RunAnim = 616140816, JumpAnim = 616139451, FallAnim = 616134815, ClimbAnim = 616133594, Animation1 = 616136790, Animation2 = 616136790 },
}

local function setAnimId(obj, id)
    if not obj or not id then return end
    pcall(function()
        if obj:IsA("Animation") then
            obj.AnimationId = "rbxassetid://" .. tostring(id)
        elseif obj:FindFirstChildOfClass("Animation") then
            obj:FindFirstChildOfClass("Animation").AnimationId = "rbxassetid://" .. tostring(id)
        end
    end)
end

local function pickPack(t, ...)
    for _, k in ipairs({ ... }) do
        if t[k] then return t[k] end
    end
    return nil
end

function applyAnimPack(name)
    local pack = animPacks[name]
    if not pack then return false end
    local char = localPlayer.Character
    if not char then return false end
    local animate = char:FindFirstChild("Animate")
    if not animate then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop(0) end)
        end
    end
    local function ensure(parent, nm)
        if not parent then return nil end
        local a = parent:FindFirstChild(nm)
        if not a then
            a = Instance.new("Animation")
            a.Name = nm
            a.Parent = parent
        end
        return a
    end
    setAnimId(ensure(animate:FindFirstChild("walk"), "WalkAnim") or animate:FindFirstChild("walk"), pickPack(pack, "WalkAnim", "Walk"))
    setAnimId(ensure(animate:FindFirstChild("run"), "RunAnim") or animate:FindFirstChild("run"), pickPack(pack, "RunAnim", "Run"))
    setAnimId(ensure(animate:FindFirstChild("jump"), "JumpAnim") or animate:FindFirstChild("jump"), pickPack(pack, "JumpAnim", "Jump"))
    setAnimId(ensure(animate:FindFirstChild("fall"), "FallAnim") or animate:FindFirstChild("fall"), pickPack(pack, "FallAnim", "Fall"))
    setAnimId(ensure(animate:FindFirstChild("climb"), "ClimbAnim") or animate:FindFirstChild("climb"), pickPack(pack, "ClimbAnim", "Climb"))
    setAnimId(ensure(animate:FindFirstChild("swim"), "Swim") or animate:FindFirstChild("swim"), pickPack(pack, "Swim"))
    setAnimId(ensure(animate:FindFirstChild("swimidle"), "SwimIdle") or animate:FindFirstChild("swimidle"), pickPack(pack, "SwimIdle") or pickPack(pack, "Swim"))
    local idle = animate:FindFirstChild("idle")
    if idle then
        local a1 = pickPack(pack, "Animation1") or (pack.Idle and pack.Idle[1])
        local a2 = pickPack(pack, "Animation2") or (pack.Idle and pack.Idle[2]) or a1
        setAnimId(idle:FindFirstChild("Animation1"), a1)
        setAnimId(idle:FindFirstChild("Animation2"), a2)
    end
    animate.Disabled = true
    task.wait(0.05)
    animate.Disabled = false
    animPack = name
    return true
end

-- ============================================================
-- CHARTER (Headless / Korblox)
-- ============================================================
function applyHeadlessToChar(char, enabled)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if enabled then
        head.Transparency = 1
        for _, c in ipairs(head:GetChildren()) do
            if c:IsA("Decal") or c:IsA("Texture") then c.Transparency = 1 end
        end
        local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
        if face then face.Transparency = 1 end
    else
        head.Transparency = 0
        for _, c in ipairs(head:GetChildren()) do
            if c:IsA("Decal") or c:IsA("Texture") then c.Transparency = 0 end
        end
    end
end

function applyKorbloxToChar(parent, enabled)
    if not parent then return end
    local hum = parent:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if enabled then
        if hum.RigType == Enum.HumanoidRigType.R6 then
            local rl = parent:FindFirstChild("Right Leg")
            if rl then
                for _, c in ipairs(rl:GetChildren()) do
                    if c:IsA("SpecialMesh") or c:IsA("CharacterMesh") then c:Destroy() end
                end
                rl.Color = Color3.fromRGB(64, 64, 64)
                local sm = Instance.new("SpecialMesh")
                sm.MeshType = Enum.MeshType.FileMesh
                sm.MeshId = "rbxassetid://101851696"
                sm.TextureId = "rbxassetid://101851254"
                sm.Scale = Vector3.new(1, 1, 1)
                sm.Name = "KorbloxMesh"
                sm.Parent = rl
            end
        elseif hum.RigType == Enum.HumanoidRigType.R15 then
            local rul = parent:FindFirstChild("RightUpperLeg")
            if rul then
                rul.Transparency = 1
                local rll = parent:FindFirstChild("RightLowerLeg")
                local rf = parent:FindFirstChild("RightFoot")
                if rll then rll.Transparency = 1 end
                if rf then rf.Transparency = 1 end
                local old = parent:FindFirstChild("KorbloxLeg")
                if old then old:Destroy() end
                local part = Instance.new("Part")
                part.Name = "KorbloxLeg"
                part.Size = Vector3.new(1, 2, 1)
                part.Anchored = false
                part.CanCollide = false
                part.Color = Color3.fromRGB(64, 64, 64)
                part.Parent = parent
                local sm = Instance.new("SpecialMesh")
                sm.MeshType = Enum.MeshType.FileMesh
                sm.MeshId = "rbxassetid://101851696"
                sm.TextureId = "rbxassetid://101851254"
                sm.Scale = Vector3.new(1, 1, 1)
                sm.Name = "KorbloxMesh"
                sm.Parent = part
                local weld = Instance.new("Weld")
                weld.Part0 = rul
                weld.Part1 = part
                weld.C0 = CFrame.new(0, -0.8, 0)
                weld.Name = "KorbloxWeld"
                weld.Parent = part
            end
        end
    else
        if hum.RigType == Enum.HumanoidRigType.R6 then
            local rl = parent:FindFirstChild("Right Leg")
            if rl then
                for _, c in ipairs(rl:GetChildren()) do
                    if c:IsA("SpecialMesh") and c.Name == "KorbloxMesh" then c:Destroy() end
                end
            end
        elseif hum.RigType == Enum.HumanoidRigType.R16 then
            -- no-op
        elseif hum.RigType == Enum.HumanoidRigType.R15 then
            local rul = parent:FindFirstChild("RightUpperLeg")
            if rul then
                rul.Transparency = 0
                local rll = parent:FindFirstChild("RightLowerLeg")
                local rf = parent:FindFirstChild("RightFoot")
                if rll then rll.Transparency = 0 end
                if rf then rf.Transparency = 0 end
                local old = parent:FindFirstChild("KorbloxLeg")
                if old then old:Destroy() end
            end
        end
    end
end

function applyCharterToChar(char)
    if not char then return end
    applyHeadlessToChar(char, headless)
    applyKorbloxToChar(char, korblox)
end

localPlayer.CharacterAdded:Connect(function(c)
    task.defer(function()
        task.wait(0.6)
        pcall(applyCharterToChar, c)
        if animPackEnabled then pcall(applyAnimPack, animPack) end
    end)
end)

-- ============================================================
-- ANTI-DIE
-- ============================================================
local _adSafeCF = nil
local _adLastSafe = 0
local _adRestorePending = false

local function antiDieSetHealth(hum)
    if not hum or not hum.Parent then return end
    local max = hum.MaxHealth or 100
    if max <= 0 then max = 100 end
    pcall(function()
        if hum.MaxHealth < max then hum.MaxHealth = max end
        hum.Health = max
    end)
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(hum, "Health", max)
            sethiddenproperty(hum, "MaxHealth", max)
        end
    end)
    PrintedAntiDie.invincibleUntil = tick() + (PrintedAntiDie.config.invincibilityFrames or 1.5)
    pcall(function()
        local parent = hum.Parent
        if not parent then return end
        for _, d in ipairs(parent:GetDescendants()) do
            if d:IsA("NumberValue") or d:IsA("IntValue") or d:IsA("DoubleConstrainedValue") then
                local n = d.Name:lower()
                if n:find("health") or n:find("hp") or n:find("life") then
                    pcall(function() d.Value = max end)
                end
            end
            if d:IsA("BoolValue") then
                local n = d.Name:lower()
                if n:find("dead") or n:find("died") or n:find("knocked") then
                    pcall(function() d.Value = false end)
                end
            end
        end
    end)
end

local function antiDieRevive()
    if not PrintedAntiDie.config.autoRevive then return end
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum then return end
    antiDieSetHealth(hum)
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum.BreakJointsOnDeath = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        hum:ChangeState(Enum.HumanoidStateType.Running)
        hum.PlatformStand = false
        hum.Sit = false
    end)
    if hrp then
        pcall(function()
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 0.35, math.max(vel.Y, -8) * 0.35, vel.Z * 0.35)
            hrp.AssemblyAngularVelocity = hrp.AssemblyAngularVelocity * 0
        end)
    end
end

local function antiDieHarden(hum)
    if not hum then return end
    pcall(function()
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end)
end

local function _adTrackSafe()
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if hum.Health <= 0 then return end
    if hum:GetState() == Enum.HumanoidStateType.Freefall and hrp.Position.Y < -80 then return end
    if hrp.Position.Y < -50 then return end
    if tick() - _adLastSafe < 0.2 then return end
    _adLastSafe = tick()
    _adSafeCF = hrp.CFrame
end

local function _adVoidGuard(hrp)
    if not hrp then return end
    if hrp.Position.Y > -120 then return end
    if not _adSafeCF then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = _adSafeCF + Vector3.new(0, 3, 0)
    end)
end

function startAntiDie()
    antiDieEnabled = true
    PrintedAntiDie.enabled = true
    if PrintedAntiDie.loop then PrintedAntiDie.loop:Disconnect() PrintedAntiDie.loop = nil end
    if PrintedAntiDie.stepLoop then pcall(function() PrintedAntiDie.stepLoop:Disconnect() end) PrintedAntiDie.stepLoop = nil end
    if PrintedAntiDie.healthConn then PrintedAntiDie.healthConn:Disconnect() PrintedAntiDie.healthConn = nil end
    if PrintedAntiDie.diedConn then pcall(function() PrintedAntiDie.diedConn:Disconnect() end) PrintedAntiDie.diedConn = nil end
    if PrintedAntiDie.removeConn then pcall(function() PrintedAntiDie.removeConn:Disconnect() end) PrintedAntiDie.removeConn = nil end

    local lastHarden = 0
    PrintedAntiDie.loop = RunService.Heartbeat:Connect(function()
        if not PrintedAntiDie.enabled then return end
        local char = localPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum then return end
            if tick() - lastHarden > 0.5 then
                lastHarden = tick()
                antiDieHarden(hum)
            end
            _adVoidGuard(hrp)
            if hum.Health <= 0 then
                antiDieRevive()
            else
                _adTrackSafe()
                if hum.Health < (hum.MaxHealth or 100) then antiDieSetHealth(hum) end
                if tick() < (PrintedAntiDie.invincibleUntil or 0) then
                    if hum.Health < (hum.MaxHealth or 100) then hum.Health = hum.MaxHealth or 100 end
                end
            end
            return
        end
    end)

    PrintedAntiDie.stepLoop = RunService.Stepped:Connect(function()
        if not PrintedAntiDie.enabled then return end
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum.Health < (hum.MaxHealth or 100) then antiDieSetHealth(hum) end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.Physics then
            antiDieHarden(hum)
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                hum:ChangeState(Enum.HumanoidStateType.Running)
                hum.PlatformStand = false
            end)
        end
    end)

    local function bindChar(c)
        if PrintedAntiDie.healthConn then PrintedAntiDie.healthConn:Disconnect() PrintedAntiDie.healthConn = nil end
        if PrintedAntiDie.diedConn then pcall(function() PrintedAntiDie.diedConn:Disconnect() end) PrintedAntiDie.diedConn = nil end
        if PrintedAntiDie.removeConn then pcall(function() PrintedAntiDie.removeConn:Disconnect() end) PrintedAntiDie.removeConn = nil end
        local hum = c and c:FindFirstChildOfClass("Humanoid") or c and c:WaitForChild("Humanoid", 5)
        if not hum then return end
        antiDieHarden(hum)
        PrintedAntiDie.healthConn = hum.HealthChanged:Connect(function(h)
            if not PrintedAntiDie.enabled then return end
            if h < (hum.MaxHealth or 100) then antiDieSetHealth(hum) end
            if h <= 0 then antiDieRevive() task.defer(antiDieRevive) end
        end)
        PrintedAntiDie.diedConn = hum.Died:Connect(function()
            if not PrintedAntiDie.enabled then return end
            _adRestorePending = true
            antiDieRevive()
            task.defer(antiDieRevive)
        end)
        PrintedAntiDie.removeConn = c.AncestryChanged:Connect(function(_, parent)
            if not PrintedAntiDie.enabled then return end
            if parent == nil then _adRestorePending = true end
        end)
        antiDieSetHealth(hum)
    end

    if localPlayer.Character then bindChar(localPlayer.Character) end
    if PrintedAntiDie.charConn then PrintedAntiDie.charConn:Disconnect() end
    PrintedAntiDie.charConn = localPlayer.CharacterAdded:Connect(function(c)
        if not PrintedAntiDie.enabled then return end
        task.wait(0.03)
        bindChar(c)
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            antiDieSetHealth(hum)
            antiDieHarden(hum)
        end
        if _adRestorePending and _adSafeCF then
            _adRestorePending = false
            local hrp = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                for i = 1, 6 do
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.CFrame = _adSafeCF + Vector3.new(0, 3, 0)
                    end)
                    task.wait(0.08)
                end
            end
        else
            _adRestorePending = false
        end
    end)
end

function stopAntiDie()
    antiDieEnabled = false
    PrintedAntiDie.enabled = false
    if PrintedAntiDie.loop then PrintedAntiDie.loop:Disconnect() PrintedAntiDie.loop = nil end
    if PrintedAntiDie.stepLoop then pcall(function() PrintedAntiDie.stepLoop:Disconnect() end) PrintedAntiDie.stepLoop = nil end
    if PrintedAntiDie.healthConn then PrintedAntiDie.healthConn:Disconnect() PrintedAntiDie.healthConn = nil end
    if PrintedAntiDie.diedConn then pcall(function() PrintedAntiDie.diedConn:Disconnect() end) PrintedAntiDie.diedConn = nil end
    if PrintedAntiDie.removeConn then pcall(function() PrintedAntiDie.removeConn:Disconnect() end) PrintedAntiDie.removeConn = nil end
    _adRestorePending = false
end

-- ============================================================
-- DESYNC
-- ============================================================
local function desyncFindHidden()
    local g = getgenv and getgenv() or _G
    for _, n in ipairs({ "sethiddenproperty", "set_hidden_property", "sethiddenprop", "set_hidden_prop" }) do
        local f = rawget(g, n)
        if type(f) == "function" then return f end
    end
    return nil
end

local function desyncFindGetHidden()
    local g = getgenv and getgenv() or _G
    for _, n in ipairs({ "gethiddenproperty", "get_hidden_property", "gethiddenprop", "get_hidden_prop" }) do
        local f = rawget(g, n)
        if type(f) == "function" then return f end
    end
    return nil
end

local function desyncSet(obj, prop, val)
    if not obj then return false end
    local fn = desyncFindHidden()
    if fn then if pcall(fn, obj, prop, val) then return true end end
    return pcall(function() obj[prop] = val end)
end

local function desyncGet(obj, prop)
    if not obj then return false, nil end
    local fn = desyncFindGetHidden()
    if fn then
        local ok, res = pcall(fn, obj, prop)
        if ok then return true, res end
    end
    local ok, res = pcall(function() return obj[prop] end)
    return ok, res
end

local function isBasePart(o)
    if not o then return false end
    local ok, r = pcall(function() return o:IsA("BasePart") end)
    return ok and r == true
end

local function desyncDestroyFake()
    local f = PrintedDesync.fakeRoot
    PrintedDesync.fakeRoot = nil
    if f then pcall(function() f:Destroy() end) end
end

local function desyncRestoreRepRoot()
    local r = PrintedDesync.repRootOwner
    if isBasePart(r) then desyncSet(r, "PhysicsRepRootPart", r) end
    PrintedDesync.repRootOwner = nil
end

local function desyncCreatePart(ref)
    desyncDestroyFake()
    local p = Instance.new("Part")
    p.Name = PrintedDesync.FAKE_ROOT_NAME
    p.Size = Vector3.new(2, 2, 1)
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Transparency = 1
    p.CFrame = CFrame.new(0, PrintedDesync.FAKE_ROOT_Y, 0)
    p.AssemblyLinearVelocity = PrintedDesync.FAKE_ROOT_VELOCITY
    p.Parent = workspace
    pcall(function()
        local pos = ref.Position
        p.CFrame = CFrame.new(pos.X, PrintedDesync.FAKE_ROOT_Y, pos.Z)
    end)
    PrintedDesync.fakeRoot = p
    return p
end

local function desyncSetRepRoot(owner, rep)
    if not isBasePart(owner) or not isBasePart(rep) then return false end
    desyncSet(owner, "PhysicsRepRootPart", owner)
    PrintedDesync.repRootOwner = owner
    return desyncSet(owner, "PhysicsRepRootPart", rep)
end

local function desyncStep()
    if not PrintedDesync.alive or not PrintedDesync.enabled then return end
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not isBasePart(hrp) then return end
    local fake = PrintedDesync.fakeRoot
    if not isBasePart(fake) or not fake.Parent then
        local p = desyncCreatePart(hrp)
        desyncSetRepRoot(hrp, p)
        return
    end
    pcall(function()
        local pos = hrp.Position
        local fpos = fake.Position
        local moved = math.abs(pos.X - fpos.X) > 0.01 or math.abs(pos.Z - fpos.Z) > 0.01
        if not moved then moved = math.abs(fpos.Y - PrintedDesync.FAKE_ROOT_Y) > 0.1 end
        if moved then fake.CFrame = CFrame.new(pos.X, PrintedDesync.FAKE_ROOT_Y, pos.Z) end
        fake.Anchored = true
        fake.AssemblyLinearVelocity = PrintedDesync.FAKE_ROOT_VELOCITY
    end)
    local ok, cur = desyncGet(hrp, "PhysicsRepRootPart")
    if not ok or cur ~= fake then desyncSet(hrp, "PhysicsRepRootPart", fake) end
end

local function desyncStopStep()
    if PrintedDesync.stepConnection then
        pcall(function() PrintedDesync.stepConnection:Disconnect() end)
        PrintedDesync.stepConnection = nil
    end
end

local function desyncStartStep()
    desyncStopStep()
    PrintedDesync.stepConnection = RunService.Stepped:Connect(desyncStep)
end

local function desyncStopAntiBat()
    if PrintedDesync.antiBatConn then
        pcall(function() PrintedDesync.antiBatConn:Disconnect() end)
        PrintedDesync.antiBatConn = nil
    end
    PrintedDesync.lastSafeCFrame = nil
end

local function desyncStartAntiBat()
    desyncStopAntiBat()
    PrintedDesync.lastSafeCFrame = nil
    PrintedDesync.lastCheckTime = 0
    PrintedDesync.antiBatConn = RunService.Heartbeat:Connect(function()
        if not PrintedDesync.enabled or not PrintedDesync.alive then return end
        local char = localPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        local now = tick()
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude < 70 then
            PrintedDesync.lastSafeCFrame = hrp.CFrame
            PrintedDesync.lastCheckTime = now
        elseif vel.Magnitude > 110 and PrintedDesync.lastSafeCFrame and now - PrintedDesync.lastCheckTime < 0.5 then
            hrp.CFrame = PrintedDesync.lastSafeCFrame * CFrame.new(0, 0.1, 0)
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                local tool = player.Character:FindFirstChildWhichIsA("Tool")
                if phrp and tool and tool.Name:lower():find("bat") then
                    if (hrp.Position - phrp.Position).Magnitude < PrintedDesync.ANTI_BAT_RANGE then
                        local a = math.rad(tick() * 500)
                        hrp.CFrame = hrp.CFrame * CFrame.new(math.sin(a) * 3, 0, math.cos(a) * 3)
                    end
                end
            end
        end
    end)
end

function startPrintedDesync()
    PrintedDesync.enabled = true
    desyncSet(localPlayer, "MaximumSimulationRadius", math.huge)
    desyncSet(localPlayer, "SimulationRadius", math.huge)
    pcall(function() settings().Network.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled end)
    pcall(function()
        local p = settings().Physics
        p.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        p.AllowSleep = false
    end)
    pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
    local char = localPlayer.Character
    char = char and char:FindFirstChild("HumanoidRootPart")
    if char then
        local p = desyncCreatePart(char)
        desyncSetRepRoot(char, p)
        desyncStartStep()
    end
    desyncStartAntiBat()
end

function stopPrintedDesync()
    PrintedDesync.enabled = false
    desyncStopStep()
    desyncStopAntiBat()
    desyncRestoreRepRoot()
    desyncDestroyFake()
end

-- ============================================================
-- TP BAT
-- ============================================================
local function getBatTool()
    local char = localPlayer.Character
    if not char then return nil end
    local b = char:FindFirstChild("Bat")
    if b then return b end
    local bp = localPlayer:FindFirstChild("Backpack")
    if bp then
        local b2 = bp:FindFirstChild("Bat")
        if b2 then b2.Parent = char return b2 end
    end
    return nil
end

function tryHitBatG12()
    if tpBatHittingCD then return end
    tpBatHittingCD = true
    pcall(function()
        local b = getBatTool()
        if b then
            b:Activate()
            local re = b:FindFirstChildWhichIsA("RemoteEvent")
            if re then re:FireServer() end
        end
    end)
    task.delay(0.08, function() tpBatHittingCD = false end)
end

local function getClosestPlayerG12()
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    local closest, minD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            if phrp then
                local d = (hrp.Position - phrp.Position).Magnitude
                if d < minD then minD = d closest = p end
            end
        end
    end
    return closest, minD
end

RunService.Heartbeat:Connect(function()
    if not tpBatEnabled then return end
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    pcall(function()
        local tool = char:FindFirstChildOfClass("Tool")
        local noBat = not tool
        if not noBat then
            local n = tostring(tool.Name):lower()
            noBat = not (n:find("bat") or n:find("slap"))
        end
        if noBat then
            local b = getBatTool()
            if not b then
                local bp = localPlayer:FindFirstChild("Backpack") or localPlayer:FindFirstChildOfClass("Backpack")
                for _, name in ipairs(batTools) do
                    b = char:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
                    if b then break end
                end
                if not b and bp then
                    for _, c in ipairs(bp:GetChildren()) do
                        if c:IsA("Tool") then
                            local n = c.Name:lower()
                            if n:find("bat") or n:find("slap") then b = c break end
                        end
                    end
                end
            end
            if b and b.Parent ~= char then hum:EquipTool(b) end
        end
    end)
    pcall(function()
        for _, c in ipairs(workspace:GetChildren()) do
            if c.Name == "FallDamage" or (c:IsA("Model") and c.Name:find("Fall")) then
                c:Destroy()
            end
        end
    end)
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(hrp, "PhysicsRepRootPart", hrp)
            sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(localPlayer, "MaximumSimulationRadius", math.huge)
        end
    end)
    local target = getClosestPlayerG12()
    if target and target.Character then
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        if thrp then
            if sethiddenproperty then
                pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", thrp) end)
            end
            local dest = thrp.Position + Vector3.new(0, 3.5, 0)
            if (hrp.Position - dest).Magnitude > 6 then
                hrp.CFrame = CFrame.new(dest)
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            if tpBatCamShake then
                local cam = workspace.CurrentCamera
                if cam then pcall(function() cam.CFrame = CFrame.new(cam.CFrame.Position, thrp.Position) end) end
            end
            if tpBatAutoSwing ~= false then tryHitBatG12() end
        end
    end
end)

-- ============================================================
-- SPEED LOOP
-- ============================================================
local vector5 = Vector3.new(0, 0, 0)
local moveKeys = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
}

RunService.PreSimulation:Connect(function()
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if isRagdollState(hum) then
        vector5 = Vector3.new(0, 0, 0)
        return
    end
    if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then
        local md = hum.MoveDirection
        local sp = getActiveMoveSpeed()
        if md.Magnitude > 0.05 then
            vector5 = md
            applyVelocitySpeed(hrp, hum, sp, md)
        elseif antiRagdollEnabled and vector5.Magnitude > 0.05 then
            local pressed = false
            for k in pairs(moveKeys) do
                if UserInputService:IsKeyDown(k) then pressed = true break end
            end
            if pressed then applyVelocitySpeed(hrp, hum, sp, vector5)
            else applyVelocitySpeed(hrp, hum, sp, Vector3.zero) end
        else
            applyVelocitySpeed(hrp, hum, sp, Vector3.zero)
        end
    end
    if speedLabel then
        local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
        speedLabel.Text = string.format("Speed: %.1f", Vector3.new(vel.X, 0, vel.Z).Magnitude)
    end
end)

-- ============================================================
-- AUTO CARRY MONITOR
-- ============================================================
local acFlag21 = false
local acStr8 = nil
local acN33 = 0
local acFlag22 = false

local function acApply()
    if refreshSpeedModeLabel then pcall(refreshSpeedModeLabel) end
end

local function acEnable(mode)
    if acFlag21 then return end
    if laggerToggled and laggerPhase == 2 then acStr8 = "LaggerCarry"
    elseif laggerToggled then acStr8 = "Lagger"
    elseif speedMode then acStr8 = "Carry"
    else acStr8 = "Normal" end
    acFlag21 = true
    acN33 = tick() + 0.75
    if acStr8 == "Lagger" or acStr8 == "LaggerCarry" then
        laggerToggled = true
        laggerPhase = 1
        speedMode = false
    else
        laggerToggled = false
        laggerPhase = 0
        speedMode = true
    end
    acApply()
end

local function acDisable()
    if not acFlag21 then return end
    acFlag21 = false
    acN33 = 0
    local prev = acStr8
    acStr8 = nil
    if prev == "Lagger" then
        laggerToggled = true laggerPhase = 1 speedMode = false
    elseif prev == "LaggerCarry" then
        laggerToggled = true laggerPhase = 2 speedMode = false
    elseif prev == "Carry" then
        laggerToggled = false laggerPhase = 0 speedMode = true
    else
        laggerToggled = false laggerPhase = 0 speedMode = false
    end
    acApply()
end

local function holdingBrainrotFromChar(char)
    if not char then return false end
    for _, n in ipairs({ "Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab" }) do
        local v = char:FindFirstChild(n, true)
        if v then
            if v:IsA("BoolValue") and v.Value then return true end
            if v:IsA("ObjectValue") and v.Value then return true end
            if v:IsA("StringValue") and v.Value ~= "" then return true end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
            if child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then return true end
        elseif child:IsA("Tool") then
            local n = child.Name:lower()
            if not (n:find("bat") or n:find("slap") or n:find("medusa")) then return true end
        end
    end
    return false
end

RunService.RenderStepped:Connect(function()
    if autoCarryEnabled ~= true then
        if acFlag21 then acDisable() end
        acFlag22 = false
        return
    end
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then
        if acFlag21 then acDisable() end
        acFlag22 = false
        return
    end
    local st = hum:GetState()
    local ragdolled = st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
    local stealing = false
    pcall(function() stealing = localPlayer:GetAttribute("Stealing") == true end)
    if not stealing then
        pcall(function()
            local c = localPlayer.Character
            if c then stealing = c:GetAttribute("Stealing") == true end
        end)
    end
    local holding = holdingBrainrotFromChar(char)
    if stealing and not acFlag22 then
        acFlag22 = true
        acEnable()
    elseif not stealing then
        acFlag22 = false
    end
    if holding and not acFlag21 then acEnable() end
    if acFlag21 then
        if ragdolled or (tick() > acN33 and not holding and not stealing) then acDisable() end
    end
end)

-- ============================================================
-- INTRO MUSIC
-- ============================================================
INTRO_MUSIC_OPTIONS = {}
for i = 1, 10 do
    table.insert(INTRO_MUSIC_OPTIONS, { name = "Track " .. i })
end

function getIntroMusicName(idx)
    local n = INTRO_MUSIC_OPTIONS[idx or selectedIntroMusic]
    n = n and n.name
    if not n then n = "Track " .. tostring(idx or 1) end
    return n
end

stopIntroPreview = function()
    local s = _currentIntroSound
    _currentIntroSound = nil
    if s then
        pcall(function() s:Stop() end)
        pcall(function() s.Volume = 0 end)
        pcall(function() s:Destroy() end)
    end
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if pg then
            local m = pg:FindFirstChild("PrintedIntroMusic")
            if m then pcall(function() m:Destroy() end) end
        end
    end)
end

stopIntroPlayback = function()
    stopIntroPreview()
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if pg then
            local intro = pg:FindFirstChild("PrintedIntro")
            if intro then intro:Destroy() end
        end
        if gethui then
            local h = gethui()
            local intro = h and h:FindFirstChild("PrintedIntro")
            if intro then intro:Destroy() end
        end
    end)
end
_G.PrintedStopIntroMusic = stopIntroPlayback

_safeNotify = function(msg)
    if _G.PrintedSafeModeNotify then pcall(_G.PrintedSafeModeNotify, msg) end
end

local function createIntroSound(url)
    local u = url or (INTRO_MUSIC_LINKS and INTRO_MUSIC_LINKS[selectedIntroMusic or 1])
    if not u then return nil end
    local writef = writefile or (syn and syn.writefile)
    local getcustom = getcustomasset or getsynasset or (syn and syn.getcustomasset)
    local req = syn and syn.request or http and http.request or fluxus and fluxus.request or request or http_request
    local pg = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)
    if not pg then return nil end
    pcall(function()
        local m = pg:FindFirstChild("PrintedIntroMusic")
        if m then m:Destroy() end
    end)
    local s = Instance.new("Sound")
    s.Name = "PrintedIntroMusic"
    s.Volume = 3
    s.Parent = pg
    s.Looped = false
    s.PlayOnRemove = false
    _currentIntroSound = s
    local idx = tonumber(selectedIntroMusic) or 1
    task.spawn(function()
        local exts = { tostring(u):match("%.([%w]+)$") or "mp3", "mp3", "ogg", "wav" }
        local soundId = nil
        if type(req) == "function" and type(getcustom) == "function" and type(writef) == "function" then
            local ok, res = pcall(req, { Url = u, Method = "GET" })
            local body = ok and res and (res.Body or res.body)
            if type(body) == "string" and #body > 0 then
                for _, ext in ipairs(exts) do
                    local path = "printed_intro_" .. tostring(idx) .. "." .. ext
                    if pcall(writef, path, body) then
                        local ok2, id = pcall(getcustom, path)
                        if ok2 and type(id) == "string" and #id > 0 then soundId = id break end
                    end
                end
            end
        end
        if not soundId and type(getcustom) == "function" and type(writef) == "function" then
            local ok, res = pcall(function() return game:HttpGet(u) end)
            if ok and type(res) == "string" and #res > 500 then
                for _, ext in ipairs(exts) do
                    local path = "printed_intro_" .. tostring(idx) .. "." .. ext
                    if pcall(writef, path, res) then
                        local ok2, id = pcall(getcustom, path)
                        if ok2 and type(id) == "string" and #id > 0 then soundId = id break end
                    end
                end
            end
        end
        if not s.Parent then return end
        if not soundId then
            warn("[Printed] Intro audio could not be converted to a local asset: " .. tostring(u))
            return
        end
        s.SoundId = soundId
        pcall(function() ContentProvider:PreloadAsync({ s }) end)
        if s.Parent then pcall(function() s:Play() end) end
        task.wait(1)
        if s and s.Parent and not s.IsPlaying then pcall(function() s:Play() end) end
    end)
    task.delay(15, function()
        pcall(function()
            if s and s.Parent then s:Stop() s:Destroy() end
        end)
        if _currentIntroSound == s then _currentIntroSound = nil end
    end)
    return s
end

getIntroAsset = function(idx)
    return { audio = nil, video = INTRO_MUSIC_LINKS[tonumber(idx) or selectedIntroMusic or 1], path = "printed_intro_track.mp3" }
end

createIntroSound = function(idx)
    return createIntroSound(INTRO_MUSIC_LINKS[tonumber(idx) or selectedIntroMusic or 1])
end

previewIntroMusic = function(idx)
    task.spawn(function()
        pcall(function()
            stopIntroPreview()
            createIntroSound(INTRO_MUSIC_LINKS[tonumber(idx) or selectedIntroMusic or 1])
        end)
    end)
end

playIntroSequence = function(cb)
    stopIntroPlayback()
    task.spawn(function()
        local url = INTRO_MUSIC_LINKS[selectedIntroMusic or 1] or INTRO_MUSIC_LINKS[1]
        pcall(function() createIntroSound(url) end)
        local sg = Instance.new("ScreenGui")
        sg.Name = "PrintedIntro"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 100000
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local pg = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 5)
        local placed = false
        pcall(function() if gethui then sg.Parent = gethui() placed = true end end)
        if not placed then sg.Parent = pg end
        local start = tick()
        local function waitTo(t)
            local elapsed = tick() - start
            local remaining = t - elapsed
            if remaining > 0 then task.wait(remaining) end
        end
        local color = Color3.fromRGB(90, 150, 255)
        local bg = Instance.new("Frame", sg)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel = 0
        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 1
        frame.ZIndex = 2
        local line = Instance.new("Frame", sg)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Position = UDim2.new(0.5, 0, 0.48, 0)
        line.Size = UDim2.new(0.72, 0, 0, 2)
        line.BackgroundColor3 = color
        line.BackgroundTransparency = 1
        local title = Instance.new("TextLabel", sg)
        title.AnchorPoint = Vector2.new(0.5, 0.5)
        title.Position = UDim2.new(0.5, 0, 0.48, 0)
        title.Size = UDim2.new(0, 520, 0, 70)
        title.BackgroundTransparency = 1
        title.Text = "PRINTED"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 68
        title.TextColor3 = Color3.fromRGB(245, 248, 255)
        title.TextTransparency = 1
        title.TextStrokeColor3 = color
        title.TextStrokeTransparency = 1
        local sub = Instance.new("TextLabel", sg)
        sub.AnchorPoint = Vector2.new(0.5, 0)
        sub.Position = UDim2.new(0.5, 0, 0.48, 48)
        sub.Size = UDim2.new(0, 300, 0, 22)
        sub.BackgroundTransparency = 1
        sub.Text = "ZexHub"
        sub.Font = Enum.Font.GothamMedium
        sub.TextSize = 14
        sub.TextColor3 = Color3.fromRGB(180, 190, 255)
        sub.TextTransparency = 1
        local blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = Lighting
        TweenService:Create(blur, TweenInfo.new(0.3), { Size = 14 }):Play()
        TweenService:Create(bg, TweenInfo.new(0.3), { BackgroundTransparency = 0.08 }):Play()
        TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.35 }):Play()
        waitTo(0.3)
        TweenService:Create(title, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0, TextStrokeTransparency = 0.5 }):Play()
        TweenService:Create(line, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 200, 0, 2), BackgroundTransparency = 0 }):Play()
        task.wait(0.15)
        TweenService:Create(sub, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
        waitTo(2.1)
        TweenService:Create(title, TweenInfo.new(0.15), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
        TweenService:Create(sub, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(line, TweenInfo.new(0.3), { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2) }):Play()
        TweenService:Create(bg, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(frame, TweenInfo.new(0.45), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(blur, TweenInfo.new(0.4), { Size = 0 }):Play()
        waitTo(3.5)
        pcall(function() sg:Destroy() end)
        pcall(function() blur:Destroy() end)
        if cb then pcall(cb) end
    end)
end

-- ============================================================
-- MOBILE BUTTONS
-- ============================================================
function createMobilePanel()
    pcall(function()
        local toClean = { CoreGui, localPlayer:FindFirstChild("PlayerGui"), gethui and gethui() }
        for _, parent in ipairs(toClean) do
            if parent then
                for _, name in ipairs({ "PrintedMobileButtons", "PrintedMobileButtons2" }) do
                    local f = parent:FindFirstChild(name)
                    if f then f:Destroy() end
                end
            end
        end
    end)
    pcall(function()
        local g = CoreGui:FindFirstChild("PrintedMobileButtons")
        if g then g:Destroy() end
    end)
    pcall(function()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if pg then
            local g = pg:FindFirstChild("PrintedMobileButtons")
            if g then g:Destroy() end
        end
    end)

    v91 = nil
    v88 = nil
    mobileButtonFrames = {}
    _printedBtnSeq = 0

    local sg = Instance.new("ScreenGui")
    sg.Name = "PrintedMobileButtons"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999980
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Enabled = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    local placed = false
    pcall(function() if gethui then sg.Parent = gethui() placed = true end end)
    if not placed then pcall(function() sg.Parent = CoreGui placed = true end) end
    if not placed then pcall(function() sg.Parent = localPlayer:WaitForChild("PlayerGui", 5) placed = true end) end
    if not placed then pcall(function() sg.Parent = PlayerGui end) end
    v91 = sg
    v88 = sg
    sg.Enabled = not hideMobileButtons
    hideMobileButtons = hideMobileButtons or false

    local container = Instance.new("Frame", sg)
    container.Name = "ButtonContainer"
    container.Active = false
    container.Selectable = false
    local BTN = tonumber(MOBILE_BTN_SIZE) or 64
    container.Size = UDim2.new(0, BTN * 3 + 40, 0, BTN * 4 + 40)
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    if mobileGroupPosition and type(mobileGroupPosition) == "table" then
        container.Position = UDim2.new(tonumber(mobileGroupPosition.xs) or 0.5, tonumber(mobileGroupPosition.x) or 0, tonumber(mobileGroupPosition.ys) or 0.5, tonumber(mobileGroupPosition.y) or 0)
    else
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
    end
    uiScale = Instance.new("UIScale", container)
    uiScale.Scale = tonumber(mobileButtonScaleValue) or 1.0
    _G.__PrintedBtnScaleObj = uiScale
    _G.PrintedBtnScale = uiScale.Scale

    local editBanner = Instance.new("Frame", container)
    editBanner.Name = "EditBanner"
    editBanner.Size = UDim2.new(1, 0, 0, 26)
    editBanner.Position = UDim2.new(0, 0, 0, -32)
    editBanner.BackgroundColor3 = Color3.fromRGB(255, 140, 255)
    editBanner.BorderSizePixel = 0
    editBanner.Visible = false
    editBanner.ZIndex = 51
    Instance.new("UICorner", editBanner).CornerRadius = UDim.new(1, 0)
    Instance.new("UIGradient", editBanner).Color = ColorSequence.new(Color3.fromRGB(90, 160, 255), Color3.fromRGB(12, 14, 22))
    local ebLabel = Instance.new("TextLabel", editBanner)
    ebLabel.Size = UDim2.new(1, 0, 1, 0)
    ebLabel.BackgroundTransparency = 1
    ebLabel.Text = "EDIT MODE"
    ebLabel.TextColor3 = Color3.fromRGB(15, 15, 18)
    ebLabel.Font = Enum.Font.GothamBlack
    ebLabel.TextSize = 12
    ebLabel.ZIndex = 11
    v90 = editBanner

    local btnStates = {}

    local function buildBtn(name, text, panelX, panelY)
        local BTN = tonumber(MOBILE_BTN_SIZE) or 64
        local btn = Instance.new("Frame", container)
        btn.Name = name
        btn.Size = UDim2.new(0, BTN, 0, BTN)
        btn.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(14, 16, 18)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18)
        local themeImg = Instance.new("ImageLabel", btn)
        themeImg.Name = "ThemeImg"
        themeImg.Size = UDim2.new(1, 0, 1, 0)
        themeImg.BackgroundTransparency = 1
        themeImg.ImageTransparency = 1
        themeImg.ScaleType = Enum.ScaleType.Crop
        themeImg.ZIndex = 0
        Instance.new("UICorner", themeImg).CornerRadius = UDim.new(0, 18)
        local ring = Instance.new("Frame", btn)
        ring.Name = "Ring"
        ring.Size = UDim2.new(1, 6, 1, 6)
        ring.Position = UDim2.new(0, -3, 0, -3)
        ring.BackgroundTransparency = 1
        ring.BorderSizePixel = 0
        ring.ZIndex = 5
        Instance.new("UICorner", ring).CornerRadius = UDim.new(0, 20)
        local ringStroke = Instance.new("UIStroke", ring)
        ringStroke.Thickness = 2.2
        ringStroke.Transparency = 1
        ringStroke.Color = Color3.fromRGB(255, 140, 255)
        local ringGrad = Instance.new("UIGradient", ringStroke)
        ringGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 255)),
        })
        local gradLayer = Instance.new("Frame", btn)
        gradLayer.Name = "GradLayer"
        gradLayer.Size = UDim2.new(1, 0, 1, 0)
        gradLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        gradLayer.BackgroundTransparency = 1
        gradLayer.BorderSizePixel = 0
        gradLayer.ZIndex = 1
        Instance.new("UICorner", gradLayer).CornerRadius = UDim.new(0, 18)
        local bgGrad = Instance.new("UIGradient", gradLayer)
        local a = getAccent()
        if a and a.grad then
            bgGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, a.grad[1]),
                ColorSequenceKeypoint.new(0.45, a.grad[2]),
                ColorSequenceKeypoint.new(1, a.grad[4]),
            })
        else
            bgGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(40, 150, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 22)),
            })
        end
        bgGrad.Rotation = 45
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(55, 55, 65)
        stroke.Thickness = 1.4
        stroke.Transparency = 0.25
        local strokeGrad = Instance.new("UIGradient", stroke)
        strokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 210, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 32, 130)),
        })
        local flash = Instance.new("Frame", btn)
        flash.Name = "FlashLayer"
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(255, 140, 255)
        flash.BackgroundTransparency = 1
        flash.BorderSizePixel = 0
        flash.ZIndex = 2
        Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 18)
        local label = Instance.new("TextLabel", btn)
        label.Size = UDim2.new(1, -6, 1, -6)
        label.Position = UDim2.new(0, 3, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(235, 235, 240)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 14
        label.TextWrapped = true
        label.TextScaled = false
        local sz = Instance.new("UITextSizeConstraint", label)
        sz.MinTextSize = 10
        sz.MaxTextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.ZIndex = 3
        local click = Instance.new("TextButton", btn)
        click.Size = UDim2.new(1, 0, 1, 0)
        click.BackgroundTransparency = 1
        click.Text = ""
        click.AutoButtonColor = false
        click.ZIndex = 6
        click.Active = true
        click.Selectable = false

        _printedBtnSeq = _printedBtnSeq + 1
        local defaultPos = UDim2.new(0, (panelX or 0), 0, (panelY or 0))
        local saved = mobileButtonPositions[name]
        local used = false
        if type(saved) == "table" then
            local sx = tonumber(saved.x) or 0
            local sy = tonumber(saved.y) or 0
            local sxs = tonumber(saved.xs) or 0
            local sys = tonumber(saved.ys) or 0
            if math.abs(sx) <= 2000 and math.abs(sy) <= 2000 and math.abs(sxs) <= 1 and math.abs(sys) <= 1 then
                btn.Position = UDim2.new(sxs, sx, sys, sy)
                used = true
            end
        end
        if not used then
            btn.Position = defaultPos
            mobileButtonPositions[name] = nil
        end

        mobileButtonFrames[name] = {
            frame = btn, defaultPosition = defaultPos,
            stroke = stroke, label = label, button = click,
            gradLayer = gradLayer, bgGrad = bgGrad, strokeGrad = strokeGrad,
            flashLayer = flash, btnSize = BTN, themeImg = themeImg,
            themeIdx = _printedBtnSeq, ringStroke = ringStroke, ringGrad = ringGrad,
            panelX = panelX, panelY = panelY,
        }

        local drag = false
        local startPos, startFrame, startCont, moved = nil, nil, nil, false
        local downTime = 0
        local lastFire = 0

        local function fire()
            -- Lock UI only blocks dragging, NEVER blocks aimbot / auto left / right actions
            local now = tick()
            if now - lastFire < 0.18 then return end
            lastFire = now
            downTime = now
            local action = MobileButtonActions[name]
            if action then
                task.spawn(function()
                    local ok, err = pcall(action)
                    if not ok then warn("[Printed] mobile button " .. tostring(name) .. " failed: " .. tostring(err)) end
                end)
            end
        end

        click.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            startPos = input.Position
            startFrame = btn.Position
            startCont = container.Position
            moved = false
            downTime = tick()
            -- visual feedback always
            if gradLayer then gradLayer.BackgroundTransparency = 0.15 end
            local sz = btn.Size.X.Offset
            if sz < 1 then sz = 64 end
            TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Size = UDim2.new(0, sz - 4, 0, sz - 4) }):Play()
            if flash then
                flash.BackgroundTransparency = 0.5
                TweenService:Create(flash, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
            end
            -- only allow drag reposition when unlocked
            if not uiLocked then
                drag = true
            end
        end)

        click.InputEnded:Connect(function(input)
            if not startPos then return end
            startPos = nil
            local sz = mobileButtonFrames[name] and mobileButtonFrames[name].btnSize or (tonumber(MOBILE_BTN_SIZE) or 64)
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, sz, 0, sz) }):Play()
            drag = false
            if moved then
                if _G.PrintedMobileButtonsPanel == true then
                    mobileGroupPosition = { xs = container.Position.X.Scale, x = container.Position.X.Offset, ys = container.Position.Y.Scale, y = container.Position.Y.Offset }
                else
                    mobileButtonPositions[name] = { xs = btn.Position.X.Scale, x = btn.Position.X.Offset, ys = btn.Position.Y.Scale, y = btn.Position.Y.Offset }
                end
                -- always force immediate save of positions + all config
                if printedSavePositionsNow then
                    pcall(printedSavePositionsNow)
                else
                    _printedConfigDirty = true
                    if printedSaveConfig then pcall(printedSaveConfig) end
                end
            else
                fire()
            end
        end)

        click.Activated:Connect(function()
            if not moved then fire() end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if uiLocked or not drag or not startPos or not startFrame then return end
            if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local dx = input.Position.X - startPos.X
            local dy = input.Position.Y - startPos.Y
            if math.abs(dx) > 5 or math.abs(dy) > 5 then moved = true end
            if not moved then return end
            if _G.PrintedMobileButtonsPanel == true then
                if startCont then
                    container.Position = UDim2.new(startCont.X.Scale, startCont.X.Offset + dx, startCont.Y.Scale, startCont.Y.Offset + dy)
                end
                return
            end
            btn.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + dx, startFrame.Y.Scale, startFrame.Y.Offset + dy)
        end)

        return btn, label
    end

    -- Layout (scaled for bigger 64px buttons)
    local S = tonumber(MOBILE_BTN_SIZE) or 64
    local GAP = 8
    local layout = {
        TPBat = { "TP BAT", 0, S*2 + GAP*2 },
        AutoLeft = { "AUTO LEFT", 0, 0 },
        AutoRight = { "AUTO RIGHT", S + GAP, 0 },
        DropBrainrot = { "DROP BR", 0, S + GAP },
        AutoBat = { "AIMBOT", S + GAP, S + GAP },
        TPDown = { "TP DOWN", 0, S*2 + GAP*2 },
        CarrySpeed = { "CARRY", S + GAP, S*2 + GAP*2 },
        LaggerSpeed = { "LAGGER NORMAL", 0, S*3 + GAP*3 },
        LaggerCarry = { "LAGGER CARRY", S + GAP, S*3 + GAP*3 },
    }
    for name, d in pairs(layout) do
        buildBtn(name, d[1], d[2], d[3])
    end

    function printedApplyMobilePanel()
        local panelMode = _G.PrintedMobileButtonsPanel == true
        local BTN = tonumber(MOBILE_BTN_SIZE) or 64
        container.ClipsDescendants = panelMode
        container.Active = false
        container.Selectable = false
        container.BackgroundTransparency = 1
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        local oldBG = container:FindFirstChild("PanelBG")
        if oldBG then oldBG:Destroy() end
        local oldStroke = container:FindFirstChild("PanelStroke")
        if oldStroke then oldStroke:Destroy() end
        if panelMode then
            container.Size = UDim2.new(0, BTN * 2 + 24, 0, BTN * 4 + 32)
            for k, v in pairs(mobileButtonFrames) do
                if v and v.frame then
                    v.frame.Position = UDim2.new(0, v.panelX or 0, 0, v.panelY or 0)
                    v.frame.Size = UDim2.new(0, BTN, 0, BTN)
                    v.btnSize = BTN
                    v.frame.Visible = true
                end
            end
        else
            container.Size = UDim2.new(0, BTN * 3 + 40, 0, BTN * 4 + 40)
            for k, v in pairs(mobileButtonFrames) do
                if v and v.frame then
                    local saved = mobileButtonPositions[k]
                    if type(saved) == "table" then
                        v.frame.Position = UDim2.new(saved.xs or 0, saved.x or 0, saved.ys or 0, saved.y or 0)
                    else
                        v.frame.Position = v.defaultPosition
                    end
                    v.frame.Size = UDim2.new(0, BTN, 0, BTN)
                    v.btnSize = BTN
                    v.frame.Visible = true
                end
            end
        end
        -- keep scale from saved config
        if uiScale then
            uiScale.Scale = tonumber(mobileButtonScaleValue) or 1.0
        end
    end
    _G.PrintedApplyMobilePanel = printedApplyMobilePanel
    task.defer(printedApplyMobilePanel)

    -- Actions
    MobileButtonActions.AutoLeft = function()
        autoLeftEnabled = not autoLeftEnabled
        if autoLeftEnabled then queueAutoLeftStart() else stopAutoLeft() end
        if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
        if printedMarkDirty then printedMarkDirty() end
    end
    MobileButtonActions.AutoRight = function()
        autoRightEnabled = not autoRightEnabled
        if autoRightEnabled then queueAutoRightStart() else stopAutoRight() end
        if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
        if printedMarkDirty then printedMarkDirty() end
    end
    MobileButtonActions.AutoBat = function()
        if not autoBatEnabled then
            queueAutoBatStart()
            if autoBatSetVisual then autoBatSetVisual(true) end
        else
            autoBatEnabled = false
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
        end
        if printedMarkDirty then printedMarkDirty() end
    end
    MobileButtonActions.CarrySpeed = function()
        toggleCarryMode()
        if printedMarkDirty then printedMarkDirty() end
    end
    MobileButtonActions.DropBrainrot = function() runDrop() end
    MobileButtonActions.TPDown = function() runTPFloor() end
    MobileButtonActions.LaggerCarry = function()
        local holding = isHoldingBrainrotNow()
        if laggerToggled and laggerPhase == 2 then
            if holding then laggerPhase = 1
            else laggerToggled = false laggerPhase = 0 speedMode = false end
        else
            laggerToggled = true laggerPhase = 2 speedMode = false
        end
        refreshSpeedModeLabel()
        if printedMarkDirty then printedMarkDirty() end
    end
    MobileButtonActions.LaggerSpeed = function()
        local holding = isHoldingBrainrotNow()
        if laggerToggled and laggerPhase == 1 then
            if holding then laggerPhase = 2
            else laggerToggled = false laggerPhase = 0 end
        else
            laggerToggled = true laggerPhase = 1 speedMode = false
        end
        refreshSpeedModeLabel()
        if printedMarkDirty then printedMarkDirty() end
    end
    MobileButtonActions.TPBat = function()
        tpBatEnabled = not tpBatEnabled
        if tpBatEnabled then
            if suspendBodyLock then pcall(suspendBodyLock) end
        elseif not autoBatEnabled and restoreBodyLock then
            pcall(restoreBodyLock)
        end
        pcall(function() if stopPrintedDesync then stopPrintedDesync() end end)
        pcall(function() if stopAntiBypassAimbotConn then stopAntiBypassAimbotConn() end end)
        if printedMarkDirty then printedMarkDirty() end
    end

    -- Button visual updater
    RunService.Heartbeat:Connect(function(dt)
        if not v91 or not v91.Parent then return end
        local function update(name, active)
            local d = mobileButtonFrames[name]
            if not d then return end
            local printedButtonMode = _G.PrintedButtonMode or "Gradient"
            local themeOn = (tonumber(_G.PrintedBtnTheme) or 0) > 0 and printedButtonMode == "Background"
            if active then
                if printedButtonMode == "Background" then
                    if d.gradLayer then d.gradLayer.BackgroundTransparency = 1 end
                    if d.bgGrad then d.bgGrad.Enabled = true end
                    if d.themeImg then d.themeImg.ImageTransparency = 1 end
                else
                    if d.gradLayer then d.gradLayer.BackgroundTransparency = 1 end
                    if d.bgGrad then d.bgGrad.Enabled = false end
                    if d.themeImg and themeOn then d.themeImg.ImageTransparency = 0.06 end
                end
                if d.ringStroke then
                    d.ringStroke.Color = Color3.fromRGB(255, 255, 255)
                    d.ringStroke.Thickness = 2.2
                    d.ringStroke.Transparency = 0
                end
                if d.stroke then
                    d.stroke.Color = Color3.fromRGB(245, 245, 250)
                    d.stroke.Thickness = 1.8
                    d.stroke.Transparency = 0.08
                end
                d.label.TextColor3 = Color3.new(1, 1, 1)
            else
                if d.gradLayer and printedButtonMode == "Gradient" then
                    if d.gradLayer.BackgroundTransparency < 1 then
                        d.gradLayer.BackgroundTransparency = math.min(1, d.gradLayer.BackgroundTransparency + dt * 3)
                    end
                elseif d.gradLayer then
                    d.gradLayer.BackgroundTransparency = 1
                end
                if d.ringStroke then
                    d.ringStroke.Transparency = math.min(1, (d.ringStroke.Transparency or 0) + dt * 5)
                end
                if d.stroke then
                    d.stroke.Color = Color3.fromRGB(55, 55, 65)
                    d.stroke.Thickness = 1.4
                    d.stroke.Transparency = 0.25
                end
                d.label.TextColor3 = Color3.fromRGB(220, 220, 230)
            end
        end
        update("AutoLeft", autoLeftEnabled)
        update("AutoRight", autoRightEnabled)
        update("AutoBat", autoBatEnabled)
        update("CarrySpeed", speedMode and not laggerToggled)
        update("LaggerCarry", laggerToggled and laggerPhase == 2)
        update("LaggerSpeed", laggerToggled and laggerPhase == 1)
        update("DropBrainrot", false)
        update("TPDown", false)
        update("TPBat", tpBatEnabled)
    end)

    _updateMobileAutoLeft = function() end
    _updateMobileAutoRight = function() end
    fn41()
    if _G.PrintedApplyBtnTheme then pcall(_G.PrintedApplyBtnTheme) end
    if _G.PrintedApplyButtonMode then pcall(_G.PrintedApplyButtonMode, _G.PrintedButtonMode or "Gradient") end
    if _G.PrintedApplyAccentTheme then pcall(_G.PrintedApplyAccentTheme) end
end

function fn41()
    if v88 then
        v88.Enabled = not hideMobileButtons
        if v88.Parent == nil then
            pcall(createMobilePanel)
        end
    elseif not hideMobileButtons then
        pcall(createMobilePanel)
    end
    for _, v in pairs(mobileButtonFrames or {}) do
        if v and v.frame then
            v.frame.Visible = true
        end
        if v and v.stroke then
            v.stroke.Thickness = visible and 2 or 1
            v.stroke.Color = visible and Color3.new(1, 1, 1) or Color3.fromRGB(70, 120, 80)
        end
    end
    if v90 then v90.Visible = visible end
end

_G.PrintedFlashBlockedButton = function(id)
    local v = mobileButtonFrames and mobileButtonFrames[id]
    if not v then return end
    local button = v.button or v.btn
    local frame = v.frame
    local flashLayer = v.flashLayer
    if flashLayer then
        flashLayer.BackgroundColor3 = Color3.fromRGB(120, 45, 45)
        flashLayer.BackgroundTransparency = 0.25
        flashLayer.Visible = true
        task.delay(0.6, function()
            if flashLayer and flashLayer.Parent then
                flashLayer.BackgroundTransparency = 1
                flashLayer.Visible = false
            end
        end)
    end
    if button then
        local ob = button.BackgroundColor3
        local ot = button.TextColor3
        button.BackgroundColor3 = Color3.fromRGB(120, 25, 35)
        button.TextColor3 = Color3.fromRGB(255, 210, 210)
        task.delay(0.6, function()
            if button and button.Parent then
                button.BackgroundColor3 = ob
                button.TextColor3 = ot
            end
        end)
    elseif frame then
        local ob = frame.BackgroundColor3
        frame.BackgroundColor3 = Color3.fromRGB(120, 25, 30)
        task.delay(0.6, function()
            if frame and frame.Parent then frame.BackgroundColor3 = ob end
        end)
    end
end

-- ============================================================
-- BUTTON MODE / THEME
-- ============================================================
_G.PrintedApplyBtnTheme = function()
    local mode = _G.PrintedButtonMode or "Gradient"
    local ids = _G.PrintedThemeIds or {}
    local id = ids[tonumber(_G.PrintedBtnTheme) or 0]
    local n = 0
    for _, v in pairs(mobileButtonFrames or {}) do
        n = n + 1
        if v.themeImg then
            if mode == "Background" and id then
                local idx = v.themeIdx or n
                local row = math.floor((idx - 1) % 9 / 3)
                v.themeImg.Image = "rbxassetid://" .. tostring(id)
                v.themeImg.ImageRectOffset = Vector2.new((idx - 1) % 3 * 341, row * 341)
                v.themeImg.ImageRectSize = Vector2.new(341, 341)
                v.themeImg.ImageTransparency = 0.06
                if v.gradLayer then v.gradLayer.BackgroundTransparency = 1 end
                if v.bgGrad then v.bgGrad.Enabled = false end
            else
                v.themeImg.ImageTransparency = 1
            end
        end
    end
    if mode == "Gradient" and _G.PrintedApplyButtonMode then
        pcall(_G.PrintedApplyButtonMode, "Gradient")
    end
end

_G.PrintedApplyButtonMode = function(mode)
    if mode ~= "Background" and mode ~= "Gradient" then
        mode = _G.PrintedButtonMode == "Background" and "Background" or "Gradient"
    end
    _G.PrintedButtonMode = mode
    local accent = nil
    pcall(function() if getAccent then accent = getAccent() end end)
    if not accent then accent = _G.PrintedAccentCache or ACCENT_THEMES[_G.PrintedAccentTheme or "Blue"] end
    local g1 = (accent and accent.grad and accent.grad[1]) or Color3.fromRGB(130, 60, 255)
    local g2 = (accent and accent.grad and accent.grad[3]) or Color3.fromRGB(80, 180, 255)
    local g3 = (accent and accent.grad and accent.grad[5]) or Color3.fromRGB(20, 60, 160)
    pcall(function()
        for _, v in pairs(mobileButtonFrames or {}) do
            if v then
                if mode == "Background" then
                    if v.gradLayer then v.gradLayer.BackgroundTransparency = 1 end
                    if v.bgGrad then v.bgGrad.Enabled = false end
                    if v.themeImg then v.themeImg.ImageTransparency = (tonumber(_G.PrintedBtnTheme) or 0) > 0 and 0.06 or 1 end
                else
                    if v.themeImg then v.themeImg.ImageTransparency = 1 end
                    if v.bgGrad then
                        v.bgGrad.Enabled = true
                        v.bgGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, g1),
                            ColorSequenceKeypoint.new(0.45, g2),
                            ColorSequenceKeypoint.new(1, g3),
                        })
                        v.bgGrad.Rotation = 45
                    end
                    if v.strokeGrad and accent and accent.grad then
                        v.strokeGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, accent.grad[2] or g2),
                            ColorSequenceKeypoint.new(1, g3),
                        })
                    end
                    if v.gradLayer then v.gradLayer.BackgroundTransparency = 1 end
                end
            end
        end
    end)
    if mode == "Background" and _G.PrintedApplyBtnTheme then pcall(_G.PrintedApplyBtnTheme) end
end

-- ============================================================
-- UI BUILDER
-- ============================================================
-- Kept separate from buildGui so Luau stays under its local-register limit.
local function buildStealBar(sg)
    -- ========== STEAL BAR — always bottom-center, always visible ==========
    pcall(function()
        local parents = {}
        pcall(function() if gethui then table.insert(parents, gethui()) end end)
        table.insert(parents, CoreGui)
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if pg then table.insert(parents, pg) end
        for _, p in ipairs(parents) do
            if p then
                local old = p:FindFirstChild("PrintedStealBar")
                if old then pcall(function() old:Destroy() end) end
            end
        end
    end)

    local stealGui = Instance.new("ScreenGui")
    stealGui.Name = "PrintedStealBar"
    stealGui.ResetOnSpawn = false
    stealGui.IgnoreGuiInset = true
    stealGui.DisplayOrder = 2147483647
    stealGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    stealGui.Enabled = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(stealGui) end end)

    local function parentGui()
        local ok = false
        pcall(function()
            if gethui then
                stealGui.Parent = gethui()
                ok = stealGui.Parent ~= nil
            end
        end)
        if not ok then
            pcall(function()
                stealGui.Parent = CoreGui
                ok = stealGui.Parent ~= nil
            end)
        end
        if not ok then
            pcall(function()
                local pg = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 3)
                if pg then stealGui.Parent = pg end
            end)
        end
        return stealGui.Parent ~= nil
    end
    parentGui()
    _G.__PrintedStealGui = stealGui

    -- Steal bar: smaller + smooth rounded ends (like reference photo)
    local BAR_H = 44
    local BAR_W = 340
    local stealBar = Instance.new("Frame")
    stealBar.Name = "StealBar"
    stealBar.AnchorPoint = Vector2.new(0.5, 1)
    stealBar.Size = UDim2.new(0, BAR_W, 0, BAR_H)
    stealBar.Position = UDim2.new(0.5, 0, 1, -24)
    stealBar.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
    stealBar.BackgroundTransparency = 0.06
    stealBar.BorderSizePixel = 0
    stealBar.ClipsDescendants = true
    stealBar.Visible = true
    stealBar.ZIndex = 100
    stealBar.Active = true
    stealBar.Parent = stealGui

    -- Soft rounded corners (reference style) — radius just under half height
    local outerCorner = Instance.new("UICorner")
    outerCorner.Name = "PillCorner"
    outerCorner.CornerRadius = UDim.new(0, 16)
    outerCorner.Parent = stealBar

    local barStroke = Instance.new("UIStroke")
    barStroke.Name = "PillStroke"
    barStroke.Parent = stealBar
    _G.__PrintedBarStroke = barStroke
    barStroke.Color = Color3.fromRGB(55, 145, 255)
    barStroke.Thickness = 2.2
    barStroke.Transparency = 0.08
    barStroke.LineJoinMode = Enum.LineJoinMode.Round
    barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local barGrad = Instance.new("UIGradient", barStroke)
    barGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 120, 255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(120, 200, 255)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(70, 160, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(45, 130, 255)),
    })
    task.spawn(function()
        while stealBar and stealBar.Parent do
            barGrad.Rotation = (barGrad.Rotation + 1.5) % 360
            task.wait(0.04)
        end
    end)

    local barScale = Instance.new("UIScale", stealBar)
    barScale.Scale = math.clamp(tonumber(_G.PrintedBarScale) or 1, 0.3, 1.5)
    _G.__PrintedBarScale = barScale
    _G.__PrintedBarScaleObj = barScale
    _G.__PrintedBarFrame = stealBar

    -- Avatar
    local avFrame = Instance.new("Frame", stealBar)
    avFrame.Size = UDim2.new(0, 30, 0, 30)
    avFrame.Position = UDim2.new(0, 8, 0.5, -15)
    avFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    avFrame.BorderSizePixel = 0
    avFrame.ClipsDescendants = true
    avFrame.ZIndex = 110
    local avCorner = Instance.new("UICorner", avFrame)
    avCorner.CornerRadius = UDim.new(1, 0) -- perfect circle
    local avStroke = Instance.new("UIStroke", avFrame)
    avStroke.Color = Color3.fromRGB(90, 160, 255)
    avStroke.Thickness = 1.3
    avStroke.Transparency = 0.2
    local avImg = Instance.new("ImageLabel", avFrame)
    avImg.Size = UDim2.new(1, 0, 1, 0)
    avImg.BackgroundTransparency = 1
    avImg.ScaleType = Enum.ScaleType.Crop
    avImg.ZIndex = 111
    Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        pcall(function()
            local t = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            if t and avImg.Parent then avImg.Image = t end
        end)
    end)

    -- %
    local pctLabel = Instance.new("TextLabel", stealBar)
    pctLabel.Name = "Pct"
    pctLabel.Size = UDim2.new(0, 58, 0, 24)
    pctLabel.Position = UDim2.new(0, 42, 0, 4)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Text = "0%"
    pctLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pctLabel.Font = Enum.Font.GothamBlack
    pctLabel.TextSize = 20
    pctLabel.TextXAlignment = Enum.TextXAlignment.Left
    pctLabel.TextYAlignment = Enum.TextYAlignment.Center
    pctLabel.ZIndex = 112
    pctLabel.TextStrokeTransparency = 0.65
    _G.__PrintedProgressPct = pctLabel

    -- Stats right
    local statsFrame = Instance.new("Frame", stealBar)
    statsFrame.Size = UDim2.new(0, 210, 0, 18)
    statsFrame.Position = UDim2.new(1, -216, 0, 5)
    statsFrame.BackgroundTransparency = 1
    statsFrame.ZIndex = 112
    local sLayout = Instance.new("UIListLayout", statsFrame)
    sLayout.FillDirection = Enum.FillDirection.Horizontal
    sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    sLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    sLayout.Padding = UDim.new(0, 10)

    local function makeStat(w, text)
        local lbl = Instance.new("TextLabel", statsFrame)
        lbl.Size = UDim2.new(0, w, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(200, 205, 220)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.ZIndex = 113
        return lbl
    end
    local fpsLbl = makeStat(55, "FPS --")
    local pingLbl = makeStat(88, "PING --ms")
    local clockLbl = makeStat(74, "--:-- --")

    local fc, lastFps = 0, tick()
    RunService.Heartbeat:Connect(function()
        if not stealBar or not stealBar.Parent then return end
        fc = fc + 1
        local now = tick()
        if now - lastFps >= 0.4 then
            local fps = math.floor(fc / (now - lastFps) + 0.5)
            fc = 0
            lastFps = now
            local ping = 0
            pcall(function() ping = math.floor((localPlayer:GetNetworkPing() or 0) * 1000 + 0.5) end)
            fpsLbl.Text = string.format("FPS %d", fps)
            pingLbl.Text = string.format("PING %dms", ping)
            local t = os.date("*t")
            local h = t.hour % 12
            if h == 0 then h = 12 end
            clockLbl.Text = string.format("%02d:%02d %s", h, t.min, t.hour >= 12 and "PM" or "AM")
        end
    end)

    -- Progress track
    local progressTrack = Instance.new("Frame", stealBar)
    progressTrack.Name = "ProgressTrack"
    progressTrack.Size = UDim2.new(1, -54, 0, 4)
    progressTrack.Position = UDim2.new(0, 42, 1, -11)
    progressTrack.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
    progressTrack.BackgroundTransparency = 0.25
    progressTrack.BorderSizePixel = 0
    progressTrack.ZIndex = 108
    Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

    local progressFill = Instance.new("Frame", progressTrack)
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 109
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
    local progressGrad = Instance.new("UIGradient", progressFill)
    progressGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 210, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 190, 255)),
    })
    _G.__PrintedProgressFill = progressFill

    function _G.setStealProgress(p)
        local v = math.clamp(tonumber(p) or 0, 0, 1)
        if not stealGui.Parent then parentGui() end
        stealGui.Enabled = true
        stealBar.Visible = true
        if not stealBar.Parent then stealBar.Parent = stealGui end
        progressFill.Size = UDim2.new(v, 0, 1, 0)
        pctLabel.Text = string.format("%d%%", math.floor(v * 100 + 0.5))
        if frame then pcall(function() frame.Size = UDim2.new(v, 0, 1, 0) end) end
        if textLabel2 then pcall(function() textLabel2.Text = string.format("%d%%", math.floor(v * 100 + 0.5)) end) end
    end

    function _G.resetProgressBar()
        pctLabel.Text = "0%"
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        -- keep bar VISIBLE at bottom (only reset fill)
        stealBar.Visible = true
        if frame then pcall(function() frame.Size = UDim2.new(0, 0, 1, 0) end) end
        if textLabel2 then pcall(function() textLabel2.Text = "0%" end) end
    end

    -- Force stay alive + bottom center
    RunService.Heartbeat:Connect(function()
        if not stealGui then return end
        if not stealGui.Parent then parentGui() end
        stealGui.Enabled = true
        if stealBar then
            if not stealBar.Parent then stealBar.Parent = stealGui end
            stealBar.Visible = true
            -- lock to bottom-center unless user dragged
            if not stealBar:GetAttribute("UserDragged") then
                stealBar.AnchorPoint = Vector2.new(0.5, 1)
                stealBar.Position = UDim2.new(0.5, 0, 1, -24)
            end
        end
    end)

    _G.PrintedRebuildStealBar = function()
        pcall(function() buildStealBar(sg) end)
    end

    -- Drag (marks UserDragged so heartbeat doesn't snap back)
    local sDrag, sStart, sPos = false, nil, nil
    stealBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if uiLocked then return end
            sDrag = true
            sStart = input.Position
            sPos = stealBar.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    sDrag = false
                    if stealBar then
                        stealBar:SetAttribute("UserDragged", true)
                        if printedSavePositionsNow then printedSavePositionsNow()
                        elseif printedMarkDirty then printedMarkDirty() end
                    end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sDrag and sStart and sPos and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - sStart
            stealBar.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)

    -- restore saved position if any
    if type(_G.__PrintedSavedStealPos) == "table" then
        pcall(function()
            local d = _G.__PrintedSavedStealPos
            stealBar.Position = UDim2.new(tonumber(d.xs) or 0.5, tonumber(d.x) or 0, tonumber(d.ys) or 1, tonumber(d.y) or -28)
            if _G.__PrintedSavedStealDragged then
                stealBar:SetAttribute("UserDragged", true)
            end
        end)
    end

    print("[Printed] steal bar built — bottom center")
    return stealBar
end

local function buildGui()
    local color = Color3.fromRGB(5, 5, 7)
    local color2 = Color3.fromRGB(9, 9, 13)
    local color3 = Color3.fromRGB(235, 235, 235)
    local color4 = Color3.fromRGB(170, 170, 170)
    local color5 = Color3.fromRGB(235, 235, 235)
    local color6 = Color3.fromRGB(10, 10, 14)
    local color7 = Color3.fromRGB(28, 28, 35)

    local old = CoreGui:FindFirstChild("ZexDuels")
    if old then old:Destroy() end
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old2 = pg:FindFirstChild("ZexDuels")
        if old2 then old2:Destroy() end
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "ZexDuels"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 50
    sg.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    if not pcall(function() sg.Parent = CoreGui end) then
        sg.Parent = PlayerGui
    end

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 380)
    main.Position = UDim2.new(0, 16, 0, 16)
    main.BackgroundColor3 = color
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = sg

    local bgImage = Instance.new("ImageLabel", main)
    bgImage.Name = "CustomBg"
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ImageTransparency = 0
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 0
    bgImage.Visible = false
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 18)

    local originalBg = main.BackgroundColor3
    local function restoreBg()
        if bgImage.Visible then
            main.BackgroundTransparency = 1
            bgImage.ImageTransparency = 0.12
        else
            main.BackgroundTransparency = 0
            main.BackgroundColor3 = originalBg
        end
    end

    _G.PrintedSetBg = function(id)
        local str = tostring(id or "")
        if str == "" or str == "0" then
            bgImage.Image = ""
            bgImage.Visible = false
        else
            local image = str:find("rbxassetid://") and str or ("rbxassetid://" .. str)
            bgImage.Image = image
            bgImage.ImageTransparency = 0.12
            bgImage.Visible = true
        end
        _G.__PrintedMenuBgImg = bgImage
        restoreBg()
    end

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

    local mainScale = Instance.new("UIScale", main)
    if _G.PrintedGuiScale == nil or _G.PrintedGuiScale == 1 then _G.PrintedGuiScale = 0.82 end
    mainScale.Scale = math.clamp(tonumber(_G.PrintedGuiScale) or 0.82, 0.1, 1)
    _G.__PrintedMainScale = mainScale
    _G.__PrintedMainFrame = main

    _G.__PrintedSetGuiScale = function(s)
        local s = math.clamp(tonumber(s) or 1, 0.1, 1)
        _G.PrintedGuiScale = s
        if _G.__PrintedMainScale then _G.__PrintedMainScale.Scale = s end
    end

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 62)
    titleBar.BackgroundColor3 = color2
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 5
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", titleBar)
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 12, 0, 6)
    title.Size = UDim2.new(0, 200, 0, 28)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ZIndex = 6
    title.RichText = true
    title.Text = '<font color="#FFFFFF">ZEX</font> <font color="#288CFF">DUELS</font>'
    _G.__PrintedTitleLabel = title

    local subtitle = Instance.new("TextLabel", titleBar)
    subtitle.Size = UDim2.new(1, -130, 0, 16)
    subtitle.Position = UDim2.new(0, 12, 0, 32)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "ZexHub"
    subtitle.TextColor3 = Color3.fromRGB(150, 155, 170)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 6

    local uiBtn = Instance.new("TextButton", titleBar)
    uiBtn.Size = UDim2.new(0, 32, 0, 22)
    uiBtn.Position = UDim2.new(1, -148, 0, 10)
    uiBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    uiBtn.BorderSizePixel = 0
    uiBtn.Text = "UI"
    uiBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
    uiBtn.Font = Enum.Font.GothamBold
    uiBtn.TextSize = 11
    uiBtn.ZIndex = 7
    uiBtn.AutoButtonColor = false
    Instance.new("UICorner", uiBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", uiBtn).Color = Color3.fromRGB(55, 55, 65)

    local lockBtn = Instance.new("TextButton", titleBar)
    lockBtn.Size = UDim2.new(0, 72, 0, 22)
    lockBtn.Position = UDim2.new(1, -112, 0, 10)
    lockBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = uiLocked and "LOCKED" or "UNLOCKED"
    lockBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 11
    lockBtn.ZIndex = 7
    lockBtn.AutoButtonColor = false
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", lockBtn).Color = Color3.fromRGB(55, 55, 65)

    _G.PrintedRefreshLockBtn = function()
        if lockBtn and lockBtn.Parent then
            lockBtn.Text = uiLocked and "LOCKED" or "UNLOCKED"
        end
    end

    lockBtn.Activated:Connect(function()
        uiLocked = not uiLocked
        _G.PrintedRefreshLockBtn()
        -- force immediate save + mark dirty so lock ALWAYS persists on re-execute
        _printedConfigDirty = true
        pcall(printedSaveConfig)
        if printedMarkDirty then printedMarkDirty() end
    end)

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -40, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = color4
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 20
    closeBtn.ZIndex = 7
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(35, 35, 42), TextColor3 = color5 }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(22, 22, 28), TextColor3 = color4 }):Play()
    end)

    local miniBtn = Instance.new("ImageButton", sg)
    miniBtn.Name = "MiniBtn"
    miniBtn.Size = UDim2.new(0, 108, 0, 36)
    miniBtn.Position = UDim2.new(0, 26, 0, 26)
    miniBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    miniBtn.BackgroundTransparency = 0.12
    miniBtn.BorderSizePixel = 0
    miniBtn.Image = "rbxassetid://127912104692615"
    miniBtn.ImageTransparency = 0.15
    miniBtn.ScaleType = Enum.ScaleType.Crop
    miniBtn.AutoButtonColor = false
    miniBtn.ZIndex = 10
    miniBtn.Visible = false
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1, 0)
    local miniStroke = Instance.new("UIStroke", miniBtn)
    miniStroke.Color = Color3.fromRGB(140, 255, 255)
    miniStroke.Thickness = 1.2
    miniStroke.Transparency = 0.55

    _G.__PrintedMiniBtn = miniBtn
    _G.__PrintedMini = miniBtn

    local function showGui()
        miniBtn.Visible = false
        main.Visible = true
        main.Position = UDim2.new(0, 20, 0, 20)
    end
    local function hideGui()
        main.Visible = false
        miniBtn.Visible = true
    end
    _G.__PrintedShowGui = showGui
    _G.__PrintedHideGui = hideGui
    _G.__PrintedMain = main
    closeBtn.Activated:Connect(hideGui)
    miniBtn.Activated:Connect(showGui)

    local pagesFrame = Instance.new("Frame", main)
    pagesFrame.Name = "Pages"
    pagesFrame.Size = UDim2.new(1, 0, 1, -106)
    pagesFrame.Position = UDim2.new(0, 0, 0, 62)
    pagesFrame.BackgroundTransparency = 1
    pagesFrame.BorderSizePixel = 0
    pagesFrame.ClipsDescendants = true

    local orderTabs = { "SPEED", "COMBAT", "VISUAL", "MISC", "BINDS" }
    PrintedI18n.orderTabs = orderTabs

    local pages = {}
    for i = 1, 5 do
        local sf = Instance.new("ScrollingFrame", pagesFrame)
        sf.Name = "Page" .. i
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.Position = UDim2.new(0, 0, 0, 0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ClipsDescendants = true
        sf.ScrollBarThickness = 0
        sf.ScrollBarImageTransparency = 1
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Visible = i == 1
        local layout = Instance.new("UIListLayout", sf)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 3)
        local pad = Instance.new("UIPadding", sf)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 7)
        pad.PaddingTop = UDim.new(0, 7)
        pad.PaddingBottom = UDim.new(0, 10)
        pages[i] = sf
    end

    local tabBar = Instance.new("Frame", main)
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -14, 0, 38)
    tabBar.Position = UDim2.new(0, 7, 1, -42)
    tabBar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    tabBar.BackgroundTransparency = 0.08
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 30
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(1, 0)
    local tabStroke = Instance.new("UIStroke", tabBar)
    tabStroke.Color = Color3.fromRGB(55, 90, 160)
    tabStroke.Thickness = 1.2
    tabStroke.Transparency = 0.45

    local tabButtons = {}
    local tabHolders = {}
    local switching = false

    local function selectTab(idx)
        if switching then return end
        playMenuSound("tab")
        for i = 1, #orderTabs do
            local b = tabButtons[i]
            if b then
                local active = i == idx
                local a = getAccent()
                TweenService:Create(b.bg, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = active and 0.05 or 1,
                    BackgroundColor3 = active and (a.tab or Color3.fromRGB(28, 90, 180)) or Color3.fromRGB(22, 22, 28),
                }):Play()
                TweenService:Create(b.lbl, TweenInfo.new(0.16), {
                    TextColor3 = active and Color3.fromRGB(255, 140, 255) or Color3.fromRGB(160, 165, 180),
                }):Play()
                local s = b.bg:FindFirstChild("TabStroke")
                if s then TweenService:Create(s, TweenInfo.new(0.16), { Transparency = active and 0.15 or 1 }):Play() end
            end
        end
        local page = pages[idx]
        if not page then return end
        for i = 1, #orderTabs do
            if i ~= idx and pages[i] then pages[i].Visible = false end
        end
        page.Visible = true
        page.CanvasPosition = Vector2.new(0, 0)
        page.Position = UDim2.new(0, 0, 0, 0)
        local scale = page:FindFirstChild("TabAnimScale")
        if not scale then
            scale = Instance.new("UIScale")
            scale.Name = "TabAnimScale"
            scale.Parent = page
        end
        scale.Scale = 0.985
        switching = true
        local t = TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
        t:Play()
        t.Completed:Connect(function() switching = false end)
        task.delay(0.18, function() switching = false end)
    end

    local tabPer = 1 / #orderTabs
    for i = 1, #orderTabs do
        local holder = Instance.new("Frame", tabBar)
        holder.Size = UDim2.new(tabPer, -8, 1, -6)
        holder.Position = UDim2.new(tabPer * (i - 1), 2, 0, 3)
        holder.BackgroundTransparency = 1
        holder.ZIndex = 31
        tabHolders[i] = holder
        local bg = Instance.new("Frame", holder)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(225, 225, 232)
        bg.BackgroundTransparency = i == 1 and 0 or 1
        bg.BorderSizePixel = 0
        bg.ZIndex = 31
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
        local grad = Instance.new("UIGradient", bg)
        grad.Color = ColorSequence.new(Color3.fromRGB(200, 255, 200), Color3.fromRGB(178, 182, 195))
        grad.Rotation = 90
        local lbl = Instance.new("TextLabel", holder)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = printedT(orderTabs[i])
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 12
        lbl.TextColor3 = i == 1 and Color3.new(1, 1, 1) or Color3.fromRGB(120, 155, 180)
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.ZIndex = 33
        PrintedI18n.tabLabels[i] = lbl
        local click = Instance.new("TextButton", holder)
        click.Size = UDim2.new(1, 0, 1, 0)
        click.BackgroundTransparency = 1
        click.Text = ""
        click.ZIndex = 34
        click.AutoButtonColor = false
        click.Activated:Connect(function() selectTab(i) end)
        tabButtons[i] = { bg = bg, lbl = lbl }
    end

    selectTab(1)

    -- SECTION BUILDERS
    local layoutOrder = 0
    local function nextOrder() layoutOrder = layoutOrder + 1 return layoutOrder end
    local currentPage = pages[1]

    local function addSection(name)
        currentPage = pages[({
            SPEED = 1, MOVEMENT = 1,
            COMBAT = 2, STEAL = 2,
            VISUAL = 3, BACKGROUND = 3, CHARTER = 3, ANIMATIONS = 3,
            MISC = 4, INTRO = 4, INTERFACE = 4,
            KEYBINDS = 5, BINDS = 5,
        })[name:upper()] or 4] or pages[4]
        local holder = Instance.new("Frame", currentPage)
        holder.Size = UDim2.new(1, 0, 0, 38)
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.LayoutOrder = nextOrder()
        local lbl = Instance.new("TextLabel", holder)
        lbl.Size = UDim2.new(1, -12, 0, 24)
        lbl.Position = UDim2.new(0, 8, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = (printedT(name)):upper()
        lbl.TextColor3 = Color3.fromRGB(160, 160, 250)
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 15
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextStrokeTransparency = 0.85
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        fn29(lbl, name)
        local line = Instance.new("Frame", holder)
        line.Size = UDim2.new(1, -16, 0, 2)
        line.Position = UDim2.new(0, 8, 1, -4)
        line.BackgroundColor3 = (getAccent().sect) or Color3.fromRGB(70, 120, 220)
        line.BackgroundTransparency = 0.35
        line.BorderSizePixel = 0
        _G.__PrintedSectLines = _G.__PrintedSectLines or {}
        table.insert(_G.__PrintedSectLines, line)
    end

    local function createRow(h)
        local row = Instance.new("Frame", currentPage)
        row.Size = UDim2.new(1, 0, 0, h or 38)
        row.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder()
        row.ClipsDescendants = true
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 14)
        Instance.new("UIStroke", row).Color = Color3.fromRGB(22, 22, 28)
        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(22, 22, 28) }):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(10, 10, 14) }):Play()
        end)
        return row
    end

    local function addRowLabel(row, text)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.58, 0, 1, 0)
        lbl.Position = UDim2.new(0, 9, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = printedT(text)
        lbl.TextColor3 = color5
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        fn29(lbl, text)
        return lbl
    end

    local function createToggle(row, offsetX)
        local bg = Instance.new("Frame", row)
        bg.Size = UDim2.new(0, 46, 0, 24)
        bg.Position = UDim2.new(1, -(offsetX or 56), 0.5, -12)
        bg.BackgroundColor3 = color7
        bg.BorderSizePixel = 0
        bg.ZIndex = 3
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
        local dot = Instance.new("Frame", bg)
        dot.Size = UDim2.new(0, 18, 0, 18)
        dot.Position = UDim2.new(0, 3, 0.5, -9)
        dot.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
        dot.BorderSizePixel = 0
        dot.ZIndex = 4
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        return bg, dot
    end

    local function applyToggleVisual(bg, dot, on)
        if not bg or not dot then return end
        local accent = getAccent()
        local tabColor = accent.tab or Color3.fromRGB(28, 60, 68)
        local knobColor = on and accent.stroke or Color3.fromRGB(90, 90, 100)
        if accent.stroke then knobColor = accent.stroke:Lerp(Color3.new(1, 1, 1), 0.3) end
        TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundColor3 = on and tabColor or color7 }):Play()
        TweenService:Create(dot, TweenInfo.new(0.18, Enum.EasingStyle.Back), {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            BackgroundColor3 = on and knobColor or Color3.fromRGB(90, 90, 100),
        }):Play()
        local grad = bg:FindFirstChild("AccentGrad")
        if on then
            if not grad then
                grad = Instance.new("UIGradient")
                grad.Name = "AccentGrad"
                grad.Parent = bg
            end
            if accent.grad then
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, accent.grad[1]),
                    ColorSequenceKeypoint.new(0.5, accent.grad[3]),
                    ColorSequenceKeypoint.new(1, accent.grad[5]),
                })
                grad.Rotation = 45
                grad.Enabled = true
            end
        elseif grad then
            grad.Enabled = false
        end
    end
    _G.PrintedApplyToggleVisual = applyToggleVisual

    -- Speed section
    addSection("SPEED")

    local normalRow = createRow(32)
    addRowLabel(normalRow, "Normal Speed")
    local normalBox
    normalBox = Instance.new("TextBox", normalRow)
    normalBox.Size = UDim2.new(0, 50, 0, 22)
    normalBox.Position = UDim2.new(1, -56, 0.5, -11)
    normalBox.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    normalBox.BorderSizePixel = 0
    normalBox.Text = "60"
    normalBox.TextColor3 = color5
    normalBox.Font = Enum.Font.GothamBold
    normalBox.TextSize = 11
    normalBox.ClearTextOnFocus = false
    normalBox.ZIndex = 5
    Instance.new("UICorner", normalBox).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", normalBox).Color = Color3.fromRGB(130, 30, 38)
    normalBox.FocusLost:Connect(function()
        local n = tonumber(normalBox.Text)
        if n and n > 0 and n <= 500 then NS = n end
        if fn40 then pcall(fn40) end
        if printedMarkDirty then printedMarkDirty() end
    end)

    local carryRow = createRow(32)
    addRowLabel(carryRow, "Carry Speed")
    local carryBox
    carryBox = Instance.new("TextBox", carryRow)
    carryBox.Size = UDim2.new(0, 50, 0, 22)
    carryBox.Position = UDim2.new(1, -56, 0.5, -11)
    carryBox.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    carryBox.BorderSizePixel = 0
    carryBox.Text = "30"
    carryBox.TextColor3 = color5
    carryBox.Font = Enum.Font.GothamBold
    carryBox.TextSize = 11
    carryBox.ClearTextOnFocus = false
    carryBox.ZIndex = 5
    Instance.new("UICorner", carryBox).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", carryBox).Color = Color3.fromRGB(130, 30, 38)
    carryBox.FocusLost:Connect(function()
        CS = clampCarrySpeed(tonumber(carryBox.Text))
        carryBox.Text = tostring(CS)
        if fn40 then pcall(fn40) end
        if printedMarkDirty then printedMarkDirty() end
    end)

    local laggerRow = createRow(32)
    addRowLabel(laggerRow, "Lagger Normal Speed")
    local laggerBox
    laggerBox = Instance.new("TextBox", laggerRow)
    laggerBox.Size = UDim2.new(0, 50, 0, 22)
    laggerBox.Position = UDim2.new(1, -56, 0.5, -11)
    laggerBox.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    laggerBox.BorderSizePixel = 0
    laggerBox.Text = "15"
    laggerBox.TextColor3 = color5
    laggerBox.Font = Enum.Font.GothamBold
    laggerBox.TextSize = 11
    laggerBox.ClearTextOnFocus = false
    laggerBox.ZIndex = 5
    Instance.new("UICorner", laggerBox).CornerRadius = UDim.new(1, 0)
    laggerBox.FocusLost:Connect(function()
        local n = tonumber(laggerBox.Text)
        if n and n > 0 and n <= 500 then LAGGER_SPEED = n end
        if fn40 then pcall(fn40) end
        if printedMarkDirty then printedMarkDirty() end
    end)

    local laggerCarryRow = createRow(32)
    addRowLabel(laggerCarryRow, "Lagger Carry Speed")
    local laggerCarryBox
    laggerCarryBox = Instance.new("TextBox", laggerCarryRow)
    laggerCarryBox.Size = UDim2.new(0, 50, 0, 22)
    laggerCarryBox.Position = UDim2.new(1, -56, 0.5, -11)
    laggerCarryBox.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    laggerCarryBox.BorderSizePixel = 0
    laggerCarryBox.Text = "24.5"
    laggerCarryBox.TextColor3 = color5
    laggerCarryBox.Font = Enum.Font.GothamBold
    laggerCarryBox.TextSize = 11
    laggerCarryBox.ClearTextOnFocus = false
    laggerCarryBox.ZIndex = 5
    Instance.new("UICorner", laggerCarryBox).CornerRadius = UDim.new(1, 0)
    laggerCarryBox.FocusLost:Connect(function()
        local n = tonumber(laggerCarryBox.Text)
        if n and n > 0 and n <= 500 then LAGGER_CARRY_SPEED = math.min(n, 28.9) end
        laggerCarryBox.Text = tostring(LAGGER_CARRY_SPEED)
        if fn40 then pcall(fn40) end
        if printedMarkDirty then printedMarkDirty() end
    end)

    local aimbotSpeedRow = createRow(32)
    addRowLabel(aimbotSpeedRow, "Aimbot Speed")
    local aimbotSpeedBox = Instance.new("TextBox", aimbotSpeedRow)
    aimbotSpeedBox.Size = UDim2.new(0, 50, 0, 22)
    aimbotSpeedBox.Position = UDim2.new(1, -56, 0.5, -11)
    aimbotSpeedBox.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    aimbotSpeedBox.BorderSizePixel = 0
    aimbotSpeedBox.Text = tostring(AIMBOT_SPEED or 58)
    aimbotSpeedBox.TextColor3 = color5
    aimbotSpeedBox.Font = Enum.Font.GothamBold
    aimbotSpeedBox.TextSize = 11
    aimbotSpeedBox.ClearTextOnFocus = false
    aimbotSpeedBox.ZIndex = 5
    Instance.new("UICorner", aimbotSpeedBox).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", aimbotSpeedBox).Color = Color3.fromRGB(130, 30, 38)
    aimbotSpeedBox.FocusLost:Connect(function()
        local n = tonumber(aimbotSpeedBox.Text)
        if n and n > 0 and n <= 500 then AIMBOT_SPEED = n end
        aimbotSpeedBox.Text = tostring(AIMBOT_SPEED)
        if printedMarkDirty then printedMarkDirty() end
    end)

    local lagAimbotRow = createRow(32)
    addRowLabel(lagAimbotRow, "Lagger Aimbot Speed")
    local lagAimbotBox = Instance.new("TextBox", lagAimbotRow)
    lagAimbotBox.Size = UDim2.new(0, 50, 0, 22)
    lagAimbotBox.Position = UDim2.new(1, -56, 0.5, -11)
    lagAimbotBox.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    lagAimbotBox.BorderSizePixel = 0
    lagAimbotBox.Text = tostring(LAGGER_AIMBOT_SPEED or 90)
    lagAimbotBox.TextColor3 = color5
    lagAimbotBox.Font = Enum.Font.GothamBold
    lagAimbotBox.TextSize = 11
    lagAimbotBox.ClearTextOnFocus = false
    lagAimbotBox.ZIndex = 5
    Instance.new("UICorner", lagAimbotBox).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", lagAimbotBox).Color = Color3.fromRGB(130, 30, 38)
    lagAimbotBox.FocusLost:Connect(function()
        local n = tonumber(lagAimbotBox.Text)
        if n and n > 0 and n <= 500 then LAGGER_AIMBOT_SPEED = n end
        lagAimbotBox.Text = tostring(LAGGER_AIMBOT_SPEED)
        if printedMarkDirty then printedMarkDirty() end
    end)

    local modeRow = createRow(32)
    addRowLabel(modeRow, "Mode")
    instance_speed = Instance.new("TextLabel", modeRow)
    instance_speed.Size = UDim2.new(0, 90, 1, 0)
    instance_speed.Position = UDim2.new(1, -94, 0, 0)
    instance_speed.BackgroundTransparency = 1
    instance_speed.Text = "Normal"
    instance_speed.TextColor3 = color3
    instance_speed.Font = Enum.Font.GothamBlack
    instance_speed.TextSize = 11
    instance_speed.TextXAlignment = Enum.TextXAlignment.Right
    instance = instance_speed
    local modeClick = Instance.new("TextButton", modeRow)
    modeClick.Size = UDim2.new(1, 0, 1, 0)
    modeClick.BackgroundTransparency = 1
    modeClick.Text = ""
    modeClick.ZIndex = 2
    modeClick.Activated:Connect(function()
        if _anyKeyListening then return end
        toggleCarryMode()
        if printedMarkDirty then printedMarkDirty() end
    end)
    refreshSpeedModeLabel()

    -- Combat section
    addSection("COMBAT")

    -- Body Lock
    local blRow = createRow(32)
    addRowLabel(blRow, "Body Lock")
    local blBg, blDot = createToggle(blRow)
    applyToggleVisual(blBg, blDot, false)
    local blClick = Instance.new("TextButton", blBg)
    blClick.Size = UDim2.new(1, 0, 1, 0)
    blClick.BackgroundTransparency = 1
    blClick.Text = ""
    blClick.ZIndex = 6
    blClick.Activated:Connect(function()
        bodyLockEnabled = not bodyLockEnabled
        _G.PrintedBodyLockEnabled = bodyLockEnabled
        if bodyLockEnabled then startBodyLock() else stopBodyLock() end
        applyToggleVisual(blBg, blDot, bodyLockEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    local blrRow = createRow(40)
    addRowLabel(blrRow, "Body Lock Range (9-20)")
    local blrBox = Instance.new("TextBox", blrRow)
    blrBox.Size = UDim2.new(0, 56, 0, 26)
    blrBox.Position = UDim2.new(1, -64, 0.5, -13)
    blrBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    blrBox.BorderSizePixel = 0
    blrBox.Text = "12"
    blrBox.TextColor3 = Color3.fromRGB(180, 230, 240)
    blrBox.Font = Enum.Font.GothamBold
    blrBox.TextSize = 12
    blrBox.ZIndex = 6
    blrBox.ClearTextOnFocus = false
    Instance.new("UICorner", blrBox).CornerRadius = UDim.new(0, 7)
    blrBox.FocusLost:Connect(function()
        local n = tonumber(blrBox.Text)
        if n then
            bodyLockRadius = math.clamp(n, 9, 20)
            blrBox.Text = tostring(bodyLockRadius)
            if printedMarkDirty then printedMarkDirty() end
        else
            blrBox.Text = tostring(math.clamp(tonumber(bodyLockRadius) or 12, 9, 20))
        end
    end)

    -- Anti Void
    local avRow = createRow(32)
    addRowLabel(avRow, "Anti Void")
    local avBg, avDot = createToggle(avRow)
    applyToggleVisual(avBg, avDot, false)
    local avClick = Instance.new("TextButton", avBg)
    avClick.Size = UDim2.new(1, 0, 1, 0)
    avClick.BackgroundTransparency = 1
    avClick.Text = ""
    avClick.ZIndex = 6
    avClick.Activated:Connect(function()
        antiVoidEnabled = not antiVoidEnabled
        if antiVoidEnabled then startAntiVoid() else stopAntiVoid() end
        applyToggleVisual(avBg, avDot, antiVoidEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Aimbot Mode
    local amRow = createRow(40)
    addRowLabel(amRow, "Aimbot Mode")
    local amChip = Instance.new("TextButton", amRow)
    amChip.Size = UDim2.new(0, 90, 0, 26)
    amChip.Position = UDim2.new(1, -100, 0.5, -13)
    amChip.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    amChip.BorderSizePixel = 0
    amChip.Text = "V1"
    amChip.TextColor3 = Color3.fromRGB(180, 204, 216)
    amChip.Font = Enum.Font.GothamBold
    amChip.TextSize = 11
    amChip.ZIndex = 5
    amChip.AutoButtonColor = false
    Instance.new("UICorner", amChip).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", amChip).Color = Color3.fromRGB(55, 80, 72)
    amChip.Activated:Connect(function()
        aimbotMode = (aimbotMode == "V1") and "V2" or "V1"
        amChip.Text = aimbotMode
        applyAimbotMode()
        if autoBatEnabled then
            pcall(disableAutoBat)
            autoBatEnabled = true
            pcall(enableAutoBat)
            if autoBatSetVisual then autoBatSetVisual(true) end
        end
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Auto Swing
    local asRow = createRow(32)
    addRowLabel(asRow, "Auto Swing")
    local asBg, asDot = createToggle(asRow)
    applyToggleVisual(asBg, asDot, false)
    local asClick = Instance.new("TextButton", asBg)
    asClick.Size = UDim2.new(1, 0, 1, 0)
    asClick.BackgroundTransparency = 1
    asClick.Text = ""
    asClick.ZIndex = 6
    asClick.Activated:Connect(function()
        autoSwingEnabled = not autoSwingEnabled
        applyToggleVisual(asBg, asDot, autoSwingEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- TP Cam Shake
    local tcsRow = createRow(32)
    addRowLabel(tcsRow, "TP Cam Shake")
    local tcsBg, tcsDot = createToggle(tcsRow)
    applyToggleVisual(tcsBg, tcsDot, false)
    local tcsClick = Instance.new("TextButton", tcsBg)
    tcsClick.Size = UDim2.new(1, 0, 1, 0)
    tcsClick.BackgroundTransparency = 1
    tcsClick.Text = ""
    tcsClick.ZIndex = 6
    tcsClick.Activated:Connect(function()
        tpBatCamShake = not tpBatCamShake
        applyToggleVisual(tcsBg, tcsDot, tpBatCamShake)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- TP Auto Swing
    local tasRow = createRow(32)
    addRowLabel(tasRow, "TP Auto Swing")
    local tasBg, tasDot = createToggle(tasRow)
    applyToggleVisual(tasBg, tasDot, false)
    local tasClick = Instance.new("TextButton", tasBg)
    tasClick.Size = UDim2.new(1, 0, 1, 0)
    tasClick.BackgroundTransparency = 1
    tasClick.Text = ""
    tasClick.ZIndex = 6
    tasClick.Activated:Connect(function()
        tpBatAutoSwing = not tpBatAutoSwing
        applyToggleVisual(tasBg, tasDot, tpBatAutoSwing)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Mirror TP Down
    local mtRow = createRow(32)
    addRowLabel(mtRow, "Mirror TP Down")
    local mtBg, mtDot = createToggle(mtRow)
    applyToggleVisual(mtBg, mtDot, false)
    local mtClick = Instance.new("TextButton", mtBg)
    mtClick.Size = UDim2.new(1, 0, 1, 0)
    mtClick.BackgroundTransparency = 1
    mtClick.Text = ""
    mtClick.ZIndex = 6
    mtClick.Activated:Connect(function()
        mirrorTPDownEnabled = not mirrorTPDownEnabled
        applyToggleVisual(mtBg, mtDot, mirrorTPDownEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Bat Counter
    local bcRow = createRow(32)
    addRowLabel(bcRow, "Bat Counter")
    local bcBg, bcDot = createToggle(bcRow)
    applyToggleVisual(bcBg, bcDot, false)
    local bcClick = Instance.new("TextButton", bcBg)
    bcClick.Size = UDim2.new(1, 0, 1, 0)
    bcClick.BackgroundTransparency = 1
    bcClick.Text = ""
    bcClick.ZIndex = 6
    bcClick.Activated:Connect(function()
        batCounterEnabled = not batCounterEnabled
        if batCounterEnabled then startBatCounter() else stopBatCounter() end
        applyToggleVisual(bcBg, bcDot, batCounterEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Anti Die
    local adRow = createRow(32)
    addRowLabel(adRow, "Anti Die")
    local adBg, adDot = createToggle(adRow)
    applyToggleVisual(adBg, adDot, false)
    local adClick = Instance.new("TextButton", adBg)
    adClick.Size = UDim2.new(1, 0, 1, 0)
    adClick.BackgroundTransparency = 1
    adClick.Text = ""
    adClick.ZIndex = 6
    adClick.Activated:Connect(function()
        antiDieEnabled = not antiDieEnabled
        if antiDieEnabled then startAntiDie() else stopAntiDie() end
        applyToggleVisual(adBg, adDot, antiDieEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Safe Mode
    local smRow = createRow(32)
    addRowLabel(smRow, "Safe Mode")
    local smBg, smDot = createToggle(smRow)
    applyToggleVisual(smBg, smDot, safeModeEnabled)
    local smClick = Instance.new("TextButton", smBg)
    smClick.Size = UDim2.new(1, 0, 1, 0)
    smClick.BackgroundTransparency = 1
    smClick.Text = ""
    smClick.ZIndex = 6
    smClick.Activated:Connect(function()
        safeModeEnabled = not safeModeEnabled
        applyToggleVisual(smBg, smDot, safeModeEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Steal section
    addSection("STEAL")

    -- Auto Grab
    local agRow = createRow(32)
    addRowLabel(agRow, "Auto Grab")
    local agBg, agDot = createToggle(agRow)
    applyToggleVisual(agBg, agDot, false)
    local agClick = Instance.new("TextButton", agBg)
    agClick.Size = UDim2.new(1, 0, 1, 0)
    agClick.BackgroundTransparency = 1
    agClick.Text = ""
    agClick.ZIndex = 6
    agClick.Activated:Connect(function()
        tbl19.AutoStealEnabled = not tbl19.AutoStealEnabled
        if tbl19.AutoStealEnabled then pcall(startAutoSteal) else pcall(stopAutoSteal) end
        applyToggleVisual(agBg, agDot, tbl19.AutoStealEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Steal Mode
    local sm2Row = createRow(40)
    addRowLabel(sm2Row, "Steal Mode")
    local sm2Chip = Instance.new("TextButton", sm2Row)
    sm2Chip.Size = UDim2.new(0, 90, 0, 26)
    sm2Chip.Position = UDim2.new(1, -100, 0.5, -13)
    sm2Chip.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    sm2Chip.BorderSizePixel = 0
    sm2Chip.Text = str7
    sm2Chip.TextColor3 = Color3.fromRGB(180, 204, 216)
    sm2Chip.Font = Enum.Font.GothamBold
    sm2Chip.TextSize = 11
    sm2Chip.ZIndex = 5
    sm2Chip.AutoButtonColor = false
    Instance.new("UICorner", sm2Chip).CornerRadius = UDim.new(0, 8)
    sm2Chip.Activated:Connect(function()
        str7 = (str7 == "Semi") and "Timing" or "Semi"
        sm2Chip.Text = str7
        pcall(applyStealMode)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Grab Radius
    local grRow = createRow(40)
    addRowLabel(grRow, "Grab Radius")
    local grBox = Instance.new("TextBox", grRow)
    grBox.Size = UDim2.new(0, 56, 0, 26)
    grBox.Position = UDim2.new(1, -64, 0.5, -13)
    grBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    grBox.BorderSizePixel = 0
    grBox.Text = "60"
    grBox.TextColor3 = Color3.fromRGB(230, 230, 240)
    grBox.Font = Enum.Font.GothamBold
    grBox.TextSize = 12
    grBox.ZIndex = 6
    grBox.ClearTextOnFocus = false
    Instance.new("UICorner", grBox).CornerRadius = UDim.new(0, 7)
    radInput = grBox
    grBox.FocusLost:Connect(function()
        local n = tonumber(grBox.Text)
        if n and n > 0 then
            tbl19.StealRadius = n
            n32 = n
            grBox.Text = tostring(n)
            if printedMarkDirty then printedMarkDirty() end
        end
    end)

    -- Misc section
    addSection("MISC")

    -- Infinite Jump
    local ijRow = createRow(32)
    addRowLabel(ijRow, "Infinite Jump")
    local ijBg, ijDot = createToggle(ijRow)
    applyToggleVisual(ijBg, ijDot, false)
    local ijClick = Instance.new("TextButton", ijBg)
    ijClick.Size = UDim2.new(1, 0, 1, 0)
    ijClick.BackgroundTransparency = 1
    ijClick.Text = ""
    ijClick.ZIndex = 6
    ijClick.Activated:Connect(function()
        infJumpEnabled = not infJumpEnabled
        if infJumpEnabled then
            if setInfJumpMode then setInfJumpMode(infJumpMode or "manual") end
        else
            if stopHoldToJump then stopHoldToJump() end
            pcall(stopJumpHoldState)
            pcall(stopHoldInfJump)
        end
        applyToggleVisual(ijBg, ijDot, infJumpEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Jump Mode
    local jmRow = createRow(40)
    addRowLabel(jmRow, "Jump Mode")
    local jmChip = Instance.new("TextButton", jmRow)
    jmChip.Size = UDim2.new(0, 90, 0, 26)
    jmChip.Position = UDim2.new(1, -100, 0.5, -13)
    jmChip.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    jmChip.BorderSizePixel = 0
    jmChip.Text = jumpMode
    jmChip.TextColor3 = Color3.fromRGB(180, 204, 216)
    jmChip.Font = Enum.Font.GothamBold
    jmChip.TextSize = 11
    jmChip.ZIndex = 5
    jmChip.AutoButtonColor = false
    Instance.new("UICorner", jmChip).CornerRadius = UDim.new(0, 8)
    jmChip.Activated:Connect(function()
        local newMode = (infJumpMode == "hold") and "manual" or "hold"
        if setInfJumpMode then setInfJumpMode(newMode) end
        jmChip.Text = jumpMode
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Anti Ragdoll
    local arRow = createRow(32)
    addRowLabel(arRow, "Anti Ragdoll")
    local arBg, arDot = createToggle(arRow)
    applyToggleVisual(arBg, arDot, false)
    local arClick = Instance.new("TextButton", arBg)
    arClick.Size = UDim2.new(1, 0, 1, 0)
    arClick.BackgroundTransparency = 1
    arClick.Text = ""
    arClick.ZIndex = 6
    arClick.Activated:Connect(function()
        antiRagdollEnabled = not antiRagdollEnabled
        if antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end
        applyToggleVisual(arBg, arDot, antiRagdollEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Medusa Counter
    local mcRow = createRow(32)
    addRowLabel(mcRow, "Medusa Counter")
    local mcBg, mcDot = createToggle(mcRow)
    applyToggleVisual(mcBg, mcDot, false)
    local mcClick = Instance.new("TextButton", mcBg)
    mcClick.Size = UDim2.new(1, 0, 1, 0)
    mcClick.BackgroundTransparency = 1
    mcClick.Text = ""
    mcClick.ZIndex = 6
    mcClick.Activated:Connect(function()
        medusaCounterEnabled = not medusaCounterEnabled
        if medusaCounterEnabled then pcall(setupMedusa, localPlayer.Character) end
        applyToggleVisual(mcBg, mcDot, medusaCounterEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Unwalk
    local uwRow = createRow(32)
    addRowLabel(uwRow, "Unwalk")
    local uwBg, uwDot = createToggle(uwRow)
    applyToggleVisual(uwBg, uwDot, false)
    local uwClick = Instance.new("TextButton", uwBg)
    uwClick.Size = UDim2.new(1, 0, 1, 0)
    uwClick.BackgroundTransparency = 1
    uwClick.Text = ""
    uwClick.ZIndex = 6
    uwClick.Activated:Connect(function()
        unwalkEnabled = not unwalkEnabled
        if unwalkEnabled then startUnwalk() else stopUnwalk() end
        applyToggleVisual(uwBg, uwDot, unwalkEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Visual section
    addSection("VISUAL")

    -- ESP
    local espRow = createRow(32)
    addRowLabel(espRow, "ESP")
    local espBg, espDot = createToggle(espRow)
    applyToggleVisual(espBg, espDot, false)
    local espClick = Instance.new("TextButton", espBg)
    espClick.Size = UDim2.new(1, 0, 1, 0)
    espClick.BackgroundTransparency = 1
    espClick.Text = ""
    espClick.ZIndex = 6
    espClick.Activated:Connect(function()
        espEnabled = not espEnabled
        if espEnabled then startPrintedESP() else stopPrintedESP() end
        applyToggleVisual(espBg, espDot, espEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Tracers
    local trRow = createRow(32)
    addRowLabel(trRow, "Tracers")
    local trBg, trDot = createToggle(trRow)
    applyToggleVisual(trBg, trDot, false)
    local trClick = Instance.new("TextButton", trBg)
    trClick.Size = UDim2.new(1, 0, 1, 0)
    trClick.BackgroundTransparency = 1
    trClick.Text = ""
    trClick.ZIndex = 6
    trClick.Activated:Connect(function()
        tracersEnabled = not tracersEnabled
        if tracersEnabled then startPrintedTracers() else stopPrintedTracers() end
        applyToggleVisual(trBg, trDot, tracersEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Intro
    local inRow = createRow(32)
    addRowLabel(inRow, "Intro")
    local inBg, inDot = createToggle(inRow)
    applyToggleVisual(inBg, inDot, _introEnabled ~= false)
    local inClick = Instance.new("TextButton", inBg)
    inClick.Size = UDim2.new(1, 0, 1, 0)
    inClick.BackgroundTransparency = 1
    inClick.Text = ""
    inClick.ZIndex = 6
    inClick.Activated:Connect(function()
        _introEnabled = not _introEnabled
        if not _introEnabled and stopIntroPlayback then stopIntroPlayback() end
        applyToggleVisual(inBg, inDot, _introEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Replay Intro
    local riRow = createRow(40)
    local riLabel = Instance.new("TextLabel", riRow)
    riLabel.Size = UDim2.new(0.45, 0, 1, 0)
    riLabel.Position = UDim2.new(0, 10, 0, 0)
    riLabel.BackgroundTransparency = 1
    riLabel.Text = "Replay Intro"
    riLabel.TextColor3 = Color3.fromRGB(200, 160, 130)
    riLabel.Font = Enum.Font.GothamBold
    riLabel.TextSize = 13
    riLabel.TextXAlignment = Enum.TextXAlignment.Left
    local riBtn = Instance.new("TextButton", riRow)
    riBtn.Size = UDim2.new(0, 100, 0, 26)
    riBtn.Position = UDim2.new(1, -110, 0.5, -13)
    riBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 130)
    riBtn.BorderSizePixel = 0
    riBtn.Text = "PLAY"
    riBtn.TextColor3 = Color3.fromRGB(200, 140, 230)
    riBtn.Font = Enum.Font.GothamBlack
    riBtn.TextSize = 12
    riBtn.ZIndex = 7
    riBtn.AutoButtonColor = false
    Instance.new("UICorner", riBtn).CornerRadius = UDim.new(0, 8)
    riBtn.Activated:Connect(function()
        if type(playIntroSequence) == "function" then pcall(playIntroSequence) end
    end)

    -- Intro Track
    local itRow = createRow(40)
    local itLabel = Instance.new("TextLabel", itRow)
    itLabel.Size = UDim2.new(0.42, 0, 1, 0)
    itLabel.Position = UDim2.new(0, 10, 0, 0)
    itLabel.BackgroundTransparency = 1
    itLabel.Text = "Intro Track"
    itLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    itLabel.Font = Enum.Font.GothamBold
    itLabel.TextSize = 13
    itLabel.TextXAlignment = Enum.TextXAlignment.Left
    local itBtn = Instance.new("TextButton", itRow)
    itBtn.Size = UDim2.new(0, 150, 0, 28)
    itBtn.Position = UDim2.new(1, -160, 0.5, -14)
    itBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
    itBtn.BorderSizePixel = 0
    itBtn.TextColor3 = Color3.fromRGB(170, 200, 255)
    itBtn.Font = Enum.Font.GothamBold
    itBtn.TextSize = 12
    itBtn.ZIndex = 7
    itBtn.AutoButtonColor = false
    Instance.new("UICorner", itBtn).CornerRadius = UDim.new(0, 8)
    local itStroke = Instance.new("UIStroke", itBtn)
    itStroke.Color = Color3.fromRGB(90, 130, 200)
    itStroke.Thickness = 1
    itBtn.Text = string.format("Track %d / %d", selectedIntroMusic, #INTRO_MUSIC_LINKS)
    itBtn.Activated:Connect(function()
        local n = #INTRO_MUSIC_LINKS
        selectedIntroMusic = (tonumber(selectedIntroMusic) or 1) % n + 1
        itBtn.Text = string.format("Track %d / %d", selectedIntroMusic, n)
        if printedMarkDirty then printedMarkDirty() end
        task.spawn(function()
            pcall(function()
                if type(previewIntroMusic) == "function" then previewIntroMusic(selectedIntroMusic)
                elseif type(createIntroSound) == "function" then
                    if stopIntroPreview then stopIntroPreview() end
                    createIntroSound(selectedIntroMusic)
                end
            end)
        end)
    end)

    -- Anti Lag
    local alRow = createRow(32)
    addRowLabel(alRow, "Anti Lag")
    local alBg, alDot = createToggle(alRow)
    applyToggleVisual(alBg, alDot, false)
    local alClick = Instance.new("TextButton", alBg)
    alClick.Size = UDim2.new(1, 0, 1, 0)
    alClick.BackgroundTransparency = 1
    alClick.Text = ""
    alClick.ZIndex = 6
    alClick.Activated:Connect(function()
        antiLagEnabled = not antiLagEnabled
        if antiLagEnabled then enableAntiLag() else disableAntiLag() end
        applyToggleVisual(alBg, alDot, antiLagEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Stretch Rez
    local srRow = createRow(32)
    addRowLabel(srRow, "Stretch Rez")
    local srBg, srDot = createToggle(srRow)
    applyToggleVisual(srBg, srDot, false)
    local srClick = Instance.new("TextButton", srBg)
    srClick.Size = UDim2.new(1, 0, 1, 0)
    srClick.BackgroundTransparency = 1
    srClick.Text = ""
    srClick.ZIndex = 6
    srClick.Activated:Connect(function()
        stretchRezEnabled = not stretchRezEnabled
        if stretchRezEnabled then enableStretchRez() else disableStretchRez() end
        applyToggleVisual(srBg, srDot, stretchRezEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Theme (accent)
    addSection("Accent Color")
    local acRow = createRow(40)
    addRowLabel(acRow, "Theme")
    local acChip = Instance.new("TextButton", acRow)
    acChip.Size = UDim2.new(0, 100, 0, 26)
    acChip.Position = UDim2.new(1, -110, 0.5, -13)
    acChip.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    acChip.BorderSizePixel = 0
    acChip.Text = tostring(_G.PrintedAccentTheme or "Blue")
    acChip.TextColor3 = Color3.fromRGB(180, 204, 216)
    acChip.Font = Enum.Font.GothamBold
    acChip.TextSize = 11
    acChip.ZIndex = 5
    acChip.AutoButtonColor = false
    Instance.new("UICorner", acChip).CornerRadius = UDim.new(0, 8)
    acChip.Activated:Connect(function()
        local themes = { "Blue", "Silver", "Pink", "Green", "Gold" }
        local idx = 1
        for i, t in ipairs(themes) do
            if t == _G.PrintedAccentTheme then idx = i break end
        end
        _G.PrintedAccentTheme = themes[idx % #themes + 1]
        acChip.Text = _G.PrintedAccentTheme
        if _G.PrintedApplyAccentTheme then _G.PrintedApplyAccentTheme() end
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Button Mode
    addSection("Button Mode")
    local bmRow = createRow(40)
    addRowLabel(bmRow, "Button Mode")
    local bmChip = Instance.new("TextButton", bmRow)
    bmChip.Size = UDim2.new(0, 100, 0, 26)
    bmChip.Position = UDim2.new(1, -110, 0.5, -13)
    bmChip.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    bmChip.BorderSizePixel = 0
    bmChip.Text = tostring(_G.PrintedButtonMode or "Gradient")
    bmChip.TextColor3 = Color3.fromRGB(180, 204, 216)
    bmChip.Font = Enum.Font.GothamBold
    bmChip.TextSize = 11
    bmChip.ZIndex = 5
    bmChip.AutoButtonColor = false
    Instance.new("UICorner", bmChip).CornerRadius = UDim.new(0, 8)
    bmChip.Activated:Connect(function()
        _G.PrintedButtonMode = (_G.PrintedButtonMode == "Gradient") and "Background" or "Gradient"
        bmChip.Text = _G.PrintedButtonMode
        if _G.PrintedApplyButtonMode then _G.PrintedApplyButtonMode(_G.PrintedButtonMode) end
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Background
    addSection("Background")
    local bgRow = createRow(56)
    local bgLabel = Instance.new("TextLabel", bgRow)
    bgLabel.Size = UDim2.new(0.4, 0, 1, 0)
    bgLabel.Position = UDim2.new(0, 10, 0, 0)
    bgLabel.BackgroundTransparency = 1
    bgLabel.Text = "Background"
    bgLabel.TextColor3 = color5
    bgLabel.Font = Enum.Font.GothamBold
    bgLabel.TextSize = 13
    bgLabel.TextXAlignment = Enum.TextXAlignment.Left
    local bgIds = {
        "90631990302263", "109619268613730", "88369503310562",
        "80708025126373", "102253425322931", "90453834580322",
        "135181794444219", "137260740069569", "102579945729223",
    }
    if type(currentBackground) ~= "number" or currentBackground < 1 then currentBackground = 1 end
    local bgScroll = Instance.new("ScrollingFrame", bgRow)
    bgScroll.Size = UDim2.new(1, -12, 1, -10)
    bgScroll.Position = UDim2.new(0, 6, 0, 5)
    bgScroll.BackgroundTransparency = 1
    bgScroll.BorderSizePixel = 0
    bgScroll.ScrollBarThickness = 0
    bgScroll.ScrollingDirection = Enum.ScrollingDirection.X
    bgScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    bgScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    bgScroll.ZIndex = 5
    local bgLayout = Instance.new("UIListLayout", bgScroll)
    bgLayout.FillDirection = Enum.FillDirection.Horizontal
    bgLayout.Padding = UDim.new(0, 6)
    bgLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    _G.__PrintedBgThumbs = {}
    for i, id in ipairs(bgIds) do
        local thumb = Instance.new("ImageButton", bgScroll)
        thumb.Name = "BgThumb" .. i
        thumb.Size = UDim2.new(0, 52, 0, 40)
        thumb.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
        thumb.BorderSizePixel = 0
        thumb.Image = "rbxassetid://" .. id
        thumb.ScaleType = Enum.ScaleType.Crop
        pcall(function() ContentProvider:PreloadAsync({ thumb }) end)
        thumb.ImageTransparency = 0.25
        thumb.AutoButtonColor = false
        thumb.ZIndex = 6
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", thumb)
        s.Color = Color3.fromRGB(70, 70, 80)
        s.Thickness = 1
        s.Transparency = 0.45
        _G.__PrintedBgThumbs[i] = thumb
        thumb.Activated:Connect(function()
            currentBackground = i
            if _G.PrintedSetBg then _G.PrintedSetBg(id) end
            if _G.__PrintedBgThumbs then
                for j, t in ipairs(_G.__PrintedBgThumbs) do
                    if t and t.Parent then
                        local st = t:FindFirstChildOfClass("UIStroke")
                        local active = j == i
                        if st then
                            st.Color = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(70, 70, 80)
                            st.Thickness = active and 1.8 or 1
                            st.Transparency = active and 0 or 0.4
                        end
                        t.ImageTransparency = active and 0 or 0.28
                    end
                end
            end
            if printedMarkDirty then printedMarkDirty() end
        end)
    end
    task.defer(function()
        task.wait(0.1)
        if _G.PrintedSetBg then _G.PrintedSetBg(bgIds[currentBackground]) end
    end)

    -- Charter
    addSection("CHARTER")
    local hdRow = createRow(32)
    addRowLabel(hdRow, "Headless")
    local hdBg, hdDot = createToggle(hdRow)
    applyToggleVisual(hdBg, hdDot, false)
    local hdClick = Instance.new("TextButton", hdBg)
    hdClick.Size = UDim2.new(1, 0, 1, 0)
    hdClick.BackgroundTransparency = 1
    hdClick.Text = ""
    hdClick.ZIndex = 6
    hdClick.Activated:Connect(function()
        headless = not headless
        applyHeadlessToChar(localPlayer.Character, headless)
        applyToggleVisual(hdBg, hdDot, headless)
        if printedMarkDirty then printedMarkDirty() end
    end)

    local kbRow = createRow(32)
    addRowLabel(kbRow, "Korblox")
    local kbBg, kbDot = createToggle(kbRow)
    applyToggleVisual(kbBg, kbDot, false)
    local kbClick = Instance.new("TextButton", kbBg)
    kbClick.Size = UDim2.new(1, 0, 1, 0)
    kbClick.BackgroundTransparency = 1
    kbClick.Text = ""
    kbClick.ZIndex = 6
    kbClick.Activated:Connect(function()
        korblox = not korblox
        applyKorbloxToChar(localPlayer.Character, korblox)
        applyToggleVisual(kbBg, kbDot, korblox)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Animation pack
    local apRow = createRow(40)
    addRowLabel(apRow, "Animation Pack")
    local apChip = Instance.new("TextButton", apRow)
    apChip.Size = UDim2.new(0, 130, 0, 26)
    apChip.Position = UDim2.new(1, -140, 0.5, -13)
    apChip.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    apChip.BorderSizePixel = 0
    apChip.Text = animPack
    apChip.TextColor3 = Color3.fromRGB(180, 204, 216)
    apChip.Font = Enum.Font.GothamBold
    apChip.TextSize = 11
    apChip.ZIndex = 5
    apChip.AutoButtonColor = false
    Instance.new("UICorner", apChip).CornerRadius = UDim.new(0, 8)
    local animList = {}
    for k in pairs(animPacks) do table.insert(animList, k) end
    table.sort(animList)
    local apIdx = 1
    for i, k in ipairs(animList) do if k == animPack then apIdx = i break end end
    apChip.Activated:Connect(function()
        apIdx = apIdx % #animList + 1
        animPack = animList[apIdx]
        apChip.Text = animPack
        if animPackEnabled then pcall(applyAnimPack, animPack) end
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Enable anim pack toggle
    local apeRow = createRow(32)
    addRowLabel(apeRow, "Enable Pack")
    local apeBg, apeDot = createToggle(apeRow)
    applyToggleVisual(apeBg, apeDot, false)
    local apeClick = Instance.new("TextButton", apeBg)
    apeClick.Size = UDim2.new(1, 0, 1, 0)
    apeClick.BackgroundTransparency = 1
    apeClick.Text = ""
    apeClick.ZIndex = 6
    apeClick.Activated:Connect(function()
        animPackEnabled = not animPackEnabled
        if animPackEnabled then pcall(applyAnimPack, animPack) end
        applyToggleVisual(apeBg, apeDot, animPackEnabled)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Interface section
    addSection("Interface")
    local lkRow = createRow(32)
    addRowLabel(lkRow, "Lock GUI")
    local lkBg, lkDot = createToggle(lkRow)
    applyToggleVisual(lkBg, lkDot, uiLocked)
    _G.__PrintedLockToggleBg = lkBg
    _G.__PrintedLockToggleDot = lkDot
    local lkClick = Instance.new("TextButton", lkBg)
    lkClick.Size = UDim2.new(1, 0, 1, 0)
    lkClick.BackgroundTransparency = 1
    lkClick.Text = ""
    lkClick.ZIndex = 6
    lkClick.Activated:Connect(function()
        uiLocked = not uiLocked
        _G.PrintedRefreshLockBtn()
        applyToggleVisual(lkBg, lkDot, uiLocked)
        -- force immediate save so lock ALWAYS persists on re-execute
        _printedConfigDirty = true
        pcall(printedSaveConfig)
        if printedMarkDirty then printedMarkDirty() end
    end)

    local hmRow = createRow(32)
    addRowLabel(hmRow, "Hide Mobile Buttons")
    local hmBg, hmDot = createToggle(hmRow)
    applyToggleVisual(hmBg, hmDot, hideMobileButtons)
    _G.__PrintedHideMobToggleBg = hmBg
    _G.__PrintedHideMobToggleDot = hmDot
    local hmClick = Instance.new("TextButton", hmBg)
    hmClick.Size = UDim2.new(1, 0, 1, 0)
    hmClick.BackgroundTransparency = 1
    hmClick.Text = ""
    hmClick.ZIndex = 6
    hmClick.Activated:Connect(function()
        hideMobileButtons = not hideMobileButtons
        fn41()
        applyToggleVisual(hmBg, hmDot, hideMobileButtons)
        _printedConfigDirty = true
        pcall(printedSaveConfig)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Buttons as panel
    local bpRow = createRow(32)
    addRowLabel(bpRow, "Buttons as Panel")
    local bpBg, bpDot = createToggle(bpRow)
    applyToggleVisual(bpBg, bpDot, _G.PrintedMobileButtonsPanel == true)
    local bpClick = Instance.new("TextButton", bpBg)
    bpClick.Size = UDim2.new(1, 0, 1, 0)
    bpClick.BackgroundTransparency = 1
    bpClick.Text = ""
    bpClick.ZIndex = 6
    bpClick.Activated:Connect(function()
        _G.PrintedMobileButtonsPanel = not (_G.PrintedMobileButtonsPanel == true)
        if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
        applyToggleVisual(bpBg, bpDot, _G.PrintedMobileButtonsPanel == true)
        -- force save panel mode + current group pos immediately
        if type(mobileGroupPosition) ~= "table" then mobileGroupPosition = {} end
        pcall(function()
            if v88 then
                local cont = v88:FindFirstChild("ButtonContainer")
                if cont then
                    mobileGroupPosition = {
                        xs = cont.Position.X.Scale, x = cont.Position.X.Offset,
                        ys = cont.Position.Y.Scale, y = cont.Position.Y.Offset,
                    }
                end
            end
        end)
        _printedConfigDirty = true
        pcall(printedSaveConfig)
        if printedMarkDirty then printedMarkDirty() end
    end)

    -- Reset button
    local rsRow = createRow(40)
    local rsLabel = Instance.new("TextLabel", rsRow)
    rsLabel.Size = UDim2.new(1, -70, 1, 0)
    rsLabel.Position = UDim2.new(0, 10, 0, 0)
    rsLabel.BackgroundTransparency = 1
    rsLabel.Text = "Reset All Settings"
    rsLabel.TextColor3 = Color3.fromRGB(220, 160, 230)
    rsLabel.Font = Enum.Font.Gotham
    rsLabel.TextSize = 12
    rsLabel.TextXAlignment = Enum.TextXAlignment.Left
    local rsBtn = Instance.new("TextButton", rsRow)
    rsBtn.Size = UDim2.new(0, 64, 0, 24)
    rsBtn.Position = UDim2.new(1, -74, 0.5, -12)
    rsBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 90)
    rsBtn.BorderSizePixel = 0
    rsBtn.Text = "RESET"
    rsBtn.TextColor3 = Color3.new(1, 1, 1)
    rsBtn.Font = Enum.Font.GothamBlack
    rsBtn.TextSize = 11
    rsBtn.AutoButtonColor = false
    Instance.new("UICorner", rsBtn).CornerRadius = UDim.new(0, 7)
    rsBtn.Activated:Connect(function()
        if _anyKeyListening then return end
        _G.printedConfirm("ARE U SURE?", function()
            if _G.PrintedResetAllSettings then pcall(_G.PrintedResetAllSettings) end
        end)
    end)

    -- ========== KEYBINDS SECTION ==========
    addSection("KEYBINDS")
    for _, entry in ipairs(tbl18) do
        local row = createRow(32)
        addRowLabel(row, entry.label)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 34, 0, 16)
        btn.Position = UDim2.new(1, -56, 0.5, -8)
        btn.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        btn.BorderSizePixel = 0
        btn.Text = tbl17[entry.id].kb and tbl17[entry.id].kb.Name or "None"
        btn.TextColor3 = color5
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 8
        btn.ZIndex = 5
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local clearBtn = Instance.new("TextButton", row)
        clearBtn.Size = UDim2.new(0, 16, 0, 16)
        clearBtn.Position = UDim2.new(1, -18, 0.5, -8)
        clearBtn.BackgroundColor3 = Color3.fromRGB(130, 14, 16)
        clearBtn.BorderSizePixel = 0
        clearBtn.Text = "X"
        clearBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
        clearBtn.Font = Enum.Font.GothamBlack
        clearBtn.TextSize = 11
        clearBtn.ZIndex = 6
        clearBtn.AutoButtonColor = false
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(1, 0)

        local listening = false
        local listenConn = nil
        local savedText = btn.Text
        local downTime = 0

        local function stopListen(restore)
            if not listening then return end
            listening = false
            _anyKeyListening = false
            if listenConn then listenConn:Disconnect() listenConn = nil end
            if restore then btn.Text = savedText end
            btn.TextColor3 = color5
        end

        clearBtn.Activated:Connect(function()
            if listening then stopListen(true) end
            tbl17[entry.id].kb = nil
            tbl17[entry.id].gp = nil
            btn.Text = "None"
            savedText = "None"
            if _G.PrintedRefreshKBLabels then _G.PrintedRefreshKBLabels() end
            if printedMarkDirty then printedMarkDirty() end
        end)

        btn.Activated:Connect(function()
            if listening then stopListen(true) return end
            savedText = btn.Text
            listening = true
            _anyKeyListening = true
            downTime = tick()
            btn.Text = "..."
            btn.TextColor3 = Color3.new(1, 1, 1)
            listenConn = UserInputService.InputBegan:Connect(function(input)
                if not listening then return end
                if input.KeyCode == Enum.KeyCode.Escape then stopListen(true) return end
                local isGamepad = input.UserInputType and tostring(input.UserInputType.Name):match("^Gamepad") ~= nil
                if isGamepad and tick() - downTime < 0.15 then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard and not isGamepad then return end
                if isGamepad then
                    tbl17[entry.id].gp = input.KeyCode
                    tbl17[entry.id].kb = nil
                else
                    tbl17[entry.id].kb = input.KeyCode
                    tbl17[entry.id].gp = nil
                end
                btn.Text = input.KeyCode.Name
                savedText = btn.Text
                stopListen(false)
                if _G.PrintedRefreshKBLabels then _G.PrintedRefreshKBLabels() end
                if printedMarkDirty then printedMarkDirty() end
            end)
        end)
    end

    _G.PrintedRefreshKBLabels = function()
        -- no-op placeholder, real binds update via closures above
    end

    -- ========== DRAG ==========
    local mainDrag, mainStart, mainPos = false, nil, nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if uiLocked then return end
            mainDrag = true
            mainStart = input.Position
            mainPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then mainDrag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if mainDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - mainStart
            main.Position = UDim2.new(mainPos.X.Scale, mainPos.X.Offset + d.X, mainPos.Y.Scale, mainPos.Y.Offset + d.Y)
        end
    end)
    -- save main position when drag ends
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if mainDrag then
                mainDrag = false
                if printedSavePositionsNow then printedSavePositionsNow()
                elseif printedMarkDirty then printedMarkDirty() end
            end
        end
    end)

    local miniDrag, miniStart, miniPos = false, nil, nil
    miniBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if uiLocked then return end
            miniDrag = true
            miniStart = input.Position
            miniPos = miniBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then miniDrag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if miniDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - miniStart
            miniBtn.Position = UDim2.new(miniPos.X.Scale, miniPos.X.Offset + d.X, miniPos.Y.Scale, miniPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if miniDrag then
                miniDrag = false
                if printedSavePositionsNow then printedSavePositionsNow()
                elseif printedMarkDirty then printedMarkDirty() end
            end
        end
    end)

    -- UI Layout button
    local layouts = { "side", "bottom", "top", "scroll" }
    local layoutIdx = 1
    uiBtn.Activated:Connect(function()
        layoutIdx = layoutIdx % #layouts + 1
        _G.PrintedUILayout = layouts[layoutIdx]
        if printedMarkDirty then printedMarkDirty() end
    end)

    buildStealBar(sg)

    _G._PrintedBG = {
        pages = pages,
        pageHolder = pagesFrame,
        tabBar = tabBar,
        main = main,
        gui = sg,
        sf = pages[1],
        tabBtns = tabButtons,
        tabHolders = tabHolders,
        selectTab = selectTab,
    }

    _G.PrintedResetAllSettings = function()
        print("[Printed] Reset all settings")
        NS = 60
        CS = 30
        LAGGER_SPEED = 15
        LAGGER_CARRY_SPEED = 24.5
        speedMode = false
        laggerToggled = false
        laggerPhase = 0
        antiRagdollEnabled = false
        infJumpEnabled = false
        medusaCounterEnabled = false
        batCounterEnabled = false
        unwalkEnabled = false
        autoLeftEnabled = false
        autoRightEnabled = false
        autoBatEnabled = false
        autoSwingEnabled = true
        antiLagEnabled = false
        stretchRezEnabled = false
        autoTPEnabled = false
        autoTPHeight = 20
        tpBatEnabled = false
        espEnabled = false
        tracersEnabled = false
        safeModeEnabled = true
        tbl19.AutoStealEnabled = false
        str7 = "Semi"
        headless = false
        korblox = false
        animPackEnabled = false
        animPack = "Hit Harder"
        uiLocked = false
        hideMobileButtons = false
        bodyLockEnabled = false
        antiVoidEnabled = false
        antiDieEnabled = false
        if PrintedESP then PrintedESP.enabled = false end
        if PrintedTracer then PrintedTracer.enabled = false end
    end

    return sg
end

-- ============================================================
-- BOOT (FIXED ORDER: load config FIRST so lock/panel/scale stick)
-- ============================================================
_G.PrintedGuiScale = _G.PrintedGuiScale or 0.82
_G.PrintedBtnScale = _G.PrintedBtnScale or 1.0
_G.PrintedBarScale = _G.PrintedBarScale or 1
_G.PrintedAccentTheme = _G.PrintedAccentTheme or "Blue"
_G.PrintedButtonMode = _G.PrintedButtonMode or "Gradient"
_G.PrintedBtnTheme = _G.PrintedBtnTheme or 0
_G.PrintedToggleSoundVersion = _G.PrintedToggleSoundVersion or "V1"
_G.PrintedLanguage = _G.PrintedLanguage or "en"
_G.PrintedMobileButtonsPanel = _G.PrintedMobileButtonsPanel or false

selectedIntroMusic = tonumber(selectedIntroMusic) or 1
if selectedIntroMusic < 1 then selectedIntroMusic = 1 end
if #INTRO_MUSIC_LINKS < selectedIntroMusic then selectedIntroMusic = 1 end

print("[Printed] loading...")

-- ========== STEP 1: EARLY LOAD config into globals BEFORE any GUI ==========
-- This is the real fix — lock / panel / scale / positions are set before build
local function earlyLoadConfigGlobals()
    local rf = _printed_readfile or readfile or (syn and syn.readfile) or (getgenv and getgenv().readfile)
    local isf = _printed_isfile or isfile or (syn and syn.isfile) or (getgenv and getgenv().isfile)
    if type(rf) ~= "function" then return false end
    local ok, data = pcall(function()
        if isf and not isf(PRINTED_CONFIG_FILE) then return nil end
        local raw = rf(PRINTED_CONFIG_FILE)
        if not raw or raw == "" then return nil end
        return HttpService:JSONDecode(raw)
    end)
    if not ok or type(data) ~= "table" then return false end

    local function n(v, d) local t = tonumber(v); return t or d end
    local function b(v, d) if v == nil then return d end return v and true or false end

    -- critical UI state first
    uiLocked = b(data.uiLocked, false)
    hideMobileButtons = b(data.hideMobileButtons, false)
    _G.PrintedMobileButtonsPanel = b(data.mobileButtonsPanel, false)
    mobileButtonScaleValue = n(data.mobileButtonScaleValue or data.btnScale, 1.0)
    _G.PrintedBtnScale = mobileButtonScaleValue
    if type(data.mobileButtonPositions) == "table" then
        mobileButtonPositions = data.mobileButtonPositions
    end
    if type(data.mobileGroupPosition) == "table" then
        mobileGroupPosition = data.mobileGroupPosition
    end
    _G.PrintedGuiScale = n(data.guiScale, 0.82)
    _G.PrintedBarScale = n(data.barScale, 1)
    _G.PrintedAccentTheme = tostring(data.accentTheme or "Blue")
    _G.PrintedButtonMode = tostring(data.buttonMode or "Gradient")
    _G.PrintedBtnTheme = n(data.btnTheme, 0)

    -- store positions for later apply after GUI exists
    _G.__PrintedSavedStealPos = data.stealBarPosition
    _G.__PrintedSavedStealDragged = data.stealBarDragged == true
    _G.__PrintedSavedMainPos = data.mainGuiPosition
    _G.__PrintedSavedMiniPos = data.miniBtnPosition

    print("[Printed] early config loaded | lock=" .. tostring(uiLocked) .. " panel=" .. tostring(_G.PrintedMobileButtonsPanel) .. " btnScale=" .. tostring(mobileButtonScaleValue))
    return true
end

local earlyOk = false
pcall(function() earlyOk = earlyLoadConfigGlobals() end)
if not earlyOk then
    print("[Printed] no early config / using defaults")
end

-- ========== STEP 2: build main GUI (lock button already sees correct uiLocked) ==========
local _printedGuiOk, _printedGuiErr = pcall(buildGui)
if _printedGuiOk then
    print("[Printed] gui built")
else
    warn("[Printed] GUI build failed: " .. tostring(_printedGuiErr))
end

-- Force steal bar
task.defer(function()
    task.wait(0.15)
    pcall(function()
        if not (_G.__PrintedStealGui and _G.__PrintedStealGui.Parent and _G.__PrintedBarFrame) then
            local sg = (_G._PrintedBG and _G._PrintedBG.gui) or nil
            buildStealBar(sg)
        end
        if _G.__PrintedBarFrame then
            _G.__PrintedBarFrame.Visible = true
            _G.__PrintedBarFrame.AnchorPoint = Vector2.new(0.5, 1)
            if type(_G.__PrintedSavedStealPos) == "table" then
                local d = _G.__PrintedSavedStealPos
                _G.__PrintedBarFrame.Position = UDim2.new(tonumber(d.xs) or 0.5, tonumber(d.x) or 0, tonumber(d.ys) or 1, tonumber(d.y) or -28)
                if _G.__PrintedSavedStealDragged then
                    _G.__PrintedBarFrame:SetAttribute("UserDragged", true)
                end
            else
                _G.__PrintedBarFrame.Position = UDim2.new(0.5, 0, 1, -28)
            end
        end
        if _G.setStealProgress then _G.setStealProgress(0) end
    end)
end)

-- ========== STEP 3: create mobile panel (uses already-loaded scale + panel + positions) ==========
task.defer(function()
    task.wait(0.08)
    pcall(createMobilePanel)
    -- force panel mode + scale right after create
    if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
    if _G.__PrintedBtnScaleObj then
        _G.__PrintedBtnScaleObj.Scale = tonumber(mobileButtonScaleValue) or 1.0
    end
    if type(mobileGroupPosition) == "table" and v88 then
        local cont = v88:FindFirstChild("ButtonContainer")
        if cont then
            cont.Position = UDim2.new(
                tonumber(mobileGroupPosition.xs) or 0.5, tonumber(mobileGroupPosition.x) or 0,
                tonumber(mobileGroupPosition.ys) or 0.5, tonumber(mobileGroupPosition.y) or 0
            )
        end
    end
    if type(mobileButtonPositions) == "table" and _G.PrintedMobileButtonsPanel ~= true then
        for name, pos in pairs(mobileButtonPositions) do
            local d = mobileButtonFrames and mobileButtonFrames[name]
            if d and d.frame and type(pos) == "table" then
                d.frame.Position = UDim2.new(tonumber(pos.xs) or 0, tonumber(pos.x) or 0, tonumber(pos.ys) or 0, tonumber(pos.y) or 0)
            end
        end
    end
    if v88 then v88.Enabled = not hideMobileButtons end
    if _G.PrintedApplyAccentTheme then pcall(_G.PrintedApplyAccentTheme) end
    if _G.PrintedApplyButtonMode then pcall(_G.PrintedApplyButtonMode, _G.PrintedButtonMode or "Gradient") end
    if _G.PrintedApplyBtnTheme then pcall(_G.PrintedApplyBtnTheme) end
    pcall(fn41)
end)

-- ========== STEP 4: full printedLoadConfig + force visuals ==========
task.spawn(function()
    task.wait(0.35)
    local ok = false
    pcall(function() ok = printedLoadConfig() end)
    if ok then
        print("[Printed] full config applied")
    end
    task.wait(0.12)
    pcall(function()
        -- main / mini positions
        if type(_G.__PrintedSavedMainPos) == "table" then
            local m = _G.__PrintedMainFrame or _G.__PrintedMain
            if m then
                local d = _G.__PrintedSavedMainPos
                m.Position = UDim2.new(tonumber(d.xs) or 0, tonumber(d.x) or 16, tonumber(d.ys) or 0, tonumber(d.y) or 16)
            end
        end
        if type(_G.__PrintedSavedMiniPos) == "table" then
            local m = _G.__PrintedMiniBtn or _G.__PrintedMini
            if m then
                local d = _G.__PrintedSavedMiniPos
                m.Position = UDim2.new(tonumber(d.xs) or 0, tonumber(d.x) or 26, tonumber(d.ys) or 0, tonumber(d.y) or 26)
            end
        end
        -- lock visual
        if _G.PrintedRefreshLockBtn then pcall(_G.PrintedRefreshLockBtn) end
        if _G.__PrintedLockToggleBg and _G.__PrintedLockToggleDot and _G.PrintedApplyToggleVisual then
            pcall(_G.PrintedApplyToggleVisual, _G.__PrintedLockToggleBg, _G.__PrintedLockToggleDot, uiLocked == true)
        end
        if _G.__PrintedHideMobToggleBg and _G.__PrintedHideMobToggleDot and _G.PrintedApplyToggleVisual then
            pcall(_G.PrintedApplyToggleVisual, _G.__PrintedHideMobToggleBg, _G.__PrintedHideMobToggleDot, hideMobileButtons == true)
        end
        -- mobile panel mode + scale + positions (again after full load)
        if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
        if _G.__PrintedBtnScaleObj then
            local sc = tonumber(mobileButtonScaleValue) or tonumber(_G.PrintedBtnScale) or 1.0
            _G.__PrintedBtnScaleObj.Scale = sc
            mobileButtonScaleValue = sc
            _G.PrintedBtnScale = sc
        end
        if type(mobileGroupPosition) == "table" and v88 then
            local cont = v88:FindFirstChild("ButtonContainer")
            if cont then
                cont.Position = UDim2.new(
                    tonumber(mobileGroupPosition.xs) or 0.5, tonumber(mobileGroupPosition.x) or 0,
                    tonumber(mobileGroupPosition.ys) or 0.5, tonumber(mobileGroupPosition.y) or 0
                )
            end
        end
        if type(mobileButtonPositions) == "table" and _G.PrintedMobileButtonsPanel ~= true then
            for name, pos in pairs(mobileButtonPositions) do
                local d = mobileButtonFrames and mobileButtonFrames[name]
                if d and d.frame and type(pos) == "table" then
                    d.frame.Position = UDim2.new(tonumber(pos.xs) or 0, tonumber(pos.x) or 0, tonumber(pos.ys) or 0, tonumber(pos.y) or 0)
                end
            end
        end
        if v88 then v88.Enabled = not hideMobileButtons end
        pcall(fn41)
    end)

    -- second force pass (race-condition killer)
    task.delay(0.5, function()
        pcall(function()
            if _G.PrintedRefreshLockBtn then pcall(_G.PrintedRefreshLockBtn) end
            if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
            if _G.__PrintedBtnScaleObj then
                _G.__PrintedBtnScaleObj.Scale = tonumber(mobileButtonScaleValue) or 1.0
            end
            if type(mobileGroupPosition) == "table" and v88 then
                local cont = v88:FindFirstChild("ButtonContainer")
                if cont then
                    cont.Position = UDim2.new(
                        tonumber(mobileGroupPosition.xs) or 0.5, tonumber(mobileGroupPosition.x) or 0,
                        tonumber(mobileGroupPosition.ys) or 0.5, tonumber(mobileGroupPosition.y) or 0
                    )
                end
            end
            if v88 then v88.Enabled = not hideMobileButtons end
        end)
    end)

    task.delay(1.0, function()
        if _printed_canSaveConfig then pcall(printedSaveConfig) end
    end)
end)

task.spawn(function()
    if _introEnabled == false then return end
    pcall(function()
        if type(playIntroSequence) == "function" then playIntroSequence() end
    end)
end)

-- keep mobile panel alive (respect hide + panel + scale)
task.delay(3, function()
    if not (v88 and v88.Parent) then
        pcall(createMobilePanel)
        if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
        if _G.__PrintedBtnScaleObj then
            _G.__PrintedBtnScaleObj.Scale = tonumber(mobileButtonScaleValue) or 1.0
        end
    end
    if v88 then v88.Enabled = not hideMobileButtons end
end)

task.spawn(function()
    while task.wait(8) do
        if not (v88 and v88.Parent) then
            pcall(createMobilePanel)
            if _G.PrintedApplyMobilePanel then pcall(_G.PrintedApplyMobilePanel) end
            if _G.__PrintedBtnScaleObj then
                _G.__PrintedBtnScaleObj.Scale = tonumber(mobileButtonScaleValue) or 1.0
            end
            if type(mobileButtonPositions) == "table" and _G.PrintedMobileButtonsPanel ~= true then
                for name, pos in pairs(mobileButtonPositions) do
                    local d = mobileButtonFrames and mobileButtonFrames[name]
                    if d and d.frame and type(pos) == "table" then
                        d.frame.Position = UDim2.new(tonumber(pos.xs) or 0, tonumber(pos.x) or 0, tonumber(pos.ys) or 0, tonumber(pos.y) or 0)
                    end
                end
            end
            if type(mobileGroupPosition) == "table" and v88 then
                local cont = v88:FindFirstChild("ButtonContainer")
                if cont then
                    cont.Position = UDim2.new(
                        tonumber(mobileGroupPosition.xs) or 0.5, tonumber(mobileGroupPosition.x) or 0,
                        tonumber(mobileGroupPosition.ys) or 0.5, tonumber(mobileGroupPosition.y) or 0
                    )
                end
            end
        end
        if v88 then v88.Enabled = not hideMobileButtons end
    end
end)

-- Keybind runner
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if _anyKeyListening then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if gameProcessed or UserInputService:GetFocusedTextBox() then return end
    elseif input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Gamepad2 then
        return
    end
    local kc = input.KeyCode
    for _, e in ipairs(tbl18) do
        local k = tbl17[e.id]
        if k and (k.kb == kc or k.gp == kc) then
            local act = MobileButtonActions[e.id]
            if act then task.spawn(function() pcall(act) end) end
            return
        end
    end
end)

-- SUPER FAST autosave
task.spawn(function()
    local lastForce = 0
    while true do
        task.wait(0.05)
        if not _printed_canSaveConfig then
            _printed_writefile = _printed_writefile or writefile or (syn and syn.writefile)
            _printed_canSaveConfig = type(_printed_writefile) == "function"
        end
        if _printed_canSaveConfig then
            if _printedConfigDirty then
                pcall(printedSaveConfig)
            elseif tick() - lastForce > 1 then
                lastForce = tick()
                pcall(printedSaveConfig)
            end
        end
    end
end)

print("[Zex] ready")
