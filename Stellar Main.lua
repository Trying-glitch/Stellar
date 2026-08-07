-- Stellar V3.40 Engine - Refactored Hardware-Agnostic Timing & Anti-Triangle Loop Core
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

-- Services Cached
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

-- Bypass Anti-Cheat Metatables
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

-- UI Library Loading
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Trying-glitch/Stellar/refs/heads/main/Stellar%20UI.lua"))()
local library = Library.new()
library:set_background({
    image = 77301388832536,
    transparency = 0.2,
})

-- Tabs Setup
local AutoparryTab = library:create_tab("Autoparry", "rbxassetid://76499042599127")
local SpamTab = library:create_tab("Spam Core", "rbxassetid://126017907477623")
local DetectionTab = library:create_tab("Detection", "rbxassetid://126017907477623")
local PlayerTab = library:create_tab("Player Mod", "rbxassetid://126017907477623")
local VisualsTab = library:create_tab("Visuals", "rbxassetid://126017907477623")
local MiscTab = library:create_tab("Misc Spec", "rbxassetid://126017907477623")

-- Global State Initialization
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
		__spam_threshold = 25,
		__parries = 0,
		__parry_key = nil,
		__grab_animation = nil,
		__tornado_time = tick(),
		__first_parry_done = false,
		__connections = {},
		__spam_accumulator = 0,
		__spam_rate = 15,
		__spam_batch_amount = "Fast Speed",
		__randomized_accuracy_enabled = false,
		__is_mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
		__speed_display_enabled = false,
		__spam_target = nil,
		__spam_target_time = 0,
		__timehole_active = false,
		__slashesoffury_active = false,
		__slashesoffury_count = 0,
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
		__last_global_parry = 0
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
			__phantom = false
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

-- Environments Initialization
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
local Runtime = workspace:FindFirstChild("Runtime")

-- GLASS MOBILE SPAM HELPER GUI
local function is_mobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local oldGui = CoreGui:FindFirstChild("MobileSpamHelper")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileSpamHelper"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false
ScreenGui.Parent = CoreGui

local SIZE = UDim2.new(0, 58, 0, 58)
local CORNER = UDim.new(0, 18)

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(1, -70 + 29, 0.5, -25 + 29 + 4)
Shadow.Size = UDim2.new(0, 64, 0, 64)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.55
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 1
Shadow.Parent = ScreenGui

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = CORNER
ShadowCorner.Parent = Shadow

local Button = Instance.new("ImageButton")
Button.Name = "Toggle"
Button.AnchorPoint = Vector2.new(0.5, 0.5)
Button.Position = UDim2.new(1, -70 + 29, 0.5, -25 + 29)
Button.Size = SIZE
Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Button.BackgroundTransparency = 0.75
Button.BorderSizePixel = 0
Button.AutoButtonColor = false
Button.Image = ""
Button.ZIndex = 2
Button.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = CORNER
Corner.Parent = Button

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 100, 100)
Stroke.Thickness = 1.5
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Button

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.ZIndex = 4
StatusText.Font = Enum.Font.GothamBold
StatusText.Text = "SPAM\nOFF"
StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusText.TextSize = 12
StatusText.Parent = Button

Button.Visible = is_mobile()
Shadow.Visible = is_mobile()

local dragging = false
local drag_start, button_start, shadow_start

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        drag_start = input.Position
        button_start = Button.Position
        shadow_start = Shadow.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - drag_start
    Button.Position = UDim2.new(button_start.X.Scale, button_start.X.Offset + delta.X, button_start.Y.Scale, button_start.Y.Offset + delta.Y)
    Shadow.Position = UDim2.new(shadow_start.X.Scale, shadow_start.X.Offset + delta.X, shadow_start.Y.Scale, shadow_start.Y.Offset + delta.Y)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

Button.Activated:Connect(function()
    Stellar.__properties.__gui_spam_active = not Stellar.__properties.__gui_spam_active
    Stellar.__properties.__manual_spam_enabled = Stellar.__properties.__gui_spam_active
    if Stellar.__properties.__gui_spam_active then
        StatusText.Text = "SPAM\nON"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        Stroke.Color = Color3.fromRGB(100, 255, 100)
        if Stellar.manual_spam and typeof(Stellar.manual_spam.start) == "function" then Stellar.manual_spam.start() end
    else
        StatusText.Text = "SPAM\nOFF"
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        Stroke.Color = Color3.fromRGB(255, 100, 100)
        if Stellar.manual_spam and typeof(Stellar.manual_spam.stop) == "function" then Stellar.manual_spam.stop() end
    end
end)

-- Ability ESP System
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

-- Remote Token and Upvalues
Stellar.ZX_Parry = {
	Remote = nil,
	Function = nil,
	KeyTable = nil,
	TransformFn = nil,
	NetModule = nil,
	RemoteId = nil,
	ParryHash = nil,
	Hooked = false
}
task.spawn(function()
	pcall(function()
		local SC = ReplicatedStorage:WaitForChild("Controllers", 10):FindFirstChild("SwordsController \12")
		local PRY = SC and SC:WaitForChild("PRY", 10)
		if not PRY then return end
		Stellar.ZX_Parry.Function = require(PRY)
		local ups = getupvalues(Stellar.ZX_Parry.Function)
		Stellar.ZX_Parry.KeyTable = ups[3]
		Stellar.ZX_Parry.TransformFn = ups[4]
		Stellar.ZX_Parry.NetModule = ups[6]
		Stellar.ZX_Parry.RemoteId = ups[7]
		Stellar.ZX_Parry.ParryHash = ups[8]
		if Stellar.ZX_Parry.KeyTable and Stellar.ZX_Parry.TransformFn and Stellar.ZX_Parry.NetModule and Stellar.ZX_Parry.RemoteId then
			Stellar.ZX_Parry.Remote = Stellar.ZX_Parry.NetModule:RemoteEvent(Stellar.ZX_Parry.RemoteId)
			Stellar.ZX_Parry.Hooked = true
		end
	end)
end)

local cachedToken = nil
local lastTokenTick = 0
local function generateToken(currentKey)
	if not currentKey or not Stellar.ZX_Parry.TransformFn then return nil end
	if tick() - lastTokenTick < 0.015 and cachedToken then return cachedToken end
	local tok, transformed = pcall(Stellar.ZX_Parry.TransformFn, currentKey, "TIME")
	if not tok or not transformed then return nil end
	local serverTime = workspace:GetServerTimeNow() * 100
	local timeStr = tostring(math.floor(serverTime))
	local tokenChars = {}
	for i = 1, #timeStr do
		local ki = (i - 1) % #transformed + 1
		local xb = bit32.bxor((string.byte(timeStr, i) + i) % 256, string.byte(transformed, ki))
		tokenChars[i] = string.char(xb)
	end
	cachedToken = table.concat(tokenChars)
	lastTokenTick = tick()
	return cachedToken
end

-- Bypass Metamethod System
local StellarBypassSystem = {
	__properties = {
		__captured_data = nil,
		__test_bypass_enabled = true,
		__original_metatables = {},
		__reverted_remotes = setmetatable({}, { __mode = "k" })
	}
}
function StellarBypassSystem.isValidRemoteArgs(args)
	return #args >= 4 and typeof(args[4]) == "CFrame"
end
pcall(function()
	local mt = getrawmetatable(game)
	local old = mt.__index
	setreadonly(mt, false)
	mt.__index = function(self, key)
		if typeof(self) == "Instance" then
			if (key == "FireServer" and self:IsA("RemoteEvent")) or (key == "InvokeServer" and self:IsA("RemoteFunction")) then
				return function(instance, ...)
					if not instance then return end
					local args = { ... }
					if StellarBypassSystem.isValidRemoteArgs(args) then
						if not StellarBypassSystem.__properties.__captured_data then
							StellarBypassSystem.__properties.__captured_data = {
								remote = instance,
								args = args,
								func = old(instance, key)
							}
						end
						if not StellarBypassSystem.__properties.__reverted_remotes[instance] then
							StellarBypassSystem.__properties.__reverted_remotes[instance] = args
						end
					end
					return old(self, key)(instance, ...)
				end
			end
		end
		return old(self, key)
	end
	setreadonly(mt, true)
end)

-- Sensor Module
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

-- Curve Provider
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

-- Parry Execution Core
local Cache_Update_Tick = 0
local Last_Positions_Cache = {}

local function fireParry(precalc_cframe)
	if not Stellar.__properties.__first_parry_done then
		Stellar.__properties.__first_parry_done = true
		pcall(function()
			local conns = getconnections(LocalPlayer.PlayerGui.Hotbar.Block.Activated)
			if #conns > 0 then
				for _, connection in pairs(conns) do connection:Fire() end
			end
		end)
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
	if Stellar.ZX_Parry.Hooked and Stellar.ZX_Parry.Remote then
		local keyIndex = Stellar.ZX_Parry.KeyTable and Stellar.ZX_Parry.KeyTable[3]
		local currentKey = keyIndex and Stellar.ZX_Parry.KeyTable[1][keyIndex]
		if currentKey then
			local token = generateToken(currentKey)
			if token then
				Stellar.__properties.__last_global_parry = tick()
				pcall(function()
					Stellar.ZX_Parry.Remote:FireServer(
						Stellar.ZX_Parry.ParryHash, currentKey, token, 0.5, pCF, Last_Positions_Cache, {
							cam.ViewportSize.X / 2,
							cam.ViewportSize.Y / 2
						}, false)
				end)
				return
			end
		end
	end
	local captured = StellarBypassSystem.__properties.__captured_data
	if captured and captured.remote and captured.func then
		local vp = cam.ViewportSize
		Stellar.__properties.__last_global_parry = tick()
		pcall(function()
			captured.func(captured.remote, captured.args[1], captured.args[2], captured.args[3], pCF, Last_Positions_Cache, {
				vp.X / 2,
				vp.Y / 2
			}, captured.args[7])
		end)
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

-- Animation Provider
Stellar.animation = {}
local SwordAPI = ReplicatedStorage:WaitForChild("Shared", 9e9):WaitForChild("SwordAPI", 9e9)
local last_anim_tick = 0
function Stellar.animation.play_grab_parry()
	if not Stellar.__properties.__play_animation or tick() - last_anim_tick < 0.25 then return end
	last_anim_tick = tick()
	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass('Humanoid')
	local animator = humanoid and humanoid:FindFirstChildOfClass('Animator')
	if not humanoid or not animator then return end
	local sword_name = character:GetAttribute('CurrentlyEquippedSword')
	if not sword_name or sword_name == "" then return end
	local sword_api = SwordAPI:WaitForChild("Collection", 9e9)
	local parry_animation = sword_api:WaitForChild("Default", 9e9):FindFirstChild('GrabParry')
	if not parry_animation then return end
	local success, sword_data = pcall(function()
		return ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(sword_name)
	end)
	if success and type(sword_data) == 'table' and sword_data then
		for _, object in pairs(sword_api:GetChildren()) do
			if object.Name == sword_data then
				local animation_type = object:FindFirstChild('GrabParry') and 'GrabParry' or 'Grab'
				if object:FindFirstChild(animation_type) then
					parry_animation = object[animation_type]
				end
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

-- Advanced Kinematic Acceleration & Curve Detector
Stellar.detection = {
	__ball_properties = {},
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
	local ballPos = ball.Position
	local playerPos = playerPart.Position
	local toPlayerVec = playerPos - ballPos
	local distance = toPlayerVec.Magnitude

	if distance <= 16 then return false end

	local toPlayerDir = toPlayerVec / distance
	local velocityDir = velocity / speed
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

	if now - props.last_ability_check > 0.1 then
		props.last_ability_check = now
		if ball:FindFirstChild('AeroDynamicSlashVFX') or (Runtime and Runtime:FindFirstChild('Tornado')) then
			props.ability_tick = now
		end
	end
	local hasAbility = (now - props.ability_tick) < 1.0

	if now - props.last_ping_tick > 1.0 then
		props.last_ping_tick = now
		local pingVal = 50
		pcall(function() pingVal = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		props.last_ping = math.clamp(pingVal / 1000, 0, 0.15)
	end
	local ping = props.last_ping

	local accelDir = accelMagnitude > 0 and (props.smooth_accel_vec / accelMagnitude) or Vector3.new()
	local currentDot = toPlayerDir:Dot(velocityDir)
	local accelDot = toPlayerDir:Dot(accelDir)

	local confidence = 0
	local adaptive_accel_thresh = math.max(speed * 0.25, 25)
	local angular_weight = (distance < 35) and 40 or 50

	confidence = confidence + math.clamp((accelMagnitude / adaptive_accel_thresh) * 0.4, 0, 0.4)
	confidence = confidence + math.clamp((props.smooth_angular / angular_weight) * 0.4, 0, 0.4)
	if hasAbility then confidence = confidence + 0.2 end
	if accelDot > 0.35 then confidence = confidence + 0.2 end

	local reachTime = distance / speed
	local effective_ping = ping + 0.055
	local shield_linger = math.clamp(1 - (speed / 500), 0, 1) * 0.2
	local required_tti = effective_ping + 0.05 + shield_linger
	local dynamic_range = math.clamp(21 + (speed * 0.008), 21, 40)
	local required_confidence = (distance < 35) and 0.58 or 0.62

	if confidence > required_confidence then
		local lookAheadTime = (distance < 35) and math.clamp(reachTime, 0.01, 0.12) or math.clamp(reachTime, 0.01, 0.2)
		local predictedPos = ballPos + (velocity * lookAheadTime) + (0.5 * props.smooth_accel_vec * lookAheadTime * lookAheadTime)
		local predictedDistance = (playerPos - predictedPos).Magnitude

		local is_getting_closer = predictedDistance <= (distance + 5)
		if is_getting_closer then
			local danger_radius = (distance < 35) and 18 or 25
			if predictedDistance < danger_radius or distance <= dynamic_range then
				local flatToPlayerDir = Vector3.new(toPlayerDir.X, 0, toPlayerDir.Z)
				local flatVelocityDir = Vector3.new(velocityDir.X, 0, velocityDir.Z)
				flatToPlayerDir = flatToPlayerDir.Magnitude > 0 and flatToPlayerDir.Unit or Vector3.new(0, 0, 1)
				flatVelocityDir = flatVelocityDir.Magnitude > 0 and flatVelocityDir.Unit or flatToPlayerDir

				local horizontalDot = flatToPlayerDir:Dot(flatVelocityDir)
				if horizontalDot < 0.4 or distance <= dynamic_range then
					return true
				end
			end
		end
	end

	local dynamic_dot_threshold = 1.0 - math.exp(-speed / 1500) * 0.15
	if currentDot > dynamic_dot_threshold then
		if reachTime <= required_tti or distance <= dynamic_range then
			return true
		end
	end

	return false
end

-- Auto Parry Hardware-Agnostic Core Loop
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
		
		-- Trajectory Processing & Parry Trigger
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

			-- Target Tracking Reset to Prevent Triangle Loop
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
			local distance = (playerPos - ballPos).Magnitude
			local ballSpeed = math.max(velocity.Magnitude, 0)
			
			if not isTargeted or parryFlag then continue end

			-- RTT Debounce Guard against Triangle Loop
			local pingValue = 0
			pcall(function() pingValue = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
			local pingSec = pingValue / 1000
			local rttDebounce = math.max(0.12, pingSec * 1.2)
			
			if tick() - (Stellar.__properties.__last_global_parry or 0) < rttDebounce then
				continue
			end

			-- Hardware-Agnostic TTI Calculation
			local approachVec = (playerPos - ballPos).Unit
			local approachSpeed = velocity:Dot(approachVec)
			local tti = (approachSpeed > 0) and (distance / approachSpeed) or math.huge
			
			local isCurved = Stellar.detection.is_curved(ball)
			
			-- Frame-Delta (dt) Compensated Reaction Window Formula
			local fpsCompensatedWindow = pingSec + (1.75 * dt) + math.clamp(ballSpeed / 1200, 0, 0.08)
			local distanceThreshold = 15 + (Stellar.__properties.__accuracy / 10)
			
			if isCurved then
				fpsCompensatedWindow = fpsCompensatedWindow * 0.20
				distanceThreshold = math.clamp(distanceThreshold * 0.20, 2.0, 5.0)
			end
			
			if (tti <= fpsCompensatedWindow or distance <= distanceThreshold) then
				local cachedCF = Stellar.curve.get_cframe()
				if getgenv().AutoParryMode == "Keypress" then 
					Stellar.parry.keypress(cachedCF) 
				else 
					Stellar.parry.execute_action(cachedCF) 
				end
				
				parryFlag = true
				Stellar.__properties.__last_global_parry = tick()
				
				task.spawn(function()
					task.wait(rttDebounce)
					parryFlag = false
				end)
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

-- UI Controls Registration
local autoparry_module = AutoparryTab:create_module({
	title = "Auto Parry Core",
	description = "Kinematic trajectory & hardware-compensated timing",
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
	value = 85,
	round_number = true,
	callback = function(value)
		Stellar.__properties.__accuracy = value
	end
})
autoparry_module:create_dropdown({
	title = "Parry Mode",
	flag = "ParryMode",
	options = { "Remote", "Keypress" },
	maximum_options = 1,
	callback = function(value) getgenv().AutoParryMode = value end
})

library:load()
Library.SendNotification({ title = "Stellar Engine", text = "V3.40 Refactored & Loaded.", duration = 3 })
