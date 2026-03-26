local GlobalEnv = _G
local Addon = GlobalEnv and rawget(GlobalEnv, "GearRecolor")
if not Addon then
    return
end

local CreateFrame = GlobalEnv and rawget(GlobalEnv, "CreateFrame")
local Settings = GlobalEnv and rawget(GlobalEnv, "Settings")
local InterfaceOptions_AddCategory = GlobalEnv and rawget(GlobalEnv, "InterfaceOptions_AddCategory")
local UIParent = GlobalEnv and rawget(GlobalEnv, "UIParent")

local function RegisterOptionsPanel()
    if Addon.OptionsPanelRegistered or not CreateFrame then
        return
    end

    local panel = CreateFrame("Frame", "GearRecolorOptionsPanel", UIParent)
    panel.name = "GearRecolor"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("GearRecolor")

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    description:SetText("hello world")

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
        Settings.RegisterAddOnCategory(category)
        Addon.OptionsPanelRegistered = true
        return
    end

    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        Addon.OptionsPanelRegistered = true
    end
end

RegisterOptionsPanel()
