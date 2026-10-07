task.spawn(function()
    local Players       = game:GetService("Players")
    local CoreGui       = game:GetService("CoreGui")
    local TweenService  = game:GetService("TweenService")
    local SoundService  = game:GetService("SoundService")

    local getasset = getcustomasset or getsynasset or get_custom_asset
    if not getasset then return end

    local _gethui = gethui or function()
        local ok, res = pcall(function() return CoreGui end)
        return (ok and res) or Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local httpRequest = (syn and syn.request)
        or (http and http.request)
        or http_request
        or (fluxus and fluxus.request)
        or request

    if not httpRequest or not writefile or not isfile then return end

    local files = {
        ["Intro1.jpg"]  = "https://files.catbox.moe/fyob6a.jpg",
        ["Intro2.jpg"]  = "https://files.catbox.moe/ecs00c.jpg",
        ["Intro3.jpg"]  = "https://files.catbox.moe/1v02ga.jpg",
        ["Intro4.jpg"]  = "https://files.catbox.moe/av9qjb.jpg",
        ["Intro5.jpg"]  = "https://files.catbox.moe/3l0smn.jpg",
        ["Intro6.jpg"]  = "https://files.catbox.moe/kgevzc.jpg",
        ["Intro7.jpg"]  = "https://files.catbox.moe/8ng39r.jpg",
        ["Intro8.jpg"]  = "https://files.catbox.moe/0kfnn1.jpg",
        ["Intro9.jpg"]  = "https://files.catbox.moe/rygwi3.jpg",
        ["Intro10.jpg"] = "https://files.catbox.moe/va1kb7.jpg",
        ["Intro11.jpg"] = "https://files.catbox.moe/5bjn3c.jpg",
        ["Intro12.jpg"] = "https://files.catbox.moe/niqg2p.jpg",
        ["Intro13.jpg"] = "https://files.catbox.moe/nn1o2z.jpg",
        ["Intro14.jpg"] = "https://files.catbox.moe/dic7k1.jpg",
        ["Intro15.jpg"] = "https://files.catbox.moe/6faip5.jpg",
        ["Intro16.jpg"] = "https://files.catbox.moe/u6iaai.jpg",
        ["Intro17.jpg"] = "https://files.catbox.moe/vkgrxk.jpg",
        ["Intro18.jpg"] = "https://files.catbox.moe/7ray53.jpg",
        ["Intro19.jpg"] = "https://files.catbox.moe/fpq16t.jpg",
        ["Intro20.jpg"] = "https://files.catbox.moe/1rsiln.jpg",
        ["Introsong.mp3"] = "https://files.catbox.moe/iyw1cb.mp3",
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
        local ok, asset = pcall(getasset, "Intro" .. i .. ".jpg")
        if ok and asset then
            table.insert(frameList, asset)
        end
    end

    if #frameList == 0 then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Intro"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
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
    textLabel.Text = "ZexHub 🫠"
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
        sound.SoundId = getasset("Introsong.mp3")
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
end)
