--══════════════════════════════════════════════════════════════════════
--  ZEXHUB INTRO — 9 saniye, 20 resim + müzik
--  Bittiğinde otomatik olarak ZexDuels.lua'yı yükler
--══════════════════════════════════════════════════════════════════════
repeat task.wait() until game:IsLoaded()

local Players       = game:GetService("Players")
local CoreGui       = game:GetService("CoreGui")
local TweenService  = game:GetService("TweenService")
local SoundService  = game:GetService("SoundService")

local getasset = getcustomasset or getsynasset or get_custom_asset

local _gethui = gethui or function()
    local ok, res = pcall(function() return CoreGui end)
    return (ok and res) or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local httpRequest = function(opts)
    local url = opts and opts.Url or opts
    if type(url) ~= "string" then return nil end
    local body
    pcall(function() body = game:HttpGet(url) end)
    if body and #body > 0 then
        return { Body = body, StatusCode = 200 }
    end
    return nil
end

local function playIntro()
    if not getasset then return end
    if not writefile or not isfile then return end

    local files = {
        ["ZexIntro1.jpg"]  = "https://files.catbox.moe/fyob6a.jpg",
        ["ZexIntro2.jpg"]  = "https://files.catbox.moe/ecs00c.jpg",
        ["ZexIntro3.jpg"]  = "https://files.catbox.moe/1v02ga.jpg",
        ["ZexIntro4.jpg"]  = "https://files.catbox.moe/av9qjb.jpg",
        ["ZexIntro5.jpg"]  = "https://files.catbox.moe/3l0smn.jpg",
        ["ZexIntro6.jpg"]  = "https://files.catbox.moe/kgevzc.jpg",
        ["ZexIntro7.jpg"]  = "https://files.catbox.moe/8ng39r.jpg",
        ["ZexIntro8.jpg"]  = "https://files.catbox.moe/0kfnn1.jpg",
        ["ZexIntro9.jpg"]  = "https://files.catbox.moe/rygwi3.jpg",
        ["ZexIntro10.jpg"] = "https://files.catbox.moe/va1kb7.jpg",
        ["ZexIntro11.jpg"] = "https://files.catbox.moe/5bjn3c.jpg",
        ["ZexIntro12.jpg"] = "https://files.catbox.moe/niqg2p.jpg",
        ["ZexIntro13.jpg"] = "https://files.catbox.moe/nn1o2z.jpg",
        ["ZexIntro14.jpg"] = "https://files.catbox.moe/dic7k1.jpg",
        ["ZexIntro15.jpg"] = "https://files.catbox.moe/6faip5.jpg",
        ["ZexIntro16.jpg"] = "https://files.catbox.moe/u6iaai.jpg",
        ["ZexIntro17.jpg"] = "https://files.catbox.moe/vkgrxk.jpg",
        ["ZexIntro18.jpg"] = "https://files.catbox.moe/7ray53.jpg",
        ["ZexIntro19.jpg"] = "https://files.catbox.moe/fpq16t.jpg",
        ["ZexIntro20.jpg"] = "https://files.catbox.moe/1rsiln.jpg",
        ["ZexIntrosong.mp3"] = "https://files.catbox.moe/iyw1cb.mp3",
    }

    for fileName, url in pairs(files) do
        if not isfile(fileName) then
            pcall(function()
                local res = httpRequest({ Url = url, Method = "GET" })
                if res and res.Body then
                    writefile(fileName, res.Body)
                end
            end)
        end
    end

    local frameList = {}
    for i = 1, 20 do
        local ok, asset = pcall(getasset, "ZexIntro" .. i .. ".jpg")
        if ok and asset then
            table.insert(frameList, asset)
        end
    end

    if #frameList == 0 then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZexIntro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 99999
    gui.Parent = _gethui()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ScaleType = Enum.ScaleType.Crop
    imageLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.08, 0)
    textLabel.Position = UDim2.new(0, 0, 0.88, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "ZexHub Loading"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBlack
    textLabel.ZIndex = 3
    textLabel.Parent = frame

    local sound
    pcall(function()
        sound = Instance.new("Sound")
        sound.SoundId = getasset("ZexIntrosong.mp3")
        sound.Volume = 1
        sound.Parent = SoundService
        sound:Play()
    end)

    local startTime = tick()
    local duration = 9
    local frameDelay = 0.07

    while tick() - startTime < duration do
        for _, assetUri in ipairs(frameList) do
            if tick() - startTime >= duration then break end
            imageLabel.Image = assetUri
            task.wait(frameDelay)
        end
    end

    local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(frame, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(imageLabel, fadeInfo, {ImageTransparency = 1}):Play()
    TweenService:Create(textLabel, fadeInfo, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    if sound then
        TweenService:Create(sound, fadeInfo, {Volume = 0}):Play()
    end

    task.wait(1.2)

    if sound then
        pcall(function() sound:Stop() end)
        sound:Destroy()
    end
    gui:Destroy()
end

pcall(playIntro)

task.wait(0.3)

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ty2jjr22cd-jpg/J/refs/heads/main/ZexDuels.lua"))()
end)
