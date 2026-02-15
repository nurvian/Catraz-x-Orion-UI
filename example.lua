-- [[ 1. INITIALIZATION ]] --
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()
local LPlayer = game:GetService("Players").LocalPlayer

-- [[ 2. WINDOW CONFIGURATION ]] --
-- Menggunakan fitur Header baru: Subtext, Version Tag, dan Icon Lucide
local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub",
    Subtext = "GENESIS ID | Official Community Hub", --
    Version = "v9.6.6-STABLE",
    VersionIcon = "crown", -- Icon mahkota pro
    TagColor = Color3.fromRGB(120, 20, 20), -- Warna tag kustom
    
    ShowIcon = true,
    Icon = "rbxassetid://105921924721005",
    
    SaveConfig = true, -- Mengaktifkan sistem penyimpanan
    ConfigFolder = "Catraz_Configs",
    
    WindowTransparency = 0.15,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 42,
    
    IntroEnabled = true,
    IntroText = "Welcome Back, " .. LPlayer.DisplayName,
    IntroIcon = "ghost"
})

-- =================================================================
-- TAB 1: DASHBOARD (Profil & Komunitas)
-- =================================================================
local DashTab = Window:MakeTab({ Name = "Dashboard", Icon = "layout-dashboard" })

-- Advanced Paragraph: Profil User
DashTab:AddParagraph({
    Title = "User Profile",
    Desc = "Status: Developer Access Granted\nEnjoy the premium Catraz experience.",
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LPlayer.UserId .. "&w=150&h=150",
    ImageSize = 45
})

-- Advanced Paragraph: Live Discord API
local CommDisplay = DashTab:AddParagraph({
    Title = "Catraz Community Hub",
    Desc = "🔄 Synchronizing with Satellite...",
    Image = "rbxassetid://89256806750785",
    ImageSize = 50,
    Buttons = {
        {
            Title = "Copy Invitation",
            Callback = function()
                setclipboard("https://discord.gg/XVcWDFCYSu")
                OrionLib:MakeNotification({ Name = "System", Content = "Link copied to clipboard!", Image = "link", Time = 3 })
            end
        }
    }
})

-- =================================================================
-- TAB 2: AUTOMATION (Fitur Utama Game)
-- =================================================================
local MainTab = Window:MakeTab({ Name = "Automation", Icon = "zap" })

-- Section Foldable: Untuk menjaga UI tetap rapi
local FarmSec = MainTab:AddSection({ Name = "Farming Settings", Folded = true })

-- Modern Switch Toggle
FarmSec:AddToggle({
    Name = "Auto Mine Ores",
    Default = false,
    Flag = "AutoMine_Switch", -- ID untuk Config
    Save = true,
    Callback = function(v) print("Auto Mine Status:", v) end
})

-- Slider with Value Formatting
MainTab:AddSlider({
    Name = "Movement Speed",
    Min = 16, Max = 350, Default = 16,
    Increment = 1, ValueName = "SPS",
    Color = Color3.fromRGB(200, 40, 40),
    Flag = "WalkSpeed_Slider", Save = true,
    Callback = function(v) LPlayer.Character.Humanoid.WalkSpeed = v end
})

-- =================================================================
-- TAB 3: VISUALS (Dropdown & Colors)
-- =================================================================
local VisualTab = Window:MakeTab({ Name = "Visuals", Icon = "palette" })

-- Searchable & Multi-Select Dropdown
VisualTab:AddDropdown({
    Name = "ESP Target Selection",
    Options = {"Players", "NPCs", "Ores", "Chests", "Safezones"},
    Default = {"Players"},
    Multi = true,
    Search = true, -- Mengaktifkan bar pencarian
    Flag = "ESP_Dropdown", Save = true,
    Callback = function(v) print("Selected Targets:", table.concat(v, ", ")) end
})

VisualTab:AddColorpicker({
    Name = "Chams Glow Color",
    Default = Color3.fromRGB(255, 40, 40),
    Flag = "ChamsColor", Save = true,
    Callback = function(v) print("Color Updated:", v) end
})

-- =================================================================
-- TAB 4: SYSTEM (Configs & Settings)
-- =================================================================
local SystemTab = Window:MakeTab({ Name = "System", Icon = "settings" })

-- Theme Selector
SystemTab:AddDropdown({
    Name = "Select UI Theme",
    Default = "Default",
    AllowNone = false, -- Pastikan ini FALSE agar tema tidak bisa dikosongkan
    Options = {"Default", "Ocean", "Void", "Hackerman"}, -- Harus sama dengan tabel Themes di source.lua
    Callback = function(Value)
        if Value ~= "" and OrionLib.Themes[Value] then -- Tambahkan pengecekan manual
            OrionLib.SelectedTheme = Value
            OrionLib:SetTheme()
        end
    end     
})
SystemTab:AddBind({
    Name = "Emergency Menu Toggle",
    Default = Enum.KeyCode.RightControl,
    Flag = "MenuKeybind", Save = true,
    Callback = function() print("Menu Toggle Pressed") end
})

-- [[ FITUR OTOMATIS: GENERATE CONFIG TAB ]] --
-- Membuat seluruh UI pengelolaan config (Save/Load/Cloud) secara instan
Window:AddConfigTab({ Name = "Config Manager", Icon = "database" })

-- =================================================================
-- 🛰️ LIVE DATA UPDATER LOGIC
-- =================================================================
task.spawn(function()
    local InviteCode = "XVcWDFCYSu" -- Kode Genesis ID
    while task.wait(60) do
        local Success, Result = pcall(function()
            local requestFunc = request or http_request or (http and http.request)
            local res = requestFunc({ Url = "https://discord.com/api/v9/invites/"..InviteCode.."?with_counts=true", Method = "GET" })
            return game:GetService("HttpService"):JSONDecode(res.Body)
        end)

        if Success and Result and Result.approximate_member_count then
            local FormatK = function(n) return n >= 1000 and string.format("%.1fk", n/1000) or tostring(n) end
            local Content = string.format(
                '<font color="#4fffa6">● %s Online</font>  |  👥 %s Members\n\n' ..
                '<font color="#b0b0b0">Latest updates, giveaways, and 24/7 support.</font>',
                FormatK(Result.approximate_presence_count or 0), FormatK(Result.approximate_member_count)
            )
            CommDisplay:SetTitle("Catraz Community 🟢 Live")
            CommDisplay:SetDesc(Content)
        end
    end
end)

-- [[ 3. FINALIZE ]] --
OrionLib:Init() -- Memuat konfigurasi 'Auto Load' jika tersedia