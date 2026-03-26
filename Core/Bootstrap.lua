local GlobalEnv = _G
local Addon = GlobalEnv.GearRecolor or {}
rawset(GlobalEnv, "GearRecolor", Addon)

local Colors = {
    GREEN = "|cff1eff00",
    BLUE = "|cff0070dd",
    PURPLE = "|cffa335ee",
    ORANGE = "|cffff8000",
    RED = "|cffb22222"
}

Addon.TrackColors = {
    Adventurer = Colors.GREEN,
    Veteran = Colors.BLUE,
    Champion = Colors.PURPLE,
    Hero = Colors.ORANGE,
    Myth = Colors.RED,
}

Addon.TrackAliases = {
    Adventurer = { "Adventurer" },
    Veteran = { "Veteran" },
    Champion = { "Champion" },
    Hero = { "Hero" },
    Myth = { "Myth", "Mythic" },
}

Addon.TrackOrder = {
    "Adventurer",
    "Veteran",
    "Champion",
    "Hero",
    "Myth",
}

local DefaultChatFrame = GlobalEnv and rawget(GlobalEnv, "DEFAULT_CHAT_FRAME")
local Print = GlobalEnv and rawget(GlobalEnv, "print")

if not Addon.ChatPrint then
    function Addon.ChatPrint(message)
        if DefaultChatFrame and DefaultChatFrame.AddMessage then
            DefaultChatFrame:AddMessage(message)
            return
        end

        if Print then
            Print(message)
        end
    end
end
