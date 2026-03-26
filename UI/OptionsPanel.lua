local GlobalEnv = _G
local Addon = GlobalEnv and rawget(GlobalEnv, "GearRecolor")
if not Addon then
    return
end

local CreateFrame = GlobalEnv and rawget(GlobalEnv, "CreateFrame")
local Settings = GlobalEnv and rawget(GlobalEnv, "Settings")
local InterfaceOptions_AddCategory = GlobalEnv and rawget(GlobalEnv, "InterfaceOptions_AddCategory")
local UIParent = GlobalEnv and rawget(GlobalEnv, "UIParent")
local ColorPickerFrame = GlobalEnv and rawget(GlobalEnv, "ColorPickerFrame")
local OpenColorPicker = GlobalEnv and rawget(GlobalEnv, "OpenColorPicker")

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
    description:SetText("Choose colors for each upgrade track.")

    local previewHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    previewHeader:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -14)
    previewHeader:SetText("Upgrade track colors")

    local previewRows = {}
    local previousLine = previewHeader
    for _, track in ipairs(Addon.TrackOrder) do
        local row = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        row:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, -5)
        row:SetText(track)
        previewRows[track] = row
        previousLine = row
    end

    local function RefreshTrackPreview()
        for _, track in ipairs(Addon.TrackOrder) do
            local row = previewRows[track]
            local colorCode = Addon.TrackColors[track] or "|cffffffff"
            row:SetText(colorCode .. track .. "|r")
        end
    end

    local function MakeSwatch(anchorFrame)
        local swatch = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        swatch:SetSize(22, 22)
        swatch:SetPoint("LEFT", anchorFrame, "RIGHT", 8, 0)
        swatch:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        return swatch
    end

    local function RefreshTrackSwatch(swatch, track)
        local red, green, blue = Addon.ColorCodeToRGB(Addon.TrackColors[track])
        if red and green and blue then
            swatch:SetBackdropColor(red, green, blue, 1)
        else
            swatch:SetBackdropColor(1, 1, 1, 1)
        end
    end

    local function SetInlineStatus(toastLabel, text, colorCode)
        if not toastLabel then
            return
        end

        local activeColor = colorCode or "|cff1eff00"
        toastLabel:SetText(activeColor .. text .. "|r")
        toastLabel:Show()
    end

    local function SetTrackFromRGB(track, red, green, blue)
        local colorCode = Addon.RGBToColorCode(red, green, blue)
        if not colorCode then
            return false
        end

        return Addon.SetTrackColor(track, colorCode, true)
    end

    local function OpenTrackColorPicker(track, onApplied)
        local red, green, blue = Addon.ColorCodeToRGB(Addon.TrackColors[track])
        if not (red and green and blue) then
            red, green, blue = 1, 1, 1
        end

        local function applyFromPicker()
            if ColorPickerFrame and ColorPickerFrame.GetColorRGB then
                local currentRed, currentGreen, currentBlue = ColorPickerFrame:GetColorRGB()
                if SetTrackFromRGB(track, currentRed, currentGreen, currentBlue) then
                    onApplied()
                end
            end
        end

        local function cancelFromPicker(previousValues)
            if not previousValues then
                return
            end

            if SetTrackFromRGB(track, previousValues.r, previousValues.g, previousValues.b) then
                onApplied()
            end
        end

        if ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow({
                r = red,
                g = green,
                b = blue,
                hasOpacity = false,
                swatchFunc = applyFromPicker,
                opacityFunc = nil,
                cancelFunc = cancelFromPicker,
            })
            return
        end

        if OpenColorPicker then
            local info = {
                r = red,
                g = green,
                b = blue,
                hasOpacity = false,
                swatchFunc = applyFromPicker,
                opacityFunc = nil,
                cancelFunc = cancelFromPicker,
            }
            OpenColorPicker(info)
        end
    end

    local trackSwatches = {}
    local trackToasts = {}
    local editorAnchor = previousLine
    for _, track in ipairs(Addon.EditableTracks or { "Adventurer" }) do
        local trackHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        trackHeader:SetPoint("TOPLEFT", editorAnchor, "BOTTOMLEFT", 0, -12)
        trackHeader:SetText(track .. " color")

        local trackHelp = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        trackHelp:SetPoint("TOPLEFT", trackHeader, "BOTTOMLEFT", 0, -4)
        trackHelp:SetText("Changes tooltip color for " .. track .. " only.")

        local pickerButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        pickerButton:SetSize(140, 22)
        pickerButton:SetPoint("TOPLEFT", trackHelp, "BOTTOMLEFT", 0, -8)
        pickerButton:SetText("Pick color")

        local swatch = MakeSwatch(pickerButton)
        trackSwatches[track] = swatch

        local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        resetButton:SetSize(140, 22)
        resetButton:SetPoint("LEFT", swatch, "RIGHT", 10, 0)
        resetButton:SetText("Reset to default")

        local toastLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        toastLabel:SetPoint("LEFT", resetButton, "RIGHT", 10, 0)
        toastLabel:SetText("")
        toastLabel:Hide()
        trackToasts[track] = toastLabel

        local function refreshEditor()
            RefreshTrackPreview()
            RefreshTrackSwatch(swatch, track)
        end

        pickerButton:SetScript("OnClick", function()
            OpenTrackColorPicker(track, function()
                refreshEditor()
                SetInlineStatus(toastLabel, "Saved", "|cff1eff00")
            end)
        end)

        resetButton:SetScript("OnClick", function()
            if Addon.ResetTrackColor(track) then
                refreshEditor()
                SetInlineStatus(toastLabel, "Reset", "|cffffff00")
            end
        end)

        editorAnchor = pickerButton
    end

    local function RefreshEditorSwatches()
        for track, swatch in pairs(trackSwatches) do
            RefreshTrackSwatch(swatch, track)
        end
    end

    local function RefreshOptionsPanel()
        RefreshTrackPreview()
        RefreshEditorSwatches()
        for _, toastLabel in pairs(trackToasts) do
            toastLabel:SetText("")
            toastLabel:Hide()
        end
    end

    -- Initialize visuals immediately so first paint is correct even if OnShow timing varies.
    RefreshOptionsPanel()

    if panel.HookScript then
        panel:HookScript("OnShow", RefreshOptionsPanel)
    else
        panel:SetScript("OnShow", RefreshOptionsPanel)
    end

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
