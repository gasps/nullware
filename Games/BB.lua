local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = PlayerService.LocalPlayer
local SilentAim, Aimbot, Toroiseshell = nil,
false, require(ReplicatedStorage.TS)
local BanReasons = {
    "Unsafe function",
    "Camera object", -- Crash
    "Geometry deleted", -- Crash
    "Deleted remote", -- Crash
    "Looking hard",
    "Unbound gloop", -- Crash
    "_G", -- Crash
    "Alternate mode",
    "Shooting hard",
    "Fallback config",
    "Int check",
    "Coregui instance",
    "Floating",
    "Root",
    "Hitbox extender"
}

nullware.Config = nullware.Utilities.Config:ReadJSON(nullware.Current, {
    PlayerESP = {
        AllyColor = {0.3333333432674408,1,1,0,false},
        EnemyColor = {1,1,1,0,false},

        TeamColor = false,
        TeamCheck = true,
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
        AutoShoot = false,
        Trigger = {
            Enabled = false,
            Priority = {"Head"},
            Delay = 0.15,
            HoldTime = 0
        },
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
            Priority = {"Head","Neck","Chest","Abdomen","Hips"},
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
    GameFeatures = {
        GunModification = {
            NoRecoil = false
        },
        GunCustomization = {
            Enabled = false,
            HideTextures = true,
            Color = {1,0.75,1,0.5,true},
            Transparency = 0.5,
            Reflectance = 0,
            Material = "Neon"
        },
        ArmsCustomization = {
            Enabled = false,
            HideTextures = true,
            Color = {1,0,1,0.5,false},
            Transparency = 0.5,
            Reflectance = 0,
            Material = "Neon"
        },
        Character = {
            Fly = {
                Enabled = false,
                Speed = 100
            },
            AntiAim = {
                Enabled = false,
                Pitch = -1.5,
                PitchRandom = 1
            }
        },
        Environment = {
            Enabled = false,
            ExposureCompensation = -2
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
        SilentAim = "NONE",
        Fly = "NONE"
    }
})

nullware.Utilities.Drawing:Cursor(nullware.Config.UI.Cursor)
nullware.Utilities.Drawing:FoVCircle(nullware.Config.AimAssist.Aimbot)
nullware.Utilities.Drawing:FoVCircle(nullware.Config.AimAssist.SilentAim)
local Window = nullware.Utilities.UI:Window({Name = "nullware — " .. nullware.Current,Enabled = nullware.Config.UI.Enabled,
Color = nullware.Utilities.Config:TableToColor(nullware.Config.UI.Color),Position = UDim2.new(0.2,-248,0.5,-248)}) do
    local AimAssistTab = Window:Tab({Name = "combat"}) do
        local AimbotSection = AimAssistTab:Section({Name = "aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "enabled",Value = nullware.Config.AimAssist.Aimbot.Enabled,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.Enabled = Bool
            end})
            AimbotSection:Toggle({Name = "visibility check",Value = nullware.Config.AimAssist.Aimbot.WallCheck,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.WallCheck = Bool
            end})
            AimbotSection:Keybind({Name = "Keybind",Key = nullware.Config.Binds.Aimbot,Mouse = true,Callback = function(Bool,Key)
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
                {Name = "head",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "neck",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "chest",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "abdomen",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "hips",Mode = "Toggle",Callback = function(Selected)
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
            AFoVSection:Slider({Name = "num sides",Min = 3,Max = 100,Value = nullware.Config.AimAssist.Aimbot.Circle.NumSides,Callback = function(Number)
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
            SilentAimSection:Toggle({Name = "visibility check",Value = nullware.Config.AimAssist.SilentAim.WallCheck,Callback = function(Bool)
                nullware.Config.AimAssist.SilentAim.WallCheck = Bool
            end})
            SilentAimSection:Slider({Name = "hit chance",Min = 0,Max = 100,Value = nullware.Config.AimAssist.SilentAim.HitChance,Unit = "%",Callback = function(Number)
                nullware.Config.AimAssist.SilentAim.HitChance = Number
            end})
            SilentAimSection:Slider({Name = "field of view",Min = 0,Max = 700,Value = nullware.Config.AimAssist.SilentAim.FieldOfView,Callback = function(Number)
                nullware.Config.AimAssist.SilentAim.FieldOfView = Number
            end})
            SilentAimSection:Dropdown({Name = "priority",Default = nullware.Config.AimAssist.SilentAim.Priority,List = {
                {Name = "head",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "neck",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "chest",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "aAbdomen",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "hips",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.SilentAim.Priority = Selected
                end}
            }})
        end
        local SAFoVSection = AimAssistTab:Section({Name = "silent Aim FOV",Side = "Right"}) do
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
        local MiscSection = AimAssistTab:Section({Name = "misc",Side = "Right"}) do
            MiscSection:Toggle({Name = "prediction",Value = nullware.Config.AimAssist.Aimbot.Prediction.Enabled,Callback = function(Bool)
                nullware.Config.AimAssist.Aimbot.Prediction.Enabled = Bool
            end}):ToolTip("affects only aimbot")
            MiscSection:Slider({Name = "velocity",Min = 1,Max = 20,Value = nullware.Config.AimAssist.Aimbot.Prediction.Velocity,Callback = function(Number)
                nullware.Config.AimAssist.Aimbot.Prediction.Velocity = Number
            end}):ToolTip("prediction Velocity")
            MiscSection:Toggle({Name = "autoShoot (beta)",Value = nullware.Config.AimAssist.AutoShoot,Callback = function(Bool)
                nullware.Config.AimAssist.AutoShoot = Bool
            end}):ToolTip("silent aim will not work with this being toggled")
            MiscSection:Toggle({Name = "trigger (beta)",Value = nullware.Config.AimAssist.Trigger.Enabled,Callback = function(Bool)
                nullware.Config.AimAssist.Trigger.Enabled = Bool
            end})
            MiscSection:Slider({Name = "delay",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.AimAssist.Trigger.Delay,Callback = function(Number)
                nullware.Config.AimAssist.Trigger.Delay = Number
            end}):ToolTip("trigger Delay")
            MiscSection:Slider({Name = "hold time",Min = 0,Max = 1,Precise = 2,Value = nullware.Config.AimAssist.Trigger.HoldTime,Callback = function(Number)
                nullware.Config.AimAssist.Trigger.HoldTime = Number
            end}):ToolTip("trigger hold time")
            MiscSection:Dropdown({Name = "priority",Default = nullware.Config.AimAssist.Trigger.Priority,List = {
                {Name = "head",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "neck",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "chest",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "abdomen",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "hips",Mode = "Toggle",Callback = function(Selected)
                    nullware.Config.AimAssist.Trigger.Priority = Selected
                end}
            }}):ToolTip("trigger Priority")
        end
    end
    local VisualsTab = Window:Tab({Name = "visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "team color",HSVAR = nullware.Config.PlayerESP.AllyColor,Callback = function(HSVAR)
                nullware.Config.PlayerESP.AllyColor = HSVAR
            end})
            GlobalSection:Colorpicker({Name = "enemy color",HSVAR = nullware.Config.PlayerESP.EnemyColor,Callback = function(HSVAR)
                nullware.Config.PlayerESP.EnemyColor = HSVAR
            end})
            GlobalSection:Toggle({Name = "team check",Value = nullware.Config.PlayerESP.TeamCheck,Callback = function(Bool)
                nullware.Config.PlayerESP.TeamCheck = Bool
            end})
            GlobalSection:Toggle({Name = "use team color",Value = nullware.Config.PlayerESP.TeamColor,Callback = function(Bool)
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
        local OoVSection = VisualsTab:Section({Name = "offscreen Arrows",Side = "Left"}) do
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
        local HeadSection = VisualsTab:Section({Name = "head Circles",Side = "Right"}) do
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
            HeadSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = nullware.Config.PlayerESP.Other.Head.NumSides,Callback = function(Number)
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
                nullware.Config.PlayerESP.Other.Tracer.From == "ScreenBottom" and "from bottom" or "from mouse"
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
    local GameTab = Window:Tab({Name = nullware.Current}) do
        local GCSection = GameTab:Section({Name = "gun customization",Side = "Left"}) do
            GCSection:Toggle({Name = "enabled",Value = nullware.Config.GameFeatures.GunCustomization.Enabled,Callback = function(Bool) 
                nullware.Config.GameFeatures.GunCustomization.Enabled = Bool
            end})
            GCSection:Toggle({Name = "hide textures",Value = nullware.Config.GameFeatures.GunCustomization.HideTextures,Callback = function(Bool) 
                nullware.Config.GameFeatures.GunCustomization.HideTextures = Bool
            end})
            GCSection:Colorpicker({Name = "color",HSVAR = nullware.Config.GameFeatures.GunCustomization.Color,Callback = function(HSVAR)
                nullware.Config.GameFeatures.GunCustomization.Color = HSVAR
            end})
            GCSection:Slider({Name = "reflectance",Min = 0,Max = 0.95,Precise = 2,Value = nullware.Config.GameFeatures.GunCustomization.Reflectance,Callback = function(Number)
                nullware.Config.GameFeatures.GunCustomization.Reflectance = Number
            end})
            GCSection:Dropdown({Name = "material",Default = {nullware.Config.GameFeatures.GunCustomization.Material},List = {
                {Name = "smoothPlastic",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.GunCustomization.Material = "SmoothPlastic"
                end},
                {Name = "forceField",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.GunCustomization.Material = "ForceField"
                end},
                {Name = "neon",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.GunCustomization.Material = "Neon"
                end},
                {Name = "glass",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.GunCustomization.Material = "Glass"
                end}
            }})
        end
        local GMSection = GameTab:Section({Name = "gun Modification",Side = "Left"}) do
            GMSection:Toggle({Name = "no Recoil",Value = nullware.Config.GameFeatures.GunModification.NoRecoil,Callback = function(Bool) 
                nullware.Config.GameFeatures.GunModification.NoRecoil = Bool
            end})
        end
        local EnvSection = GameTab:Section({Name = "environment",Side = "Left"}) do
            EnvSection:Toggle({Name = "enable",Value = nullware.Config.GameFeatures.Environment.Enabled,Callback = function(Bool)
                nullware.Config.GameFeatures.Environment.Enabled = Bool
                Lighting.ExposureCompensation = Bool and nullware.Config.GameFeatures.Environment.ExposureCompensation or 0
            end})
            EnvSection:Slider({Name = "exposure Compensation",Min = -5,Max = 5,Precise = 2,Value = nullware.Config.GameFeatures.Environment.ExposureCompensation,Callback = function(Number)
                nullware.Config.GameFeatures.Environment.ExposureCompensation = Number
                if nullware.Config.GameFeatures.Environment.Enabled then
                    Lighting.ExposureCompensation = Number
                end
            end})
        end
        local ACSection = GameTab:Section({Name = "arms Customization",Side = "Right"}) do
            ACSection:Toggle({Name = "enabled",Value = nullware.Config.GameFeatures.ArmsCustomization.Enabled,Callback = function(Bool) 
                nullware.Config.GameFeatures.ArmsCustomization.Enabled = Bool
            end})
            ACSection:Toggle({Name = "hide textures",Value = nullware.Config.GameFeatures.ArmsCustomization.HideTextures,Callback = function(Bool) 
                nullware.Config.GameFeatures.ArmsCustomization.HideTextures = Bool
            end})
            ACSection:Colorpicker({Name = "color",HSVAR = nullware.Config.GameFeatures.ArmsCustomization.Color,Callback = function(HSVAR)
                nullware.Config.GameFeatures.ArmsCustomization.Color = HSVAR
            end})
            ACSection:Slider({Name = "reflectance",Min = 0,Max = 0.95,Precise = 2,Value = nullware.Config.GameFeatures.ArmsCustomization.Reflectance,Callback = function(Number)
                nullware.Config.GameFeatures.ArmsCustomization.Reflectance = Number
            end})
            ACSection:Dropdown({Name = "material",Default = {nullware.Config.GameFeatures.ArmsCustomization.Material},List = {
                {Name = "smoothPlastic",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.ArmsCustomization.Material = "SmoothPlastic"
                end},
                {Name = "forceField",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.ArmsCustomization.Material = "ForceField"
                end},
                {Name = "neon",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.ArmsCustomization.Material = "Neon"
                end},
                {Name = "glass",Mode = "Button",Callback = function()
                    nullware.Config.GameFeatures.ArmsCustomization.Material = "Glass"
                end}
            }})
        end
        local CharSection = GameTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "Fly",Value = nullware.Config.GameFeatures.Character.Fly.Enabled,Callback = function(Bool) 
                nullware.Config.GameFeatures.Character.Fly.Enabled = Bool
            end}):Keybind({Key = nullware.Config.Binds.Fly,Callback = function(Bool,Key)
                nullware.Config.Binds.Fly = Key or "NONE"
            end})
            CharSection:Slider({Name = "Speed",Min = 10,Max = 100,Value = nullware.Config.GameFeatures.Character.Fly.Speed,Callback = function(Number)
                nullware.Config.GameFeatures.Character.Fly.Speed = Number
            end})
            CharSection:Toggle({Name = "Anti-Aim",Value = nullware.Config.GameFeatures.Character.AntiAim.Enabled,Callback = function(Bool) 
                nullware.Config.GameFeatures.Character.AntiAim.Enabled = Bool
            end}):Keybind({Key = nullware.Config.Binds.AntiAim,Callback = function(Bool,Key)
                nullware.Config.Binds.AntiAim = Key or "NONE"
            end})
            CharSection:Slider({Name = "Pitch",Min = -1.5,Max = 1.5,Precise = 2,Value = nullware.Config.GameFeatures.Character.AntiAim.Pitch,Callback = function(Number)
                nullware.Config.GameFeatures.Character.AntiAim.Pitch = Number
            end})
            CharSection:Slider({Name = "Pitch Random",Min = 0,Max = 1.5,Precise = 2,Value = nullware.Config.GameFeatures.Character.AntiAim.PitchRandom,Callback = function(Number)
                nullware.Config.GameFeatures.Character.AntiAim.PitchRandom = Number
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
                    Title = "nullware ",
                    Description = "Couldn't find a server",
                    Duration = 5
                })
            end
        end})
        SettingsTab:Button({Name = "join discord server",Side = "Left",Callback = function()
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
                        ["code"] = "eJKBjZsnu3"
                    }
                })
            })
        end}):ToolTip("join for support, updates and more!")
        local BackgroundSection = SettingsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Dropdown({Name = "Image",Default = {nullware.Config.UI.Background},List = {
                {Name = "legacy",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://2151741365"
                    nullware.Config.UI.BackgroundId = "rbxassetid://2151741365"
                end},
                {Name = "gay",Mode = "Button",Callback = function()
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
            CreditsSection:Label({Text = "pasted by gasped!"})
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

for Index,Property in pairs({"ExposureCompensation"}) do
    if nullware.Config.GameFeatures.Environment.Enabled then
        Lighting[Property] = nullware.Config.GameFeatures.Environment[Property]
    end
    Lighting:GetPropertyChangedSignal(Property):Connect(function()
        if nullware.Config.GameFeatures.Environment.Enabled then
            Lighting[Property] = nullware.Config.GameFeatures.Environment[Property]
        end
    end)
end

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.zero
BodyVelocity.MaxForce = Vector3.zero

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

local function InputToVelocity()
    local Camera = Workspace.CurrentCamera
    local Velocities = {}

    Velocities[1] = UserInputService:IsKeyDown(Enum.KeyCode.W)
    and Camera.CFrame.LookVector or Vector3.zero
    Velocities[2] = UserInputService:IsKeyDown(Enum.KeyCode.S)
    and -Camera.CFrame.LookVector or Vector3.zero
    Velocities[3] = UserInputService:IsKeyDown(Enum.KeyCode.A)
    and -Camera.CFrame.RightVector or Vector3.zero
    Velocities[4] = UserInputService:IsKeyDown(Enum.KeyCode.D)
    and Camera.CFrame.RightVector or Vector3.zero
    Velocities[5] = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    and Vector3.new(0,1,0) or Vector3.zero
    Velocities[6] = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    and Vector3.new(0,-1,0) or Vector3.zero
    
    return (
        Velocities[1] +
        Velocities[2] +
        Velocities[3] +
        Velocities[4] +
        Velocities[5] +
        Velocities[6]
    )
end

local function FindRemoteEvent(Name)
    for Index,RemoteEvent in pairs(ReplicatedStorage:GetDescendants()) do
        if RemoteEvent:IsA("RemoteEvent") and RemoteEvent.Name == Name then
            return RemoteEvent
        end
    end
end

local function FindGunModel()
    for Index,Instance in pairs(Workspace:GetChildren()) do
        if Instance:FindFirstChild("AnimationController") then
            return Instance
        end
    end
end

local function FindPlayerFromCharacter(Character)
    for Index, Player in pairs(PlayerService:GetPlayers()) do
        if Player.Character == Character then
            return Player
        end
    end
end

local function PlayerFly(Config)
    if not Config.Enabled then
        BodyVelocity.MaxForce = Vector3.zero
        return
    end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        BodyVelocity.Parent = LocalPlayer.Character.PrimaryPart
        BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.Velocity = InputToVelocity() * Config.Speed
    end
end

local function CustomizeGun(Config,Properties)
    if not Config.Enabled then return end
    local GunModel = FindGunModel()
    if GunModel then
        for Index,Instance in pairs(GunModel.Body:GetDescendants()) do
            if Config.HideTextures and Instance:IsA("Texture") then
                Instance.Transparency = 1
            elseif Instance:IsA("BasePart") and Instance.Transparency < 1
            and Instance.Reflectance < 1 then
                Instance.Color = nullware.Utilities.Config:TableToColor(Config.Color)
                Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
                Instance.Reflectance = Config.Reflectance
                Instance.Material = Config.Material
            end
        end
    end
end

local function CustomizeArms(Config,Properties)
    if not Config.Enabled then return end
    for Index,Instance in pairs(Workspace.Arms:GetDescendants()) do
        if Config.HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = nullware.Utilities.Config:TableToColor(Config.Color)
            Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
            Instance.Reflectance = Config.Reflectance
            Instance.Material = Config.Material
        end
    end
end

local function Raycast(Origin,Direction,Table)
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    RaycastParams.FilterDescendantsInstances = Table
    RaycastParams.IgnoreWater = true
    return Workspace:Raycast(Origin,Direction,RaycastParams)
end

local function TeamCheck(Target)
    return LocalPlayer.Team ~= Target.Team
    or tostring(Target.Team) == "FFA"
end

local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return not Raycast(
        Camera.CFrame.Position,
        Hitbox.Position - Camera.CFrame.Position,
        {Workspace.Geometry,Workspace.Terrain}
    )
end

local function GetTarget(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    local FieldOfView = Config.FieldOfView
    local ClosestTarget = nil

    for Index, Target in pairs(PlayerService:GetPlayers()) do
        local Character = Target.Character and Target.Character:FindFirstChild("Hitbox")
        if Target ~= LocalPlayer and TeamCheck(Target) then
            for Index, BodyPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(BodyPart)
                if Hitbox then
                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and FieldOfView > Magnitude and WallCheck(Config.WallCheck,Hitbox) then
                        FieldOfView = Magnitude
                        ClosestTarget = {
                            Player = Target,
                            Character = Target.Character,
                            Hitbox = Hitbox
                        }
                    end
                end
            end
        end
    end

    return ClosestTarget
end

local function Trigger(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    for Index, Target in pairs(PlayerService:GetPlayers()) do
        local Character = Target.Character and Target.Character:FindFirstChild("Hitbox")
        if Target ~= LocalPlayer and TeamCheck(Target) then
            for Index, BodyPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(BodyPart)
                if Hitbox and iswindowactive() and WallCheck(true,Hitbox) and Raycast(
                Camera.CFrame.Position,Camera.CFrame.LookVector * 1000,{Hitbox}) then
                    task.wait(Config.Delay)
                    mouse1press()
                    task.wait(Config.HoldTime)
                    mouse1release()
                end
            end
        end
    end
end

local function AutoShoot(Enabled)
    if not Enabled then return end
    local Camera = Workspace.CurrentCamera
    local Distance = math.huge
    local TargetHitbox = nil

    for Index, Target in pairs(PlayerService:GetPlayers()) do
        local Character = Target.Character and Target.Character:FindFirstChild("Hitbox")
        if Target ~= LocalPlayer and TeamCheck(Target) then
            local Hitbox = Character and Character:FindFirstChild("Head")
            if Hitbox then
                local Magnitude = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                if Distance > Magnitude then
                    Distance = Magnitude
                    TargetHitbox = Hitbox
                end
            end
        end
    end

    local GunModel = FindGunModel()
    if TargetHitbox and GunModel
    and LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("Backpack")
    and LocalPlayer.Character.Backpack:FindFirstChild("Items")
    and LocalPlayer.Character.Backpack.Items:FindFirstChild(GunModel.Name) then
        local GunFolder = LocalPlayer.Character.Backpack.Items[GunModel.Name]
        if LocalPlayer.Character.Backpack.Items[GunModel.Name].State.Ammo.Server.Value > 0 then
            local ID = Toroiseshell.Projectiles:GetID()
            Toroiseshell.Network:Fire("Item_Paintball","AltAim",GunFolder,true)
            Toroiseshell.Network:Fire("Item_Paintball","Shoot",GunFolder,
            TargetHitbox.Position,{{TargetHitbox.Position.Unit,ID}})
            Toroiseshell.Network:Fire("Projectiles","__Hit",ID,
            TargetHitbox.Position,TargetHitbox,
            TargetHitbox.Position.Unit,TargetHitbox.Parent.Parent)
        else
            Toroiseshell.Network:Fire("Item_Paintball","Reload",GunFolder)
        end
    end
end

local function AimAt(Target,Config)
    if not Target then return end
    Target = Target.Hitbox
    local Camera = Workspace.CurrentCamera
    local Mouse = UserInputService:GetMouseLocation()
    local TargetPrediction = ((Target.Position - Camera.CFrame.Position).Magnitude * Target.AssemblyLinearVelocity * (Config.Prediction.Velocity / 10)) / 100
    local TargetOnScreen = Camera:WorldToViewportPoint(Config.Prediction.Enabled and Target.Position + TargetPrediction or Target.Position)
    mousemoverel(
        (TargetOnScreen.X - Mouse.X) * Config.Sensitivity,
        (TargetOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

local HitNotify = Instance.new("BindableEvent")
HitNotify.Event:Connect(function(Player,Hitbox)
    local GunModel = FindGunModel()
    if GunModel then
        nullware.Utilities.UI:Notification2({
            Title = "Hit " .. Player.Name .. " in the " .. Hitbox.Name .. " with " .. GunModel.Name,
            Color = Color3.new(1,0.5,0.25),
            Duration = 3
        })
    end
end)

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if getnamecallmethod() == "FireServer" then
        for Index, Reason in pairs(BanReasons) do
            if typeof(args[2]) == "string" and string.match(args[2],Reason) then
                return
            end
        end
    end
    return __namecall(self, ...)
end)

local OldNetworkFire = Toroiseshell.Network.Fire
Toroiseshell.Network.Fire = function(self, ...)
    local args = {...}
    if nullware.Config.AimAssist.SilentAim.Enabled and SilentAim
    and not nullware.Config.AimAssist.AutoShoot then
        if args[2] == "__Hit" and math.random(0,100) <= nullware.Config.AimAssist.SilentAim.HitChance then
            args[4] = SilentAim.Hitbox.Position
            args[5] = SilentAim.Hitbox
            args[6] = Vector3.one
            args[7] = SilentAim.Player
            HitNotify:Fire(SilentAim.Player,SilentAim.Hitbox)
        end
    end
    if nullware.Config.GameFeatures.Character.AntiAim.Enabled and args[3] == "Look" then
        args[4] = nullware.Config.GameFeatures.Character.AntiAim.Pitch < -0
        and nullware.Config.GameFeatures.Character.AntiAim.Pitch + Random.new():NextNumber(0,
        nullware.Config.GameFeatures.Character.AntiAim.PitchRandom)
        or nullware.Config.GameFeatures.Character.AntiAim.Pitch - Random.new():NextNumber(0,
        nullware.Config.GameFeatures.Character.AntiAim.PitchRandom)
    end
    return OldNetworkFire(self, unpack(args))
end

local OldRecoilFire = Toroiseshell.Camera.Recoil.Fire
Toroiseshell.Camera.Recoil.Fire = function(self,...)
    local args = {...}
    if nullware.Config.GameFeatures.GunModification.NoRecoil then
        args[1] = Vector2.zero
        args[2] = 0
        args[3] = 0
        args[4] = 0
    end
    return OldRecoilFire(self,unpack(args))
end

RunService.Heartbeat:Connect(function()
    SilentAim = GetTarget(nullware.Config.AimAssist.SilentAim)
    if Aimbot then AimAt(GetTarget(nullware.Config.AimAssist.Aimbot),
        nullware.Config.AimAssist.Aimbot)
    end

    if nullware.Config.UI.Watermark then
        nullware.Utilities.UI:Watermark({
            Enabled = true,
            Title = string.format(
                "nullware  — %s\nTime: %s - %s\nFPS: %i/s\nPing: %i ms",
                nullware.Current,os.date("%X"),os.date("%x"),GetFPS(),math.round(Stats.PerformanceStats.Ping:GetValue())
            )
        })
    end

    AutoShoot(nullware.Config.AimAssist.AutoShoot)
    PlayerFly(nullware.Config.GameFeatures.Character.Fly)
    CustomizeGun(nullware.Config.GameFeatures.GunCustomization)
    CustomizeArms(nullware.Config.GameFeatures.ArmsCustomization)
end)
nullware.Utilities.ThreadLoop(0,function()
    Trigger(nullware.Config.AimAssist.Trigger)
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
