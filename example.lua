--[[
    CATRAZ HUB - SHOWCASE SCRIPT
    Update: Added Notification Toggle Example
]]

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub | Development",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazTest",
    IntroEnabled = true,
    IntroText = "Welcome Graywolf",
    IntroIcon = "ghost",
    ImageBackground = "rbxassetid://4483345998",
    ImageTransparency = 0.8
})

-- =================================================================
-- TAB: MAIN
-- =================================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "house",
    PremiumOnly = false
})

local NotifySection = MainTab:AddSection({
    Name = "Notification Test"
})

-- [[ CONTOH NOTIFICATION TOGGLE ]] --
NotifySection:AddToggle({
    Name = "Enable Notifs",
    Default = false,
    Callback = function(Value)
        -- Logika: Jika Value == true (Nyala), kirim notif
        if Value then
            OrionLib:MakeNotification({
                Name = "System",
                Content = "Notifications are now ENABLED!",
                Image = "bell", -- Pastikan icon 'bell' ada di list kamu
                Time = 3
            })
        else
            -- Jika mati
            OrionLib:MakeNotification({
                Name = "System",
                Content = "Notifications DISABLED.",
                Image = "bell-off", -- Pastikan icon 'bell-off' ada
                Time = 3
            })
        end
    end    
})

-- Section Lain
local CombatSection = MainTab:AddSection({
    Name = "Combat Features"
})

CombatSection:AddButton({
    Name = "Test Modern Notif",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Achievement",
            Content = "You clicked the button! This notification has a custom glow outline.",
            Image = "trophy",
            Time = 5
        })
    end    
})

-- =================================================================
-- TAB: SETTINGS
-- =================================================================
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "cog",
    PremiumOnly = false
})

SettingsTab:AddDropdown({
    Name = "Select Theme",
    Default = "Default",
    Options = {"Default", "Ocean", "Void", "Hackerman"},
    Callback = function(Value)
        OrionLib.SelectedTheme = Value
        OrionLib:SetTheme()
    end    
})

OrionLib:Init()