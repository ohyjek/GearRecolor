local Colors = {
    GREEN = "|cff1eff00",
    BLUE = "|cff0070dd",
    PURPLE = "|cffa335ee",
    ORANGE = "|cffff8000",
    RED = "|cffb22222"
}

local GlobalEnv = _G
local TooltipDataProcessor = GlobalEnv and rawget(GlobalEnv, "TooltipDataProcessor")
local Enum = GlobalEnv and rawget(GlobalEnv, "Enum")
local GameTooltip = GlobalEnv and rawget(GlobalEnv, "GameTooltip")
local ItemRefTooltip = GlobalEnv and rawget(GlobalEnv, "ItemRefTooltip")
local ShoppingTooltip1 = GlobalEnv and rawget(GlobalEnv, "ShoppingTooltip1")
local ShoppingTooltip2 = GlobalEnv and rawget(GlobalEnv, "ShoppingTooltip2")
local HookSecureFunc = GlobalEnv and rawget(GlobalEnv, "hooksecurefunc")
local C_Timer = GlobalEnv and rawget(GlobalEnv, "C_Timer")
local SlashCmdList = GlobalEnv and rawget(GlobalEnv, "SlashCmdList")
local DefaultChatFrame = GlobalEnv and rawget(GlobalEnv, "DEFAULT_CHAT_FRAME")
local Print = GlobalEnv and rawget(GlobalEnv, "print")

local TrackColors = {
    Adventurer = Colors.GREEN,
    Veteran = Colors.BLUE,
    Champion = Colors.PURPLE,
    Hero = Colors.ORANGE,
    Myth = Colors.RED,
}

local TrackAliases = {
    Adventurer = { "Adventurer" },
    Veteran = { "Veteran" },
    Champion = { "Champion" },
    Hero = { "Hero" },
    Myth = { "Myth", "Mythic" },
}

local TrackOrder = {
    "Adventurer",
    "Veteran",
    "Champion",
    "Hero",
    "Myth",
}

local function ChatPrint(message)
    if DefaultChatFrame and DefaultChatFrame.AddMessage then
        DefaultChatFrame:AddMessage(message)
        return
    end

    if Print then
        Print(message)
    end
end

local function PrintColorLegend()
    ChatPrint("|cff66ccffGearRecolor|r upgrade track colors:")
    for _, track in ipairs(TrackOrder) do
        local color = TrackColors[track]
        ChatPrint(" - " .. color .. track .. "|r")
    end
    ChatPrint("|cff66ccffUsage:|r /gearrecolor or /grc")
end

local function StripColorCodes(text)
    if not text then
        return nil
    end

    local cleaned = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    return cleaned:gsub("|r", "")
end

local function RecolorText(text, color)
    if not text or not color then
        return text
    end

    -- Only remove an outer color wrapper, keep the displayed content intact.
    local withoutLeadingColor = text:gsub("^|c%x%x%x%x%x%x%x%x", "")
    local withoutOuterColor = withoutLeadingColor:gsub("|r$", "")
    return color .. withoutOuterColor .. "|r"
end

local function BuildColoredUpgradeLine(text)
    local plainText = StripColorCodes(text)
    if not plainText then
        return nil
    end

    -- Keep support for both old and newer tooltip labels.
    local isUpgradeLine = plainText:find("Upgrade Level", 1, true) or plainText:find("Upgrade Track", 1, true)
    if not isUpgradeLine then
        return nil
    end

    for track, color in pairs(TrackColors) do
        local aliases = TrackAliases[track]
        if aliases then
            for _, alias in ipairs(aliases) do
                if plainText:find(alias, 1, true) then
                    return RecolorText(text, color)
                end
            end
        else
            if plainText:find(track, 1, true) then
                return RecolorText(text, color)
            end
        end
    end

    -- Fallback for unexpected wording that still references myth track.
    if plainText:find("Myth", 1, true) or plainText:find("Mythic", 1, true) then
        local mythColor = TrackColors.Myth
        if mythColor then
            return RecolorText(text, mythColor)
        end
    end

    return nil
end

local function OnTooltipSetItem(tooltip)
    if not tooltip or not tooltip.GetName or not tooltip.NumLines then
        return
    end

    local tooltipName = tooltip:GetName()

    for i = 1, tooltip:NumLines() do
        if tooltipName then
            local leftLine = GlobalEnv[tooltipName .. "TextLeft" .. i]
            if leftLine then
                local text = leftLine:GetText()
                local coloredItemLevel = BuildColoredUpgradeLine(text)
                if coloredItemLevel and coloredItemLevel ~= text then
                    leftLine:SetText(coloredItemLevel)
                end
            end

            local rightLine = GlobalEnv[tooltipName .. "TextRight" .. i]
            if rightLine then
                local text = rightLine:GetText()
                local coloredItemLevel = BuildColoredUpgradeLine(text)
                if coloredItemLevel and coloredItemLevel ~= text then
                    rightLine:SetText(coloredItemLevel)
                end
            end
        end
    end

    -- Some tooltips add item lines on non-standard font strings.
    if tooltip.GetRegions then
        local regions = { tooltip:GetRegions() }
        for _, region in ipairs(regions) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                local text = region:GetText()
                local coloredItemLevel = BuildColoredUpgradeLine(text)
                if coloredItemLevel and coloredItemLevel ~= text then
                    region:SetText(coloredItemLevel)
                end
            end
        end
    end

    -- Comparison tooltip text can finalize one frame later.
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if not tooltip or not tooltip.GetName or not tooltip.NumLines then
                return
            end

            local deferredName = tooltip:GetName()
            if not deferredName then
                return
            end

            for i = 1, tooltip:NumLines() do
                local deferredLeft = GlobalEnv[deferredName .. "TextLeft" .. i]
                if deferredLeft then
                    local text = deferredLeft:GetText()
                    local coloredItemLevel = BuildColoredUpgradeLine(text)
                    if coloredItemLevel and coloredItemLevel ~= text then
                        deferredLeft:SetText(coloredItemLevel)
                    end
                end

                local deferredRight = GlobalEnv[deferredName .. "TextRight" .. i]
                if deferredRight then
                    local text = deferredRight:GetText()
                    local coloredItemLevel = BuildColoredUpgradeLine(text)
                    if coloredItemLevel and coloredItemLevel ~= text then
                        deferredRight:SetText(coloredItemLevel)
                    end
                end
            end
        end)
    end
end

if SlashCmdList then
    SlashCmdList.GEARRECOLOR = PrintColorLegend
    rawset(GlobalEnv, "SLASH_GEARRECOLOR1", "/gearrecolor")
    rawset(GlobalEnv, "SLASH_GEARRECOLOR2", "/grc")
end

-- Retail-safe path: catches normal and comparison item tooltips.
if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
else
    -- Fallback for environments without TooltipDataProcessor.
    if GameTooltip and HookSecureFunc then
        HookSecureFunc(GameTooltip, "SetHyperlink", OnTooltipSetItem)
        HookSecureFunc(GameTooltip, "SetBagItem", OnTooltipSetItem)
        HookSecureFunc(GameTooltip, "SetInventoryItem", OnTooltipSetItem)
    end

    if ItemRefTooltip and HookSecureFunc then
        HookSecureFunc(ItemRefTooltip, "SetHyperlink", OnTooltipSetItem)
    end

    if ShoppingTooltip1 and HookSecureFunc then
        HookSecureFunc(ShoppingTooltip1, "SetHyperlink", OnTooltipSetItem)
    end

    if ShoppingTooltip2 and HookSecureFunc then
        HookSecureFunc(ShoppingTooltip2, "SetHyperlink", OnTooltipSetItem)
    end
end
