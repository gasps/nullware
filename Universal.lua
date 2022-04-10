local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")

local LocalPlayer = PlayerService.LocalPlayer
local Aimbot, SilentAim = false, nil

nullware.Config = nullware.Utilities.Config:ReadJSON(nullware.Current, {
    PlayerESP = {
        AllyColor = {0.3333333432674408,1,1,0,false},
        EnemyColor = {1,1,1,0,false},

        TeamColor = false,
        TeamCheck = false,
        Highlight = {
            Enabled = false,
            Transparency = 0.5,
            OutlineColor = {0,0,0,0.5,false}
        },
        Box = {
            Enabled = false,
            Outline = true,
            Filled = false,
            Thickness = 1,
            Transparency = 1,
            Info = {
                Enabled = false,
                AutoScale = true,
                Transparency = 1,
                Size = 16
            }
        },
        Other = {
            Head = {
                Enabled = false,
                AutoScale = true,
                Filled = true,
                Radius = 8,
                NumSides = 4,
                Thickness = 1,
                Transparency = 1
            },
            Tracer = {
                Enabled = false,
                Thickness = 1,
                Transparency = 1,
                From = "ScreenBottom"
            },
            Arrow = {
                Enabled = false,
                Filled = true,
                Width = 16,
                Height = 16,
                Thickness = 1,
                Transparency = 1,
                DistanceFromCenter = 80
            }
        }
    },
    AimAssist = {
        TeamCheck = false,
        SilentAim = {
            Enabled = false,
            WallCheck = false,
            HitChance = 100,
            FieldOfView = 50,
            Priority = {"Head"},
            Circle = {
                Visible = true,
                Transparency = 0.5,
                Color = {0.6666666865348816,1,1,0.5,false},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        },
        Aimbot = {
            Enabled = false,
            WallCheck = false,
            Sensitivity = 0.25,
            FieldOfView = 100,
            Priority = {"Head","HumanoidRootPart"},
            Prediction = {
                Enabled = false,
                Velocity = 1,
            },
            Circle = {
                Visible = true,
                Transparency = 0.5,
                Color = {1,1,1,0.5,false},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        }
    },
    UI = {
        Enabled = true,
        Keybind = "RightShift",
        Color = {0.8333333134651184,0.5,0.5,0,false},
        TileSize = 74,
        Watermark = true,
        Background = "Floral",
        BackgroundId = "rbxassetid://5553946656",
        BackgroundColor = {1,0,0,0,false},
        BackgroundTransparency = 0,
        Cursor = {
            Enabled = false,
            Length = 16,
            Width = 11,

            Crosshair = {
                Enabled = false,
                Color = {1,1,1,0,false},
                Size = 4,
                Gap = 2,
            }
        }
    },
    Binds = {
        Aimbot = "MouseButton2",
        SilentAim = "NONE"
    }
})

nullware.Utilities.Drawing:Cursor(nullware.Config.UI.Cursor)
nullware.Utilities.Drawing:FoVCircle(nullware.Config.AimAssist.Aimbot)
nullware.Utilities.Drawing:FoVCircle(nullware.Config.AimAssist.SilentAim)
local Window = nullware.Utilities.UI:Window({Name = "nullwareware — " .. nullware.Current,Enabled = nullware.Config.UI.Enabled,
Color = nullware.Utilities.Config:TableToColor(nullware.Config.UI.Color),Position = UDim2.new(0.2,-248,0.5,-248)}) do
    local AimAssistTab = Window:Tab({Name = "combat"}) do
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "enabled",Value = nullware.Config.AimAssist.Aimbot.Enabled,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.Enabled = Bool
            end})
            AimbotSection:Toggle({Name = "visibility check",Value = nullware.Config.AimAssist.Aimbot.WallCheck,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.WallCheck = Bool
            end})
            AimbotSection:Keybind({Name = "keybind",Key = nullware.Config.Binds.Aimbot,Mouse = true,Callback = function(Bool,Key)
                nullware.Config.Binds.Aimbot = Key or "NONE"
                Aimbot = nullware.Config.AimAssist.Aimbot.Enabled and Bool
            end})
            AimbotSection:Slider({Name = "smoothness",Min = 0,Max = 100,Value = nullware.Config.AimAssist.Aimbot.Sensitivity * 100,Unit = "%",Callback = function(Number)
                nullware.Config.AimAssist.Aimbot.Sensitivity = Number / 100
            end})
            AimbotSection:Slider({Name = "field of view",Min = 0,Max = 500,Value = nullware.Config.AimAssist.Aimbot.FieldOfView,Callback = function(Number)
                nullware.Config.AimAssist.Aimbot.FieldOfView = Number
            end})
            AimbotSection:Dropdown({Name = "priority",Default = nullware.Config.AimAssist.Aimbot.Priority,List = {
                {Name = "had",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "humanoidrootpart",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Aimbot.Priority = Selected
                end}
            }})
        end
        local AFoVSection = AimAssistTab:Section({Name = "aimbot fov circle",Side = "Left"}) do
            AFoVSection:Toggle({Name = "enabled",Value = nullware.Config.AimAssist.Aimbot.Circle.Visible,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.Circle.Visible = Bool
            end})
            AFoVSection:Toggle({Name = "filled",Value = nullware.Config.AimAssist.Aimbot.Circle.Filled,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.Circle.Filled = Bool
            end})
            AFoVSection:Colorpicker({Name = "color",HSVAR = nullware.Config.AimAssist.Aimbot.Circle.Color,Callback = function(HSVAR)
                nullware.Config.AimAssist.Aimbot.Circle.Color = HSVAR
            end})
            AFoVSection:Slider({Name = "numsides",Min = 3,Max = 100,Value = nullware.Config.AimAssist.Aimbot.Circle.NumSides,Callback = function(Number)
                nullware.Config.AimAssist.Aimbot.Circle.NumSides = Number
            end})
            AFoVSection:Slider({Name = "thickness",Min = 1,Max = 10,Value = nullware.Config.AimAssist.Aimbot.Circle.Thickness,Callback = function(Number)
                nullware.Config.AimAssist.Aimbot.Circle.Thickness = Number
            end})
        end
        local SilentAimSection = AimAssistTab:Section({Name = "silent aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "enabled",Value = nullware.Config.AimAssist.SilentAim.Enabled,Callback = function(Bool)
                nullware.Config.AimAssist.SilentAim.Enabled = Bool
            end}):Keybind({Key = nullware.Config.Binds.SilentAim,Mouse = true,Callback = function(Bool,Key)
                nullware.Config.Binds.SilentAim = Key or "NONE"
            end})
            SilentAimSection:Toggle({Name = "visibility Check",Value = nullware.Config.AimAssist.SilentAim.WallCheck,Callback = function(Bool)
                nullware.Config.AimAssist.SilentAim.WallCheck = Bool
            end})
            SilentAimSection:Slider({Name = "hit Chance",Min = 0,Max = 200,Value = nullware.Config.AimAssist.SilentAim.HitChance,Unit = "%",Callback = function(Number)
                nullware.Config.AimAssist.SilentAim.HitChance = Number
            end})
            SilentAimSection:Slider({Name = "field of view",Min = 0,Max = 1000,Value = nullware.Config.AimAssist.SilentAim.FieldOfView,Callback = function(Number)
                nullware.Config.AimAssist.SilentAim.FieldOfView = Number
            end})
            SilentAimSection:Dropdown({Name = "priority",Default = nullware.Config.AimAssist.SilentAim.Priority,List = {
                {Name = "head",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "humanoidrootpart",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end}
            }})
        end
        local SAFoVSection = AimAssistTab:Section({Name = "silent aim fov circle",Side = "Right"}) do
            SAFoVSection:Toggle({Name = "enabled",Value = nullware.Config.AimAssist.SilentAim.Circle.Visible,Callback = function(Bool)
                nullware.Config.AimAssist.SilentAim.Circle.Visible = Bool
            end})
            SAFoVSection:Toggle({Name = "filled",Value = nullware.Config.AimAssist.SilentAim.Circle.Filled,Callback = function(Bool)
                nullware.Config.AimAssist.SilentAim.Circle.Filled = Bool
            end})
            SAFoVSection:Colorpicker({Name = "color",HSVAR = nullware.Config.AimAssist.SilentAim.Circle.Color,Callback = function(HSVAR)
                nullware.Config.AimAssist.SilentAim.Circle.Color = HSVAR
            end})
            SAFoVSection:Slider({Name = "num sides",Min = 3,Max = 100,Value = nullware.Config.AimAssist.SilentAim.Circle.NumSides,Callback = function(Number)
                nullware.Config.AimAssist.SilentAim.Circle.NumSides = Number
            end})
            SAFoVSection:Slider({Name = "thickness",Min = 1,Max = 10,Value = nullware.Config.AimAssist.SilentAim.Circle.Thickness,Callback = function(Number)
                nullware.Config.AimAssist.SilentAim.Circle.Thickness = Number
            end})
        end
        local MiscSection = AimAssistTab:Section({Name = "Misc",Side = "Right"}) do
            MiscSection:Toggle({Name = "team check",Side = "Left",Value = nullware.Config.AimAssist.TeamCheck,Callback = function(Bool)
                nullware.Config.AimAssist.TeamCheck = Bool
            end}):ToolTip("affects aimbot and silent aim")
            MiscSection:Toggle({Name = "prediction",Value = nullware.Config.AimAssist.Aimbot.Prediction.Enabled,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.Prediction.Enabled = Bool
            end}):ToolTip("affects only aimbot")
            MiscSection:Slider({Name = "velocity",Min = 1,Max = 20,Value = nullware.Config.AimAssist.Aimbot.Prediction.Velocity,Callback = function(Number)
                nullware.Config.AimAssist.Aimbot.Prediction.Velocity = Number
            end}):ToolTip("prediction velocity")
        end
    end
    local VisualsTab = Window:Tab({Name = "visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "team color",HSVAR = nullware.Config.PlayerESP.AllyColor,Callback = function(HSVAR)
                nullware.Config.PlayerESP.AllyColor = HSVAR
            end})
            GlobalSection:Colorpicker({Name = "enemy color",HSVAR = nullware.Config.PlayerESP.EnemyColor,Callback = function(HSVAR)
                nullware.Config.PlayerESP.EnemyColor = HSVAR
            end})
            GlobalSection:Toggle({Name = "team Check",Value = nullware.Config.PlayerESP.TeamCheck,Callback = function(Bool)
                nullware.Config.PlayerESP.TeamCheck = Bool
            end})
            GlobalSection:Toggle({Name = "use Team Color",Value = nullware.Config.PlayerESP.TeamColor,Callback = function(Bool)
                nullware.Config.PlayerESP.TeamColor = Bool
            end})
        end
        local BoxSection = VisualsTab:Section({Name = "boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "enabled",Value = nullware.Config.PlayerESP.Box.Enabled,Callback = function(Bool)
                nullware.Config.PlayerESP.Box.Enabled = Bool
            end})
            BoxSection:Toggle({Name = "filled",Value = nullware.Config.PlayerESP.Box.Filled,Callback = function(Bool)
                nullware.Config.PlayerESP.Box.Filled = Bool
            end})
            BoxSection:Toggle({Name = "outline",Value = nullware.Config.PlayerESP.Box.Outline,Callback = function(Bool)
                nullware.Config.PlayerESP.Box.Outline = Bool
            end})
            BoxSection:Slider({Name = "thickness",Min = 1,Max = 10,Value = nullware.Config.PlayerESP.Box.Thickness,Callback = function(Number)
                nullware.Config.PlayerESP.Box.Thickness = Number
            end})
            BoxSection:Slider({Name = "transparency",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.PlayerESP.Box.Transparency,Callback = function(Number)
                nullware.Config.PlayerESP.Box.Transparency = Number
            end})
            BoxSection:Divider({Text = "text / info"})
            BoxSection:Toggle({Name = "enabled",Value = nullware.Config.PlayerESP.Box.Info.Enabled,Callback = function(Bool)
                nullware.Config.PlayerESP.Box.Info.Enabled = Bool
            end})
            BoxSection:Toggle({Name = "autoscale",Value = nullware.Config.PlayerESP.Box.Info.AutoScale,Callback = function(Bool)
                nullware.Config.PlayerESP.Box.Info.AutoScale = Bool
            end})
            BoxSection:Slider({Name = "size",Min = 14,Max = 28,Value = nullware.Config.PlayerESP.Box.Info.Size,Callback = function(Number)
                nullware.Config.PlayerESP.Box.Info.Size = Number
            end})
            BoxSection:Slider({Name = "transparency",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.PlayerESP.Box.Info.Transparency,Callback = function(Number)
                nullware.Config.PlayerESP.Box.Info.Transparency = Number
            end})
        end
        local OoVSection = VisualsTab:Section({Name = "offscreen arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "enabled",Value = nullware.Config.PlayerESP.Other.Arrow.Enabled,Callback = function(Bool)
                nullware.Config.PlayerESP.Other.Arrow.Enabled = Bool
            end})
            OoVSection:Toggle({Name = "filled",Value = nullware.Config.PlayerESP.Other.Arrow.Filled,Callback = function(Bool)
                nullware.Config.PlayerESP.Other.Arrow.Filled = Bool
            end})
            OoVSection:Slider({Name = "height",Min = 14,Max = 28,Value = nullware.Config.PlayerESP.Other.Arrow.Height,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Arrow.Height = Number
            end})
            OoVSection:Slider({Name = "width",Min = 14,Max = 28,Value = nullware.Config.PlayerESP.Other.Arrow.Width,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Arrow.Width = Number
            end})
            OoVSection:Slider({Name = "distance from center",Min = 80,Max = 200,Value = nullware.Config.PlayerESP.Other.Arrow.DistanceFromCenter,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Arrow.DistanceFromCenter = Number
            end})
            OoVSection:Slider({Name = "thickness",Min = 1,Max = 10,Value = nullware.Config.PlayerESP.Other.Arrow.Thickness,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Arrow.Thickness = Number
            end})
            OoVSection:Slider({Name = "transparency",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.PlayerESP.Other.Arrow.Transparency,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Arrow.Transparency = Number
            end})
        end
        local HeadSection = VisualsTab:Section({Name = "head circles",Side = "Right"}) do
            HeadSection:Toggle({Name = "enabled",Value = nullware.Config.PlayerESP.Other.Head.Enabled,Callback = function(Bool)
                nullware.Config.PlayerESP.Other.Head.Enabled = Bool
            end})
            HeadSection:Toggle({Name = "filled",Value = nullware.Config.PlayerESP.Other.Head.Filled,Callback = function(Bool)
                nullware.Config.PlayerESP.Other.Head.Filled = Bool
            end})
            HeadSection:Toggle({Name = "autoscale",Value = nullware.Config.PlayerESP.Other.Head.AutoScale,Callback = function(Bool)
                nullware.Config.PlayerESP.Other.Head.AutoScale = Bool
            end})
            HeadSection:Slider({Name = "radius",Min = 1,Max = 10,Value = nullware.Config.PlayerESP.Other.Head.Radius,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Head.Radius = Number
            end})
            HeadSection:Slider({Name = "num sides",Min = 3,Max = 100,Value = nullware.Config.PlayerESP.Other.Head.NumSides,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Head.NumSides = Number
            end})
            HeadSection:Slider({Name = "thickness",Min = 1,Max = 10,Value = nullware.Config.PlayerESP.Other.Head.Thickness,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Head.Thickness = Number
            end})
            HeadSection:Slider({Name = "transparency",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.PlayerESP.Other.Head.Transparency,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Head.Transparency = Number
            end})
        end
        local TracerSection = VisualsTab:Section({Name = "tracers",Side = "Right"}) do
            TracerSection:Toggle({Name = "enabled",Value = nullware.Config.PlayerESP.Other.Tracer.Enabled,Callback = function(Bool)
                nullware.Config.PlayerESP.Other.Tracer.Enabled = Bool
            end})
            TracerSection:Dropdown({Name = "mode",Default = {
                nullware.Config.PlayerESP.Other.Tracer.From == "ScreenBottom" and "From Bottom" or "From Mouse"
            },List = {
                {Name = "from bottom",Mode = "Button",Callback = function()
                    nullware.Config.PlayerESP.Other.Tracer.From = "ScreenBottom"
                end},
                {Name = "from mouse",Mode = "Button",Callback = function()
                    nullware.Config.PlayerESP.Other.Tracer.From = "Mouse"
                end}
            }})
            TracerSection:Slider({Name = "thickness",Min = 1,Max = 10,Value = nullware.Config.PlayerESP.Other.Tracer.Thickness,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Tracer.Thickness = Number
            end})
            TracerSection:Slider({Name = "transparency",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.PlayerESP.Other.Tracer.Transparency,Callback = function(Number)
                nullware.Config.PlayerESP.Other.Tracer.Transparency = Number
            end})
        end
        local HighlightSection = VisualsTab:Section({Name = "highlights",Side = "Right"}) do
            HighlightSection:Toggle({Name = "enabled",Value = nullware.Config.PlayerESP.Highlight.Enabled,Callback = function(Bool)
                nullware.Config.PlayerESP.Highlight.Enabled = Bool
            end})
            HighlightSection:Slider({Name = "transparency",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.PlayerESP.Highlight.Transparency,Callback = function(Number)
                nullware.Config.PlayerESP.Highlight.Transparency = Number
            end})
            HighlightSection:Colorpicker({Name = "outline color",HSVAR = nullware.Config.PlayerESP.Highlight.OutlineColor,Callback = function(HSVAR)
                nullware.Config.PlayerESP.Highlight.OutlineColor = HSVAR
            end})
        end
    end
    local SettingsTab = Window:Tab({Name = "settings"}) do
        local MenuSection = SettingsTab:Section({Name = "menu",Side = "Left"}) do
            MenuSection:Toggle({Name = "enabled",Value = Window.Enabled,Callback = function(Bool) 
                Window:Toggle(Bool)
            end}):Keybind({Key = nullware.Config.UI.Keybind,Callback = function(Bool,Key)
                nullware.Config.UI.Keybind = Key or "NONE"
            end})
            MenuSection:Toggle({Name = "watermark",Value = nullware.Config.UI.Watermark,Callback = function(Bool) 
                nullware.Config.UI.Watermark = Bool
                if not nullware.Config.UI.Watermark then
                    nullware.Utilities.UI:Watermark()
                end
            end})
            MenuSection:Toggle({Name = "close on exec",Value = not nullware.Config.UI.Enabled,Callback = function(Bool) 
                nullware.Config.UI.Enabled = not Bool
            end})
            MenuSection:Toggle({Name = "custom mouse",Value = nullware.Config.UI.Cursor.Enabled,Callback = function(Bool) 
                nullware.Config.UI.Cursor.Enabled = Bool
            end})
            MenuSection:Colorpicker({Name = "color",HSVAR = nullware.Config.UI.Color,Callback = function(HSVAR,Color)
                nullware.Config.UI.Color = HSVAR
                Window:SetColor(Color)
            end})
        end
        local CrosshairSection = SettingsTab:Section({Name = "custom crosshair",Side = "Left"}) do
            CrosshairSection:Toggle({Name = "enabled",Value = nullware.Config.UI.Cursor.Crosshair.Enabled,Callback = function(Bool) 
                nullware.Config.UI.Cursor.Crosshair.Enabled = Bool
            end})
            CrosshairSection:Colorpicker({Name = "color",HSVAR = nullware.Config.UI.Cursor.Crosshair.Color,Callback = function(HSVAR)
                nullware.Config.UI.Cursor.Crosshair.Color = HSVAR
            end})
            CrosshairSection:Slider({Name = "size",Min = 0,Max = 100,Value = nullware.Config.UI.Cursor.Crosshair.Size,Callback = function(Number)
                nullware.Config.UI.Cursor.Crosshair.Size = Number
            end})
            CrosshairSection:Slider({Name = "gap",Min = 0,Max = 100,Value = nullware.Config.UI.Cursor.Crosshair.Gap,Callback = function(Number)
                nullware.Config.UI.Cursor.Crosshair.Gap = Number
            end})
        end
        SettingsTab:Button({Name = "rejoin",Side = "Left",Callback = function()
            if #PlayerService:GetPlayers() <= 1 then
                LocalPlayer:Kick("\nrejoining...")
                task.wait()
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            else
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end})
        SettingsTab:Button({Name = "server hop",Side = "Left",Callback = function()
            local Servers = {}
            local Request = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local DataDecoded = HttpService:JSONDecode(Request).data
            for Index,ServerData in ipairs(DataDecoded) do
                if type(ServerData) == "table" and ServerData.id ~= game.JobId then
                    table.insert(Servers,ServerData.id)
                end
            end
            if #Servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)])
            else
                nullware.Utilities.UI:Notification({
                    Title = "nullware",
                    Description = "couldn't find a server",
                    Duration = 5
                })
            end
        end})
        SettingsTab:Button({Name = "nullware - join a discord server",Side = "Left",Callback = function()
            local Request = (syn and syn.request) or request
            Request({
                ["Url"] = "http://localhost:6463/rpc?v=1",
                ["Method"] = "POST",
                ["Headers"] = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com"
                },
                ["Body"] = HttpService:JSONEncode({
                    ["cmd"] = "INVITE_BROWSER",
                    ["nonce"] = string.lower(HttpService:GenerateGUID(false)),
                    ["args"] = {
                        ["code"] = ""
                    }
                })
            })
        end}):ToolTip("Join for support, updates and more!")
        local BackgroundSection = SettingsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Dropdown({Name = "Image",Default = {nullware.Config.UI.Background},List = {
                {Name = "legacy",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://2151741365"
                    nullware.Config.UI.BackgroundId = "rbxassetid://2151741365"
                end},
                {Name = "hearts",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073763717"
                    nullware.Config.UI.BackgroundId = "rbxassetid://6073763717"
                end},
                {Name = "abstract",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073743871"
                    nullware.Config.UI.BackgroundId = "rbxassetid://6073743871"
                end},
                {Name = "hexagon",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073628839"
                    nullware.Config.UI.BackgroundId = "rbxassetid://6073628839"
                end},
                {Name = "circles",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071579801"
                    nullware.Config.UI.BackgroundId = "rbxassetid://6071579801"
                end},
                {Name = "flowers",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071575925"
                    nullware.Config.UI.BackgroundId = "rbxassetid://6071575925"
                end},
                {Name = "floral",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://5553946656"
                    nullware.Config.UI.BackgroundId = "rbxassetid://5553946656"
                end}
            }})
            Window.Background.Image = nullware.Config.UI.BackgroundId
            Window.Background.ImageTransparency = nullware.Config.UI.BackgroundColor[4]
            Window.Background.TileSize = UDim2.new(0,nullware.Config.UI.TileSize,0,nullware.Config.UI.TileSize)
            Window.Background.ImageColor3 = nullware.Utilities.Config:TableToColor(nullware.Config.UI.BackgroundColor)
            BackgroundSection:Textbox({Name = "custom image",Text = "",Placeholder = "ImageId",Callback = function(String)
                Window.Background.Image = "rbxassetid://" .. String
                nullware.Config.UI.BackgroundId = "rbxassetid://" .. String
            end})
            BackgroundSection:Colorpicker({Name = "color",HSVAR = nullware.Config.UI.BackgroundColor,Callback = function(HSVAR,Color)
                nullware.Config.UI.BackgroundColor = HSVAR
                Window.Background.ImageColor3 = Color
                Window.Background.ImageTransparency = HSVAR[4]
            end})
            BackgroundSection:Slider({Name = "tile offset",Min = 74, Max = 296,Value = Window.Background.TileSize.X.Offset,Callback = function(Number)
                nullware.Config.UI.TileSize = Number
                Window.Background.TileSize = UDim2.new(0,Number,0,Number)
            end})
        end
        local CreditsSection = SettingsTab:Section({Name = "credits",Side = "Right"}) do
            CreditsSection:Label({Text = "pasted by gasps!"})
            CreditsSection:Divider()
            CreditsSection:Label({Text = "Thanks to Jan for this awesome background patterns."})
            CreditsSection:Label({Text = "Thanks to Infinite Yield Team for server hop."})
            CreditsSection:Label({Text = "Thanks to Blissful for Offscreen Arrows."})
            CreditsSection:Label({Text = "Thanks to coasts for his Universal ESP."})
            CreditsSection:Label({Text = "Thanks to el3tric for Bracket V2."})
            CreditsSection:Label({Text = "❤️ ❤️ ❤️ ❤️"})
        end
    end
end

local LastIteration
local FrameUpdate = {}
local Start = os.clock()
local function GetFPS()
	LastIteration = os.clock()
	for Index = #FrameUpdate, 1, -1 do
		FrameUpdate[Index + 1] = FrameUpdate[Index] >= LastIteration - 1 and FrameUpdate[Index] or nil
	end
	FrameUpdate[1] = LastIteration
	return os.clock() - Start >= 1 and #FrameUpdate or #FrameUpdate / (os.clock() - Start)
end

local function TeamCheck(Target)
    if nullware.Config.AimAssist.TeamCheck then
        return LocalPlayer.Team ~= Target.Team
    end
    return true
end

local function WallCheck(Enabled,Hitbox,Character)
	if not Enabled then return true end
	local Camera = Workspace.CurrentCamera
	return not Camera:GetPartsObscuringTarget({Hitbox.Position},{
        LocalPlayer.Character,
        Character
    })[1]
end

local function GetTarget(Config)
    if not Config.Enabled then return end
	local Camera = Workspace.CurrentCamera
	local FieldOfView = Config.FieldOfView
	local ClosestTarget = nil

	for Index, Target in pairs(PlayerService:GetPlayers()) do
		local Character = Target.Character
		local Health = Character and (Character:FindFirstChildOfClass("Humanoid") and Character:FindFirstChildOfClass("Humanoid").Health > 0)
		if Target ~= LocalPlayer and Health and TeamCheck(Target) then
			for Index, BodyPart in pairs(Config.Priority) do
				local Hitbox = Character and Character:FindFirstChild(BodyPart)
				if Hitbox then
					local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
					local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
					if OnScreen and FieldOfView > Magnitude and WallCheck(Config.WallCheck,Hitbox,Character) then
						FieldOfView = Magnitude
						ClosestTarget = Hitbox
					end
				end
			end
		end
	end

	return ClosestTarget
end

local function AimAt(Target,Config)
	if not Target then return end
	local Camera = Workspace.CurrentCamera
	local Mouse = UserInputService:GetMouseLocation()
	local TargetPrediction = ((Target.Position - Camera.CFrame.Position).Magnitude * Target.AssemblyLinearVelocity * (Config.Prediction.Velocity / 10)) / 100
	local TargetOnScreen = Camera:WorldToViewportPoint(Config.Prediction.Enabled and Target.Position + TargetPrediction or Target.Position)
	mousemoverel(
		(TargetOnScreen.X - Mouse.X) * Config.Sensitivity,
		(TargetOnScreen.Y - Mouse.Y) * Config.Sensitivity
	)
end

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if nullware.Config.AimAssist.SilentAim.Enabled and SilentAim then
        local Camera = Workspace.CurrentCamera
        local HitChance = math.random(0,100) <= nullware.Config.AimAssist.SilentAim.HitChance
        if getnamecallmethod() == "Raycast" and HitChance then
            args[2] = SilentAim.Position - Camera.CFrame.Position
        elseif getnamecallmethod() == "FindPartOnRayWithIgnoreList" and HitChance then
            args[1] = Ray.new(args[1].Origin,SilentAim.Position - Camera.CFrame.Position)
        end
    end
    return __namecall(self, unpack(args))
end)

RunService.Heartbeat:Connect(function()
    SilentAim = GetTarget(nullware.Config.AimAssist.SilentAim)
    if Aimbot then AimAt(GetTarget(nullware.Config.AimAssist.Aimbot),
        nullware.Config.AimAssist.Aimbot)
    end

    if nullware.Config.UI.Watermark then
        nullware.Utilities.UI:Watermark({
            Enabled = true,
            Title = string.format(
                "nullware — %s\nTime: %s - %s\nFPS: %i/s\nPing: %i ms",
                nullware.Current,os.date("%X"),os.date("%x"),GetFPS(),math.round(Stats.PerformanceStats.Ping:GetValue())
            )
        })
    end
end)

for Index, Player in pairs(PlayerService:GetPlayers()) do
    if Player ~= LocalPlayer then
        nullware.Utilities.Drawing:AddESP("Player", Player, nullware.Config.PlayerESP)
    end
end
PlayerService.PlayerAdded:Connect(function(Player)
    nullware.Utilities.Drawing:AddESP("Player", Player, nullware.Config.PlayerESP)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    if Player == LocalPlayer then nullware.Utilities.Config:WriteJSON(nullware.Current,nullware.Config) end
    nullware.Utilities.Drawing:RemoveESP(Player)
end)
