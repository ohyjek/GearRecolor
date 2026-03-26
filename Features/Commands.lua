local GlobalEnv = _G
local Addon = GlobalEnv and rawget(GlobalEnv, "GearRecolor")
if not Addon then
    return
end

local SlashCmdList = GlobalEnv and rawget(GlobalEnv, "SlashCmdList")

local function PrintColorLegend()
    Addon.ChatPrint("|cff66ccffGearRecolor|r upgrade track colors:")
    for _, track in ipairs(Addon.TrackOrder) do
        local color = Addon.TrackColors[track]
        Addon.ChatPrint(" - " .. color .. track .. "|r")
    end
    Addon.ChatPrint("|cff66ccffUsage:|r /gearrecolor or /grc")
end

if SlashCmdList then
    SlashCmdList.GEARRECOLOR = PrintColorLegend
    rawset(GlobalEnv, "SLASH_GEARRECOLOR1", "/gearrecolor")
    rawset(GlobalEnv, "SLASH_GEARRECOLOR2", "/grc")
end
