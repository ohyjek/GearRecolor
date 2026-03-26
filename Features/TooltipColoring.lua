local GlobalEnv = _G
local Addon = GlobalEnv and rawget(GlobalEnv, "GearRecolor")
if not Addon then
    return
end

local TooltipDataProcessor = GlobalEnv and rawget(GlobalEnv, "TooltipDataProcessor")
local Enum = GlobalEnv and rawget(GlobalEnv, "Enum")
local GameTooltip = GlobalEnv and rawget(GlobalEnv, "GameTooltip")
local ItemRefTooltip = GlobalEnv and rawget(GlobalEnv, "ItemRefTooltip")
local ShoppingTooltip1 = GlobalEnv and rawget(GlobalEnv, "ShoppingTooltip1")
local ShoppingTooltip2 = GlobalEnv and rawget(GlobalEnv, "ShoppingTooltip2")
local HookSecureFunc = GlobalEnv and rawget(GlobalEnv, "hooksecurefunc")
local C_Timer = GlobalEnv and rawget(GlobalEnv, "C_Timer")

local function StripColorCodes(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    return string.gsub(cleaned, "|r", "")
end

local function RecolorText(text, color)
    if type(text) ~= "string" or not color then
        return text
    end

    -- Only remove an outer color wrapper, keep the displayed content intact.
    local withoutLeadingColor = string.gsub(text, "^|c%x%x%x%x%x%x%x%x", "")
    local withoutOuterColor = string.gsub(withoutLeadingColor, "|r$", "")
    return color .. withoutOuterColor .. "|r"
end

local function BuildColoredUpgradeLine(text)
    local plainText = StripColorCodes(text)
    if not plainText then
        return nil
    end

    -- Keep support for both old and newer tooltip labels.
    local isUpgradeLine = string.find(plainText, "Upgrade Level", 1, true) or string.find(plainText, "Upgrade Track", 1, true)
    if not isUpgradeLine then
        return nil
    end

    for track, color in pairs(Addon.TrackColors) do
        local aliases = Addon.TrackAliases[track]
        if aliases then
            for _, alias in ipairs(aliases) do
                if string.find(plainText, alias, 1, true) then
                    return RecolorText(text, color)
                end
            end
        else
            if string.find(plainText, track, 1, true) then
                return RecolorText(text, color)
            end
        end
    end

    -- Fallback for unexpected wording that still references myth track.
    if string.find(plainText, "Myth", 1, true) or string.find(plainText, "Mythic", 1, true) then
        local mythColor = Addon.TrackColors.Myth
        if mythColor then
            return RecolorText(text, mythColor)
        end
    end

    return nil
end

local function TryBuildColoredUpgradeLine(text)
    local ok, recolored = pcall(BuildColoredUpgradeLine, text)
    if ok then
        return recolored
    end

    -- Secret tooltip strings can throw on any string conversion.
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
                local coloredItemLevel = TryBuildColoredUpgradeLine(text)
                if coloredItemLevel then
                    leftLine:SetText(coloredItemLevel)
                end
            end

            local rightLine = GlobalEnv[tooltipName .. "TextRight" .. i]
            if rightLine then
                local text = rightLine:GetText()
                local coloredItemLevel = TryBuildColoredUpgradeLine(text)
                if coloredItemLevel then
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
                local coloredItemLevel = TryBuildColoredUpgradeLine(text)
                if coloredItemLevel then
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
                    local coloredItemLevel = TryBuildColoredUpgradeLine(text)
                    if coloredItemLevel then
                        deferredLeft:SetText(coloredItemLevel)
                    end
                end

                local deferredRight = GlobalEnv[deferredName .. "TextRight" .. i]
                if deferredRight then
                    local text = deferredRight:GetText()
                    local coloredItemLevel = TryBuildColoredUpgradeLine(text)
                    if coloredItemLevel then
                        deferredRight:SetText(coloredItemLevel)
                    end
                end
            end
        end)
    end
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
