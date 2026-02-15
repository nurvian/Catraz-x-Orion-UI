local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
-- GANTI BAGIAN OrionLib.Themes DENGAN INI:
	Themes = {
		Default = { -- Ini "Catraz Theme" (Default)
			Main = Color3.fromRGB(18, 18, 18), -- Background Utama (Gelap banget)
			Second = Color3.fromRGB(28, 28, 28), -- Background Tombol/Tab
			Stroke = Color3.fromRGB(200, 40, 40), -- OUTLINE MERAH (Identitas Catraz)
			Divider = Color3.fromRGB(45, 45, 45), -- Garis pemisah
			Text = Color3.fromRGB(255, 255, 255), -- Teks Utama
			TextDark = Color3.fromRGB(170, 170, 170) -- Teks Deskripsi
		},
		Ocean = { -- Cocok buat Script Fishing
			Main = Color3.fromRGB(20, 25, 35),
			Second = Color3.fromRGB(30, 40, 50),
			Stroke = Color3.fromRGB(0, 150, 255), -- Outline Biru Laut
			Divider = Color3.fromRGB(40, 55, 70),
			Text = Color3.fromRGB(240, 255, 255),
			TextDark = Color3.fromRGB(150, 180, 200)
		},
        Void = { -- Tema Hitam Putih (Clean)
			Main = Color3.fromRGB(8, 8, 8),
			Second = Color3.fromRGB(15, 15, 15),
			Stroke = Color3.fromRGB(255, 255, 255), -- Outline Putih Terang
			Divider = Color3.fromRGB(30, 30, 30),
			Text = Color3.fromRGB(255, 255, 255),
			TextDark = Color3.fromRGB(100, 100, 100)
		},
        Hackerman = { -- Tema Hijau Matrix
            Main = Color3.fromRGB(10, 15, 10),
            Second = Color3.fromRGB(20, 30, 20),
            Stroke = Color3.fromRGB(0, 255, 100), -- Outline Hijau Neon
            Divider = Color3.fromRGB(20, 50, 20),
            Text = Color3.fromRGB(200, 255, 200),
            TextDark = Color3.fromRGB(100, 150, 100)
        }
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

-- [[ ICON SYSTEM KHUSUS FORMAT SIMPLE ]] --
local Icons = (function()
    -- Ganti link ini dengan link RAW pastebin/github file icon kamu yang tadi
    local Success, Result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
    end)
    
    -- Kalau gagal load, balikin tabel kosong biar ga error
    if not Success then return {} end
    return Result
end)()

local function GetIcon(Name)
    if Icons[Name] then
        return Icons[Name] -- Mengembalikan "rbxassetid://..."
    end
    return nil
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end

end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				--TweenService:Create(Main, TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
				Main.Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end    

-- [[ SOURCE.LUA - BARIS 136 (DI BAWAH MAKEDRAGGABLE) ]] --

local function MakeResizable(Handle, Target)
    local Resizing = false
    local StartPos = nil
    local StartSize = nil

    AddConnection(Handle.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Resizing = true
            StartPos = Input.Position
            StartSize = Target.Size
        end
    end)

    AddConnection(UserInputService.InputChanged, function(Input)
        if Resizing and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - StartPos
            -- Batas minimal $450 \times 260$, maksimal $800 \times 600$
            local NewWidth = math.clamp(StartSize.X.Offset + Delta.X, 450, 800)
            local NewHeight = math.clamp(StartSize.Y.Offset + Delta.Y, 260, 600)
            Target.Size = UDim2.new(0, NewWidth, 0, NewHeight)
        end
    end)

    AddConnection(UserInputService.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Resizing = false
        end
    end)
end

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end    
	table.insert(OrionLib.ThemeObjects[Type], Object)
	local Theme = OrionLib.Themes[OrionLib.SelectedTheme] or OrionLib.Themes["Default"]
	Object[ReturnProperty(Object)] = Theme[Type]
	return Object
end    

function OrionLib:SetTheme() 
	-- [[ FIX: VALIDASI TEMA SEBELUM LOOP ]] --
	local TargetTheme = OrionLib.Themes[OrionLib.SelectedTheme]
	if not TargetTheme then 
		OrionLib.SelectedTheme = "Default"
		TargetTheme = OrionLib.Themes["Default"]
	end

	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = TargetTheme[Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function() 
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end



CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

-- [[ SOURCE.LUA - UPDATE CREATEELEMENT IMAGE ]] --
CreateElement("Image", function(ImageName_or_ID)
    local ImageProps = {
        BackgroundTransparency = 1,
        Image = "",
        ScaleType = Enum.ScaleType.Fit
    }

    local IconData = GetIcon(ImageName_or_ID)
    
    if IconData then
        if type(IconData) == "table" then
            -- Jika library format Table (Spritesheet)
            ImageProps.Image = IconData.Image
            ImageProps.ImageRectSize = IconData.ImageRectSize
            ImageProps.ImageRectOffset = IconData.ImageRectPosition
            ImageProps.ScaleType = Enum.ScaleType.Stretch
        else
            -- Jika library format String (ID Langsung)
            ImageProps.Image = IconData
        end
    elseif ImageName_or_ID then
        -- Jika input adalah rbxassetid manual
        ImageProps.Image = ImageName_or_ID
    end

    return Create("ImageLabel", ImageProps)
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:AddDialog(Config)
    Config = Config or {}
    Config.Title = Config.Title or "Dialog"
    Config.Content = Config.Content or "Are you sure?"
    Config.YesText = Config.YesText or "Yes"
    Config.NoText = Config.NoText or "No"
    Config.Callback = Config.Callback or function() end

    local DialogOverlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Parent = Orion,
        ZIndex = 5000, -- Naikkan ZIndex agar di atas segalanya
        Active = true
    })

    local DialogFrame = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
        Parent = DialogOverlay,
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 5001,
        ClipsDescendants = false -- Pastikan false agar elemen dalam terlihat
    }), "Second")

    AddThemeObject(MakeElement("Stroke", nil, 2), "Stroke").Parent = DialogFrame

    -- Judul & Konten
    local TitleLabel = Create("TextLabel", {
        Parent = DialogFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 10), Text = Config.Title, TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18, Font = Enum.Font.GothamBold, ZIndex = 5002
    })

    local ContentLabel = Create("TextLabel", {
        Parent = DialogFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 45),
        Position = UDim2.new(0, 20, 0, 42), Text = Config.Content, TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 13, Font = Enum.Font.Gotham, TextWrapped = true, ZIndex = 5002
    })

    -- Tombol YES
    local YesBtn = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(200, 40, 40), 0, 6), {
        Size = UDim2.new(0, 110, 0, 35),
        Position = UDim2.new(0.5, -120, 0.4, 0), -- Posisi eksplisit
        Parent = DialogFrame, ZIndex = 5003
    }), "Stroke")

    local YesClick = Create("TextButton", {
        Parent = YesBtn, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = Config.YesText, TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 5004
    })

    -- Tombol NO
    local NoBtn = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(45, 45, 45), 0, 6), {
        Size = UDim2.new(0, 110, 0, 35),
        Position = UDim2.new(0.5, 10, 0.4, 0),
        Parent = DialogFrame, ZIndex = 5003
    }), "Divider")

    local NoClick = Create("TextButton", {
        Parent = NoBtn, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = Config.NoText, TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 5004
    })

    -- [[ ANIMASI MASUK FIXED ]]
    local DialogScale = Create("UIScale", { Parent = DialogFrame, Scale = 0 })
    TweenService:Create(DialogOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(DialogScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    -- [[ EVENT CLICK FIXED ]]
    YesClick.MouseButton1Up:Connect(function()
        Config.Callback()
        DialogOverlay:Destroy()
    end)

    NoClick.MouseButton1Up:Connect(function()
        local TweenOut = TweenService:Create(DialogScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        TweenService:Create(DialogOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenOut:Play()
        TweenOut.Completed:Connect(function() DialogOverlay:Destroy() end)
    end)
end

-- NEW NEW GANTI SELURUH FUNCTION OrionLib:MakeNotification DENGAN INI:

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or ""
		NotificationConfig.Time = NotificationConfig.Time or 5 
        -- Properti baru untuk Background Image di Notifikasi
		NotificationConfig.ImageBackground = NotificationConfig.ImageBackground or nil
		NotificationConfig.ImageTransparency = NotificationConfig.ImageTransparency or 0.8

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		-- 1. FRAME UTAMA
		local NotificationFrame = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 8), {
			Parent = NotificationParent, 
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0.1, 
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = false 
		}), "Second")

        -- [[ FITUR BARU: BACKGROUND IMAGE NOTIFIKASI ]]
		if NotificationConfig.ImageBackground then
			local NotifBG = Create("ImageLabel", {
				Name = "NotifBackground",
				Parent = NotificationFrame,
				BackgroundTransparency = 1,
				Image = NotificationConfig.ImageBackground,
				ImageTransparency = NotificationConfig.ImageTransparency,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				ZIndex = 0, -- Di belakang teks
				ScaleType = Enum.ScaleType.Stretch
			})
			Create("UICorner", {
				CornerRadius = UDim.new(0, 8),
				Parent = NotifBG
			})
		end
		
		-- 2. OUTLINE
		local Outline = AddThemeObject(MakeElement("Stroke", Color3.fromRGB(255, 255, 255), 1.5), "Stroke")
		Outline.Parent = NotificationFrame
		Outline.Transparency = 0

		-- 3. DROP SHADOW
		local Shadow = Create("ImageLabel", {
			Parent = NotificationFrame,
			BackgroundTransparency = 1,
			Image = "rbxassetid://5554236805", 
			ImageColor3 = Color3.fromRGB(0,0,0),
			ImageTransparency = 0.5,
			Size = UDim2.new(1, 20, 1, 20),
			Position = UDim2.new(0, -10, 0, -10),
			ZIndex = 0,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(23,23,277,277)
		})

		-- 4. DEFINISI ELEMENT (Disimpan ke variabel biar gak error "Not a valid member")
		local NotifPadding = MakeElement("Padding", 12, 12, 12, 12)
		
		local NotifIcon = SetProps(MakeElement("Image", NotificationConfig.Image), {
			Size = UDim2.new(0, 24, 0, 24),
			ImageColor3 = Color3.fromRGB(240, 240, 240),
			Name = "Icon",
			Position = UDim2.new(0, 0, 0, 2)
		})

		local NotifTitle = AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Name, 16), {
			Size = UDim2.new(1, -35, 0, 20),
			Position = UDim2.new(0, 32, 0, 2),
			Font = Enum.Font.GothamBold,
			Name = "Title",
			TextXAlignment = Enum.TextXAlignment.Left
		}), "Text")

		local NotifContent = AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 32),
			Font = Enum.Font.GothamMedium,
			Name = "Content",
			AutomaticSize = Enum.AutomaticSize.Y,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextWrapped = true,
			TextTransparency = 0.3
		}), "TextDark")

		-- Masukkan semua element ke dalam Frame
		SetChildren(NotificationFrame, {
			NotifPadding,
			NotifIcon,
			NotifTitle,
			NotifContent
		})

		-- 5. ANIMASI (Pake variabel lokal tadi)
		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		wait(NotificationConfig.Time - 0.88)

		-- Animasi Keluar
		TweenService:Create(NotifIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
		TweenService:Create(Shadow, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(Outline, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
		TweenService:Create(NotifTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		TweenService:Create(NotifContent, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
		
        -- Animasi Background Image Keluar (Jika ada)
		if NotificationFrame:FindFirstChild("NotifBackground") then
			TweenService:Create(NotificationFrame.NotifBackground, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		end

		wait(0.2)
		NotificationFrame:TweenPosition(UDim2.new(1.2, 0, 0, 0),'In','Quint',0.8,true)
		
		wait(1)
		NotificationFrame:Destroy()
		NotificationParent:Destroy()
	end)
end

function OrionLib:Init()
    local AutoLoadPath = OrionLib.Folder .. "/AutoLoad.txt"
    if isfile(AutoLoadPath) then
        local Target = readfile(AutoLoadPath)
        local ConfigPath = OrionLib.Folder .. "/" .. Target .. ".txt"
        if isfile(ConfigPath) then
            pcall(function() LoadCfg(readfile(ConfigPath)) end) -- Memuat otomatis
        end
    end
end

function OrionLib:MakeWindow(WindowConfig)
    local FirstTab = true
    local Minimized = false
    local Loaded = false
    local UIHidden = false

    -- Logika Auto-Detect
    local UserInputService = game:GetService("UserInputService")
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local DefaultSize = IsMobile and UDim2.new(0, 450, 0, 260) or UDim2.new(0, 615, 0, 344)
    local DefaultPos = UDim2.new(0.5, -DefaultSize.X.Offset/2, 0.5, -DefaultSize.Y.Offset/2)

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
    -- SET DEFAULT BACKGROUND DISINI (Set Kasar)
    WindowConfig.ImageBackground = WindowConfig.ImageBackground or "rbxassetid://93195749393891"
    WindowConfig.ImageTransparency = WindowConfig.ImageTransparency or 0.8
    WindowConfig.WindowTransparency = WindowConfig.WindowTransparency or 0.1
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"), 
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"), 
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1, 0, 1, 0),
				}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		}),
	}), "Second")

    -- [[ 1. SIAPKAN ELEMEN HEADER ]] --
    WindowConfig.Name = WindowConfig.Name or "Orion Library"
    WindowConfig.Version = WindowConfig.Version or "v1.0.0"
    WindowConfig.Subtext = WindowConfig.Subtext or "Premium Script Hub"
    WindowConfig.VersionIcon = WindowConfig.VersionIcon or "shield-check"
    WindowConfig.TagColor = WindowConfig.TagColor or OrionLib.Themes[OrionLib.SelectedTheme].Stroke
    
    -- [[ 1. ADJUST WINDOW NAME (NAIKKAN) ]] --
    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 18), {
        AnchorPoint = Vector2.new(0, 0.5), 
        -- Ubah angka 0 menjadi -10 untuk menaikkan judul
        Position = UDim2.new(0, (WindowConfig.ShowIcon and 55 or 25), 0.5, -10), 
        Size = UDim2.new(0, 0, 0, 30),
        Font = Enum.Font.GothamBlack,
        Text = WindowConfig.Name,
        Name = "Title",
        ZIndex = 50,
        AutomaticSize = Enum.AutomaticSize.X
    }), "Text")

    -- [[ 2. ADJUST SUBTEXT (NAIKKAN) ]] --
    local WindowSubtext = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Subtext, 11), {
        AnchorPoint = Vector2.new(0, 0.5),
        -- Ubah angka 15 menjadi 5 agar subtext ikut naik mendekati judul
        Position = UDim2.new(0, (WindowConfig.ShowIcon and 55 or 25), 0.5, 5), 
        Size = UDim2.new(0, 0, 0, 15),
        Font = Enum.Font.GothamSemibold,
        Text = WindowConfig.Subtext,
        Name = "Subtext",
        ZIndex = 50,
        AutomaticSize = Enum.AutomaticSize.X
    }), "TextDark")

    local VersionTag = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", WindowConfig.TagColor, 0, 4), {
        Size = UDim2.new(0, 0, 0, 18), -- Ukuran tetap 18 sesuai permintaan
        Name = "VersionTag",
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 40
    }), {
        MakeElement("Padding", 0, 6, 6, 0), -- Jarak dalam tag
        SetProps(MakeElement("List", 0, 4), { -- Menata icon & teks ke samping secara otomatis
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        -- Ikon Lucide di depan
        SetProps(MakeElement("Image", WindowConfig.VersionIcon), {
            Size = UDim2.new(0, 12, 0, 12),
            Name = "VIcon",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 45
        }),
        -- Teks Versi
        SetProps(MakeElement("Label", WindowConfig.Version, 11), {
            Size = UDim2.new(0, 0, 0, 12),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = WindowConfig.Version,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 45
        })
    }), "Stroke")
    
    MakeElement("Padding", 0, 6, 6, 0).Parent = VersionTag -- Kasih jarak

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

    -- [[ BAGIAN RAWAN ERROR YANG SUDAH DIPERBAIKI ]] --
    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
        Parent = Orion,
        Position = DefaultPos, -- Menggunakan variabel dari auto-detect
        Size = DefaultSize,    -- Menggunakan variabel dari auto-detect
        ClipsDescendants = true,
        BackgroundTransparency = WindowConfig.WindowTransparency or 0.1
    }), {
        -- [[ TOPBAR ]] --
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Name = "TopBar"
        }), {
            WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
                Size = UDim2.new(0, 70, 0, 30),
                Position = UDim2.new(1, -90, 0, 10)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Frame"), {
                    Size = UDim2.new(0, 1, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0)
                }), "Stroke"), 
                CloseBtn,
                MinimizeBtn
            }), "Second"), 
        }),
        DragPoint,
        WindowStuff,

        -- [[ 1. TAMBAHKAN RESIZE HANDLE DI SINI ]] --
        Create("ImageLabel", {
            Name = "ResizeHandle",
            Position = UDim2.new(1, -18, 1, -18), -- Pojok kanan bawah
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Image = "rbxassetid://136255899715930", -- Icon resize segitiga
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.5,
            ZIndex = 10,
            Active = true
        })
    }), "Main")
	
    -- [[ 3. PASANG PARENT & LOGIKA SETELAH WINDOW JADI ]] --
    WindowName.Parent = MainWindow.TopBar
    WindowSubtext.Parent = MainWindow.TopBar
    VersionTag.Parent = MainWindow.TopBar
    VersionTag.BackgroundColor3 = WindowConfig.TagColor or OrionLib.Themes[OrionLib.SelectedTheme].Stroke -- Sekarang MainWindow sudah tidak nil

    WindowName.Text = WindowConfig.Name
    WindowSubtext.Text = WindowConfig.Subtext

    -- Logika Ikon yang BENAR (Baris 793)
    if WindowConfig.ShowIcon then
        local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
            Parent = MainWindow.TopBar,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 20, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Name = "HeaderIcon",
            ZIndex = 10
        })
    end

    -- [[ UPDATE POSISI: MOVE UP ]] --
    task.spawn(function()
        while MainWindow and MainWindow.Parent do
            local TitleX = WindowName.AbsolutePosition.X - MainWindow.AbsolutePosition.X
            -- Ganti angka terakhir jadi -12 atau -14 untuk menaikkan tag
            VersionTag.Position = UDim2.new(0, TitleX + WindowName.AbsoluteSize.X + 8, 0.5, -20) 
            task.wait(0.2)
        end
    end)

    -- [[ RESIZE & DRAG ]]
    if MainWindow:FindFirstChild("ResizeHandle") then
        MakeResizable(MainWindow.ResizeHandle, MainWindow)
    end
    MakeDraggable(DragPoint, MainWindow)
	
   -- [[ FIX LOGIKA BACKGROUND IMAGE ]]
	if WindowConfig.ImageBackground then
		local BGImage = Create("ImageLabel", {
			Name = "BackgroundCustom",
			Parent = MainWindow,
			BackgroundTransparency = 1,
			Image = WindowConfig.ImageBackground, 
			ImageTransparency = WindowConfig.ImageTransparency, 
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 0, 
			ScaleType = Enum.ScaleType.Stretch, -- Ganti ke Stretch agar ID biasa muncul
		})
        
        local BGCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = BGImage
        })
	end
    -- HAPUS BIANGKEROKNYA
    -- [[ SOURCE.LUA - UPDATE CLOSE BUTTON ]] --
    AddConnection(CloseBtn.MouseButton1Up, function()
        OrionLib:AddDialog({
            Title = "Exit Catraz Hub?",
            Content = "Are you sure you want to close? You will need to re-execute the script.",
            YesText = "Yes, Close",
            NoText = "No, Stay",
            Callback = function()
                OrionLib:Destroy() -- Fungsi destroy kamu yang lama
            end
        })
    end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
		end
	end)

    -- [[ 1. SET DEFAULT & CHANGEABLE ICON ]] --
    WindowConfig.ToggleIcon = WindowConfig.ToggleIcon or "rbxassetid://105921924721005"
    WindowConfig.ToggleSize = WindowConfig.ToggleSize or 50 -- Ukuran bisa di-custom

    -- [[ SOURCE.LUA - UPDATE FLOATING TOGGLE (MODERN STYLE) ]] --

    -- Wadah utama dibuat transparan total
    local FloatingToggle = AddThemeObject(SetProps(MakeElement("Frame"), {
        Size = UDim2.new(0, 0, 0, 0), -- Mulai dari 0 untuk animasi masuk
        Position = UDim2.new(0.1, 0, 0.5, 0),
        Parent = Orion,
        Visible = false,
        ZIndex = 100,
        BackgroundTransparency = 1, -- Transparan agar hanya gambar yang terlihat
        Active = true,
        AnchorPoint = Vector2.new(0.5, 0.5)
    }), "Second")

    -- Layer Bayangan (Modern Shadow) agar gambar terlihat melayang
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = FloatingToggle,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993", -- Shadow lembut
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        Size = UDim2.new(1.5, 0, 1.5, 0), -- Lebih lebar dari icon
        Position = UDim2.new(0.5, 0, 0.5, 2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 99
    })

    -- Icon Utama (Mengisi penuh wadah agar "pas")
    local MainIcon = SetProps(MakeElement("Image", WindowConfig.ToggleIcon), {
        Parent = FloatingToggle,
        Size = UDim2.new(1, 0, 1, 0), 
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit, -- Gambar tidak gepeng
        Name = "Icon",
        ZIndex = 100
    })

    -- Tombol Klik & Drag (Transparan di paling atas)
    local ToggleBtn = SetProps(MakeElement("Button"), {
        Parent = FloatingToggle,
        Size = UDim2.new(1, 0, 1, 0),
        Name = "ToggleBtn",
        ZIndex = 102
    })

    -- [[ PERBAIKAN DRAG ]] --
    -- Menggunakan tombol transparan sebagai pemicu drag agar lancar
    MakeDraggable(ToggleBtn, FloatingToggle)

    -- [[ 2. FUNGSI UNTUK GANTI IMAGE TOGEL SECARA DINAMIS ]] --
    function OrionLib:ChangeToggleIcon(NewIconID)
        MainIcon.Image = (string.find(NewIconID, "rbxassetid://") and NewIconID) or "rbxassetid://" .. NewIconID
    end

    -- [[ 3. ANIMASI MINIMIZE (WINDOW KE TOGGLE) ]] --
    AddConnection(MinimizeBtn.MouseButton1Up, function()
        MainWindow.ClipsDescendants = true
        local Tween = TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = FloatingToggle.Position,
            BackgroundTransparency = 1
        })
        Tween:Play()
        
        Tween.Completed:Connect(function()
            MainWindow.Visible = false
            FloatingToggle.Visible = true
            -- Animasi membesar menggunakan ToggleSize
            TweenService:Create(FloatingToggle, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, WindowConfig.ToggleSize, 0, WindowConfig.ToggleSize)
            }):Play()
        end)
    end)

    -- [[ 4. ANIMASI RE-OPEN (TOGGLE KE WINDOW) ]] --
    AddConnection(ToggleBtn.MouseButton1Up, function()
        local TweenOut = TweenService:Create(FloatingToggle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        TweenOut:Play()
        
        TweenOut.Completed:Connect(function()
            FloatingToggle.Visible = false
            MainWindow.Visible = true
            MainWindow.Position = FloatingToggle.Position 
            
            TweenService:Create(MainWindow, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 615, 0, 344),
                Position = UDim2.new(0.5, -307, 0.5, -172),
                BackgroundTransparency = WindowConfig.WindowTransparency or 0.1
            }):Play()
        end)
    end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})

		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})

		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end 

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end	

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

       -- [[ LOGIKA ICON SIMPLE ]] --
		local IconID = GetIcon(TabConfig.Icon)
		if IconID then
			TabFrame.Ico.Image = IconID
			TabFrame.Ico.ScaleType = Enum.ScaleType.Fit 
		else
			if TabConfig.Icon and string.find(tostring(TabConfig.Icon), "rbxassetid://") then
				TabFrame.Ico.Image = TabConfig.Icon
				TabFrame.Ico.ScaleType = Enum.ScaleType.Fit
			else
				TabFrame.Ico.Image = "" 
			end
		end
        TabFrame.Ico.ImageRectSize = Vector2.new(0,0)
        TabFrame.Ico.ImageRectOffset = Vector2.new(0,0)
        
		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end    

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				end    
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end    
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			
			Container.Visible = true
			Container.Position = UDim2.new(0, 150, 0, 75)
			TweenService:Create(Container, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 150, 0, 50)
			}):Play()
		end)

		-- [[ DEFINISI GetElements (PASTIKAN AddSection ADA DI DALAM SINI) ]] --
		local function GetElements(ItemParent)
			local ElementFunction = {}

			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = ToChange
				end
				return LabelFunction
			end

            -- [[ SOURCE.LUA - ADVANCED DYNAMIC PARAGRAPH ]] --

            function ElementFunction:AddParagraph(Config)
                Config = Config or {}
                Config.Title = Config.Title or "Paragraph"
                Config.Desc = Config.Desc or "Description"
                Config.Image = Config.Image or nil
                Config.ImageSize = Config.ImageSize or 38
                Config.Buttons = Config.Buttons or {} -- Mendukung banyak tombol

                local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 0.85,
                    Parent = ItemParent,
                    ClipsDescendants = true
                }), {
                    AddThemeObject(MakeElement("Stroke", nil, 1), "Stroke"),
                    MakeElement("Padding", 10, 12, 12, 10),
                    SetProps(MakeElement("List", 0, 8), { -- List utama untuk menyusun elemen secara vertikal
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 10)
                    })
                }), "Second")

                -- 1. BAGIAN ATAS (Image + Text)
                local TopContainer = SetProps(MakeElement("TFrame"), {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                TopContainer.Parent = ParagraphFrame
                
                local MainLayout = SetProps(MakeElement("List", 0, 12), {
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Parent = TopContainer
                })

                -- Asset Gambar / Ikon
                if Config.Image or Config.Icon then
                    local Img = SetProps(MakeElement("Image", Config.Image or Config.Icon), {
                        Parent = TopContainer,
                        Size = UDim2.new(0, Config.ImageSize, 0, Config.ImageSize),
                        ZIndex = 5
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Img })
                end

                -- Container Teks
                local TextContainer = SetChildren(SetProps(MakeElement("TFrame"), {
                    Size = UDim2.new(1, -(Config.Image and Config.ImageSize + 15 or 0), 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = TopContainer
                }), {
                    MakeElement("List", 0, 2)
                })

                local TitleLabel = AddThemeObject(SetProps(MakeElement("Label", Config.Title, 15), {
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Parent = TextContainer
                }), "Text")

                local DescLabel = AddThemeObject(SetProps(MakeElement("Label", Config.Desc, 13), {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Font = Enum.Font.GothamMedium,
                    TextWrapped = true,
                    TextTransparency = 0.3,
                    Parent = TextContainer
                }), "TextDark")

                -- 2. BAGIAN TOMBOL (Jika ada)
                local ButtonContainer = SetProps(MakeElement("TFrame"), {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = ParagraphFrame,
                    Visible = #Config.Buttons > 0
                })
                SetProps(MakeElement("List", 0, 8), { FillDirection = Enum.FillDirection.Horizontal, Parent = ButtonContainer })

                for _, BtnData in ipairs(Config.Buttons) do
                    local SmallBtn = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(200, 40, 40), 0, 4), {
                        Size = UDim2.new(0, 0, 0, 26),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Parent = ButtonContainer
                    }), {
                        MakeElement("Padding", 0, 10, 10, 0),
                        SetProps(MakeElement("Label", BtnData.Title, 12), {
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            Font = Enum.Font.GothamBold,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextXAlignment = Enum.TextXAlignment.Center
                        })
                    }), "Stroke")
                    
                    local BtnClick = SetProps(MakeElement("Button"), { Parent = SmallBtn, Size = UDim2.new(1, 0, 1, 0) })
                    BtnClick.MouseButton1Up:Connect(BtnData.Callback)
                end

                -- 3. AUTO RESIZE LOGIC
                AddConnection(ParagraphFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.UIListLayout.AbsoluteContentSize.Y + 20)
                end)

                -- 4. RETURN FUNCTIONS (Untuk Live Update)
                local ParagraphFunctions = {}
                function ParagraphFunctions:SetTitle(NewTitle) TitleLabel.Text = NewTitle end
                function ParagraphFunctions:SetDesc(NewDesc) DescLabel.Text = NewDesc end
                function ParagraphFunctions:SetImage(NewImg) if TopContainer:FindFirstChild("ImageLabel") then TopContainer.ImageLabel.Image = NewImg end end
                
                return ParagraphFunctions
            end

			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://107150227368485"
				local Button = {}
				local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })
				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")
				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function() ButtonConfig.Callback() end)
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
				function Button:Set(ButtonText) ButtonFrame.Content.Text = ButtonText end	
				return Button
			end    

            -- [[ SOURCE.LUA - UPDATE ADD TOGGLE (SWITCH STYLE) ]] --

            function ElementFunction:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(200, 40, 40) -- Warna Catraz (Merah)
                ToggleConfig.Flag = ToggleConfig.Flag or nil
                ToggleConfig.Save = ToggleConfig.Save or false

                local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save, Type = "Toggle"}
                local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })

                -- 1. TRACK (Latar belakang saklar yang lonjong)
                local ToggleTrack = SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Divider, 0, 12), {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 0 --
                }), {
                    AddThemeObject(MakeElement("Stroke", nil, 1.5), "Stroke") -- Outline saklar
                })

                -- 2. KNOB (Bulatan saklar yang bergeser)
                local ToggleKnob = SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Parent = ToggleTrack
                })

                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = ItemParent,
                    BackgroundTransparency = WindowConfig.WindowTransparency -- Ikut transparansi window
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
                        Size = UDim2.new(1, -60, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    ToggleTrack,
                    Click
                }), "Second")

                -- 3. FUNGSI ANIMASI GESER
                function Toggle:Set(Value)
                    Toggle.Value = Value
                    
                    -- Animasi Warna Track
                    local TargetColor = Toggle.Value and ToggleConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Divider
                    TweenService:Create(ToggleTrack, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = TargetColor}):Play()
                    
                    -- Animasi Geser Knob
                    local TargetPosition = Toggle.Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                    TweenService:Create(ToggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = TargetPosition}):Play()
                    
                    -- Callback
                    ToggleConfig.Callback(Toggle.Value)
                end    

                -- Inisialisasi awal
                Toggle:Set(Toggle.Value)

                -- Event Klik
                AddConnection(Click.MouseButton1Up, function()
                    Toggle:Set(not Toggle.Value)
                    if OrionLib.SaveCfg then
                        SaveCfg(game.GameId)
                    end
                end)

                -- Hover effect
                AddConnection(Click.MouseEnter, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
                end)
                AddConnection(Click.MouseLeave, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                end)

                if ToggleConfig.Flag then OrionLib.Flags[ToggleConfig.Flag] = Toggle end	
                return Toggle
            end

			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false
				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false
				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})
				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), { Color = SliderConfig.Color }),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.8
					}), "Text"),
					SliderDrag
				})
				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")
				SliderBar.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end 
				end)
				SliderBar.InputEnded:Connect(function(Input) 
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end 
				end)
				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then 
						local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale)) 
						SaveCfg(game.GameId)
					end
				end)
				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					TweenService:Create(SliderDrag,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
					SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderConfig.Callback(self.Value)
				end      
				Slider:Set(Slider.Value)
				if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = Slider end
				return Slider
			end  

            -- [[ SOURCE.LUA - UPDATE DROPDOWN: MULTI-SELECT & DESELECT & SEARCH ]] --

            function ElementFunction:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or ""
                DropdownConfig.Multi = DropdownConfig.Multi or false -- FITUR BARU: Pilihan Ganda
                DropdownConfig.Search = DropdownConfig.Search or false 
                DropdownConfig.AllowNone = (DropdownConfig.AllowNone == nil and true) or DropdownConfig.AllowNone
                DropdownConfig.Callback = DropdownConfig.Callback or function() end
                DropdownConfig.Flag = DropdownConfig.Flag or nil
                DropdownConfig.Save = DropdownConfig.Save or false
                

                -- Inisialisasi Value (Kalau Multi pake Tabel, kalau Single pake String)
                local Dropdown = {
                    Value = DropdownConfig.Multi and {} or DropdownConfig.Default, 
                    Options = DropdownConfig.Options, 
                    Buttons = {}, 
                    Toggled = false, 
                    Type = "Dropdown", 
                    Save = DropdownConfig.Save
                }
                
                local MaxElements = 5
                local ContainerYOffset = DropdownConfig.Search and 72 or 38
                
                local DropdownList = MakeElement("List")
                local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {DropdownList}), {
                    Position = UDim2.new(0, 0, 0, ContainerYOffset),
                    Size = UDim2.new(1, 0, 1, -ContainerYOffset),
                    ClipsDescendants = true
                }), "Divider")

                local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })
                
                local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = ItemParent,
                    ClipsDescendants = true,
                    BackgroundTransparency = WindowConfig.WindowTransparency
                }), {
                    DropdownContainer,
                    SetProps(SetChildren(MakeElement("TFrame"), {
                        AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
                            Size = UDim2.new(1, -12, 1, 0),
                            Position = UDim2.new(0, 12, 0, 0),
                            Font = Enum.Font.GothamBold,
                            Name = "Content"
                        }), "Text"),
                        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
                            Size = UDim2.new(0, 20, 0, 20),
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(1, -30, 0.5, 0),
                            Name = "Ico"
                        }), "TextDark"),
                        AddThemeObject(SetProps(MakeElement("Label", "...", 13), {
                            Size = UDim2.new(1, -40, 1, 0),
                            Font = Enum.Font.Gotham,
                            Name = "Selected",
                            TextXAlignment = Enum.TextXAlignment.Right
                        }), "TextDark"),
                        AddThemeObject(SetProps(MakeElement("Frame"), {
                            Size = UDim2.new(1, 0, 0, 1),
                            Position = UDim2.new(0, 0, 1, -1),
                            Name = "Line",
                            Visible = false
                        }), "Stroke"), 
                        Click
                    }), {Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true, Name = "F"}),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    MakeElement("Corner")
                }), "Second")

                -- [[ SOURCE.LUA - FIXED DROPDOWN DISPLAY BUG ]] --

                local function UpdateSelectedText()
                    if DropdownConfig.Multi then
                        -- Pastikan variabel adalah tabel
                        if type(Dropdown.Value) ~= "table" then Dropdown.Value = {} end
                        
                        if #Dropdown.Value == 0 then
                            DropdownFrame.F.Selected.Text = "..."
                        else
                            -- Membersihkan tampilan: Pastikan hanya nama string yang digabung
                            local DisplayList = {}
                            for _, v in ipairs(Dropdown.Value) do
                                -- Pastikan v bukan tabel agar tidak muncul "table: 0x..."
                                if type(v) ~= "table" then
                                    table.insert(DisplayList, tostring(v))
                                end
                            end
                            DropdownFrame.F.Selected.Text = table.concat(DisplayList, ", ")
                        end
                    else
                        -- Untuk Single-Select: Jika tidak sengaja terisi tabel, ambil item pertama atau kosongkan
                        if type(Dropdown.Value) == "table" then
                            Dropdown.Value = Dropdown.Value[1] or ""
                        end
                        
                        local DisplayValue = tostring(Dropdown.Value or "")
                        DropdownFrame.F.Selected.Text = (DisplayValue == "" or DisplayValue == "nil") and "..." or DisplayValue
                    end
                end

                -- [[ FIX LOGIKA DROPDOWN DI SOURCE.LUA ]] --

                function Dropdown:Set(Value)
                    if DropdownConfig.Multi then
                        if type(Value) == "table" then
                            Dropdown.Value = Value
                        else
                            if type(Dropdown.Value) ~= "table" then Dropdown.Value = {} end
                            local FoundIndex = table.find(Dropdown.Value, Value)
                            if FoundIndex then
                                if DropdownConfig.AllowNone or #Dropdown.Value > 1 then
                                    table.remove(Dropdown.Value, FoundIndex)
                                end
                            else
                                table.insert(Dropdown.Value, Value)
                            end
                        end
                    else
                        -- FIX: Jangan batalkan pilihan kalau nilainya sama saat startup
                        local NewValue = type(Value) == "table" and Value[1] or Value
                        Dropdown.Value = NewValue
                    end

                    -- Update Visual Tombol
                    for Name, Btn in pairs(Dropdown.Buttons) do
                        local IsActive = false
                        if DropdownConfig.Multi then
                            IsActive = table.find(Dropdown.Value, Name)
                        else
                            IsActive = (Dropdown.Value == Name)
                        end
                        
                        TweenService:Create(Btn, TweenInfo.new(.15), {BackgroundTransparency = IsActive and 0 or 1}):Play()
                        TweenService:Create(Btn.Title, TweenInfo.new(.15), {TextTransparency = IsActive and 0 or 0.4}):Play()
                    end

                    UpdateSelectedText()
                    return DropdownConfig.Callback(Dropdown.Value)
                end

                -- (Logika Search Bar & Refresh tetap sama seperti sebelumnya)
                if DropdownConfig.Search then
                    local SearchFrame = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                        Size = UDim2.new(1, -20, 0, 28),
                        Position = UDim2.new(0, 10, 0, 38),
                        Parent = DropdownFrame,
                        BackgroundTransparency = 0.8
                    }), "Main")

                    local SearchInput = AddThemeObject(Create("TextBox", {
                        Parent = SearchFrame,
                        Size = UDim2.new(1, -10, 1, 0),
                        Position = UDim2.new(0, 5, 0, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        PlaceholderText = "Search...",
                        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        ClearTextOnFocus = false
                    }), "Text")

                    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
                        local Input = SearchInput.Text:lower()
                        for Name, Button in pairs(Dropdown.Buttons) do
                            Button.Visible = string.find(Name:lower(), Input) and true or false
                        end
                    end)
                end

                local function AddOptions(Options)
                    for _, Option in pairs(Options) do
                        local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
                            MakeElement("Corner", 0, 6),
                            AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
                                Position = UDim2.new(0, 8, 0, 0),
                                Size = UDim2.new(1, -8, 1, 0),
                                Name = "Title"
                            }), "Text")
                        }), {
                            Parent = DropdownContainer,
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundTransparency = 1,
                            ClipsDescendants = true
                        }), "Divider")
                        
                        AddConnection(OptionBtn.MouseButton1Click, function()
                            Dropdown:Set(Option)
                            if OrionLib.SaveCfg then SaveCfg(game.GameId) end
                        end)
                        Dropdown.Buttons[Option] = OptionBtn
                    end
                end	

                function Dropdown:Refresh(Options, Delete)
                    if Delete then
                        for _,v in pairs(Dropdown.Buttons) do v:Destroy() end    
                        table.clear(Dropdown.Buttons)
                    end
                    Dropdown.Options = Options
                    AddOptions(Dropdown.Options)
                end  

                AddConnection(Click.MouseButton1Click, function()
                    Dropdown.Toggled = not Dropdown.Toggled
                    DropdownFrame.F.Line.Visible = Dropdown.Toggled
                    TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(.15), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
                    
                    local TargetHeight = 38
                    if Dropdown.Toggled then
                        local ContentHeight = DropdownList.AbsoluteContentSize.Y + ContainerYOffset
                        TargetHeight = math.min(ContentHeight, 38 + (MaxElements * 28) + (DropdownConfig.Search and 34 or 0))
                    end
                    TweenService:Create(DropdownFrame, TweenInfo.new(.15), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
                end)

                Dropdown:Refresh(Dropdown.Options, false)
                Dropdown:Set(Dropdown.Value)
                UpdateSelectedText()
                
                if DropdownConfig.Flag then OrionLib.Flags[DropdownConfig.Flag] = Dropdown end
                return Dropdown
            end

			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false
				local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false
				local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })
				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")
				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")
				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
				end)
				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)
				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function() if not CheckKey(BlacklistedKeys, Input.KeyCode) then Key = Input.KeyCode end end)
						pcall(function() if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then Key = Input.UserInputType end end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)
				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)
				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = Bind.Value.Name or Bind.Value
					BindBox.Value.Text = Bind.Value
				end
				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then OrionLib.Flags[BindConfig.Flag] = Bind end
				return Bind
			end  

			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end
				local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })
				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = "Input",
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false
				}), "Text")
				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")
				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")
				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)
				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then TextboxActual.Text = "" end	
				end)
				TextboxActual.Text = TextboxConfig.Default
				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)
				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)
				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)
				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
			end 

			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false
				local ColorH, ColorS, ColorV = 1, 1, 1
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}
				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252"
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					ColorSelection
				})
				local Hue = Create("Frame", {
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible = false
				}, {
					Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},}),
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					HueSelection
				})
				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Hue,
					Color,
					Create("UIPadding", {
						PaddingLeft = UDim.new(0, 35),
						PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 17)
					})
				})
				local Click = SetProps(MakeElement("Button"), { Size = UDim2.new(1, 0, 1, 0) })
				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Main")
				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")
				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)
				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end
				ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
				ColorS = (math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
				ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then ColorInput:Disconnect() end
						ColorInput = AddConnection(RunService.RenderStepped, function()
							local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
							local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
							ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX
							ColorV = 1 - ColorY
							UpdateColorPicker()
						end)
					end
				end)
				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then ColorInput:Disconnect() end
					end
				end)
				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then HueInput:Disconnect() end
						HueInput = AddConnection(RunService.RenderStepped, function()
							local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
							HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
							ColorH = 1 - HueY
							UpdateColorPicker()
						end)
					end
				end)
				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then HueInput:Disconnect() end
					end
				end)
				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end
				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
				return Colorpicker
			end  
			
            -- [[ SOURCE.LUA - UPGRADED ADDSECTION ]] --

            function ElementFunction:AddSection(SectionConfig)
                SectionConfig.Name = SectionConfig.Name or "Section"
                SectionConfig.TextSize = SectionConfig.TextSize or 17 -- Ukuran teks lebih gede
                SectionConfig.Font = SectionConfig.Font or Enum.Font.GothamBold -- Font default lebih tebal
                SectionConfig.Folded = SectionConfig.Folded or false -- Opsi awal tertutup

                local SectionCollapsed = SectionConfig.Folded
                
                local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
                    Size = UDim2.new(1, 0, 0, 26), -- Akan diatur ulang di bawah
                    Parent = ItemParent,
                    ClipsDescendants = true 
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, SectionConfig.TextSize), {
                        Size = UDim2.new(1, -30, 0, 26), 
                        Position = UDim2.new(0, 0, 0, 0), 
                        TextYAlignment = Enum.TextYAlignment.Center, 
                        Font = SectionConfig.Font -- Menggunakan custom font
                    }), "Text"),
                    SetChildren(SetProps(MakeElement("TFrame"), {
                        AnchorPoint = Vector2.new(0, 0),
                        Size = UDim2.new(1, 0, 0, 0), -- Ukuran holder awal
                        Position = UDim2.new(0, 0, 0, 28),
                        Name = "Holder"
                    }), {
                        MakeElement("List", 0, 6)
                    }),
                })

                local FoldBtn = SetProps(MakeElement("ImageButton", "rbxassetid://92473583511724"), { 
                    Parent = SectionFrame,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0, 3), 
                    ImageColor3 = Color3.fromRGB(150, 150, 150),
                    BackgroundTransparency = 1,
                    Rotation = SectionCollapsed and -90 or 0 -- Atur rotasi awal
                })

                -- Logika Update Ukuran Otomatis
                AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    if not SectionCollapsed then
                        SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 33)
                        SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
                    end
                end)

                -- Set Status Awal (Jika Folded = true)
                if SectionCollapsed then
                    SectionFrame.Size = UDim2.new(1, 0, 0, 26)
                end

                AddConnection(FoldBtn.MouseButton1Click, function()
                    SectionCollapsed = not SectionCollapsed
                    if SectionCollapsed then
                        TweenService:Create(FoldBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Rotation = -90}):Play() 
                        TweenService:Create(SectionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 26)}):Play() 
                    else
                        TweenService:Create(FoldBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
                        TweenService:Create(SectionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                            Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 33)
                        }):Play()
                    end
                end)

                local SectionFunction = {}
                for i, v in next, GetElements(SectionFrame.Holder) do
                    SectionFunction[i] = v 
                end
                return SectionFunction
            end

			return ElementFunction   
		end	
		-- [[ AKHIR DARI FUNGSI GetElements ]] --

		local TabFunctions = GetElements(Container)
		if TabConfig.PremiumOnly then
			for i, v in next, TabFunctions do
				TabFunctions[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Locked Feature", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end

        -- [[ SOURCE.LUA - FINAL PRO CONFIG MANAGER ]] --

        function TabFunction:AddConfigTab(ConfigConfig)
            ConfigConfig = ConfigConfig or {}
            local SelectedConfig = nil
            local NewConfigName = "Default"
            local ImportURL = ""
            local ImportFileName = ""

            local ConfigTab = self:MakeTab({
                Name = ConfigConfig.Name or "Config",
                Icon = ConfigConfig.Icon or "database"
            })

            -- FUNGSI HELPER: Ambil Daftar File (Hanya Nama)
            local function GetConfigList()
                local List = {}
                if isfolder(OrionLib.Folder) then
                    for _, File in ipairs(listfiles(OrionLib.Folder)) do
                        -- Mengambil nama file saja tanpa path dan tanpa .txt
                        local Name = File:match("([^\\/]+)%.txt$")
                        if Name and Name ~= "AutoLoad" then 
                            table.insert(List, Name)
                        end
                    end
                end
                return List
            end

            -- SECTION 1: CREATE & OVERWRITE
            local CreateSection = ConfigTab:AddSection({ Name = "Create & Overwrite" })

            CreateSection:AddTextbox({
                Name = "New Config Name",
                Default = "Default",
                TextDisappear = false,
                Callback = function(Value) NewConfigName = Value end
            })

            CreateSection:AddButton({
                Name = "Create & Save New",
                Callback = function()
                    if NewConfigName ~= "" then
                        SaveCfg(NewConfigName)
                        ConfigTab:RefreshAllDropdowns()
                        OrionLib:MakeNotification({ Name = "Success", Content = "Config '"..NewConfigName.."' Created!", Time = 3 })
                    end
                end
            })

            local OverwriteDropdown = CreateSection:AddDropdown({
                Name = "Select to Overwrite",
                Options = GetConfigList(),
                Callback = function(Value) SelectedConfig = Value end
            })

            CreateSection:AddButton({
                Name = "Overwrite Selected",
                Callback = function()
                    if SelectedConfig and SelectedConfig ~= "" then
                        SaveCfg(SelectedConfig)
                        OrionLib:MakeNotification({ Name = "Config", Content = "Updated '"..SelectedConfig.."'!", Time = 3 })
                    end
                end
            })

            -- SECTION 2: LOAD & MANAGE
            local LoadSection = ConfigTab:AddSection({ Name = "Load & Manage" })

            local LoadDropdown = LoadSection:AddDropdown({
                Name = "Select Config",
                Options = GetConfigList(),
                Callback = function(Value) SelectedConfig = Value end
            })

            LoadSection:AddButton({
                Name = "Load Selected",
                Callback = function()
                    if SelectedConfig then
                        local Path = OrionLib.Folder .. "/" .. SelectedConfig .. ".txt"
                        if isfile(Path) then
                            LoadCfg(readfile(Path)) -- Memuat isi file
                            OrionLib:MakeNotification({ Name = "Success", Content = "Config '"..SelectedConfig.."' Loaded!", Time = 3 })
                        end
                    end
                end
            })

            LoadSection:AddButton({
                Name = "Delete Selected",
                Callback = function()
                    if SelectedConfig then
                        local Path = OrionLib.Folder .. "/" .. SelectedConfig .. ".txt"
                        if isfile(Path) then
                            delfile(Path) -- Menghapus file permanen
                            ConfigTab:RefreshAllDropdowns()
                            OrionLib:MakeNotification({ Name = "Deleted", Content = "File removed.", Time = 3 })
                            SelectedConfig = nil
                        end
                    end
                end
            })

            -- SECTION 3: CLOUD SHARE
            local CloudSection = ConfigTab:AddSection({ Name = "Cloud Share" })

            CloudSection:AddButton({
                Name = "Export Selected to Clipboard",
                Callback = function()
                    if SelectedConfig then
                        local Path = OrionLib.Folder .. "/" .. SelectedConfig .. ".txt"
                        if isfile(Path) then
                            setclipboard(readfile(Path)) -- Salin data JSON ke clipboard
                            OrionLib:MakeNotification({ Name = "Export", Content = "JSON copied to clipboard!", Time = 3 })
                        end
                    end
                end
            })

            CloudSection:AddTextbox({
                Name = "Import Raw URL",
                Placeholder = "https://...",
                Callback = function(V) ImportURL = V end
            })

            CloudSection:AddTextbox({
                Name = "Save As...",
                Placeholder = "NewConfig",
                Callback = function(V) ImportFileName = V end
            })

            CloudSection:AddButton({
                Name = "Download & Import",
                Callback = function()
                    if ImportURL ~= "" and ImportFileName ~= "" then
                        local Success, Response = pcall(function() return game:HttpGet(ImportURL) end)
                        if Success and Response then
                            writefile(OrionLib.Folder .. "/" .. ImportFileName .. ".txt", Response)
                            ConfigTab:RefreshAllDropdowns()
                            OrionLib:MakeNotification({ Name = "Success", Content = "Config Downloaded!", Time = 3 })
                        else
                            OrionLib:MakeNotification({ Name = "Error", Content = "Download Failed!", Time = 3 })
                        end
                    end
                end
            })
            -- SECTION 4: AUTO LOAD SETTINGS
            local AutoSection = ConfigTab:AddSection({ Name = "Startup Settings" })

            AutoSection:AddButton({
                Name = "Set Selected as Auto Load",
                Callback = function()
                    if SelectedConfig then
                        writefile(OrionLib.Folder .. "/AutoLoad.txt", SelectedConfig)
                        OrionLib:MakeNotification({ Name = "Auto Load", Content = SelectedConfig .. " will load next time!", Time = 3 })
                    end
                end
            })

            AutoSection:AddButton({
                Name = "Disable Auto Load",
                Callback = function()
                    if isfile(OrionLib.Folder .. "/AutoLoad.txt") then
                        delfile(OrionLib.Folder .. "/AutoLoad.txt")
                        OrionLib:MakeNotification({ Name = "Auto Load", Content = "Disabled.", Time = 3 })
                    end
                end
            })

            -- FUNGSI INTERNAL: Refresh Dropdown
            function ConfigTab:RefreshAllDropdowns()
                local NewList = GetConfigList()
                LoadDropdown:Refresh(NewList, true) -- Refresh opsi dropdown
                OverwriteDropdown:Refresh(NewList, true)
            end

            return ConfigTab
        end
		
		return TabFunctions 
	end
	--if writefile and isfile then
	--	if not isfile("NewLibraryNotification1.txt") then
	--		local http_req = (syn and syn.request) or (http and http.request) or http_request
	--		if http_req then
	--			http_req({
	--				Url = 'http://127.0.0.1:6463/rpc?v=1',
	--				Method = 'POST',
	--				Headers = {
	--					['Content-Type'] = 'application/json',
	--					Origin = 'https://discord.com'
	--				},
	--				Body = HttpService:JSONEncode({
	--					cmd = 'INVITE_BROWSER',
	--					nonce = HttpService:GenerateGUID(false),
	--					args = {code = 'sirius'}
	--				})
	--			})
	--		end
	--		OrionLib:MakeNotification({
	--			Name = "UI Library Available",
	--			Content = "New UI Library Available - Joining Discord (#announcements)",
	--			Time = 8
	--		})
	--		spawn(function()
	--			local UI = game:GetObjects("rbxassetid://11403719739")[1]

	--			if gethui then
	--				UI.Parent = gethui()
	--			elseif syn.protect_gui then
	--				syn.protect_gui(UI)
	--				UI.Parent = game.CoreGui
	--			else
	--				UI.Parent = game.CoreGui
	--			end

	--			wait(11)

	--			UI:Destroy()
	--		end)
	--		writefile("NewLibraryNotification1.txt","The value for the notification having been sent to you.")
	--	end
	--end
	

	
	return TabFunction
end   

function OrionLib:Destroy()
	Orion:Destroy()
end

return OrionLib