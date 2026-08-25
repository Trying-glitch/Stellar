-- Stellar V5.3.1 Engine - Integrated with Dynamic GC Tokenization & Precision Metatable Proxying
local cloneref = cloneref or function(obj) return obj end
local getconnections = getconnections or function() return {} end
local getupvalues = debug.getupvalues or getupvalues or function() return {} end
local setupvalue = debug.setupvalue or setupvalue or function() end
local getinfo = debug.getinfo or getinfo or function() return { name = "" } end
local islclosure = islclosure or function() return false end
local isourclosure = isourclosure or function() return false end
local setthreadidentity = setthreadidentity or function() end
local hookfunction = hookfunction or (getgenv and getgenv().hookfunction) or (getgenv and getgenv().hookfunc)
local newcclosure = newcclosure or (getgenv and getgenv().newcclosure) or function(f) return f end
local getgc = getgc or function() return {} end
local getrawmetatable = getrawmetatable or function() return {} end
local setreadonly = setreadonly or function() end

-- Core Services Cached
local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local Stats = cloneref(game:GetService('Stats'))

-- Stellar Original Anti-Cheat Environment Hardening
if hookfunction and getrenv then
	pcall(function()
		local _BAC_oldDebugInfo
		_BAC_oldDebugInfo = hookfunction(getrenv().debug.info, function(f, t)
			if type(f) == "function" then
				return "[C]"
			elseif f == 4 and t == "s" then
				return "ReplicatedStorage.Controllers.SwordsController "
			end
			return _BAC_oldDebugInfo(f, t)
		end)
		local _BAC_oldGetfenv
		_BAC_oldGetfenv = hookfunction(getrenv().getfenv, function(l)
			if l ~= nil and type(l) == "number" and l >= 1 and l <= 10 then
				return _BAC_oldGetfenv(10)
			end
			return _BAC_oldGetfenv(l)
		end)
	end)
end

-- Stellar UI Library Initialization
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Trying-glitch/Stellar/refs/heads/main/Stellar%20UI.lua"))()
local library = Library.new()
library:set_background({
    image = 77301388832536,
    transparency = 0.2,
})

-- UI Tab Allocation
local AutoparryTab = library:create_tab("Autoparry", "rbxassetid://76499042599127")
local SpamTab = library:create_tab("Spam Core", "rbxassetid://126017907477623")
local DetectionTab = library:create_tab("Detection", "rbxassetid://126017907477623")
local PlayerTab = library:create_tab("Player Mod", "rbxassetid://126017907477623")
local VisualsTab = library:create_tab("Visuals", "rbxassetid://126017907477623")
local MiscTab = library:create_tab("Misc Spec", "rbxassetid://126017907477623")

-- Global State Machine Initialization
local Stellar = {
	__properties = {
		__autoparry_enabled = false,
		__triggerbot_enabled = false,
		__manual_spam_enabled = false,
		__gui_spam_active = false,
		__auto_spam_enabled = false,
		__play_animation = false,
		__curve_mode = 1,
		__accuracy = 100,
		__divisor_multiplier = 1.1,
		__parried = false,
		__training_parried = false,
		__spam_threshold = 25,
		__parries = 0,
		__parry_key = nil,
		__grab_animation = nil,
		__tornado_time = tick(),
		__connections = {},
		__spam_accumulator = 0,
		__spam_batch_amount = "FPS Priority",
		__randomized_accuracy_enabled = false,
		__is_mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
		__speed_display_enabled = false,
		__spam_target = nil,
		__spam_target_time = 0,
		__timehole_active = false,
		__slashesoffury_active = false,
		__slashesoffury_count = 0,
		__infinity_active = false,
		__deathslash_active = false,
		__auto_spam_distance_multiplier = 1.0,
		__walkspeed = 16,
		__jumppower = 50,
		__modify_player = false,
		__CameraEnabled = false,
		__CameraFOV = 70,
		__immortality_enabled = false,
		__immortality_speed_bypass = true,
		__immortality_angle = 72,
		__immortality_height = 15,
		__immortality_depth = -8,
		__immortality_radius = 10,
		__immortality_desync_types = {},
		__auto_ability_enabled = false,
		__ability_esp_enabled = false
	},
	__config = {
		__curve_names = {
			'Camera',
			'Random',
			'Accelerated',
			'Backwards',
			'Slow',
			'High',
			'RandomTarget',
			'Left',
			'Right'
		},
		__detections = {
			__timehole = false,
			__slashesoffury = false,
			__phantom = false,
			__infinity = false,
			__deathslash = false
		}
	},
	__triggerbot = {
		__enabled = false,
		__is_parrying = false,
		__parries = 0,
		__max_parries = 10000,
		__parry_delay = 0.15
	}
}

getgenv()._ZX_VelHistory = getgenv()._ZX_VelHistory or {
	ball = {},
	player = {},
	MAX_SAMPLES = 7
}
local _ZX_VelHistory = getgenv()._ZX_VelHistory

-- Environment Validation
if not game:IsLoaded() then
	game.Loaded:Wait()
end
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Alive = workspace:FindFirstChild("Alive") or workspace:WaitForChild("Alive", 10) or workspace
local Runtime = workspace:FindFirstChild("Runtime") or workspace:WaitForChild("Runtime", 10)

local originalClockTime
local originalGlobalShadows
local originalEffectStates = {}
local originalBloomProps = {}
local createdBloom = nil
local initialized = false
local disabledAtmispheres = {}
local timeConnection = nil 
local descendantConnection = nil
local originalPartShadows = setmetatable({}, {__mode = "k"})

-- ============================================================================
-- INTEGRATED DYNAMIC GC TOKENIZATION & METATABLE PROXY SUBSYSTEM
-- ============================================================================
local _token = nil

task.spawn(function()
	for _, Function in ipairs(getgc(true)) do
		if type(Function) == 'function' and debug.info(Function, 's'):find('PRY', 1, true) then
			for _, value in ipairs(debug.getupvalues(Function)) do
				if type(value) == 'function' then
					_token = value
					break
				end
			end
			if _token then break end
		end
	end
end)

local function _tokenize(_remote_uid)
	if not _token then return nil end
	local time_str = tostring(math.floor(workspace:GetServerTimeNow() * 100))
	local key = _token(_remote_uid, 'TIME')
	if not key then return nil end
	local characters = table.create(#time_str)

	for index = 1, #time_str do
		characters[index] = string.char(bit32.bxor(
			(string.byte(time_str, index) + index) % 256,
			string.byte(key, (index - 1) % #key + 1)
		))
	end

	return table.concat(characters)
end

local _reverted = setmetatable({}, { __mode = "k" })
local _original = {}
local _captured = nil

local function _is_valid(args)
	return #args == 8 
		and type(args[2]) == "string" 
		and type(args[3]) == "string" 
		and type(args[4]) == "number" 
		and typeof(args[5]) == "CFrame" 
		and type(args[6]) == "table" 
		and type(args[7]) == "table" 
		and type(args[8]) == "boolean"
end

local function _hook(remote)
	if not _reverted[remote] then
		local meta = getrawmetatable(remote)
		if meta and not _original[meta] then
			_original[meta] = true
			setreadonly(meta, false)

			local _old = meta.__index
			meta.__index = function(self, key)
				if (key == 'FireServer' and self:IsA('RemoteEvent')) or
				   (key == 'InvokeServer' and self:IsA('RemoteFunction')) then
					return function(_, ...)
						local _arguments = {...}
						if _is_valid(_arguments) then
							if not _reverted[self] then
								_reverted[self] = _arguments
								_captured = {
									remote = self,
									args = _arguments
								}
							end
						end
						return _old(self, key)(_, unpack(_arguments))
					end
				end
				return _old(self, key)
			end
			setreadonly(meta, true)
		end
	end
end

for _, _remote in ipairs(ReplicatedStorage:GetDescendants()) do
	if _remote:IsA('RemoteEvent') or _remote:IsA('RemoteFunction') then
		_hook(_remote)
	end
end

ReplicatedStorage.DescendantAdded:Connect(function(_remote)
	if _remote:IsA('RemoteEvent') or _remote:IsA('RemoteFunction') then
		_hook(_remote)
	end
end)

-- Legacy Compatibility Binding Wrapper
Stellar.ZX_Parry = { Hooked = true }

-- ============================================================================
-- INTEGRATED FLOATING TOGGLE SWITCH SUBSYSTEM
-- ============================================================================
local FloatingSwitchSystem = {
	ScreenGui = nil,
	Root = nil,
	IsOn = false,
	Connections = {},
	Config = {
		Title = "MANUAL SPAM",
		Keybind = Enum.KeyCode.V,
		StartPosition = UDim2.new(1, -190, 1, -168),
		ColorOff = Color3.fromRGB(40, 40, 46),
		ColorOn = Color3.fromRGB(48, 224, 158),
		KnobColor = Color3.fromRGB(248, 248, 252)
	}
}

local function buildFloatingToggleSwitch()
	if CoreGui:FindFirstChild("StellarFloatingToggle") then
		CoreGui.StellarFloatingToggle:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StellarFloatingToggle"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false
	screenGui.Parent = CoreGui
	FloatingSwitchSystem.ScreenGui = screenGui

	local root = Instance.new("CanvasGroup")
	root.Name = "Root"
	root.Size = UDim2.fromOffset(168, 114)
	root.Position = FloatingSwitchSystem.Config.StartPosition
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.Parent = screenGui
	FloatingSwitchSystem.Root = root

	local rootScale = Instance.new("UIScale")
	rootScale.Scale = 0.75
	rootScale.Parent = root

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
	shadow.Size = UDim2.fromOffset(154, 100)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.5
	shadow.BorderSizePixel = 0
	shadow.ZIndex = 0
	shadow.Parent = root
	local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0, 18) sc.Parent = shadow

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.Size = UDim2.fromOffset(150, 96)
	card.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
	card.BackgroundTransparency = 0.05
	card.BorderSizePixel = 0
	card.ZIndex = 1
	card.Parent = root

	local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 16) cc.Parent = card
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = Color3.fromRGB(255, 255, 255)
	cardStroke.Transparency = 0.91
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local cardGradient = Instance.new("UIGradient")
	cardGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
	})
	cardGradient.Rotation = 60
	cardGradient.Parent = card

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -16, 0, 16)
	title.Position = UDim2.new(0, 8, 0, 8)
	title.Font = Enum.Font.GothamBold
	title.Text = FloatingSwitchSystem.Config.Title
	title.TextSize = 12
	title.TextColor3 = Color3.fromRGB(195, 195, 205)
	title.TextTransparency = 0.1
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextScaled = true
	title.ZIndex = 2
	title.Parent = card

	local titleConstraint = Instance.new("UITextSizeConstraint")
	titleConstraint.MaxTextSize = 12 titleConstraint.MinTextSize = 8
	titleConstraint.Parent = title

	local glowOuter = Instance.new("Frame")
	glowOuter.Name = "GlowOuter"
	glowOuter.AnchorPoint = Vector2.new(0.5, 0.5)
	glowOuter.Position = UDim2.new(0.5, 0, 0, 46)
	glowOuter.Size = UDim2.fromOffset(104, 64)
	glowOuter.BackgroundColor3 = FloatingSwitchSystem.Config.ColorOn
	glowOuter.BackgroundTransparency = 1
	glowOuter.BorderSizePixel = 0
	glowOuter.ZIndex = 1
	glowOuter.Parent = card
	local goc = Instance.new("UICorner") goc.CornerRadius = UDim.new(1, 0) goc.Parent = glowOuter

	local glowInner = Instance.new("Frame")
	glowInner.Name = "GlowInner"
	glowInner.AnchorPoint = Vector2.new(0.5, 0.5)
	glowInner.Position = UDim2.new(0.5, 0, 0, 46)
	glowInner.Size = UDim2.fromOffset(84, 48)
	glowInner.BackgroundColor3 = FloatingSwitchSystem.Config.ColorOn
	glowInner.BackgroundTransparency = 1
	glowInner.BorderSizePixel = 0
	glowInner.ZIndex = 1
	glowInner.Parent = card
	local gic = Instance.new("UICorner") gic.CornerRadius = UDim.new(1, 0) gic.Parent = glowInner

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Active = true
	track.AnchorPoint = Vector2.new(0.5, 0.5)
	track.Position = UDim2.new(0.5, 0, 0, 46)
	track.Size = UDim2.fromOffset(72, 34)
	track.BackgroundColor3 = FloatingSwitchSystem.Config.ColorOff
	track.BorderSizePixel = 0
	track.ZIndex = 2
	track.Parent = card
	local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1, 0) tc.Parent = track

	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = Color3.fromRGB(64, 64, 72)
	trackStroke.Thickness = 1.5
	trackStroke.Transparency = 0.2
	trackStroke.Parent = track

	local trackGradient = Instance.new("UIGradient")
	trackGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	trackGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.94),
		NumberSequenceKeypoint.new(1, 1)
	})
	trackGradient.Rotation = 90
	trackGradient.Parent = track

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = UDim2.new(0, 3, 0.5, 0)
	knob.Size = UDim2.fromOffset(28, 28)
	knob.BackgroundColor3 = FloatingSwitchSystem.Config.KnobColor
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Parent = track
	local kc = Instance.new("UICorner") kc.CornerRadius = UDim.new(1, 0) kc.Parent = knob

	local knobStroke = Instance.new("UIStroke")
	knobStroke.Color = Color3.fromRGB(224, 224, 230)
	knobStroke.Thickness = 1
	knobStroke.Transparency = 0.5
	knobStroke.Parent = knob

	local statusRow = Instance.new("Frame")
	statusRow.Name = "StatusRow"
	statusRow.AnchorPoint = Vector2.new(0.5, 0)
	statusRow.Position = UDim2.new(0.5, 0, 0, 70)
	statusRow.Size = UDim2.new(1, -16, 0, 20)
	statusRow.BackgroundTransparency = 1
	statusRow.ZIndex = 2
	statusRow.Parent = card

	local statusLayout = Instance.new("UIListLayout")
	statusLayout.FillDirection = Enum.FillDirection.Horizontal
	statusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	statusLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	statusLayout.Padding = UDim.new(0, 6)
	statusLayout.SortOrder = Enum.SortOrder.LayoutOrder
	statusLayout.Parent = statusRow

	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.Size = UDim2.fromOffset(8, 8)
	dot.BackgroundColor3 = FloatingSwitchSystem.Config.ColorOff
	dot.BorderSizePixel = 0
	dot.LayoutOrder = 1
	dot.ZIndex = 2
	dot.Parent = statusRow
	local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1, 0) dc.Parent = dot

	local statusText = Instance.new("TextLabel")
	statusText.Name = "StatusText"
	statusText.BackgroundTransparency = 1
	statusText.Size = UDim2.fromOffset(28, 16)
	statusText.Font = Enum.Font.GothamBold
	statusText.Text = "OFF"
	statusText.TextSize = 12
	statusText.TextColor3 = Color3.fromRGB(150, 150, 160)
	statusText.TextXAlignment = Enum.TextXAlignment.Left
	statusText.LayoutOrder = 2
	statusText.ZIndex = 2
	statusText.Parent = statusRow

	local keyTag = Instance.new("TextLabel")
	keyTag.Name = "KeyTag"
	keyTag.AutomaticSize = Enum.AutomaticSize.X
	keyTag.Size = UDim2.fromOffset(0, 18)
	keyTag.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	keyTag.Font = Enum.Font.GothamBold
	keyTag.Text = FloatingSwitchSystem.Config.Keybind.Name
	keyTag.TextSize = 11
	keyTag.TextColor3 = Color3.fromRGB(205, 205, 215)
	keyTag.LayoutOrder = 3
	keyTag.ZIndex = 2
	keyTag.Parent = statusRow
	local ktc = Instance.new("UICorner") ktc.CornerRadius = UDim.new(0, 5) ktc.Parent = keyTag
	local ktStroke = Instance.new("UIStroke") ktStroke.Color = Color3.fromRGB(68, 68, 76) ktStroke.Thickness = 1 ktStroke.Parent = keyTag
	local ktPad = Instance.new("UIPadding") ktPad.PaddingLeft = UDim.new(0, 7) ktPad.PaddingRight = UDim.new(0, 7) ktPad.Parent = keyTag

	local function applyVisualState(on, animated)
		local quick = TweenInfo.new(animated and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local knobTween = TweenInfo.new(animated and 0.28 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local knobPos = on and UDim2.new(1, -31, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)

		TweenService:Create(track, quick, { BackgroundColor3 = on and FloatingSwitchSystem.Config.ColorOn or FloatingSwitchSystem.Config.ColorOff }):Play()
		TweenService:Create(trackStroke, quick, { Color = on and FloatingSwitchSystem.Config.ColorOn or Color3.fromRGB(64, 64, 72) }):Play()
		TweenService:Create(knob, knobTween, { Position = knobPos }):Play()
		TweenService:Create(dot, quick, { BackgroundColor3 = on and FloatingSwitchSystem.Config.ColorOn or Color3.fromRGB(90, 90, 98) }):Play()
		TweenService:Create(statusText, quick, { TextColor3 = on and FloatingSwitchSystem.Config.ColorOn or Color3.fromRGB(150, 150, 160) }):Play()
		TweenService:Create(glowOuter, quick, { BackgroundTransparency = on and 0.82 or 1 }):Play()
		TweenService:Create(glowInner, quick, { BackgroundTransparency = on and 0.7 or 1 }):Play()
		statusText.Text = on and "ON" or "OFF"
	end

	local function toggleState()
		FloatingSwitchSystem.IsOn = not FloatingSwitchSystem.IsOn
		applyVisualState(FloatingSwitchSystem.IsOn, true)
		Stellar.__properties.__gui_spam_active = FloatingSwitchSystem.IsOn
		Stellar.__properties.__manual_spam_enabled = FloatingSwitchSystem.IsOn
		if FloatingSwitchSystem.IsOn then
			if Stellar.manual_spam and typeof(Stellar.manual_spam.start) == "function" then Stellar.manual_spam.start() end
		else
			if Stellar.manual_spam and typeof(Stellar.manual_spam.stop) == "function" then Stellar.manual_spam.stop() end
		end
	end

	applyVisualState(FloatingSwitchSystem.IsOn, false)

	local dragging, moved = false, false
	local dragStart, startPos = Vector2.zero, Vector2.zero
	local DRAG_TOLERANCE = 4

	table.insert(FloatingSwitchSystem.Connections, track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true moved = false
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = root.AbsolutePosition
			TweenService:Create(track, TweenInfo.new(0.12), { Size = UDim2.fromOffset(76, 36) }):Play()
		end
	end))

	table.insert(FloatingSwitchSystem.Connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local point = Vector2.new(input.Position.X, input.Position.Y)
			local delta = point - dragStart
			if delta.Magnitude > DRAG_TOLERANCE then moved = true end
			local camera = workspace.CurrentCamera
			local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
			local size = root.AbsoluteSize
			local x = math.clamp(startPos.X + delta.X, 0, math.max(viewport.X - size.X, 0))
			local y = math.clamp(startPos.Y + delta.Y, 0, math.max(viewport.Y - size.Y, 0))
			root.Position = UDim2.fromOffset(x, y)
		end
	end))

	table.insert(FloatingSwitchSystem.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				TweenService:Create(track, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(72, 34) }):Play()
				if not moved then toggleState() end
			end
		end
	end))

	table.insert(FloatingSwitchSystem.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == FloatingSwitchSystem.Config.Keybind then
			toggleState()
			local resting = keyTag.BackgroundColor3
			TweenService:Create(keyTag, TweenInfo.new(0.06), { BackgroundColor3 = FloatingSwitchSystem.Config.ColorOn }):Play()
			task.delay(0.15, function()
				TweenService:Create(keyTag, TweenInfo.new(0.25), { BackgroundColor3 = resting }):Play()
			end)
		end
	end))

	TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
	TweenService:Create(rootScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

buildFloatingToggleSwitch()

-- ============================================================================
-- INTEGRATED PERFORMANCE MONITOR SUBSYSTEM
-- ============================================================================
local PerfMonitorSystem = {
	ScreenGui = nil,
	Card = nil,
	Connections = {},
	Config = {
		FPS_GOOD = 50, FPS_OK = 30,
		PING_GOOD = 80, PING_OK = 140,
		UPDATE_RATE = 0.15,
		SMOOTHING = 0.25,
		GRAPH_SAMPLES = 36,
		CARD_WIDTH = 214,
		EXPANDED_HEIGHT = 140,
		COLLAPSED_HEIGHT = 46,
		START_POSITION = UDim2.new(0, 20, 0, 20)
	},
	Colors = {
		bg = Color3.fromRGB(19, 19, 26),
		textDim = Color3.fromRGB(150, 152, 172),
		textBright = Color3.fromRGB(238, 239, 246),
		good = Color3.fromRGB(88, 234, 150),
		ok = Color3.fromRGB(255, 196, 84),
		bad = Color3.fromRGB(255, 99, 99)
	}
}

local function buildPerformanceMonitor()
	if CoreGui:FindFirstChild("StellarPerformanceMonitor") then
		CoreGui.StellarPerformanceMonitor:Destroy()
	end

	local function createInst(className, props, children)
		local inst = Instance.new(className)
		for prop, val in pairs(props or {}) do inst[prop] = val end
		for _, child in ipairs(children or {}) do child.Parent = inst end
		return inst
	end

	local function corner(radius)
		return createInst("UICorner", { CornerRadius = UDim.new(0, radius) })
	end

	local statusDot = createInst("Frame", {
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = PerfMonitorSystem.Colors.good,
		BorderSizePixel = 0
	}, { corner(4) })

	local titleLabel = createInst("TextLabel", {
		Text = "PERFORMANCE",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = PerfMonitorSystem.Colors.textDim,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(1, -16, 1, 0)
	})

	local dragHandle = createInst("Frame", {
		Name = "DragHandle",
		BackgroundTransparency = 1,
		Active = true,
		Size = UDim2.new(1, -30, 1, 0)
	}, { statusDot, titleLabel })

	local toggleButton = createInst("TextButton", {
		Name = "Toggle",
		Text = "-",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = PerfMonitorSystem.Colors.textDim,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.93,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22)
	}, { corner(7) })

	local header = createInst("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		LayoutOrder = 1
	}, { dragHandle, toggleButton })

	local fpsValue = createInst("TextLabel", {
		Name = "FPSValue",
		Text = "--",
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		TextColor3 = PerfMonitorSystem.Colors.textBright,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(1, 0, 0, 30)
	})

	local fpsBlock = createInst("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 82, 1, 0)
	}, {
		createInst("TextLabel", {
			Text = "FPS", Font = Enum.Font.GothamMedium, TextSize = 11,
			TextColor3 = PerfMonitorSystem.Colors.textDim, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16)
		}),
		fpsValue
	})

	local divider = createInst("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 90, 0.5, 0),
		Size = UDim2.new(0, 1, 0, 34)
	})

	local pingValue = createInst("TextLabel", {
		Name = "PingValue",
		Text = "--",
		RichText = true,
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		TextColor3 = PerfMonitorSystem.Colors.textBright,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(1, 0, 0, 30)
	})

	local pingBlock = createInst("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 100, 0, 0),
		Size = UDim2.new(0, 82, 1, 0)
	}, {
		createInst("TextLabel", {
			Text = "PING", Font = Enum.Font.GothamMedium, TextSize = 11,
			TextColor3 = PerfMonitorSystem.Colors.textDim, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16)
		}),
		pingValue
	})

	local statsFrame = createInst("Frame", {
		Name = "Stats",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		LayoutOrder = 2
	}, { fpsBlock, divider, pingBlock })

	local BAR_WIDTH, BAR_GAP = 3, 2
	local bars = {}
	local graph = createInst("Frame", {
		Name = "Graph",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 3
	})

	for i = 1, PerfMonitorSystem.Config.GRAPH_SAMPLES do
		local bar = createInst("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, (i - 1) * (BAR_WIDTH + BAR_GAP), 1, 0),
			Size = UDim2.new(0, BAR_WIDTH, 0, 2),
			BackgroundColor3 = PerfMonitorSystem.Colors.good,
			BorderSizePixel = 0
		}, { corner(1) })
		bar.Parent = graph
		bars[i] = bar
	end

	local cardStroke = createInst("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.87,
		Thickness = 1
	})

	local card = createInst("Frame", {
		Name = "Card",
		BackgroundColor3 = PerfMonitorSystem.Colors.bg,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = PerfMonitorSystem.Config.START_POSITION,
		Size = UDim2.new(0, PerfMonitorSystem.Config.CARD_WIDTH, 0, PerfMonitorSystem.Config.EXPANDED_HEIGHT)
	}, {
		corner(14),
		cardStroke,
		createInst("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.93),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		createInst("UIPadding", {
			PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)
		}),
		createInst("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		header, statsFrame, graph
	})

	local screenGui = createInst("ScreenGui", {
		Name = "StellarPerformanceMonitor",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		DisplayOrder = 999
	}, { card })
	screenGui.Parent = CoreGui
	PerfMonitorSystem.ScreenGui = screenGui
	PerfMonitorSystem.Card = card

	local expanded = true
	table.insert(PerfMonitorSystem.Connections, toggleButton.MouseButton1Click:Connect(function()
		expanded = not expanded
		toggleButton.Text = expanded and "-" or "+"
		TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, PerfMonitorSystem.Config.CARD_WIDTH, 0, expanded and PerfMonitorSystem.Config.EXPANDED_HEIGHT or PerfMonitorSystem.Config.COLLAPSED_HEIGHT)
		}):Play()
	end))

	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	table.insert(PerfMonitorSystem.Connections, dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true dragStart = input.Position startPos = card.Position
			TweenService:Create(cardStroke, TweenInfo.new(0.15), { Transparency = 0.5 }):Play()
		end
	end))

	table.insert(PerfMonitorSystem.Connections, dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	table.insert(PerfMonitorSystem.Connections, UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local viewport = workspace.CurrentCamera.ViewportSize
			local size = card.AbsoluteSize
			local newX = math.clamp(startPos.X.Offset + delta.X, 0, math.max(0, viewport.X - size.X))
			local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - size.Y))
			card.Position = UDim2.new(0, newX, 0, newY)
		end
	end))

	table.insert(PerfMonitorSystem.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				TweenService:Create(cardStroke, TweenInfo.new(0.3), { Transparency = 0.87 }):Play()
			end
		end
	end))

	local frameTimes = {}
	table.insert(PerfMonitorSystem.Connections, RunService.RenderStepped:Connect(function(dt)
		table.insert(frameTimes, dt)
		if #frameTimes > 30 then table.remove(frameTimes, 1) end
	end))

	local function getFPS()
		if #frameTimes == 0 then return 0 end
		local sum = 0 for _, dt in ipairs(frameTimes) do sum = sum + dt end
		local avg = sum / #frameTimes
		return avg > 0 and (1 / avg) or 0
	end

	local function getPing()
		local ok, val = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		return ok and val or 0
	end

	local function fpsColor(fps)
		if fps >= PerfMonitorSystem.Config.FPS_GOOD then return PerfMonitorSystem.Colors.good
		elseif fps >= PerfMonitorSystem.Config.FPS_OK then return PerfMonitorSystem.Colors.ok
		else return PerfMonitorSystem.Colors.bad end
	end

	local function pingColor(ping)
		if ping <= PerfMonitorSystem.Config.PING_GOOD then return PerfMonitorSystem.Colors.good
		elseif ping <= PerfMonitorSystem.Config.PING_OK then return PerfMonitorSystem.Colors.ok
		else return PerfMonitorSystem.Colors.bad end
	end

	local displayFps, displayPing = 0, 0
	local history = table.create(PerfMonitorSystem.Config.GRAPH_SAMPLES, 0)

	task.spawn(function()
		while card and card.Parent do
			local targetFps = getFPS()
			local targetPing = getPing()
			
			Stellar.__properties.__cached_fps = targetFps
			Stellar.__properties.__cached_ping = targetPing

			displayFps = displayFps + (targetFps - displayFps) * PerfMonitorSystem.Config.SMOOTHING
			displayPing = displayPing + (targetPing - displayPing) * PerfMonitorSystem.Config.SMOOTHING

			local roundedFps = math.floor(displayFps + 0.5)
			local roundedPing = math.floor(displayPing + 0.5)

			fpsValue.Text = tostring(roundedFps)
			pingValue.Text = string.format('%d<font size="14" transparency="0.4"> ms</font>', roundedPing)

			local fColor = fpsColor(roundedFps)
			local pColor = pingColor(roundedPing)

			TweenService:Create(fpsValue, TweenInfo.new(PerfMonitorSystem.Config.UPDATE_RATE), { TextColor3 = fColor }):Play()
			TweenService:Create(pingValue, TweenInfo.new(PerfMonitorSystem.Config.UPDATE_RATE), { TextColor3 = pColor }):Play()

			local overall = (fColor == PerfMonitorSystem.Colors.bad or pColor == PerfMonitorSystem.Colors.bad) and PerfMonitorSystem.Colors.bad
				or (fColor == PerfMonitorSystem.Colors.ok or pColor == PerfMonitorSystem.Colors.ok) and PerfMonitorSystem.Colors.ok
				or PerfMonitorSystem.Colors.good
			TweenService:Create(statusDot, TweenInfo.new(PerfMonitorSystem.Config.UPDATE_RATE), { BackgroundColor3 = overall }):Play()

			table.insert(history, roundedFps)
			table.remove(history, 1)

			local maxVal = 30
			for _, v in ipairs(history) do if v > maxVal then maxVal = v end end

			for i, bar in ipairs(bars) do
				local v = history[i] or 0
				bar.Size = UDim2.new(0, BAR_WIDTH, 0, math.clamp((v / maxVal) * 24, 2, 24))
				bar.BackgroundColor3 = fpsColor(v)
			end
			task.wait(PerfMonitorSystem.Config.UPDATE_RATE)
		end
	end)
end

buildPerformanceMonitor()

-- Ability ESP Subsystem
local billboardLabels = {}
local function createBillboardGui(p)
	task.spawn(function()
		local character = p.Character
		while not character or not character.Parent do
			task.wait()
			character = p.Character
		end
		local head = character:WaitForChild("Head", 10)
		if not head then return end
		local bg = Instance.new("BillboardGui")
		bg.Name = "AbilityESP_Gui"
		bg.Adornee = head
		bg.Size = UDim2.new(0, 220, 0, 60)
		bg.StudsOffset = Vector3.new(0, 3.5, 0)
		bg.AlwaysOnTop = true
		bg.Parent = head
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.new(1, 0, 1, 0)
		tl.TextColor3 = Color3.new(1, 1, 1)
		tl.TextSize = 14
		tl.TextStrokeTransparency = 0
		tl.Font = Enum.Font.GothamBold
		tl.BackgroundTransparency = 1
		tl.Parent = bg
		tl.Visible = false
		billboardLabels[p] = tl
		local hum = character:FindFirstChild("Humanoid")
		if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not (character and character.Parent) then
				conn:Disconnect()
				pcall(function() bg:Destroy() end)
				billboardLabels[p] = nil
				return
			end
			tl.Visible = Stellar.__properties.__ability_esp_enabled
			if Stellar.__properties.__ability_esp_enabled then
				local ab = p:GetAttribute("EquippedAbility")
				tl.Text = ab and (p.DisplayName .. " [" .. ab .. "]") or p.DisplayName
			end
		end)
	end)
end
for _, p in pairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		p.CharacterAdded:Connect(function() createBillboardGui(p) end)
		if p.Character then createBillboardGui(p) end
	end
end
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function() createBillboardGui(p) end)
end)

-- Immortality Orbital Desync Module
local function getSafeCharacterComponents()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if hrp and head then return char, hrp, head end
    return nil, nil, nil
end

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if Stellar.__properties.__immortality_enabled and not checkcaller() then
        if key == "CFrame" then
            local char, hrp, head = getSafeCharacterComponents()
            if char and hrp and head then
                local cache = Stellar.__properties.__immortality_desync_types
                if cache and cache[1] then
                    if self == hrp then
                        return cache[1]
                    elseif self == head then
                        local yOffset = (hrp.Size.Y * 0.5) + 0.5
                        return cache[1] + Vector3.new(0, yOffset, 0)
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end))

if Stellar.__properties.__connections.__immortality then
    Stellar.__properties.__connections.__immortality:Disconnect()
    Stellar.__properties.__connections.__immortality = nil
end

Stellar.__properties.__connections.__immortality = RunService.Heartbeat:Connect(function()
    if not Stellar.__properties.__immortality_enabled then return end
    local char, hrp, _ = getSafeCharacterComponents()
    if not hrp then return end
    if Stellar.__properties.__immortality_speed_bypass and setfflag then
        pcall(setfflag, "S2PhysicsSenderRate", "1333335")
    end
    local realCFrame = hrp.CFrame + Vector3.new(0, 0.01, 0)
    local realVelocity = hrp.AssemblyLinearVelocity
    local cache = Stellar.__properties.__immortality_desync_types
    cache[1] = realCFrame
    cache[2] = realVelocity
    local currentTime = tick()
    local angle = Stellar.__properties.__immortality_angle or 72
    local height = Stellar.__properties.__immortality_height or 15
    local depth = Stellar.__properties.__immortality_depth or -8
    local radius = Stellar.__properties.__immortality_radius or 10

    local calculatedAngle = currentTime * math.pi * 2 * angle / 5
    local calculatedCycle = math.floor(currentTime * 29) % 2
    local calculatedYOffset = (calculatedCycle == 0) and depth or height
    local calculatedOffset = Vector3.new(math.cos(calculatedAngle) * radius, calculatedYOffset, math.sin(calculatedAngle) * radius)
    local targetCFrame = cache[1] + calculatedOffset

    hrp.CFrame = targetCFrame
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    task.spawn(function()
        RunService.RenderStepped:Wait()
        if hrp and hrp.Parent then
            hrp.CFrame = cache[1] or realCFrame
            hrp.AssemblyLinearVelocity = cache[2] or realVelocity
        end
    end)
end)

task.spawn(function()
	while true do
		if _captured and _captured.remote then
			Library.SendNotification({
				title = "Stellar Engine",
				text = " Remotes Captured: " .. _captured.remote.Name,
				duration = 3
			})
			break -- Stops checking once captured and notified
		end
		task.wait(0.5)
	end
end)

-- Dynamic Accuracy & Ping Scaling
local function update_divisor()
	local reversed_accuracy = 101 - Stellar.__properties.__accuracy
	Stellar.__properties.__divisor_multiplier = 0.7 + (reversed_accuracy - 1) * 0.0035353535353535
end

local function update_randomized_accuracy()
	if not Stellar.__properties.__randomized_accuracy_enabled then return end
	local ping_str = Stats.Network.ServerStatsItem:GetValueString()
	local ping = tonumber(ping_str:match("%d+")) or 0
	local new_accuracy = (ping >= 90) and 4 or ((ping <= 50) and math.random(70, 100) or Stellar.__properties.__accuracy)
	Stellar.__properties.__accuracy = new_accuracy
	update_divisor()
end

task.spawn(function()
	while task.wait(1) do
		if Stellar.__properties.__randomized_accuracy_enabled then
			pcall(update_randomized_accuracy)
		end
	end
end)

-- Player Movement Modifiers
Stellar.playermod = {}
function Stellar.playermod.update()
	if not Stellar.__properties.__modify_player then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Stellar.__properties.__walkspeed
		hum.JumpPower = Stellar.__properties.__jumppower
	end
end
Stellar.__properties.__connections.__playermod = RunService.Heartbeat:Connect(Stellar.playermod.update)

-- Ability Remote Listener Pipeline
task.spawn(function()
	local netFolder = nil
	local indexFolder = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index")
	if indexFolder then
		for _, child in ipairs(indexFolder:GetChildren()) do
			if string.match(child.Name, "sleitnick_net") then
				netFolder = child:FindFirstChild("net")
				if netFolder then break end
			end
		end
	end
	
	if netFolder then
		Stellar.__properties.__connections.__detections_list = {}
		if netFolder:FindFirstChild("RE/TimeHoleActivate") then
			table.insert(Stellar.__properties.__connections.__detections_list, netFolder["RE/TimeHoleActivate"].OnClientEvent:Connect(function(...)
				if not Stellar.__config.__detections.__timehole then return end
				local args = { ... }
				local player = args[1]
				if player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name) then
					Stellar.__properties.__timehole_active = true
				end
			end))
		end
		if netFolder:FindFirstChild("RE/TimeHoleDeactivate") then
			table.insert(Stellar.__properties.__connections.__detections_list, netFolder["RE/TimeHoleDeactivate"].OnClientEvent:Connect(function()
				Stellar.__properties.__timehole_active = false
			end))
		end
		
		local maxParryCount = 35
		local parryDelay = 0.05
		if netFolder:FindFirstChild("RE/SlashesOfFuryActivate") then
			table.insert(Stellar.__properties.__connections.__detections_list, netFolder["RE/SlashesOfFuryActivate"].OnClientEvent:Connect(function(...)
				if not Stellar.__config.__detections.__slashesoffury then return end
				local args = { ... }
				local player = args[1]
				if player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name) then
					Stellar.__properties.__slashesoffury_active = true
					Stellar.__properties.__slashesoffury_count = 0
				end
			end))
		end
		if netFolder:FindFirstChild("RE/SlashesOfFuryEnd") then
			table.insert(Stellar.__properties.__connections.__detections_list, netFolder["RE/SlashesOfFuryEnd"].OnClientEvent:Connect(function()
				Stellar.__properties.__slashesoffury_active = false
				Stellar.__properties.__slashesoffury_count = 0
			end))
		end
		if netFolder:FindFirstChild("RE/SlashesOfFuryParry") then
			table.insert(Stellar.__properties.__connections.__detections_list, netFolder["RE/SlashesOfFuryParry"].OnClientEvent:Connect(function()
				if not Stellar.__config.__detections.__slashesoffury then return end
				Stellar.__properties.__slashesoffury_count = Stellar.__properties.__slashesoffury_count + 1
			end))
		end
		if netFolder:FindFirstChild("RE/SlashesOfFuryCatch") then
			table.insert(Stellar.__properties.__connections.__detections_list, netFolder["RE/SlashesOfFuryCatch"].OnClientEvent:Connect(function()
				task.spawn(function()
					while Stellar.__properties.__slashesoffury_active and Stellar.__properties.__slashesoffury_count < maxParryCount do
						if Stellar.__config.__detections.__slashesoffury then
							if tick() - (Stellar.__properties.__last_global_parry or 0) >= parryDelay then
								Stellar.__properties.__last_global_parry = tick()
								Stellar.parry.execute()
							end
							task.wait(parryDelay)
						else
							break
						end
					end
				end)
			end))
		end
	end

	pcall(function()
		local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
		if remotes then
			if remotes:FindFirstChild("DeathBall") then
				remotes.DeathBall.OnClientEvent:Connect(function(c, d)
					if Stellar.__config.__detections.__deathslash then
						Stellar.__properties.__deathslash_active = d or false
					end
				end)
			end
			if remotes:FindFirstChild("InfinityBall") then
				remotes.InfinityBall.OnClientEvent:Connect(function(a, b)
					if Stellar.__config.__detections.__infinity then
						Stellar.__properties.__infinity_active = b or false
					end
				end)
			end
		end
	end)
end)

-- Anti-Phantom Execution Routine
if Runtime then
	Stellar.__properties.__connections.__phantom = Runtime.ChildAdded:Connect(function(Object)
		if Stellar.__config.__detections.__phantom then
			if Object.Name == "maxTransmission" or Object.Name == "transmissionpart" then
				local Weld = Object:FindFirstChildWhichIsA("WeldConstraint")
				if Weld then
					local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
					if Character and Weld.Part1 == Character:FindFirstChild("HumanoidRootPart") then
						local CurrentBall = Stellar.ball.get()
						Weld:Destroy()
						if CurrentBall then
							local FocusConnection
							FocusConnection = RunService.RenderStepped:Connect(function()
								local Highlighted = CurrentBall:GetAttribute("highlighted")
								if Highlighted == true then
									if tick() - (Stellar.__properties.__last_global_parry or 0) >= 0.1 then
										Stellar.__properties.__last_global_parry = tick()
										Stellar.parry.execute()
									end
								elseif Highlighted == false then
									FocusConnection:Disconnect()
								end
							end)
							task.delay(3, function()
								if FocusConnection and FocusConnection.Connected then
									FocusConnection:Disconnect()
								end
							end)
						end
					end
				end
			end
		end
	end)
end

-- Sensor & Target Selection Modules
Stellar.ball = {}
function Stellar.ball.get()
	local balls = workspace:FindFirstChild('Balls')
	if not balls then return nil end
	for _, ball in pairs(balls:GetChildren()) do
		if ball:GetAttribute('realBall') then
			ball.CanCollide = false
			return ball
		end
	end
	return nil
end

function Stellar.ball.get_all()
	local balls_table = {}
	local balls = workspace:FindFirstChild('Balls')
	if balls then
		for _, ball in pairs(balls:GetChildren()) do
			if ball:GetAttribute('realBall') then
				ball.CanCollide = false
				table.insert(balls_table, ball)
			end
		end
	end
	return balls_table
end

Stellar.player = {}
local Closest_Entity = nil
local last_closest_check = 0
function Stellar.player.get_closest()
	local now = tick()
	if now - last_closest_check < 0.1 then return Closest_Entity end
	last_closest_check = now
	local max_distance = math.huge
	local closest_entity = nil
	if not Alive then return nil end
	for _, entity in pairs(Alive:GetChildren()) do
		if entity ~= LocalPlayer.Character and entity.PrimaryPart then
			local distance = LocalPlayer:DistanceFromCharacter(entity.PrimaryPart.Position)
			if distance < max_distance then
				max_distance = distance
				closest_entity = entity
			end
		end
	end
	Closest_Entity = closest_entity
	return closest_entity
end

function Stellar.player.get_closest_to_cursor()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then return nil end
	local closest_player, minimal_dot = nil, -math.huge
	local camera = workspace.CurrentCamera
	if not Alive then return nil end
	local success, mouse_location = pcall(function() return UserInputService:GetMouseLocation() end)
	if not success then return nil end
	local ray = camera:ScreenPointToRay(mouse_location.X, mouse_location.Y)
	local pointer = CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
	for _, player in pairs(Alive:GetChildren()) do
		if player == LocalPlayer.Character or not player:FindFirstChild('HumanoidRootPart') then continue end
		local direction = (player.HumanoidRootPart.Position - camera.CFrame.Position).Unit
		local dot = pointer.LookVector:Dot(direction)
		if dot > minimal_dot then
			minimal_dot = dot
			closest_player = player
		end
	end
	return closest_player
end

-- Curve Provider Module
Stellar.curve = {}
function Stellar.curve.get_cframe()
	local camera = workspace.CurrentCamera
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
	if not root then return camera.CFrame end
	local targetPart = nil
	local closest = Stellar.player.get_closest_to_cursor()
	if closest and closest:FindFirstChild('HumanoidRootPart') then
		targetPart = closest.HumanoidRootPart
	end
	local target_pos = targetPart and targetPart.Position or (root.Position + camera.CFrame.LookVector * 100)
	local curve_functions = {
		[1] = function() return camera.CFrame end,
		[2] = function()
			local direction, random_offset, attempts = (target_pos - root.Position).Unit, Vector3.new(), 0
			repeat
				random_offset = Vector3.new(math.random(-4000, 4000), math.random(-4000, 4000), math.random(-4000, 4000))
				attempts = attempts + 1
			until direction:Dot((target_pos + random_offset - root.Position).Unit) < 0.95 or attempts > 10
			return CFrame.new(root.Position, target_pos + random_offset)
		end,
		[3] = function() return CFrame.new(root.Position, target_pos + Vector3.new(0, 5, 0)) end,
		[4] = function() return CFrame.new(camera.CFrame.Position, root.Position + (root.Position - target_pos).Unit * 10000 + Vector3.new(0, 1000, 0)) end,
		[5] = function() return CFrame.new(root.Position, target_pos + Vector3.new(0, -9e18, 0)) end,
		[6] = function() return CFrame.new(root.Position, target_pos + Vector3.new(0, 9e18, 0)) end,
		[7] = function()
			local candidates = {}
			if Alive then
				for _, pl in pairs(Alive:GetChildren()) do
					if pl ~= LocalPlayer.Character and pl.PrimaryPart then
						table.insert(candidates, pl)
					end
				end
			end
			if #candidates > 0 then
				return CFrame.new(root.Position, candidates[math.random(1, #candidates)].PrimaryPart.Position)
			end
			return camera.CFrame
		end,
		[8] = function() return CFrame.new(root.Position, root.Position + (-camera.CFrame.RightVector * 10000)) end,
		[9] = function() return CFrame.new(root.Position, root.Position + (camera.CFrame.RightVector * 10000)) end
	}
	local selected_func = curve_functions[Stellar.__properties.__curve_mode] or curve_functions[1]
	return selected_func()
end

-- Universal Parry Execution Subsystem
local Cache_Update_Tick = 0
local Last_Positions_Cache = {}
local lastHitTick = 0

local function fireParry(precalc_cframe)
	local cam = workspace.CurrentCamera
	local pCF = precalc_cframe or Stellar.curve.get_cframe()

	if tick() - Cache_Update_Tick > 0.1 then
		table.clear(Last_Positions_Cache)
		if Alive and cam then
			for _, character in ipairs(Alive:GetChildren()) do
				local primary = character.PrimaryPart
				if primary and character.Name ~= LocalPlayer.Name then
					local ok, sp = pcall(cam.WorldToScreenPoint, cam, primary.Position)
					if ok then Last_Positions_Cache[character.Name] = sp end
				end
			end
		end
		Cache_Update_Tick = tick()
	end

	local vp = cam.ViewportSize
	local viewport_center = { vp.X / 2, vp.Y / 2 }

	-- Dispatch via Intercepted Metatable Cache
	if _captured and _captured.remote and _captured.args then
		local remote_uid = _captured.args[2]
		local token = _tokenize(remote_uid)
		if token then
			local packet = {
				_captured.args[1],
				remote_uid,
				token,
				0.5,
				pCF,
				Last_Positions_Cache,
				viewport_center,
				false
			}
			lastHitTick = tick()
			if _captured.remote:IsA("RemoteEvent") then
				_captured.remote:FireServer(unpack(packet))
			elseif _captured.remote:IsA("RemoteFunction") then
				_captured.remote:InvokeServer(unpack(packet))
			end
			return
		end
	end

	-- Secondary Fallback across All Intercepted Remotes
	for _remote, _arg_list in pairs(_reverted) do
		local remote_uid = _arg_list[2]
		local token = _tokenize(remote_uid)
		if token then
			local packet = {
				_arg_list[1],
				remote_uid,
				token,
				0.5,
				pCF,
				Last_Positions_Cache,
				viewport_center,
				false
			}
			lastHitTick = tick()
			if _remote:IsA("RemoteEvent") then
				_remote:FireServer(unpack(packet))
			elseif _remote:IsA("RemoteFunction") then
				_remote:InvokeServer(unpack(packet))
			end
			return
		end
	end
end


Stellar.parry = {}
function Stellar.parry.execute(precalc_cframe)
	if Stellar.__properties.__parries > 10000 or not LocalPlayer.Character then return end
	fireParry(precalc_cframe)
	Stellar.__properties.__parries = Stellar.__properties.__parries + 1
	task.delay(0.5, function() Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - 1) end)
end

function Stellar.parry.keypress(precalc_cframe)
	if Stellar.__properties.__parries > 10000 or not LocalPlayer.Character then return end
	fireParry(precalc_cframe)
	Stellar.__properties.__parries = Stellar.__properties.__parries + 1
	task.delay(0.5, function() Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - 1) end)
end

function Stellar.parry.execute_action(precalc_cframe)
	Stellar.animation.play_grab_parry()
	Stellar.parry.execute(precalc_cframe)
end

function Stellar.parry.execute_bruteforce(precalc_cframe)
	if Stellar.__properties.__parries > 10000 or not LocalPlayer.Character then return end
	fireParry(precalc_cframe)
	Stellar.__properties.__parries = Stellar.__properties.__parries + 1
	task.delay(0.5, function() Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - 1) end)
end

-- Animation Subsystem
Stellar.animation = {}
local SwordAPI = ReplicatedStorage:WaitForChild("Shared", 9e9):WaitForChild("SwordAPI", 9e9)
local last_anim_tick = 0
function Stellar.animation.play_grab_parry()
    if not Stellar.__properties.__play_animation then
        return
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local animator = humanoid and humanoid:FindFirstChildOfClass('Animator')
    if not humanoid or not animator then return end
    
    local sword_name
    if getgenv().skinChangerEnabled then
        sword_name = getgenv().swordAnimations
    else
        sword_name = character:GetAttribute('CurrentlyEquippedSword')
    end
    if not sword_name then return end
    
    local sword_api = ReplicatedStorage.Shared.SwordAPI.Collection
    local parry_animation = sword_api.Default:FindFirstChild('GrabParry')
    if not parry_animation then return end
    
    local sword_data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(sword_name)
    if not sword_data or not sword_data['AnimationType'] then return end
    
    for _, object in pairs(sword_api:GetChildren()) do
        if object.Name == sword_data['AnimationType'] then
            if object:FindFirstChild('GrabParry') or object:FindFirstChild('Grab') then
                local animation_type = object:FindFirstChild('GrabParry') and 'GrabParry' or 'Grab'
                parry_animation = object[animation_type]
            end
        end
    end
    
    if Stellar.__properties.__grab_animation and Stellar.__properties.__grab_animation.IsPlaying then
        Stellar.__properties.__grab_animation:Stop()
    end
    
    Stellar.__properties.__grab_animation = animator:LoadAnimation(parry_animation)
    Stellar.__properties.__grab_animation.Priority = Enum.AnimationPriority.Action4
    Stellar.__properties.__grab_animation:Play()
end

-- Fused Anti-Curve Physics Engine
Stellar.detection = {
	__ball_properties = {
		__lerp_radians = 0,
		__last_warping = tick(),
		__curving = tick()
	},
	__kinematic_properties = {}
}

function Stellar.detection.is_curved(ball)
	ball = ball or Stellar.ball.get()
	if not ball then return false end

	local zoomies = ball:FindFirstChild("zoomies")
	local velocity = zoomies and zoomies.VectorVelocity or ball.AssemblyLinearVelocity
	local speed = velocity.Magnitude
	if speed < 15 then return false end

	local char = LocalPlayer.Character
	local playerPart = char and char.PrimaryPart
	if not playerPart then return false end

	local ballPos = ball.Position
	local playerPos = playerPart.Position
	local toPlayerVec = playerPos - ballPos
	local distance = toPlayerVec.Magnitude

	if distance <= 3.5 then return false end

	local toPlayerDir = toPlayerVec / distance
	local velocityDir = velocity / speed
	local currentDot = toPlayerDir:Dot(velocityDir)

	if currentDot < -0.30 then
		return true
	end

	if not Stellar.detection.__kinematic_properties[ball] then
		local initial_history = {}
		for i = 1, 6 do initial_history[i] = { v = Vector3.new(), t = 0 } end
		Stellar.detection.__kinematic_properties[ball] = {
			history = initial_history,
			idx = 0,
			smooth_accel_vec = Vector3.new(),
			smooth_angular = 0,
			last_ping = 0.05,
			last_ping_tick = 0,
			last_ability_check = 0,
			ability_tick = 0
		}
	end

	local props = Stellar.detection.__kinematic_properties[ball]
	local now = os.clock()

	props.idx = (props.idx % 6) + 1
	props.history[props.idx].v = velocity
	props.history[props.idx].t = now

	local raw_accel_vec = Vector3.new()
	local raw_angular = 0
	local oldest_idx = (props.idx % 6) + 1
	local oldest = props.history[oldest_idx]

	if oldest.t > 0 then
		local time_span = now - oldest.t
		if time_span > 0.005 then
			local velocity_diff = velocity - oldest.v
			if velocity_diff.Magnitude > 2 then
				raw_accel_vec = velocity_diff / time_span
				local crossVec = (oldest.v / oldest.v.Magnitude):Cross(velocityDir)
				raw_angular = math.deg(math.asin(math.clamp(crossVec.Magnitude, -1, 1))) / time_span
			end
		end
	end

	props.smooth_accel_vec = props.smooth_accel_vec:Lerp(raw_accel_vec, 0.4)
	props.smooth_angular = props.smooth_angular + (raw_angular - props.smooth_angular) * 0.4

	local accelMagnitude = props.smooth_accel_vec.Magnitude
	local accelDir = accelMagnitude > 0 and (props.smooth_accel_vec / accelMagnitude) or Vector3.new()
	local accelDot = toPlayerDir:Dot(accelDir)

	local confidence = 0
	local adaptive_accel_thresh = math.max(speed * 0.25, 25)

	confidence = confidence + math.clamp((accelMagnitude / adaptive_accel_thresh) * 0.4, 0, 0.4)
	confidence = confidence + math.clamp((props.smooth_angular / 40) * 0.4, 0, 0.4)
	
	if math.abs(accelDot) > 0.15 then confidence = confidence + 0.2 end

	local reachTime = distance / speed
	local required_confidence = (distance < 35) and 0.50 or 0.58

	if confidence > required_confidence then
		local lookAheadTime = math.clamp(reachTime, 0.01, 0.15)
		local predictedPos = ballPos + (velocity * lookAheadTime) + (0.5 * props.smooth_accel_vec * lookAheadTime * lookAheadTime)
		local predictedDistance = (playerPos - predictedPos).Magnitude

		if predictedDistance < distance or distance <= 25 then
			if currentDot < 0.35 then
				return true
			end
		end
	end

	local clamped_dot = math.clamp(currentDot, -1, 1)
	local radians = math.asin(clamped_dot)
	local ballProps = Stellar.detection.__ball_properties
	ballProps.__lerp_radians = ballProps.__lerp_radians + (radians - ballProps.__lerp_radians) * 0.85

	if ballProps.__lerp_radians < 0.016 then
		ballProps.__last_warping = tick()
	end

	local sudden_curve = (tick() - ballProps.__last_warping) < (reachTime / 1.4)
	if sudden_curve and distance > 3.5 then
		return true
	end

	return false
end

if workspace:FindFirstChild('Balls') then
	workspace.Balls.ChildRemoved:Connect(function(child)
		Stellar.detection.__kinematic_properties[child] = nil
	end)
end

-- Primary Auto Parry Execution Engine
Stellar.autoparry = {}
local parryFlag = false
local isExecutingSlashes = false
local abilityDebounce = false

function Stellar.autoparry.start()
	if Stellar.__properties.__connections.__combat then Stellar.__properties.__connections.__combat:Disconnect() end
	parryFlag, isExecutingSlashes, abilityDebounce = false, false, false

	Stellar.__properties.__connections.__combat = RunService.PreSimulation:Connect(function(dt)
		if not Stellar.__properties.__autoparry_enabled or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
		
		local localName = LocalPlayer.Name
		local playerPos = LocalPlayer.Character.PrimaryPart.Position
		local cam = workspace.CurrentCamera
		
		if Stellar.__config.__detections.__infinity and Stellar.__properties.__infinity_active then return end
		if Stellar.__config.__detections.__deathslash and Stellar.__properties.__deathslash_active then return end
		if Stellar.__config.__detections.__timehole and Stellar.__properties.__timehole_active then return end
		if Stellar.__config.__detections.__slashesoffury and Stellar.__properties.__slashesoffury_active then return end

		-- Auto Ability Engine
		if getgenv().AutoAbility or (Stellar and Stellar.__properties and Stellar.__properties.__auto_ability_enabled) then
			local hotbar = LocalPlayer.PlayerGui:FindFirstChild("Hotbar")
			local abilityGui = hotbar and hotbar:FindFirstChild("Ability")
			local AbilityCD = abilityGui and abilityGui:FindFirstChild("UIGradient")
			local char = LocalPlayer.Character
			local abs = char and char:FindFirstChild("Abilities")
			if abs then
				local ball = Stellar.ball.get()
				if ball and ball.Parent then
					local currentTarget = ball:GetAttribute("target")
					local isTargeted = (currentTarget == localName)
					local distance = LocalPlayer:DistanceFromCharacter(ball.Position)
					local isAbilityReady = false
					pcall(function() isAbilityReady = AbilityCD and math.abs(AbilityCD.Offset.Y - 0.5) < 0.05 end)
					
					local slashes = abs:FindFirstChild("Slashes Of Fury") or abs:FindFirstChild("Slashes of Fury")
					local isSlashesReady = slashes and slashes.Enabled and isAbilityReady
					
					if isSlashesReady and isTargeted then
						if distance <= 40 and not isExecutingSlashes then
							task.spawn(function()
								isExecutingSlashes = true
								pcall(function()
									local btn = ReplicatedStorage.Remotes:FindFirstChild("AbilityButtonPress")
									if btn then if btn:IsA("RemoteEvent") then btn:FireServer() else btn:Fire() end end
								end)
								for _ = 1, 6 do
									Stellar.parry.execute_bruteforce()
									task.wait(0.025)
								end
								isExecutingSlashes = false
							end)
						end
					elseif isAbilityReady and isTargeted and not abilityDebounce then
						local standardAbilities = {"Raging Deflection", "Rapture", "Calming Deflection", "Aerodynamic Slash", "Fracture"}
						for _, abilityName in ipairs(standardAbilities) do
							local abilityObj = abs:FindFirstChild(abilityName)
							if abilityObj and abilityObj.Enabled and distance <= 40 then
								Stellar.__properties.__parried = true
								abilityDebounce = true
								pcall(function()
									local btn = ReplicatedStorage.Remotes:FindFirstChild("AbilityButtonPress")
									if btn then if btn:IsA("RemoteEvent") then btn:FireServer() else btn:Fire() end end
								end)
								task.delay(0.2, function() abilityDebounce = false end)
								break
							end
						end
					end
				end
			end
		end

		-- Ball Trajectory Processing Loop
		local balls = Stellar.ball.get_all()
		for _, ball in pairs(balls) do
			if LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape') then continue end
			local zoomies = ball:FindFirstChild('zoomies')
			if not zoomies then continue end
			
			if not Stellar.__properties.__tornado_time then Stellar.__properties.__tornado_time = 0 end
			local aeroVFX = ball:FindFirstChild('AeroDynamicSlashVFX')
			if aeroVFX then
				Stellar.__properties.__tornado_time = tick()
				aeroVFX:Destroy()
			end
			
			local currentTornado = Runtime and Runtime:FindFirstChild('Tornado')
			if currentTornado then
				local tornadoDuration = currentTornado:GetAttribute('TornadoTime') or 1
				if (tick() - Stellar.__properties.__tornado_time) < (tornadoDuration + 0.314159) then continue end
			end

			if not ball:GetAttribute("Stellar_TargetTracked") then
				ball:SetAttribute("Stellar_TargetTracked", true)
				local targetConn = ball:GetAttributeChangedSignal("target"):Connect(function() parryFlag = false end)
				local destroyConn; destroyConn = ball.Destroying:Connect(function()
					if targetConn then targetConn:Disconnect() end
					if destroyConn then destroyConn:Disconnect() end
				end)
			end
			
			local currentTarget = ball:GetAttribute('target')
			local isTargeted = (currentTarget == localName)
			local velocity = zoomies.VectorVelocity
			local ballPos = ball.Position
			local toPlayerVec = playerPos - ballPos
			local distance = toPlayerVec.Magnitude

			if not _ZX_VelHistory[ball] then _ZX_VelHistory[ball] = {} end
			table.insert(_ZX_VelHistory[ball], 1, { pos = ballPos, vel = velocity, t = tick() })
			if #_ZX_VelHistory[ball] > _ZX_VelHistory.MAX_SAMPLES then table.remove(_ZX_VelHistory[ball], #_ZX_VelHistory[ball]) end
			
			local ballSpeed = math.max(velocity.Magnitude, 0)
			local spamThresh = Stellar.__properties.__spam_threshold * Stellar.__properties.__auto_spam_distance_multiplier
			local currentParryCount = Stellar.__properties.__parries or 0
			local maxClashDistance = Stellar.__properties.__spam_threshold

			local autoSpamConditionsMet = Stellar.__properties.__auto_spam_enabled and (currentParryCount > 1) and (isTargeted or (distance and distance < maxClashDistance))

			if autoSpamConditionsMet and distance <= spamThresh then
				Stellar.animation.play_grab_parry()
				local batchAmount = Stellar.__properties.__spam_batch_amount
				local burstCount = (batchAmount == "FPS Priority" and 4) or (batchAmount == "Bruteforce" and 15) or (batchAmount == "Extremely Fast" and 20) or 8
				
				local cachedCF = Stellar.curve.get_cframe()
				for _ = 1, burstCount do Stellar.parry.execute_bruteforce(cachedCF) end
				
				Stellar.__properties.__parries = Stellar.__properties.__parries + burstCount
				task.delay(0.2, function() Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - burstCount) end)
			end

			if not isTargeted or parryFlag then continue end

			-- Teleportation/Spike Interception
			if _ZX_VelHistory[ball] and #_ZX_VelHistory[ball] >= 2 then
				local lastPos = _ZX_VelHistory[ball][2].pos
				local currentPos = _ZX_VelHistory[ball][1].pos
				local distanceJump = (currentPos - lastPos).Magnitude
				if distanceJump > 75 and distance < 45 then
					local cachedCF = Stellar.curve.get_cframe()
					if getgenv().AutoParryMode == "Keypress" then Stellar.parry.keypress(cachedCF) else Stellar.parry.execute_bruteforce(cachedCF) end
					parryFlag = true
					task.spawn(function() task.wait(0.5) parryFlag = false end)
					continue
				end
			end
			
			-- Kinematic Autoparry Pipeline
			local isCurved = Stellar.detection.is_curved(ball)
			local pingValue = 0
			pcall(function() pingValue = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
			local ping = pingValue / 1000

			local approachDir = (distance > 0) and (toPlayerVec / distance) or Vector3.new()
			local approachSpeed = velocity:Dot(approachDir)

			local kinematicProps = Stellar.detection.__kinematic_properties[ball]
			local accelVec = kinematicProps and kinematicProps.smooth_accel_vec or Vector3.new()
			local approachAccel = accelVec:Dot(approachDir)

			local calculatedTTI = math.huge
			local a_param = 0.5 * approachAccel
			local b_param = approachSpeed
			local c_param = -distance

			if math.abs(a_param) > 0.01 then
				local discriminant = (b_param * b_param) - (4 * a_param * c_param)
				if discriminant >= 0 then
					local t1 = (-b_param + math.sqrt(discriminant)) / (2 * a_param)
					local t2 = (-b_param - math.sqrt(discriminant)) / (2 * a_param)
					if t1 > 0 and t2 > 0 then
						calculatedTTI = math.min(t1, t2)
					elseif t1 > 0 then
						calculatedTTI = t1
					elseif t2 > 0 then
						calculatedTTI = t2
					end
				end
			elseif approachSpeed > 0 then
				calculatedTTI = distance / approachSpeed
			end

			local latencyDistanceOffset = (ping * 1.0) * approachSpeed
			local pingAdjustedDistance = math.max(0, distance - latencyDistanceOffset)

			local pingScalar = (ping > 0.2) and 1.35 or 0.95
			local reactionWindow = 0.12 + (ping * pingScalar)
			local distanceThreshold = 9 + (Stellar.__properties.__accuracy / 15) + (ping * 12)

			if isCurved then
				reactionWindow = reactionWindow * 0.25
				distanceThreshold = math.clamp(distanceThreshold * 0.20, 2.0, 5.0)
			else
				reactionWindow = reactionWindow + math.clamp(ballSpeed / 1000, 0, 0.10)
			end

			local isApproaching = approachSpeed > 0.5
			local satisfiesTTI = isApproaching and (calculatedTTI <= reactionWindow)
			local satisfiesDistance = isApproaching and (pingAdjustedDistance <= distanceThreshold)

			if satisfiesTTI or satisfiesDistance then
				parryFlag = true
				
				task.spawn(function()
					local cachedCF = Stellar.curve.get_cframe()
					if getgenv().AutoParryMode == "Keypress" then 
						Stellar.parry.keypress(cachedCF) 
					else 
						Stellar.parry.execute_action(cachedCF) 
					end
				end)
				
				local lastCycle = tick()
				task.spawn(function()
					repeat RunService.PreSimulation:Wait() until (tick() - lastCycle) >= 1 or not parryFlag
					parryFlag = false
				end)
			end
		end

		-- Secondary Training Ball Handler
		local trainingFolder = workspace:FindFirstChild("TrainingBalls")
		if trainingFolder then
			for _, tBall in pairs(trainingFolder:GetChildren()) do
				if tBall:GetAttribute("realBall") then
					local zoomies = tBall:FindFirstChild('zoomies')
					if zoomies and tBall:GetAttribute('target') == localName then
						local distance = LocalPlayer:DistanceFromCharacter(tBall.Position)
						local speed = zoomies.VectorVelocity.Magnitude
						local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 1000
						local parry_acc = (ping * 10) + math.max(speed / (2.4 * Stellar.__properties.__divisor_multiplier), 9.5)
						if distance <= parry_acc and not Stellar.__properties.__training_parried then
							Stellar.__properties.__training_parried = true
							local cachedCF = Stellar.curve.get_cframe()
							if getgenv().AutoParryMode == "Keypress" then Stellar.parry.keypress(cachedCF) else Stellar.parry.execute_action(cachedCF) end
							task.delay(0.5, function() Stellar.__properties.__training_parried = false end)
						end
					end
				end
			end
		end
	end)
end

function Stellar.autoparry.stop()
	if Stellar.__properties.__connections.__combat then
		Stellar.__properties.__connections.__combat:Disconnect()
		Stellar.__properties.__connections.__combat = nil
	end
end

-- Instant Triggerbot Subsystem
Stellar.triggerbot = {}
function Stellar.triggerbot.trigger(ball)
	if Stellar.__triggerbot.__is_parrying or Stellar.__triggerbot.__parries > Stellar.__triggerbot.__max_parries then return end
	if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape') then return end
	Stellar.__triggerbot.__is_parrying = true
	Stellar.__triggerbot.__parries = Stellar.__triggerbot.__parries + 1
	Stellar.animation.play_grab_parry()
	Stellar.parry.execute()
	task.delay(Stellar.__triggerbot.__parry_delay, function() Stellar.__triggerbot.__parries = math.max(0, Stellar.__triggerbot.__parries - 1) end)
	local connection
	connection = ball:GetAttributeChangedSignal('target'):Once(function()
		Stellar.__triggerbot.__is_parrying = false
		if connection then connection:Disconnect() end
	end)
	task.spawn(function()
		local start_time = tick()
		repeat RunService.Heartbeat:Wait() until (tick() - start_time >= 1 or not Stellar.__triggerbot.__is_parrying)
		Stellar.__triggerbot.__is_parrying = false
	end)
end

function Stellar.triggerbot.loop()
	if not Stellar.__triggerbot.__enabled then return end
	local balls = workspace:FindFirstChild('Balls')
	if not balls then return end
	for _, ball in pairs(balls:GetChildren()) do
		if ball:IsA('BasePart') and ball:GetAttribute('target') == LocalPlayer.Name then
			Stellar.triggerbot.trigger(ball)
			break
		end
	end
end

function Stellar.triggerbot.enable(enabled)
	Stellar.__triggerbot.__enabled = enabled
	if enabled then
		if not Stellar.__properties.__connections.__triggerbot then
			Stellar.__properties.__connections.__triggerbot = RunService.Heartbeat:Connect(Stellar.triggerbot.loop)
		end
	else
		if Stellar.__properties.__connections.__triggerbot then
			Stellar.__properties.__connections.__triggerbot:Disconnect()
			Stellar.__properties.__connections.__triggerbot = nil
		end
		Stellar.__triggerbot.__is_parrying = false
		Stellar.__triggerbot.__parries = 0
	end
end

-- Manual High-Frequency Spam Subsystem
Stellar.manual_spam = {}
local manualSpamActive = false
local manualConnection = nil
function Stellar.manual_spam.start()
	Stellar.manual_spam.stop()
	manualSpamActive = true
	manualConnection = RunService.PreSimulation:Connect(function()
		if not (Stellar.__properties.__manual_spam_enabled and Stellar.__properties.__gui_spam_active) then
			Stellar.manual_spam.stop()
			return
		end
		local batchAmount = Stellar.__properties.__spam_batch_amount
		local burstCount = (batchAmount == "FPS Priority" and 4) or (batchAmount == "Bruteforce" and 15) or (batchAmount == "Extremely Fast" and 20) or 8
		local cachedCF = Stellar.curve.get_cframe()
		for _ = 1, burstCount do
			if getgenv().AutoParryMode == "Keypress" then Stellar.parry.keypress(cachedCF) else Stellar.parry.execute_bruteforce(cachedCF) end
		end
		if Stellar.__properties.__play_animation then Stellar.animation.play_grab_parry() end
	end)
end

function Stellar.manual_spam.stop()
	manualSpamActive = false
	if manualConnection then manualConnection:Disconnect(); manualConnection = nil end
end

-- Control Elements Registration
local autoparry_module = AutoparryTab:create_module({
	title = "Auto Parry Core",
	description = "Kinematic trajectory & trajectory protections",
	flag = "AutoParryModule",
	section = "left",
	callback = function(state)
		Stellar.__properties.__autoparry_enabled = state
		Stellar.__properties.__play_animation = state
		if state then pcall(Stellar.autoparry.start) else pcall(Stellar.autoparry.stop) end
	end
})

autoparry_module:create_slider({
	title = "Parry Accuracy",
	flag = "ParryAccuracy",
	maximum_value = 100,
	minimum_value = 1,
	value = 50,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__accuracy = value
		update_divisor()
	end
})

autoparry_module:create_dropdown({
	title = "Parry Mode",
	flag = "ParryMode",
	options = { "Remote", "Keypress" },
	maximum_options = 1,
	callback = function(value) getgenv().AutoParryMode = value end
})

autoparry_module:create_dropdown({
	title = "Mode curve",
	flag = "ModeCurve",
	options = Stellar.__config.__curve_names,
	maximum_options = 1,
	callback = function(value)
		for i, name in ipairs(Stellar.__config.__curve_names) do
			if name == value then Stellar.__properties.__curve_mode = i; break end
		end
	end
})

autoparry_module:create_divider({})
autoparry_module:create_checkbox({
	title = "Randomize Accuracy",
	flag = "RandomizeAccuracy",
	callback = function(value)
		if Stellar then
			Stellar.__properties.__randomized_accuracy_enabled = value
			if value and update_randomized_accuracy then
				pcall(update_randomized_accuracy)
			end
		end
	end
})

autoparry_module:create_checkbox({
	title = "Auto Abilities",
	flag = "AutoAbilities",
	callback = function(state) Stellar.__properties.__auto_ability_enabled = state end
})

autoparry_module:create_checkbox({
	title = "Instant Triggerbot",
	flag = "TriggerbotModule",
	callback = function(state)
		Stellar.__properties.__triggerbot_enabled = state
		Stellar.triggerbot.enable(state)
	end
})

local spam_module = SpamTab:create_module({
	title = "Auto Spam",
	description = "Smart Spam that changes its speed accordingly",
	flag = "AutoSpamModule",
	section = "left",
	callback = function(state) Stellar.__properties.__auto_spam_enabled = state end
})

spam_module:create_slider({
	title = "Auto Spam Distance",
	flag = "AutoSpamDist",
	maximum_value = 50,
	minimum_value = 5,
	value = 35,
	round_number = true,
	callback = function(value) Stellar.__properties.__spam_threshold = value end
})

spam_module:create_dropdown({
	title = "Spam Batch Mode",
	flag = "SpamBatchAmount",
	options = { "FPS Priority", "Balanced", "Bruteforce", "Extremely Fast" },
	maximum_options = 1,
	callback = function(value) Stellar.__properties.__spam_batch_amount = value end
})

local manual_spam_module = SpamTab:create_module({
	title = "Manual Spam", 
	description = "Floating switch interface controller", 
	flag = "ManualSpamModule", 
	section = "right",
	callback = function(state)
		Stellar.__properties.__manual_spam_enabled = state
		if FloatingSwitchSystem.ScreenGui then FloatingSwitchSystem.ScreenGui.Enabled = state end
		if not state then
			Stellar.__properties.__gui_spam_active = false
			FloatingSwitchSystem.IsOn = false
			if Stellar.manual_spam then Stellar.manual_spam.stop() end
		end
	end
})

local detection_module = DetectionTab:create_module({
	title = "Ability Detections",
	description = "Adjust auto-parry parameters per enemy skills",
	flag = "DetectionModule",
	section = "left",
	callback = function(state) end
})

detection_module:create_divider({})
detection_module:create_checkbox({
	title = "Phantom",
	flag = "PhantomDetectToggle",
	callback = function(state) Stellar.__config.__detections.__phantom = state end
})

detection_module:create_checkbox({
	title = "Time Hole Auto Parry",
	flag = "TimeHoleDetectToggle",
	callback = function(state) Stellar.__config.__detections.__timehole = state end
})

detection_module:create_checkbox({
	title = "Slashes of Fury Auto Counter",
	flag = "SlashesOfFuryDetectToggle",
	callback = function(state) Stellar.__config.__detections.__slashesoffury = state end
})

detection_module:create_checkbox({
	title = "Infinity Ball Detection",
	flag = "InfinityDetectToggle",
	callback = function(state) Stellar.__config.__detections.__infinity = state end
})

detection_module:create_checkbox({
	title = "Death Slash Detection",
	flag = "DeathSlashDetectToggle",
	callback = function(state) Stellar.__config.__detections.__deathslash = state end
})

local player_module = PlayerTab:create_module({
	title = "Movement Modifiers",
	description = "Adjust local character attributes",
	flag = "PlayerModule",
	section = "left",
	callback = function(state) Stellar.__properties.__modify_player = state end
})

player_module:create_slider({
	title = "WalkSpeed",
	flag = "WalkSpeedMod",
	maximum_value = 100,
	minimum_value = 16,
	value = 16,
	round_number = true,
	callback = function(value) Stellar.__properties.__walkspeed = value end
})

player_module:create_slider({
	title = "JumpPower",
	flag = "JumpPowerMod",
	maximum_value = 200,
	minimum_value = 50,
	value = 50,
	round_number = true,
	callback = function(value) Stellar.__properties.__jumppower = value end
})

local fov_module = PlayerTab:create_module({
	title = "FOV Changer",
	description = "Adjust camera field of view",
	flag = "FOVmodule",
	section = "right",
	callback = function(state)
		Stellar.__properties.__CameraEnabled = state
		local Camera = workspace.CurrentCamera
		if state then
			Stellar.__properties.__CameraFOV = Stellar.__properties.__CameraFOV or 70
			Camera.FieldOfView = Stellar.__properties.__CameraFOV
			if not Stellar.__properties.__FOVLoop then
				Stellar.__properties.__FOVLoop = RunService.RenderStepped:Connect(function()
					if Stellar.__properties.__CameraEnabled then Camera.FieldOfView = Stellar.__properties.__CameraFOV end
				end)
			end
		else
			Camera.FieldOfView = 70
			if Stellar.__properties.__FOVLoop then
				Stellar.__properties.__FOVLoop:Disconnect()
				Stellar.__properties.__FOVLoop = nil
			end
		end
	end
})

fov_module:create_slider({
	title = "Camera FOV",
	flag = "CameraFOVSlider",
	maximum_value = 120,
	minimum_value = 50,
	value = 70,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__CameraFOV = value
		if Stellar.__properties.__CameraEnabled then workspace.CurrentCamera.FieldOfView = value end
	end
})

local immortality_module = PlayerTab:create_module({
	title = "Immortality Desync",
	flag = "ImmortalityModule",
	description = "Semi-immortal orbital desync",
	section = "right",
	callback = function(state) Stellar.__properties.__immortality_enabled = state end
})

immortality_module:create_checkbox({
	title = "Speed Bypass",
	flag = "ImmortalitySpeedBypass",
	callback = function(state) Stellar.__properties.__immortality_speed_bypass = state end
})

immortality_module:create_slider({
	title = "Orbital Angle",
	flag = "ImmortalityAngle",
	maximum_value = 100,
	minimum_value = 0,
	value = 72,
	round_number = true,
	callback = function(value) Stellar.__properties.__immortality_angle = value end
})

immortality_module:create_slider({
	title = "Peak Height",
	flag = "ImmortalityHeight",
	maximum_value = 270,
	minimum_value = 0,
	value = 15,
	round_number = true,
	callback = function(value) Stellar.__properties.__immortality_height = value end
})

immortality_module:create_slider({
	title = "Desync Depth",
	flag = "ImmortalityDepth",
	maximum_value = 20,
	minimum_value = 0,
	value = 8,
	round_number = true,
	callback = function(value) Stellar.__properties.__immortality_depth = -value end
})

immortality_module:create_slider({
	title = "Orbit Radius",
	flag = "ImmortalityRadius",
	maximum_value = 100,
	minimum_value = 10,
	value = 10,
	round_number = true,
	callback = function(value) Stellar.__properties.__immortality_radius = value end
})

local visuals_module = VisualsTab:create_module({
	title = "Visual",
	description = "Changes Visual",
	flag = "VisualsModule",
	section = "left",
	callback = function(state) end
})

visuals_module:create_button({
	title = "Unlock All",
	callback = function()
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Trying-glitch/RlxProject/refs/heads/main/unlocked%20all%20BB%20no%20gui.txt"))()
		end)
	end
})

local reduce_lag_module = VisualsTab:create_module({
	title = "Reduce Lag",
	description = "Reduce Lag while maintaining visuals",
	flag = "ReduceLagModule",
	section = "right",
	callback = function(state)
		if state then
			if not initialized then
				originalClockTime = Lighting.ClockTime
				originalGlobalShadows = Lighting.GlobalShadows
				
				for _, effect in pairs(Lighting:GetChildren()) do
					if effect:IsA("PostEffect") then
						originalEffectStates[effect] = effect.Enabled
					end
				end
				
				local existingBloom = Lighting:FindFirstChildOfClass("BloomEffect")
				if existingBloom then
					originalBloomProps = {
						Intensity = existingBloom.Intensity,
						Size = existingBloom.Size,
						Threshold = existingBloom.Threshold,
						Enabled = existingBloom.Enabled
					}
				end
				
				for _, obj in pairs(Workspace:GetDescendants()) do
					if obj:IsA("BasePart") then
						originalPartShadows[obj] = obj.CastShadow
					end
				end
				
				initialized = true
			end

			Lighting.ClockTime = 0
			Lighting.GlobalShadows = false

			for _, effect in pairs(Lighting:GetChildren()) do
				if effect:IsA("PostEffect") and not effect:IsA("BloomEffect") then
					effect.Enabled = false
				elseif effect:IsA("Atmosphere") then
					table.insert(disabledAtmispheres, effect)
					effect.Parent = nil
				end
			end

			local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
			if not bloom then
				bloom = Instance.new("BloomEffect")
				bloom.Parent = Lighting
				createdBloom = bloom
			end
			bloom.Enabled = true
			bloom.Intensity = 1.5
			bloom.Size = 24
			bloom.Threshold = 0.8

			for _, obj in pairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					obj.CastShadow = false
				end
			end

			if not timeConnection then
				timeConnection = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
					if Lighting.ClockTime ~= 0 then
						Lighting.ClockTime = 0
					end
				end)
			end
			
			if not descendantConnection then
				descendantConnection = Workspace.DescendantAdded:Connect(function(obj)
					if obj:IsA("BasePart") then
						if originalPartShadows[obj] == nil then
							originalPartShadows[obj] = obj.CastShadow
						end
						obj.CastShadow = false
					end
				end)
			end

			Library.SendNotification({ title = "Stellar Engine", text = "Potato Mode and Night theme initialize", duration = 2 })
		else
			if not initialized then return end
			
			if timeConnection then
				timeConnection:Disconnect()
				timeConnection = nil
			end
			
			if descendantConnection then
				descendantConnection:Disconnect()
				descendantConnection = nil
			end
			
			Lighting.ClockTime = originalClockTime
			Lighting.GlobalShadows = originalGlobalShadows
			
			for _, atmos in pairs(disabledAtmispheres) do
				if atmos then
					atmos.Parent = Lighting
				end
			end
			table.clear(disabledAtmispheres)
			
			for effect, wasEnabled in pairs(originalEffectStates) do
				if effect and effect.Parent then
					effect.Enabled = wasEnabled
				end
			end
			
			if createdBloom then
				createdBloom:Destroy()
				createdBloom = nil
			else
				local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
				if bloom and originalBloomProps.Intensity then
					bloom.Intensity = originalBloomProps.Intensity
					bloom.Size = originalBloomProps.Size
					bloom.Threshold = originalBloomProps.Threshold
					bloom.Enabled = originalBloomProps.Enabled
				end
			end
			
			for obj, hadShadow in pairs(originalPartShadows) do
				if obj and obj.Parent then
					obj.CastShadow = hadShadow
				end
			end

			Library.SendNotification({ title = "Stellar Engine", text = "Potato Mode and Night theme unloaded", duration = 2 })
		end
	end
})

local misc_module = MiscTab:create_module({
	title = "Miscellaneous",
	description = "Extra utility settings",
	flag = "MiscModule",
	section = "left",
	callback = function(state) end
})

local ability_esp_module = MiscTab:create_module({
	title = "Ability ESP",
	description = "Displays equipped abilities over players",
	flag = "AbilityESPModule",
	section = "left",
	callback = function(state)
		Stellar.__properties.__ability_esp_enabled = state
		for _, l in pairs(billboardLabels) do
			if l then l.Visible = state end
		end
	end
})

local no_render_module = MiscTab:create_module({
	title = "No Render",
	description = "Disables rendering of heavy effects",
	flag = "NoRenderModule",
	section = "right",
	callback = function(state)
		local effectScripts = nil
		pcall(function()
			if Players and Players.LocalPlayer and Players.LocalPlayer.PlayerScripts then
				effectScripts = Players.LocalPlayer.PlayerScripts:FindFirstChild("EffectScripts")
			end
		end)
		if effectScripts then
			local clientFX = effectScripts:FindFirstChild("ClientFX")
			if clientFX then clientFX.Disabled = state end
		end
		if state then
			Stellar.__properties.__connections.__no_render = workspace.Runtime.ChildAdded:Connect(function(Value)
				Debris:AddItem(Value, 0)
			end)
		else
			if Stellar.__properties.__connections.__no_render then
				Stellar.__properties.__connections.__no_render:Disconnect()
				Stellar.__properties.__connections.__no_render = nil
			end
		end
	end
})

misc_module:create_button({
	title = "Unload Stellar Engine",
	callback = function()
		Stellar.autoparry.stop()
		Stellar.triggerbot.enable(false)
		Stellar.__properties.__modify_player = false
		Stellar.__properties.__ability_esp_enabled = false
		Stellar.__properties.__immortality_enabled = false
		if Stellar.__properties.__FOVLoop then
			Stellar.__properties.__FOVLoop:Disconnect()
			Stellar.__properties.__FOVLoop = nil
		end
		workspace.CurrentCamera.FieldOfView = 70
		if no_render_module then no_render_module:callback(false) end
		for _, l in pairs(billboardLabels) do
			pcall(function() l.Parent:Destroy() end)
		end
		for key, connection in pairs(Stellar.__properties.__connections) do
			if typeof(connection) == "RBXScriptConnection" and connection.Connected then
				connection:Disconnect()
			end
		end
		table.clear(Stellar.__properties.__connections)
		if library and library.unload then pcall(library.unload) end
		print("[Stellar Engine] Safely unloaded from memory without resource leaks.")
	end
})

misc_module:create_button({
	title = "Print Debug Configuration",
	callback = function()
		print("--- [ Stellar Unified Debug Configuration ] ---")
		print("Auto Parry Enabled:", Stellar.__properties.__autoparry_enabled)
		print("Auto Spam Enabled :", Stellar.__properties.__auto_spam_enabled)
		print("Spam Batch Mode   :", Stellar.__properties.__spam_batch_amount)
		print("Spam Distance     :", Stellar.__properties.__spam_threshold)
		print("Parry Mode        :", getgenv().AutoParryMode or "Remote")
		print("Immortality       :", Stellar.__properties.__immortality_enabled)
		print("GC Token Status   :", _token ~= nil and "Active" or "Unbound")
		print("Captured Remote   :", _captured and _captured.remote:GetFullName() or "None")
		print("-----------------------------------------------")
	end
})

-- Script Initialization Launch
library:load()
Library.SendNotification({ title = "Stellar Engine", text = "Stellar V5.3.6 (bypassed) Initialized.", duration = 3 })
Library.SendNotification({ title = "Stellar Engine", text = "[IMPORTANT] Please Parry Manually First", duration = 5 })
