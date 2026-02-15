--[[
    CATRAZ HUB - MASTER TEMPLATE
    Author: GRAYWOLF
    Library: Modified Orion Lib (With IconModule & Custom Themes)
]]

-- 1. LOAD LIBRARY (Ganti Link ini dengan Link Raw GitHub Source Code Modifikasi kamu)
-- Kalau testing di executor lokal, bisa pakai loadstring(readfile("source.lua"))()
local OrionLib = loadstring(game:HttpGet("LINK_RAW_GITHUB_SOURCE_CODE_KAMU_DISINI"))()

-- 2. MEMBUAT WINDOW UTAMA
local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub | Universal",
    HidePremium = false,
    SaveConfig = true, -- Auto save config
    ConfigFolder = "CatrazConfig", -- Nama folder di workspace
    
    -- Fitur Intro
    IntroEnabled = true,
    IntroText = "Catraz Hub",
    IntroIcon = "Ghost", -- Icon dari Library Lucide (Pastikan IconModule sudah terpasang)
    
    -- Fitur Background Image (Opsional, hapus jika tidak mau)
    ImageBackground = "rbxassetid://4483345998", -- Contoh background abstrak
    ImageTransparency = 0.8 -- Biar tulisan tetap terbaca jelas
})

-- =================================================================
-- TAB 1: MAIN (Contoh Penggunaan Button, Toggle, Slider, Label)
-- =================================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "Sword", -- Icon Pedang
    PremiumOnly = false
})

-- SECTION: Pemisah Kategori
local FarmSection = MainTab:AddSection({
    Name = "Farming Features"
})

-- LABEL: Menampilkan teks info
local StatusLabel = FarmSection:AddLabel("Status: Idle")

-- TOGGLE: Saklar On/Off
FarmSection:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(Value)
        StatusLabel:Set("Status: " .. (Value and "Farming..." or "Idle"))
        
        -- Logika Auto Farm disini
        while Value do
            print("Farming berjalan...")
            task.wait(1)
            -- Cek ulang value biar bisa berhenti
            if not Value then break end
        end
    end    
})

-- SLIDER: Penggeser Angka (Contoh: WalkSpeed)
FarmSection:AddSlider({
    Name = "WalkSpeed Modifier",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 0, 0), -- Warna slider custom
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

-- BUTTON: Tombol Biasa
FarmSection:AddButton({
    Name = "Kill All Mobs (Test)",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Action Executed",
            Content = "Membunuh semua monster di sekitar...",
            Image = "Skull",
            Time = 3
        })
    end    
})

-- =================================================================
-- TAB 2: VISUALS (Contoh Penggunaan Colorpicker & Toggle)
-- =================================================================
local VisualTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "Eye", -- Icon Mata
    PremiumOnly = false
})

local EspSection = VisualTab:AddSection({
    Name = "ESP Settings"
})

-- TOGGLE DENGAN FLAG (Untuk Save Config)
EspSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Save = true, -- Config akan disimpan
    Flag = "EspToggle", -- Nama unik untuk config
    Callback = function(Value)
        print("ESP is now", Value)
    end    
})

-- COLORPICKER: Pemilih Warna (Penting buat ESP)
EspSection:AddColorpicker({
    Name = "Enemy Color",
    Default = Color3.fromRGB(255, 0, 0), -- Merah
    Save = true, -- Warna juga disimpan di config
    Flag = "EspColor",
    Callback = function(Value)
        -- Logika ubah warna ESP disini
        print("Warna ESP diubah menjadi:", Value)
    end    
})

-- =================================================================
-- TAB 3: SETTINGS (Contoh Dropdown, Keybind, Textbox, Paragraph)
-- =================================================================
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "Settings",
    PremiumOnly = false
})

-- PARAGRAPH: Teks Panjang
SettingsTab:AddParagraph("Info", "Versi Script: 1.0\nDibuat oleh: GRAYWOLF\nCatraz Hub Official")

-- DROPDOWN: Menu Pilihan (Ganti Tema)
SettingsTab:AddDropdown({
    Name = "Select Theme",
    Default = "Default",
    Options = {"Default", "Ocean", "Void", "Hackerman"}, -- Harus sesuai nama di tabel Themes source code
    Callback = function(Value)
        OrionLib.SelectedTheme = Value
        OrionLib:SetTheme() -- Memanggil fungsi reload tema (Pastikan source code sudah diedit!)
    end    
})

-- KEYBIND: Pengatur Tombol Keyboard
SettingsTab:AddBind({
    Name = "Toggle UI Key",
    Default = Enum.KeyCode.RightShift,
    Hold = false,
    Callback = function()
        print("UI Toggled") -- Fungsi internal Orion sudah otomatis handle hide/show
    end    
})

-- TEXTBOX: Input Teks
SettingsTab:AddTextbox({
    Name = "Webhook URL",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        print("Webhook baru:", Value)
    end	  
})

-- 3. INISIALISASI AKHIR
OrionLib:Init() -- Wajib dipanggil di akhir biar config ke-load