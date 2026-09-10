setfpscap(9999)
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

-- ═══════════════════════════════════════════════════════════════
-- REAL DEVICE SNAPSHOT (UI-Scale Protection vs Device Spoofer)
-- ═══════════════════════════════════════════════════════════════
if not getgenv()._ZX_REAL_DEVICE_STATE then
	getgenv()._ZX_REAL_DEVICE_STATE = {
		Touch    = UserInputService.TouchEnabled,
		Mouse    = UserInputService.MouseEnabled,
		Keyboard = UserInputService.KeyboardEnabled,
		Gamepad  = UserInputService.GamepadEnabled,
	}
end

-- Stellar UI Library Initialization
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Trying-glitch/Stellar/refs/heads/main/Stellar%20UI.lua"))()
local library = Library.new()
-- Force Stellar UI to detect device from the REAL snapshot, not the spoof
do
	local _orig_get_device = Library.get_device
	local real = getgenv()._ZX_REAL_DEVICE_STATE
	function Library:get_device()
		if real then
			if real.Touch then
				self._device = 'Mobile'
			elseif real.Keyboard and real.Mouse then
				self._device = 'PC'
			elseif real.Gamepad then
				self._device = 'Console'
			else
				self._device = 'Unknown'
			end
			return
		end
		return _orig_get_device(self)
	end
end
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

-- Sword Slash Color Configuration
-- FIX: Only uses solid color mode now, no rainbow/random effects
local SwordSlashConfig = {
	__enabled = false,
	__color = Color3.fromRGB(255, 0, 0),  -- Default red (change this to your desired color)
	__transparency = 0.3,
	__glow_intensity = 1,
	__custom_mode = "Solid" -- FIXED: Only Solid mode supported for sword blade
}

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
		__parry_range = 5, -- ParryRange Scale: 1 = Tightest/Legit, 10+ = Earliest/Aggressive
		__predictive_anti_curve_enabled = true,
		__curve_sensitivity = 50, -- Threshold scale 1-100%
		__prediction_accuracy = 75, -- Lookahead sampling density 1-100%
		__preclick_enabled = false,
		__preclick_max_distance = 100,
		__parried = false,
      __fast_parry_enabled = true,
      __fast_parry_cooldown = 0.03,       -- minimum ms between parries (40ms = 1.5 servo frames)
      __fast_parry_arm_time = 0.045,      -- unlock ball after 45ms regardless of signals
--   __fast_parry_last_fire = 0,
		__training_parried = false,
		__spam_threshold = 25,
		__burst_multiplier = 1,
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
		__slashesoffury_delay = 0.05,
		__slashesoffury_max_count = 36,
		__infinity_active = false,
		__deathslash_active = false,
		__freeze_active = false,
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
		__ability_esp_enabled = false,
		__staff_group_id = 12836673,
		__staff_min_rank = 10,
		__detected_staff_members = {},
		__staff_rank_cache = {},
		__hitsound_enabled = false,
		__hitsound_type = "Medal",
		__hitsound_volume = 5,
		__bgm_enabled = false,
		__bgm_track = "Eeyuh",
		__bgm_volume = 3,
		__bgm_loop = false,
		__active_emote_track = nil,
		__selected_emote = "",
		__emotes_enabled = false    
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
			__deathslash = false,
			__dribble = false,
			__cooldown_protection = false,
			__thunder_dash_nocooldown = false,
			__staff_detection = false,
			__staff_action_mode = "Notification"
		}
	},
	__triggerbot = {
		__enabled = false,
		__is_parrying = false,
		__parries = 0,
		__max_parries = 10000,
		__parry_delay = 0.15,
		__custom_keybind = Enum.KeyCode.R
	}
}

getgenv()._ZX_VelHistory = getgenv()._ZX_VelHistory or setmetatable({}, { __mode = "k" })
local _ZX_VelHistory = getgenv()._ZX_VelHistory
_ZX_VelHistory.MAX_SAMPLES = 10

-- Sword Slash Color System (targets known ParryFX effect structure)
local CollectionService = game:GetService("CollectionService")

local KNOWN_EFFECT_PATHS = {
	"Impact/Glow2Sided",
	"Impact/flare2",
	"Impact/circles",
	"Impact/fast-burst",
	"Impact/impact",
	"Star",
	"Slash/Effect",
	"Slash/Effect3",
}

local sword_slash_system = {
	__active = false,
	__connections = {},
	__rainbow_loop = nil,

	get_current_color = function(self)
		local color = SwordSlashConfig.__color
		if SwordSlashConfig.__custom_mode == "Rainbow" then
			color = Color3.fromHSV((tick() % 3) / 3, 1, 1)
		elseif SwordSlashConfig.__custom_mode == "Random" then
			color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		end
		return color
	end,

	apply_color = function(self, inst, color)
		pcall(function()
			if inst:IsA("BasePart") then
				inst.Color = color
			elseif inst:IsA("Highlight") then
				inst.FillColor = color
				inst.OutlineColor = color
			elseif inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
				inst.Color = ColorSequence.new(color)
			end
		end)
	end,

	is_local_player_sword = function(self, parryFxPart)
		-- Check if this sword belongs to LOCAL PLAYER only
		if not parryFxPart or not parryFxPart:IsDescendantOf(workspace) then return false end
		
		-- Get local player and their character
		local localPlayer = Players.LocalPlayer
		if not localPlayer or not localPlayer.Character then return false end
		
		-- Simple check: is this part a descendant of the local player's character?
		return parryFxPart:IsDescendantOf(localPlayer.Character)
	end,

	color_parry_fx_object = function(self, parryFxPart)
		if not SwordSlashConfig.__enabled then return end
		
		-- CRITICAL: Only color if it belongs to LOCAL PLAYER
		if not self:is_local_player_sword(parryFxPart) then return end
		
		local color = self:get_current_color()

		-- Color the part itself
		self:apply_color(parryFxPart, color)

		-- Color each known child effect by path
		for _, path in ipairs(KNOWN_EFFECT_PATHS) do
			local current = parryFxPart
			for segment in path:gmatch("[^/]+") do
				current = current and current:FindFirstChild(segment)
			end
			if current then
				self:apply_color(current, color)
			end
		end

		-- Also brute-force color any remaining descendants, just in case
		for _, d in ipairs(parryFxPart:GetDescendants()) do
			self:apply_color(d, color)
		end

		-- Reassert for a short window in case of tweens
		local start_time = tick()
		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not parryFxPart.Parent or (tick() - start_time) > 1.2 then
				if conn then conn:Disconnect() end
				return
			end
			local c = self:get_current_color()
			self:apply_color(parryFxPart, c)
			for _, d in ipairs(parryFxPart:GetDescendants()) do
				self:apply_color(d, c)
			end
		end)
		table.insert(self.__connections, conn)
	end,

	start_rainbow_loop = function(self)
		-- Stop existing loop
		if self.__rainbow_loop then
			self.__rainbow_loop:Disconnect()
		end
		
		-- Only start if rainbow or random mode is active
		if SwordSlashConfig.__custom_mode ~= "Rainbow" and SwordSlashConfig.__custom_mode ~= "Random" then
			return
		end
		
		-- Start continuous color update loop
		self.__rainbow_loop = RunService.RenderStepped:Connect(function()
			if not SwordSlashConfig.__enabled then return end
			self:reapply_all()
		end)
	end,

	stop_rainbow_loop = function(self)
		if self.__rainbow_loop then
			self.__rainbow_loop:Disconnect()
			self.__rainbow_loop = nil
		end
	end,

	start = function(self)
		self.__active = true
		self:stop_connections()

		-- Color any that already exist
		for _, inst in ipairs(CollectionService:GetTagged("ParryFX")) do
			self:color_parry_fx_object(inst)
		end

		-- Color new ones as they appear
		table.insert(self.__connections, CollectionService:GetInstanceAddedSignal("ParryFX"):Connect(function(inst)
			self:color_parry_fx_object(inst)
		end))
	end,

	stop_connections = function(self)
		for _, conn in ipairs(self.__connections) do
			conn:Disconnect()
		end
		table.clear(self.__connections)
	end,

	stop = function(self)
		self.__active = false
		self:stop_connections()
	end,

	reapply_all = function(self)
		if not SwordSlashConfig.__enabled then return end
		for _, inst in ipairs(CollectionService:GetTagged("ParryFX")) do
			self:color_parry_fx_object(inst)
		end
	end
}

-- Environment Validation
if not game:IsLoaded() then game.Loaded:Wait() end
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end
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

-- Metatable Proxy & GC Token Subsystem
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

Stellar.ZX_Parry = { Hooked = true }

-- Floating Toggle Switch Subsystem (SYNCED Manual Spam + Triggerbot)
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

-- Triggerbot Floating Switch with Dynamic Keybind
local TriggerbotFloatingSwitch = {
	ScreenGui = nil,
	Root = nil,
	IsOn = false,
	Connections = {},
	KeyTagLabel = nil,
	Config = {
		Title = "TRIGGERBOT",
		StartPosition = UDim2.new(1, -190, 1, -298),
		ColorOff = Color3.fromRGB(40, 40, 46),
		ColorOn = Color3.fromRGB(255, 100, 100),
		KnobColor = Color3.fromRGB(248, 248, 252)
	},
	getKeybind = function(self)
		return Stellar.__triggerbot.__custom_keybind or Enum.KeyCode.R
	end,
	updateKeybind = function(self, newKeybind)
		Stellar.__triggerbot.__custom_keybind = newKeybind
		if self.KeyTagLabel then
			self.KeyTagLabel.Text = newKeybind.Name or "R"
		end
	end
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

-- Build Triggerbot Floating Switch (Synced with Manual Spam)
local function buildTriggerbotSwitch()
	if CoreGui:FindFirstChild("StellarTriggerbotToggle") then
		CoreGui.StellarTriggerbotToggle:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StellarTriggerbotToggle"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false
	screenGui.Parent = CoreGui
	TriggerbotFloatingSwitch.ScreenGui = screenGui

	local root = Instance.new("CanvasGroup")
	root.Name = "Root"
	root.Size = UDim2.fromOffset(168, 114)
	root.Position = TriggerbotFloatingSwitch.Config.StartPosition
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.Parent = screenGui
	TriggerbotFloatingSwitch.Root = root

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
	title.Text = TriggerbotFloatingSwitch.Config.Title
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
	glowOuter.BackgroundColor3 = TriggerbotFloatingSwitch.Config.ColorOn
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
	glowInner.BackgroundColor3 = TriggerbotFloatingSwitch.Config.ColorOn
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
	track.BackgroundColor3 = TriggerbotFloatingSwitch.Config.ColorOff
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
	knob.BackgroundColor3 = TriggerbotFloatingSwitch.Config.KnobColor
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
	dot.BackgroundColor3 = TriggerbotFloatingSwitch.Config.ColorOff
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
	keyTag.Text = TriggerbotFloatingSwitch:getKeybind().Name or "R"
	keyTag.TextSize = 11
	keyTag.TextColor3 = Color3.fromRGB(205, 205, 215)
	keyTag.LayoutOrder = 3
	keyTag.ZIndex = 2
	keyTag.Parent = statusRow
	TriggerbotFloatingSwitch.KeyTagLabel = keyTag
	local ktc = Instance.new("UICorner") ktc.CornerRadius = UDim.new(0, 5) ktc.Parent = keyTag
	local ktStroke = Instance.new("UIStroke") ktStroke.Color = Color3.fromRGB(68, 68, 76) ktStroke.Thickness = 1 ktStroke.Parent = keyTag
	local ktPad = Instance.new("UIPadding") ktPad.PaddingLeft = UDim.new(0, 7) ktPad.PaddingRight = UDim.new(0, 7) ktPad.Parent = keyTag

	local function applyVisualState(on, animated)
		local quick = TweenInfo.new(animated and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local knobTween = TweenInfo.new(animated and 0.28 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local knobPos = on and UDim2.new(1, -31, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)

		TweenService:Create(track, quick, { BackgroundColor3 = on and TriggerbotFloatingSwitch.Config.ColorOn or TriggerbotFloatingSwitch.Config.ColorOff }):Play()
		TweenService:Create(trackStroke, quick, { Color = on and TriggerbotFloatingSwitch.Config.ColorOn or Color3.fromRGB(64, 64, 72) }):Play()
		TweenService:Create(knob, knobTween, { Position = knobPos }):Play()
		TweenService:Create(dot, quick, { BackgroundColor3 = on and TriggerbotFloatingSwitch.Config.ColorOn or Color3.fromRGB(90, 90, 98) }):Play()
		TweenService:Create(statusText, quick, { TextColor3 = on and TriggerbotFloatingSwitch.Config.ColorOn or Color3.fromRGB(150, 150, 160) }):Play()
		TweenService:Create(glowOuter, quick, { BackgroundTransparency = on and 0.82 or 1 }):Play()
		TweenService:Create(glowInner, quick, { BackgroundTransparency = on and 0.7 or 1 }):Play()
		statusText.Text = on and "ON" or "OFF"
	end

	local function toggleState()
		TriggerbotFloatingSwitch.IsOn = not TriggerbotFloatingSwitch.IsOn
		applyVisualState(TriggerbotFloatingSwitch.IsOn, true)
		Stellar.__properties.__triggerbot_enabled = TriggerbotFloatingSwitch.IsOn
		if TriggerbotFloatingSwitch.IsOn then
			if Stellar.triggerbot and typeof(Stellar.triggerbot.enable) == "function" then Stellar.triggerbot.enable(true) end
		else
			if Stellar.triggerbot and typeof(Stellar.triggerbot.enable) == "function" then Stellar.triggerbot.enable(false) end
		end
	end

	applyVisualState(TriggerbotFloatingSwitch.IsOn, false)

	local dragging, moved = false, false
	local dragStart, startPos = Vector2.zero, Vector2.zero
	local DRAG_TOLERANCE = 4

	table.insert(TriggerbotFloatingSwitch.Connections, track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true moved = false
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = root.AbsolutePosition
			TweenService:Create(track, TweenInfo.new(0.12), { Size = UDim2.fromOffset(76, 36) }):Play()
		end
	end))

	table.insert(TriggerbotFloatingSwitch.Connections, UserInputService.InputChanged:Connect(function(input)
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

	table.insert(TriggerbotFloatingSwitch.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				TweenService:Create(track, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(72, 34) }):Play()
				if not moved then toggleState() end
			end
		end
	end))

	table.insert(TriggerbotFloatingSwitch.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == TriggerbotFloatingSwitch:getKeybind() then
			toggleState()
			local resting = keyTag.BackgroundColor3
			TweenService:Create(keyTag, TweenInfo.new(0.06), { BackgroundColor3 = TriggerbotFloatingSwitch.Config.ColorOn }):Play()
			task.delay(0.15, function()
				TweenService:Create(keyTag, TweenInfo.new(0.25), { BackgroundColor3 = resting }):Play()
			end)
		end
	end))

	TweenService:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
	TweenService:Create(rootScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

buildTriggerbotSwitch()

-- Convert key name string to Enum.KeyCode
local function stringToKeyCode(keyName)
	if not keyName then return Enum.KeyCode.R end
	keyName = keyName:upper()
	
	local keyMap = {
		["A"] = Enum.KeyCode.A, ["B"] = Enum.KeyCode.B, ["C"] = Enum.KeyCode.C,
		["D"] = Enum.KeyCode.D, ["E"] = Enum.KeyCode.E, ["F"] = Enum.KeyCode.F,
		["G"] = Enum.KeyCode.G, ["H"] = Enum.KeyCode.H, ["I"] = Enum.KeyCode.I,
		["J"] = Enum.KeyCode.J, ["K"] = Enum.KeyCode.K, ["L"] = Enum.KeyCode.L,
		["M"] = Enum.KeyCode.M, ["N"] = Enum.KeyCode.N, ["O"] = Enum.KeyCode.O,
		["P"] = Enum.KeyCode.P, ["Q"] = Enum.KeyCode.Q, ["R"] = Enum.KeyCode.R,
		["S"] = Enum.KeyCode.S, ["T"] = Enum.KeyCode.T, ["U"] = Enum.KeyCode.U,
		["V"] = Enum.KeyCode.V, ["W"] = Enum.KeyCode.W, ["X"] = Enum.KeyCode.X,
		["Y"] = Enum.KeyCode.Y, ["Z"] = Enum.KeyCode.Z,
		["F1"] = Enum.KeyCode.F1, ["F2"] = Enum.KeyCode.F2, ["F3"] = Enum.KeyCode.F3,
		["F4"] = Enum.KeyCode.F4, ["F5"] = Enum.KeyCode.F5, ["F6"] = Enum.KeyCode.F6,
		["F7"] = Enum.KeyCode.F7, ["F8"] = Enum.KeyCode.F8, ["F9"] = Enum.KeyCode.F9,
		["F10"] = Enum.KeyCode.F10, ["F11"] = Enum.KeyCode.F11, ["F12"] = Enum.KeyCode.F12,
		["0"] = Enum.KeyCode.Zero, ["1"] = Enum.KeyCode.One, ["2"] = Enum.KeyCode.Two,
		["3"] = Enum.KeyCode.Three, ["4"] = Enum.KeyCode.Four, ["5"] = Enum.KeyCode.Five,
		["6"] = Enum.KeyCode.Six, ["7"] = Enum.KeyCode.Seven, ["8"] = Enum.KeyCode.Eight,
		["9"] = Enum.KeyCode.Nine,
		["SPACE"] = Enum.KeyCode.Space, ["TAB"] = Enum.KeyCode.Tab,
		["SHIFT"] = Enum.KeyCode.LeftShift, ["CTRL"] = Enum.KeyCode.LeftControl,
		["ALT"] = Enum.KeyCode.LeftAlt, ["RETURN"] = Enum.KeyCode.Return
	}
	
	return keyMap[keyName] or Enum.KeyCode.R
end

-- Performance Monitor Subsystem
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
		Active = false,  -- GATED: enabled after remote capture
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
		Size = UDim2.new(0, 22, 0, 22),
		Active = false  -- GATED: enabled after remote capture
	}, { corner(7) })

	local header = createInst("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		LayoutOrder = 1
	}, { dragHandle, toggleButton })

	local fpsValue = createInst("TextLabel", {
		Name = "FPSValue", Text = "--", Font = Enum.Font.GothamBold, TextSize = 28,
		TextColor3 = PerfMonitorSystem.Colors.textBright, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 30)
	})

	local fpsBlock = createInst("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(0, 82, 1, 0)
	}, {
		createInst("TextLabel", {
			Text = "FPS", Font = Enum.Font.GothamMedium, TextSize = 11,
			TextColor3 = PerfMonitorSystem.Colors.textDim, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16)
		}),
		fpsValue
	})

	local divider = createInst("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9,
		BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 90, 0.5, 0), Size = UDim2.new(0, 1, 0, 34)
	})

	local pingValue = createInst("TextLabel", {
		Name = "PingValue", Text = "--", RichText = true, Font = Enum.Font.GothamBold, TextSize = 28,
		TextColor3 = PerfMonitorSystem.Colors.textBright, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 30)
	})

	local pingBlock = createInst("Frame", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 100, 0, 0), Size = UDim2.new(0, 82, 1, 0)
	}, {
		createInst("TextLabel", {
			Text = "PING", Font = Enum.Font.GothamMedium, TextSize = 11,
			TextColor3 = PerfMonitorSystem.Colors.textDim, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16)
		}),
		pingValue
	})

	local statsFrame = createInst("Frame", {
		Name = "Stats", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48), LayoutOrder = 2
	}, { fpsBlock, divider, pingBlock })

	local BAR_WIDTH, BAR_GAP = 3, 2
	local bars = {}
	local graph = createInst("Frame", {
		Name = "Graph", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 3
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
		Name = "Card", BackgroundColor3 = PerfMonitorSystem.Colors.bg,
		BackgroundTransparency = 0.05, BorderSizePixel = 0, ClipsDescendants = true,
		Position = PerfMonitorSystem.Config.START_POSITION,
		Size = UDim2.new(0, PerfMonitorSystem.Config.CARD_WIDTH, 0, PerfMonitorSystem.Config.EXPANDED_HEIGHT),
		Active = false  -- never blocks, ever
	}, {
		corner(14), cardStroke,
		createInst("UIGradient", {
			Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
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
			Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder
		}),
		header, statsFrame, graph
	})

	local screenGui = createInst("ScreenGui", {
		Name = "StellarPerformanceMonitor", ResetOnSpawn = false,
		IgnoreGuiInset = false, DisplayOrder = 999
	}, { card })
	screenGui.Parent = CoreGui
	PerfMonitorSystem.ScreenGui = screenGui
	PerfMonitorSystem.Card = card

	-- ═══════════════════════════════════════════════════════════════
	-- CAPTURE GATE: everything passive until _captured fires,
	-- then flip interactive on. Drag/toggle connections below stay
	-- wired the whole time — they simply don't fire while Active=false.
	-- ═══════════════════════════════════════════════════════════════
	local function setInteractive(enabled)
		pcall(function()
			dragHandle.Active = enabled
			toggleButton.Active = enabled
		end)
	end

	setInteractive(false)  -- start fully passive

	task.spawn(function()
		-- wait for the remote hook to capture a valid parry remote
		while not (_captured and _captured.remote) do
			task.wait(0.5)
		end
		setInteractive(true)  -- remotes captured → dragging/toggle safe now
	end)

	-- Collapse/expand (only works post-capture because of Active gate)
	local expanded = true
	table.insert(PerfMonitorSystem.Connections, toggleButton.MouseButton1Click:Connect(function()
		if not toggleButton.Active then return end
		expanded = not expanded
		toggleButton.Text = expanded and "-" or "+"
		TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, PerfMonitorSystem.Config.CARD_WIDTH, 0, expanded and PerfMonitorSystem.Config.EXPANDED_HEIGHT or PerfMonitorSystem.Config.COLLAPSED_HEIGHT)
		}):Play()
	end))

	-- Drag logic — ORIGINAL code, untouched. Works once dragHandle.Active = true
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
			break
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

Stellar.dribble_detection = {}

function Stellar.dribble_detection.scan()
	if not Stellar.__config.__detections.__dribble then
		Stellar.__properties.__dribble_active = false
		return
	end

	local ballsFolder = workspace:FindFirstChild("Balls")
	if not ballsFolder then
		Stellar.__properties.__dribble_active = false
		return
	end

	local dribbleFound = false
	for _, ball in ipairs(ballsFolder:GetChildren()) do
		if ball:IsA("BasePart") then
			local hasAttribute = ball:GetAttribute("dribble") or ball:GetAttribute("Dribble")
			local nameMatch = ball.Name and string.find(string.lower(ball.Name), "dribble") ~= nil
			local childMatch = ball:FindFirstChild("Dribble") ~= nil or ball:FindFirstChild("Dribbling") ~= nil

			if hasAttribute or nameMatch or childMatch then
				dribbleFound = true
				break
			end
		end
	end

	Stellar.__properties.__dribble_active = dribbleFound
end

function Stellar.dribble_detection.start()
	Stellar.dribble_detection.stop()

	Stellar.__properties.__connections.__dribble_monitor = task.spawn(function()
		while task.wait(0.15) do
			if Stellar.__config.__detections.__dribble then
				Stellar.dribble_detection.scan()
			else
				Stellar.__properties.__dribble_active = false
			end
		end
	end)
end

function Stellar.dribble_detection.stop()
	if Stellar.__properties.__connections.__dribble_monitor then
		if type(Stellar.__properties.__connections.__dribble_monitor) == "thread" then
			task.cancel(Stellar.__properties.__connections.__dribble_monitor)
		end
		Stellar.__properties.__connections.__dribble_monitor = nil
	end
	Stellar.__properties.__dribble_active = false
end

-- Ability Remote Listener Pipeline
Stellar.ability_detections = {}

function Stellar.ability_detections.initialize()
	Stellar.ability_detections.cleanup()

	task.spawn(function()
		local packages = ReplicatedStorage:WaitForChild("Packages", 10)
		local indexFolder = packages and packages:WaitForChild("_Index", 10)
		local netFolder = nil

		if indexFolder then
			for _, child in ipairs(indexFolder:GetChildren()) do
				if string.match(child.Name, "sleitnick_net") then
					netFolder = child:WaitForChild("net", 5)
					if netFolder then break end
				end
			end
		end

		if netFolder then
			local timeHoleAct = netFolder:FindFirstChild("RE/TimeHoleActivate")
			if timeHoleAct then
				Stellar.__properties.__connections.__det_timehole_act = timeHoleAct.OnClientEvent:Connect(function(...)
					if not Stellar.__config.__detections.__timehole then return end
					local args = { ... }
					local player = args[1]
					if player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name) then
						Stellar.__properties.__timehole_active = true
					end
				end)
			end

			local timeHoleDeact = netFolder:FindFirstChild("RE/TimeHoleDeactivate")
			if timeHoleDeact then
				Stellar.__properties.__connections.__det_timehole_deact = timeHoleDeact.OnClientEvent:Connect(function()
					Stellar.__properties.__timehole_active = false
				end)
			end
		end

		local ballsFolder = workspace:FindFirstChild("Balls")
		if ballsFolder then
			Stellar.__properties.__connections.__det_slashes_combo = ballsFolder.ChildAdded:Connect(function(Value)
				local childConn
				childConn = Value.ChildAdded:Connect(function(Child)
					if Child.Name == 'ComboCounter' then
						local Sof_Label = Child:FindFirstChildOfClass('TextLabel')

						if Sof_Label then
							Stellar.__properties.__slashesoffury_active = true
							
							task.spawn(function()
								repeat
									if Stellar.__config.__detections.__slashesoffury then
										local Slashes_Counter = tonumber(Sof_Label.Text)
										local max_parries = Stellar.__properties.__slashesoffury_max_count or 34

										if Slashes_Counter and Slashes_Counter <= max_parries then
											local delayVal = Stellar.__properties.__slashesoffury_delay or 0.05
											if tick() - (Stellar.__properties.__last_global_parry or 0) >= delayVal then
												Stellar.__properties.__last_global_parry = tick()
												Stellar.parry.execute_action()
											end
										end
									end
									task.wait()
								until not Sof_Label.Parent or not Sof_Label
								
								Stellar.__properties.__slashesoffury_active = false
							end)
						end
					end
				end)
				
				local destroyConn
				destroyConn = Value.Destroying:Connect(function()
					if childConn then childConn:Disconnect() end
					if destroyConn then destroyConn:Disconnect() end
				end)
			end)
		end

		pcall(function()
			local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
			if remotes then
				local deathBall = remotes:FindFirstChild("DeathBall")
				if deathBall then
					Stellar.__properties.__connections.__det_deathball = deathBall.OnClientEvent:Connect(function(c, d)
						if Stellar.__config.__detections.__deathslash then
							Stellar.__properties.__deathslash_active = d or false
						end
					end)
				end

				local infinityBall = remotes:FindFirstChild("InfinityBall")
				if infinityBall then
					Stellar.__properties.__connections.__det_infinityball = infinityBall.OnClientEvent:Connect(function(a, b)
						if Stellar.__config.__detections.__infinity then
							Stellar.__properties.__infinity_active = b or false
						end
					end)
				end

				local parrySuccessAll = remotes:FindFirstChild("ParrySuccessAll")
				if parrySuccessAll then
					Stellar.__properties.__connections.__det_parrysuccess = parrySuccessAll.OnClientEvent:Connect(function(_, root)
						if not root or not root.Parent or root.Parent == LocalPlayer.Character then return end
						if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end

						local closest = Stellar.player.get_closest()
						local ball = Stellar.ball.get()
						if not ball or not closest or not closest.PrimaryPart then return end

						local targetDist = (LocalPlayer.Character.PrimaryPart.Position - closest.PrimaryPart.Position).Magnitude
						local ballVec = LocalPlayer.Character.PrimaryPart.Position - ball.Position
						if ballVec.Magnitude == 0 then return end

						local ballDist = ballVec.Magnitude
						local ballDir = ballVec.Unit
						local ballVel = ball.AssemblyLinearVelocity or Vector3.new()
						if ballVel.Magnitude == 0 then return end

						local dot = ballDir:Dot(ballVel.Unit)
						local isCurved = Stellar.detection.is_curved(ball)

						if targetDist < 15 and ballDist < 15 and dot > -0.25 and isCurved then
							Stellar.parry.execute_action()
						end
					end)
				end
			end
		end)
	end)

	local runtimeFolder = workspace:WaitForChild("Runtime", 10) or workspace
	Stellar.__properties.__connections.__det_phantom = runtimeFolder.ChildAdded:Connect(function(object)
		if not Stellar.__config.__detections.__phantom then return end
		if object.Name == "maxTransmission" or object.Name == "transmissionpart" then
			local weld = object:FindFirstChildWhichIsA("WeldConstraint")
			if weld then
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				if char and weld.Part1 == char:FindFirstChild("HumanoidRootPart") then
					local currentBall = Stellar.ball.get()
					weld:Destroy()
					if currentBall then
						local focusConn
						focusConn = RunService.RenderStepped:Connect(function()
							local highlighted = currentBall:GetAttribute("highlighted")
							if highlighted == true then
								if tick() - (Stellar.__properties.__last_global_parry or 0) >= 0.1 then
									Stellar.__properties.__last_global_parry = tick()
									Stellar.parry.execute_action(cachedCF) 
								end
							elseif highlighted == false then
								if focusConn then focusConn:Disconnect() end
							end
						end)
						task.delay(3, function()
							if focusConn and focusConn.Connected then focusConn:Disconnect() end
						end)
					end
				end
			end
		end
	end)
end

function Stellar.ability_detections.cleanup()
	local keys = {
		"__det_timehole_act",
		"__det_timehole_deact",
		"__det_slashes_combo",
		"__det_deathball",
		"__det_infinityball",
		"__det_parrysuccess",
		"__det_phantom"
	}

	for _, key in ipairs(keys) do
		if Stellar.__properties.__connections[key] then
			pcall(function() Stellar.__properties.__connections[key]:Disconnect() end)
			Stellar.__properties.__connections[key] = nil
		end
	end
end

Stellar.ability_exploits = {}

function Stellar.ability_exploits.apply_thunder_dash()
    if not Stellar.__config.__detections.__thunder_dash_nocooldown then return end

    local shared = ReplicatedStorage:FindFirstChild('Shared')
    local abilities = shared and shared:FindFirstChild('Abilities')
    local thunderDashModule = abilities and abilities:FindFirstChild('Thunder Dash')
    if not thunderDashModule then return end

    local ok, mod = pcall(require, thunderDashModule)
    if ok and mod then
        pcall(function()
            mod.cooldown = 0
            mod.cooldownReductionPerUpgrade = 0
        end)
    end
end

Stellar.staff_detection = {}

function Stellar.staff_detection.get_rank(player)
	if not player or not player:IsA("Player") then return 0 end
	
	if Stellar.__properties.__staff_rank_cache[player.UserId] then
		return Stellar.__properties.__staff_rank_cache[player.UserId]
	end

	local success, rank = pcall(function()
		return player:GetRankInGroup(Stellar.__properties.__staff_group_id)
	end)

	if success and type(rank) == "number" then
		Stellar.__properties.__staff_rank_cache[player.UserId] = rank
		return rank
	end

	return 0
end

function Stellar.staff_detection.process_player(player)
	if not player or player == LocalPlayer then return end
	
	local userId = player.UserId
	if Stellar.__properties.__detected_staff_members[userId] then
		return
	end

	task.spawn(function()
		local rank = Stellar.staff_detection.get_rank(player)
		if rank >= Stellar.__properties.__staff_min_rank then
			Stellar.__properties.__detected_staff_members[userId] = {
				Name = player.Name,
				DisplayName = player.DisplayName,
				Rank = rank,
				Time = os.time()
			}

			local actionMode = Stellar.__config.__detections.__staff_action_mode
			
			if actionMode == "Notification" then
				Library.SendNotification({
					title = "STAFF DETECTED",
					text = "Moderator in server: " .. player.Name .. " (Rank " .. tostring(rank) .. "+)",
					duration = 6
				})
			elseif actionMode == "Kick" then
				LocalPlayer:Kick("\n[Stellar Security]\nStaff member detected in session: " .. player.Name .. ".\nDisconnected to protect account integrity.")
			end
		end
	end)
end

function Stellar.staff_detection.start()
	Stellar.staff_detection.stop()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			Stellar.staff_detection.process_player(player)
		end
	end

	Stellar.__properties.__connections.__staff_detection = Players.PlayerAdded:Connect(function(player)
		if Stellar.__config.__detections.__staff_detection then
			Stellar.staff_detection.process_player(player)
		end
	end)
end

function Stellar.staff_detection.stop()
	if Stellar.__properties.__connections.__staff_detection then
		if typeof(Stellar.__properties.__connections.__staff_detection) == "RBXScriptConnection" then
			Stellar.__properties.__connections.__staff_detection:Disconnect()
		end
		Stellar.__properties.__connections.__staff_detection = nil
	end
	
	table.clear(Stellar.__properties.__detected_staff_members)
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

local function fireParryInput()
	if keypress and keyrelease then
		pcall(function()
			keypress(0x46)
			task.wait(0.03)
			keyrelease(0x46)
		end)
		return true
	end
	
	if mouse1press and mouse1release then
		pcall(function()
			mouse1press()
			task.wait(0.03)
			mouse1release()
		end)
		return true
	end
	if mouse1click then
		pcall(function() mouse1click() end)
		return true
	end
	return false
end

local function fireParry(precalc_cframe)
    if not _captured then
		fireParryInput()
		return
	end
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- ULTRA-FAST PARRY EXECUTION WITH SUB-TICK RE-ARM PROTECTION
-- Fires on PreSimulation for minimal latency (handled in autoparry start),
-- uses a "re-arm token" that is ONLY reset by:
--   1. target attribute change (server actually swapped targets), OR
--   2. a hard safety timeout (configurable, default 40ms) — whichever comes first.
-- This prevents double-parry while enabling 1-50ms reaction times.
-- ═══════════════════════════════════════════════════════════════════════════════

-- New properties needed (add to Stellar.__properties init at top of file):
--   __fast_parry_cooldown = 0.04    -- 40ms minimum re-arm delay
--   __fast_parry_last_fire = 0

Stellar.parry = {}

local _parryTokenLocked = {}   -- weak-keyed by ball: prevents re-fire while locked

local function canFireParryOnBall(ball)
    if _parryTokenLocked[ball] then return false end
    return true
end

local function lockParryOnBall(ball)
    if not ball or not _parryTokenLocked then return end
    _parryTokenLocked[ball] = true
    
    -- Unlock when game swaps target or after safety window expires
    local unlocked = false
    local function unlock()
        if unlocked then return end
        unlocked = true
        _parryTokenLocked[ball] = nil
    end

    -- Signal-based unlock (server processed our parry → target changes)
    ball:GetAttributeChangedSignal("target"):Once(function()
        unlock()
    end)

    -- Hard timeout unlock (safety net — 45ms after we fired)
    task.delay(Stellar.__properties.__fast_parry_arm_time or 0.045, function()
        unlock()
    end)
end

function Stellar.parry.execute(precalc_cframe)
    if Stellar.__properties.__parries > 10000 or not LocalPlayer.Character then 
        return false
    end
    
    -- Rate-limit: only every X ms maximum (PreSimulation fires ~60/s minimum)
    local now = tick()
    if now - (Stellar.__properties.__fast_parry_last_fire or 0) < (Stellar.__properties.__fast_parry_cooldown or 0.04) then
        return false
    end
    Stellar.__properties.__fast_parry_last_fire = now
    
    fireParry(precalc_cframe)
    Stellar.__properties.__parries = Stellar.__properties.__parries + 1
    task.delay(0.5, function() 
        Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - 1) 
    end)
    return true
end

function Stellar.parry.keypress(precalc_cframe)
    if Stellar.__properties.__parries > 10000 or not LocalPlayer.Character then 
        return false 
    end

    local now = tick()
    if now - (Stellar.__properties.__fast_parry_last_fire or 0) < (Stellar.__properties.__fast_parry_cooldown or 0.04) then
        return false
    end
    Stellar.__properties.__fast_parry_last_fire = now

    fireParryInput()

    Stellar.__properties.__parries = Stellar.__properties.__parries + 1
    task.delay(0.5, function() 
        Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - 1) 
    end)
    return true
end

function Stellar.parry.execute_action(precalc_cframe)
    Stellar.animation.play_grab_parry()
    return Stellar.parry.execute(precalc_cframe)
end

function Stellar.parry.execute_bruteforce(precalc_cframe)
    if Stellar.__properties.__parries > 10000 or not LocalPlayer.Character then 
        return false 
    end
    fireParry(precalc_cframe)
    Stellar.__properties.__parries = Stellar.__properties.__parries + 1
    task.delay(0.5, function() 
        Stellar.__properties.__parries = math.max(0, Stellar.__properties.__parries - 1) 
    end)
    return true
end

-- Exposed for the ball-locked fast path in autoparry.start
Stellar.parry.canFireOnBall = canFireParryOnBall
Stellar.parry.lockBall = lockParryOnBall

local parryLockUntil = setmetatable({}, { __mode = "k" })  -- 🔒 time-based, immune to target flicker

local last_anim_tick = 0
Stellar.animation = { _active_animator = nil, _track_cache = {}, _resolved_swords = {} }
local function find_grab_parry_in_folder(folder, has_accessory)
    if not folder then return nil end
    local type_folder = folder:FindFirstChild(has_accessory and "Accessory" or "Base")
    if type_folder then
        local sub = type_folder:FindFirstChild("Default") or type_folder
        local anim = sub:FindFirstChild("GrabParry") or sub:FindFirstChild("Parry")
        if anim then return anim end
    end
    local anim = folder:FindFirstChild("GrabParry") or folder:FindFirstChild("Parry")
    if anim then return anim end
    local def = folder:FindFirstChild("Default")
    if def then
        anim = def:FindFirstChild("GrabParry") or def:FindFirstChild("Parry")
        if anim then return anim end
    end return nil
end

local function resolve_parry_animation(character, sword_name)
    local collection = ReplicatedStorage:WaitForChild("Shared", 9e9):WaitForChild("SwordAPI", 9e9):WaitForChild("Collection", 9e9)
    local default_folder = collection:FindFirstChild("Default")
    local default_anim = default_folder and (default_folder:FindFirstChild("GrabParry") or default_folder:FindFirstChild("Parry"))
    if not sword_name or sword_name == "" then return default_anim end
    if Stellar.animation._resolved_swords[sword_name] then return Stellar.animation._resolved_swords[sword_name] end
    local has_accessory = character:GetAttribute("HasAccessoryEquipped") or false
    local parry_animation = default_anim
    local success, sword_data = pcall(function() return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(sword_name) end)
    if success and type(sword_data) == "table" then
        local own_folder = collection:FindFirstChild(sword_data.Name or sword_name)
        local found = find_grab_parry_in_folder(own_folder, has_accessory)
        if not found and sword_data.AnimationType then
            local type_folder = collection:FindFirstChild(sword_data.AnimationType)
            found = find_grab_parry_in_folder(type_folder, has_accessory)
        end
        if found then parry_animation = found end
    end
    Stellar.animation._resolved_swords[sword_name] = parry_animation return parry_animation
end

function Stellar.animation.play_grab_parry()
    if not Stellar.__properties.__play_animation or (tick() - last_anim_tick) < 0.25 then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end

    if Stellar.animation._active_animator ~= animator then
        table.clear(Stellar.animation._track_cache)
        Stellar.animation._active_animator = animator
    end

    local sword_name = character:GetAttribute("CurrentlyEquippedSword")
    local parry_animation = resolve_parry_animation(character, sword_name)
    if not parry_animation then return end

    local anim_id = parry_animation.AnimationId
    local track = Stellar.animation._track_cache[anim_id]

    if not track or not track.Parent then
        local ok, loadedTrack = pcall(function() return animator:LoadAnimation(parry_animation) end)
        if not ok or not loadedTrack then return end
        track = loadedTrack
        track.Priority = Enum.AnimationPriority.Action4
        Stellar.animation._track_cache[anim_id] = track
    end

    if track.IsPlaying then return end
    track.TimePosition = 0
    last_anim_tick = tick()
    track:Play(0.05, 1.0, 1.0)
end

task.spawn(function()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        local parrySuccessRemote = remotes and remotes:WaitForChild("ParrySuccess", 10)
        if parrySuccessRemote then
            parrySuccessRemote.OnClientEvent:Connect(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.Name == "GrabParry" or track.Name == "Parry" or track.Name == "Grab" then track:Stop(0.1) end
                    end
                end
            end)
        end
    end)
end)

-- SYSTEM 3: REAL PREDICTIVE KINEMATIC ANTI-CURVE ENGINE
Stellar.detection = {
    __ball_properties = {
        __lerp_radians = 0,
        __last_warping = tick(),
        __curving = tick()
    },
    __kinematic_properties = {}
}

-- ══ RANGE-SCALED CURVE TIGHTENING ═══════════════════════════════════
-- Range 1 → 0.95 (5% tighter) · Range 7 → 0.70 (30% tighter)
function Stellar.detection.get_curve_tighten()
	local r = math.clamp(Stellar.__properties.__parry_range, 1, 7)
	return 0.95 - ((r - 1) / 6) * 0.25
end

function Stellar.detection.is_curved(ball)
    ball = ball or Stellar.ball.get()
    if not ball then return false end
    if not Stellar.__properties.__predictive_anti_curve_enabled then return false end

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

    if distance <= 6.0 then return false end

    local toPlayerDir = toPlayerVec / distance
    local velocityDir = velocity / speed
    local currentDot = toPlayerDir:Dot(velocityDir)

    -- ── Initialise per-ball kinematic tracker ──────────────────────────
    if not Stellar.detection.__kinematic_properties[ball] then
        local initial_history = {}
        for i = 1, 8 do
            initial_history[i] = { p = ballPos, v = velocity, t = os.clock() }
        end
        Stellar.detection.__kinematic_properties[ball] = {
            history = initial_history,
            idx = 0,
            smooth_accel_vec = Vector3.new(),
            smooth_angular = 0
        }
    end

    local props = Stellar.detection.__kinematic_properties[ball]
    local now = os.clock()

    props.idx = (props.idx % 8) + 1
    props.history[props.idx] = { p = ballPos, v = velocity, t = now }

    -- ── Raw acceleration from oldest→newest sample ────────────────────
    local raw_accel_vec = Vector3.new()
    local oldest_idx = (props.idx % 8) + 1
    local oldest = props.history[oldest_idx]

    if oldest and oldest.t > 0 and (now - oldest.t) > 0.015 then
        local dt = now - oldest.t
        local dv = velocity - oldest.v
        raw_accel_vec = dv / dt
    end

    local alpha = math.clamp(Stellar.__properties.__prediction_accuracy / 100, 0.1, 0.9)
    props.smooth_accel_vec = props.smooth_accel_vec:Lerp(raw_accel_vec, alpha)

    -- ── Forward trajectory prediction (kinematic) ─────────────────────
    local lookAheadHorizon = math.clamp(
        (distance / speed) * (Stellar.__properties.__prediction_accuracy / 50), 0.05, 0.45
    )
    local sampleSteps = 5
    local dtStep = lookAheadHorizon / sampleSteps
    local minPredictedDistance = distance
    local threatening = false

    for step = 1, sampleSteps do
        local t = step * dtStep
        local predictedPos = ballPos + (velocity * t) + (0.5 * props.smooth_accel_vec * t * t)
        local predDist = (playerPos - predictedPos).Magnitude
        if predDist < minPredictedDistance then
            minPredictedDistance = predDist
        end
        if predDist <= 15 then
            threatening = true
        end
    end

    local sensitivity = math.clamp(Stellar.__properties.__curve_sensitivity / 100, 0.1, 1.0)
    local tight = Stellar.detection.get_curve_tighten()
    local maxAllowedDivergence = 0.35 * (1.1 - sensitivity) * (2 - tight)
    local missMargin = 0.9 - (1 - tight) * 0.05

    -- ── NEW: Backwards-upward arc detection ────────────────────────────
    -- Ball velocity points AWAY from player (upward/backward arc) yet
    -- the predicted closest approach still reaches you → risky curve.
    local isMovingAway = currentDot < -0.1
    local isApproaching = currentDot > 0.1

    if isMovingAway and threatening then
        -- Ball is heading away (backwards-upward) but will loop close
        return true
    end

    -- ── Original generic curve check (forward arc / lateral curl) ─────
    if not threatening and (minPredictedDistance > distance * missMargin) and (currentDot < maxAllowedDivergence) then
        return true
    end

    -- ── Sharp acceleration divergence (any direction) ─────────────────
    local accelMag = props.smooth_accel_vec.Magnitude
    if isApproaching and not threatening and accelMag > 50 then
        local accelDir = props.smooth_accel_vec / accelMag
        local lateralComponent = (accelDir - velocityDir * accelDir:Dot(velocityDir)).Magnitude
        if lateralComponent > 0.3 * tight and minPredictedDistance > distance * 0.6 then
            return true
        end
    end

    return false
end

if workspace:FindFirstChild('Balls') then
    workspace.Balls.ChildRemoved:Connect(function(child)
        Stellar.detection.__kinematic_properties[child] = nil
    end)
end

-- Backwards-upward arc: ball moving away from player while looping back
function Stellar.detection.is_backwards_upward_curve(ball)
    if not ball then return false end
    if not Stellar.__properties.__predictive_anti_curve_enabled then return false end

    local zoomies = ball:FindFirstChild("zoomies")
    if not zoomies then return false end

    local velocity = zoomies.VectorVelocity
    local speed = velocity.Magnitude
    if speed < 30 then return false end

    local char = LocalPlayer.Character
    local playerPart = char and char.PrimaryPart
    if not playerPart then return false end

    local toPlayer = playerPart.Position - ball.Position
    local distance = toPlayer.Magnitude
    if distance <= 6 then return false end

    local toPlayerDir = toPlayer / distance
    local velDir = velocity / speed
    local velocityDir = velDir
    local dot = toPlayerDir:Dot(velDir)

    -- ① Ball moving away from the player
    if dot >= -0.1 then return false end

    -- ② Vertical component is significant (upward arc)
    local upness = velocityDir.Y
    if velocityDir.Y < 0.15 then return false end

    -- ③ Within reasonable threat range (< 60 studs)
    if distance > 60 then return false end

    return true
end

function Stellar.detection.get_closest_player_distance()
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return math.huge end
    
    local myPos = char.PrimaryPart.Position
    local minDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local otherChar = player.Character
            if otherChar and otherChar.PrimaryPart then
                local dist = (myPos - otherChar.PrimaryPart.Position).Magnitude
                if dist < minDist then minDist = dist end
            end
        end
    end
    
    local alive = workspace:FindFirstChild("Alive")
    if alive then
        for _, character in ipairs(alive:GetChildren()) do
            if character:IsA("Model") and character ~= LocalPlayer.Character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (myPos - hrp.Position).Magnitude
                    if dist < minDist then minDist = dist end
                end
            end
        end
    end
    
    return minDist
end

function Stellar.detection.is_close_range_combat()
    local closestPlayerDist = Stellar.detection.get_closest_player_distance()
    return closestPlayerDist < 25
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLEAN FAST AUTOPARRY
-- Based on the ORIGINAL Stellar logic that worked
-- Only changes: per-ball lock + slightly earlier trigger + CFrame caching
-- No backup re-fires, no prediction math, no aggressive re-arm
-- ═══════════════════════════════════════════════════════════════════════════════

Stellar.autoparry = {}
	local parryFlag = false
	local autoSpamActive = false
	local lastCycle = 0
	local firedOnBall = setmetatable({}, { __mode = "k" })

	local CURVE_T = {
		[1] = function(root, target, cam) return cam.CFrame end,
		[2] = function(root, target) -- Random
			local dir = (target - root.Position).Unit
			local off, n = Vector3.new(), 0
			repeat
				off = Vector3.new(math.random(-4000,4000), math.random(-4000,4000), math.random(-4000,4000))
				n = n + 1
			until dir:Dot((target + off - root.Position).Unit) < 0.95 or n > 10
			return CFrame.new(root.Position, target + off)
		end,
		[3] = function(root, target) return CFrame.new(root.Position, target + Vector3.new(0,5,0)) end,
		[4] = function(root, target, cam) return CFrame.new(cam.CFrame.Position,
			root.Position + (root.Position - target).Unit * 10000 + Vector3.new(0,1000,0)) end,
		[5] = function(root, target) return CFrame.new(root.Position, target + Vector3.new(0,-9e18,0)) end,
		[6] = function(root, target) return CFrame.new(root.Position, target + Vector3.new(0, 9e18,0)) end,
		[7] = function(root, target, cam) -- RandomTarget
			local pos = {}
			for _, m in ipairs(Alive:GetChildren()) do
				if m ~= LocalPlayer.Character and m.PrimaryPart then
					pos[#pos+1] = m.PrimaryPart.Position
				end
			end
			if #pos > 0 then return CFrame.new(root.Position, pos[math.random(1,#pos)]) end
			return cam.CFrame
		end,
		[8] = function(root, _, cam) return CFrame.new(root.Position, root.Position - cam.CFrame.RightVector * 10000) end,
		[9] = function(root, _, cam) return CFrame.new(root.Position, root.Position + cam.CFrame.RightVector * 10000) end,
	}

	-- Real-ball cache (event-driven, zero per-frame scans)
	local realBalls = {}
	do
		local bf = workspace:FindFirstChild("Balls")
		if bf then
			local add = function(b)
				if b:IsA("BasePart") and b:GetAttribute("realBall") then realBalls[b] = true end
			end
			for _, b in ipairs(bf:GetChildren()) do add(b) end
			bf.ChildAdded:Connect(add)
			bf.ChildRemoved:Connect(function(b) realBalls[b] = nil end)
		end
	end

	LocalPlayer.CharacterAdded:Connect(function()
		for b in pairs(firedOnBall) do firedOnBall[b] = nil end
		table.clear(parryLockUntil)
		parryFlag = false
	end)

	-- Per-ball lock (SAME semantics as before — no refire risk)
	local function lockBall(ball)
		if not ball then return end
		firedOnBall[ball] = true
		local conn
		conn = ball:GetAttributeChangedSignal("target"):Connect(function()
			if ball:GetAttribute("target") ~= LocalPlayer.Name then
				firedOnBall[ball] = nil
				if conn then conn:Disconnect() end
			end
		end)
		local dc
		dc = ball.Destroying:Connect(function()
			firedOnBall[ball] = nil
			if conn then conn:Disconnect() end
			if dc then dc:Disconnect() end
		end)
	end

	function Stellar.autoparry.start()
		local props = Stellar.__properties
		Stellar.autoparry.stop()
		Stellar.ability_detections.initialize()
		Stellar.dribble_detection.start()

		parryFlag = false
		autoSpamActive = false
		lastCycle = os.clock()

		props.__connections.__combat = RunService.PreSimulation:Connect(function()
			if not props.__autoparry_enabled then return end
			if autoSpamActive then return end

			local char = LocalPlayer.Character
			local root = char and char.PrimaryPart
			if not root then return end
			if root:FindFirstChild("SingularityCape") then return end

			local det = Stellar.__config.__detections
			if det.__infinity      and props.__infinity_active      then return end
			if det.__deathslash    and props.__deathslash_active    then return end
			if det.__timehole      and props.__timehole_active      then return end
			if det.__slashesoffury and props.__slashesoffury_active then return end

			local cam = workspace.CurrentCamera
			local camCF = cam.CFrame            -- cached once per frame
			local myPos = root.Position
			local myName = LocalPlayer.Name

			-- Dribble state
			local dribbleActive = det.__dribble and props.__dribble_active
			if props.__dribble_was_active and not dribbleActive then
				props.__dribble_was_active = false
				props.__dribble_exit_time = os.clock()
			end
			local postDribbleWindow = props.__dribble_exit_time
				and (os.clock() - props.__dribble_exit_time < 0.2)

			local pingS = (tonumber(getgenv()._ZX_PingCache or props.__cached_ping) or 50) / 1000
			local rangeScale = math.clamp(props.__parry_range, 1, 20)
			local accuracyMod = (props.__accuracy / 100) * props.__divisor_multiplier

			local frameCF = nil   -- lazy: computed only once per frame on first fire

			
			for ball in pairs(realBalls) do
				if not ball.Parent then continue end
				if firedOnBall[ball] then continue end
				local lockUntil = parryLockUntil[ball]
				if lockUntil then
					if os.clock() < lockUntil then continue end
					parryLockUntil[ball] = nil
				end

				local zoomies = ball:FindFirstChild("zoomies")
				if not zoomies then continue end

				local velocity = zoomies.VectorVelocity
				local ballSpeed = velocity.Magnitude

				-- Tornado
				local aero = ball:FindFirstChild("AeroDynamicSlashVFX")
				if aero then
					props.__tornado_time = os.clock()
					aero:Destroy()
				end
				local tor = Runtime and Runtime:FindFirstChild("Tornado")
				if tor then
					local dur = tor:GetAttribute("TornadoTime") or 1
					if (os.clock() - props.__tornado_time) < (dur + 0.314159) then continue end
				end

				-- target-attr tracking (once per ball)
				if not ball:GetAttribute("Stellar_TargetTracked") then
					ball:SetAttribute("Stellar_TargetTracked", true)
					ball:GetAttributeChangedSignal("target"):Connect(function()
						parryFlag = false
					end)
				end

				local currentTarget = ball:GetAttribute("target")
				local isTargeted = (currentTarget == myName)
				if not isTargeted and not dribbleActive and not postDribbleWindow then continue end
				if parryFlag then continue end

				local toPlayer = myPos - ball.Position
				local distance = toPlayer.Magnitude

				
				local speedBonus = (ballSpeed > 150) and math.sqrt(ballSpeed - 150) * 0.001 or 0
				local speedFactor = 1 + speedBonus
				local rangeMul = (0.20 + rangeScale * 0.08) * speedFactor
				local baseWindow = math.max(rangeMul + pingS * 0.7, 0.05)
				local reach = (baseWindow * math.max(ballSpeed, 20) * accuracyMod)
					+ (rangeScale * 1.3 * speedFactor)

				-- ── Approach ratio ─────────────────────────────────────
				local approachRatio = (ballSpeed > 5)
					and math.clamp(velocity:Dot(toPlayer.Unit) / ballSpeed, 0.1, 1.0)
					or 1.0
				reach = reach * approachRatio

				-- ── Backwards-upward arc ───────────────────────────────
				local isBackwardUp = Stellar.detection.is_backwards_upward_curve(ball)
				if isBackwardUp then
					reach = reach * 0.35
				end

				if distance > reach * 1.5 then continue end

				-- ── Anti-curve gate ────────────────────────────────────
				local isCurved = Stellar.detection.is_curved(ball)
				local curveTighten = 1.0
				if isCurved then
					if isBackwardUp then
						curveTighten = math.max(0.6 * Stellar.detection.get_curve_tighten(), 0.45)
						reach = reach * curveTighten
					else
						continue
					end
				end

				local approachDir = (distance > 0) and (toPlayer / distance) or Vector3.new()
				local approachSpeed = velocity:Dot(approachDir)
				local tti = (approachSpeed > 0.1) and (distance / approachSpeed) or math.huge
				local triggerWindow = baseWindow * curveTighten
				local trigger = (approachSpeed > 0.1)
					and (tti <= triggerWindow or distance <= reach)

				if isTargeted and not trigger and distance <= reach * 0.7 then
					trigger = true
				end
				if not trigger then continue end
                    if Stellar.preclick and Stellar.preclick.track_speed then
                        Stellar.preclick.track_speed(currentTarget, ballSpeed)
                    end

                    if isTargeted then

                        -- Cooldown protection
                        if det.__cooldown_protection then
                            local hotbar = LocalPlayer:FindFirstChild("PlayerGui")
                            local bi = hotbar and hotbar:FindFirstChild("Hotbar") and hotbar.Hotbar:FindFirstChild("Block")
                            local cd = bi and bi:FindFirstChild("UIGradient")
                            if cd and cd.Offset.Y < 0.4 then
                                local py = ReplicatedStorage:FindFirstChild("Remotes")
                                local press = py and py:FindFirstChild("AbilityButtonPress")
                                if press then
                                    press:Fire()
                                    parryFlag = true
                                    lastCycle = os.clock()
                                    continue
                                end
                            end
                        end

                        -- Auto ability
                        if getgenv().AutoAbility or props.__auto_ability_enabled then
                            local hotbar = LocalPlayer:FindFirstChild("PlayerGui")
                            local ai = hotbar and hotbar:FindFirstChild("Hotbar") and hotbar.Hotbar:FindFirstChild("Ability")
                            local acd = ai and ai:FindFirstChild("UIGradient")
                            if acd and acd.Offset.Y == 0.5 then
                                local abs = char:FindFirstChild("Abilities")
                                if abs then
                                    for _, n in ipairs({"Raging Deflection","Rapture","Calming Deflection","Aerodynamic Slash","Fracture","Death Slash"}) do
                                        local ab = abs:FindFirstChild(n)
                                        if ab and ab.Enabled then
                                            parryFlag = true
                                            lastCycle = os.clock()
                                            local py = ReplicatedStorage:FindFirstChild("Remotes")
                                            if py and py:FindFirstChild("AbilityButtonPress") then
                                                py.AbilityButtonPress:Fire()
                                                task.delay(2.432, function()
                                                    local ds = py:FindFirstChild("DeathSlashShootActivation")
                                                    if ds then ds:FireServer(true) end
                                                end)
                                            end
                                            continue
                                        end
                                    end
                                end
                            end
                        end

                        if dribbleActive and det.__dribble then return end

                        if not frameCF then
                            local closest = Stellar.player.get_closest_to_cursor()
                            local target = (closest and closest:FindFirstChild("HumanoidRootPart"))
                                and closest.HumanoidRootPart.Position
                                or (myPos + camCF.LookVector * 100)
                            frameCF = (CURVE_T[props.__curve_mode] or CURVE_T[1])(root, target, cam)
                        end

                        if getgenv().AutoParryMode == "Keypress" then
                            Stellar.parry.keypress(frameCF)
                        else
                            Stellar.parry.execute_action(frameCF)
                        end

                        lockBall(ball)
                        -- 🔒 time-lock: covers server round-trip (ping) + fast-ball window
                        local lockDur = 0.08 + pingS * 0.6
                        if ballSpeed > 250 then lockDur += (ballSpeed - 250) * 0.00025 end
                        parryLockUntil[ball] = os.clock() + math.clamp(lockDur, 0.08, 0.30)
                        getgenv()._Stellar_LastAutoParry = os.clock()

                        parryFlag = true
                        lastCycle = os.clock()

                        if postDribbleWindow then
                            props.__dribble_exit_time = nil
                        end
                    end
				
			end
		end)
	end

	function Stellar.autoparry.stop()
		local props = Stellar.__properties
		if props.__connections.__combat then
			props.__connections.__combat:Disconnect()
			props.__connections.__combat = nil
		end
		parryFlag = false
		for b in pairs(firedOnBall) do firedOnBall[b] = nil end
		table.clear(parryLockUntil)
	end
LocalPlayer.CharacterAdded:Connect(function()
	for b in pairs(firedOnBall) do firedOnBall[b] = nil end
	table.clear(parryLockUntil)
	parryFlag = false
end)

-- Instant Triggerbot Subsystem
Stellar.triggerbot = {}
function Stellar.triggerbot.trigger(ball)
	if Stellar.__triggerbot.__is_parrying or Stellar.__triggerbot.__parries > Stellar.__triggerbot.__max_parries then return end
	if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart:FindFirstChild('SingularityCape') then return end
	if os.clock() - (getgenv()._Stellar_LastAutoParry or 0) < 0.1 then return end   -- 🛡 skip if autoparry just fired
	Stellar.__triggerbot.__is_parrying = true
	Stellar.__triggerbot.__parries = Stellar.__triggerbot.__parries + 1
	Stellar.animation.play_grab_parry()
	Stellar.parry.execute()
	getgenv()._Stellar_LastAutoParry = os.clock()                                    -- 🛡 mark so autoparry won't double it
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

-- ═══════════════════════════════════════════════════════════════════════════
	-- AZURE-STYLE AUTO SPAM · FINAL (lean)
	--   Fires straight camera CFrame (no curve) · closed-loop win detection ·
	--   FPS-adaptive burst · hysteresis range · batched accounting ·
	--   target-change reaction · packet budget
	-- ═══════════════════════════════════════════════════════════════════════════

	-- ── Spam-local state ──────────────────────────────────────────────────────
	local AS_engaged = false          -- hysteresis latch
	local AS_lastSuccess = 0          -- last confirmed win (tick)
	local AS_escalation = 0           -- silence-driven burst bump
	local AS_firesThisSecond = 0      -- packet budget
	local AS_secondMark = 0
	local AS_BUDGET = 300             -- max remote fires / sec
	local AS_reactions = {}           -- per-ball target-change conns
	local E_inContact = false
	local E_lastContact = 0

	local function AS_budgetAllows()
		local now = tick()
		if now - AS_secondMark >= 1 then
			AS_secondMark = now
			AS_firesThisSecond = 0
		end
		return AS_firesThisSecond < AS_BUDGET
	end

	-- ── Batched burst firing (single accounting decrement per burst) ──────────
	local function AS_fire_burst(cf, count)
		local props = Stellar.__properties
		local keypress = (getgenv().AutoSpamMode or getgenv().AutoParryMode) == "Keypress"
		for _ = 1, count do
			if keypress then
				fireParryInput()
			else
				fireParry(cf)
			end
		end
		AS_firesThisSecond += count
		props.__parries += count
		task.delay(0.2, function()
			props.__parries = math.max(0, props.__parries - count)
		end)
	end

	-- ── Cached realBall list ──────────────────────────────────────────────────
	local AS_ballCache = {}
	do
		local ballsFolder = workspace:FindFirstChild("Balls")
		if ballsFolder then
			for _, b in ipairs(ballsFolder:GetChildren()) do
				if b:IsA("BasePart") and b:GetAttribute("realBall") then
					AS_ballCache[b] = true
				end
			end
			ballsFolder.ChildAdded:Connect(function(b)
				if b:IsA("BasePart") and b:GetAttribute("realBall") then
					AS_ballCache[b] = true
				end
			end)
			ballsFolder.ChildRemoved:Connect(function(b)
				AS_ballCache[b] = nil
				if AS_reactions[b] then
					AS_reactions[b]:Disconnect()
					AS_reactions[b] = nil
				end
			end)
		end
	end

	-- ── Target-change reaction (fires before PreSimulation on tag swap) ───────
	local function AS_attach_reaction(ball, props)
		if AS_reactions[ball] then return end
		AS_reactions[ball] = ball:GetAttributeChangedSignal("target"):Connect(function()
			if not props.__auto_spam_enabled then return end
			if ball:GetAttribute("target") ~= LocalPlayer.Name then return end
			if not ball:FindFirstChild("zoomies") then return end
			local char = LocalPlayer.Character
			local root = char and char.PrimaryPart
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not root or not hum or hum.Health <= 0 then return end
			if (root.Position - ball.Position).Magnitude > math.max(props.__spam_threshold * 2.5, 35) then return end
			if not AS_budgetAllows() then return end
			AS_engaged = true
			AS_fire_burst(workspace.CurrentCamera.CFrame, math.min(props.__burst_multiplier or 1, 2))
		end)
	end

	Stellar.autospam = {}

	function Stellar.autospam.start()
		local props = Stellar.__properties
		Stellar.autospam.stop()

		AS_engaged = false
		AS_lastSuccess = 0
		AS_escalation = 0
		AS_firesThisSecond = 0
		AS_secondMark = tick()

		-- Closed loop: confirm our wins, reset escalation on success
		props.__connections.__spam_win = ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, root)
			if root and root.Parent == LocalPlayer.Character then
				AS_lastSuccess = tick()
				AS_escalation = 0
			end
		end)

		for ball in pairs(AS_ballCache) do
			AS_attach_reaction(ball, props)
		end

		props.__connections.__autospam = RunService.PreSimulation:Connect(function()
			if not props.__auto_spam_enabled then return end
			if props.__slashesoffury_active then return end

			local character = LocalPlayer.Character
			local root = character and character.PrimaryPart
			if not root then return end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end
			if root:FindFirstChild("SingularityCape") then return end

			-- Nearest live ball from cache
			local myPos = root.Position
			local ball, zoomies, nearest = nil, nil, math.huge
			for b in pairs(AS_ballCache) do
				if b.Parent then
					local z = b:FindFirstChild("zoomies")
					if z and z.VectorVelocity.Magnitude > 0 then
						local d = (myPos - b.Position).Magnitude
						if d < nearest then
							nearest = d
							ball, zoomies = b, z
						end
					end
				end
			end
			if not ball then return end

			local velocity = zoomies.VectorVelocity
			local speed = velocity.Magnitude
			local ballTarget = ball:GetAttribute("target")
			if not ballTarget then return end

			local closest = Stellar.player.get_closest()
			if not closest or not closest.PrimaryPart then return end

			local toBall = myPos - ball.Position
			local distance = toBall.Magnitude
			if distance == 0 then return end

			local enemyPos = closest.PrimaryPart.Position
			local enemyDist = (enemyPos - myPos).Magnitude

			-- Far-range gate (Azure)
			if ballTarget == LocalPlayer.Name and enemyDist > props.__spam_threshold and distance > props.__spam_threshold then
				AS_engaged = false
				autoSpamActive = false
				return
			end

			-- ── Azure spam_service envelope ────────────────────────────────────
			local E = 1
			local now = tick()

			if enemyDist <= 3 then
				E_inContact = true
			elseif E_inContact and enemyDist > 3.3 then
				E_inContact = false
				E_lastContact = now
			end

			if (not E_inContact) and (now - E_lastContact >= 1.5) then
				local nDir = enemyPos - myPos
				nDir = (nDir.Magnitude > 0) and nDir.Unit or Vector3.new()

				local myMove = humanoid.MoveDirection
				if myMove.Magnitude > 0.2 and myMove:Dot(nDir) < -0.4 then E = 10 end

				local eHum = closest:FindFirstChildOfClass("Humanoid")
				local eMove = eHum and eHum.MoveDirection or Vector3.new()
				if eMove.Magnitude > 0.2 and eMove:Dot(-nDir) < -0.4 then E = 10 end
			end

			local ping = tonumber(getgenv()._ZX_PingCache or props.__cached_ping) or 50
			local range = math.min((ping * 0.7) + math.min(speed / (E * 1.2), 80), props.__spam_threshold)
			if enemyDist > range then return end

			-- Post-hit approach penalty (faster re-arm than stock Azure)
			local dirToBall = toBall / distance
			local approach = dirToBall:Dot(velocity.Unit)
			local penalty = math.clamp(math.clamp(-approach, 0, 1) * (speed / 30), 0, 6)

			local scale = math.clamp((props.__spam_threshold / 11) * (props.__auto_spam_distance_multiplier or 1), 0.5, 2.5)
			local spamRange = (range - penalty) * scale

			-- ── Hysteresis: outer edge 1.2x, inner edge exact ──────────────────
			if AS_engaged then
				if distance > spamRange * 1.2 then
					AS_engaged = false
				end
			else
				if distance <= spamRange then
					AS_engaged = true
				end
			end

			if not AS_engaged then
				autoSpamActive = false
				return
			end

			if props.__parries <= 1 then return end
			if character:GetAttribute("Pulsed") then return end
			if not AS_budgetAllows() then return end

			autoSpamActive = true
			parryFlag = false

			-- ── Adaptive burst: slider floor + silence escalation + low-FPS ────
			local burst = math.max(1, math.ceil(props.__burst_multiplier or 1))

			if now - AS_lastSuccess > (0.3 + AS_escalation * 0.15) then
				AS_escalation = math.min(AS_escalation + 1, 3)
			end
			burst = burst + AS_escalation

			local fps = props.__cached_fps or 60
			if fps < 90 then
				burst = burst + 1
			end
			burst = math.min(burst, 4)

			-- Straight camera CFrame — no curve on spam packets
			AS_fire_burst(workspace.CurrentCamera.CFrame, burst)

			if props.__play_animation then
				Stellar.animation.play_grab_parry()
			end
		end)
	end

	function Stellar.autospam.stop()
		local props = Stellar.__properties
		if props.__connections.__autospam then
			props.__connections.__autospam:Disconnect()
			props.__connections.__autospam = nil
		end
		if props.__connections.__spam_win then
			props.__connections.__spam_win:Disconnect()
			props.__connections.__spam_win = nil
		end
		for ball, conn in pairs(AS_reactions) do
			conn:Disconnect()
			AS_reactions[ball] = nil
		end
		AS_engaged = false
		autoSpamActive = false
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- PRECLICK SYSTEM (Sapphire-style, with configurable sliders)
-- Tracks ball speeds when NOT targeted at you, then auto-parries when that
-- player gets eliminated while a fast ball was heading toward you.
-- ═══════════════════════════════════════════════════════════════════════════════

local PreclickConfig = {
    enabled = false,
    max_kill_distance = 100,
    speed_threshold = 800,
    random_delay_min = 120,   -- ms
    random_delay_max = 140,   -- ms
    cooldown = 0.4,
}

local PreclickState = {
    sender = nil,
    speeds = {},
    last_parry = 0,
    connection = nil,
    max_samples = 15,
    sender_position = nil,   -- last known position of sender
}

local function preclick_reset()
    PreclickState.sender = nil
    PreclickState.speeds = {}
    PreclickState.sender_position = nil
end

local function startPreclickTracking()
    if PreclickState.connection then return end

    PreclickState.connection = RunService.Heartbeat:Connect(function()
        if not PreclickConfig.enabled then return end
        if not Stellar.__properties.__autoparry_enabled then return end

        local now = tick()
        if now - PreclickState.last_parry < PreclickConfig.cooldown then return end

        local sender = PreclickState.sender
        if not sender or sender == "" then return end

        local alive = workspace:FindFirstChild("Alive")
        if not alive then
            preclick_reset()
            return
        end

        -- Track sender's last known position while alive
        local senderModel = alive:FindFirstChild(sender)
        if senderModel then
            local hrp = senderModel:FindFirstChild("HumanoidRootPart")
            if hrp and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                PreclickState.sender_position = hrp.Position
            end
            return  -- still alive, don't fire
        end

        -- Sender was eliminated — check if they had a fast ball
        local speeds = PreclickState.speeds[sender]
        if not speeds or #speeds == 0 then
            preclick_reset()
            return
        end

        -- Check if ANY sample was >= speed threshold
        local fastEnough = false
        for _, s in ipairs(speeds) do
            if s >= PreclickConfig.speed_threshold then
                fastEnough = true
                break
            end
        end

        if not fastEnough then
            preclick_reset()
            return
        end

        -- Distance check: were they close enough when they died?
        if PreclickState.sender_position and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local myPos = LocalPlayer.Character.PrimaryPart.Position
            local dist = (myPos - PreclickState.sender_position).Magnitude
            if dist > PreclickConfig.max_kill_distance then
                preclick_reset()
                return
            end
        end

        -- All checks passed — fire parry
        PreclickState.last_parry = now

        local delay = math.random(
            PreclickConfig.random_delay_min,
            PreclickConfig.random_delay_max
        ) / 1000

        task.delay(delay, function()
            pcall(function()
                if Stellar and Stellar.parry then
                    if getgenv().AutoParryMode == "Keypress" then
                        Stellar.parry.keypress()
                    else
                        Stellar.parry.execute_action()
                    end
                end
            end)
        end)

        preclick_reset()
    end)
end

local function stopPreclickTracking()
    if PreclickState.connection then
        PreclickState.connection:Disconnect()
        PreclickState.connection = nil
    end
    preclick_reset()
    PreclickState.last_parry = 0
end

-- Called by autoparry each frame for every ball, regardless of target
local function preclick_trackSpeed(ballTarget, speed)
    if not PreclickConfig.enabled then return end
    if not ballTarget or ballTarget == "" then return end
    if ballTarget == LocalPlayer.Name then return end

    PreclickState.sender = ballTarget

    if not PreclickState.speeds[ballTarget] then
        PreclickState.speeds[ballTarget] = {}
    end

    table.insert(PreclickState.speeds[ballTarget], speed)
    if #PreclickState.speeds[ballTarget] > PreclickState.max_samples then
        table.remove(PreclickState.speeds[ballTarget], 1)
    end
end

Stellar.preclick = {
    enabled = false,

    start = function()
        if Stellar.preclick.enabled then return end
        Stellar.preclick.enabled = true
        PreclickConfig.enabled = true
        startPreclickTracking()
    end,

    stop = function()
        if not Stellar.preclick.enabled then return end
        Stellar.preclick.enabled = false
        PreclickConfig.enabled = false
        stopPreclickTracking()
    end,

    set_max_distance = function(distance)
        PreclickConfig.max_kill_distance = math.max(10, distance)
    end,

    set_speed_threshold = function(threshold)
        PreclickConfig.speed_threshold = math.max(100, threshold)
    end,

    set_delay = function(min_ms, max_ms)
        PreclickConfig.random_delay_min = math.max(10, min_ms)
        PreclickConfig.random_delay_max = math.max(PreclickConfig.random_delay_min, max_ms)
    end,

    track_speed = preclick_trackSpeed,
}

Stellar.hitsounds = {
	__sound_instance = nil,
	__ids = {
		["Medal"]            = "rbxassetid://6607336718",
		["Fatality"]         = "rbxassetid://6607113255",
		["Skeet"]            = "rbxassetid://6607204501",
		["Switches"]         = "rbxassetid://6607173363",
		["Rust Headshot"]    = "rbxassetid://138750331387064",
		["Neverlose Sound"]  = "rbxassetid://110168723447153",
		["Bubble"]           = "rbxassetid://6534947588",
		["Laser"]            = "rbxassetid://7837461331",
		["Steve"]            = "rbxassetid://4965083997",
		["Call of Duty"]     = "rbxassetid://5952120301",
		["Bat"]              = "rbxassetid://3333907347",
		["TF2 Critical"]     = "rbxassetid://296102734",
		["Saber"]            = "rbxassetid://8415678813",
		["Bameware"]         = "rbxassetid://3124331820"
	}
}

function Stellar.hitsounds.init()
	if not Stellar.hitsounds.__sound_instance then
		local snd = Instance.new("Sound")
		snd.Name = "StellarHitSound"
		snd.Volume = Stellar.__properties.__hitsound_volume
		snd.SoundId = Stellar.hitsounds.__ids[Stellar.__properties.__hitsound_type] or ""
		snd.Parent = cloneref(game:GetService("SoundService"))
		Stellar.hitsounds.__sound_instance = snd
	end

	pcall(function()
		local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
		local parrySuccess = remotes and remotes:FindFirstChild("ParrySuccess")
		if parrySuccess then
			Stellar.__properties.__connections.__hitsound_event = parrySuccess.OnClientEvent:Connect(function()
				if Stellar.__properties.__hitsound_enabled and Stellar.hitsounds.__sound_instance then
					Stellar.hitsounds.__sound_instance:Play()
				end
			end)
		end
	end)
end

function Stellar.hitsounds.set_sound(name)
	Stellar.__properties.__hitsound_type = name
	if Stellar.hitsounds.__sound_instance and Stellar.hitsounds.__ids[name] then
		Stellar.hitsounds.__sound_instance.SoundId = Stellar.hitsounds.__ids[name]
	end
end

function Stellar.hitsounds.set_volume(val)
	Stellar.__properties.__hitsound_volume = val
	if Stellar.hitsounds.__sound_instance then
		Stellar.hitsounds.__sound_instance.Volume = val
	end
end

Stellar.sound_controller = {
	__sound_instance = nil,
	__tracks = {
		["Eeyuh"]                             = "rbxassetid://16190782181",
		["Low Cortisol"]                      = "rbxassetid://110919391228823",
		["Bounce"]                            = "rbxassetid://5907568539",
		["Misery"]                            = "rbxassetid://116571091072402",
		["ODETARI"]                           = "rbxassetid://5877731483",
		["PIXY"]                              = "rbxassetid://71105881541052",
		["Erwachen"]                          = "rbxassetid://124853612881772",
		["Grasp the Light"]                   = "rbxassetid://89549155689397",
		["Beyond the Shadows"]                = "rbxassetid://120729792529978",
		["Rise to the Horizon"]               = "rbxassetid://72573266268313",
		["Echoes of the Candy Kingdom"]       = "rbxassetid://103040477333590",
		["Speed"]                             = "rbxassetid://125550253895893",
		["Lo-fi Chill A"]                     = "rbxassetid://9043887091",
		["Lo-fi Ambient"]                     = "rbxassetid://129775776987523",
		["Tears in the Rain"]                 = "rbxassetid://129710845038263"
	}
}

function Stellar.sound_controller.init()
	if not Stellar.sound_controller.__sound_instance then
		local snd = Instance.new("Sound")
		snd.Name = "StellarBGM"
		snd.Volume = Stellar.__properties.__bgm_volume
		snd.Looped = Stellar.__properties.__bgm_loop
		snd.Parent = cloneref(game:GetService("SoundService"))
		Stellar.sound_controller.__sound_instance = snd
	end
end

function Stellar.sound_controller.play(track_name)
	Stellar.sound_controller.init()
	local sound_id = Stellar.sound_controller.__tracks[track_name]
	if sound_id and Stellar.sound_controller.__sound_instance then
		Stellar.sound_controller.__sound_instance:Stop()
		Stellar.sound_controller.__sound_instance.SoundId = sound_id
		Stellar.sound_controller.__sound_instance.Volume = Stellar.__properties.__bgm_volume
		Stellar.sound_controller.__sound_instance.Looped = Stellar.__properties.__bgm_loop
		Stellar.sound_controller.__sound_instance:Play()
	end
end

function Stellar.sound_controller.stop()
	if Stellar.sound_controller.__sound_instance then
		Stellar.sound_controller.__sound_instance:Stop()
	end
end

Stellar.emotes = {
	__storage = {},
	__names = {}
}

function Stellar.emotes.scan()
	table.clear(Stellar.emotes.__storage)
	table.clear(Stellar.emotes.__names)
	
	local misc_folder = ReplicatedStorage:FindFirstChild("Misc")
	local emotes_folder = misc_folder and misc_folder:FindFirstChild("Emotes")
	
	if emotes_folder then
		for _, child in ipairs(emotes_folder:GetChildren()) do
			if child:IsA("Animation") and child:GetAttribute("EmoteName") then
				local name = child:GetAttribute("EmoteName")
				Stellar.emotes.__storage[name] = child
				table.insert(Stellar.emotes.__names, name)
			end
		end
	end
	table.sort(Stellar.emotes.__names)
end

function Stellar.emotes.play(emote_name)
	local anim_asset = Stellar.emotes.__storage[emote_name]
	if not anim_asset then return end
	
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if not animator then return end
	
	if Stellar.__properties.__active_emote_track then
		Stellar.__properties.__active_emote_track:Stop()
		Stellar.__properties.__active_emote_track:Destroy()
		Stellar.__properties.__active_emote_track = nil
	end
	
	local ok, track = pcall(function() return animator:LoadAnimation(anim_asset) end)
	if ok and track then
		Stellar.__properties.__active_emote_track = track
		Stellar.__properties.__selected_emote = emote_name
		track:Play()
	end
end

function Stellar.emotes.stop()
	if Stellar.__properties.__active_emote_track then
		Stellar.__properties.__active_emote_track:Stop()
		Stellar.__properties.__active_emote_track:Destroy()
		Stellar.__properties.__active_emote_track = nil
	end
end

function Stellar.emotes.start_loop()
	if Stellar.__properties.__connections.__emotes_loop then
		Stellar.__properties.__connections.__emotes_loop:Disconnect()
	end
	
	Stellar.__properties.__connections.__emotes_loop = RunService.Heartbeat:Connect(function()
		if not Stellar.__properties.__emotes_enabled then return end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		local speed = hrp.AssemblyLinearVelocity.Magnitude
		if speed > 30 then
			if Stellar.__properties.__active_emote_track then
				Stellar.emotes.stop()
			end
		else
			if not Stellar.__properties.__active_emote_track and Stellar.__properties.__selected_emote ~= "" then
				Stellar.emotes.play(Stellar.__properties.__selected_emote)
			end
		end
	end)
end
Stellar.device_spoofer = {
	__enabled = false,
	__device  = "PC",
	__hooked  = false,
	__armed   = false,
}

local DEVICE_PROPS = {
	["PC"]      = { MouseEnabled = true,  KeyboardEnabled = true,  TouchEnabled = false, GamepadEnabled = false },
	["Phone"]   = { MouseEnabled = false, KeyboardEnabled = false, TouchEnabled = true,  GamepadEnabled = false },
	["Tablet"]  = { MouseEnabled = false, KeyboardEnabled = false, TouchEnabled = true,  GamepadEnabled = false },
	["Console"] = { MouseEnabled = false, KeyboardEnabled = false, TouchEnabled = false, GamepadEnabled = true  },
}

local SPOOFER_FILE      = "StellarDeviceSpoofer.cfg"
local SPOOFER_STUB_FILE = "StellarDeviceSpoofer.stub.lua"

local UI_PROTECTED_KEYS = { MouseEnabled = true, KeyboardEnabled = true, TouchEnabled = true, GamepadEnabled = true }
local _checkcaller = checkcaller or function() return false end

-- Stub injected via queue_on_teleport (self re-arming, UI-scale safe)
local SPOOFER_STUB = [==[
task.spawn(function()
	local cloneref        = cloneref or function(o) return o end
	local newcclosure     = newcclosure or function(f) return f end
	local getrawmetatable = getrawmetatable or function() return {} end
	local setreadonly     = setreadonly or function() end
	local is_caller_ours  = checkcaller or function() return false end
	local HttpService     = cloneref(game:GetService("HttpService"))
	local UISvc           = cloneref(game:GetService("UserInputService"))

	-- ★ Snapshot REAL device BEFORE hooking (UI scale protection)
	if not getgenv()._ZX_REAL_DEVICE_STATE then
		pcall(function()
			getgenv()._ZX_REAL_DEVICE_STATE = {
				Touch = UISvc.TouchEnabled, Mouse = UISvc.MouseEnabled,
				Keyboard = UISvc.KeyboardEnabled, Gamepad = UISvc.GamepadEnabled,
			}
		end)
	end

	local function rearm()
		pcall(function()
			if queue_on_teleport and isfile and isfile("StellarDeviceSpoofer.stub.lua") then
				queue_on_teleport(readfile("StellarDeviceSpoofer.stub.lua"))
			end
		end)
	end

	-- Main script already hooked this session → skip, but stay armed
	if getgenv()._ZX_SPOOF_HOOK_ACTIVE then rearm() return end

	local cfg = nil
	pcall(function()
		if isfile and isfile("StellarDeviceSpoofer.cfg") and readfile then
			cfg = HttpService:JSONDecode(readfile("StellarDeviceSpoofer.cfg"))
		end
	end)
	if not cfg or not cfg.enabled or not cfg.device then
		pcall(function()
			if delfile and isfile and isfile("StellarDeviceSpoofer.stub.lua") then delfile("StellarDeviceSpoofer.stub.lua") end
		end)
		return
	end

	local DEVICE_PROPS = {
		["PC"]      = { MouseEnabled = true,  KeyboardEnabled = true,  TouchEnabled = false, GamepadEnabled = false },
		["Phone"]   = { MouseEnabled = false, KeyboardEnabled = false, TouchEnabled = true,  GamepadEnabled = false },
		["Tablet"]  = { MouseEnabled = false, KeyboardEnabled = false, TouchEnabled = true,  GamepadEnabled = false },
		["Console"] = { MouseEnabled = false, KeyboardEnabled = false, TouchEnabled = false, GamepadEnabled = true  },
	}
	local device = cfg.device
	local props = DEVICE_PROPS[device]
	if not props then return end
	local UI_KEYS = { MouseEnabled = true, KeyboardEnabled = true, TouchEnabled = true, GamepadEnabled = true }

	local RS = cloneref(game:GetService("ReplicatedStorage"))
	local Players = cloneref(game:GetService("Players"))
	local LP = Players.LocalPlayer
	while not LP do task.wait() LP = Players.LocalPlayer end
	if not LP.Character then LP.CharacterAdded:Wait() end

	local function wfc(parent, name, timeout)
		local t = tick()
		while tick() - t < (timeout or 20) do
			local c = parent:FindFirstChild(name)
			if c then return c end task.wait(0.2)
		end
	end

	wfc(RS, "UserInputService", 20); wfc(RS, "ClientGameModules", 20)
	local dlF = RS:FindFirstChild("ClientGameModules")
	if dlF then wfc(dlF, "DeviceListener", 20) end
	local ps = wfc(LP, "PlayerScripts", 20)
	if ps then local cl = wfc(ps, "Client", 20) if cl then wfc(cl, "DeviceChecker", 20) end end
	local pkgs = wfc(RS, "Packages", 20)
	if pkgs then
		local idx = wfc(pkgs, "_Index", 20)
		if idx then
			local sl = wfc(idx, "sleitnick_net@0.1.0", 20)
			if sl then local n = wfc(sl, "net", 20) if n then wfc(n, "RF/GetDeviceTypeForPlayer", 20) end end
		end
	end
	task.wait(1)

	pcall(function()
		local mod = require(RS:WaitForChild("UserInputService"))
		local mt = getrawmetatable(mod)
		local old = mt.__index
		setreadonly(mt, false)
		mt.__index = newcclosure(function(self, key)
			if is_caller_ours() and UI_KEYS[key] then return old(self, key) end  -- ★ UI sees REAL device
			if props[key] ~= nil then return props[key] end
			return old(self, key)
		end)
		setreadonly(mt, true)
	end)

	pcall(function()
		local dl = require(RS.ClientGameModules.DeviceListener)
		if type(dl) == "table" then
			rawset(dl, "Device", device)
			rawset(dl, "IsMobile", function() return device == "Phone" or device == "Tablet" end)
			if dl.State and dl.State.Set then dl.State:Set(device) end
		end
	end)

	pcall(function()
		local dc = require(LP.PlayerScripts.Client.DeviceChecker)
		if type(dc) == "table" then
			rawset(dc, "GetDeviceType", function() return device end)
			rawset(dc, "IsMobile", function() return device == "Phone" or device == "Tablet" end)
		end
	end)

	pcall(function()
		local rf = RS.Packages._Index["sleitnick_net@0.1.0"].net:WaitForChild("RF/GetDeviceTypeForPlayer", 5)
		if rf then rf.OnClientInvoke = function() return device end end
	end)

	getgenv()._ZX_SPOOF_HOOK_ACTIVE = true

	task.spawn(function()
		while LP and LP.Parent do
			task.wait(1)
			pcall(function()
				local dl = require(RS.ClientGameModules.DeviceListener)
				if type(dl) == "table" and dl.Device ~= device then
					rawset(dl, "Device", device)
					rawset(dl, "IsMobile", function() return device == "Phone" or device == "Tablet" end)
				end
			end)
		end
	end)

	rearm()  -- ★ armed again for the NEXT teleport
	print("[Stellar Spoofer] Applied: " .. device)
end)
]==]

local function saveSpoofConfig(device, enabled)
	pcall(writefile, SPOOFER_FILE, HttpService:JSONEncode({ device = device, enabled = enabled }))
end

local function loadSpoofConfig()
	local loaded = false
	pcall(function()
		if isfile(SPOOFER_FILE) then
			local cfg = HttpService:JSONDecode(readfile(SPOOFER_FILE))
			if cfg and cfg.device and DEVICE_PROPS[cfg.device] then
				Stellar.device_spoofer.__device = cfg.device
				Stellar.device_spoofer.__enabled = (cfg.enabled == true)
				loaded = true
			end
		end
	end)
	return loaded
end

local function queueSpoof()
	pcall(function()
		if not (queue_on_teleport and writefile) then return end
		writefile(SPOOFER_STUB_FILE, SPOOFER_STUB)          -- stub re-arm source
		queue_on_teleport(SPOOFER_STUB)
		Stellar.device_spoofer.__armed = true
	end)
end

local function disarmSpoof()
	Stellar.device_spoofer.__armed = false
	pcall(function()
		if delfile and isfile and isfile(SPOOFER_STUB_FILE) then delfile(SPOOFER_STUB_FILE) end
	end)
end

function Stellar.device_spoofer.apply(device)
	local props = DEVICE_PROPS[device]
	if not props then return end

	Stellar.device_spoofer.__device = device
	Stellar.device_spoofer.__enabled = true

	-- ① Hook custom UserInputService module
	pcall(function()
		local mod = require(ReplicatedStorage:WaitForChild("UserInputService"))
		if not Stellar.device_spoofer.__hooked and not getgenv()._ZX_SPOOF_HOOK_ACTIVE then
			local mt = getrawmetatable(mod)
			local old = mt.__index
			setreadonly(mt, false)
			mt.__index = newcclosure(function(self, key)
				if _checkcaller() and UI_PROTECTED_KEYS[key] then  -- ★ our env = REAL values
					return old(self, key)
				end
				local cfg = DEVICE_PROPS[Stellar.device_spoofer.__device]
				if cfg and cfg[key] ~= nil then return cfg[key] end
				return old(self, key)
			end)
			setreadonly(mt, true)
			getgenv()._ZX_SPOOF_HOOK_ACTIVE = true
		end
		Stellar.device_spoofer.__hooked = true
	end)

	-- ② Patch DeviceListener
	pcall(function()
		local dl = require(ReplicatedStorage.ClientGameModules.DeviceListener)
		if type(dl) == "table" then
			rawset(dl, "Device", device)
			rawset(dl, "IsMobile", function() return device == "Phone" or device == "Tablet" end)
			if dl.State and dl.State.Set then dl.State:Set(device) end
		end
	end)

	-- ③ Patch DeviceChecker
	pcall(function()
		local dc = require(LocalPlayer.PlayerScripts.Client.DeviceChecker)
		if type(dc) == "table" then
			rawset(dc, "GetDeviceType", function() return device end)
			rawset(dc, "IsMobile", function() return device == "Phone" or device == "Tablet" end)
		end
	end)

	-- ④ Set RF callback
	pcall(function()
		local rf = ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net
			:WaitForChild("RF/GetDeviceTypeForPlayer", 5)
		if rf then rf.OnClientInvoke = function() return device end end
	end)

	-- ⑤ Update Stellar mobile detection
	Stellar.__properties.__is_mobile = props.TouchEnabled and not props.MouseEnabled

	saveSpoofConfig(device, true)
	queueSpoof()
end

-- ★ NEW: no rejoin — just waits, applies when you teleport
function Stellar.device_spoofer.arm_for_teleport()
	local device = Stellar.device_spoofer.__device
	if not DEVICE_PROPS[device] then return end
	Stellar.device_spoofer.__enabled = true
	saveSpoofConfig(device, true)
	queueSpoof()
	Library.SendNotification({
		title = "Device Spoofer",
		text = "Armed ✔ Spoof as " .. device .. " will apply the moment you teleport — no rejoin needed.",
		duration = 4
	})
end

function Stellar.device_spoofer.disable()
	Stellar.device_spoofer.__enabled = false
	pcall(function()
		local dl = require(ReplicatedStorage.ClientGameModules.DeviceListener)
		if type(dl) == "table" then
			rawset(dl, "Device", "Phone")
			rawset(dl, "IsMobile", function() return true end)
			if dl.State and dl.State.Set then dl.State:Set("Phone") end
		end
	end)
	pcall(function()
		local dc = require(LocalPlayer.PlayerScripts.Client.DeviceChecker)
		if type(dc) == "table" then
			rawset(dc, "GetDeviceType", function() return "Mobile" end)
			rawset(dc, "IsMobile", function() return true end)
		end
	end)
	Stellar.__properties.__is_mobile = true
	saveSpoofConfig(Stellar.device_spoofer.__device, false)
	disarmSpoof()
end

-- ★ Instant rejoin + spoof
function Stellar.device_spoofer.rejoin()
	local device = Stellar.device_spoofer.__device
	Stellar.device_spoofer.__enabled = true
	saveSpoofConfig(device, true)
	queueSpoof()
	Library.SendNotification({ title = "Device Spoofer", text = "Rejoining instantly — spoof as " .. device, duration = 2 })
	task.delay(0.2, function()
		pcall(function()
			game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
		end)
	end)
end

loadSpoofConfig()

-- ★ FIXED: auto-apply on startup (old version never ran — loadSpoofConfig returned nil)
task.spawn(function()
	if not loadSpoofConfig() then return end
	if not Stellar.device_spoofer.__enabled then return end

	local device = Stellar.device_spoofer.__device

	local function waitForModule(path, timeout)
		local obj = ReplicatedStorage
		for _, name in ipairs(path) do
			obj = obj:WaitForChild(name, timeout or 15)
			if not obj then return nil end
		end
		return obj
	end

	waitForModule({"UserInputService"}, 15)
	waitForModule({"ClientGameModules", "DeviceListener"}, 15)

	local client = LocalPlayer:WaitForChild("PlayerScripts", 15)
	if client then client:WaitForChild("Client", 15) end
	if client and client:FindFirstChild("Client") then
		client.Client:WaitForChild("DeviceChecker", 15)
	end

	waitForModule({"Packages", "_Index", "sleitnick_net@0.1.0", "net", "RF/GetDeviceTypeForPlayer"}, 15)
	task.wait(2)

	Stellar.device_spoofer.apply(device)
	Library.SendNotification({ title = "Device Spoofer", text = "Auto-applied after teleport: " .. device, duration = 3 })
	print("[Stellar] Device Spoofer auto-applied: " .. device)
end)
-- ═══════════════════════════════════════════════════════════════
-- AUTO-APPLY ON STARTUP — waits for all modules to exist
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
	local wasLoaded = loadSpoofConfig()
	if not wasLoaded then return end

	local device = Stellar.device_spoofer.__device

	-- Wait for ALL required modules to be available
	local function waitForModule(path, timeout)
		local obj = ReplicatedStorage
		for _, name in ipairs(path) do
			obj = obj:WaitForChild(name, timeout or 15)
			if not obj then return nil end
		end
		return obj
	end

	-- 1. Wait for UserInputService module
	waitForModule({"UserInputService"}, 15)

	-- 2. Wait for DeviceListener
	waitForModule({"ClientGameModules", "DeviceListener"}, 15)

	-- 3. Wait for DeviceChecker
	local client = LocalPlayer:WaitForChild("PlayerScripts", 15)
	if client then client:WaitForChild("Client", 15) end
	if client and client:FindFirstChild("Client") then
		client.Client:WaitForChild("DeviceChecker", 15)
	end

	-- 4. Wait for RF remote
	waitForModule({"Packages", "_Index", "sleitnick_net@0.1.0", "net", "RF/GetDeviceTypeForPlayer"}, 15)

	-- Extra safety wait
	task.wait(2)

	-- NOW apply
	Stellar.device_spoofer.apply(device)

	Library.SendNotification({
		title = "Device Spoofer",
		text = "Auto-applied after rejoin: " .. device,
		duration = 3
	})

	print("[Stellar] Device Spoofer auto-applied: " .. device)
end)

-- UI MODULE BINDINGS & EXPANDED CONFIGURATION SLIDERS
local autoparry_module = AutoparryTab:create_module({
	title = "Auto Parry Core",
	description = "Automatic ball deflection",
	flag = "AutoParryModule",
	section = "left",
	callback = function(state)
		Stellar.__properties.__autoparry_enabled = state
		Stellar.__properties.__play_animation = state
		if state then pcall(Stellar.autoparry.start) else pcall(Stellar.autoparry.stop) end
	end
})

autoparry_module:create_slider({
	title = "Parry Range Scale",
	flag = "ParryRangeSlider",
	maximum_value = 7,
	minimum_value = 1,
	value = 2,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__parry_range = value
	end
})

autoparry_module:create_slider({
	title = "Parry Accuracy",
	flag = "ParryAccuracy",
	maximum_value = 100,
	minimum_value = 1,
	value = 100,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__accuracy = value
		update_divisor()
	end
})

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

autoparry_module:create_dropdown({
	title = "Parry Mode",
	flag = "ParryMode",
	options = { "Remote", "Keypress" },
	maximum_options = 1,
	callback = function(value) getgenv().AutoParryMode = value end
})

autoparry_module:create_divider({showtopic = true, title = "Curve"})

autoparry_module:create_dropdown({
	title = "Mode curve",
	flag = "ModeCurve",
	options = Stellar.__config.__curve_names,
	multi_dropdown = false,
	maximum_options = 9,
	callback = function(value)
		for i, name in ipairs(Stellar.__config.__curve_names) do
			if name == value then Stellar.__properties.__curve_mode = i; break end
		end
	end
})

autoparry_module:create_divider({showtopic = true, title = "Anti-Curve"})

autoparry_module:create_checkbox({
	title = "Predictive Anti-Curve",
	flag = "PredictiveAntiCurveToggle",
	callback = function(state)
		Stellar.__properties.__predictive_anti_curve_enabled = state
	end
})

autoparry_module:create_slider({
	title = "Curve Sensitivity",
	flag = "CurveSensitivitySlider",
	maximum_value = 100,
	minimum_value = 1,
	value = 50,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__curve_sensitivity = value
	end
})

autoparry_module:create_slider({
	title = "Prediction Accuracy",
	flag = "PredictionAccuracySlider",
	maximum_value = 100,
	minimum_value = 1,
	value = 75,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__prediction_accuracy = value
	end
})

autoparry_module:create_divider({showtopic = true, title = "Utilities"})

autoparry_module:create_checkbox({
	title = "Auto Abilities",
	flag = "AutoAbilities",
	callback = function(state) Stellar.__properties.__auto_ability_enabled = state end
})

autoparry_module:create_checkbox({
    title = "Cooldown Protection",
    flag = "CDProtection",
    callback = function(state)
         Stellar.__config.__detections.__cooldown_protection = state
    end
})

triggerbot_module = AutoparryTab:create_module({
	title = "Triggerbot",
	description= "Immediately parry if targeted",
	flag = "TriggerbotFloatingSwitch",
	section= "right",
	callback = function(state)
		Stellar.__properties.__triggerbot_enabled = state
		if TriggerbotFloatingSwitch.ScreenGui then TriggerbotFloatingSwitch.ScreenGui.Enabled = state end
		if not state then
			TriggerbotFloatingSwitch.IsOn = false
			if Stellar.triggerbot and typeof(Stellar.triggerbot.enable) == "function" then Stellar.triggerbot.enable(false) end
		end
	end
})

-- Triggerbot Settings
triggerbot_module:create_slider({
	title = "Parry Delay",
	flag = "TBParryDelay",
	minimum_value = 0.05,
	maximum_value = 0.5,
	value = 0.15,
	round_number = false,
	callback = function(value)
		Stellar.__triggerbot.__parry_delay = value
	end
})

triggerbot_module:create_feature({
	title = "TB Keybind",
	flag = "triggerbot_keybind",
	default = "Unknown",
	disablecheck = false,
	callback = function(checked)
		Stellar.__properties.__triggerbot_enabled = checked
		TriggerbotFloatingSwitch.IsOn = checked
		if checked then
			if Stellar.triggerbot and typeof(Stellar.triggerbot.enable) == "function" then Stellar.triggerbot.enable(true) end
			if TriggerbotFloatingSwitch.ScreenGui then TriggerbotFloatingSwitch.ScreenGui.Enabled = true end
		else
			if Stellar.triggerbot and typeof(Stellar.triggerbot.enable) == "function" then Stellar.triggerbot.enable(false) end
		end
	end,
	keybind_callback = function(keyName)
		local keyCode = stringToKeyCode(keyName)
		TriggerbotFloatingSwitch:updateKeybind(keyCode)
	end
})

local preclick_module = AutoparryTab:create_module({
    title = "Preclick",
    description = "Parry once after you eliminate enemy",
    flag = "PreclickModule",
    section = "right",
    callback = function(state)
        Stellar.__properties.__preclick_enabled = state
        if state then
            Stellar.preclick.start()
        else
            Stellar.preclick.stop()
        end
    end
})

preclick_module:create_slider({
    title = "Speed Threshold",
    flag = "PreclickSpeedThreshold",
    minimum_value = 500,
    maximum_value = 800,
    value = 600,
    round_number = true,
    callback = function(value)
        Stellar.preclick.set_speed_threshold(value)
    end
})

preclick_module:create_slider({
    title = "Max Kill Distance",
    flag = "PreclickMaxDistance",
    minimum_value = 10,
    maximum_value = 200,
    value = 100,
    round_number = true,
    callback = function(value)
        Stellar.preclick.set_max_distance(value)
    end
})

preclick_module:create_slider({
    title = "Delay (ms)",
    flag = "PreclickDelay",
    minimum_value = 50,
    maximum_value = 300,
    value = 140,
    round_number = true,
    callback = function(value)
        -- Both min and max set to the slider value ±10ms
        Stellar.preclick.set_delay(math.max(50, value - 10), value)
    end
})

local spam_module = SpamTab:create_module({
	title = "Auto Spam",
	description = "Rapid parry with high speed based on Spam Mode",
	flag = "AutoSpamModule",
	section = "left",
	callback = function(state) 
		Stellar.__properties.__auto_spam_enabled = state 
		if state then pcall(Stellar.autospam.start) else pcall(Stellar.autospam.stop) end
	end
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

spam_module:create_slider({
	title = "Burst Multiplier",
	flag = "SpamBurstMultiplier",
	minimum_value = 0.5,
	maximum_value = 2,
	value = 1,
	round_number = false,
	callback = function(value)
		Stellar.__properties.__burst_multiplier = value
	end
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

manual_spam_module:create_dropdown({
	title = "Spam Mode",
	flag = "SpamBatchAmount",
	options = { "FPS Priority", "Balanced", "Bruteforce", "Extremely Fast" },
	multi_dropdown = false,
	maximum_options = 4,
	callback = function(value) Stellar.__properties.__spam_batch_amount = value end
})
local detection_module = DetectionTab:create_module({
	title = "Ability Detections",
	description = "Adjust auto-parry parameters per enemy skills",
	flag = "DetectionModule",
	section = "left",
	callback = function(state) end
})

detection_module:create_divider({ disableline = true, showtopic = true, title = "Abilities" })

detection_module:create_checkbox({
	title = "Phantom",
	flag = "PhantomDetectToggle",
	callback = function(state) Stellar.__config.__detections.__phantom = state end
})

detection_module:create_checkbox({
	title = "Time Hole",
	flag = "TimeHoleDetectToggle",
	callback = function(state) Stellar.__config.__detections.__timehole = state end
})

detection_module:create_checkbox({
	title = "Slashes of Fury",
	flag = "SlashesOfFuryDetectToggle",
	callback = function(state) Stellar.__config.__detections.__slashesoffury = state end
})

detection_module:create_slider({
	title = "Slashes Parry Delay",
	flag = "SlashesParryDelay",
	maximum_value = 0.25,
	minimum_value = 0.05,
	value = 0.05,
	round_number = false,
	callback = function(value)
		Stellar.__properties.__slashesoffury_delay = value
	end
})

detection_module:create_slider({
	title = "Slashes Max Parry Count",
	flag = "SlashesMaxParryCount",
	maximum_value = 36,
	minimum_value = 1,
	value = 36,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__slashesoffury_max_count = value
	end
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

local dribble_module = DetectionTab:create_module({
	title = "Dribble Detection",
	flag = "DribbleDetectionModule",
	description = "Real-time dribble ball tracking & curve bypass",
	section = "right",
	callback = function(state)
		Stellar.__config.__detections.__dribble = state
		if state then
			Stellar.dribble_detection.start()
			Library.SendNotification({
				title = "Stellar Engine",
				text = "Dribble Detection Activated",
				duration = 2
			})
		else
			Stellar.dribble_detection.stop()
			Library.SendNotification({
				title = "Stellar Engine",
				text = "Dribble Detection Deactivated",
				duration = 2
			})
		end
	end
})

local staff_module = DetectionTab:create_module({
	title = "Staff Detection",
	description = "Real-time moderation team identification & protection",
	flag = "StaffDetectionModule",
	section = "right",
	callback = function(state)
		Stellar.__config.__detections.__staff_detection = state
		if state then
			Stellar.staff_detection.start()
			Library.SendNotification({
				title = "Stellar Engine",
				text = "Staff Detection System Activated",
				duration = 2
			})
		else
			Stellar.staff_detection.stop()
			Library.SendNotification({
				title = "Stellar Engine",
				text = "Staff Detection System Deactivated",
				duration = 2
			})
		end
	end
})

staff_module:create_dropdown({
	title = "Action Mode",
	flag = "StaffActionMode",
	options = { "Notification", "Kick" },
	multi_dropdown = false,
	maximum_options = 2,
	callback = function(value)
		Stellar.__config.__detections.__staff_action_mode = value
	end
})

staff_module:create_button({
	title = "Scan Current Server",
	callback = function()
		local detectedCount = 0
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local rank = Stellar.staff_detection.get_rank(player)
				if rank >= Stellar.__properties.__staff_min_rank then
					detectedCount = detectedCount + 1
				end
			end
		end
		
		Library.SendNotification({
			title = "Server Audit Complete",
			text = "Active Staff Members Identified: " .. tostring(detectedCount),
			duration = 3
		})
	end
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
					if Stellar.__properties.__CameraEnabled then
						Camera.FieldOfView = Stellar.__properties.__CameraFOV
					end
				end)
			end
		else
			if Stellar.__properties.__FOVLoop then
				Stellar.__properties.__FOVLoop:Disconnect()
				Stellar.__properties.__FOVLoop = nil
			end
			Camera.FieldOfView = 70
		end
	end
})

fov_module:create_slider({
	title = "Field Of View",
	flag = "FOVSlider",
	maximum_value = 120,
	minimum_value = 30,
	value = 70,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__CameraFOV = value
		if Stellar.__properties.__CameraEnabled then
			workspace.CurrentCamera.FieldOfView = value
		end
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

_G.PlayerCosmeticsCleanup = {}
    
local PlayerCosmetics = PlayerTab:create_module({
	title = "Player Cosmetics",
	flag = "Player_Cosmetics",
	description = "Apply headless and korblox",
	section = "left",
	callback = function(value)
		local players = game:GetService("Players")
		local lp = players.LocalPlayer

		local function applyKorblox(character)
			local rightLeg = character:FindFirstChild("RightLeg") or character:FindFirstChild("Right Leg")
			if not rightLeg then return end
			
			for _, child in pairs(rightLeg:GetChildren()) do
				if child:IsA("SpecialMesh") then child:Destroy() end
			end
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshId = "rbxassetid://101851696"
			specialMesh.TextureId = "rbxassetid://115727863"
			specialMesh.Scale = Vector3.new(1, 1, 1)
			specialMesh.Parent = rightLeg
		end

		local function saveRightLegProperties(char)
			if char then
				local rightLeg = char:FindFirstChild("RightLeg") or char:FindFirstChild("Right Leg")
				if rightLeg then
					local originalMesh = rightLeg:FindFirstChildOfClass("SpecialMesh")
					if originalMesh then
						_G.PlayerCosmeticsCleanup.originalMeshId = originalMesh.MeshId
						_G.PlayerCosmeticsCleanup.originalTextureId = originalMesh.TextureId
						_G.PlayerCosmeticsCleanup.originalScale = originalMesh.Scale
					else
						_G.PlayerCosmeticsCleanup.hadNoMesh = true
					end
					
					_G.PlayerCosmeticsCleanup.rightLegChildren = {}
					for _, child in pairs(rightLeg:GetChildren()) do
						if child:IsA("SpecialMesh") then
							table.insert(_G.PlayerCosmeticsCleanup.rightLegChildren, {
								ClassName = child.ClassName,
								Properties = {
									MeshId = child.MeshId,
									TextureId = child.TextureId,
									Scale = child.Scale
								}
							})
						end
					end
				end
			end
		end
		
		local function restoreRightLeg(char)
			if char then
				local rightLeg = char:FindFirstChild("RightLeg") or char:FindFirstChild("Right Leg")
				if rightLeg and _G.PlayerCosmeticsCleanup.rightLegChildren then
					for _, child in pairs(rightLeg:GetChildren()) do
						if child:IsA("SpecialMesh") then child:Destroy() end
					end
					
					if _G.PlayerCosmeticsCleanup.hadNoMesh then return end
					
					for _, childData in ipairs(_G.PlayerCosmeticsCleanup.rightLegChildren) do
						if childData.ClassName == "SpecialMesh" then
							local newMesh = Instance.new("SpecialMesh")
							newMesh.MeshId = childData.Properties.MeshId
							newMesh.TextureId = childData.Properties.TextureId
							newMesh.Scale = childData.Properties.Scale
							newMesh.Parent = rightLeg
						end
					end
				end
			end
		end

		if value then
			CosmeticsActive = true
			getgenv().Config = { Headless = true }
			
			if lp.Character then
				local head = lp.Character:FindFirstChild("Head")
				if head and getgenv().Config.Headless then
					_G.PlayerCosmeticsCleanup.headTransparency = head.Transparency
					local decal = head:FindFirstChildOfClass("Decal")
					if decal then
						_G.PlayerCosmeticsCleanup.faceDecalId = decal.Texture
						_G.PlayerCosmeticsCleanup.faceDecalName = decal.Name
					end
				end
				saveRightLegProperties(lp.Character)
				applyKorblox(lp.Character)
			end
			
			_G.PlayerCosmeticsCleanup.characterAddedConn = lp.CharacterAdded:Connect(function(char)
				local head = char:FindFirstChild("Head")
				if head and getgenv().Config.Headless then
					_G.PlayerCosmeticsCleanup.headTransparency = head.Transparency
					local decal = head:FindFirstChildOfClass("Decal")
					if decal then
						_G.PlayerCosmeticsCleanup.faceDecalId = decal.Texture
						_G.PlayerCosmeticsCleanup.faceDecalName = decal.Name
					end
				end
				saveRightLegProperties(char)
				applyKorblox(char)
			end)
			
			if getgenv().Config.Headless then
				headLoop = task.spawn(function()
					while CosmeticsActive do
						local char = lp.Character
						if char then
							local head = char:FindFirstChild("Head")
							if head then
								head.Transparency = 1
								local decal = head:FindFirstChildOfClass("Decal")
								if decal then decal:Destroy() end
							end
						end
						task.wait(0.1)
					end
				end)
			end
		else
			CosmeticsActive = false
			if _G.PlayerCosmeticsCleanup.characterAddedConn then
				_G.PlayerCosmeticsCleanup.characterAddedConn:Disconnect()
				_G.PlayerCosmeticsCleanup.characterAddedConn = nil
			end
			if headLoop then
				task.cancel(headLoop)
				headLoop = nil
			end
			local char = lp.Character
			if char then
				local head = char:FindFirstChild("Head")
				if head and _G.PlayerCosmeticsCleanup.headTransparency ~= nil then
					head.Transparency = _G.PlayerCosmeticsCleanup.headTransparency
					if _G.PlayerCosmeticsCleanup.faceDecalId then
						local newDecal = head:FindFirstChildOfClass("Decal") or Instance.new("Decal", head)
						newDecal.Name = _G.PlayerCosmeticsCleanup.faceDecalName or "face"
						newDecal.Texture = _G.PlayerCosmeticsCleanup.faceDecalId
						newDecal.Face = Enum.NormalId.Front
					end
				end
				restoreRightLeg(char)
			end
			_G.PlayerCosmeticsCleanup = {}
		end
	end
})
    
Stellar.emotes.scan()
Stellar.hitsounds.init()
Stellar.sound_controller.init()

local hitsounds_module = PlayerTab:create_module({
	title = "Hit Sounds",
	description = "Custom sound upon successful parry",
	flag = "HitSoundsModule",
	section = "left",
	callback = function(state)
		Stellar.__properties.__hitsound_enabled = state
	end
})

hitsounds_module:create_slider({
	title = "Volume",
	flag = "HitSoundVolumeSlider",
	minimum_value = 1,
	maximum_value = 10,
	value = 5,
	round_number = true,
	callback = function(value)
		Stellar.hitsounds.set_volume(value)
	end
})

hitsounds_module:create_dropdown({
	title = "Sound Selection",
	flag = "HitSoundTypeDropdown",
	options = {
		"Medal", "Fatality", "Skeet", "Switches", "Rust Headshot",
		"Neverlose Sound", "Bubble", "Laser", "Steve", "Call of Duty",
		"Bat", "TF2 Critical", "Saber", "Bameware"
	},
	multi_dropdown = false,
	maximum_options = 14,
	callback = function(value)
		Stellar.hitsounds.set_sound(value)
	end
})

local emotes_module = PlayerTab:create_module({
	title = "Custom Emotes",
	description = "Plays custom animations when stationary",
	flag = "EmotesModule",
	section = "right",
	callback = function(state)
		Stellar.__properties.__emotes_enabled = state
		if state then
			Stellar.emotes.start_loop()
			if Stellar.__properties.__selected_emote ~= "" then
				Stellar.emotes.play(Stellar.__properties.__selected_emote)
			end
		else
			if Stellar.__properties.__connections.__emotes_loop then
				Stellar.__properties.__connections.__emotes_loop:Disconnect()
				Stellar.__properties.__connections.__emotes_loop = nil
			end
			Stellar.emotes.stop()
		end
	end
})

if #Stellar.emotes.__names > 0 then
	emotes_module:create_dropdown({
		title = "Animation Selection",
		flag = "SelectedAnimationTrack",
		options = Stellar.emotes.__names,
		multi_dropdown = false,
		maximum_options = #Stellar.emotes.__names,
		callback = function(value)
			Stellar.__properties.__selected_emote = value
			if Stellar.__properties.__emotes_enabled then
				Stellar.emotes.play(value)
			end
		end
	})
end

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

visuals_module:create_paragraph({
	title = "⚠️EVERYONE CAN SEE ANIMATIONS",
	text = "IF YOU USE SKIN CHANGER BACKSWORD YOU MUST EQUIP AN ACTUAL BACKSWORD"
})

local visualPart
local visualConnection

local Visualiser = VisualsTab:create_module({
    title = 'Visualiser',
    flag = 'Visualiser',
    description = 'Parry Range Visualiser',
    section = 'right',
    callback = function(value)
        if value then
            if not visualPart then
                visualPart = Instance.new("Part")
                visualPart.Name = "VisualiserPart"
                visualPart.Shape = Enum.PartType.Ball
                visualPart.Material = Enum.Material.ForceField
                visualPart.Color = Color3.fromRGB(255, 255, 255)
                visualPart.Transparency = 0  
                visualPart.CastShadow = false 
                visualPart.Anchored = true
                visualPart.CanCollide = false
                visualPart.Parent = workspace
            end

            visualConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local Player = game:GetService("Players").LocalPlayer 
                local character = Player and Player.Character
                local HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if visualPart then
                    if HumanoidRootPart then
                        visualPart.CFrame = HumanoidRootPart.CFrame  
                    end

                    if getgenv().VisualiserRainbow then
                        local hue = (tick() % 5) / 5
                        visualPart.Color = Color3.fromHSV(hue, 1, 1)
                    else
                        local hueVal = getgenv().VisualiserHue or 0
                        visualPart.Color = Color3.fromHSV(hueVal / 360, 1, 1)
                    end

                    local speed = 0
                    local maxSpeed = 350 
                    
                    if Stellar and Stellar.ball then
                        local Balls = Stellar.ball.get_all()
                        for _, Ball in pairs(Balls) do
                            if Ball and Ball:FindFirstChild("zoomies") then
                                local Velocity = Ball.AssemblyLinearVelocity
                                speed = math.min(Velocity.Magnitude, maxSpeed) / 6.5  
                                break
                            end
                        end
                    end

                    local size = math.max(speed, 6.5)
                    visualPart.Size = Vector3.new(size, size, size)
                end
            end)
        else
            if visualConnection then
                visualConnection:Disconnect()
                visualConnection = nil
            end

            if visualPart then
                visualPart:Destroy()
                visualPart = nil
            end
        end
    end
})

Visualiser:create_checkbox({
    title = 'Rainbow',
    flag = 'VisualiserRainbow',
    callback = function(value)
        getgenv().VisualiserRainbow = value
    end
})

Visualiser:create_slider({
    title = 'Color Hue',
    flag = 'VisualiserHue',
    minimum_value = 0,
    maximum_value = 360,
    value = 0,
    callback = function(value)
        getgenv().VisualiserHue = value
    end
})

local Alive = workspace:FindFirstChild("Alive") or workspace:WaitForChild("Alive")
local Runtime = workspace.Runtime

local ballTrailState = {}
local rainbowHue = 0

local function clear_ball_trail(ball)
    if not ball then
        return
    end

    local existingTrail = ball:FindFirstChild('Trail')
    if existingTrail then
        existingTrail:Destroy()
    end

    local existingEmitter = ball:FindFirstChild('ParticleEmitter')
    if existingEmitter then
        existingEmitter:Destroy()
    end

    local existingGlow = ball:FindFirstChild('BallGlow')
    if existingGlow then
        existingGlow:Destroy()
    end

    local attachment0 = ball:FindFirstChild('Attachment0')
    if attachment0 then
        attachment0:Destroy()
    end

    local attachment1 = ball:FindFirstChild('Attachment1')
    if attachment1 then
        attachment1:Destroy()
    end

    ballTrailState[ball] = nil
end

local function apply_ball_trail(ball)
    if not ball then
        return
    end

    if not getgenv().BallTrailEnabled then
        clear_ball_trail(ball)
        return
    end

    if ballTrailState[ball] then
        local trail = ball:FindFirstChild('Trail')
        if trail then
            if getgenv().BallTrailRainbowEnabled then
                local color = Color3.fromHSV(rainbowHue / 360, 1, 1)
                trail.Color = ColorSequence.new(color)
                getgenv().BallTrailColor = color
            else
                trail.Color = ColorSequence.new(getgenv().BallTrailColor or Color3.new(1, 1, 1))
            end
        end
        return
    end

    ballTrailState[ball] = true

    local trail = Instance.new('Trail')
    trail.Name = 'Trail'

    local attachment0 = Instance.new('Attachment')
    attachment0.Name = 'Attachment0'
    attachment0.Position = Vector3.new(0, ball.Size.Y / 2, 0)
    attachment0.Parent = ball

    local attachment1 = Instance.new('Attachment')
    attachment1.Name = 'Attachment1'
    attachment1.Position = Vector3.new(0, -ball.Size.Y / 2, 0)
    attachment1.Parent = ball

    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Lifetime = 0.4
    trail.WidthScale = NumberSequence.new(0.5)
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Color = ColorSequence.new(getgenv().BallTrailColor or Color3.new(1, 1, 1))
    trail.Parent = ball

    if getgenv().BallTrailParticleEnabled then
        local emitter = Instance.new('ParticleEmitter')
        emitter.Name = 'ParticleEmitter'
        emitter.Rate = 100
        emitter.Lifetime = NumberRange.new(0.5, 1)
        emitter.Speed = NumberRange.new(0, 1)
        emitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
        emitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        emitter.Parent = ball
    end

    if getgenv().BallTrailGlowEnabled then
        local glow = Instance.new('PointLight')
        glow.Name = 'BallGlow'
        glow.Range = 15
        glow.Brightness = 2
        glow.Parent = ball
    end
end

RunService.Heartbeat:Connect(function()
    rainbowHue = (rainbowHue + 1) % 360
    local ball = Stellar.ball.get()
    if ball then
        apply_ball_trail(ball)
    else
        for _, existing_ball in ipairs(workspace:FindFirstChild('Balls') and workspace.Balls:GetChildren() or {}) do
            apply_ball_trail(existing_ball)
        end
    end
end)

local ball_trail_module = VisualsTab:create_module({
    title = 'Ball Trail',
    flag = 'Ball_Trail',
    description = 'Toggles ball trail effects',
    section = 'right',
    callback = function(value: boolean)
        getgenv().BallTrailEnabled = value
    end
})

ball_trail_module:create_slider({
    title = 'Ball Trail Hue',
    flag = 'Ball_Trail_Hue',
    minimum_value = 0,
    maximum_value = 360,
    value = 0,
    round_number = true,
    callback = function(value: number)
        if not getgenv().BallTrailRainbowEnabled then
            getgenv().BallTrailColor = Color3.fromHSV(value / 360, 1, 1)
        end
        getgenv().BallTrailHue = value
    end
})

ball_trail_module:create_checkbox({
    title = 'Rainbow Trail',
    flag = 'Ball_Trail_Rainbow',
    callback = function(value: boolean)
        getgenv().BallTrailRainbowEnabled = value
    end
})

ball_trail_module:create_checkbox({
    title = 'Particle Emitter',
    flag = 'Ball_Trail_Particle',
    callback = function(value: boolean)
        getgenv().BallTrailParticleEnabled = value
    end
})

ball_trail_module:create_checkbox({
    title = 'Glow Effect',
    flag = 'Ball_Trail_Glow',
    callback = function(value: boolean)
        getgenv().BallTrailGlowEnabled = value
    end
})

local CustomSky = VisualsTab:create_module({
	title = 'Custom Sky',
	flag = 'Custom_Sky',
	description = 'Toggles a custom skybox',
	section = 'left',
	callback = function(value)
		local Lighting = game.Lighting
		local Sky = Lighting:FindFirstChildOfClass("Sky")
		if value then
			if not Sky then Sky = Instance.new("Sky", Lighting) end
		else
			if Sky then
				local defaultSkyboxIds = {"591058823", "591059876", "591058104", "591057861", "591057625", "591059642"}
				local skyFaces = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}
				for index, face in ipairs(skyFaces) do
					Sky[face] = "rbxassetid://" .. defaultSkyboxIds[index]
				end
				Lighting.GlobalShadows = true
			end
		end
	end
})
    
CustomSky:create_dropdown({
    title = 'Select Sky',
    flag = 'custom_sky_selector',
    options = {
		"Default", "Vaporwave", "Redshift", "Desert", "DaBaby", "Minecraft",
		"SpongeBob", "Skibidi", "Blaze", "Pussy Cat", "Among Us", "Space Wave",
		"Space Wave2", "Turquoise Wave", "Dark Night", "Bright Pink", "White Galaxy", "Blue Galaxy"
	},
	multi_dropdown = false,
	maximum_options = 18,
	callback = function(selectedOption)
		local skyboxData = nil
		if selectedOption == "Default" then
			skyboxData = {"591058823", "591059876", "591058104", "591057861", "591057625", "591059642"}
		elseif selectedOption == "Vaporwave" then
			skyboxData = {"1417494030", "1417494146", "1417494253", "1417494402", "1417494499", "1417494643"}
		elseif selectedOption == "Redshift" then
			skyboxData = {"401664839", "401664862", "401664960", "401664881", "401664901", "401664936"}
		elseif selectedOption == "Desert" then
			skyboxData = {"1013852", "1013853", "1013850", "1013851", "1013849", "1013854"}
		elseif selectedOption == "DaBaby" then
			skyboxData = {"7245418472", "7245418472", "7245418472", "7245418472", "7245418472", "7245418472"}
		elseif selectedOption == "Minecraft" then
			skyboxData = {"1876545003", "1876544331", "1876542941", "1876543392", "1876543764", "1876544642"}
		elseif selectedOption == "SpongeBob" then
			skyboxData = {"7633178166", "7633178166", "7633178166", "7633178166", "7633178166", "7633178166"}
		elseif selectedOption == "Skibidi" then
			skyboxData = {"14952256113", "14952256113", "14952256113", "14952256113", "14952256113", "14952256113"}
		elseif selectedOption == "Blaze" then
			skyboxData = {"150939022", "150939038", "150939047", "150939056", "150939063", "150939082"}
		elseif selectedOption == "Pussy Cat" then
			skyboxData = {"11154422902", "11154422902", "11154422902", "11154422902", "11154422902", "11154422902"}
		elseif selectedOption == "Among Us" then
			skyboxData = {"5752463190", "5752463190", "5752463190", "5752463190", "5752463190", "5752463190"}
		elseif selectedOption == "Space Wave" then
			skyboxData = {"16262356578", "16262358026", "16262360469", "16262362003", "16262363873", "16262366016"}
		elseif selectedOption == "Space Wave2" then
			skyboxData = {"1233158420", "1233158838", "1233157105", "1233157640", "1233157995", "1233159158"}
		elseif selectedOption == "Turquoise Wave" then
			skyboxData = {"47974894", "47974690", "47974821", "47974776", "47974859", "47974909"}
		elseif selectedOption == "Dark Night" then
			skyboxData = {"6285719338", "6285721078", "6285722964", "6285724682", "6285726335", "6285730635"}
		elseif selectedOption == "Bright Pink" then
			skyboxData = {"271042516", "271077243", "271042556", "271042310", "271042467", "271077958"}
		elseif selectedOption == "White Galaxy" then
			skyboxData = {"5540798456", "5540799894", "5540801779", "5540801192", "5540799108", "5540800635"}
		elseif selectedOption == "Blue Galaxy" then
			skyboxData = {"14961495673", "14961494492", "14961492844", "14961491298", "14961490439", "14961489508"}
		end

		if not skyboxData then return end

		local Lighting = game.Lighting
		local Sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
		local skyFaces = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}
		for index, face in ipairs(skyFaces) do
			Sky[face] = "rbxassetid://" .. skyboxData[index]
		end
		Lighting.GlobalShadows = false
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
					if Lighting.ClockTime ~= 0 then Lighting.ClockTime = 0 end
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

			Library.SendNotification({ title = "Stellar Engine", text = "Potato Mode initialized", duration = 2 })
		else
			if not initialized then return end
			
			if timeConnection then timeConnection:Disconnect(); timeConnection = nil end
			if descendantConnection then descendantConnection:Disconnect(); descendantConnection = nil end
			
			Lighting.ClockTime = originalClockTime
			Lighting.GlobalShadows = originalGlobalShadows
			
			for _, atmos in pairs(disabledAtmispheres) do
				if atmos then atmos.Parent = Lighting end
			end
			table.clear(disabledAtmispheres)
			
			for effect, wasEnabled in pairs(originalEffectStates) do
				if effect and effect.Parent then effect.Enabled = wasEnabled end
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
				if obj and obj.Parent then obj.CastShadow = hadShadow end
			end

			Library.SendNotification({ title = "Stellar Engine", text = "Potato Mode unloaded", duration = 2 })
		end
	end
})

-- Sword Slash Color Module
local slash_color_module = VisualsTab:create_module({
	title = "Colorable Sword Slash",
	description = "Customize the color of your sword slashes",
	flag = "SlashColorModule",
	section = "right",
	callback = function(state)
		SwordSlashConfig.__enabled = state
		if state then
			sword_slash_system:start()
			-- Start rainbow loop if rainbow/random mode is selected
			if SwordSlashConfig.__custom_mode == "Rainbow" or SwordSlashConfig.__custom_mode == "Random" then
				sword_slash_system:start_rainbow_loop()
			end
		else
			sword_slash_system:stop()
			sword_slash_system:stop_rainbow_loop()
		end
	end
})

slash_color_module:create_dropdown({
	title = "Color Mode",
	flag = "SlashColorMode",
	options = {"Solid", "Rainbow", "Random"},
	multi_dropdown = false,
	maximum_options = 3,
	callback = function(value)
		SwordSlashConfig.__custom_mode = value
		-- Start rainbow loop if rainbow/random mode selected
		if value == "Rainbow" or value == "Random" then
			sword_slash_system:start_rainbow_loop()
		else
			sword_slash_system:stop_rainbow_loop()
		end
	end
})

local r_val = 255
local g_val = 0
local b_val = 0

slash_color_module:create_slider({
	title = "Red",
	flag = "SlashColorRed",
	minimum_value = 0,
	maximum_value = 255,
	value = 255,
	round_number = true,
	callback = function(value)
		r_val = value
		SwordSlashConfig.__color = Color3.fromRGB(r_val, g_val, b_val)
		sword_slash_system:reapply_all()
	end
})

slash_color_module:create_slider({
	title = "Green",
	flag = "SlashColorGreen",
	minimum_value = 0,
	maximum_value = 255,
	value = 0,
	round_number = true,
	callback = function(value)
		g_val = value
		SwordSlashConfig.__color = Color3.fromRGB(r_val, g_val, b_val)
		sword_slash_system:reapply_all()
	end
})

slash_color_module:create_slider({
	title = "Blue",
	flag = "SlashColorBlue",
	minimum_value = 0,
	maximum_value = 255,
	value = 0,
	round_number = true,
	callback = function(value)
		b_val = value
		SwordSlashConfig.__color = Color3.fromRGB(r_val, g_val, b_val)
		sword_slash_system:reapply_all()
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

local thunder_dash_module = MiscTab:create_module({
	title = "Thunder Dash No CD",
	description = "Disables cooldown for Thunder Dash",
	flag = "ThunderDash",
	section = "right",
	callback = function(state)
		Stellar.__config.__detections.__thunder_dash_nocooldown = state
		if state then
			Stellar.ability_exploits.apply_thunder_dash()
		end
	end
})

local device_spoofer_module = MiscTab:create_module({
	title = "Device Spoofer",
	description = "Spoof device type (survives rejoin)",
	flag = "DeviceSpooferModule",
	section = "left",
	callback = function(state)
		if state then
			Stellar.device_spoofer.apply(Stellar.device_spoofer.__device)
			Library.SendNotification({
				title = "Device Spoofer",
				text = "Spoofing as: " .. Stellar.device_spoofer.__device,
				duration = 2
			})
		else
			Stellar.device_spoofer.disable()
			Library.SendNotification({
				title = "Device Spoofer",
				text = "Spoof removed",
				duration = 2
			})
		end
	end
})

device_spoofer_module:create_dropdown({
	title = "Spoof As",
	flag = "DeviceSpoofType",
	options = { "PC", "Phone", "Tablet", "Console" },
	multi_dropdown = false,
	maximum_options = 4,
	callback = function(value)
		Stellar.device_spoofer.__device = value
		Stellar.device_spoofer.apply(value)
		Library.SendNotification({
			title = "Device Spoofer",
			text = "Spoofing as: " .. value,
			duration = 2
		})
	end
})

device_spoofer_module:create_button({
	title = "Arm Spoof",
	callback = function()
		Stellar.device_spoofer.arm_for_teleport()
	end
})

device_spoofer_module:create_button({
	title = "Rejoin",
	callback = function()
		Stellar.device_spoofer.rejoin()
	end
})

device_spoofer_module:create_paragraph({
	title = "Infos",
	text = "Arm Spoof mean wait till you teleport then apply the spoof. Spoof required to rejoin for it to work."
})

local Event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("WinnerText")
local ConnectionHooked = false

local CustomAnnouncer = MiscTab:create_module({
    title = 'Custom Announcer',
    flag = 'Custom_Announcer',
    description = 'Customize the game announcements',
    section = 'right',
    callback = function(value)
        -- We only need to hook the event once when it's first toggled on
        if value and not ConnectionHooked then
            ConnectionHooked = true
            
            -- Get the game's original event connections
            local originalConnections = getconnections(Event.OnClientEvent)
            
            -- Disable them so the game doesn't process the default message automatically
            for _, conn in ipairs(originalConnections) do
                conn:Disable()
            end
            
            -- Create our own interceptor that listens for the server's announcement
            Event.OnClientEvent:Connect(function(originalText, ...)
                local textToDisplay = originalText
                
                -- Check if our toggle is enabled, and replace the text if it is
                if Library._config._flags["Custom_Announcer"] then
                    textToDisplay = Library._config._flags["announcer_text"] or "On Third, Stellar"
                end
                
                -- Pass the (potentially modified) text back to the game's original GUI functions
                for _, conn in ipairs(originalConnections) do
                    if conn.Function then
                        conn.Function(textToDisplay, ...)
                    end
                end
            end)
        end
    end
})

CustomAnnouncer:create_textbox({
    title = "Custom Announcement Text",
    placeholder = "Enter custom announcer text... ",
    flag = "announcer_text",
    callback = function(text)
        -- We no longer need to fire the signal here. 
        -- We just save the text, and the interceptor above will use it on the next real announcement.
        Library._config._flags["announcer_text"] = text
    end
})

local bgm_module = MiscTab:create_module({
	title = "Sound Controller",
	description = "Background music player and ambient controller",
	flag = "SoundControllerModule",
	section = "left",
	callback = function(state)
		Stellar.__properties.__bgm_enabled = state
		if state then
			Stellar.sound_controller.play(Stellar.__properties.__bgm_track)
		else
			Stellar.sound_controller.stop()
		end
	end
})

bgm_module:create_checkbox({
	title = "Loop Song",
	flag = "LoopSongCheckbox",
	callback = function(state)
		Stellar.__properties.__bgm_loop = state
		if Stellar.sound_controller.__sound_instance then
			Stellar.sound_controller.__sound_instance.Looped = state
		end
	end
})

bgm_module:create_slider({
	title = "Music Volume",
	flag = "BGMVolumeSlider",
	minimum_value = 1,
	maximum_value = 10,
	value = 3,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__bgm_volume = value
		if Stellar.sound_controller.__sound_instance then
			Stellar.sound_controller.__sound_instance.Volume = value
		end
	end
})

bgm_module:create_divider({})

bgm_module:create_dropdown({
	title = "Select Track",
	flag = "BGMTrackDropdown",
	options = {
		"Eeyuh", "Low Cortisol", "Bounce", "Misery",
		"ODETARI", "PIXY", "Erwachen", "Grasp the Light",
		"Beyond the Shadows", "Rise to the Horizon", "Echoes of the Candy Kingdom",
		"Speed", "Lo-fi Chill A", "Lo-fi Ambient", "Tears in the Rain"
	},
	multi_dropdown = false,
	maximum_options = 15,
	callback = function(value)
		Stellar.__properties.__bgm_track = value
		if Stellar.__properties.__bgm_enabled then
			Stellar.sound_controller.play(value)
		end
	end
})

misc_module:create_button({
	title = "Unload Stellar Engine",
	callback = function()
		Stellar.autoparry.stop()
		Stellar.__triggerbot.__enabled = false
      pcall(Stellar.device_spoofer.disable)
		Stellar.staff_detection.stop()
		Stellar.__properties.__modify_player = false
		Stellar.__properties.__ability_esp_enabled = false
		Stellar.__properties.__immortality_enabled = false
		Stellar.emotes.stop()
		Stellar.sound_controller.stop()

		if Stellar.hitsounds.__sound_instance then
			Stellar.hitsounds.__sound_instance:Destroy()
			Stellar.hitsounds.__sound_instance = nil
		end

		if Stellar.sound_controller.__sound_instance then
			Stellar.sound_controller.__sound_instance:Destroy()
			Stellar.sound_controller.__sound_instance = nil
		end

		if Stellar.__properties.__connections.__hitsound_event then
			Stellar.__properties.__connections.__hitsound_event:Disconnect()
			Stellar.__properties.__connections.__hitsound_event = nil
		end

		if Stellar.__properties.__connections.__emotes_loop then
			Stellar.__properties.__connections.__emotes_loop:Disconnect()
			Stellar.__properties.__connections.__emotes_loop = nil
		end

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
		print("Parry Range Scale :", Stellar.__properties.__parry_range)
		print("Anti-Curve Engine :", Stellar.__properties.__predictive_anti_curve_enabled)
		print("Curve Sensitivity :", Stellar.__properties.__curve_sensitivity)
		print("Prediction Accuracy:", Stellar.__properties.__prediction_accuracy)
		print("Auto Spam Enabled :", Stellar.__properties.__auto_spam_enabled)
		print("Spam Batch Mode   :", Stellar.__properties.__spam_batch_amount)
		print("Immortality       :", Stellar.__properties.__immortality_enabled)
		print("GC Token Status   :", _token ~= nil and "Active" or "Unbound")
		print("Captured Remote   :", _captured and _captured.remote:GetFullName() or "None")
		print("-----------------------------------------------")
	end
})

misc_module:create_button({
	title = "Discord Server",
	callback = function()
		local discord = "https://discord.gg/VAYtA3gRN"
		setclipboard(discord)
	end
})

-- Launch Initialization
library:load()
Library.SendNotification({ title = "Stellar Engine", text = "Stellar V6.7 Initialized.", duration = 3 })
