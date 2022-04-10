repeat task.wait() until game.GameId ~= 0
if nullware and nullware.Loaded then
	nullware.Utilities.UI:Notification({
		Title = "nullware",
		Description = "script already executed!",
		Duration = 5
	})
	return
end

getgenv().nullware = {
	Loaded = true,
	Debug = false,
	Current = "Loader",
	Utilities = {},
	Config = {}
}

nullware.Utilities.UI = nullware.Debug and loadfile("nullware/Utilities/UI.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Utilities/UI.lua"))()
nullware.Utilities.Config = nullware.Debug and loadfile("nullware/Utilities/Config.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Utilities/Config.lua"))()
nullware.Utilities.Drawing = nullware.Debug and loadfile("nullware/Utilities/Drawing.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Utilities/Drawing.lua"))()
nullware.Utilities.ThreadLoop = function(Wait,Function)
	coroutine.wrap(function()
		while task.wait(Wait) do
			Function()
		end
	end)()
end

nullware.Games = {
	["1054526971"] = {
		Name = "Blackhawk Rescue Mission 5",
		Script = nullware.Debug and readfile("nullware/Games/BRM5.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Games/BRM5.lua")
	},
	["580765040"] = {
		Name = "RAGDOLL UNIVERSE",
		Script = nullware.Debug and readfile("nullware/Games/RU.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Games/RU.lua")
	},
	["1168263273"] = {
		Name = "bad business",
		Script = nullware.Debug and readfile("nullware/Games/BB.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Games/BB.lua")
	},
	--[[
	["807930589"] = {
		Name = "The Wild West",
		Script = nullware.Debug and readfile("nullware/Games/TWW.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Games/TWW.lua")
	},
	["2194874153"] = {
		Name = "Those Who Remain",
		Script = nullware.Debug and readfile("nullware/Games/TWR.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Games/TWR.lua")
	}
	]]
}

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local function getGameInfo()
	for Id,Info in pairs(nullware.Games) do
		if tostring(game.GameId) == Id then
			return Info
		end
	end
end

LocalPlayer.OnTeleport:Connect(function(State)
	if State == Enum.TeleportState.Started then
		getgenv().nullware.Loaded = false
		local QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport
		QueueOnTeleport(nullware.Debug and readfile("nullware/Loader.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Loader.lua"))
	end
end)

local Info = getGameInfo()
if Info then
	nullware.Current = Info.Name
	nullware.Utilities.UI:Notification({
		Title = "nullware",
		Description = nullware.Current .. " loaded!",
		Duration = 5
	})
	loadstring(Info.Script)()
else
	nullware.Current = "Universal"
	nullware.Utilities.UI:Notification({
		Title = "nullware : gay",
		Description = nullware.Current .. " loaded!",
		Duration = 5
	})
	loadstring(nullware.Debug and readfile("nullware/Universal.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/gasps/nullware/main/Universal.lua"))()
end
