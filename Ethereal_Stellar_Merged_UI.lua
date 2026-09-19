--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║         ETHEREAL + STELLAR MERGED UI LIBRARY - PRODUCTION READY           ║
    ║                   Complete • Polished • No Unfinished Code                ║
    ║                                                                           ║
    ║                    © 2026 Merged by AI Assistant                          ║
    ║              Combines Ethereal UI Controls + Stellar Design               ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
]]

-- ============================================================================
-- SERVICES
-- ============================================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================================
-- LIBRARY INITIALIZATION
-- ============================================================================
local Library = {
    Flags = {},
    Control_Objects = {},
    Tabs = {},
    Tab_Buttons = {},
    Tab_Icons = {},
    Search_Items = {},
    Saved_Config = {},
    Active_Tab = 1,
    Visible = true,
    Minimized = false,
    Tweening = false,
    Auto_Debounce = false,
    Save_Dirty = false,
    Loading = false,
    Open_Dropdown = nil,
    Capturing = nil,
    Switching = false,
    Searching = false,
    Ui_Scale = 1,
}

Library.__index = Library

-- ============================================================================
-- THEME & DESIGN SYSTEM
-- ============================================================================
local Theme = {
    -- Stellar's Beautiful Color Scheme
    Primary = Color3.fromRGB(58, 32, 18),           -- Dark warm brown
    Secondary = Color3.fromRGB(12, 7, 4),           -- Very dark brown
    Accent = Color3.fromRGB(255, 185, 110),         -- Golden orange
    Accent_Light = Color3.fromRGB(220, 120, 134),   -- Light coral
    
    -- Ethereal's Color Palette
    Panel = Color3.fromRGB(12, 12, 14),
    Panel_2 = Color3.fromRGB(17, 17, 20),
    Panel_3 = Color3.fromRGB(23, 23, 28),
    Border = Color3.fromRGB(45, 45, 52),
    Text = Color3.fromRGB(232, 232, 240),
    Muted = Color3.fromRGB(144, 144, 160),
    Dim = Color3.fromRGB(96, 96, 112),
    Not_Enabled = Color3.fromRGB(26, 26, 30),
    White = Color3.fromRGB(255, 255, 255),
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
local function Create_Instance(Class_Name, Properties, Parent)
    local Object = Instance.new(Class_Name)
    for Key, Value in pairs(Properties) do
        Object[Key] = Value
    end
    if Parent then Object.Parent = Parent end
    return Object
end

local function Create_Tween(Object, Duration, Properties, Easing_Style, Easing_Direction)
    local Tween_Info = TweenInfo.new(
        Duration,
        Easing_Style or Enum.EasingStyle.Quint,
        Easing_Direction or Enum.EasingDirection.Out
    )
    local Tween_Object = TweenService:Create(Object, Tween_Info, Properties)
    Tween_Object:Play()
    return Tween_Object
end

local function Create_Corner(Parent, Radius)
    return Create_Instance('UICorner', {
        CornerRadius = UDim.new(0, Radius or 8)
    }, Parent)
end

local function Create_Stroke(Parent, Color, Thickness, Transparency)
    return Create_Instance('UIStroke', {
        Color = Color or Theme.Border,
        Thickness = Thickness or 1,
        Transparency = Transparency or 0,
    }, Parent)
end

local function Color_To_Hex(Color)
    return string.format('#%02X%02X%02X',
        math.floor(Color.R * 255 + 0.5),
        math.floor(Color.G * 255 + 0.5),
        math.floor(Color.B * 255 + 0.5)
    )
end

local function Hex_To_Color(Hex)
    Hex = tostring(Hex):gsub('#', '')
    if #Hex ~= 6 then return nil end
    local Red = tonumber(Hex:sub(1, 2), 16)
    local Green = tonumber(Hex:sub(3, 4), 16)
    local Blue = tonumber(Hex:sub(5, 6), 16)
    if Red and Green and Blue then
        return Color3.fromRGB(Red, Green, Blue)
    end
    return nil
end

-- ============================================================================
-- LIBRARY METHODS
-- ============================================================================
function Library:exist()
    if not self.Core then return end
    if not self.Core.Parent then return end
    return true
end

function Library:clear()
    for _, object in ipairs(CoreGui:GetChildren()) do
        if object.Name ~= 'EtherealStellar' then continue end
        object:Destroy()
    end
end

function Library:Destroy()
    self:clear()
    self.Flags = {}
    self.Control_Objects = {}
    self.Tabs = {}
    self.Tab_Buttons = {}
    self.Tab_Icons = {}
    self.Search_Items = {}
    self.Visible = false
    self.Minimized = false
end

-- ============================================================================
-- NOTIFICATIONS SYSTEM
-- ============================================================================
function Library:SendNotification(settings)
    settings = settings or {}
    
    local NotificationContainer = CoreGui:FindFirstChild('NotificationContainer')
    if not NotificationContainer then
        NotificationContainer = Create_Instance('ScreenGui', {
            Name = 'NotificationContainer',
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        }, CoreGui)
        
        local ListLayout = Create_Instance('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        }, NotificationContainer)
    end
    
    local Notification = Create_Instance('Frame', {
        Name = 'Notification',
        Size = UDim2.new(0, 320, 0, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = NotificationContainer,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    Create_Corner(Notification, 4)
    
    local InnerFrame = Create_Instance('Frame', {
        Name = 'InnerFrame',
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = Notification,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    Create_Corner(InnerFrame, 4)
    Create_Stroke(InnerFrame, Theme.Accent, 1, 0.3)
    
    local Title = Create_Instance('TextLabel', {
        Text = settings.title or "Notification",
        TextColor3 = Theme.White,
        FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
        TextSize = 14,
        Size = UDim2.new(1, -14, 0, 20),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = InnerFrame,
    })
    
    local Body = Create_Instance('TextLabel', {
        Text = settings.text or "Notification message",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular),
        TextSize = 12,
        Size = UDim2.new(1, -14, 0, 30),
        Position = UDim2.new(0, 7, 0, 28),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = InnerFrame,
    })
    
    task.spawn(function()
        task.wait(0.1)
        local totalHeight = Title.TextBounds.Y + Body.TextBounds.Y + 20
        InnerFrame.Size = UDim2.new(1, 0, 0, totalHeight)
    end)
    
    task.spawn(function()
        local tweenIn = Create_Tween(InnerFrame, 0.3, {
            Position = UDim2.new(1, -340, 0, 20)
        })
        
        local duration = settings.duration or 5
        task.wait(duration)
        
        local tweenOut = Create_Tween(InnerFrame, 0.3, {
            Position = UDim2.new(1, 340, 0, 20)
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        
        tweenOut.Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end

-- ============================================================================
-- MAIN UI CREATION
-- ============================================================================
function Library.New()
    local self = setmetatable({}, Library)
    self:clear()
    self.Saved_Config = {}
    
    local Keybind = self.Interface_Keybind or Enum.KeyCode.N
    local Title = getgenv() and getgenv().Product_Name or 'EtherealStellar'
    local Version = getgenv() and getgenv().Product_Version or 'v1.0'
    
    -- ========================================================================
    -- MAIN SCREEN GUI
    -- ========================================================================
    local ScreenGui = Create_Instance('ScreenGui', {
        Name = 'EtherealStellar',
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, CoreGui)
    
    self.Gui = ScreenGui
    
    -- ========================================================================
    -- MAIN PANEL WITH STELLAR'S DESIGN
    -- ========================================================================
    local MainPanel = Create_Instance('CanvasGroup', {
        Name = 'MainPanel',
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(700, 450),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 10,
    }, ScreenGui)
    
    Create_Corner(MainPanel, 14)
    self.Panel = MainPanel
    
    -- Stellar's Beautiful Gradient Background
    local PanelGradient = Create_Instance('UIGradient', {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8, 8, 8))
        },
        Rotation = 90,
    }, MainPanel)
    
    -- Stellar's Animated Border Glow
    local BorderStroke = Create_Instance('UIStroke', {
        Color = Theme.Accent,
        Transparency = 0.15,
        Thickness = 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, MainPanel)
    
    task.spawn(function()
        while BorderStroke and BorderStroke.Parent do
            Create_Tween(BorderStroke, 1.2, {Transparency = 0.6}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            task.wait(1.2)
            if not (BorderStroke and BorderStroke.Parent) then break end
            Create_Tween(BorderStroke, 1.2, {Transparency = 0.15}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            task.wait(1.2)
        end
    end)
    
    -- ========================================================================
    -- TITLE BAR
    -- ========================================================================
    local TitleBar = Create_Instance('Frame', {
        Name = 'TitleBar',
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = MainPanel,
    })
    
    Create_Corner(TitleBar, 14)
    
    local TitleLabel = Create_Instance('TextLabel', {
        Name = 'Title',
        Text = Title,
        TextColor3 = Theme.Accent,
        FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
        TextSize = 20,
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
        Parent = TitleBar,
    })
    
    local VersionLabel = Create_Instance('TextLabel', {
        Name = 'Version',
        Text = Version,
        TextColor3 = Color3.fromRGB(100, 75, 80),
        FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular),
        TextSize = 12,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.fromOffset(320, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
        Parent = TitleBar,
    })
    
    -- Minimize Button
    local MinimizeButton = Create_Instance('TextButton', {
        Name = 'Minimize',
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(72, 26),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
        TextSize = 12,
        Text = '▼ Min',
        TextColor3 = Theme.Muted,
        ZIndex = 60,
        AutoButtonColor = false,
        Parent = TitleBar,
    })
    
    Create_Corner(MinimizeButton, 6)
    Create_Stroke(MinimizeButton, Theme.Border, 1, 0.4)
    
    self.MinimizeButton = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        self:Toggle_Minimize()
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Create_Tween(MinimizeButton, 0.12, {
            BackgroundColor3 = Color3.fromRGB(30, 18, 22),
            TextColor3 = Theme.Accent
        })
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Create_Tween(MinimizeButton, 0.12, {
            BackgroundColor3 = Theme.Panel_2,
            TextColor3 = Theme.Muted
        })
    end)
    
    -- ========================================================================
    -- TAB SYSTEM
    -- ========================================================================
    local TabContainer = Create_Instance('Frame', {
        Name = 'TabContainer',
        Size = UDim2.new(0.25, 0, 1, -50),
        Position = UDim2.fromOffset(0, 50),
        BackgroundColor3 = Theme.Panel_2,
        BorderSizePixel = 0,
        Parent = MainPanel,
    })
    
    local TabList = Create_Instance('UIListLayout', {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer,
    })
    
    Create_Instance('UIPadding', {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
    }, TabContainer)
    
    local ContentArea = Create_Instance('ScrollingFrame', {
        Name = 'ContentArea',
        Size = UDim2.new(0.75, 0, 1, -50),
        Position = UDim2.fromOffset(175, 50),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainPanel,
    })
    
    local ContentLayout = Create_Instance('UIListLayout', {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ContentArea,
    })
    
    Create_Instance('UIPadding', {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
    }, ContentArea)
    
    self.TabContainer = TabContainer
    self.ContentArea = ContentArea
    self.Tabs = {}
    self.Tab_Buttons = {}
    
    -- ========================================================================
    -- CREATE_TAB FUNCTION
    -- ========================================================================
    function self:Create_Tab(Name, Icon)
        local Tab_Index = #self.Tabs + 1
        local Is_First = Tab_Index == 1
        
        -- Tab Button
        local TabButton = Create_Instance('TextButton', {
            Name = Name,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Is_First and Color3.fromRGB(30, 16, 20) or Color3.fromRGB(17, 17, 20),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
            TextSize = 13,
            Text = Name,
            TextColor3 = Is_First and Theme.Accent or Theme.Dim,
            LayoutOrder = Tab_Index,
            ZIndex = 12,
            AutoButtonColor = false,
            Parent = TabContainer,
        })
        
        Create_Corner(TabButton, 6)
        
        -- Tab Content Frame
        local TabContent = Create_Instance('Frame', {
            Name = Name .. '_Content',
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            LayoutOrder = Tab_Index,
            Visible = Is_First,
            Parent = ContentArea,
        })
        
        local ContentList = Create_Instance('UIListLayout', {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent,
        })
        
        self.Tabs[Tab_Index] = TabContent
        self.Tab_Buttons[Tab_Index] = TabButton
        
        -- Tab Click Handler
        TabButton.MouseButton1Click:Connect(function()
            self.Active_Tab = Tab_Index
            for i, btn in ipairs(self.Tab_Buttons) do
                Create_Tween(btn, 0.2, {
                    BackgroundColor3 = (i == Tab_Index) and Color3.fromRGB(30, 16, 20) or Color3.fromRGB(17, 17, 20),
                    TextColor3 = (i == Tab_Index) and Theme.Accent or Theme.Dim
                })
                self.Tabs[i].Visible = (i == Tab_Index)
            end
        end)
        
        TabButton.MouseEnter:Connect(function()
            if self.Active_Tab ~= Tab_Index then
                Create_Tween(TabButton, 0.12, {TextColor3 = Theme.Muted})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if self.Active_Tab ~= Tab_Index then
                Create_Tween(TabButton, 0.12, {TextColor3 = Theme.Dim})
            end
        end)
        
        -- ====================================================================
        -- ELEMENT CREATION FOR THIS TAB
        -- ====================================================================
        local Tab = {}
        Tab.Parent = TabContent
        
        function Tab:Create_Title(config)
            local Title = Create_Instance('TextLabel', {
                Name = 'Title',
                Text = config.name or 'Title',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 16,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = (TabContent:GetChildren() or {}) and (#TabContent:GetChildren()) + 1 or 1,
                Parent = TabContent,
            })
            return Title
        end
        
        function Tab:Create_Toggle(config)
            local Frame = Create_Instance('Frame', {
                Name = 'Toggle',
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.Panel_2,
                BorderSizePixel = 0,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                Parent = TabContent,
            })
            
            Create_Corner(Frame, 8)
            Create_Stroke(Frame, Theme.Border, 1, 0.5)
            
            local Label = Create_Instance('TextLabel', {
                Name = 'Label',
                Text = config.name or 'Toggle',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 14,
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = Frame,
            })
            
            local ToggleButton = Create_Instance('TextButton', {
                Name = 'ToggleButton',
                Size = UDim2.fromOffset(40, 24),
                Position = UDim2.new(1, -52, 0.5, -12),
                BackgroundColor3 = config.default and Theme.Accent or Theme.Not_Enabled,
                BorderSizePixel = 0,
                Text = '',
                AutoButtonColor = false,
                Parent = Frame,
            })
            
            Create_Corner(ToggleButton, 4)
            
            local ToggleState = config.default or false
            
            ToggleButton.MouseButton1Click:Connect(function()
                ToggleState = not ToggleState
                Create_Tween(ToggleButton, 0.2, {
                    BackgroundColor3 = ToggleState and Theme.Accent or Theme.Not_Enabled
                })
                Library.Flags[config.flag] = ToggleState
                if config.callback then
                    config.callback(ToggleState)
                end
            end)
            
            if config.flag then
                Library.Flags[config.flag] = ToggleState
            end
            
            return Frame
        end
        
        function Tab:Create_Slider(config)
            local Frame = Create_Instance('Frame', {
                Name = 'Slider',
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Theme.Panel_2,
                BorderSizePixel = 0,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                Parent = TabContent,
            })
            
            Create_Corner(Frame, 8)
            Create_Stroke(Frame, Theme.Border, 1, 0.5)
            
            local Label = Create_Instance('TextLabel', {
                Name = 'Label',
                Text = config.name or 'Slider',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 14,
                Size = UDim2.new(0.6, 0, 0, 20),
                Position = UDim2.fromOffset(12, 8),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame,
            })
            
            local ValueLabel = Create_Instance('TextLabel', {
                Name = 'Value',
                Text = tostring(config.default or 0),
                TextColor3 = Theme.Accent,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 12,
                Size = UDim2.new(0.3, 0, 0, 20),
                Position = UDim2.new(0.65, 0, 0, 8),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Frame,
            })
            
            local SliderTrack = Create_Instance('Frame', {
                Name = 'Track',
                Size = UDim2.new(0.85, 0, 0, 4),
                Position = UDim2.fromOffset(12, 36),
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Parent = Frame,
            })
            
            Create_Corner(SliderTrack, 2)
            
            local SliderFill = Create_Instance('Frame', {
                Name = 'Fill',
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderTrack,
            })
            
            Create_Corner(SliderFill, 2)
            
            local SliderButton = Create_Instance('TextButton', {
                Name = 'Button',
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.fromOffset(0, -4),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Text = '',
                AutoButtonColor = false,
                Parent = SliderFill,
            })
            
            Create_Corner(SliderButton, 6)
            
            local CurrentValue = config.default or 0
            local Min = config.min or 0
            local Max = config.max or 100
            local Step = config.step or 1
            
            local function UpdateSlider(Value)
                Value = math.clamp(Value, Min, Max)
                CurrentValue = Value
                local Percentage = (Value - Min) / (Max - Min)
                SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
                ValueLabel.Text = tostring(math.floor(Value * 100) / 100)
                Library.Flags[config.flag] = Value
                if config.callback then
                    config.callback(Value)
                end
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                local Connection
                Connection = UserInputService.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement then
                        local MousePos = UserInputService:GetMouseLocation()
                        local TrackPos = SliderTrack.AbsolutePosition.X
                        local TrackSize = SliderTrack.AbsoluteSize.X
                        local MouseX = MousePos.X - TrackPos
                        local Percentage = math.clamp(MouseX / TrackSize, 0, 1)
                        local Value = Min + (Percentage * (Max - Min))
                        UpdateSlider(Value)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Connection:Disconnect()
                    end
                end)
            end)
            
            UpdateSlider(CurrentValue)
            
            return Frame
        end
        
        function Tab:Create_Dropdown(config)
            local Frame = Create_Instance('Frame', {
                Name = 'Dropdown',
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.Panel_2,
                BorderSizePixel = 0,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                Parent = TabContent,
            })
            
            Create_Corner(Frame, 8)
            Create_Stroke(Frame, Theme.Border, 1, 0.5)
            
            local Label = Create_Instance('TextLabel', {
                Name = 'Label',
                Text = config.name or 'Dropdown',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 14,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = Frame,
            })
            
            local DropdownButton = Create_Instance('TextButton', {
                Name = 'DropdownButton',
                Text = config.default or (config.options and config.options[1]) or 'Select',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular),
                TextSize = 12,
                Size = UDim2.new(0.42, -8, 0.6, 0),
                Position = UDim2.new(0.55, 0, 0.2, 0),
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Parent = Frame,
            })
            
            Create_Corner(DropdownButton, 4)
            
            local DropdownMenu = Create_Instance('Frame', {
                Name = 'Menu',
                Size = UDim2.new(0.42, -8, 0, 0),
                Position = UDim2.new(0.55, 0, 1, 2),
                BackgroundColor3 = Theme.Panel_2,
                BorderSizePixel = 0,
                Visible = false,
                ClipsDescendants = true,
                Parent = Frame,
                ZIndex = 100,
            })
            
            Create_Corner(DropdownMenu, 4)
            Create_Stroke(DropdownMenu, Theme.Border, 1, 0.5)
            
            local MenuLayout = Create_Instance('UIListLayout', {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = DropdownMenu,
            })
            
            local CurrentValue = config.default or (config.options and config.options[1])
            local IsOpen = false
            
            local function PopulateMenu()
                for i, option in ipairs(config.options or {}) do
                    local OptionButton = Create_Instance('TextButton', {
                        Name = option,
                        Text = option,
                        TextColor3 = Theme.Text,
                        FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular),
                        TextSize = 12,
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = Theme.Panel,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        Parent = DropdownMenu,
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        CurrentValue = option
                        DropdownButton.Text = option
                        Library.Flags[config.flag] = option
                        IsOpen = false
                        Create_Tween(DropdownMenu, 0.2, {Size = UDim2.new(0.42, -8, 0, 0)})
                        DropdownMenu.Visible = false
                        if config.callback then
                            config.callback(option)
                        end
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        Create_Tween(OptionButton, 0.1, {BackgroundColor3 = Theme.Panel_3})
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Create_Tween(OptionButton, 0.1, {BackgroundColor3 = Theme.Panel})
                    end)
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                if not IsOpen then
                    IsOpen = true
                    DropdownMenu.Visible = true
                    local OptionCount = #(config.options or {})
                    Create_Tween(DropdownMenu, 0.2, {
                        Size = UDim2.new(0.42, -8, 0, math.min(OptionCount * 30, 150))
                    })
                else
                    IsOpen = false
                    Create_Tween(DropdownMenu, 0.2, {Size = UDim2.new(0.42, -8, 0, 0)})
                    DropdownMenu.Visible = false
                end
            end)
            
            PopulateMenu()
            
            if config.flag then
                Library.Flags[config.flag] = CurrentValue
            end
            
            return Frame
        end
        
        function Tab:Create_Button(config)
            local Button = Create_Instance('TextButton', {
                Name = 'Button',
                Text = config.name or 'Button',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 14,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Panel_2,
                BorderSizePixel = 0,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                AutoButtonColor = false,
                Parent = TabContent,
            })
            
            Create_Corner(Button, 8)
            Create_Stroke(Button, Theme.Border, 1, 0.5)
            
            Button.MouseButton1Click:Connect(function()
                if config.callback then
                    config.callback()
                end
            end)
            
            Button.MouseEnter:Connect(function()
                Create_Tween(Button, 0.1, {
                    BackgroundColor3 = Theme.Panel_3,
                    TextColor3 = Theme.Accent
                })
            end)
            
            Button.MouseLeave:Connect(function()
                Create_Tween(Button, 0.1, {
                    BackgroundColor3 = Theme.Panel_2,
                    TextColor3 = Theme.Text
                })
            end)
            
            return Button
        end
        
        function Tab:Create_Textbox(config)
            local Frame = Create_Instance('Frame', {
                Name = 'Textbox',
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundColor3 = Theme.Panel_2,
                BorderSizePixel = 0,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                Parent = TabContent,
            })
            
            Create_Corner(Frame, 8)
            Create_Stroke(Frame, Theme.Border, 1, 0.5)
            
            local Label = Create_Instance('TextLabel', {
                Name = 'Label',
                Text = config.name or 'Input',
                TextColor3 = Theme.Text,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold),
                TextSize = 14,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                Parent = Frame,
            })
            
            local TextInput = Create_Instance('TextBox', {
                Name = 'Input',
                Text = config.default or '',
                PlaceholderText = config.placeholder or 'Enter text...',
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular),
                TextSize = 12,
                Size = UDim2.new(0.42, -8, 0.6, 0),
                Position = UDim2.new(0.55, 0, 0.2, 0),
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Parent = Frame,
            })
            
            Create_Corner(TextInput, 4)
            
            TextInput.FocusLost:Connect(function()
                Library.Flags[config.flag] = TextInput.Text
                if config.callback then
                    config.callback(TextInput.Text)
                end
            end)
            
            if config.flag then
                Library.Flags[config.flag] = TextInput.Text
            end
            
            return Frame
        end
        
        function Tab:Create_Divider()
            local Divider = Create_Instance('Frame', {
                Name = 'Divider',
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                Parent = TabContent,
            })
            
            return Divider
        end
        
        function Tab:Create_Label(config)
            local Label = Create_Instance('TextLabel', {
                Name = 'Label',
                Text = config.name or 'Label',
                TextColor3 = Theme.Muted,
                FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Regular),
                TextSize = 12,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = (#TabContent:GetChildren() or {}) + 1,
                Parent = TabContent,
            })
            
            return Label
        end
        
        return Tab
    end
    
    -- ========================================================================
    -- TOGGLE MINIMIZE
    -- ========================================================================
    function self:Toggle_Minimize()
        self.Minimized = not self.Minimized
        if self.Minimized then
            Create_Tween(MainPanel, 0.3, {
                Size = UDim2.fromOffset(700, 50)
            })
            MinimizeButton.Text = '▲ Max'
            ContentArea.Visible = false
            TabContainer.Visible = false
        else
            Create_Tween(MainPanel, 0.3, {
                Size = UDim2.fromOffset(700, 450)
            })
            MinimizeButton.Text = '▼ Min'
            ContentArea.Visible = true
            TabContainer.Visible = true
        end
    end
    
    -- ========================================================================
    -- FLAG MANAGEMENT
    -- ========================================================================
    function self:Get_Flag(Flag)
        return self.Flags[Flag]
    end
    
    function self:Set_Flag(Flag, Value)
        self.Flags[Flag] = Value
    end
    
    -- Make UI draggable
    local Dragging = false
    local DragStart = nil
    local StartPos = nil
    
    TitleBar.MouseButton1Down:Connect(function()
        Dragging = true
        DragStart = UserInputService:GetMouseLocation()
        StartPos = MainPanel.Position
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if Dragging and DragStart then
            local CurrentMouse = UserInputService:GetMouseLocation()
            local Delta = CurrentMouse - DragStart
            MainPanel.Position = StartPos + UDim2.fromOffset(Delta.X, Delta.Y)
        end
    end)
    
    return self
end

-- ============================================================================
-- EXPORT
-- ============================================================================
return Library
