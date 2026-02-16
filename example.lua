-- [[ 1. INITIALIZATION ]] --
-- GANTI LINK DI BAWAH INI DENGAN LINK RAW SOURCE.LUA HASIL MODIFIKASI KITA TADI
-- Kalau kamu tes di executor langsung (local file), gunakan readfile/loadfile
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))() 
local LPlayer = game:GetService("Players").LocalPlayer
local WindowConfig = {
    Name = "Catraz Hub",
    Subtext = "Premium Script Hub | " .. os.date("%A, %B %d"), -- Menampilkan Tanggal
    Version = "v2.5-PRO",
    VersionIcon = "shield-check", -- Icon Lucide
    TagColor = Color3.fromRGB(200, 40, 40), -- Merah Catraz
    
    ShowIcon = true,
    Icon = "rbxassetid://105921924721005", -- Ganti dengan iconmu
    
    -- [[ BACKGROUND IMAGE BIAR EFEK GLASS MAKIN KELIHATAN ]] --
    ImageBackground = "rbxassetid://14246964899", -- Gambar Abstrak Gelap
    ImageTransparency = 0.8, -- Transparansi gambar background
    WindowTransparency = 0.1, -- Transparansi warna dasar window
    
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Data",
    
    IntroEnabled = true,
    IntroText = "Welcome, " .. LPlayer.DisplayName,
    IntroIcon = "rbxassetid://105921924721005",
    
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
}

local Window = OrionLib:MakeWindow(WindowConfig)

-- =================================================================
-- TAB 1: HOME (CONTOH GLASS TAB)
-- =================================================================
-- Tab ini menggunakan fitur Glass = true dan Outline = false agar terlihat modern/flat
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "home",
    Glass = true,   -- Efek kaca pada tombol tab
    Outline = false -- Hilangkan garis pinggir tombol tab
})

-- Section Transparan (Glass Box)
local UserSection = HomeTab:AddSection({
    Name = "User Information",
    Glass = true,   -- Kotak section jadi transparan
    Outline = false -- Hilangkan garis pinggir section
})

UserSection:AddParagraph({
    Title = "Subscription Status",
    Desc = "Status: <font color='#42f563'>Active</font>\nTier: <b>Developer</b>\nUID: " .. LPlayer.UserId,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LPlayer.UserId .. "&w=150&h=150",
    ImageSize = 45
})

UserSection:AddButton({
    Name = "Copy Discord Link",
    Icon = "link",
    Outline = false, -- Tombol flat tanpa border
    Callback = function()
        setclipboard("https://discord.gg/CatrazHub")
        OrionLib:MakeNotification({Name = "Success", Content = "Link copied!", Time = 3})
    end
})

-- =================================================================
-- TAB 2: MAIN FEATURES (CONTOH STANDARD & MIXED)
-- =================================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "sword",
    Glass = false, -- Tab biasa
    Outline = true -- Pakai outline
})

-- Section dengan Outline tapi tanpa Glass (Solid)
local FarmSec = MainTab:AddSection({
    Name = "Auto Farm Settings",
    Glass = false, 
    Outline = true,
    Folded = false
})

-- Contoh Toggle TANPA Outline (Menyatu dengan background)
FarmSec:AddToggle({
    Name = "Auto Attack",
    Default = false,
    Outline = false, -- Flat Style
    Flag = "AutoAttack",
    Save = true,
    Callback = function(Value)
        print("Auto Attack:", Value)
    end
})

-- Contoh Dropdown Multi-Select
FarmSec:AddDropdown({
    Name = "Select Mobs",
    Default = {},
    Options = {"Goblin", "Orc", "Dragon", "Slime", "Wolf"},
    Multi = true,
    Search = true,
    Outline = true, -- Tetap pakai outline biar tegas
    Flag = "MobSelect",
    Callback = function(Value)
        print("Mobs:", table.concat(Value, ", "))
    end
})

-- Section Kedua (Combat)
local CombatSec = MainTab:AddSection({ Name = "Combat" })

-- Slider tanpa Outline
CombatSec:AddSlider({
    Name = "Kill Aura Range",
    Min = 0,
    Max = 50,
    Default = 20,
    Increment = 1,
    ValueName = "Studs",
    Outline = false, -- Flat Slider
    Flag = "KillAuraRange",
    Callback = function(Value)
        print("Range set to:", Value)
    end
})

-- =================================================================
-- TAB 3: VISUALS (CONTOH FULL GLASS UI)
-- =================================================================
local VisualTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "eye",
    Glass = true,
    Outline = true
})

-- Section Glass dengan Outline (Kotak kaca bergaris)
local ESPSec = VisualTab:AddSection({
    Name = "ESP Configuration",
    Glass = true,
    Outline = true
})

ESPSec:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Outline = false,
    Callback = function(Value) 
        -- Logika ESP
    end
})

ESPSec:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Outline = true, -- Outline on biar kotak warnanya jelas
    Callback = function(Value)
        -- Ubah warna ESP
    end
})

-- Textbox tanpa outline frame utama, tapi kotak input tetap ada (default logic)
ESPSec:AddTextbox({
    Name = "Custom ESP Name",
    Default = "",
    TextDisappear = false,
    Outline = false, 
    Callback = function(Value)
        print("ESP Name:", Value)
    end
})

-- =================================================================
-- TAB 4: SETTINGS & CONFIGS
-- =================================================================
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings"
})

local SysSec = SettingsTab:AddSection({ Name = "System" })

SysSec:AddBind({
    Name = "Menu Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Outline = true,
    Flag = "MenuBind",
    Save = true,
    Callback = function()
        -- Sudah otomatis dihandle lib, tapi bisa tambah fungsi lain disini
    end
})

SysSec:AddButton({
    Name = "Unload Script",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
    end
})

-- [[ FITUR PRO: CONFIG MANAGER BAWAAN ]] --
-- Ini akan membuat Tab baru khusus untuk save/load config
Window:AddConfigTab({
    Name = "Configs",
    Icon = "save"
})

-- [[ INITIALIZE ]] --
OrionLib:Init()