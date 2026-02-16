local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- [[ 1. JUNKIE SDK INITIALIZATION ]] --
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()

-- [[ 2. CONFIGURATION (WAJIB DIISI) ]] --
local JunkieConfig = {
    Service = "Catraz Hub Key System", -- Ganti dengan Nama Service di Dashboard Junkie
    Identifier = "13459",          -- Ganti dengan Identifier di Dashboard Junkie
    Provider = "Catraz Hub Key System",            -- Biarkan Mixed atau sesuaikan (Linkvertise/Lootlabs)
}

-- Setup Junkie Library
Junkie.service = JunkieConfig.Service
Junkie.identifier = JunkieConfig.Identifier
Junkie.provider = JunkieConfig.Provider

local Config = {
    Theme = {
        Main = Color3.fromRGB(25, 25, 25),
        MainGradient = Color3.fromRGB(10, 10, 10),
        Second = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(200, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 150, 150),
        Status = {
            Online = Color3.fromRGB(46, 204, 113),
            Offline = Color3.fromRGB(231, 76, 60),
            Maintenance = Color3.fromRGB(241, 196, 15)
        }
    }
}

-- [[ DATABASE GAME ID ]] --
local GameScripts = {
    [121864768012064] = "https://api.jnkie.com/api/v1/luascripts/public/97afe9c02a8026a11c091fedb8e687bd4c866ee7ac2a7a292bb9513ad65b5c5a/download", 
    [76558904092080]  = "https://api.jnkie.com/api/v1/luascripts/public/ea8ae5d36a20a896bb7f85ea42d1378ea6925566a1ddfb715928d016ad3fe70e/download", 
    [129009554587176] = "https://api.jnkie.com/api/v1/luascripts/public/ea8ae5d36a20a896bb7f85ea42d1378ea6925566a1ddfb715928d016ad3fe70e/download",
    [131884594917121] = "https://api.jnkie.com/api/v1/luascripts/public/ea8ae5d36a20a896bb7f85ea42d1378ea6925566a1ddfb715928d016ad3fe70e/download",
    [1537690962] = "https://api.jnkie.com/api/v1/luascripts/public/356b91d2f130f0d93b4bf50e5d3c9f611a6b210ce97f97317a2c7213c1a25431/download",
    [127794225497302] = "https://api.jnkie.com/api/v1/luascripts/public/14aa3e4477536a13411814650297c3acba168a2a4a21687ac9242dab1fc7aa2c/download",
}

-- Script Universal (Kalau game tidak dikenali, load ini)
local UniversalScript = "https://raw.githubusercontent.com/username/repo/main/Universal.lua"

-- [[ GAME LIST DATA ]] --
local SupportedGames = {
    { Name = "The Forge", Status = "Online", Version = "v1.0.0", Image = "rbxassetid://98973451489192" },
    { Name = "Fish It!", Status = "Offline", Version = "v2.1.0", Image = "rbxassetid://82929970878099" },
    { Name = "Abyss", Status = "Online", Version = "v2.2.8 BETA", Image = "rbxassetid://84335672529391" },
    { Name = "Bee Swarm Simulator", Status = "Maintenance", Version = "v5.0.0", Image = "rbxassetid://125583404434914" },
    { Name = "Blox Fruits", Status = "ComingSoon", Version = "---", Image = "rbxassetid://112069893242409" },
    { Name = "Solo Hunter", Status = "ComingSoon", Version = "---", Image = "rbxassetid://123363546077395" }
}

-- [[ CLEANUP LAMA ]] --
if CoreGui:FindFirstChild("CatrazKeySystem") then CoreGui.CatrazKeySystem:Destroy() end
for _, v in pairs(Lighting:GetChildren()) do
    if v.Name == "CatrazBlur" then v:Destroy() end
end

-- [[ UI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CatrazKeySystem"
ScreenGui.Parent = (gethui and gethui()) or CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- 1. BLUR EFFECT
local BlurFX = Instance.new("BlurEffect")
BlurFX.Name = "CatrazBlur"
BlurFX.Size = 0 
BlurFX.Parent = Lighting
TweenService:Create(BlurFX, TweenInfo.new(1, Enum.EasingStyle.Quint), {Size = 15}):Play()

-- 2. BACKDROP
local Backdrop = Instance.new("ImageLabel")
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 0.3
Backdrop.Image = "" 
Backdrop.Parent = ScreenGui

-- 3. MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Animasi Start
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Config.Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- [[ BG GRADIENT ]] --
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Theme.Main),
    ColorSequenceKeypoint.new(1, Config.Theme.MainGradient)
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Config.Theme.Accent
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

-- [[ PARTICLE CONTAINER ]] --
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Name = "ParticleLayer"
ParticleContainer.Size = UDim2.new(1, 0, 1, 0) 
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ZIndex = 5 
ParticleContainer.Active = false 
ParticleContainer.Parent = MainFrame 

-- [[ LEFT PANEL ]] --
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0.4, 0, 1, 0)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ZIndex = 10 
LeftPanel.Parent = MainFrame

local PaddingLeft = Instance.new("UIPadding")
PaddingLeft.PaddingTop = UDim.new(0, 40)
PaddingLeft.PaddingLeft = UDim.new(0, 30)
PaddingLeft.PaddingRight = UDim.new(0, 30)
PaddingLeft.PaddingBottom = UDim.new(0, 30)
PaddingLeft.Parent = LeftPanel

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Image = "rbxassetid://105921924721005"
Logo.BackgroundTransparency = 1
Logo.ZIndex = 11
Logo.Parent = LeftPanel

local Title = Instance.new("TextLabel")
Title.Text = "CATRAZ HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Config.Theme.Text
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 70)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = LeftPanel

local SubTitle = Instance.new("TextLabel")
SubTitle.Text = "Authentication Required"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 14
SubTitle.TextColor3 = Config.Theme.SubText
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 95)
SubTitle.BackgroundTransparency = 1
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.ZIndex = 11
SubTitle.Parent = LeftPanel

local KeyInputBg = Instance.new("Frame")
KeyInputBg.Size = UDim2.new(1, 0, 0, 45)
KeyInputBg.Position = UDim2.new(0, 0, 0.5, -20)
KeyInputBg.BackgroundColor3 = Config.Theme.Second
KeyInputBg.ZIndex = 11
KeyInputBg.Parent = LeftPanel
Instance.new("UICorner", KeyInputBg).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", KeyInputBg).Color = Color3.fromRGB(60,60,60)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Enter Access Key..."
KeyInput.Text = ""
KeyInput.TextColor3 = Config.Theme.Text
KeyInput.PlaceholderColor3 = Color3.fromRGB(100,100,100)
KeyInput.TextSize = 14
KeyInput.ZIndex = 12
KeyInput.Parent = KeyInputBg

local function CreateButton(Text, Color, PosY, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.Position = UDim2.new(0, 0, 0, PosY)
    Btn.BackgroundColor3 = Color
    Btn.Text = Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextSize = 14
    Btn.ZIndex = 11
    Btn.Parent = LeftPanel
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(Callback)
    return Btn
end

local function CloseUI()
    if BlurFX then
        TweenService:Create(BlurFX, TweenInfo.new(0.5), {Size = 0}):Play()
    end
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(Backdrop, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    
    wait(0.5)
    
    if BlurFX then BlurFX:Destroy() end
    ScreenGui:Destroy()
end

-- [[ INTEGRASI JUNKIE + GAME DISPATCHER ]] --
local CheckBtn = CreateButton("Verify Access", Config.Theme.Accent, 240, function()
    local InputKey = KeyInput.Text
    
    -- 1. Cek Input Kosong
    if not InputKey or #InputKey == 0 then
        KeyInput.Text = "Please Enter Key!"
        KeyInput.TextColor3 = Config.Theme.Status.Maintenance
        wait(1)
        KeyInput.Text = ""
        KeyInput.TextColor3 = Config.Theme.Text
        return
    end

    KeyInput.Text = "Checking..."
    KeyInput.TextColor3 = Config.Theme.SubText
    
    -- 2. Validasi ke Server Junkie
    local Validation = Junkie.check_key(InputKey)
    
    if Validation.valid then
        -- [[ LOGIN SUKSES ]] --
        KeyInput.Text = "Welcome, " .. LocalPlayer.Name .. "!"
        KeyInput.TextColor3 = Config.Theme.Status.Online
        
        -- Simpan Key Global
        getgenv().SCRIPT_KEY = InputKey
        
        wait(0.5)
        CloseUI() -- Tutup Key System
        
        -- [[ 3. GAME DISPATCHER LOGIC ]] --
        local PlaceID = game.PlaceId
        local ScriptToLoad = GameScripts[PlaceID]
        
        if ScriptToLoad then
            -- A. Game Dikenali -> Load Script Khusus Game itu
            -- Notification (Optional)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Catraz Hub";
                Text = "Game Detected! Loading Script...";
                Duration = 5;
            })
            loadstring(game:HttpGet(ScriptToLoad))()
            
        else
            -- B. Game TIDAK Dikenali -> KICK PEMAIN
            -- Pesan kick dibuat rapi agar user tau kenapa mereka dikeluarkan
            local KickMessage = "\n[Catraz Hub]\n\nSorry, this game is NOT supported yet!\nPlace ID: " .. tostring(PlaceID) .. "\n\nJoin our Discord for updates: discord.gg/catrazhub"
            LocalPlayer:Kick(KickMessage)
        end
        
    else
        -- [[ LOGIN GAGAL ]] --
        local ErrorMsg = Validation.message or "Invalid Key!"
        
        if ErrorMsg == "KEY_EXPIRED" then
            KeyInput.Text = "Key Expired!"
        elseif ErrorMsg == "HWID_BANNED" then
            KeyInput.Text = "HWID Banned!"
            LocalPlayer:Kick("Catraz Hub: HWID Banned")
        elseif ErrorMsg == "HWID_MISMATCH" then
            KeyInput.Text = "HWID Mismatch!"
        else
            KeyInput.Text = "Invalid Key!"
        end
        
        KeyInput.TextColor3 = Config.Theme.Status.Offline
        
        -- Efek Getar
        local OriginalPos = MainFrame.Position
        for i = 1, 3 do
            MainFrame.Position = OriginalPos + UDim2.new(0, math.random(-5,5), 0, 0)
            wait(0.05)
        end
        MainFrame.Position = OriginalPos
        
        wait(1)
        KeyInput.Text = ""
        KeyInput.TextColor3 = Config.Theme.Text
    end
end)

-- [[ INTEGRASI JUNKIE DI TOMBOL GET KEY ]] --
local GetKeyBtn = CreateButton("Get Key (Link)", Config.Theme.Second, 290, function()
    local Link = Junkie.get_key_link()
    
    if Link then
        setclipboard(Link)
        KeyInput.Text = "Link Copied!"
        KeyInput.TextColor3 = Config.Theme.Status.Online
    else
        KeyInput.Text = "Rate Limited (Wait 5m)"
        KeyInput.TextColor3 = Config.Theme.Status.Maintenance
    end
    
    wait(1.5)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Config.Theme.Text
end)

local CloseBtn = Instance.new("ImageButton")
CloseBtn.Image = "rbxassetid://9886659671"
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 10) 
CloseBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.ZIndex = 20
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(CloseUI)

-- [[ RIGHT PANEL (DENGAN GRADIENT & FIXES) ]] --
local RightPanelBG = Instance.new("Frame")
RightPanelBG.Size = UDim2.new(0.6, 0, 1, 0)
RightPanelBG.Position = UDim2.new(0.4, 0, 0, 0)
RightPanelBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RightPanelBG.BorderSizePixel = 0
RightPanelBG.ZIndex = 2
RightPanelBG.Parent = MainFrame

local RightGradient = Instance.new("UIGradient")
RightGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
RightGradient.Rotation = 90
RightGradient.Parent = RightPanelBG

local RPCorner = Instance.new("UICorner")
RPCorner.CornerRadius = UDim.new(0, 12)
RPCorner.Parent = RightPanelBG

local FixCorner = Instance.new("Frame")
FixCorner.Size = UDim2.new(0, 15, 1, 0)
FixCorner.Position = UDim2.new(0, 0, 0, 0)
FixCorner.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FixCorner.BorderSizePixel = 0
FixCorner.ZIndex = 3
FixCorner.Parent = RightPanelBG

local FixGradient = Instance.new("UIGradient")
FixGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
FixGradient.Rotation = 90
FixGradient.Parent = FixCorner

-- [[ RIGHT PANEL CONTENT ]] --
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.6, 0, 1, 0)
RightPanel.Position = UDim2.new(0.4, 0, 0, 0)
RightPanel.BackgroundTransparency = 1 
RightPanel.ZIndex = 5
RightPanel.Parent = MainFrame

local GameTitle = Instance.new("TextLabel")
GameTitle.Text = "Supported Games"
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 18
GameTitle.TextColor3 = Config.Theme.Text
GameTitle.Size = UDim2.new(1, -40, 0, 30)
GameTitle.Position = UDim2.new(0, 20, 0, 20)
GameTitle.BackgroundTransparency = 1
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.ZIndex = 6
GameTitle.Parent = RightPanel

local GameScroll = Instance.new("ScrollingFrame")
GameScroll.Size = UDim2.new(1, -20, 1, -70)
GameScroll.Position = UDim2.new(0, 10, 0, 60)
GameScroll.BackgroundTransparency = 1
GameScroll.ScrollBarThickness = 2
GameScroll.ScrollBarImageColor3 = Config.Theme.Accent
GameScroll.ZIndex = 6
GameScroll.Parent = RightPanel

local GridLayout = Instance.new("UIGridLayout")
GridLayout.CellSize = UDim2.new(0.48, 0, 0, 100)
GridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
GridLayout.Parent = GameScroll

for _, GameData in pairs(SupportedGames) do
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Config.Theme.Second
    Card.ClipsDescendants = true
    Card.Parent = GameScroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local CardGradient = Instance.new("UIGradient")
    CardGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
    }
    CardGradient.Rotation = 45
    CardGradient.Parent = Card

    local GImage = Instance.new("ImageLabel")
    GImage.Size = UDim2.new(1, 0, 1, 0)
    GImage.Image = GameData.Image
    GImage.ScaleType = Enum.ScaleType.Crop
    GImage.ImageTransparency = 0.4
    GImage.BackgroundTransparency = 1
    GImage.Parent = Card

    local GradientFrame = Instance.new("Frame")
    GradientFrame.Size = UDim2.new(1, 0, 0.6, 0)
    GradientFrame.Position = UDim2.new(0, 0, 0.4, 0)
    GradientFrame.BorderSizePixel = 0
    GradientFrame.Parent = Card
    local UIGrad = Instance.new("UIGradient")
    UIGrad.Rotation = 90
    UIGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))}
    UIGrad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2)}
    UIGrad.Parent = GradientFrame

    local StatusColor = Config.Theme.Status.Online
    if GameData.Status == "Offline" then StatusColor = Config.Theme.Status.Offline end
    if GameData.Status == "Maintenance" then StatusColor = Config.Theme.Status.Maintenance end
    if GameData.Status == "ComingSoon" then StatusColor = Color3.fromRGB(100,100,100) end

    local StatusDot = Instance.new("Frame")
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(0, 8, 0, 8)
    StatusDot.BackgroundColor3 = StatusColor
    StatusDot.Parent = Card
    Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

    local StatusText = Instance.new("TextLabel")
    StatusText.Text = string.upper(GameData.Status)
    StatusText.Size = UDim2.new(0, 0, 0, 8)
    StatusText.Position = UDim2.new(0, 20, 0, 8)
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextSize = 10
    StatusText.TextColor3 = StatusColor
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.BackgroundTransparency = 1
    StatusText.Parent = Card

    local GName = Instance.new("TextLabel")
    GName.Text = GameData.Name
    GName.Size = UDim2.new(1, -16, 0, 20)
    GName.Position = UDim2.new(0, 8, 1, -25)
    GName.Font = Enum.Font.GothamBold
    GName.TextSize = 14
    GName.TextColor3 = Config.Theme.Text
    GName.TextXAlignment = Enum.TextXAlignment.Left
    GName.BackgroundTransparency = 1
    GName.Parent = Card

    if GameData.Status == "ComingSoon" then
        GImage.ImageTransparency = 0.8
        local LockIcon = Instance.new("ImageLabel")
        LockIcon.Image = "rbxassetid://3926305904"
        LockIcon.Size = UDim2.new(0, 24, 0, 24)
        LockIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
        LockIcon.BackgroundTransparency = 1
        LockIcon.ImageColor3 = Color3.fromRGB(200,200,200)
        LockIcon.Parent = Card
        
        local CSLabel = Instance.new("TextLabel")
        CSLabel.Text = "COMING SOON"
        CSLabel.Size = UDim2.new(1, 0, 0, 20)
        CSLabel.Position = UDim2.new(0, 0, 0.5, 15)
        CSLabel.Font = Enum.Font.GothamBold
        CSLabel.TextSize = 12
        CSLabel.TextColor3 = Color3.fromRGB(150,150,150)
        CSLabel.BackgroundTransparency = 1
        CSLabel.Parent = Card
        
        GName.Visible = false
        StatusDot.Visible = false
        StatusText.Visible = false
    end
end

-- [[ DRAGGABLE ]] --
local function MakeDraggable(Frame)
    local dragToggle, dragInput, dragStart, startPos
    local function updateInput(input)
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true; dragStart = input.Position; startPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
        end
    end)
    Frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then updateInput(input) end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragToggle then updateInput(input) end end)
end
MakeDraggable(MainFrame)

-- [[ AUTOMATED SEASONAL PARTICLE SYSTEM ]] --
task.spawn(function()
    local Assets = {
        Winter = "rbxthumb://type=Asset&id=238426663&w=420&h=420", 
        Spring = "rbxthumb://type=Asset&id=243344624&w=420&h=420", 
        Summer = "rbxthumb://type=Asset&id=4989157720&w=420&h=420", 
        Autumn = "rbxthumb://type=Asset&id=480281248&w=420&h=420", 
        Valentine = "rbxthumb://type=Asset&id=8941506195&w=420&h=420", 
        Halloween = "rbxthumb://type=Asset&id=4019390863&w=420&h=420", 
        Christmas = "rbxthumb://type=Asset&id=238426663&w=420&h=420", 
        NewYear   = "rbxthumb://type=Asset&id=2415762163&w=420&h=420"  
    }

    local function GetCurrentTheme()
        local Date = os.date("*t")
        local Month, Day = Date.month, Date.day
        if Month == 2 and Day == 14 then return "Valentine" end
        if Month == 10 and Day == 31 then return "Halloween" end
        if Month == 12 or Month == 1 or Month == 2 then return "Winter" end
        if Month >= 3 and Month <= 5 then return "Spring" end
        if Month >= 6 and Month <= 8 then return "Summer" end
        return "Autumn"
    end

    local ThemeName = GetCurrentTheme()
    local TextureID = Assets[ThemeName] or Assets["Spring"]
    
    local FrameCount = 0
    RunService.RenderStepped:Connect(function()
        if not MainFrame.Parent then return end 
        FrameCount = FrameCount + 1
        
        if FrameCount % 15 == 0 then
            local P = Instance.new("ImageLabel")
            P.Name = "Particle"
            P.Parent = ParticleContainer 
            P.BackgroundTransparency = 1
            P.Image = TextureID
            P.ImageTransparency = 0.3
            P.ZIndex = 4 
            P.AnchorPoint = Vector2.new(0.5, 0.5) 
            
            if ThemeName == "Autumn" or ThemeName == "Halloween" then
                P.ImageColor3 = Color3.fromRGB(255, 150, 50)
            elseif ThemeName == "Valentine" then
                P.ImageColor3 = Color3.fromRGB(255, 100, 100) 
            else
                P.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            
            local Size = math.random(20, 35)
            P.Size = UDim2.new(0, Size, 0, Size)
            
            local ContainerWidth = ParticleContainer.AbsoluteSize.X
            local Padding = 15
            if ContainerWidth < 100 then ContainerWidth = 750 end

            local StartX = math.random(Padding, ContainerWidth - Padding)
            P.Position = UDim2.new(0, StartX, 0, 10)
            P.Rotation = math.random(0, 360)

            local Drift = math.random(-20, 20)
            local TargetX = math.clamp(StartX + Drift, Padding, ContainerWidth - Padding)
            local EndPos = UDim2.new(0, TargetX, 0.9, Size)
            
            local FallTime = math.random(4, 7)
            
            local Tween = TweenService:Create(P, TweenInfo.new(FallTime, Enum.EasingStyle.Linear), {
                Position = EndPos,
                Rotation = P.Rotation + 180
            })
            Tween:Play()
            
            Debris:AddItem(P, FallTime)
        end
    end)
end)

-- [[ AUDIO SYSTEM ]] --
local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "CatrazSounds"
SoundFolder.Parent = ScreenGui

local function PlaySound(Id, Volume)
    local S = Instance.new("Sound")
    S.SoundId = Id
    S.Volume = Volume or 1
    S.Parent = SoundFolder
    S.PlayOnRemove = true
    S:Destroy()
end

local S_Hover = "rbxassetid://6895079853" 
local S_Click = "rbxassetid://4351886305" 

for _, Descendant in pairs(ScreenGui:GetDescendants()) do
    if Descendant:IsA("TextButton") or Descendant:IsA("ImageButton") then
        Descendant.MouseEnter:Connect(function() PlaySound(S_Hover, 0.5) end)
        Descendant.MouseButton1Click:Connect(function() PlaySound(S_Click, 1) end)
    end
end

-- [[ START ANIMATION ]] --
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 750, 0, 450)}):Play()