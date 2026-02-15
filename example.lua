--[[
    CATRAZ HUB - COMPLETE TESTING SCRIPT
    Mencakup: Toggle (Switch), Slider, Searchable Dropdown, Input, Bind, Colorpicker, dll.
]]

-- 1. LOAD LIBRARY
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

-- 2. MEMBUAT WINDOW
local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub | Full Testing",
    HidePremium = false,
    SaveConfig = true, -- Wajib true untuk fitur Config Tab
    ConfigFolder = "CatrazTestFull",
    
    WindowTransparency = 0.2, -- Efek transparan pada window utama
    ImageTransparency = 0.8,
    
    IntroEnabled = true,
    IntroText = "Welcome to Catraz Hub",
    IntroIcon = "ghost" -- Menggunakan IconModule (Nama Icon)
})

-- =================================================================
-- TAB: TESTING ELEMEN (Basic)
-- =================================================================
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "house",
    PremiumOnly = false
})

-- SECTION: FOLDABLE (Bisa Dilipat)
local FoldSection = MainTab:AddSection({
    Name = "Foldable Testing (Klik Panah!)" -- Mendukung fitur lipat
})

-- BUTTON
FoldSection:AddButton({
    Name = "Test Notification",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "System",
            Content = "Modern notification triggered with custom glow outline!",
            Image = "bell",
            ImageBackground = "rbxassetid://93195749393891", -- Background notifikasi
            ImageTransparency = 0.7,
            Time = 4
        })
    end    
})

-- TOGGLE (Switch Style)
FoldSection:AddToggle({
    Name = "Switch Toggle Test",
    Default = false,
    Flag = "ToggleTest", -- Unik ID untuk save config
    Save = true,
    Callback = function(Value)
        print("Toggle Status:", Value)
    end    
})

-- SLIDER
MainTab:AddSlider({
    Name = "Walkspeed Adjuster",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(200, 40, 40), -- Warna merah Catraz
    Increment = 1,
    ValueName = "Speed",
    Flag = "SpeedSlider",
    Save = true,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

-- =================================================================
-- TAB: INPUT & SELECTION
-- =================================================================
local InputTab = Window:MakeTab({
    Name = "Inputs",
    Icon = "keyboard",
    PremiumOnly = false
})

-- SEARCHABLE DROPDOWN
InputTab:AddDropdown({
    Name = "Teleport Selection",
    Default = "None",
    Options = {"Spawn", "Village", "Snow Mountain", "Desert", "Boss Arena", "Secret Island"},
    Search = true, -- Mengaktifkan Search Bar
    Flag = "TPDropdown",
    Save = true,
    Callback = function(Value)
        print("Selected Location:", Value)
    end    
})

-- TEXTBOX
InputTab:AddTextbox({
    Name = "Custom Message",
    Default = "Hello World",
    TextDisappear = false, -- Teks tidak hilang setelah enter
    Callback = function(Value)
        print("User Inputted:", Value)
    end	  
})

-- KEYBIND
InputTab:AddBind({
    Name = "Kill Aura Bind",
    Default = Enum.KeyCode.E,
    Hold = false,
    Flag = "KABind",
    Save = true,
    Callback = function()
        print("Bind Key Pressed!")
    end    
})

-- COLORPICKER
InputTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Save = true,
    Callback = function(Value)
        print("Color Selected:", Value)
    end	  
})

-- =================================================================
-- TAB: MISC (Labels & Paragraphs)
-- =================================================================
local MiscTab = Window:MakeTab({
    Name = "Information",
    Icon = "info",
    PremiumOnly = false
})

MiscTab:AddLabel("Status: Developer Build") -- Label teks tebal

MiscTab:AddParagraph("About Catraz", "This script is a modified version of Orion UI designed for the Catraz Community with modern animations and searchable dropdowns.")

-- =================================================================
-- TAB: SETTINGS & CONFIG
-- =================================================================
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    PremiumOnly = false
})

SettingsTab:AddDropdown({
    Name = "Select UI Theme",
    Default = "Default",
    Options = {"Default", "Ocean", "Void", "Hackerman"},
    Callback = function(Value)
        OrionLib.SelectedTheme = Value
        OrionLib:SetTheme() -- Mengubah warna seluruh elemen UI
    end    
})

-- [[ FITUR OTOMATIS: TAB CONFIG ]] --
-- Membuat tab Save/Load secara instan dalam 1 baris
Window:AddConfigTab() 

-- 3. INITIALIZE
OrionLib:Init() -- Memuat config jika 'Auto Load' aktif