--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  S T E L L A R   U I   ·   "Ethereal Edition"                        ║
    ║                                                                      ║
    ║  A ground-up visual redesign of the Stellar UI library. It adopts    ║
    ║  the Ethereal design language — soft layered panels, hairline        ║
    ║  borders, considered typography, fluid spring motion — while        ║
    ║  keeping the entire Stellar component API intact:                    ║
    ║                                                                      ║
    ║      library:create_tab(name, icon)                                  ║
    ║      tab:create_module{ ... }        module:create_slider{ ... }     ║
    ║      module:create_toggle{ ... }     module:create_dropdown{ ... }   ║
    ║      module:create_keybind{ ... }    module:create_textbox{ ... }    ║
    ║      module:create_button{ ... }     module:create_colorpicker{ ... }║
    ║                                                                      ║
    ║  Everything is themeable, animated and mobile aware.                 ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

--=====================================================================
--  Services
--=====================================================================
local cloneref = cloneref or function(service) return service end

local CoreGui          = cloneref(game:GetService('CoreGui'))
local Lighting         = cloneref(game:GetService('Lighting'))
local Debris           = cloneref(game:GetService('Debris'))
local TweenService     = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local TextService      = cloneref(game:GetService('TextService'))
local HttpService      = cloneref(game:GetService('HttpService'))
local ContentProvider  = cloneref(game:GetService('ContentProvider'))
local Players          = cloneref(game:GetService('Players'))
local RunService       = cloneref(game:GetService('RunService'))
local Workspace        = cloneref(game:GetService('Workspace'))

local LocalPlayer = Players.LocalPlayer

local FONT_HEAD = 'rbxasset://fonts/families/GothamSSm.json'
local FONT_BODY = 'rbxasset://fonts/families/SourceSansPro.json'

--=====================================================================
--  Localisation  (kept 1:1 with the original Stellar "GG" contract)
--=====================================================================
getgenv().GG = getgenv().GG or {
    SelectedLanguage = 'en',
    Language = {
        CheckboxEnabled  = 'Enabled',
        CheckboxDisabled = 'Disabled',
        SliderValue      = 'Value',
        DropdownSelect   = 'Select',
        DropdownNone     = 'None',
        DropdownSelected = 'Selected',
        ButtonClick      = 'Click',
        TextboxEnter     = 'Enter',
        ModuleEnabled    = 'Enabled',
        ModuleDisabled   = 'Disabled',
        TabGeneral       = 'General',
        TabSettings      = 'Settings',
        Loading          = 'Loading...',
        Error            = 'Error',
        Success          = 'Success'
    }
}

local GG = getgenv().GG
local LANG = GG.Language
local function tr(key, fallback)
    local value = LANG and LANG[key]
    if value == nil then return fallback or key end
    return value
end

--=====================================================================
--  Theme engine
--  Every colour in the interface flows through this table. Objects are
--  registered through `bind()` so `library:set_theme()` can live-swap
--  the entire palette without rebuilding the window.
--=====================================================================
local Theme_Presets = {
    -- Default: the cool indigo/sapphire palette from the reference shot.
    Stellar = {
        Accent      = Color3.fromRGB(88, 132, 255),
        Accent_2    = Color3.fromRGB(138, 104, 255),
        Accent_Soft = Color3.fromRGB(30, 44, 92),
        Panel       = Color3.fromRGB(11, 12, 21),
        Panel_2     = Color3.fromRGB(16, 18, 30),
        Panel_3     = Color3.fromRGB(23, 26, 41),
        Panel_4     = Color3.fromRGB(31, 35, 54),
        Border      = Color3.fromRGB(38, 43, 64),
        Text        = Color3.fromRGB(232, 234, 244),
        Muted       = Color3.fromRGB(140, 146, 170),
        Dim         = Color3.fromRGB(92, 98, 124),
        NotEnabled  = Color3.fromRGB(26, 29, 44),
        Success     = Color3.fromRGB(86, 214, 154),
        Warning     = Color3.fromRGB(230, 188, 100),
        Danger      = Color3.fromRGB(240, 100, 122)
    },
    -- Faithful to Ethereal.lua's own rose / graphite palette.
    Ethereal = {
        Accent      = Color3.fromRGB(203, 104, 118),
        Accent_2    = Color3.fromRGB(232, 138, 118),
        Accent_Soft = Color3.fromRGB(48, 24, 30),
        Panel       = Color3.fromRGB(12, 12, 14),
        Panel_2     = Color3.fromRGB(17, 17, 20),
        Panel_3     = Color3.fromRGB(23, 23, 28),
        Panel_4     = Color3.fromRGB(30, 30, 36),
        Border      = Color3.fromRGB(45, 45, 52),
        Text        = Color3.fromRGB(232, 232, 240),
        Muted       = Color3.fromRGB(144, 144, 160),
        Dim         = Color3.fromRGB(96, 96, 112),
        NotEnabled  = Color3.fromRGB(26, 26, 30),
        Success     = Color3.fromRGB(96, 212, 160),
        Warning     = Color3.fromRGB(230, 188, 64),
        Danger      = Color3.fromRGB(220, 96, 110)
    },
    Emerald = {
        Accent      = Color3.fromRGB(72, 199, 142),
        Accent_2    = Color3.fromRGB(120, 220, 170),
        Accent_Soft = Color3.fromRGB(18, 52, 40),
        Panel       = Color3.fromRGB(10, 15, 14),
        Panel_2     = Color3.fromRGB(15, 22, 20),
        Panel_3     = Color3.fromRGB(21, 31, 28),
        Panel_4     = Color3.fromRGB(28, 42, 37),
        Border      = Color3.fromRGB(38, 55, 48),
        Text        = Color3.fromRGB(230, 240, 236),
        Muted       = Color3.fromRGB(136, 156, 148),
        Dim         = Color3.fromRGB(88, 108, 100),
        NotEnabled  = Color3.fromRGB(23, 34, 30),
        Success     = Color3.fromRGB(120, 226, 168),
        Warning     = Color3.fromRGB(230, 188, 100),
        Danger      = Color3.fromRGB(232, 104, 122)
    },
    Amethyst = {
        Accent      = Color3.fromRGB(163, 116, 255),
        Accent_2    = Color3.fromRGB(214, 120, 255),
        Accent_Soft = Color3.fromRGB(42, 28, 74),
        Panel       = Color3.fromRGB(13, 11, 20),
        Panel_2     = Color3.fromRGB(19, 16, 29),
        Panel_3     = Color3.fromRGB(27, 22, 40),
        Panel_4     = Color3.fromRGB(36, 30, 53),
        Border      = Color3.fromRGB(50, 42, 72),
        Text        = Color3.fromRGB(236, 232, 246),
        Muted       = Color3.fromRGB(150, 142, 176),
        Dim         = Color3.fromRGB(102, 94, 128),
        NotEnabled  = Color3.fromRGB(29, 24, 44),
        Success     = Color3.fromRGB(110, 214, 168),
        Warning     = Color3.fromRGB(232, 190, 108),
        Danger      = Color3.fromRGB(240, 104, 140)
    }
}

local Theme = {}
for key, value in pairs(Theme_Presets.Stellar) do
    Theme[key] = value
end

local Theme_Name = 'Stellar'

local Theme_Bindings = {}
local Theme_Functions = {}

-- Register a colour property so it follows live theme changes.
local function bind(object, property, key)
    if not object then return object end
    table.insert(Theme_Bindings, { object = object, property = property, key = key })
    if Theme[key] ~= nil then
        object[property] = Theme[key]
    end
    return object
end

-- Register an arbitrary callback for things gradients / composite colours.
local function bind_fn(fn)
    table.insert(Theme_Functions, fn)
    fn()
end

local function apply_theme()
    for _, entry in ipairs(Theme_Bindings) do
        local object = entry.object
        if object and object.Parent and Theme[entry.key] ~= nil then
            object[entry.property] = Theme[entry.key]
        end
    end
    for _, fn in ipairs(Theme_Functions) do
        pcall(fn)
    end
end

--=====================================================================
--  Tiny instance / tween helpers
--=====================================================================
local function create(class, properties, parent)
    local object = Instance.new(class)
    if properties then
        for property, value in pairs(properties) do
            object[property] = value
        end
    end
    if parent then object.Parent = parent end
    return object
end

local function tween(object, duration, properties, style, direction)
    if not object then return end
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

-- An infinitely repeating tween. The caller keeps the handle so the motion
-- can be cancelled when the state that needs it goes away (e.g. a status dot
-- that switched off).
local function looping_tween(object, duration, properties, style, direction, reverses)
    if not object then return nil end
    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Linear,
        direction or Enum.EasingDirection.Out,
        -1, -- repeat forever
        reverses or false,
        0
    )
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

-- Short "pop" entrance: find-or-create a UIScale, jump it below 1 and spring
-- it back. A resting scale of exactly 1 renders identically to no scale, so
-- leaving the child behind is harmless.
local function pop_scale(object, from, to, duration, style)
    if not object or not object.Parent then return nil end
    local scale = object:FindFirstChild('StellarPopScale')
    if not scale then
        scale = create('UIScale', { Name = 'StellarPopScale', Scale = 1 }, object)
    end
    scale.Scale = from or 0.96
    tween(scale, duration or 0.26, { Scale = to or 1 }, style or Enum.EasingStyle.Back)
    return scale
end

local function corner(parent, radius, aspect)
    return create('UICorner', {
        CornerRadius = aspect and UDim.new(aspect, radius) or UDim.new(0, radius)
    }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return create('UIStroke', {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end

local function padding(parent, top, right, bottom, left)
    return create('UIPadding', {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0)
    }, parent)
end

local function list_layout(parent, properties)
    local props = properties or {}
    props.SortOrder = props.SortOrder or Enum.SortOrder.LayoutOrder
    return create('UIListLayout', props, parent)
end

local function gradient(parent, color_sequence, rotation, transparency)
    local grad = create('UIGradient', {
        Color = color_sequence,
        Rotation = rotation or 0
    }, parent)
    if transparency then grad.Transparency = transparency end
    return grad
end

local function accent_gradient(parent, rotation)
    local grad = gradient(parent, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent_2)
    }), rotation or 0)
    bind_fn(function()
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.Accent_2)
        })
    end)
    return grad
end

local function font(weight)
    return Font.new(FONT_HEAD, weight or Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
end

local function body_font(weight)
    return Font.new(FONT_BODY, weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

local function sound(parent, id, volume)
    return create('Sound', {
        Name = 'StellarSound',
        SoundId = 'rbxassetid://' .. tostring(id),
        Volume = volume or 0.4
    }, parent)
end

local function hex(color)
    return string.format('#%02X%02X%02X',
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5))
end

local function measure_text(text, width, text_size, weight)
    text = tostring(text or '')
    local ok, bounds = pcall(function()
        local params = Instance.new('GetTextBoundsParams')
        params.Text = text
        params.Font = Font.new(FONT_HEAD, weight or Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        params.Size = text_size
        params.Width = width
        return TextService:GetTextBoundsAsync(params)
    end)
    if ok and bounds then
        return math.max(text_size * 1.35, bounds.Y)
    end
    local per_line = math.max(1, math.floor(width / (text_size * 0.56)))
    local lines = math.max(1, math.ceil(#text / per_line))
    return text_size * 1.35 * lines
end

--=====================================================================
--  Connection bookkeeping
--=====================================================================
local Connections = {}

function Connections:disconnect(key)
    local connection = self[key]
    if connection and typeof(connection) == 'RBXScriptConnection' then
        pcall(function() connection:Disconnect() end)
    end
    self[key] = nil
end

function Connections:disconnect_all()
    local keys = {}
    for key in pairs(self) do
        if typeof(self[key]) == 'RBXScriptConnection' then
            table.insert(keys, key)
        end
    end
    for _, key in ipairs(keys) do
        pcall(function() self[key]:Disconnect() end)
        self[key] = nil
    end
end

--=====================================================================
--  Config persistence (same Stellar/<gameId>.json format as before)
--=====================================================================
local Config = {}

local SESSION_DIR = 'Stellar'
local NAMED_DIR = 'Stellar/configs'

local function sanitize_name(name)
    name = tostring(name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    -- Keep it a single file name: no path separators, no traversal.
    name = name:gsub('[\\/]+', '_'):gsub('%.%.', '_')
    name = name:gsub('[%c]', '')
    if #name > 64 then name = name:sub(1, 64) end
    return name
end

local function normalize(config)
    if type(config) ~= 'table' then
        config = { _flags = {}, _keybinds = {}, _library = {} }
    end
    config._flags = config._flags or {}
    config._keybinds = config._keybinds or {}
    config._library = config._library or {}
    return config
end

function Config:ensure_folder()
    pcall(function()
        if isfolder and makefolder then
            if not isfolder(SESSION_DIR) then makefolder(SESSION_DIR) end
            if not isfolder(NAMED_DIR) then makefolder(NAMED_DIR) end
        end
    end)
end

function Config:save(file_name, config)
    self:ensure_folder()
    if type(writefile) ~= 'function' then return false end
    local ok, result = pcall(function()
        writefile(SESSION_DIR .. '/' .. tostring(file_name) .. '.json', HttpService:JSONEncode(config))
        return true
    end)
    if not ok then
        warn('[Stellar] failed to save config:', result)
        return false
    end
    return true
end

function Config:load(file_name)
    local ok, result = pcall(function()
        if not (isfile and readfile) then return nil end
        if not isfile(SESSION_DIR .. '/' .. tostring(file_name) .. '.json') then
            return nil
        end
        local raw = readfile(SESSION_DIR .. '/' .. tostring(file_name) .. '.json')
        if not raw or raw == '' then return nil end
        return HttpService:JSONDecode(raw)
    end)

    if not ok then
        warn('[Stellar] failed to load config:', result)
    end

    return normalize(result)
end

--=====================================================================
--  Named configs  ("saved configs")
--  Stored as Stellar/configs/<name>.json so players can keep several
--  profiles (e.g. "legit", "rage") and switch between them.
--=====================================================================
function Config:named_path(name)
    return NAMED_DIR .. '/' .. sanitize_name(name) .. '.json'
end

function Config:exists_named(name)
    if not (isfile and sanitize_name(name) ~= '') then return false end
    local ok, exists = pcall(isfile, self:named_path(name))
    return ok and exists == true
end

function Config:save_named(name, config)
    name = sanitize_name(name)
    if name == '' then return false end
    if type(writefile) ~= 'function' then return false end
    self:ensure_folder()
    local ok, result = pcall(function()
        writefile(self:named_path(name), HttpService:JSONEncode(config))
        return true
    end)
    if not ok then
        warn('[Stellar] failed to save named config:', result)
        return false
    end
    return true
end

function Config:load_named(name)
    name = sanitize_name(name)
    if name == '' then return nil end
    if not (isfile and readfile) then return nil end
    if not self:exists_named(name) then return nil end
    local ok, result = pcall(function()
        local raw = readfile(self:named_path(name))
        if not raw or raw == '' then return nil end
        return HttpService:JSONDecode(raw)
    end)
    if not ok then
        warn('[Stellar] failed to load named config:', result)
        return nil
    end
    if type(result) ~= 'table' then return nil end
    return normalize(result)
end

function Config:delete_named(name)
    name = sanitize_name(name)
    if name == '' then return false end
    if type(delfile) ~= 'function' then return false end
    if not self:exists_named(name) then return false end
    local ok = pcall(delfile, self:named_path(name))
    return ok
end

function Config:list_named()
    local names = {}
    if type(listfiles) ~= 'function' then return names end
    local ok, files = pcall(listfiles, NAMED_DIR)
    if not ok or type(files) ~= 'table' then return names end
    for _, path in ipairs(files) do
        local name = tostring(path):match('([^/\\]+)%.json$')
        if name then table.insert(names, name) end
    end
    table.sort(names)
    return names
end

--=====================================================================
--  Asset resolution (accepts raw ids, rbxassetid://, marketplace urls)
--=====================================================================
local Util = {}

function Util:map(value, in_min, in_max, out_min, out_max)
    return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function Util:resolve_asset_id(id)
    if id == nil then return nil end
    id = tostring(id)
    if id == '' then return nil end
    if id:match('^rbxassetid://') or id:match('^rbxthumb://') or id:match('^http') or id:match('^rbxasset://') then
        return id
    end
    local digits = id:match('(%d+)')
    if not digits then return nil end
    return 'rbxassetid://' .. digits
end

--=====================================================================
--  Animated logo (sprite sheets)
--=====================================================================
-- The original Stellar library shipped a little animated cat sprite and
-- Ethereal ships its own animated mark. Both are plain sprite sheets, so
-- we can play either one by stepping ImageRectOffset on an ImageLabel.
--
-- Each entry: image + the sheet's pixel size + its grid + frame count/fps.
local Logo_Animations = {
    Stellar = {
        image   = 'rbxassetid://74080484918102', -- Stellar cat (5 frames)
        width   = 60,  height = 40,
        columns = 3,   rows   = 2,
        frames  = 5,   fps    = 10
    },
    Ethereal = {
        image   = 'rbxassetid://133009150415671', -- Ethereal mark (8 frames)
        width   = 150, height = 120,
        columns = 3,   rows   = 3,
        frames  = 8,   fps    = 12
    }
}

-- Plays a sprite sheet on an ImageLabel. Returns a stop() function. The
-- loop self-terminates as soon as the label leaves the DataModel, so it
-- is safe to fire-and-forget.
function Util:animate_sprite(image_label, sheet)
    local noop = function() end
    if not image_label or type(sheet) ~= 'table' then return noop end

    local columns = math.max(1, tonumber(sheet.columns) or 1)
    local rows    = math.max(1, tonumber(sheet.rows) or 1)
    local frames  = math.max(1, tonumber(sheet.frames) or (columns * rows))
    local fps     = math.max(1, tonumber(sheet.fps) or 10)

    if sheet.image then
        image_label.Image = Util:resolve_asset_id(sheet.image) or sheet.image
    end

    local sheet_width  = tonumber(sheet.width) or 0
    local sheet_height = tonumber(sheet.height) or 0
    if sheet_width > 0 and sheet_height > 0 then
        image_label.ImageRectSize = Vector2.new(
            math.floor(sheet_width / columns),
            math.floor(sheet_height / rows)
        )
    end

    local frame_size = image_label.ImageRectSize
    if not frame_size or frame_size.X <= 0 or frame_size.Y <= 0 then
        return noop
    end

    local offsets = {}
    for index = 0, frames - 1 do
        local column = index % columns
        local row = math.floor(index / columns)
        offsets[index + 1] = Vector2.new(column * frame_size.X, row * frame_size.Y)
    end

    image_label.ImageRectOffset = offsets[1]

    local stopped = false
    local index = 1
    task.spawn(function()
        while not stopped and image_label and image_label.Parent do
            task.wait(1 / fps)
            if stopped or not image_label or not image_label.Parent then break end
            index = (index % frames) + 1
            image_label.ImageRectOffset = offsets[index]
        end
    end)

    return function() stopped = true end
end

-- Applies either an animated sprite sheet or a plain static image to a
-- logo ImageLabel and returns a stop() function.
--
-- options = {
--     animation = 'Stellar' | 'Ethereal' | <sheet table> | false,
--     image     = <asset id>   -- when given, shown statically
-- }
function Util:apply_logo(image_label, options)
    local noop = function() end
    if not image_label then return noop end
    options = options or {}

    local choice = options.animation
    local sheet

    if type(choice) == 'table' then
        sheet = choice
    elseif options.image == nil or options.image == false then
        if choice ~= false then
            sheet = Logo_Animations[choice or 'Stellar'] or Logo_Animations.Stellar
        end
    end

    if sheet then
        return Util:animate_sprite(image_label, sheet)
    end

    image_label.Image = Util:resolve_asset_id(options.image) or ''
    image_label.ImageRectSize = Vector2.new(0, 0)
    image_label.ImageRectOffset = Vector2.new(0, 0)
    return noop
end

-- Blends two colours; t = 0 returns `a`, t = 1 returns `b`.
local function mix_color(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

-- Approximate rendered width of the edition badge text. The chip grows and
-- shrinks with its label, so a build/version string like "ETHEREAL v2.1" fits
-- without clipping or leaving a gap.
local function edition_badge_width(text)
    local length = #tostring(text or '')
    return math.max(34, math.floor(length * 5.4) + 16)
end

-- Animated "wordmark" title (Discord-style).
--
-- A UIGradient parented to a TextLabel tints the glyphs themselves. The
-- resting glyphs are a dimmed version of the theme text colour and a bright
-- white highlight band travels across them, so the title reads as a glossy
-- shine rather than flat text. The band is roughly three glyphs wide (not the
-- one-glyph sliver it used to be), and it travels from fully off the left edge
-- to fully off the right edge before repeating, so the loop never snaps a
-- half-visible highlight back across the word.
--
-- The label's own TextColor3 is forced to white so the gradient colours are
-- shown exactly as authored, and the palette is re-authored on every theme
-- change so the sheen always matches the active typography.
--
-- options = {
--     band     = 0.4,   -- highlight width, in label widths (~3 glyphs)
--     period   = 2.4,   -- seconds for one full sweep
--     pause    = 0.9,   -- seconds to rest before sweeping again
--     rotation = 0      -- gradient angle (0 = horizontal)
-- }
--
-- Returns a stop() function.
function Util:animate_wordmark(label, options)
    local noop = function() end
    if not label then return noop end
    options = options or {}

    local band     = math.clamp(tonumber(options.band) or 0.4, 0.12, 0.6)
    local period   = math.max(0.4, tonumber(options.period) or 2.4)
    local pause    = math.max(0, tonumber(options.pause) or 0.9)
    local rotation = tonumber(options.rotation) or 0

    -- White base: the gradient is multiplied into the glyph colour, so this
    -- keeps the authored gradient exact instead of tinting it twice.
    label.TextColor3 = Color3.fromRGB(255, 255, 255)

    local lo = 0.5 - band * 0.5
    local hi = 0.5 + band * 0.5

    local function palette()
        local text = Theme.Text
        -- Resting glyphs are dimmed toward black so the white highlight band
        -- is clearly visible as it sweeps; a near-white resting colour would
        -- hide the shine entirely on the dark panel.
        local base = mix_color(text, Color3.fromRGB(0, 0, 0), 0.45)
        local bright = mix_color(text, Color3.fromRGB(255, 255, 255), 0.95)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, base),
            ColorSequenceKeypoint.new(lo, base),
            ColorSequenceKeypoint.new(0.50, bright),
            ColorSequenceKeypoint.new(hi, base),
            ColorSequenceKeypoint.new(1.00, base)
        })
    end

    -- Travel the highlight from fully off the left edge to fully off the right
    -- edge before resetting, so the loop never snaps a half-visible sheen
    -- across the word; the pause then reads as a natural gap between passes.
    local from = -hi
    local to = 1 - lo

    local grad = create('UIGradient', {
        Name = 'WordmarkGradient',
        Rotation = rotation,
        Offset = Vector2.new(from, 0),
        Color = palette()
    }, label)
    grad:SetAttribute('BandWidth', band)

    bind_fn(function()
        if grad and grad.Parent then
            grad.Color = palette()
        end
    end)

    local stopped = false
    task.spawn(function()
        while not stopped and label and label.Parent and grad and grad.Parent do
            grad.Offset = Vector2.new(from, 0)
            tween(grad, period, { Offset = Vector2.new(to, 0) }, Enum.EasingStyle.Sine)
            task.wait(period)
            if stopped then break end
            task.wait(pause)
        end
    end)

    return function()
        stopped = true
        if grad and grad.Parent then grad:Destroy() end
    end
end

--=====================================================================
--  Acrylic backdrop blur (ported from Stellar — quality gated)
--=====================================================================
local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)
    self:setup()
    return self
end

function AcrylicBlur:create_folder()
    local old = Workspace.CurrentCamera:FindFirstChild('StellarAcrylic')
    if old then
        Debris:AddItem(old, 0)
    end
    local folder = create('Folder', { Name = 'StellarAcrylic' }, Workspace.CurrentCamera)
    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
    local dof = Lighting:FindFirstChild('StellarAcrylic') or create('DepthOfFieldEffect', {}, Lighting)
    dof.FarIntensity = 0
    dof.FocusDistance = 0.05
    dof.InFocusRadius = 0.1
    dof.NearIntensity = 1
    dof.Name = 'StellarAcrylic'
    dof.Parent = Lighting
end

function AcrylicBlur:create_frame()
    local frame = create('Frame', {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    }, self._object)
    self._frame = frame
end

function AcrylicBlur:create_root()
    local part = create('Part', {
        Name = 'Root',
        Color = Color3.new(0, 0, 0),
        Material = Enum.Material.Glass,
        Size = Vector3.new(1, 1, 0),
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        Locked = true,
        CastShadow = false,
        Transparency = 0.98
    }, self._folder)

    create('SpecialMesh', {
        Name = 'Mesh',
        MeshType = Enum.MeshType.Brick,
        Offset = Vector3.new(0, 0, -0.000001)
    }, part)

    self._root = part
end

function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()
    self:create_frame()
    self:render(0.001)
    self:check_quality_level()
end

function AcrylicBlur:render(distance)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new()
    }

    local function update_positions(size, position)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end

    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right

        local ray1 = Workspace.CurrentCamera:ScreenPointToRay(top_left.X, top_left.Y)
        local ray2 = Workspace.CurrentCamera:ScreenPointToRay(top_right.X, top_right.Y)
        local ray3 = Workspace.CurrentCamera:ScreenPointToRay(bottom_right.X, bottom_right.Y)

        local p1 = ray1.Origin + ray1.Direction * distance
        local p2 = ray2.Origin + ray2.Direction * distance
        local p3 = ray3.Origin + ray3.Direction * distance

        if not self._root or not self._root.Parent then return end

        local width = (p2 - p1).Magnitude
        local height = (p2 - p3).Magnitude

        self._root.CFrame = CFrame.fromMatrix(
            (p1 + p3) / 2,
            Workspace.CurrentCamera.CFrame.XVector,
            Workspace.CurrentCamera.CFrame.YVector,
            Workspace.CurrentCamera.CFrame.ZVector
        )

        local mesh = self._root:FindFirstChild('Mesh')
        if mesh then
            mesh.Scale = Vector3.new(math.max(width, 0.01), math.max(height, 0.01), 0)
        end
    end

    local function on_change()
        if not self._frame or not self._frame.Parent then return end
        local offset = Util:map(Workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
        update_positions(size, position)
        task.spawn(update)
    end

    Connections['acrylic_cframe'] = Workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections['acrylic_viewport'] = Workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(update)
    Connections['acrylic_fov'] = Workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(update)
    Connections['acrylic_pos'] = self._frame:GetPropertyChangedSignal('AbsolutePosition'):Connect(on_change)
    Connections['acrylic_size'] = self._frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(on_change)

    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local ok, settings = pcall(function()
        return UserSettings().GameSettings
    end)
    if not ok or not settings then return end

    local quality = settings.SavedQualityLevel.Value
    self:set_visible(quality >= 8)

    Connections['acrylic_quality'] = settings:GetPropertyChangedSignal('SavedQualityLevel'):Connect(function()
        self:set_visible(settings.SavedQualityLevel.Value >= 8)
    end)
end

function AcrylicBlur:set_visible(state)
    if self._root and self._root.Parent then
        self._root.Transparency = state and 0.98 or 1
    end
end

--=====================================================================
--  Small vector glyphs drawn with frames (no asset dependencies)
--=====================================================================
local function draw_chevron(parent, size, color, thickness)
    size = size or 8
    thickness = thickness or 1.6
    local holder = create('Frame', {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5)
    }, parent)

    create('Frame', {
        Size = UDim2.new(0, size * 0.62, 0, thickness),
        Position = UDim2.new(0, size * 0.02, 0, size * 0.34),
        AnchorPoint = Vector2.new(0, 0.5),
        Rotation = 40,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    create('Frame', {
        Size = UDim2.new(0, size * 0.62, 0, thickness),
        Position = UDim2.new(1, -size * 0.02, 0, size * 0.34),
        AnchorPoint = Vector2.new(1, 0.5),
        Rotation = -40,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    return holder
end

local function draw_check(parent, color, thickness)
    thickness = thickness or 1.8
    local holder = create('Frame', {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, parent)

    create('Frame', {
        Size = UDim2.new(0, 5, 0, thickness),
        Position = UDim2.new(0.5, -2, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Rotation = 45,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    create('Frame', {
        Size = UDim2.new(0, 9, 0, thickness),
        Position = UDim2.new(0.5, 1, 0.5, -1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Rotation = -45,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    return holder
end

local function draw_magnifier(parent, color, size)
    size = size or 12
    local holder = create('Frame', {
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1
    }, parent)

    local ring = create('Frame', {
        Size = UDim2.fromOffset(size * 0.62, size * 0.62),
        Position = UDim2.fromOffset(size * 0.05, size * 0.05),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, holder)
    corner(ring, 1, 1)
    create('UIStroke', {
        Color = color,
        Thickness = 1.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, ring)

    create('Frame', {
        Size = UDim2.fromOffset(size * 0.34, 1.4),
        Position = UDim2.fromOffset(size * 0.6, size * 0.66),
        Rotation = 45,
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, holder)

    return holder
end

--=====================================================================
--  Global tooltip
--=====================================================================
local Tooltip = { _gui = nil, _frame = nil, _label = nil, _token = 0 }

function Tooltip.ensure()
    if Tooltip._gui and Tooltip._gui.Parent then return end

    local gui = create('ScreenGui', {
        Name = 'StellarTooltip',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 2000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    local frame = create('Frame', {
        Name = 'Tip',
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 2
    }, gui)
    corner(frame, 6)
    stroke(frame, Theme.Border, 1, 0.2)
    padding(frame, 5, 9, 5, 9)

    local label = create('TextLabel', {
        Name = 'Text',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Medium),
        TextColor3 = Theme.Text,
        TextSize = 11,
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = '',
        ZIndex = 3
    }, frame)

    Tooltip._gui = gui
    Tooltip._frame = frame
    Tooltip._label = label
    bind(frame, 'BackgroundColor3', 'Panel_3')
    bind(label, 'TextColor3', 'Text')
end

function Tooltip.show(text)
    Tooltip.ensure()
    Tooltip._token = Tooltip._token + 1
    local token = Tooltip._token
    Tooltip._label.Text = text
    Tooltip._frame.Visible = true
    Tooltip._frame.BackgroundTransparency = 1
    Tooltip._label.TextTransparency = 1
    tween(Tooltip._frame, 0.16, { BackgroundTransparency = 0.05 })
    tween(Tooltip._label, 0.16, { TextTransparency = 0 })

    task.spawn(function()
        while Tooltip._token == token and Tooltip._frame.Visible do
            local mouse = UserInputService:GetMouseLocation()
            Tooltip._frame.Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 18)
            task.wait()
        end
    end)
end

function Tooltip.hide()
    if not Tooltip._frame then return end
    Tooltip._token = Tooltip._token + 1
    tween(Tooltip._frame, 0.12, { BackgroundTransparency = 1 })
    tween(Tooltip._label, 0.12, { TextTransparency = 1 })
    task.delay(0.13, function()
        if Tooltip._frame then Tooltip._frame.Visible = false end
    end)
end

function Tooltip.attach(object, text)
    if not object or not text then return end
    local pending = nil
    object.MouseEnter:Connect(function()
        if pending then task.cancel(pending) end
        pending = task.delay(0.4, function()
            Tooltip.show(text)
        end)
    end)
    object.MouseLeave:Connect(function()
        if pending then task.cancel(pending) pending = nil end
        Tooltip.hide()
    end)
end

--=====================================================================
--  Toast notifications
--=====================================================================
local Notifications = { _gui = nil, _container = nil }

local NOTIFY_COLORS = {
    info    = 'Accent',
    success = 'Success',
    warning = 'Warning',
    error   = 'Danger'
}

local NOTIFY_GLYPHS = {
    info = 'i',
    success = '✓',
    warning = '!',
    error = '×'
}

function Notifications.ensure()
    if Notifications._gui and Notifications._gui.Parent then return end

    local gui = create('ScreenGui', {
        Name = 'StellarNotifications',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1500,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    local container = create('Frame', {
        Name = 'Stack',
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.new(0, 306, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, gui)

    list_layout(container, { Padding = UDim.new(0, 10) })

    Notifications._gui = gui
    Notifications._container = container
end

function Notifications.push(settings)
    settings = settings or {}
    Notifications.ensure()

    local kind = settings.type or 'info'
    local color_key = NOTIFY_COLORS[kind] or 'Accent'
    local title_text = settings.title or tr('Success', 'Notification')
    local body_text = tostring(settings.text or '')

    -- Compute the toast height up front. Relying on AutomaticSize here made
    -- the card jump around because its children are absolutely positioned.
    local width = 306
    local text_width = width - 72
    local body_height = body_text ~= '' and math.max(14, measure_text(body_text, text_width, 10)) or 0
    local height = math.max(62, 31 + body_height + (body_text ~= '' and 9 or 0) + 16)

    local toast = create('CanvasGroup', {
        Name = 'Toast',
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Panel_2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ClipsDescendants = false
    }, Notifications._container)
    corner(toast, 10)
    local toast_stroke = stroke(toast, Theme.Border, 1, 0.25)
    bind(toast, 'BackgroundColor3', 'Panel_2')

    local accent_bar = create('Frame', {
        Name = 'Accent',
        Size = UDim2.new(0, 3, 0, math.max(16, height - 16)),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundColor3 = Theme[color_key],
        BorderSizePixel = 0
    }, toast)
    corner(accent_bar, 1, 1)
    bind(accent_bar, 'BackgroundColor3', color_key)

    local icon_holder = create('Frame', {
        Name = 'Icon',
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(15, 14),
        BackgroundColor3 = Theme[color_key],
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0
    }, toast)
    corner(icon_holder, 1, 1)
    bind(icon_holder, 'BackgroundColor3', color_key)

    -- The glyph label must fill its holder: without an explicit Size a
    -- TextLabel defaults to 0x0 and the icon is invisible.
    local icon_label = create('TextLabel', {
        Name = 'Glyph',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme[color_key],
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Text = NOTIFY_GLYPHS[kind] or 'i'
    }, icon_holder)
    bind(icon_label, 'TextColor3', color_key)

    local title = create('TextLabel', {
        Name = 'Title',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = title_text,
        Size = UDim2.new(1, -92, 0, 15),
        Position = UDim2.fromOffset(56, 15)
    }, toast)
    bind(title, 'TextColor3', 'Text')

    local body
    if body_text ~= '' then
        body = create('TextLabel', {
            Name = 'Body',
            BackgroundTransparency = 1,
            FontFace = body_font(Enum.FontWeight.Regular),
            TextColor3 = Theme.Muted,
            TextSize = 10,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = body_text,
            Size = UDim2.new(1, -72, 0, body_height),
            Position = UDim2.fromOffset(56, 33)
        }, toast)
        bind(body, 'TextColor3', 'Muted')
    end

    local close = create('TextButton', {
        Name = 'Close',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Dim,
        TextSize = 15,
        Text = '×',
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -30, 0, 9),
        AutoButtonColor = false
    }, toast)
    bind(close, 'TextColor3', 'Dim')

    local progress_track = create('Frame', {
        Name = 'ProgressTrack',
        Size = UDim2.new(1, -30, 0, 3),
        Position = UDim2.new(0, 15, 1, -11),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0
    }, toast)
    corner(progress_track, 1, 1)
    bind(progress_track, 'BackgroundColor3', 'Panel_4')

    local progress_fill = create('Frame', {
        Name = 'ProgressFill',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme[color_key],
        BorderSizePixel = 0
    }, progress_track)
    corner(progress_fill, 1, 1)
    bind(progress_fill, 'BackgroundColor3', color_key)

    local duration = tonumber(settings.duration) or 5
    local dismissed = false

    local function dismiss()
        if dismissed then return end
        dismissed = true
        -- Fade the whole group at once: a UIListLayout owns child Position,
        -- so sliding is not possible, and per-child fades can leave text
        -- floating over a transparent card.
        tween(toast, 0.28, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(toast_stroke, 0.2, { Transparency = 1 })
        task.delay(0.32, function()
            if toast then toast:Destroy() end
        end)
    end

    close.MouseButton1Click:Connect(dismiss)

    -- entrance: the group fades in while the card springs from slightly
    -- small, and the icon tile pops in ahead of the text
    tween(toast, 0.4, { GroupTransparency = 0 })
    pop_scale(toast, 0.94, 1, 0.34)
    pop_scale(icon_holder, 0.55, 1, 0.32)
    if duration > 0 then
        tween(progress_fill, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
        task.delay(duration, dismiss)
    else
        progress_track.Visible = false
    end
end

--=====================================================================
--  Loader
--=====================================================================
local Library = {}

function Library.create_loader(self, settings)
    settings = settings or {}

    local old = CoreGui:FindFirstChild('StellarLoader')
    if old then old:Destroy() end

    local accent = settings.accent_color or Theme.Accent
    local stages = settings.stages
    if type(stages) ~= 'table' or #stages == 0 then
        stages = { settings.title or 'Loading' }
    end
    local rng = Random.new()
    local particles_alive = true
    local closed = false
    local finished = false

    local gui = create('ScreenGui', {
        Name = 'StellarLoader',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    -- The weather is the *only* full-screen element. Everything else lives on
    -- the floating card below, so the loader never blacks out the viewport.
    local particle_layer = create('Frame', {
        Name = 'ParticleLayer',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 1
    }, gui)

    local weather = settings.weather
    if weather == nil then weather = 'rain' end
    local weather_count = tonumber(settings.weather_count)
        or (weather == 'snow' and 46 or 48)
    -- Seconds for a snowflake to cross the whole screen. Slow on purpose:
    -- the old 4.5-9s fall read as a hurried burst rather than calm snow.
    local snow_speed = math.max(4, tonumber(settings.snow_speed) or 16)
    particle_layer:SetAttribute('Weather', tostring(weather))
    particle_layer:SetAttribute('SnowSpeed', snow_speed)

    -- One particle falls top-to-bottom on a loop. Rain is a thin, fast streak
    -- that fades toward its tail; snow is a slow, gentle flake. The first fall
    -- keeps the particle's random starting height so the sky is populated the
    -- instant the loader appears instead of emptying and refilling as a burst.
    local function spawn_weather_particle()
        if weather == false or weather == 'none' then return end

        if weather == 'snow' then
            local flake = create('Frame', {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromOffset(rng:NextNumber(2, 4), rng:NextNumber(2, 4)),
                Position = UDim2.new(rng:NextNumber(-0.02, 1.02), 0, rng:NextNumber(-0.15, 0.95), 0),
                BackgroundColor3 = accent,
                BackgroundTransparency = rng:NextNumber(0.3, 0.72),
                BorderSizePixel = 0,
                ZIndex = 1
            }, particle_layer)
            corner(flake, 0, 1)

            task.spawn(function()
                while particles_alive and flake and flake.Parent do
                    local start_x = flake.Position.X.Scale
                    local start_y = flake.Position.Y.Scale
                    local distance = math.max(0.15, 1.12 - start_y)
                    tween(flake, snow_speed * distance, {
                        Position = UDim2.new(start_x + rng:NextNumber(-0.04, 0.04), 0, 1.12, 0)
                    }, Enum.EasingStyle.Linear)
                    task.wait(snow_speed * distance)
                    if not (particles_alive and flake and flake.Parent) then break end
                    task.wait(rng:NextNumber(0, 2))
                    if not (particles_alive and flake and flake.Parent) then break end
                    flake.Position = UDim2.new(rng:NextNumber(-0.02, 1.02), 0, -0.12, 0)
                end
            end)
        else
            local streak = create('Frame', {
                Size = UDim2.fromOffset(rng:NextNumber(1, 2), rng:NextNumber(9, 20)),
                Position = UDim2.new(rng:NextNumber(-0.02, 1.02), 0, rng:NextNumber(-0.15, 0.95), 0),
                BackgroundColor3 = accent,
                BackgroundTransparency = rng:NextNumber(0.45, 0.8),
                BorderSizePixel = 0,
                ZIndex = 1
            }, particle_layer)
            corner(streak, 1, 1)
            -- Fade the tail so each streak reads as a falling drop of light.
            gradient(streak, ColorSequence.new(accent), 90, NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(1, 1)
            }))

            task.spawn(function()
                local base_duration = rng:NextNumber(0.7, 1.4)
                while particles_alive and streak and streak.Parent do
                    local start_x = streak.Position.X.Scale
                    local start_y = streak.Position.Y.Scale
                    local distance = math.max(0.15, 1.12 - start_y)
                    tween(streak, base_duration * distance, {
                        Position = UDim2.new(start_x + rng:NextNumber(-0.02, 0.02), 0, 1.12, 0)
                    }, Enum.EasingStyle.Linear)
                    task.wait(base_duration * distance)
                    if not (particles_alive and streak and streak.Parent) then break end
                    task.wait(rng:NextNumber(0, 1.2))
                    if not (particles_alive and streak and streak.Parent) then break end
                    streak.Position = UDim2.new(rng:NextNumber(-0.02, 1.02), 0, -0.12, 0)
                end
            end)
        end
    end

    for _ = 1, weather_count do spawn_weather_particle() end

    -- ------------------------------------------------------------------
    --  Floating card: brand + clock, status checklist, animated mark,
    --  progress (ETA left / percent right) and the bottom quote.
    --  Deliberately NOT a full-screen panel — only the weather spans the
    --  viewport.
    -- ------------------------------------------------------------------
    -- Tall enough that a full 5-row status list still clears the pinned quote.
    local CARD_W, CARD_H = 520, 380
    local PAD = 22

    local card = create('CanvasGroup', {
        Name = 'LoaderCard',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(CARD_W, CARD_H),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 2
    }, gui)
    corner(card, 16)
    local card_stroke = stroke(card, Theme.Border, 1, 0.25)
    bind(card, 'BackgroundColor3', 'Panel')
    bind(card_stroke, 'Color', 'Border')

    -- Top accent hairline, matching the main window.
    local accent_line = create('Frame', {
        Name = 'AccentLine',
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    }, card)
    gradient(accent_line, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.Accent_2),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    }), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }))
    bind_fn(function()
        accent_line.BackgroundColor3 = Theme.Accent
    end)

    -- Responsive scaling so the card never looks oversized on a phone or
    -- tiny on a large display.
    local scale = create('UIScale', {}, card)
    local function update_scale()
        local camera = Workspace.CurrentCamera
        if camera then
            local viewport = camera.ViewportSize
            scale.Scale = math.clamp(
                math.min(viewport.X / (CARD_W + 120), viewport.Y / (CARD_H + 120)),
                0.62, 1.15
            )
        end
    end
    update_scale()
    local scale_connection
    local camera = Workspace.CurrentCamera
    if camera then
        scale_connection = camera:GetPropertyChangedSignal('ViewportSize'):Connect(update_scale)
    end

    local container = create('Frame', {
        Name = 'LoaderContainer',
        Size = UDim2.new(1, -PAD * 2, 1, -PAD * 2),
        Position = UDim2.fromOffset(PAD, PAD),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, card)
    list_layout(container, {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })

    -- Header: brand on the left, "07:31 PM · 00s" on the right.
    local header = create('Frame', {
        Name = 'Header',
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, container)

    local brand = create('TextLabel', {
        Name = 'Brand',
        -- Hug the text so the wordmark gradient spans the glyphs exactly.
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Text,
        TextSize = 20,
        Text = settings.brand or 'Stellar.',
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        ZIndex = 3
    }, header)
    -- Animated Discord-style wordmark: a dark→bright→dark sheen sweeps the
    -- brand text for as long as the loader is open.
    local stop_wordmark = Util:animate_wordmark(brand)

    local clock = create('TextLabel', {
        Name = 'Clock',
        Size = UDim2.fromOffset(96, 20),
        Position = UDim2.new(1, -42, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Medium),
        TextColor3 = Theme.Muted,
        TextSize = 13,
        Text = '--:-- -- ·',
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTransparency = 1,
        ZIndex = 3
    }, header)
    bind(clock, 'TextColor3', 'Muted')

    local elapsed = create('TextLabel', {
        Name = 'Elapsed',
        Size = UDim2.fromOffset(42, 20),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 12,
        Text = '0s',
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTransparency = 1,
        ZIndex = 3
    }, header)
    bind(elapsed, 'TextColor3', 'Dim')

    local divider = create('Frame', {
        Name = 'Divider',
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 3
    }, header)
    bind(divider, 'BackgroundColor3', 'Border')

    -- Live status checklist, left aligned. Every row is "> text"; the active
    -- row shows a trailing spinner, completed rows just dim.
    --
    -- The list is a *fixed* height sized for the maximum number of rows. It
    -- used to auto-size, which meant every new log line pushed the centred
    -- mark (and the progress bar) down the card. Pinning the height keeps the
    -- whole card still while the checklist fills in.
    local STATUS_ROW_H, STATUS_ROW_GAP = 18, 6
    local max_status = math.clamp(tonumber(settings.max_log_lines) or 5, 1, 5)
    local status_h = max_status * STATUS_ROW_H + (max_status - 1) * STATUS_ROW_GAP

    local status_list = create('Frame', {
        Name = 'StatusList',
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, status_h),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 3
    }, container)
    list_layout(status_list, {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, STATUS_ROW_GAP)
    })

    local status_entries = {}
    local active_entry = nil

    local function make_status_row(text)
        local row = create('Frame', {
            Name = 'StatusLine',
            LayoutOrder = #status_entries + 1,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            ZIndex = 3
        }, status_list)

        local marker = create('TextLabel', {
            Name = 'Icon',
            Size = UDim2.fromOffset(14, 18),
            BackgroundTransparency = 1,
            FontFace = font(Enum.FontWeight.Bold),
            TextColor3 = Theme.Accent,
            TextSize = 13,
            Text = '>',
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4
        }, row)

        local label = create('TextLabel', {
            Name = 'Label',
            Size = UDim2.new(1, -44, 1, 0),
            Position = UDim2.fromOffset(15, 0),
            BackgroundTransparency = 1,
            FontFace = body_font(Enum.FontWeight.Medium),
            TextColor3 = Theme.Text,
            TextSize = 13,
            Text = tostring(text),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1,
            ZIndex = 4
        }, row)

        local spin = create('TextLabel', {
            Name = 'Spinner',
            Size = UDim2.fromOffset(16, 18),
            Position = UDim2.new(1, -16, 0, 0),
            BackgroundTransparency = 1,
            FontFace = font(Enum.FontWeight.Bold),
            TextColor3 = Theme.Accent,
            TextSize = 13,
            Text = '/',
            TextXAlignment = Enum.TextXAlignment.Right,
            Visible = false,
            ZIndex = 4
        }, row)

        return { row = row, icon = marker, label = label, spinner = spin }
    end

    local function finish_active()
        local entry = active_entry
        if not entry then return end
        active_entry = nil
        if entry.spinner and entry.spinner.Parent then
            entry.spinner.Visible = false
        end
        if entry.label and entry.label.Parent then
            entry.label.TextColor3 = Theme.Dim
        end
    end

    local function add_status(text)
        if closed then return nil end
        local entry = make_status_row(text)
        entry.active = true
        active_entry = entry
        table.insert(status_entries, entry)
        if entry.spinner and entry.spinner.Parent then
            entry.spinner.Visible = true
        end
        tween(entry.label, 0.3, { TextTransparency = 0 })
        if #status_entries > max_status then
            local oldest = table.remove(status_entries, 1)
            if oldest and oldest.row then oldest.row:Destroy() end
        end
        return entry
    end

    local spinner_frames = { '/', '|', '\\', '-' }
    task.spawn(function()
        local index = 1
        while not closed do
            local entry = active_entry
            if entry and entry.spinner and entry.spinner.Parent then
                entry.spinner.Text = spinner_frames[index]
            end
            index = (index % #spinner_frames) + 1
            task.wait(0.12)
        end
    end)

    -- Centre row: a single animated mark. There is deliberately no second
    -- icon — the old orbiting accent ring read as a duplicate next to the
    -- sprite, so the sprite is now the only thing in this row, centred.
    local mark_row = create('Frame', {
        Name = 'MarkRow',
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 84),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, container)

    local mark_group = create('Frame', {
        Name = 'MarkGroup',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(84, 84),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, mark_row)

    local logo_bg = create('Frame', {
        Name = 'LogoMark',
        Size = UDim2.fromOffset(64, 64),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 4
    }, mark_group)
    corner(logo_bg, 18)
    -- A soft accent fade instead of a solid tile: the colour pools behind
    -- the top of the animation and dissolves toward the bottom, so the mark
    -- floats on the card rather than sitting in a blue square. (UIGradient
    -- composes multiplicatively with BackgroundTransparency, so the fade
    -- lives in the gradient's transparency sequence, not on the frame.)
    gradient(logo_bg, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent_2)
    }), 90, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.78),
        NumberSequenceKeypoint.new(0.6, 0.9),
        NumberSequenceKeypoint.new(1, 1)
    }))
    bind_fn(function()
        if not logo_bg.Parent then return end
        local fade = logo_bg:FindFirstChildOfClass('UIGradient')
        if fade then
            fade.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.Accent_2)
            })
        end
    end)

    local logo_image = create('ImageLabel', {
        Name = 'Logo',
        Size = UDim2.fromOffset(46, 46),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5
    }, logo_bg)
    local stop_logo = Util:apply_logo(logo_image, {
        animation = settings.animation or Library.Logo_Animation,
        image = settings.logo
    })
    -- Simple fade in — no overshoot, no scale.
    tween(logo_image, 0.45, { ImageTransparency = 0 })

    -- Progress meta: ETA stamp on the left, percentage on the right.
    local meta_row = create('Frame', {
        Name = 'ProgressMeta',
        LayoutOrder = 4,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, container)

    local eta = create('TextLabel', {
        Name = 'Eta',
        Size = UDim2.fromOffset(120, 16),
        Position = UDim2.fromOffset(0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Medium),
        TextColor3 = Theme.Muted,
        TextSize = 12,
        Text = '00:00',
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3
    }, meta_row)
    bind(eta, 'TextColor3', 'Muted')

    local percent = create('TextLabel', {
        Name = 'Percent',
        Size = UDim2.fromOffset(120, 16),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Text,
        TextSize = 13,
        Text = '0%',
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 3
    }, meta_row)
    bind(percent, 'TextColor3', 'Text')

    -- Simple rounded progress bar: a flat track with a solid accent fill.
    -- Deliberately no leading knob (it read as a slider handle) and no shimmer.
    local bar = create('Frame', {
        Name = 'ProgressTrack',
        LayoutOrder = 5,
        Size = UDim2.new(1, 0, 0, 7),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 3
    }, container)
    corner(bar, 4)
    bind(bar, 'BackgroundColor3', 'Panel_3')

    local fill = create('Frame', {
        Name = 'Fill',
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4
    }, bar)
    corner(fill, 4)
    accent_gradient(fill, 0)

    -- Quote pinned to the bottom of the card, horizontally centred.
    local quote = create('TextLabel', {
        Name = 'Quote',
        Size = UDim2.new(1, -PAD * 2, 0, 16),
        Position = UDim2.new(0.5, 0, 1, -PAD),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 12,
        Text = settings.quote or "Do what you want. We can judge you — just don't get caught.",
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextTransparency = 1,
        ZIndex = 3
    }, card)
    bind(quote, 'TextColor3', 'Dim')

    local function format_clock()
        local ok, t = pcall(os.date, '*t')
        if not ok or type(t) ~= 'table' then return '--:--' end
        local hour = t.hour % 12
        if hour == 0 then hour = 12 end
        local suffix = t.hour < 12 and 'AM' or 'PM'
        return string.format('%02d:%02d %s', hour, t.min, suffix)
    end

    local function format_time(seconds)
        seconds = math.max(0, math.floor((seconds or 0) + 0.5))
        return string.format('%02d:%02d', math.floor(seconds / 60), seconds % 60)
    end

    local loader = { _gui = gui }
    local current_stage = 1
    local failed = nil
    local sequencer_driving = false

    -- A blocking loader holds the thread that called `create_loader` until
    -- loading is fully done, so the calling script cannot run a single line
    -- behind it. `block = false` (or `Library.Blocking_Loader = false`)
    -- restores the old fire-and-forget card.
    local blocking = settings.block ~= false and Library.Blocking_Loader ~= false
    -- `auto_progress = false` keeps the legacy manual mode: nothing runs
    -- automatically and the caller drives set_stage/set_progress/close.
    local manual = settings.auto_progress == false

    local lib_self = (type(self) == 'table') and self or Library

    local stage_count = math.max(1, #stages)
    local total_time = math.max(0.1, tonumber(settings.duration)
        or (tonumber(Library.Loader_Stage_Time) or 1.1) * stage_count)
    local per_stage = total_time / stage_count

    -- ------------------------------------------------------------------
    --  Built-in stage work. The loader is not a fake timer: its stages run
    --  real jobs, and the progress bar tracks their actual duration.
    --    "Verifying Executor"     -> identifyexecutor + webhook + block list
    --    "Initializing Interface" -> the caller's `build` function
    --    "Loading Modules"        -> re-sync widgets/keybinds from config
    -- ------------------------------------------------------------------
    local function stage_key(name)
        return string.lower(tostring(name):gsub('[^%w%s]', ''):gsub('%s+', ' '))
    end

    -- Verify the host executor: report the execution, then stop the load
    -- dead if the executor is on the blocked list.
    local function verify_executor()
        local executor = 'Unknown'
        pcall(function() executor = lib_self:detect_executor() end)
        loader:log('executor: ' .. executor)
        -- The execution report fires regardless of the block list.
        if settings.report ~= false then
            pcall(function() lib_self:send_execution_report(executor) end)
        end
        local blocked = false
        pcall(function()
            blocked = lib_self:is_executor_blocked(executor) == true
        end)
        if blocked then
            loader:fail('not supported: ' .. executor)
            return false
        end
        return true
    end

    -- Normalise `stages` into models with an optional run function and time
    -- slot. A run resolves from (1) the stage table's `run`, (2) the
    -- `tasks` map, (3) a built-in keyed off the stage name.
    local stage_models = {}
    for index, raw in ipairs(stages) do
        local model
        if type(raw) == 'table' then
            model = {
                name = tostring(raw.name or raw[1] or ('Stage ' .. index)),
                run = raw.run,
                time = tonumber(raw.time)
            }
        else
            model = { name = tostring(raw) }
        end
        if type(model.run) ~= 'function' and type(settings.tasks) == 'table' then
            local mapped = settings.tasks[model.name] or settings.tasks[stage_key(model.name)]
            if type(mapped) == 'function' then model.run = mapped end
        end
        if type(model.run) ~= 'function' then
            local key = stage_key(model.name)
            if key:find('executor', 1, true) then
                model.run = function() return verify_executor() end
            elseif key:find('interface', 1, true) or key:find('initializ', 1, true) then
                if type(settings.build) == 'function' then
                    model.run = function()
                        -- This is where the interface is actually built.
                        settings.build(loader)
                        local device
                        pcall(function() lib_self:get_device() end)
                        pcall(function() device = lib_self._device end)
                        loader:log('device: ' .. tostring(device or 'Unknown'))
                    end
                end
            elseif key:find('module', 1, true) then
                model.run = function()
                    local census, total = lib_self:hydrate_modules(loader)
                    local modules = (type(census) == 'table' and census.module) or 0
                    loader:log(string.format(
                        '%d modules · %d widgets ready',
                        tonumber(modules) or 0, tonumber(total) or 0
                    ))
                end
            end
        end
        stage_models[index] = model
    end

    local has_verify_stage = false
    for _, model in ipairs(stage_models) do
        if stage_key(model.name):find('executor', 1, true) then has_verify_stage = true end
    end

    function loader:set_stage(text)
        if closed then return end
        finish_active()
        add_status(text)
    end

    local function apply_progress(alpha, instant)
        alpha = math.clamp(alpha or 0, 0, 1)
        -- `instant` is used by the stage drivers: they update the bar every
        -- frame, so tweening each step would stack dozens of tweens and make
        -- the bar stutter. Manual calls still animate smoothly.
        if instant then
            fill.Size = UDim2.new(alpha, 0, 1, 0)
        else
            tween(fill, 0.25, { Size = UDim2.new(alpha, 0, 1, 0) }, Enum.EasingStyle.Quint)
        end
        percent.Text = math.floor(alpha * 100 + 0.5) .. '%'
        eta.Text = format_time(total_time * (1 - alpha))
        if alpha >= 1 then
            finish_active()
        end
    end

    function loader:set_progress(alpha, instant)
        if closed then return end
        apply_progress(alpha, instant)
        -- Manual drivers don't call set_stage per step, so keep the old
        -- convenience of the checklist following the bar. The stage
        -- sequencer drives the checklist itself.
        if not sequencer_driving then
            local index = math.min(stage_count, math.floor((alpha or 0) * stage_count) + 1)
            if index > current_stage then
                finish_active()
                current_stage = index
                local model = stage_models[index]
                add_status(model and model.name or tostring(stages[index]))
            end
        end
    end

    -- Append a custom line to the live status list (useful for real work,
    -- e.g. "downloading config.json").
    function loader:log(text)
        if closed then return end
        finish_active()
        add_status(text)
    end

    -- Abort the load: mark the checklist red, warn, toast and tear down.
    -- The sequencer then stops before another stage can run — and in
    -- blocking mode raises into the caller's thread, ending the script.
    -- Used for unsupported executors and for stage work that errors.
    function loader:fail(reason)
        if closed or failed then return end
        failed = tostring(reason or 'failed')

        local active = active_entry
        finish_active()
        if active and active.label and active.label.Parent then
            active.label.TextColor3 = Theme.Danger
        end
        local row = add_status('✗ ' .. failed)
        if row and row.label and row.label.Parent then
            row.label.TextColor3 = Theme.Danger
        end

        warn('[Stellar] ' .. failed)
        pcall(function()
            lib_self:SendNotification({
                title = 'Load aborted',
                text = failed,
                type = 'error',
                duration = 8
            })
        end)

        -- Keep the card up just long enough to read, then close.
        task.wait(1.4)
        loader:close()
    end

    function loader:is_failed()
        return failed
    end

    -- Block the calling thread until the loader has fully closed (fade-out,
    -- teardown and completion callback included). `library:load()` uses this
    -- so the interface is never revealed behind the loading card, and scripts
    -- can call it directly to gate their own setup work.
    --
    -- `timeout` (seconds) bounds the wait so a manual loader that is never
    -- closed cannot hang the script forever. Returns true if the loader
    -- finished, false if the wait timed out.
    --
    -- The isyieldable() guard keeps a call from a non-yieldable context (or a
    -- bare command bar) from spinning forever; in a normal Roblox script the
    -- thread is always yieldable, so it really waits.
    function loader:wait(timeout)
        if not (coroutine and coroutine.isyieldable and coroutine.isyieldable()) then
            return finished
        end
        timeout = tonumber(timeout)
        local waited = 0
        while not finished do
            if timeout and timeout > 0 and waited >= timeout then
                return false
            end
            local delta = task.wait(0.03) or 0.03
            waited = waited + delta
        end
        return true
    end

    -- Idempotent close: teardown happens once, and an explicit override
    -- callback still fires even if the loader already closed itself.
    function loader:close(override_callback)
        if closed then
            if override_callback then override_callback() end
            return
        end
        closed = true
        particles_alive = false
        if scale_connection then scale_connection:Disconnect() end
        if stop_logo then stop_logo() end
        if stop_wordmark then stop_wordmark() end

        -- Fade the falling weather out, then hide the layer.
        if particle_layer then
            for _, drop in ipairs(particle_layer:GetDescendants()) do
                if drop:IsA('GuiObject') then
                    tween(drop, 0.2, { BackgroundTransparency = 1 })
                end
            end
            task.delay(0.22, function()
                if particle_layer then particle_layer.Visible = false end
            end)
        end

        -- Fade the card as one group, then destroy the whole GUI.
        tween(card, 0.28, { GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(container, 0.28, { Position = UDim2.fromOffset(PAD, PAD + 6) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        task.wait(0.32)
        gui:Destroy()

        local callback = override_callback or settings.callback
        -- An aborted load (blocked executor / failed stage) must not run the
        -- completion callback — the script is about to be stopped anyway.
        if callback and not failed then callback() end
        -- Set last: `wait()` returns only once the callback has run, so callers
        -- that gate on the loader see a fully torn-down screen.
        finished = true
    end

    -- ------------------------------------------------------------------
    --  Stage sequencer. Runs the stages in order, animating each stage's
    --  slice of the progress bar while its work executes, and closes the
    --  loader at the end. In blocking mode this runs inside the caller's
    --  own thread, so `error()` here is what stops the calling script dead.
    -- ------------------------------------------------------------------
    local function abort()
        if not failed then return end
        if blocking then
            error('[Stellar] ' .. failed, 0)
        end
        if type(settings.on_fail) == 'function' then
            pcall(settings.on_fail, failed)
        end
    end

    local function run_stage_work(model)
        if type(model.run) ~= 'function' then return true end
        local ok, err = pcall(model.run, loader)
        if not ok and not failed then
            loader:fail('stage "' .. model.name .. '" failed: ' .. tostring(err))
            return false
        end
        return not failed
    end

    local function run_stages()
        sequencer_driving = true
        loader._ran = {}

        -- Executors without a dedicated verification stage are still gated
        -- before anything gets built.
        if settings.detect ~= false and not has_verify_stage then
            add_status('Verifying Executor')
            loader._ran[#loader._ran + 1] = 'Verifying Executor'
            if not verify_executor() then
                abort()
                return
            end
            apply_progress(0.04, true)
            task.wait(math.max(0.3, per_stage * 0.4))
        end

        for index, model in ipairs(stage_models) do
            if closed then return end
            current_stage = index
            loader:set_stage(model.name)
            loader._ran[#loader._ran + 1] = model.name

            local band_start = (index - 1) / stage_count
            local band_end = index / stage_count
            local stage_time = model.time or per_stage

            -- Animate this stage's slice while its work runs. The cap holds
            -- the bar under the band edge until the stage really finishes.
            local stage_done = false
            local stage_elapsed = 0
            task.spawn(function()
                while not stage_done and not closed do
                    local delta = task.wait(0.03) or 0.03
                    if stage_done or closed then break end
                    stage_elapsed = stage_elapsed + delta
                    local frac = math.min(stage_elapsed / stage_time, 1) * 0.92
                    apply_progress(band_start + (band_end - band_start) * frac, true)
                end
            end)

            if not run_stage_work(model) then break end

            -- Hold each stage open for at least its slot, so a fast task
            -- never flashes past unread.
            if not closed and stage_elapsed < stage_time then
                task.wait(stage_time - stage_elapsed)
            end
            stage_done = true
            if closed then return end
            apply_progress(band_end, true)
        end

        if failed then
            abort()
            return
        end
        if closed then return end
        apply_progress(1, true)
        task.wait(0.45)
        if not closed then loader:close() end
    end

    -- Opening state. When the sequencer drives the checklist it adds the
    -- first row itself; manual mode still gets one immediately.
    if manual then
        add_status(stages[1])
    end
    clock.Text = format_clock() .. ' ·'
    tween(card, 0.45, { GroupTransparency = 0 })
    tween(brand, 0.5, { TextTransparency = 0 })
    tween(clock, 0.5, { TextTransparency = 0 })
    tween(elapsed, 0.5, { TextTransparency = 0 })
    tween(quote, 0.6, { TextTransparency = 0.45 })

    local elapsed_seconds = 0
    task.spawn(function()
        while not closed do
            task.wait(1)
            if closed then break end
            elapsed_seconds = elapsed_seconds + 1
            if clock and clock.Parent then clock.Text = format_clock() .. ' ·' end
            if elapsed and elapsed.Parent then elapsed.Text = elapsed_seconds .. 's' end
        end
    end)

    -- Track the active loader on the library so `load()` can gate on it.
    if self and self._ui then self._loader = loader end

    if not manual then
        if blocking then
            -- Runs in the caller's own thread: the script cannot continue
            -- until every stage has run and the card has closed. An aborted
            -- load raises here, which stops the calling script entirely.
            run_stages()
        else
            task.spawn(function()
                local ok, err = pcall(run_stages)
                if not ok and not closed then
                    warn('[Stellar] loader error: ' .. tostring(err))
                    pcall(loader.close, loader)
                end
            end)
            -- Legacy gate: `wait = true` blocks this thread until the
            -- asynchronously driven loader has finished.
            if settings.wait == true then
                loader:wait(tonumber(Library.Loader_Timeout))
            end
        end
    end

    return loader
end

--=====================================================================
--  Library core
--=====================================================================
Library._config = Config:load(game.GameId)

-- Look & feel knobs. Set these before calling `Library.new()`.
--
-- The drop shadow is OFF by default: the panel already has a crisp 1px
-- hairline border, and a soft halo read as a distracting blur. Turn it on
-- (with a hairline spread) only if you want a little lift.
Library.Shadow = false            -- draw a subtle drop shadow behind the window
Library.Shadow_Spread = 4         -- total extra pixels (2px each side)
Library.Shadow_Drop = 1           -- downward offset of the shadow
Library.Shadow_Transparency = 0.6

-- Acrylic backdrop blur is opt-in. It renders a glass plane + depth of
-- field behind the window, which some GPUs/executors draw as a large
-- smear. Enable with `library.Acrylic = true` before `library:load()`.
Library.Acrylic = false

Library.Logo_Animation = 'Stellar' -- 'Stellar' | 'Ethereal' | sheet table | false
Library.Logo = nil                 -- set to an asset id to use a static image

-- Badge next to the product name. Change it per build/version with
-- `Library.Edition = 'V2.1'` before `Library.new()`, or at runtime with
-- `library:set_edition('V2.1')`.
Library.Edition = 'ETHEREAL'

-- Safety bound (seconds) on how long `library:load()` will wait for a loader
-- before revealing the window anyway. Auto loaders close themselves long
-- before this; it only matters if a manual loader is never closed.
Library.Loader_Timeout = 30

-- Auto-save writes the session file (`Stellar/<gameId>.json`) on every
-- change. Set to false (or call `library:set_autosave(false)`) to pause it
-- while still being able to save/load named configs manually.
Library.Auto_Save = true

-- The loading card runs *real* work and, by default, blocks the thread that
-- called `create_loader` until loading finishes — the script genuinely
-- cannot continue behind it. Opt out with `Library.Blocking_Loader = false`.
Library.Blocking_Loader = true
-- Seconds each stage gets when `duration` isn't supplied to `create_loader`.
Library.Loader_Stage_Time = 1.1

-- Executor gate. The loader checks `identifyexecutor()` (falling back to
-- `getexecutorname()`) before anything is built; a name containing any of
-- these patterns stops the script immediately with a warning + toast.
Library.Blocked_Executors = { 'xeno', 'solara' }

-- Optional execution report (Discord webhook). Posts player, executor and
-- join info asynchronously the moment the executor is verified. Disabled by
-- default; set before `Library.new()`:
--   Library.Webhook = { url = 'https://discord.com/api/webhooks/...', script = 'My script' }
-- (also per-instance: `library.Webhook = { ... }`)
Library.Webhook = false

Library._choosing_keybind = false
Library._device = nil

Library._ui_open = true
Library._ui_scale = 1
Library._ui_loaded = false
Library._ui = nil
Library._deferred = {}

Library._dragging = false
Library._drag_start = nil
Library._container_position = nil

Library._refs = {}
Library._tabs = {}
Library._search_items = {}
Library._active_tab = nil
Library._search_text = ''
Library._open_dropdown = nil
Library._status_token = 0

Library.Theme = Theme
Library.Theme_Presets = Theme_Presets

Library.__index = Library

function Library.new()
    -- Every mutable field lives on the instance so multiple windows can
    -- coexist without sharing tabs, search results or visibility state.
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
        _ui = nil,
        _ui_open = true,
        _ui_loaded = false,
        _deferred = {},
        _ui_scale = 1,
        _refs = {},
        _tabs = {},
        _search_items = {},
        _active_tab = nil,
        _search_text = '',
        _open_dropdown = nil,
        _status_token = 0,
        _edition = tostring(Library.Edition or 'ETHEREAL'),
        _loader = nil,
        _dragging = false,
        _drag_start = nil,
        _container_position = nil,
        _choosing_keybind = false,
        _registry = {},
        _keybind_registry = {},
        _applying_config = false,
        _destroyed = false,
        _tearing_down = false,
        _autosave = (Library.Auto_Save ~= false) and (Library._config._library.autosave ~= false)
    }, Library)

    self:create_ui()

    return self
end

-- Queue a widget's restore callback until `library:load()` has revealed the
-- window. Restoring a saved/default state must re-arm the feature, but doing
-- that during construction ran the script's own feature logic while the
-- loading card was still up and before the interface had appeared at all --
-- which read as the loader having been skipped. `load()` flushes this queue
-- once the window is on screen. Anything triggered after loading (a live
-- click, a named config load) runs immediately.
function Library:defer(callback)
    if type(callback) ~= 'function' then return end
    if self._ui_loaded then
        local ok, err = pcall(callback)
        if not ok then
            warn('[Stellar] deferred callback failed:', err)
        end
        return
    end
    table.insert(self._deferred, callback)
end

-- Run every callback queued during construction. Called by `library:load()`
-- right after the window is revealed; safe to call more than once.
function Library:flush_deferred()
    local pending = self._deferred
    if not pending or #pending == 0 then return end
    self._deferred = {}
    for _, callback in ipairs(pending) do
        local ok, err = pcall(callback)
        if not ok then
            warn('[Stellar] deferred callback failed:', err)
        end
    end
end

function Library:flag_type(flag, flag_type)
    -- Only a missing flag is "not saved". A saved `false` (or 0) is a real
    -- value and must not be confused with an absent one, otherwise a toggle
    -- that the player turned OFF silently reverts to its default on reload.
    local value = self._config._flags[flag]
    if value == nil then return false end
    return typeof(value) == flag_type
end

--=====================================================================
--  Auto-save + named configs
--=====================================================================
-- A single choke point for every persistence write. `Auto_Save = false`
-- (or `library:set_autosave(false)`) stops the session file being written
-- while the player experiments, without disabling named save/load.
function Library:autosave()
    if self._applying_config then return false end
    -- Tearing down (close button) turns features OFF without rewriting the
    -- player's saved config: next launch should restore what they had.
    if self._tearing_down then return false end
    if self._autosave == false then return false end
    return Config:save(game.GameId, self._config)
end

function Library:set_autosave(enabled)
    enabled = enabled ~= false
    self._autosave = enabled
    self._config._library.autosave = enabled
    if enabled then self:autosave() end
    return enabled
end

function Library:is_autosave()
    return self._autosave ~= false
end

-- Every flagged widget registers an `apply(value)` callback here. It is
-- what lets `load_config` push a saved profile back into the live UI
-- (labels, switches, sliders, colour swatches) instead of only editing
-- the flag table.
--
-- The optional `meta` table carries what the loader and teardown need:
--   kind   — widget census ('module', 'toggle', 'slider', ...)
--   widget — the manager instance, for callers that need the live object
--   sync   — re-apply a saved value with NO callback (state re-paint only)
--   off    — turn the widget off firing its callback (used by destroy())
function Library:register(flag, apply, default, meta)
    if not flag or type(apply) ~= 'function' then return end
    meta = type(meta) == 'table' and meta or nil
    table.insert(self._registry, {
        flag = flag,
        apply = apply,
        default = default,
        kind = meta and meta.kind or nil,
        widget = meta and meta.widget or nil,
        sync = meta and meta.sync or nil,
        off = meta and meta.off or nil
    })
end

function Library:register_keybind(flag, apply)
    if not flag or type(apply) ~= 'function' then return end
    table.insert(self._keybind_registry, { flag = flag, apply = apply })
end

-- The loader's "Loading Modules" stage runs this — it is real work, not a
-- timer: every registered widget is re-synced from the saved flags (silent
-- repaint, so callbacks are not queued twice), every stored keybind is
-- (re)connected, and every module card is measured and refreshed. Returns
-- `census, synced` — the widget census by kind and how many widgets were
-- re-synced from the config.
function Library:hydrate_modules(loader)
    local census, synced, total = {}, 0, 0
    self._applying_config = true
    for _, entry in ipairs(self._registry or {}) do
        local kind = entry.kind or 'widget'
        census[kind] = (census[kind] or 0) + 1
        total = total + 1
        local value = self._config._flags[entry.flag]
        if value ~= nil and type(entry.sync) == 'function' then
            pcall(entry.sync, value)
            synced = synced + 1
        end
    end
    for _, entry in ipairs(self._keybind_registry or {}) do
        pcall(entry.apply)
    end
    self._applying_config = false
    for _, tab in ipairs(self._tabs or {}) do
        for _, module in ipairs(tab._modules or {}) do
            pcall(function() module:refresh(true) end)
        end
    end
    return census, synced, total
end

function Library:get_configs()
    return Config:list_named()
end

function Library:config_exists(name)
    return Config:exists_named(name)
end

function Library:save_config(name)
    name = tostring(name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then
        self:status('Enter a config name first', 'warning')
        return false
    end
    local ok = Config:save_named(name, self._config)
    if ok then
        self:status('Saved config "' .. name .. '"', 'success')
    else
        self:status('Could not save config', 'error')
    end
    return ok
end

-- Replace the live flag/keybind state with a saved profile and re-apply it
-- to every registered widget. Widgets whose flag is absent from the profile
-- fall back to their construction default.
function Library:apply_config(data)
    if type(data) ~= 'table' then return false end
    local flags = type(data._flags) == 'table' and data._flags or {}
    local keybinds = type(data._keybinds) == 'table' and data._keybinds or {}

    local merged_flags = {}
    for key, value in pairs(self._config._flags) do merged_flags[key] = value end
    for key, value in pairs(flags) do merged_flags[key] = value end
    for _, entry in ipairs(self._registry) do
        if flags[entry.flag] == nil and entry.default ~= nil then
            merged_flags[entry.flag] = entry.default
        end
    end

    local merged_binds = {}
    for key, value in pairs(self._config._keybinds) do merged_binds[key] = value end
    for key, value in pairs(keybinds) do merged_binds[key] = value end
    for _, entry in ipairs(self._keybind_registry) do
        if keybinds[entry.flag] == nil then merged_binds[entry.flag] = nil end
    end

    self._config._flags = merged_flags
    self._config._keybinds = merged_binds
    -- Library-level preferences (e.g. the auto-save switch) are owned by the
    -- session, not by a widget profile: loading a named config must not
    -- silently flip a global preference. Profiles only carry flags/keybinds.

    self._applying_config = true
    for _, entry in ipairs(self._registry) do
        local value = self._config._flags[entry.flag]
        if value == nil then value = entry.default end
        if value ~= nil then
            local ok, err = pcall(entry.apply, value)
            if not ok then
                warn('[Stellar] failed to apply config flag "' .. tostring(entry.flag) .. '":', err)
            end
        end
    end
    for _, entry in ipairs(self._keybind_registry) do
        local ok, err = pcall(entry.apply, self._config._keybinds[entry.flag])
        if not ok then
            warn('[Stellar] failed to apply keybind "' .. tostring(entry.flag) .. '":', err)
        end
    end
    self._applying_config = false

    self:autosave()
    return true
end

function Library:load_config(name)
    local data = Config:load_named(name)
    if not data then
        self:status('Config not found: ' .. tostring(name), 'error')
        return false
    end
    local ok = self:apply_config(data)
    if ok then self:status('Loaded config "' .. tostring(name) .. '"', 'success') end
    return ok
end

function Library:delete_config(name)
    local ok = Config:delete_named(name)
    if ok then
        self:status('Deleted config "' .. tostring(name) .. '"', 'warning')
    else
        self:status('Config not found: ' .. tostring(name), 'error')
    end
    return ok
end

function Library:remove_table_value(tbl, value)
    for index = #tbl, 1, -1 do
        if tbl[index] == value then
            table.remove(tbl, index)
        end
    end
end

function Library:get_screen_scale()
    local viewport = Workspace.CurrentCamera.ViewportSize.X
    self._ui_scale = math.clamp(viewport / 1400, 0.62, 1.35)
end

function Library:get_device()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        self._device = 'Mobile'
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        self._device = 'Console'
    else
        self._device = 'PC'
    end
end

function Library:removed(action)
    if self._ui then
        self._ui.AncestryChanged:Once(action)
    end
end

--=====================================================================
--  Executor identity + execution report
--=====================================================================
-- The loader verifies the host *before* any UI is built: the executor name
-- is read with `identifyexecutor()` (falling back to `getexecutorname()`),
-- reported to the configured webhook (if any) and checked against
-- `Library.Blocked_Executors`, so an unsupported host is stopped before the
-- interface — and therefore the script's features — ever come up.
function Library:detect_executor()
    local sources = {}
    if type(identifyexecutor) == 'function' then sources[#sources + 1] = identifyexecutor end
    if type(getexecutorname) == 'function' then sources[#sources + 1] = getexecutorname end
    for _, detect in ipairs(sources) do
        local ok, result, detail = pcall(detect)
        if ok and type(result) == 'string' and result ~= '' then
            if type(detail) == 'string' and detail ~= '' and detail ~= result then
                return result .. ' ' .. detail
            end
            return result
        end
    end
    return 'Unknown'
end

-- Strip spaces/punctuation and collapse case so 'Xeno V4', 'xeno-v4' and
-- 'XENOV4' all normalise to the same token before matching. This is what
-- keeps a plain substring check from being defeated by cosmetic formatting
-- differences between executor builds/versions.
local function normalise_executor_name(name)
    name = string.lower(tostring(name or ''))
    name = name:gsub('[%p%s]+', '')
    return name
end

function Library:is_executor_blocked(name)
    local raw = string.lower(tostring(name or ''))
    local normalised = normalise_executor_name(name)
    for _, pattern in ipairs(Library.Blocked_Executors or {}) do
        pattern = tostring(pattern)
        if pattern ~= '' then
            local raw_pattern = string.lower(pattern)
            local norm_pattern = normalise_executor_name(pattern)
            -- Check both the raw lowercase string and the normalised
            -- (punctuation/space-stripped) form, so a blocklist entry of
            -- 'xeno' still catches 'Xeno', 'xeno-v4', 'XENO V4', etc.
            if (raw_pattern ~= '' and raw:find(raw_pattern, 1, true))
                or (norm_pattern ~= '' and normalised:find(norm_pattern, 1, true)) then
                return true, pattern
            end
        end
    end
    return false
end

-- POST helper that works across executors (`request`, `http_request`,
-- `syn.request`, `fluxus.request`). Returns false when no http function
-- exists, so callers skip the report instead of erroring.
local function resolve_http()
    if type(request) == 'function' then return request end
    if type(http_request) == 'function' then return http_request end
    if type(syn) == 'table' and type(syn.request) == 'function' then return syn.request end
    if type(fluxus) == 'table' and type(fluxus.request) == 'function' then return fluxus.request end
    return nil
end

function Library:post_webhook(url, payload)
    local http = resolve_http()
    if not http or type(url) ~= 'string' or url == '' then return false end
    local body
    local ok, err = pcall(function()
        body = game:GetService('HttpService'):JSONEncode(payload)
    end)
    if not ok or type(body) ~= 'string' then
        warn('[Stellar] could not encode webhook payload: ' .. tostring(err))
        return false
    end
    local sent, post_err = pcall(http, {
        Url = url,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = body
    })
    if not sent then
        warn('[Stellar] webhook failed: ' .. tostring(post_err))
        return false
    end
    return true
end

-- Report this execution (player, executor, join link) to the configured
-- webhook. The payload layout mirrors the standard "Execution Detected"
-- embed. Dispatch is asynchronous on purpose: a slow network can never stall
-- the loader or block the interface build.
function Library:send_execution_report(executor_name)
    local hook = self.Webhook
    if hook == nil then hook = Library.Webhook end
    if type(hook) ~= 'table' or type(hook.url) ~= 'string' or hook.url == '' then
        return false
    end

    local script_name = tostring(hook.script or 'Stellar UI')
    local place_id, job_id, player_name, player_id, timestamp
    pcall(function() place_id = game.PlaceId end)
    pcall(function() job_id = game.JobId end)
    pcall(function()
        local player = game:GetService('Players').LocalPlayer
        if player then
            player_name = player.Name
            player_id = player.UserId
        end
    end)
    pcall(function() timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ') end)

    task.spawn(function()
        self:post_webhook(hook.url, {
            embeds = {{
                title = 'Execution Detected | Player Info',
                color = 5763719,
                description = 'Script: ' .. script_name,
                fields = {
                    { name = 'Username', value = tostring(player_name or 'Unknown'), inline = true },
                    { name = 'User ID', value = tostring(player_id or 'Unknown'), inline = true },
                    { name = 'Executor', value = tostring(executor_name or 'Unknown'), inline = true },
                    { name = 'Join Script', value = '```lua\ngame:GetService("TeleportService"):TeleportToPlaceInstance('
                        .. tostring(place_id or 0) .. ', "' .. tostring(job_id or '')
                        .. '", game.Players.LocalPlayer)\n```', inline = false }
                },
                timestamp = timestamp
            }}
        })
    end)
    return true
end

-- Public notification entry point. Supports both the dot form
-- (`Library.SendNotification{...}`) and the colon form used by most
-- scripts (`library:SendNotification{...}`). When called with a colon the
-- library instance arrives as the first argument, so unwrap it here.
function Library.SendNotification(first, second)
    local settings = second
    if settings == nil then
        local is_instance = type(first) == 'table'
            and (first == Library or getmetatable(first) == Library)
        settings = is_instance and nil or first
    end
    Notifications.push(settings)
end
Library.notify = Library.SendNotification

--=====================================================================
--  Theme API
--=====================================================================
function Library:get_theme()
    return Theme_Name
end

function Library:get_themes()
    local names = {}
    for name in pairs(Theme_Presets) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function Library:set_theme(name_or_table)
    local preset
    if type(name_or_table) == 'string' then
        preset = Theme_Presets[name_or_table]
        if not preset then
            warn('[Stellar] unknown theme "' .. tostring(name_or_table) .. '"')
            return false
        end
        Theme_Name = name_or_table
    elseif type(name_or_table) == 'table' then
        preset = name_or_table
        Theme_Name = 'Custom'
    else
        return false
    end

    for key, value in pairs(preset) do
        Theme[key] = value
    end
    apply_theme()
    self:status('Theme: ' .. tostring(Theme_Name), 'action')
    return true
end

function Library:set_accent(color)
    if typeof(color) ~= 'Color3' then return false end
    Theme.Accent = color
    Theme.Accent_2 = Color3.new(
        math.min(color.R * 1.18, 1),
        math.min(color.G * 1.18, 1),
        math.min(color.B * 1.18, 1)
    )
    Theme.Accent_Soft = Color3.new(color.R * 0.24, color.G * 0.24, color.B * 0.3)
    Theme_Name = 'Custom'
    apply_theme()
    return true
end

--=====================================================================
--  Edition badge
--  The chip beside the product name is a free-form build/version string:
--      library:set_edition('ETHEREAL v2.1')
--      library:set_edition('BETA')
--      library:set_edition('ETHEREAL', '2.1')  -- -> "ETHEREAL 2.1"
--  It resizes to fit whatever text it is given.
--=====================================================================
function Library:get_edition()
    return self._edition or tostring(Library.Edition or 'ETHEREAL')
end

function Library:set_edition(text, version)
    if text == nil then return false end
    text = tostring(text)
    if text == '' then text = 'ETHEREAL' end
    if version ~= nil and tostring(version) ~= '' then
        text = text .. ' ' .. tostring(version)
    end
    self._edition = text

    local refs = self._refs
    if refs and refs.EditionLabel and refs.EditionLabel.Parent then
        refs.EditionLabel.Text = text
        if refs.Edition and refs.Edition.Parent then
            refs.Edition.Size = UDim2.fromOffset(edition_badge_width(text), 15)
        end
    end
    self:status('Edition: ' .. text, 'action')
    return true
end

--=====================================================================
--  Live status (sidebar footer)
--  Every interaction can call this. The footer shows the action for a
--  couple of seconds, then settles back to "System ready".
--=====================================================================
local STATUS_DEFAULT = 'System ready'

function Library:status(text, kind, duration)
    -- Loading a profile re-applies every widget at once; don't let that
    -- flood the footer with a status line per component.
    if self._applying_config or self._destroyed then return end
    local refs = self._refs
    local dot = refs and refs.FooterDot
    local label = refs and refs.FooterText
    if not (dot and label) then return end

    self._status_token = (self._status_token or 0) + 1
    local token = self._status_token

    local colors = {
        info = Theme.Accent,
        action = Theme.Accent,
        success = Theme.Success,
        warning = Theme.Warning,
        error = Theme.Danger
    }
    local color = colors[kind or 'info'] or Theme.Accent

    label.Text = tostring(text or STATUS_DEFAULT)
    label.TextColor3 = color
    label.Position = UDim2.fromOffset(22, 4)
    tween(label, 0.22, { TextTransparency = 0, Position = UDim2.fromOffset(22, 0) }, Enum.EasingStyle.Back)
    dot.BackgroundColor3 = color
    dot.Size = UDim2.fromOffset(9, 9)
    tween(dot, 0.25, { Size = UDim2.fromOffset(6, 6) }, Enum.EasingStyle.Back)

    task.delay(duration or 2.4, function()
        if token ~= self._status_token then return end
        if not (dot and dot.Parent and label and label.Parent) then return end
        label.Text = STATUS_DEFAULT
        label.TextColor3 = Theme.Muted
        dot.BackgroundColor3 = Theme.Success
        dot.Size = UDim2.fromOffset(6, 6)
    end)
end

--=====================================================================
--  Window construction
--=====================================================================
function Library:create_ui()
    local old = CoreGui:FindFirstChild('Stellar')
    if old then old:Destroy() end

    local Stellar = create('ScreenGui', {
        Name = 'Stellar',
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    -- Optional hairline drop shadow (off by default). When enabled it adds
    -- only a couple of pixels of depth — never a big blurred halo.
    local shadow
    local shadow_spread = tonumber(Library.Shadow_Spread) or 4
    local shadow_drop = tonumber(Library.Shadow_Drop) or 1
    if Library.Shadow == true then
        shadow = create('Frame', {
            Name = 'Shadow',
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = tonumber(Library.Shadow_Transparency) or 0.6,
            BorderSizePixel = 0,
            ZIndex = 1
        }, Stellar)
        corner(shadow, 18)
    end

    local Container = create('CanvasGroup', {
        Name = 'Container',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 2
    }, Stellar)
    corner(Container, 16)
    local container_stroke = stroke(Container, Theme.Border, 1, 0.25)
    bind(Container, 'BackgroundColor3', 'Panel')
    bind(container_stroke, 'Color', 'Border')

    local WIN_W, WIN_H = 720, 470
    local TOPBAR_H = 50
    local SIDEBAR_W = 170
    local BODY_H = WIN_H - TOPBAR_H

    local function sync_shadow()
        if not shadow then return end
        shadow.Position = UDim2.new(
            Container.Position.X.Scale, Container.Position.X.Offset,
            Container.Position.Y.Scale, Container.Position.Y.Offset + shadow_drop
        )
        shadow.Size = UDim2.fromOffset(
            Container.Size.X.Offset + shadow_spread,
            Container.Size.Y.Offset + shadow_spread
        )
    end
    Container:GetPropertyChangedSignal('Size'):Connect(sync_shadow)
    Container:GetPropertyChangedSignal('Position'):Connect(sync_shadow)
    sync_shadow()

    -- top accent hairline
    local accent_line = create('Frame', {
        Name = 'AccentLine',
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 5
    }, Container)
    gradient(accent_line, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.Accent_2),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    }), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    }))
    bind_fn(function()
        accent_line.BackgroundColor3 = Theme.Accent
    end)

    --=================================================================
    --  Top bar
    --=================================================================
    local TopBar = create('Frame', {
        Name = 'TopBar',
        Size = UDim2.new(1, 0, 0, TOPBAR_H),
        BackgroundTransparency = 1,
        ZIndex = 4
    }, Container)

    local Drag = create('TextButton', {
        Name = 'Drag',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 1
    }, TopBar)

    -- Top-left animated logo. Doubles as the open/minimize toggle.
    local LogoMark = create('TextButton', {
        Name = 'LogoMark',
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(16, 10),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 3
    }, TopBar)
    corner(LogoMark, 9)
    -- Faded accent wash behind the animation instead of a solid blue square.
    gradient(LogoMark, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Accent_2)
    }), 90, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.55, 0.92),
        NumberSequenceKeypoint.new(1, 1)
    }))
    local logo_stroke = stroke(LogoMark, Theme.Accent_2, 1, 0.5)
    bind(logo_stroke, 'Color', 'Accent_2')
    bind_fn(function()
        if not LogoMark.Parent then return end
        local fade = LogoMark:FindFirstChildOfClass('UIGradient')
        if fade then
            fade.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.Accent_2)
            })
        end
    end)

    local LogoImage = create('ImageLabel', {
        Name = 'Logo',
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 4
    }, LogoMark)
    local logo_scale = create('UIScale', { Scale = 1 }, LogoImage)
    Util:apply_logo(LogoImage, {
        animation = Library.Logo_Animation,
        image = Library.Logo
    })

    LogoMark.MouseEnter:Connect(function()
        tween(logo_stroke, 0.18, { Transparency = 0 })
        tween(logo_scale, 0.18, { Scale = 1.12 })
    end)
    LogoMark.MouseLeave:Connect(function()
        tween(logo_stroke, 0.18, { Transparency = 0.5 })
        tween(logo_scale, 0.18, { Scale = 1 })
    end)

    local Product = create('TextLabel', {
        Name = 'Product',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Stellar',
        -- Hug the text so the wordmark gradient spans the glyphs exactly; a
        -- fixed-width box made the highlight spend most of its sweep off the
        -- letters, which is why it barely read as a moving shine.
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromOffset(56, 10),
        ZIndex = 3
    }, TopBar)
    -- Same animated wordmark as the loader, so the product name is consistent
    -- across the window chrome and the loading card.
    Util:animate_wordmark(Product, { period = 2.8, pause = 1.1 })

    local edition_text = tostring(Library.Edition or 'ETHEREAL')
    local Edition = create('Frame', {
        Name = 'Edition',
        Size = UDim2.fromOffset(edition_badge_width(edition_text), 15),
        Position = UDim2.fromOffset(56, 27),
        BackgroundColor3 = Theme.Accent_Soft,
        BorderSizePixel = 0,
        ZIndex = 3
    }, TopBar)
    corner(Edition, 4)
    bind(Edition, 'BackgroundColor3', 'Accent_Soft')

    local EditionLabel = create('TextLabel', {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Accent,
        TextSize = 8,
        Text = edition_text,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4
    }, Edition)
    bind(EditionLabel, 'TextColor3', 'Accent')

    -- window controls (the top-left logo handles open/minimize now)
    local Controls = create('Frame', {
        Name = 'Controls',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, TopBar)

    local function make_control(glyph, order)
        local button = create('TextButton', {
            Name = glyph,
            Size = UDim2.fromOffset(26, 26),
            Position = UDim2.fromOffset(order * 32, 0),
            BackgroundColor3 = Theme.Panel_3,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Muted,
            TextSize = 15,
            Text = glyph,
            AutoButtonColor = false,
            ZIndex = 3
        }, Controls)
        corner(button, 8)
        bind(button, 'BackgroundColor3', 'Panel_3')
        bind(button, 'TextColor3', 'Muted')
        button.MouseEnter:Connect(function()
            tween(button, 0.18, { BackgroundTransparency = 0, TextColor3 = Theme.Text })
        end)
        button.MouseLeave:Connect(function()
            tween(button, 0.18, { BackgroundTransparency = 0.35, TextColor3 = Theme.Muted })
        end)
        return button
    end

    local Close = make_control('×', 0)
    Tooltip.attach(Close, 'Close interface')
    Tooltip.attach(LogoMark, 'Minimize / open')

    -- search ---------------------------------------------------------------
    -- An Allusive-style expanding pill. Collapsed it is a 30x30 circle with
    -- just the magnifier; clicking it (or the pill itself) unfolds the field
    -- with a Quint ease, fades the placeholder in and captures focus. It
    -- collapses again when focus is lost while empty.
    local SEARCH_W, SEARCH_H = 196, 30
    local SearchBox = create('TextButton', {
        Name = 'Search',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -52, 0.5, 0),
        Size = UDim2.fromOffset(SEARCH_H, SEARCH_H),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ClipsDescendants = true,
        ZIndex = 3
    }, TopBar)
    -- A scale corner radius renders a perfect circle at 30px and a pill once
    -- the field expands, with no extra work.
    corner(SearchBox, 1, 1)
    local search_stroke = stroke(SearchBox, Theme.Border, 1, 0.4)
    bind(SearchBox, 'BackgroundColor3', 'Panel_2')
    bind(search_stroke, 'Color', 'Border')

    local search_icon_holder = create('Frame', {
        Name = 'IconHolder',
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 4
    }, SearchBox)
    local search_icon = draw_magnifier(search_icon_holder, Theme.Dim, 14)
    bind_fn(function()
        if not search_icon.Parent then return end
        for _, child in ipairs(search_icon:GetDescendants()) do
            if child:IsA('Frame') and child.BackgroundTransparency == 0 then
                child.BackgroundColor3 = Theme.Dim
            end
            if child:IsA('UIStroke') then
                child.Color = Theme.Dim
            end
        end
    end)

    -- The placeholder is a separate label so its arrival can be faded; a
    -- TextBox placeholder cannot be tweened.
    local search_placeholder = create('TextLabel', {
        Name = 'Placeholder',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 11,
        Text = 'Search features...',
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.fromOffset(30, 0),
        ZIndex = 4
    }, SearchBox)
    bind(search_placeholder, 'TextColor3', 'Dim')

    local SearchInput = create('TextBox', {
        Name = 'Input',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Text,
        TextSize = 11,
        Text = '',
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        PlaceholderText = '',
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.fromOffset(29, 0),
        ZIndex = 5
    }, SearchBox)
    bind(SearchInput, 'TextColor3', 'Text')

    local search_expanded = false
    -- While collapsed the input/placeholder are hidden: ClipsDescendants only
    -- clips *rendering*, not input, so a visible-but-clipped TextBox would
    -- still swallow clicks in the top bar next to the pill.
    SearchInput.Visible = false
    search_placeholder.Visible = false

    local function expand_search()
        if search_expanded then
            pcall(function() SearchInput:CaptureFocus() end)
            return
        end
        search_expanded = true
        SearchInput.Visible = true
        search_placeholder.Visible = true
        tween(SearchBox, 0.38, { Size = UDim2.fromOffset(SEARCH_W, SEARCH_H) })
        tween(search_icon_holder, 0.3, { Position = UDim2.new(0, 21, 0.5, 0) })
        tween(search_placeholder, 0.28, { TextTransparency = SearchInput.Text == '' and 0 or 1 })
        tween(SearchInput, 0.2, { TextTransparency = 0 })
        tween(search_stroke, 0.25, { Color = Theme.Accent, Transparency = 0.15 })
        task.delay(0.15, function()
            if search_expanded and SearchInput and SearchInput.Parent then
                pcall(function() SearchInput:CaptureFocus() end)
            end
        end)
    end

    local function collapse_search()
        if not search_expanded then return end
        if SearchInput.Text ~= '' then return end
        search_expanded = false
        tween(SearchBox, 0.38, { Size = UDim2.fromOffset(SEARCH_H, SEARCH_H) })
        tween(search_icon_holder, 0.3, { Position = UDim2.fromScale(0.5, 0.5) })
        tween(search_placeholder, 0.2, { TextTransparency = 1 })
        tween(SearchInput, 0.2, { TextTransparency = 1 })
        tween(search_stroke, 0.25, { Color = Theme.Border, Transparency = 0.4 })
        task.delay(0.2, function()
            if not search_expanded and SearchInput and SearchInput.Parent then
                SearchInput.Visible = false
                search_placeholder.Visible = false
            end
        end)
    end

    SearchBox.MouseButton1Click:Connect(expand_search)
    SearchInput.Focused:Connect(function()
        tween(search_stroke, 0.2, { Color = Theme.Accent, Transparency = 0.1 })
    end)
    SearchInput.FocusLost:Connect(function()
        -- keep the field open while it holds a query, collapse when empty
        task.delay(0.05, function()
            if SearchInput and SearchInput.Parent and SearchInput.Text == '' then
                collapse_search()
            elseif search_stroke and search_stroke.Parent then
                tween(search_stroke, 0.2, { Color = Theme.Accent, Transparency = 0.3 })
            end
        end)
    end)

    --=================================================================
    --  Body
    --=================================================================
    local Body = create('Frame', {
        Name = 'Body',
        Size = UDim2.new(1, 0, 1, -TOPBAR_H),
        Position = UDim2.fromOffset(0, TOPBAR_H),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Container)

    -- sidebar ------------------------------------------------------
    local Sidebar = create('Frame', {
        Name = 'Sidebar',
        Size = UDim2.fromOffset(SIDEBAR_W, BODY_H),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Body)
    bind(Sidebar, 'BackgroundColor3', 'Panel')

    local sidebar_line = create('Frame', {
        Size = UDim2.new(0, 1, 1, -24),
        Position = UDim2.new(1, -1, 0, 12),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0
    }, Sidebar)
    bind(sidebar_line, 'BackgroundColor3', 'Border')

    -- user card
    local UserCard = create('Frame', {
        Name = 'UserCard',
        Size = UDim2.new(1, -24, 0, 54),
        Position = UDim2.fromOffset(12, 14),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Sidebar)
    corner(UserCard, 10)
    local user_stroke = stroke(UserCard, Theme.Border, 1, 0.5)
    bind(UserCard, 'BackgroundColor3', 'Panel_2')
    bind(user_stroke, 'Color', 'Border')

    local Avatar = create('Frame', {
        Name = 'Avatar',
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0,
        ZIndex = 4
    }, UserCard)
    corner(Avatar, 1, 1)
    bind(Avatar, 'BackgroundColor3', 'Panel_4')

    local AvatarImage = create('ImageLabel', {
        Name = 'Image',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = '',
        ZIndex = 5
    }, Avatar)
    corner(AvatarImage, 1, 1)

    task.spawn(function()
        if LocalPlayer then
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and thumb then AvatarImage.Image = thumb end
        end
    end)

    local UserName = create('TextLabel', {
        Name = 'Name',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = LocalPlayer and LocalPlayer.DisplayName or 'Stellar User',
        Size = UDim2.new(1, -58, 0, 14),
        Position = UDim2.fromOffset(52, 12),
        ZIndex = 4
    }, UserCard)
    bind(UserName, 'TextColor3', 'Text')

    local UserSub = create('TextLabel', {
        Name = 'Sub',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = '@' .. (LocalPlayer and LocalPlayer.Name or 'guest'),
        Size = UDim2.new(1, -58, 0, 12),
        Position = UDim2.fromOffset(52, 27),
        ZIndex = 4
    }, UserCard)
    bind(UserSub, 'TextColor3', 'Dim')

    local OnlineDot = create('Frame', {
        Name = 'Dot',
        Size = UDim2.fromOffset(7, 7),
        Position = UDim2.new(1, -12, 1, -12),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        ZIndex = 5
    }, UserCard)
    corner(OnlineDot, 1, 1)
    bind(OnlineDot, 'BackgroundColor3', 'Success')

    local NavLabel = create('TextLabel', {
        Name = 'NavLabel',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Dim,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'NAVIGATION',
        Size = UDim2.new(1, -24, 0, 10),
        Position = UDim2.fromOffset(14, 80),
        ZIndex = 3
    }, Sidebar)
    bind(NavLabel, 'TextColor3', 'Dim')

    local Tabs = create('ScrollingFrame', {
        Name = 'Tabs',
        Size = UDim2.new(1, -16, 1, -142),
        Position = UDim2.fromOffset(8, 94),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollBarImageTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Selectable = false,
        ZIndex = 3
    }, Sidebar)
    list_layout(Tabs, { Padding = UDim.new(0, 4) })

    local SidebarFooter = create('Frame', {
        Name = 'Footer',
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 1, -42),
        BackgroundColor3 = Theme.Panel_2,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Sidebar)
    corner(SidebarFooter, 8)
    bind(SidebarFooter, 'BackgroundColor3', 'Panel_2')

    local FooterDot = create('Frame', {
        Size = UDim2.fromOffset(6, 6),
        Position = UDim2.fromOffset(10, 12),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        ZIndex = 4
    }, SidebarFooter)
    corner(FooterDot, 1, 1)
    bind(FooterDot, 'BackgroundColor3', 'Success')

    create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Medium),
        TextColor3 = Theme.Muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = 'System ready',
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(22, 0),
        ZIndex = 4
    }, SidebarFooter)
    local FooterText = SidebarFooter:FindFirstChildWhichIsA('TextLabel')
    bind(FooterText, 'TextColor3', 'Muted')

    local HintKey = create('TextLabel', {
        Name = 'Hint',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(38, 14),
        BackgroundColor3 = Theme.Panel_4,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Dim,
        TextSize = 8,
        Text = 'CTRL',
        ZIndex = 4
    }, SidebarFooter)
    corner(HintKey, 4)
    bind(HintKey, 'BackgroundColor3', 'Panel_4')
    bind(HintKey, 'TextColor3', 'Dim')
    Tooltip.attach(HintKey, 'Toggle interface')

    -- content ------------------------------------------------------
    local Content = create('Frame', {
        Name = 'Content',
        Size = UDim2.new(1, -SIDEBAR_W, 1, 0),
        Position = UDim2.fromOffset(SIDEBAR_W, 0),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Body)

    local TabTitle = create('TextLabel', {
        Name = 'TabTitle',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Text,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Welcome',
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.fromOffset(20, 16),
        ZIndex = 3
    }, Content)
    bind(TabTitle, 'TextColor3', 'Text')

    local TabSubtitle = create('TextLabel', {
        Name = 'TabSubtitle',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = 'Stellar • Ethereal Edition',
        Size = UDim2.new(1, -40, 0, 14),
        Position = UDim2.fromOffset(20, 36),
        ZIndex = 3
    }, Content)
    bind(TabSubtitle, 'TextColor3', 'Dim')

    local header_line = create('Frame', {
        Name = 'HeaderLine',
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.fromOffset(20, 58),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 3
    }, Content)
    bind(header_line, 'BackgroundColor3', 'Border')

    local Columns = create('Frame', {
        Name = 'Columns',
        Size = UDim2.new(1, -40, 1, -74),
        Position = UDim2.fromOffset(20, 72),
        BackgroundTransparency = 1,
        ZIndex = 3
    }, Content)

    local COL_W = 248

    -- Each tab builds its own pair of scrolling columns inside `Columns`,
    -- so the base container only hosts the empty state until a tab exists.

    -- empty state
    local EmptyState = create('Frame', {
        Name = 'EmptyState',
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = true,
        ZIndex = 3
    }, Columns)
    local empty_label = create('TextLabel', {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.42),
        Size = UDim2.fromOffset(320, 40),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 11,
        TextWrapped = true,
        Text = 'No tabs yet.\nCreate one with library:create_tab("Main", "rbxassetid://...")'
    }, EmptyState)
    bind(empty_label, 'TextColor3', 'Dim')
    --=================================================================
    --  Store refs
    --=================================================================
    self._ui = Stellar
    self._refs = {
        Stellar = Stellar,
        Container = Container,
        TopBar = TopBar,
        Drag = Drag,
        Controls = Controls,
        SearchBox = SearchBox,
        SearchInput = SearchInput,
        Body = Body,
        Sidebar = Sidebar,
        Tabs = Tabs,
        Content = Content,
        TabTitle = TabTitle,
        TabSubtitle = TabSubtitle,
        Columns = Columns,
        EmptyState = EmptyState,
        EmptyLabel = empty_label,
        FooterDot = FooterDot,
        FooterText = FooterText,
        LogoMark = LogoMark,
        LogoImage = LogoImage,
        Product = Product,
        Edition = Edition,
        EditionLabel = EditionLabel,
        Close = Close,
        WIN_W = WIN_W,
        WIN_H = WIN_H
    }

    --=================================================================
    --  Search behaviour
    --=================================================================
    SearchInput:GetPropertyChangedSignal('Text'):Connect(function()
        -- typed text replaces the faded placeholder label
        if search_placeholder and search_placeholder.Parent then
            search_placeholder.TextTransparency = SearchInput.Text == '' and 0 or 1
        end
        self:set_search(SearchInput.Text)
    end)

    --=================================================================
    --  Dragging
    --=================================================================
    local function on_drag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position

            Connections['container_input_ended'] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then return end
                Connections:disconnect('container_input_ended')
                self._dragging = false
            end)
        end
    end

    local function drag(input)
        if not self._dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - self._drag_start
            local position = UDim2.new(
                self._container_position.X.Scale,
                self._container_position.X.Offset + delta.X,
                self._container_position.Y.Scale,
                self._container_position.Y.Offset + delta.Y
            )
            tween(Container, 0.18, { Position = position }, Enum.EasingStyle.Linear)
        end
    end

    Connections['container_input_began'] = Drag.InputBegan:Connect(on_drag)
    Connections['input_changed'] = UserInputService.InputChanged:Connect(drag)

    --=================================================================
    --  Window controls
    --=================================================================
    -- The animated logo in the top-left opens/minimizes the window.
    LogoMark.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    Close.MouseButton1Click:Connect(function()
        -- The × fully tears the interface down. Use the top-left logo (or
        -- Left CTRL) when you only want to minimize.
        self:destroy()
    end)

    Connections['library_visibility'] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode ~= Enum.KeyCode.LeftControl then return end
        self._ui_open = not self._ui_open
        self:change_visiblity(self._ui_open)
    end)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    --=================================================================
    --  Lifecycle helpers
    --=================================================================
    function self:Update1Run(alpha)
        if alpha == 'nil' or alpha == nil then
            Container.BackgroundTransparency = 0.05
        else
            pcall(function()
                Container.BackgroundTransparency = tonumber(alpha)
            end)
        end
    end

    function self:UIVisiblity()
        Stellar.Enabled = not Stellar.Enabled
    end

    -- The window's arrival/scale pop. Kept as its own UIScale so the mobile
    -- device scale (a separate instance) is never overwritten; the two
    -- multiply, and this one always settles at 1.
    local function window_scale()
        local scale = Container:FindFirstChild('StellarWindowScale')
        if not scale then
            scale = create('UIScale', { Name = 'StellarWindowScale', Scale = 1 }, Container)
        end
        return scale
    end

    function self:change_visiblity(state)
        -- Collapse any open dropdown accordion whenever the interface is
        -- minimized or reopened, so the card is not left half-expanded.
        if self._open_dropdown then
            self._open_dropdown:unfold_settings()
        end
        if state then
            Body.Visible = true
            TopBar.Search.Visible = true
            TopBar.Controls.Visible = true
            -- Allusive-style reopen: the window rises back into place and the
            -- scale springs from slightly small to rest.
            Container.Position = UDim2.new(0.5, 0, 0.5, 14)
            tween(Container, 0.45, { Size = UDim2.fromOffset(WIN_W, WIN_H), Position = UDim2.new(0.5, 0, 0.5, 0) })
            tween(Container, 0.4, { GroupTransparency = 0 })
            pop_scale(Container, 0.97, 1, 0.4, Enum.EasingStyle.Back)
        else
            -- a minimized window collapses the search pill too, so reopening
            -- starts from the tidy circular state
            collapse_search()
            tween(Container, 0.4, { Size = UDim2.fromOffset(148, TOPBAR_H) })
            pop_scale(Container, 1, 0.96, 0.3, Enum.EasingStyle.Quint)
            task.delay(0.18, function()
                if not self._ui_open then
                    Body.Visible = false
                    TopBar.Search.Visible = false
                    TopBar.Controls.Visible = false
                end
            end)
        end
    end

    function self:load()
        -- Hold the reveal until any active loader has finished. Without this
        -- the window faded in behind the loading card while it was still
        -- running, which looked like the loader had been skipped.
        if self._loader then
            self._loader:wait(tonumber(Library.Loader_Timeout))
            self._loader = nil
        end

        local images = {}
        for _, object in ipairs(Stellar:GetDescendants()) do
            if object:IsA('ImageLabel') and object.Image ~= '' then
                table.insert(images, object)
            end
        end
        pcall(function() ContentProvider:PreloadAsync(images) end)

        self:get_device()
        local ui_scale = create('UIScale', {}, Container)

        if self._device == 'Mobile' then
            self:get_screen_scale()
            ui_scale.Scale = self._ui_scale
            Connections['ui_scale'] = Workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
                self:get_screen_scale()
                ui_scale.Scale = self._ui_scale
            end)
        end

        tween(Container, 0.5, { Size = UDim2.fromOffset(WIN_W, WIN_H), GroupTransparency = 0 })
        -- Allusive-style arrival: the window starts slightly small and low,
        -- then springs up into place as it fades in.
        local arrive_scale = window_scale()
        arrive_scale.Scale = 0.92
        Container.Position = UDim2.new(0.5, 0, 0.5, 18)
        tween(arrive_scale, 0.55, { Scale = 1 }, Enum.EasingStyle.Back)
        tween(Container, 0.5, { Position = UDim2.new(0.5, 0, 0.5, 0) })
        if self.Acrylic == true then
            pcall(function() AcrylicBlur.new(Container) end)
        end
        self._ui_loaded = true
        -- The window is now being revealed, so it is safe to re-arm every
        -- module/feature/toggle whose saved state was restored during
        -- construction. Deferring these kept the script's feature logic from
        -- running behind the loading card before the UI appeared.
        self:flush_deferred()
    end

    return self
end

--=====================================================================
--  Search / filtering
--=====================================================================
function Library:set_search(text)
    self._search_text = tostring(text or ''):lower()
    local query = self._search_text
    local active = self._active_tab
    local matches_active = false

    for _, item in ipairs(self._search_items) do
        local frame = item.frame
        if frame and frame.Parent then
            local visible
            if query == '' then
                visible = true
            else
                local haystack = (tostring(item.title or '') .. ' ' .. tostring(item.description or '') .. ' ' .. tostring(item.keywords or '')):lower()
                visible = string.find(haystack, query, 1, true) ~= nil
            end
            -- cards that come back from a filter pop in instead of snapping
            if visible and not frame.Visible then
                frame.Visible = true
                pop_scale(frame, 0.96, 1, 0.24)
            else
                frame.Visible = visible
            end
            if frame.Visible and item.tab == active then
                matches_active = true
            end
        end
    end

    if active then
        if query ~= '' and not matches_active then
            self._refs.EmptyLabel.Text = 'No results for "' .. tostring(text) .. '"'
            self._refs.EmptyState.Visible = true
        else
            self._refs.EmptyState.Visible = false
        end
    end
end

--=====================================================================
--  Card geometry
--=====================================================================
local CARD_W = 248
local CARD_PAD_X = 12
local CARD_GAP = 8

--=====================================================================
--  Tab manager
--=====================================================================
local TabManager = {}
TabManager.__index = TabManager

--=====================================================================
--  Module manager
--=====================================================================
local ModuleManager = {}
ModuleManager.__index = ModuleManager

-- Keybind chip helper -------------------------------------------------
local function make_keybind_chip(parent, flag, library, on_change, tooltip_text)
    local chip = create('TextButton', {
        Name = 'Keybind',
        Size = UDim2.fromOffset(40, 18),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 6
    }, parent)
    corner(chip, 5)
    local chip_stroke = stroke(chip, Theme.Border, 1, 0.35)
    bind(chip, 'BackgroundColor3', 'Panel_3')
    bind(chip_stroke, 'Color', 'Border')

    local label = create('TextLabel', {
        Name = 'Label',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Dim,
        TextSize = 9,
        Text = '—',
        ZIndex = 7
    }, chip)
    bind(label, 'TextColor3', 'Dim')

    local function set_text(key)
        if key == nil or key == 'Unknown' or key == '' then
            label.Text = '—'
            label.TextColor3 = Theme.Dim
        else
            label.Text = tostring(key):gsub('Enum.KeyCode.', '')
            label.TextColor3 = Theme.Accent
        end
    end

    set_text(library._config._keybinds[flag])

    local function finish(key)
        library._config._keybinds[flag] = key
        library:autosave()
        set_text(key)
        if on_change then on_change(key) end
        if key == nil then
            library:status('Cleared keybind', 'warning')
        else
            library:status('Bound ' .. tostring(key):gsub('Enum.KeyCode.', ''), 'action')
        end
    end

    chip.MouseButton1Click:Connect(function()
        if library._choosing_keybind then return end
        library._choosing_keybind = true
        label.Text = '...'
        label.TextColor3 = Theme.Accent
        tween(chip_stroke, 0.2, { Color = Theme.Accent, Transparency = 0 })
        tween(chip, 0.2, { BackgroundTransparency = 0 })
        -- while listening the chip breathes, so it is obvious the UI is
        -- waiting for a key rather than ignoring the click
        local breathe = looping_tween(chip, 0.7, { BackgroundTransparency = 0.45 },
            Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, true)
        pop_scale(chip, 0.9, 1, 0.22)

        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end

            if connection then connection:Disconnect() end
            library._choosing_keybind = false
            if breathe then pcall(function() breathe:Cancel() end) end
            chip.BackgroundTransparency = 0.15
            tween(chip_stroke, 0.2, { Color = Theme.Border, Transparency = 0.35 })
            tween(chip, 0.2, { BackgroundTransparency = 0.15 })
            pop_scale(chip, 1.12, 1, 0.24)

            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                finish(nil)
            else
                finish(tostring(input.KeyCode))
            end
        end)
    end)

    chip.MouseButton2Click:Connect(function()
        finish(nil)
    end)

    if tooltip_text ~= false then
        Tooltip.attach(chip, tooltip_text or 'Click to bind · Right-click to clear')
    end

    -- Let `library:load_config` refresh the chip label for a loaded profile.
    library:register_keybind(flag, set_text)

    return { chip = chip, label = label, set_text = set_text, finish = finish }
end

-- Module construction -------------------------------------------------
local function build_module(parent, settings, library, tab, opts)
    opts = opts or {}
    local has_toggle = not opts.paragraph
    local has_description = settings.description ~= nil and settings.description ~= ''
    local header_h = has_description and 58 or 48

    local instance = setmetatable({
        _settings = settings,
        _library = library,
        _tab = tab,
        _state = false,
        _has_toggle = has_toggle,
        _header_h = header_h,
        _body_height = 0,
        _paragraph = opts.paragraph == true
    }, ModuleManager)

    local Module = create('Frame', {
        Name = 'Module',
        Size = UDim2.new(0, CARD_W, 0, header_h),
        BackgroundColor3 = Theme.Panel_2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4
    }, parent)
    corner(Module, 11)
    local module_stroke = stroke(Module, Theme.Border, 1, 0.35)
    bind(Module, 'BackgroundColor3', 'Panel_2')
    bind(module_stroke, 'Color', 'Border')

    local Header = create('TextButton', {
        Name = 'Header',
        Size = UDim2.new(1, 0, 0, header_h),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 5
    }, Module)

    -- accent rail (lights up while the module is enabled)
    local AccentRail = create('Frame', {
        Name = 'AccentRail',
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 6
    }, Module)
    corner(AccentRail, 1, 1)
    accent_gradient(AccentRail, 90)

    local IconBox = create('Frame', {
        Name = 'Icon',
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromOffset(14, math.floor((header_h - 30) / 2)),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        ZIndex = 6
    }, Header)
    corner(IconBox, 8)
    local icon_stroke = stroke(IconBox, Theme.Border, 1, 0.4)
    bind(IconBox, 'BackgroundColor3', 'Panel_3')
    bind(icon_stroke, 'Color', 'Border')

    local icon_id = Util:resolve_asset_id(settings.icon)
    if icon_id then
        local image = create('ImageLabel', {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = icon_id,
            ImageColor3 = Theme.Muted,
            ZIndex = 7
        }, IconBox)
        bind(image, 'ImageColor3', 'Muted')
        instance._status_icon = image
    else
        -- On/off status dot instead of a decorative glyph: it glows accent
        -- blue while the module is enabled, fades to grey while it is off,
        -- and pulses when the state flips (see instance:paint_status).
        local dot = create('Frame', {
            Name = 'StatusDot',
            Size = UDim2.fromOffset(9, 9),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Muted,
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            ZIndex = 7
        }, IconBox)
        corner(dot, 1, 1)
        local dot_stroke = stroke(dot, Theme.Accent, 1, 1)
        instance._status_dot = dot
        instance._status_dot_stroke = dot_stroke
    end

    local Title = create('TextLabel', {
        Name = 'Title',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = settings.title or 'Module',
        Size = UDim2.new(1, -156, 0, 16),
        Position = UDim2.fromOffset(54, has_description and 12 or math.floor((header_h - 16) / 2)),
        ZIndex = 6
    }, Header)
    bind(Title, 'TextColor3', 'Text')

    local Description
    if has_description then
        Description = create('TextLabel', {
            Name = 'Description',
            BackgroundTransparency = 1,
            FontFace = body_font(Enum.FontWeight.Regular),
            TextColor3 = Theme.Dim,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = settings.description,
            Size = UDim2.new(1, -156, 0, 12),
            Position = UDim2.fromOffset(54, 30),
            ZIndex = 6
        }, Header)
        bind(Description, 'TextColor3', 'Dim')
    end

    -- keybind + toggle
    local keybind
    if has_toggle and settings.flag then
        keybind = make_keybind_chip(Header, settings.flag, library, function()
            instance:connect_keybind()
        end)
        keybind.chip.Position = UDim2.new(1, -12 - 38 - 8 - 40, 0.5, 0)
        keybind.chip.AnchorPoint = Vector2.new(0, 0.5)
    end

    local Toggle, Knob
    if has_toggle then
        Toggle = create('Frame', {
            Name = 'Toggle',
            Size = UDim2.fromOffset(38, 20),
            Position = UDim2.new(1, -12 - 38, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.NotEnabled,
            BorderSizePixel = 0,
            ZIndex = 6
        }, Header)
        corner(Toggle, 1, 1)
        local toggle_stroke = stroke(Toggle, Theme.Border, 1, 0.5)
        bind(Toggle, 'BackgroundColor3', 'NotEnabled')
        bind(toggle_stroke, 'Color', 'Border')

        Knob = create('Frame', {
            Name = 'Knob',
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.Dim,
            BorderSizePixel = 0,
            ZIndex = 7
        }, Toggle)
        corner(Knob, 1, 1)
        bind(Knob, 'BackgroundColor3', 'Dim')
    end

    local Divider = create('Frame', {
        Name = 'Divider',
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.fromOffset(12, header_h - 1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 6
    }, Module)
    bind(Divider, 'BackgroundColor3', 'Border')

    local Body = create('Frame', {
        Name = 'Body',
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, header_h),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 5
    }, Module)
    list_layout(Body, { Padding = UDim.new(0, CARD_GAP) })
    padding(Body, 2, CARD_PAD_X, 12, CARD_PAD_X)

    instance._module = Module
    instance._header = Header
    instance._body = Body
    instance._title = Title
    instance._description = Description
    instance._toggle = Toggle
    instance._knob = Knob
    instance._keybind = keybind
    instance._accent_rail = AccentRail
    instance._divider = Divider
    instance._module_stroke = module_stroke

    -- Shared on/off paint for the module's status marker. Modules without a
    -- custom icon show the status dot (blue → grey/faded); modules with one
    -- get the icon tinted with the same language. `instant` skips the pulse
    -- (used by theme repaints).
    function instance:paint_status(state, instant)
        local on_color, off_color = Theme.Accent, Theme.Muted
        local dot = self._status_dot
        if dot and dot.Parent then
            local target = state and on_color or off_color
            local transparency = state and 0 or 0.45
            local ring = state and 0.55 or 1
            if instant then
                dot.BackgroundColor3 = target
                dot.BackgroundTransparency = transparency
                dot.Size = UDim2.fromOffset(9, 9)
                if self._status_dot_stroke then
                    self._status_dot_stroke.Color = on_color
                    self._status_dot_stroke.Transparency = ring
                end
            else
                tween(dot, 0.28, { BackgroundColor3 = target, BackgroundTransparency = transparency })
                if self._status_dot_stroke then
                    tween(self._status_dot_stroke, 0.28, { Color = on_color, Transparency = ring })
                end
                -- A quick breath so the change is felt, not just seen.
                local pulse = state and 12 or 7
                tween(dot, 0.16, { Size = UDim2.fromOffset(pulse, pulse) }, Enum.EasingStyle.Back)
                task.delay(0.18, function()
                    if dot.Parent and ((state and self._state) or (not state and not self._state)) then
                        tween(dot, 0.24, { Size = UDim2.fromOffset(9, 9) }, Enum.EasingStyle.Back)
                    end
                end)
            end
        end
        local image = self._status_icon
        if image and image.Parent then
            if instant then
                image.ImageColor3 = state and on_color or off_color
                image.ImageTransparency = state and 0 or 0.4
            else
                tween(image, 0.28, {
                    ImageColor3 = state and on_color or off_color,
                    ImageTransparency = state and 0 or 0.4
                })
                -- a small arrival pop so the flip is felt, not just seen
                pop_scale(image, state and 0.7 or 1.15, 1, 0.26)
            end
        end
    end

    -- keep the on/off look correct when the palette changes at runtime
    bind_fn(function()
        if not Module.Parent then return end
        if instance._state then
            Module.BackgroundColor3 = Theme.Panel_3
            module_stroke.Color = Theme.Accent
            module_stroke.Transparency = 0.7
            if Toggle then Toggle.BackgroundColor3 = Theme.Accent end
            if Knob then Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end
            if instance._status_dot then
                instance._status_dot.BackgroundColor3 = Theme.Accent
                instance._status_dot.BackgroundTransparency = 0
                if instance._status_dot_stroke then
                    instance._status_dot_stroke.Color = Theme.Accent
                    instance._status_dot_stroke.Transparency = 0.55
                end
            end
            if instance._status_icon then
                instance._status_icon.ImageColor3 = Theme.Accent
                instance._status_icon.ImageTransparency = 0
            end
        else
            Module.BackgroundColor3 = Theme.Panel_2
            module_stroke.Color = Theme.Border
            module_stroke.Transparency = 0.35
            if Toggle then Toggle.BackgroundColor3 = Theme.NotEnabled end
            if Knob then Knob.BackgroundColor3 = Theme.Dim end
            if instance._status_dot then
                instance._status_dot.BackgroundColor3 = Theme.Muted
                instance._status_dot.BackgroundTransparency = 0.45
                if instance._status_dot_stroke then
                    instance._status_dot_stroke.Transparency = 1
                end
            end
            if instance._status_icon then
                instance._status_icon.ImageColor3 = Theme.Muted
                instance._status_icon.ImageTransparency = 0.4
            end
        end
    end)

    -- The whole header is the hit target: clicking anywhere on the card's
    -- top row (including the switch) flips the module on or off. The keybind
    -- chip is a child button, so its clicks never reach the header.
    if has_toggle then
        Header.MouseButton1Click:Connect(function()
            instance:change_state(not instance._state)
        end)

        Header.MouseEnter:Connect(function()
            -- hover lifts the card: a brighter hairline and a small icon pop
            tween(module_stroke, 0.2, { Transparency = instance._state and 0.45 or 0.12 })
            pop_scale(IconBox, 1, 1.08, 0.18)
            if not instance._state then
                tween(Module, 0.2, { BackgroundColor3 = Theme.Panel_3 })
            end
        end)
        Header.MouseLeave:Connect(function()
            tween(module_stroke, 0.2, { Transparency = instance._state and 0.7 or 0.35 })
            pop_scale(IconBox, 1.08, 1, 0.22)
            if not instance._state then
                tween(Module, 0.2, { BackgroundColor3 = Theme.Panel_2 })
            end
        end)
    end

    -- Config apply hooks: the module switch, and re-arming its keybind.
    if has_toggle and settings.flag then
        local default = type(settings.default) == 'boolean' and settings.default or false
        library:register(settings.flag, function(value)
            instance:change_state(value and true or false, true, false)
        end, default, {
            kind = 'module',
            widget = instance,
            sync = function(value)
                -- silent: repaint only, the callback was queued at build
                instance:change_state(value and true or false, true, true)
            end,
            off = function()
                -- fires the callback with `false` so the feature stops
                if instance._state then instance:change_state(false) end
            end
        })
    end
    if settings.flag then
        library:register_keybind(settings.flag, function() instance:connect_keybind() end)
    end

    return instance
end

-- Recompute the body height from its children and resize the card.
function ModuleManager:refresh(instant)
    local total = 14 -- top + bottom padding
    local count = 0
    for _, child in ipairs(self._body:GetChildren()) do
        if child:IsA('GuiObject') and child.Visible then
            total = total + child.Size.Y.Offset
            count = count + 1
        end
    end
    total = total + math.max(0, count - 1) * CARD_GAP
    self._body_height = total
    self._body.Size = UDim2.new(1, 0, 0, total)

    if self._state then
        local target = UDim2.new(0, CARD_W, 0, self._header_h + total)
        if instant then
            self._module.Size = target
        else
            tween(self._module, 0.38, { Size = target })
        end
    end
end

function ModuleManager:change_state(state, initial, silent)
    if not self._has_toggle then return end
    local library = self._library
    -- A destroyed UI must not keep accepting toggles (the close button fired
    -- every feature off before this guard went live).
    if library and library._destroyed and not library._tearing_down then return end
    self._state = state

    -- The status dot (or custom icon) follows the same on/off language.
    self:paint_status(state, initial == true)

    if self._toggle then
        -- the knob squashes as it travels: a small mechanical detail that
        -- makes the switch feel like a real control (skipped on restore)
        if not initial and self._knob and self._knob.Parent then
            tween(self._knob, 0.1, { Size = UDim2.fromOffset(11, 11) })
            task.delay(0.1, function()
                if self._knob and self._knob.Parent then
                    tween(self._knob, 0.24, { Size = UDim2.fromOffset(14, 14) }, Enum.EasingStyle.Back)
                end
            end)
        end
        if state then
            tween(self._module, 0.4, { Size = UDim2.new(0, CARD_W, 0, self._header_h + self._body_height) })
            tween(self._toggle, 0.28, { BackgroundColor3 = Theme.Accent })
            tween(self._knob, 0.34, {
                Position = UDim2.fromOffset(21, 3),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, Enum.EasingStyle.Back)
            tween(self._module, 0.3, { BackgroundColor3 = Theme.Panel_3 })
            tween(self._module_stroke, 0.3, { Color = Theme.Accent, Transparency = 0.7 })
            self._accent_rail.Visible = true
            self._accent_rail.Size = UDim2.new(0, 3, 0, 0)
            tween(self._accent_rail, 0.4, { Size = UDim2.new(0, 3, 0, self._header_h - 16) }, Enum.EasingStyle.Back)
        else
            tween(self._module, 0.4, { Size = UDim2.new(0, CARD_W, 0, self._header_h) })
            tween(self._toggle, 0.28, { BackgroundColor3 = Theme.NotEnabled })
            tween(self._knob, 0.34, {
                Position = UDim2.fromOffset(3, 3),
                BackgroundColor3 = Theme.Dim
            }, Enum.EasingStyle.Back)
            tween(self._module, 0.3, { BackgroundColor3 = Theme.Panel_2 })
            tween(self._module_stroke, 0.3, { Color = Theme.Border, Transparency = 0.35 })
            tween(self._accent_rail, 0.25, { Size = UDim2.new(0, 3, 0, 0) })
            task.delay(0.25, function()
                if not self._state then
                    self._accent_rail.Visible = false
                end
            end)
        end
    end

    self._divider.Visible = state

    local flag = self._settings.flag
    -- While the teardown pass turns features off, the saved flags are left
    -- untouched: the player's config keeps the state they had, so the next
    -- session restores it instead of everything coming back disabled.
    if flag and not (library and library._tearing_down) then
        self._library._config._flags[flag] = state
        if not initial and not silent then
            self._library:autosave()
        end
    end

    -- Fire the callback on a construction/restore pass too. A module that was
    -- saved ON must re-arm its feature, not merely paint an "on" switch; the
    -- original Stellar library ran the callback while restoring. The callback
    -- is *queued* rather than run immediately, so the script's feature logic
    -- waits until `library:load()` has revealed the window instead of running
    -- behind the loading card. Live clicks still fire immediately.
    if self._settings.callback and not silent then
        if initial then
            local callback = self._settings.callback
            self._library:defer(function() callback(state) end)
        else
            self._settings.callback(state)
        end
    end

    if not initial and not silent and not (library and library._tearing_down) then
        self._library:status(
            (state and 'Enabled ' or 'Disabled ') .. tostring(self._settings.title or 'module'),
            state and 'success' or 'warning'
        )
    end
end

function ModuleManager:get_state()
    return self._state
end

-- Compatibility shim: the original Stellar library exposed the module's
-- callback through the module object, so scripts could re-run it on demand
-- (e.g. `no_render_module:callback(false)` during an unload routine).
-- Re-invoke the stored callback without touching the toggle state.
function ModuleManager:callback(state)
    if self._settings and self._settings.callback then
        self._settings.callback(state)
    end
end

function ModuleManager:connect_keybind()
    local flag = self._settings.flag
    if not flag then return end

    if Connections['keybind_press_' .. flag] then
        Connections:disconnect('keybind_press_' .. flag)
    end

    local stored = self._library._config._keybinds[flag]
    if not stored then return end

    Connections['keybind_press_' .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if tostring(input.KeyCode) == stored then
            self:change_state(not self._state)
        end
    end)
end

function ModuleManager:scale_keybind(empty)
    if not self._keybind then return end
    local chip = self._keybind.chip
    local target = empty and UDim2.fromOffset(40, 18) or UDim2.fromOffset(44, 18)
    tween(chip, 0.16, { Size = target }, Enum.EasingStyle.Back)
    task.delay(0.18, function()
        tween(chip, 0.16, { Size = UDim2.fromOffset(40, 18) })
    end)
end

--=====================================================================
--  Tab construction
--=====================================================================
function Library:create_tab(title, icon)
    local refs = self._refs
    local Tabs = refs.Tabs
    local Columns = refs.Columns

    local tab = setmetatable({
        _library = self,
        _title = title,
        _icon = icon,
        _modules = {}
    }, TabManager)

    local TabButton = create('TextButton', {
        Name = 'Tab',
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 4
    }, Tabs)
    corner(TabButton, 8)

    local active_pill = create('Frame', {
        Name = 'Pill',
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    }, TabButton)
    corner(active_pill, 1, 1)
    accent_gradient(active_pill, 90)

    local icon_id = Util:resolve_asset_id(icon)
    local icon_holder = create('Frame', {
        Name = 'Icon',
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(14, 9),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, TabButton)

    local icon_image
    if icon_id then
        icon_image = create('ImageLabel', {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = icon_id,
            ImageColor3 = Theme.Dim,
            ZIndex = 6
        }, icon_holder)
        bind(icon_image, 'ImageColor3', 'Dim')
    else
        icon_image = create('Frame', {
            Size = UDim2.fromOffset(9, 9),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Rotation = 45,
            BackgroundColor3 = Theme.Dim,
            BorderSizePixel = 0,
            ZIndex = 6
        }, icon_holder)
        corner(icon_image, 2)
        bind(icon_image, 'BackgroundColor3', 'Dim')
    end

    local TabLabel = create('TextLabel', {
        Name = 'Label',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = title or 'Tab',
        Size = UDim2.new(1, -52, 1, 0),
        Position = UDim2.fromOffset(38, 0),
        ZIndex = 5
    }, TabButton)
    bind(TabLabel, 'TextColor3', 'Dim')

    -- per-tab content sections
    local Sections = create('Frame', {
        Name = 'Sections',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 3
    }, Columns)

    local function make_column(name, x)
        local section = create('ScrollingFrame', {
            Name = name,
            Size = UDim2.new(0, CARD_W, 1, 0),
            Position = UDim2.fromOffset(x, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Selectable = false,
            ZIndex = 3
        }, Sections)
        list_layout(section, { Padding = UDim.new(0, 10) })
        return section
    end

    local LeftSection = make_column('LeftSection', 0)
    local RightSection = make_column('RightSection', CARD_W + 14)

    tab._button = TabButton
    tab._pill = active_pill
    tab._label = TabLabel
    tab._icon = icon_image
    tab._sections = Sections
    tab._left = LeftSection
    tab._right = RightSection

    table.insert(self._tabs, tab)

    local function activate(silent)
        for _, other in ipairs(self._tabs) do
            local is_active = other == tab
            other._sections.Visible = is_active
            if is_active then
                tween(other._button, 0.28, { BackgroundTransparency = 0.25, BackgroundColor3 = Theme.Panel_3 })
                tween(other._label, 0.28, { TextColor3 = Theme.Text })
                tween(other._pill, 0.34, { Size = UDim2.new(0, 3, 0, 18) }, Enum.EasingStyle.Back)
                if other._icon and other._icon:IsA('ImageLabel') then
                    tween(other._icon, 0.28, { ImageColor3 = Theme.Accent })
                elseif other._icon then
                    tween(other._icon, 0.28, { BackgroundColor3 = Theme.Accent })
                end
                -- Allusive-style arrival: the incoming section slides in from
                -- the right while scaling up to rest, so switching tabs feels
                -- like the content travels rather than teleports.
                if silent then
                    other._sections.Position = UDim2.fromOffset(0, 0)
                else
                    other._sections.Position = UDim2.fromOffset(16, 0)
                    pop_scale(other._sections, 0.97, 1, 0.32, Enum.EasingStyle.Quint)
                    tween(other._sections, 0.32, { Position = UDim2.fromOffset(0, 0) })
                end
            else
                tween(other._button, 0.28, { BackgroundTransparency = 1 })
                tween(other._label, 0.28, { TextColor3 = Theme.Dim })
                tween(other._pill, 0.25, { Size = UDim2.new(0, 3, 0, 0) })
                if other._icon and other._icon:IsA('ImageLabel') then
                    tween(other._icon, 0.28, { ImageColor3 = Theme.Dim })
                elseif other._icon then
                    tween(other._icon, 0.28, { BackgroundColor3 = Theme.Dim })
                end
            end
        end

        self._active_tab = tab
        -- the header crossfades to the new tab's title instead of snapping
        local new_title = title or 'Tab'
        local new_subtitle = tostring(#tab._modules) .. ' feature' .. (#tab._modules == 1 and '' or 's') .. ' available'
        if silent then
            refs.TabTitle.Text = new_title
            refs.TabSubtitle.Text = new_subtitle
        else
            tween(refs.TabTitle, 0.12, { TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(refs.TabSubtitle, 0.12, { TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.13, function()
                if not refs.TabTitle.Parent then return end
                refs.TabTitle.Text = new_title
                refs.TabSubtitle.Text = new_subtitle
                tween(refs.TabTitle, 0.22, { TextTransparency = 0 })
                tween(refs.TabSubtitle, 0.22, { TextTransparency = 0 })
            end)
        end
        refs.EmptyState.Visible = false
        if not silent then
            self:status('Opened ' .. tostring(title or 'tab'), 'action')
        end
    end

    tab._activate = activate
    TabButton.MouseButton1Click:Connect(activate)

    TabButton.MouseEnter:Connect(function()
        if self._active_tab ~= tab then
            tween(TabButton, 0.2, { BackgroundTransparency = 0.65, BackgroundColor3 = Theme.Panel_3 })
            tween(TabLabel, 0.2, { TextColor3 = Theme.Muted })
            -- the row nudges toward the cursor, hinting it is interactive
            tween(icon_holder, 0.2, { Position = UDim2.fromOffset(17, 9) })
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if self._active_tab ~= tab then
            tween(TabButton, 0.2, { BackgroundTransparency = 1 })
            tween(TabLabel, 0.2, { TextColor3 = Theme.Dim })
            tween(icon_holder, 0.2, { Position = UDim2.fromOffset(14, 9) })
        end
    end)

    if self._active_tab == nil then
        activate(true)
    end

    -- keep tab tinting correct through palette swaps
    bind_fn(function()
        if not TabButton.Parent then return end
        local is_active = self._active_tab == tab
        if is_active then
            TabButton.BackgroundColor3 = Theme.Panel_3
            TabLabel.TextColor3 = Theme.Text
            if icon_image:IsA('ImageLabel') then
                icon_image.ImageColor3 = Theme.Accent
            else
                icon_image.BackgroundColor3 = Theme.Accent
            end
        else
            TabButton.BackgroundColor3 = Theme.Panel_3
            TabLabel.TextColor3 = Theme.Dim
            if icon_image:IsA('ImageLabel') then
                icon_image.ImageColor3 = Theme.Dim
            else
                icon_image.BackgroundColor3 = Theme.Dim
            end
        end
    end)

    return tab
end

--=====================================================================
--  Tab component factories
--=====================================================================
function TabManager:create_module(settings)
    settings = settings or {}
    local parent = settings.section == 'right' and self._right or self._left
    local module = build_module(parent, settings, self._library, self, {})

    table.insert(self._modules, module)
    if self._library._active_tab == self then
        self._library._refs.TabSubtitle.Text = tostring(#self._modules) .. ' feature' .. (#self._modules == 1 and '' or 's') .. ' available'
    end

    table.insert(self._library._search_items, {
        frame = module._module,
        title = settings.title,
        description = settings.description,
        tab = self
    })

    if settings.flag or settings.default ~= nil then
        if settings.flag and self._library:flag_type(settings.flag, 'boolean') then
            -- `silent = false` so the callback fires and the feature re-arms;
            -- `initial = true` keeps autosave and the status footer quiet.
            module:change_state(self._library._config._flags[settings.flag], true, false)
        elseif settings.default ~= nil then
            module:change_state(settings.default, true, false)
        else
            module:change_state(false, true, true)
        end
    end
    if settings.flag then
        module:connect_keybind()
    end

    return module
end

function TabManager:moduleparagraph(settings)
    settings = settings or {}
    settings.section = settings.section or 'left'
    local parent = settings.section == 'right' and self._right or self._left
    local module = build_module(parent, settings, self._library, self, { paragraph = true })
    table.insert(self._modules, module)
    table.insert(self._library._search_items, {
        frame = module._module,
        title = settings.title,
        description = settings.description,
        tab = self
    })
    return module
end

function TabManager:create_image(settings)
    settings = settings or {}
    local parent = settings.section == 'right' and self._right or self._left
    local height = tonumber(settings.height) or 150

    local card = create('Frame', {
        Name = 'ImageModule',
        Size = UDim2.new(0, CARD_W, 0, height),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 4
    }, parent)
    corner(card, 11)
    local card_stroke = stroke(card, Theme.Border, 1, 0.35)
    bind(card, 'BackgroundColor3', 'Panel_2')
    bind(card_stroke, 'Color', 'Border')

    local image_id = Util:resolve_asset_id(settings.image)
    local image = create('ImageLabel', {
        Name = 'Image',
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        Image = image_id or '',
        ImageTransparency = image_id and (settings.transparency or 0) or 1,
        ScaleType = settings.scale_type or Enum.ScaleType.Crop,
        ZIndex = 5
    }, card)
    corner(image, 8)

    -- Graceful placeholder while there is no image (or if the asset fails).
    local placeholder = create('Frame', {
        Name = 'Placeholder',
        Size = image.Size,
        Position = image.Position,
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        Visible = image_id == nil,
        ZIndex = 5
    }, card)
    corner(placeholder, 8)
    bind(placeholder, 'BackgroundColor3', 'Panel_3')

    local placeholder_label = create('TextLabel', {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Dim,
        TextSize = 10,
        Text = settings.placeholder or 'No image',
        ZIndex = 6
    }, placeholder)
    bind(placeholder_label, 'TextColor3', 'Dim')

    if image_id then
        pcall(function()
            ContentProvider:PreloadAsync({ image }, function(_, status)
                if status ~= Enum.AssetFetchStatus.Success then
                    placeholder.Visible = true
                end
            end)
        end)
    end

    if settings.title then
        local caption = create('Frame', {
            Name = 'Caption',
            Size = UDim2.new(1, -16, 0, 26),
            Position = UDim2.new(0, 8, 1, -34),
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            ZIndex = 6
        }, card)
        corner(caption, 7)
        bind(caption, 'BackgroundColor3', 'Panel')

        local caption_label = create('TextLabel', {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Text,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = settings.title,
            ZIndex = 7
        }, caption)
        bind(caption_label, 'TextColor3', 'Text')
    end

    table.insert(self._library._search_items, {
        frame = card,
        title = settings.title or 'Image',
        description = settings.description,
        tab = self
    })
    return card
end

--=====================================================================
--  Field helpers
--=====================================================================
local BODY_W = CARD_W - CARD_PAD_X * 2

local _uid = 0
local function uid()
    _uid = _uid + 1
    return _uid
end

local function field_label(parent, text, size)
    local label = create('TextLabel', {
        Name = 'Label',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Muted,
        TextSize = size or 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = text or '',
        Size = UDim2.new(1, -60, 0, 13),
        ZIndex = 6
    }, parent)
    bind(label, 'TextColor3', 'Muted')
    return label
end

--=====================================================================
--  Paragraph / text
--=====================================================================
function ModuleManager:create_paragraph(settings)
    settings = settings or {}
    local title_text = settings.title
    local body_text = settings.text or settings.richtext or ''
    local rich = settings.rich == true

    local title_h = title_text and 15 or 0
    local body_h = math.max(14, measure_text(body_text, BODY_W - 18, 10))
    local height = 10 + title_h + (title_text and 5 or 0) + body_h + 10

    local frame = create('Frame', {
        Name = 'Paragraph',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 5
    }, self._body)
    corner(frame, 8)
    local frame_stroke = stroke(frame, Theme.Border, 1, 0.5)
    bind(frame, 'BackgroundColor3', 'Panel_3')
    bind(frame_stroke, 'Color', 'Border')

    if title_text then
        local title = create('TextLabel', {
            BackgroundTransparency = 1,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = title_text,
            Size = UDim2.new(1, -18, 0, 15),
            Position = UDim2.fromOffset(9, 9),
            ZIndex = 6
        }, frame)
        bind(title, 'TextColor3', 'Text')
    end

    local body = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = rich,
        Text = body_text,
        Size = UDim2.new(1, -18, 0, body_h),
        Position = UDim2.fromOffset(9, 9 + title_h + (title_text and 5 or 0)),
        ZIndex = 6
    }, frame)
    bind(body, 'TextColor3', 'Muted')

    self:refresh()
    return { _frame = frame }
end

function ModuleManager:create_text(settings)
    settings = settings or {}
    local rich = settings.rich == true
    local text_value = settings.text or settings.richtext or ''
    local height = math.max(28, measure_text(text_value, BODY_W - 18, 10) + 18)

    local frame = create('Frame', {
        Name = 'Text',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 5
    }, self._body)
    corner(frame, 8)
    local frame_stroke = stroke(frame, Theme.Border, 1, 0.5)
    bind(frame, 'BackgroundColor3', 'Panel_3')
    bind(frame_stroke, 'Color', 'Border')

    local body = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = rich,
        Text = text_value,
        Size = UDim2.new(1, -18, 0, height - 18),
        Position = UDim2.fromOffset(9, 9),
        ZIndex = 6
    }, frame)
    bind(body, 'TextColor3', 'Muted')

    local manager = { _frame = frame }
    local module = self

    function manager:Set(new_settings)
        new_settings = new_settings or {}
        local new_rich = new_settings.rich == true
        local new_text = new_settings.text or new_settings.richtext or ''
        body.RichText = new_rich
        body.Text = new_text
        local new_height = math.max(28, measure_text(new_text, BODY_W - 18, 10) + 18)
        frame.Size = UDim2.new(0, BODY_W, 0, new_height)
        body.Size = UDim2.new(1, -18, 0, new_height - 18)
        module:refresh()
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Textbox
--=====================================================================
function ModuleManager:create_textbox(settings)
    settings = settings or {}
    local manager = { _text = '', _library = self._library }
    local height = 47

    local frame = create('Frame', {
        Name = 'TextboxRow',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Input', 10).Position = UDim2.fromOffset(0, 0)

    -- Resolve the starting text once: a saved string wins (even an empty
    -- one), then the caller's `text`, then ''. Using `or` here would treat a
    -- deliberately-cleared field as "unset" and put the default back.
    local initial_text = settings.text or ''
    if settings.flag then
        local stored = self._library._config._flags[settings.flag]
        if type(stored) == 'string' then initial_text = stored end
    end
    manager._text = initial_text

    local box = create('TextBox', {
        Name = 'Textbox',
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.fromOffset(0, 17),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Dim,
        PlaceholderText = settings.placeholder or 'Enter text...',
        TextSize = 10,
        Text = initial_text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 6
    }, frame)
    corner(box, 7)
    padding(box, 0, 9, 0, 9)
    local box_stroke = stroke(box, Theme.Border, 1, 0.4)
    bind(box, 'BackgroundColor3', 'Panel_3')
    bind(box, 'TextColor3', 'Text')
    bind(box, 'PlaceholderColor3', 'Dim')
    bind(box_stroke, 'Color', 'Border')

    box.Focused:Connect(function()
        tween(box_stroke, 0.2, { Color = Theme.Accent, Transparency = 0.1 })
        tween(box, 0.2, { BackgroundColor3 = Theme.Panel_4 })
    end)
    box.FocusLost:Connect(function()
        tween(box_stroke, 0.2, { Color = Theme.Border, Transparency = 0.4 })
        tween(box, 0.2, { BackgroundColor3 = Theme.Panel_3 })
        manager:update_text(box.Text)
    end)

    function manager:update_text(text, silent)
        text = text == nil and '' or tostring(text)
        self._text = text
        if box.Text ~= text then box.Text = text end
        if settings.flag then
            self._library._config._flags[settings.flag] = text
            if not silent then self._library:autosave() end
        end
        -- Fire on restore too so a saved value is re-applied to the script.
        -- The construction restore (`silent`) is queued until the window is
        -- revealed; typing/submitting fires immediately.
        if settings.callback then
            if silent then
                local callback = settings.callback
                self._library:defer(function() callback(text) end)
            else
                settings.callback(text)
            end
        end
        if not silent then
            self._library:status(
                (settings.title or 'Input') .. ': ' .. (text ~= '' and tostring(text) or 'empty'),
                'info'
            )
        end
    end

    function manager:get_text()
        return manager._text
    end

    if settings.flag then
        self._library:register(settings.flag, function(value)
            manager:update_text(value, true)
        end, initial_text, { kind = 'textbox', widget = manager })
    end

    -- Re-apply a saved/default value on construction (quiet: no autosave or
    -- status) so a script that reads the field gets the restored text.
    manager:update_text(initial_text, true)

    self:refresh()
    return manager
end

--=====================================================================
--  Checkbox / toggle row
--=====================================================================
function ModuleManager:create_checkbox(settings)
    settings = settings or {}
    local manager = { _state = false, _library = self._library }
    local height = 24

    local row = create('TextButton', {
        Name = 'CheckboxRow',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 5
    }, self._body)

    local title = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = settings.title or 'Toggle',
        Size = UDim2.new(1, -60, 1, 0),
        ZIndex = 6
    }, row)
    bind(title, 'TextColor3', 'Text')

    local box = create('Frame', {
        Name = 'Box',
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.new(1, -18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        ZIndex = 6
    }, row)
    corner(box, 5)
    local box_stroke = stroke(box, Theme.Border, 1, 0.3)
    bind(box, 'BackgroundColor3', 'Panel_3')
    bind(box_stroke, 'Color', 'Border')

    local check_holder = create('Frame', {
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, box)
    local check = draw_check(check_holder, Color3.fromRGB(255, 255, 255), 1.7)

    local keybind_chip
    if settings.flag and settings.keybind ~= false then
        keybind_chip = make_keybind_chip(row, settings.flag, self._library, function(key)
            if settings.keybind_callback then settings.keybind_callback(key) end
        end)
        keybind_chip.chip.Position = UDim2.new(1, -26 - 8 - 40, 0.5, 0)
        keybind_chip.chip.AnchorPoint = Vector2.new(0, 0.5)
        title.Size = UDim2.new(1, -132, 1, 0)
    end

    function manager:change_state(state, initial, silent)
        local library = self._library
        if library and library._destroyed and not library._tearing_down then return end
        self._state = state
        if state then
            tween(box, 0.22, { BackgroundColor3 = Theme.Accent })
            tween(box_stroke, 0.22, { Color = Theme.Accent, Transparency = 0 })
            check_holder.Size = UDim2.fromOffset(12, 12)
            check.Visible = true
        else
            tween(box, 0.22, { BackgroundColor3 = Theme.Panel_3 })
            tween(box_stroke, 0.22, { Color = Theme.Border, Transparency = 0.3 })
            check_holder.Size = UDim2.fromOffset(0, 0)
            check.Visible = false
        end

        if settings.flag and not (self._library and self._library._tearing_down) then
            self._library._config._flags[settings.flag] = state
            -- `initial`/`silent` mark a restore/apply pass; don't rewrite the
            -- file for every widget while a config is being rebuilt.
            if not initial and not silent then self._library:autosave() end
        end
        -- A restored toggle must run its callback so the feature re-arms.
        -- Queue it until the window is revealed (see `Library:defer`); a live
        -- click still fires immediately.
        if not silent and settings.callback then
            if initial then
                local callback = settings.callback
                self._library:defer(function() callback(state) end)
            else
                settings.callback(state)
            end
        end
        if not initial and not silent then
            self._library:status(
                (state and 'Enabled ' or 'Disabled ') .. tostring(settings.title or 'toggle'),
                state and 'success' or 'warning'
            )
        end
    end

    function manager:get_state()
        return self._state
    end

    row.MouseButton1Click:Connect(function()
        manager:change_state(not manager._state)
    end)

    if settings.flag then
        local flag = settings.flag
        Connections['checkbox_key_' .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local stored = self._library._config._keybinds[flag]
            if stored and tostring(input.KeyCode) == stored then
                manager:change_state(not manager._state)
            end
        end)

        if self._library:flag_type(flag, 'boolean') then
            manager:change_state(self._library._config._flags[flag], true, false)
        elseif settings.default ~= nil then
            manager:change_state(settings.default, true, false)
        end

        -- Let `library:load_config` push a saved profile back into this row.
        local default = type(settings.default) == 'boolean' and settings.default or false
        self._library:register(flag, function(value)
            manager:change_state(value and true or false, true, false)
        end, default, {
            kind = 'toggle',
            widget = manager,
            sync = function(value)
                manager:change_state(value and true or false, true, true)
            end,
            off = function()
                if manager._state then manager:change_state(false) end
            end
        })
    end

    bind_fn(function()
        if not box.Parent then return end
        if manager._state then
            box.BackgroundColor3 = Theme.Accent
            box_stroke.Color = Theme.Accent
        else
            box.BackgroundColor3 = Theme.Panel_3
            box_stroke.Color = Theme.Border
        end
    end)

    self:refresh()
    return manager
end

ModuleManager.create_toggle = ModuleManager.create_checkbox

--=====================================================================
--  Button
--=====================================================================
function ModuleManager:create_button(settings)
    settings = settings or {}
    local height = 30

    local button = create('TextButton', {
        Name = 'Button',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        Text = settings.title or 'Button',
        AutoButtonColor = false,
        ZIndex = 5
    }, self._body)
    corner(button, 8)
    local variant = settings.variant
    if variant == 'ghost' then
        button.BackgroundColor3 = Theme.Panel_3
        button.TextColor3 = Theme.Text
        local s = stroke(button, Theme.Border, 1, 0.3)
        bind(button, 'BackgroundColor3', 'Panel_3')
        bind(button, 'TextColor3', 'Text')
        bind(s, 'Color', 'Border')
    elseif variant == 'danger' then
        button.BackgroundColor3 = Theme.Danger
        bind(button, 'BackgroundColor3', 'Danger')
    else
        accent_gradient(button, 0)
    end

    local base = button.BackgroundColor3
    local function base_color()
        if variant == 'ghost' then return Theme.Panel_3 end
        if variant == 'danger' then return Theme.Danger end
        return Theme.Accent
    end
    button.MouseEnter:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = base_color():Lerp(Color3.new(1, 1, 1), 0.14) })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.18, { BackgroundColor3 = base_color() })
    end)
    button.MouseButton1Down:Connect(function()
        tween(button, 0.08, { BackgroundColor3 = base_color():Lerp(Color3.new(0, 0, 0), 0.12) })
    end)
    button.MouseButton1Up:Connect(function()
        tween(button, 0.14, { BackgroundColor3 = base_color():Lerp(Color3.new(1, 1, 1), 0.14) })
    end)

    button.MouseButton1Click:Connect(function()
        if settings.callback then settings.callback() end
        self._library:status(settings.title or 'Action', variant == 'danger' and 'error' or 'action')
    end)

    self:refresh()
    return button
end

--=====================================================================
--  Divider / section header
--=====================================================================
function ModuleManager:create_divider(settings)
    settings = settings or {}
    -- `disableline` (used by the original Stellar API) draws the topic label
    -- on its own, without the hairline rule through it.
    local height = settings.disableline and 16 or 20

    local frame = create('Frame', {
        Name = 'Divider',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local line
    if not settings.disableline then
        line = create('Frame', {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            ZIndex = 5
        }, frame)
        gradient(line, ColorSequence.new(Color3.fromRGB(255, 255, 255)), 0, NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        }))
        bind(line, 'BackgroundColor3', 'Border')
    end

    if settings.showtopic and settings.title then
        local label = create('TextLabel', {
            BackgroundColor3 = Theme.Panel_2,
            BackgroundTransparency = 0,
            FontFace = font(Enum.FontWeight.SemiBold),
            TextColor3 = Theme.Muted,
            TextSize = 10,
            Text = settings.title,
            Size = UDim2.new(0, 140, 0, 14),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 6
        }, frame)
        bind(label, 'TextColor3', 'Muted')
        bind(label, 'BackgroundColor3', 'Panel_2')
    end

    self:refresh()
    return frame
end

function ModuleManager:create_section(settings)
    settings = settings or {}
    local height = 24

    local frame = create('Frame', {
        Name = 'Section',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local label = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.Bold),
        TextColor3 = Theme.Dim,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = string.upper(settings.title or 'Section'),
        Size = UDim2.new(1, -60, 0, 12),
        Position = UDim2.fromOffset(0, 6),
        ZIndex = 6
    }, frame)
    bind(label, 'TextColor3', 'Dim')

    create('Frame', {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.fromOffset(0, 20),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 5
    }, frame)

    self:refresh()
    return frame
end

--=====================================================================
--  Slider
--=====================================================================
function ModuleManager:create_slider(settings)
    settings = settings or {}
    local manager = {}
    local minimum = settings.minimum_value or 0
    local maximum = settings.maximum_value or 100
    local height = 42

    local frame = create('Frame', {
        Name = 'Slider',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Slider', 10).Position = UDim2.fromOffset(0, 0)

    local value_label = create('TextLabel', {
        Name = 'Value',
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = '0',
        Size = UDim2.new(0, 70, 0, 13),
        Position = UDim2.new(1, -70, 0, 0),
        ZIndex = 6
    }, frame)
    bind(value_label, 'TextColor3', 'Text')

    local track = create('Frame', {
        Name = 'Track',
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.fromOffset(0, 30),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0,
        ZIndex = 5
    }, frame)
    corner(track, 1, 1)
    bind(track, 'BackgroundColor3', 'Panel_4')

    local fill = create('Frame', {
        Name = 'Fill',
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    }, track)
    corner(fill, 1, 1)
    accent_gradient(fill, 0)

    local knob = create('Frame', {
        Name = 'Knob',
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 7
    }, track)
    corner(knob, 1, 1)
    local knob_stroke = stroke(knob, Theme.Accent, 2, 0)
    bind(knob_stroke, 'Color', 'Accent')

    -- A plain Frame does not receive InputBegan in Roblox unless Active is
    -- true. Use an invisible TextButton as the hit target instead: buttons
    -- always sink input, and a taller strip makes the thin track easy to
    -- grab on touch devices.
    local hit = create('TextButton', {
        Name = 'Hit',
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.fromOffset(0, 23),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 8
    }, frame)

    local dragging = false

    local function format(value)
        if settings.round_number then
            return tostring(math.floor(value + 0.5))
        end
        return tostring(math.floor(value * 10 + 0.5) / 10)
    end

    local function apply(value, save, fire, defer)
        value = math.clamp(value, minimum, maximum)
        local percentage = 0
        if maximum ~= minimum then
            percentage = (value - minimum) / (maximum - minimum)
        end
        tween(fill, 0.1, { Size = UDim2.new(percentage, 0, 1, 0) }, Enum.EasingStyle.Linear)
        knob.Position = UDim2.new(percentage, 0, 0.5, 0)
        value_label.Text = format(value) .. (settings.suffix or '')

        if settings.flag then
            self._library._config._flags[settings.flag] = value
            if save then self._library:autosave() end
        end
        manager._value = value
        if fire and settings.callback then
            if defer then
                local callback = settings.callback
                self._library:defer(function() callback(value) end)
            else
                settings.callback(value)
            end
        end
    end

    function manager:set_percentage(value)
        apply(value, true, true)
    end

    function manager:get_value()
        return manager._value
    end

    local function update_from_mouse(pixel_x)
        -- `pixel_x` comes from InputObject.Position, which matches
        -- AbsolutePosition. Fall back to GetMouseLocation only when needed.
        if pixel_x == nil then
            pixel_x = UserInputService:GetMouseLocation().X
        end
        local track_x = track.AbsolutePosition.X
        local track_width = math.max(1, track.AbsoluteSize.X)
        local alpha = math.clamp((pixel_x - track_x) / track_width, 0, 1)
        apply(minimum + (maximum - minimum) * alpha, false, true)
    end

    local slider_id = 'slider_' .. tostring(uid())
    local function cleanup_slider()
        Connections:disconnect(slider_id .. '_move')
        Connections:disconnect(slider_id .. '_end')
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = true
        tween(knob, 0.15, { Size = UDim2.fromOffset(15, 15) }, Enum.EasingStyle.Back)
        update_from_mouse(input.Position.X)

        cleanup_slider()
        Connections[slider_id .. '_move'] = UserInputService.InputChanged:Connect(function(move_input)
            if move_input.UserInputType == Enum.UserInputType.MouseMovement or move_input.UserInputType == Enum.UserInputType.Touch then
                update_from_mouse(move_input.Position.X)
            end
        end)

        Connections[slider_id .. '_end'] = UserInputService.InputEnded:Connect(function(end_input)
            if end_input.UserInputType ~= Enum.UserInputType.MouseButton1 and end_input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            dragging = false
            tween(knob, 0.15, { Size = UDim2.fromOffset(12, 12) })
            cleanup_slider()
            if not settings.ignoresaved and settings.flag then
                self._library:autosave()
            end
            self._library:status(
                (settings.title or 'Slider') .. ' set to ' .. format(manager._value or minimum) .. (settings.suffix or ''),
                'info'
            )
        end)
    end)

    hit.MouseEnter:Connect(function()
        if not dragging then tween(knob, 0.15, { Size = UDim2.fromOffset(14, 14) }) end
    end)
    hit.MouseLeave:Connect(function()
        if not dragging then tween(knob, 0.15, { Size = UDim2.fromOffset(12, 12) }) end
    end)

    local initial = settings.value or minimum
    if settings.flag and self._library:flag_type(settings.flag, 'number') and not settings.ignoresaved then
        initial = self._library._config._flags[settings.flag]
    end
    -- `fire = true`: a restored slider must re-apply its value, not just draw
    -- the knob at the saved position. `save = false` keeps construction quiet,
    -- and `defer = true` queues the callback until the window is shown.
    apply(initial, false, true, true)

    if settings.flag and not settings.ignoresaved then
        self._library:register(settings.flag, function(value)
            if type(value) == 'number' then manager:set_percentage(value) end
        end, initial, { kind = 'slider', widget = manager })
    end

    manager._frame = frame
    manager._hit = hit
    manager._track = track

    self:refresh()
    return manager
end

--=====================================================================
--  Dropdown
--=====================================================================
function ModuleManager:create_dropdown(settings)
    settings = settings or {}
    local library = self._library
    local manager = { _state = false, _module = self, _value = nil }
    local options = {}
    for _, option in ipairs(settings.options or {}) do
        table.insert(options, option)
    end

    local option_height = 26
    local option_gap = 2
    local max_visible = settings.maximum_options or 7
    local row_height = 48

    local function list_height_for(count)
        count = math.min(count, max_visible)
        if count <= 0 then return 0 end
        return count * option_height + (count - 1) * option_gap + 8
    end

    local frame = create('Frame', {
        Name = 'Dropdown',
        Size = UDim2.new(0, BODY_W, 0, row_height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Dropdown', 10).Position = UDim2.fromOffset(0, 0)

    local box = create('TextButton', {
        Name = 'Box',
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.fromOffset(0, 16),
        BackgroundColor3 = Theme.Panel_3,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 6
    }, frame)
    corner(box, 8)
    local box_stroke = stroke(box, Theme.Border, 1, 0.4)
    bind(box, 'BackgroundColor3', 'Panel_3')
    bind(box_stroke, 'Color', 'Border')

    local current_label = create('TextLabel', {
        Name = 'Current',
        BackgroundTransparency = 1,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tr('DropdownNone', 'None'),
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        ZIndex = 7
    }, box)
    bind(current_label, 'TextColor3', 'Muted')

    local chevron_holder = create('Frame', {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(1, -20, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, box)
    local chevron = draw_chevron(chevron_holder, 10, Theme.Dim, 1.6)
    bind_fn(function()
        if not chevron.Parent then return end
        for _, child in ipairs(chevron:GetDescendants()) do
            if child:IsA('Frame') then child.BackgroundColor3 = Theme.Dim end
        end
    end)

    -- Classic Stellar accordion: the option list expands *inside* the card,
    -- directly under the box. The dropdown row grows and `refresh()` grows the
    -- module card with it, so the list is never clipped and the cards below
    -- slide down naturally.
    local list = create('ScrollingFrame', {
        Name = 'List',
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, row_height),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Active = true,
        ZIndex = 5
    }, frame)
    corner(list, 8)
    local list_stroke = stroke(list, Theme.Border, 1, 0.35)
    list_layout(list, { Padding = UDim.new(0, option_gap) })
    padding(list, 4, 4, 4, 4)
    bind(list, 'BackgroundColor3', 'Panel_3')
    bind(list_stroke, 'Color', 'Border')

    -- Exposed for introspection / tests.
    manager._list = list
    manager._box = box
    manager._frame = frame
    manager._box_stroke = box_stroke

    local option_buttons = {}

    local function display(value)
        if settings.multi_dropdown then
            local values = value or {}
            if type(values) ~= 'table' then values = { values } end
            if #values == 0 then return tr('DropdownNone', 'None') end
            local names = {}
            for _, item in ipairs(values) do
                table.insert(names, typeof(item) == 'string' and item or item.Name)
            end
            return table.concat(names, ', ')
        end
        if value == nil then return tr('DropdownNone', 'None') end
        return typeof(value) == 'string' and value or value.Name
    end

    local function refresh_selection(value)
        local lookup = {}
        if settings.multi_dropdown then
            local values = value or {}
            if type(values) ~= 'table' then values = { values } end
            for _, item in ipairs(values) do lookup[item] = true end
        end
        for option_value, entry in pairs(option_buttons) do
            local selected
            if settings.multi_dropdown then
                selected = lookup[option_value] == true
            else
                selected = option_value == value
            end
            entry.mark.Visible = selected
            entry.button.TextColor3 = selected and Theme.Accent or Theme.Muted
        end
    end

    function manager:update(value, silent)
        manager._value = value
        current_label.Text = display(value)
        refresh_selection(value)
        if settings.flag then
            library._config._flags[settings.flag] = value
            if not silent then library:autosave() end
        end
        -- The callback always runs: a restored selection has to be applied.
        -- `silent` marks the construction restore, whose callback is queued
        -- until the window is revealed instead of firing behind the loader.
        if settings.callback then
            if silent then
                local callback = settings.callback
                library:defer(function() callback(value) end)
            else
                settings.callback(value)
            end
        end
        if not silent then
            library:status((settings.title or 'Dropdown') .. ': ' .. display(value), 'info')
        end
    end

    -- The row is `row_height` tall when closed; opening adds the list height.
    -- The row size is applied instantly and `refresh()` animates the card, so
    -- the card visibly unfolds to reveal the options.
    local function apply_open_size()
        local list_h = manager._state and list_height_for(#options) or 0
        list.Size = UDim2.new(1, 0, 0, list_h)
        frame.Size = UDim2.new(0, BODY_W, 0, row_height + list_h)
        self:refresh()
    end

    local function close_list()
        if not manager._state then return end
        manager._state = false
        if library._open_dropdown == manager then library._open_dropdown = nil end
        list.Visible = false
        apply_open_size()
        tween(chevron_holder, 0.25, { Rotation = 0 })
        tween(box_stroke, 0.2, { Color = Theme.Border, Transparency = 0.4 })
    end

    function manager:unfold_settings()
        if manager._state then
            close_list()
            return
        end
        if library._open_dropdown and library._open_dropdown ~= manager then
            library._open_dropdown:unfold_settings()
        end
        manager._state = true
        library._open_dropdown = manager
        list.Visible = true
        apply_open_size()
        tween(chevron_holder, 0.25, { Rotation = 180 })
        tween(box_stroke, 0.2, { Color = Theme.Accent, Transparency = 0.2 })
        -- the options cascade in one after another instead of appearing as a
        -- single block, which keeps the unfold feeling deliberate
        local index = 0
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA('TextButton') then
                index = index + 1
                local option = child
                local stagger = math.min(0.2, (index - 1) * 0.035)
                option.TextTransparency = 1
                task.delay(stagger, function()
                    if option.Parent then
                        tween(option, 0.2, { TextTransparency = 0 })
                    end
                end)
            end
        end
    end

    local function rebuild(new_options)
        options = new_options or {}
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA('TextButton') then child:Destroy() end
        end
        option_buttons = {}

        for _, option_value in ipairs(options) do
            local text = typeof(option_value) == 'string' and option_value or option_value.Name
            local option = create('TextButton', {
                Name = 'Option',
                Size = UDim2.new(1, 0, 0, option_height),
                BackgroundColor3 = Theme.Panel_4,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                FontFace = body_font(Enum.FontWeight.Regular),
                TextColor3 = Theme.Muted,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                AutoButtonColor = false,
                ZIndex = 6
            }, list)
            corner(option, 6)
            padding(option, 0, 8, 0, 8)
            bind(option, 'BackgroundColor3', 'Panel_4')

            local mark = create('Frame', {
                Name = 'Mark',
                Size = UDim2.fromOffset(10, 10),
                Position = UDim2.new(1, -10, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Visible = false,
                ZIndex = 7
            }, option)
            draw_check(mark, Theme.Accent, 1.6)
            bind_fn(function()
                if not mark.Parent then return end
                for _, child in ipairs(mark:GetDescendants()) do
                    if child:IsA('Frame') then child.BackgroundColor3 = Theme.Accent end
                end
            end)

            option.MouseEnter:Connect(function()
                tween(option, 0.15, { BackgroundTransparency = 0.6 })
            end)
            option.MouseLeave:Connect(function()
                tween(option, 0.15, { BackgroundTransparency = 1 })
            end)
            option.MouseButton1Click:Connect(function()
                if settings.multi_dropdown then
                    local current = settings.flag and library._config._flags[settings.flag] or manager._value
                    if type(current) ~= 'table' then current = {} end
                    local next_list = {}
                    local found = false
                    for _, item in ipairs(current) do
                        if item == option_value then
                            found = true
                        else
                            table.insert(next_list, item)
                        end
                    end
                    if not found then table.insert(next_list, option_value) end
                    manager:update(next_list)
                else
                    manager:update(option_value)
                    close_list()
                end
            end)

            option_buttons[option_value] = { mark = mark, button = option }
        end
    end

    function manager:set_options(new_options)
        rebuild(new_options)
        if manager._state then apply_open_size() end
    end

    function manager:New(value)
        if value and value.options then
            manager:set_options(value.options)
        end
        return manager
    end

    box.MouseButton1Click:Connect(function()
        manager:unfold_settings()
    end)

    rebuild(options)

    local initial
    if settings.flag and library._config._flags[settings.flag] ~= nil then
        initial = library._config._flags[settings.flag]
    elseif settings.multi_dropdown then
        initial = {}
    else
        initial = settings.value or options[1]
    end
    -- Quiet restore: paints the label/selection, writes the flag, and fires
    -- the callback (so a saved choice is re-applied) without an autosave.
    manager:update(initial, true)

    bind_fn(function()
        if not frame.Parent then return end
        local value = initial
        if settings.flag then
            value = library._config._flags[settings.flag]
        end
        refresh_selection(value)
    end)

    if settings.flag and not settings.ignoresaved then
        library:register(settings.flag, function(value)
            if settings.multi_dropdown and type(value) ~= 'table' then value = {} end
            manager:update(value)
        end, initial, { kind = 'dropdown', widget = manager })
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Feature row (compact toggle + keybind)
--=====================================================================
function ModuleManager:create_feature(settings)
    settings = settings or {}
    local height = 26
    local manager = { _state = false, _library = self._library }

    local row = create('Frame', {
        Name = 'Feature',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local title = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = settings.title or 'Feature',
        Size = UDim2.new(1, -100, 1, 0),
        ZIndex = 6
    }, row)
    bind(title, 'TextColor3', 'Text')

    local box
    local check
    if not settings.disablecheck then
        box = create('TextButton', {
            Name = 'Box',
            Size = UDim2.fromOffset(18, 18),
            Position = UDim2.new(1, -18, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Panel_3,
            BorderSizePixel = 0,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 6
        }, row)
        corner(box, 5)
        local box_stroke = stroke(box, Theme.Border, 1, 0.3)
        bind(box, 'BackgroundColor3', 'Panel_3')
        bind(box_stroke, 'Color', 'Border')

        local holder = create('Frame', {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 7
        }, box)
        check = draw_check(holder, Color3.fromRGB(255, 255, 255), 1.7)
        check.Visible = false

        function manager:change_state(state, initial, silent)
            local library = self._library
            if library and library._destroyed and not library._tearing_down then return end
            self._state = state
            if state then
                tween(box, 0.2, { BackgroundColor3 = Theme.Accent })
                tween(box_stroke, 0.2, { Color = Theme.Accent, Transparency = 0 })
                holder.Size = UDim2.fromOffset(12, 12)
                check.Visible = true
            else
                tween(box, 0.2, { BackgroundColor3 = Theme.Panel_3 })
                tween(box_stroke, 0.2, { Color = Theme.Border, Transparency = 0.3 })
                holder.Size = UDim2.fromOffset(0, 0)
                check.Visible = false
            end
            if settings.flag and not (self._library and self._library._tearing_down) then
                self._library._config._flags[settings.flag] = state
                if not initial and not silent then self._library:autosave() end
            end
            if not silent and settings.callback then
                if initial then
                    local callback = settings.callback
                    self._library:defer(function() callback(state) end)
                else
                    settings.callback(state)
                end
            end
        end

        bind_fn(function()
            if not box.Parent then return end
            if manager._state then
                box.BackgroundColor3 = Theme.Accent
                box_stroke.Color = Theme.Accent
            else
                box.BackgroundColor3 = Theme.Panel_3
                box_stroke.Color = Theme.Border
            end
        end)
    else
        local action = create('TextButton', {
            Name = 'Action',
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 6
        }, row)
        action.MouseButton1Click:Connect(function()
            if settings.button_callback then settings.button_callback() end
        end)
    end

    if settings.flag then
        local chip = make_keybind_chip(row, settings.flag, self._library, function(key)
            if settings.keybind_callback then settings.keybind_callback(key) end
        end)
        chip.chip.Position = UDim2.new(1, -26 - 8 - 40, 0.5, 0)
        chip.chip.AnchorPoint = Vector2.new(0, 0.5)
        title.Size = UDim2.new(1, -132, 1, 0)
    end

    if box then
        box.MouseButton1Click:Connect(function()
            manager:change_state(not manager._state)
        end)
    end

    if settings.flag then
        local flag = settings.flag
        Connections['feature_key_' .. flag] = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local stored = self._library._config._keybinds[flag]
            if stored and tostring(input.KeyCode) == stored then
                if manager.change_state then manager:change_state(not manager._state) end
            end
        end)
    end

    if manager.change_state then
        local flag = settings.flag
        if flag and self._library:flag_type(flag, 'boolean') then
            manager:change_state(self._library._config._flags[flag], true, false)
        elseif type(settings.default) == 'boolean' then
            -- Only a boolean `default` is an initial checked state. The
            -- original library used `default` for the keybind label
            -- ("Unknown"), so a string must never turn the feature on.
            manager:change_state(settings.default, true, false)
        end
        if flag then
            local default = type(settings.default) == 'boolean' and settings.default or false
            self._library:register(flag, function(value)
                manager:change_state(value and true or false, true, false)
            end, default, {
                kind = 'feature',
                widget = manager,
                sync = function(value)
                    manager:change_state(value and true or false, true, true)
                end,
                off = function()
                    if manager._state then manager:change_state(false) end
                end
            })
        end
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Standalone keybind row
--=====================================================================
function ModuleManager:create_keybind(settings)
    settings = settings or {}
    local height = 26

    local row = create('Frame', {
        Name = 'KeybindRow',
        Size = UDim2.new(0, BODY_W, 0, height),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, self._body)

    local title = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = settings.title or 'Keybind',
        Size = UDim2.new(1, -60, 1, 0),
        ZIndex = 6
    }, row)
    bind(title, 'TextColor3', 'Text')

    local manager = {}
    if settings.flag then
        local chip = make_keybind_chip(row, settings.flag, self._library, function(key)
            if settings.callback then settings.callback(key) end
        end)
        chip.chip.Position = UDim2.new(1, -40, 0.5, 0)
        chip.chip.AnchorPoint = Vector2.new(0, 0.5)
        manager.set = chip.set_text
    end

    self:refresh()
    return manager
end

--=====================================================================
--  Color picker
--=====================================================================
function ModuleManager:create_colorpicker(settings)
    settings = settings or {}
    local manager = { _state = false, _module = self }
    local height_closed = 30
    local picker_height = 132

    local frame = create('Frame', {
        Name = 'ColorPicker',
        Size = UDim2.new(0, BODY_W, 0, height_closed),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 5
    }, self._body)

    field_label(frame, settings.title or 'Color', 10).Position = UDim2.fromOffset(0, 3)

    local swatch = create('TextButton', {
        Name = 'Swatch',
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = '',
        AutoButtonColor = false,
        ZIndex = 6
    }, frame)
    corner(swatch, 6)
    local swatch_stroke = stroke(swatch, Theme.Border, 1, 0.2)
    bind(swatch_stroke, 'Color', 'Border')

    local swatch_hex = create('TextLabel', {
        BackgroundTransparency = 1,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 9,
        Text = '#FFFFFF',
        ZIndex = 7
    }, swatch)

    local panel = create('Frame', {
        Name = 'Panel',
        Size = UDim2.new(1, 0, 0, picker_height),
        Position = UDim2.fromOffset(0, height_closed),
        BackgroundColor3 = Theme.Panel_3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        -- A Frame with ClipsDescendants still delivers input to children that
        -- are visually clipped away in Roblox. The panel starts hidden so the
        -- collapsed picker's invisible SV/hue drag zones cannot swallow
        -- touches below the swatch; `set_panel_open` reveals it on expand.
        Visible = false,
        ZIndex = 6
    }, frame)
    corner(panel, 8)
    local panel_stroke = stroke(panel, Theme.Border, 1, 0.5)
    bind(panel, 'BackgroundColor3', 'Panel_3')
    bind(panel_stroke, 'Color', 'Border')

    local sv = create('Frame', {
        Name = 'SV',
        Size = UDim2.fromOffset(120, 84),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 7
    }, panel)
    corner(sv, 6)

    local sv_white = create('Frame', {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 8
    }, sv)
    corner(sv_white, 6)
    gradient(sv_white, ColorSequence.new(Color3.fromRGB(255, 255, 255)), 0, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }))

    local sv_black = create('Frame', {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 9
    }, sv)
    corner(sv_black, 6)
    gradient(sv_black, ColorSequence.new(Color3.fromRGB(0, 0, 0)), 90, NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }))
    -- A crisp hairline makes the square's real bounds obvious, so the touch
    -- target reads as the box and not the panel around it.
    local sv_stroke = stroke(sv_black, Theme.Border, 1, 0.25)
    bind(sv_stroke, 'Color', 'Border')

    local sv_marker = create('Frame', {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromScale(1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 10
    }, sv)
    corner(sv_marker, 1, 1)
    create('UIStroke', {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, sv_marker)

    -- Buttons always receive InputBegan; a bare Frame does not unless it is
    -- made Active. These transparent overlays make the picker draggable.
    local sv_hit = create('TextButton', {
        Name = 'SVHit',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 11
    }, sv)

    local hue_bar = create('Frame', {
        Name = 'Hue',
        Size = UDim2.fromOffset(120, 12),
        Position = UDim2.fromOffset(10, 104),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 7
    }, panel)
    corner(hue_bar, 1, 1)
    gradient(hue_bar, ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    }), 0)
    local hue_stroke = stroke(hue_bar, Theme.Border, 1, 0.25)
    bind(hue_stroke, 'Color', 'Border')

    local hue_marker = create('Frame', {
        Size = UDim2.fromOffset(4, 16),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 8
    }, hue_bar)
    corner(hue_marker, 2)

    local hue_hit = create('TextButton', {
        Name = 'HueHit',
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = '',
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 9
    }, hue_bar)

    local hex_box = create('TextBox', {
        Name = 'Hex',
        Size = UDim2.fromOffset(84, 26),
        Position = UDim2.fromOffset(140, 10),
        BackgroundColor3 = Theme.Panel_4,
        BorderSizePixel = 0,
        FontFace = body_font(Enum.FontWeight.Regular),
        TextColor3 = Theme.Text,
        TextSize = 10,
        Text = '#FFFFFF',
        ClearTextOnFocus = false,
        ZIndex = 7
    }, panel)
    corner(hex_box, 6)
    padding(hex_box, 0, 8, 0, 8)
    bind(hex_box, 'BackgroundColor3', 'Panel_4')
    bind(hex_box, 'TextColor3', 'Text')

    local preview = create('Frame', {
        Size = UDim2.fromOffset(84, 40),
        Position = UDim2.fromOffset(140, 44),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 7
    }, panel)
    corner(preview, 6)

    local presets = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 170, 80),
        Color3.fromRGB(255, 230, 90), Color3.fromRGB(110, 220, 140), Color3.fromRGB(80, 200, 230),
        Color3.fromRGB(110, 140, 255), Color3.fromRGB(180, 120, 255), Color3.fromRGB(255, 120, 200),
        Color3.fromRGB(150, 150, 165), Color3.fromRGB(90, 90, 105), Color3.fromRGB(30, 30, 40)
    }
    local preset_row = create('Frame', {
        Size = UDim2.new(0, 84, 0, 24),
        Position = UDim2.fromOffset(140, 92),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, panel)
    create('UIGridLayout', {
        CellSize = UDim2.fromOffset(12, 11),
        CellPadding = UDim2.fromOffset(2, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, preset_row)

    local function parse_hex(text)
        text = tostring(text):gsub('#', '')
        if #text ~= 6 then return nil end
        local r = tonumber(text:sub(1, 2), 16)
        local g = tonumber(text:sub(3, 4), 16)
        local b = tonumber(text:sub(5, 6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
        return nil
    end

    local hue, sat, val = 0.6, 0.7, 1

    local function paint(color, save, fire, defer)
        local h, s, v = color:ToHSV()
        hue, sat, val = h, s, v
        sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        sv_marker.Position = UDim2.fromScale(sat, 1 - val)
        hue_marker.Position = UDim2.new(hue, 0, 0.5, 0)
        swatch.BackgroundColor3 = color
        preview.BackgroundColor3 = color
        hex_box.Text = hex(color)
        swatch_hex.Text = hex(color)

        local luminance = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
        swatch_hex.TextColor3 = luminance > 0.6 and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(255, 255, 255)

        if settings.flag then
            self._library._config._flags[settings.flag] = hex(color)
            if save then self._library:autosave() end
        end
        if fire ~= false and settings.callback then
            if defer then
                local callback = settings.callback
                self._library:defer(function() callback(color) end)
            else
                settings.callback(color)
            end
        end
    end

    function manager:set_color(color)
        paint(color, true, true)
    end

    function manager:get_color()
        return Color3.fromHSV(hue, sat, val)
    end

    local function update_sv(mouse_x, mouse_y)
        local position = sv.AbsolutePosition
        local size = sv.AbsoluteSize
        sat = math.clamp((mouse_x - position.X) / math.max(1, size.X), 0, 1)
        val = 1 - math.clamp((mouse_y - position.Y) / math.max(1, size.Y), 0, 1)
        paint(Color3.fromHSV(hue, sat, val), false)
    end

    local function update_hue(mouse_x)
        local position = hue_bar.AbsolutePosition
        local size = math.max(1, hue_bar.AbsoluteSize.X)
        hue = math.clamp((mouse_x - position.X) / size, 0, 1)
        paint(Color3.fromHSV(hue, sat, val), false)
    end

    sv_hit.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        -- Use the input's own position: it shares AbsolutePosition's coordinate
        -- space. UserInputService:GetMouseLocation() is offset from the GUI by
        -- the top-bar inset, which dragged the value straight to black.
        update_sv(input.Position.X, input.Position.Y)
        Connections['picker_sv'] = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                update_sv(move.Position.X, move.Position.Y)
            end
        end)
        Connections['picker_sv_end'] = UserInputService.InputEnded:Connect(function()
            Connections:disconnect('picker_sv')
            Connections:disconnect('picker_sv_end')
            paint(Color3.fromHSV(hue, sat, val), true)
            self._library:status((settings.title or 'Colour') .. ' · ' .. hex(Color3.fromHSV(hue, sat, val)), 'info')
        end)
    end)

    hue_hit.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        update_hue(input.Position.X)
        Connections['picker_hue'] = UserInputService.InputChanged:Connect(function(move)
            if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
                update_hue(move.Position.X)
            end
        end)
        Connections['picker_hue_end'] = UserInputService.InputEnded:Connect(function()
            Connections:disconnect('picker_hue')
            Connections:disconnect('picker_hue_end')
            paint(Color3.fromHSV(hue, sat, val), true)
            self._library:status((settings.title or 'Colour') .. ' · ' .. hex(Color3.fromHSV(hue, sat, val)), 'info')
        end)
    end)

    hex_box.FocusLost:Connect(function()
        local color = parse_hex(hex_box.Text)
        if color then
            paint(color, true)
        else
            hex_box.Text = hex(Color3.fromHSV(hue, sat, val))
        end
    end)

    for _, preset_color in ipairs(presets) do
        local button = create('TextButton', {
            Size = UDim2.fromOffset(10, 20),
            BackgroundColor3 = preset_color,
            BorderSizePixel = 0,
            Text = '',
            AutoButtonColor = false,
            ZIndex = 8
        }, preset_row)
        corner(button, 3)
        button.MouseButton1Click:Connect(function()
            paint(preset_color, true)
        end)
    end

    -- Hide/show the expanded panel. The frame snaps to its collapsed height
    -- (and clips) the instant the picker closes, so hiding the panel there is
    -- visually free and guarantees the invisible drag zones stop eating input.
    local function set_panel_open(open)
        panel.Visible = open
        sv_hit.Visible = open
        hue_hit.Visible = open
    end

    function manager:unfold_settings()
        self._state = not self._state
        set_panel_open(self._state)
        if self._state then
            frame.Size = UDim2.new(0, BODY_W, 0, height_closed + picker_height)
        else
            frame.Size = UDim2.new(0, BODY_W, 0, height_closed)
        end
        self._module:refresh()
    end

    -- Allow callers (and tests) to open/close deterministically.
    function manager:set_open(state)
        state = state and true or false
        if state ~= self._state then
            self:unfold_settings()
        end
    end

    swatch.MouseButton1Click:Connect(function()
        manager:unfold_settings()
    end)

    local initial = Theme.Accent
    if settings.flag then
        local stored = self._library._config._flags[settings.flag]
        if type(stored) == 'string' then
            local parsed = parse_hex(stored)
            if parsed then initial = parsed end
        end
    elseif settings.color then
        initial = settings.color
    end
    -- Fire the callback so a restored colour is re-applied by the script;
    -- `save = false` keeps construction from writing the file, and
    -- `defer = true` queues the callback until the window is revealed.
    paint(initial, false, true, true)

    -- Let `library:load_config` push a saved profile back into the swatch.
    -- A saved colour is a hex string; a live caller may hand us a Color3.
    if settings.flag then
        self._library:register(settings.flag, function(value)
            local color
            if typeof(value) == 'Color3' then
                color = value
            elseif type(value) == 'string' then
                color = parse_hex(value)
            end
            -- Restoring must not re-save while a profile is being applied,
            -- but the callback fires so a feature can re-apply the colour.
            if color then paint(color, false, true) end
        end, hex(initial), { kind = 'color', widget = manager })
    end

    manager._frame = frame
    manager._panel = panel
    manager._sv = sv
    manager._sv_hit = sv_hit
    manager._hue_bar = hue_bar
    manager._hue_hit = hue_hit
    manager._swatch = swatch

    self:refresh()
    return manager
end

--=====================================================================
--  Aliases for convenience
--=====================================================================
ModuleManager.create_input = ModuleManager.create_textbox
ModuleManager.create_label = ModuleManager.create_text

--=====================================================================
--  Custom window background
--=====================================================================
-- settings = {
--     image = 100228876632788,      -- id, table of ids, or a Folder of ImageLabels/Decals/StringValues
--     transparency = 0.2,           -- 0 visible → 1 invisible
--     scale_type = Enum.ScaleType.Crop
-- }
function Library:set_background(settings)
    settings = settings or {}
    local Stellar = CoreGui:FindFirstChild('Stellar')
    local Container = Stellar and Stellar:FindFirstChild('Container')
    if not Container then
        warn('[Stellar] set_background called before load()')
        return nil
    end

    local background = Container:FindFirstChild('CustomBackground')
    if not background then
        background = create('ImageLabel', {
            Name = 'CustomBackground',
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScaleType = Enum.ScaleType.Crop,
            Image = '',
            ImageTransparency = 1,
            ZIndex = 0
        }, Container)
        corner(background, 16)
    end

    local source = settings.image
    local resolved

    if typeof(source) == 'Instance' and source:IsA('Folder') then
        local options = source:GetChildren()
        if #options > 0 then
            local pick = options[math.random(1, #options)]
            if pick:IsA('ImageLabel') then
                resolved = pick.Image
            elseif pick:IsA('Decal') then
                resolved = pick.Texture
            elseif pick:IsA('StringValue') then
                resolved = pick.Value
            end
        end
    elseif type(source) == 'table' then
        if #source > 0 then
            resolved = source[math.random(1, #source)]
        end
    elseif source ~= nil then
        resolved = source
    end

    resolved = Util:resolve_asset_id(resolved)
    if not resolved then
        background.Image = ''
        background.ImageTransparency = 1
        return background
    end

    background.Image = resolved
    background.ScaleType = settings.scale_type or Enum.ScaleType.Crop
    background.ImageTransparency = settings.transparency or 0
    return background
end

function Library:clear_background()
    local Stellar = CoreGui:FindFirstChild('Stellar')
    local Container = Stellar and Stellar:FindFirstChild('Container')
    local background = Container and Container:FindFirstChild('CustomBackground')
    if background then
        background.Image = ''
        background.ImageTransparency = 1
    end
end

--=====================================================================
--  Teardown
--=====================================================================
function Library:destroy()
    -- `self` is the library instance when called as `library:destroy()`. It is
    -- nil/Library when called statically (e.g. `Library.unload()` or
    -- `pcall(library.unload)`), which still tears the shared GUI down.
    local instance = (type(self) == 'table' and self ~= Library) and self or nil

    if instance then
        if instance._destroyed then return end
        instance._destroyed = true
    end

    Connections:disconnect_all()

    if instance then
        -- Closing the window is not enough: every feature the player left
        -- enabled must be told to stop. Firing each stateful widget's
        -- callback with `false` is what actually kills the script's logic
        -- (loops, connections, hooks it started when it was enabled).
        -- Autosave and the status footer are suppressed during this pass so
        -- the teardown neither rewrites the saved config nor floods the UI.
        instance._tearing_down = true
        for _, entry in ipairs(instance._registry or {}) do
            if type(entry.off) == 'function' then
                pcall(entry.off)
            end
        end
        instance._tearing_down = false
    end

    -- Tear down this instance's own window (not whichever ScreenGui happens
    -- to share the name, so multiple windows can coexist).
    if instance and instance._ui then
        pcall(function() instance._ui:Destroy() end)
    end

    local stellar = CoreGui:FindFirstChild('Stellar')
    if stellar then pcall(function() stellar:Destroy() end) end
    local loader = CoreGui:FindFirstChild('StellarLoader')
    if loader then loader:Destroy() end
    local notifications = CoreGui:FindFirstChild('StellarNotifications')
    if notifications then notifications:Destroy() end
    local tooltip = CoreGui:FindFirstChild('StellarTooltip')
    if tooltip then tooltip:Destroy() end

    if instance then
        instance._ui = nil
        instance._refs = {}
        instance._tabs = {}
        instance._search_items = {}
        instance._active_tab = nil
        instance._search_text = ''
        instance._open_dropdown = nil
        instance._status_token = (instance._status_token or 0) + 1
        instance._ui_open = false
        instance._deferred = {}
        instance._loader = nil
    end
end

-- The original Stellar API exposed `Library.unload`. Keep it as an alias so
-- existing scripts that call `library:unload()` / `pcall(library.unload)`
-- keep working against the redesign.
Library.unload = Library.destroy

return Library
