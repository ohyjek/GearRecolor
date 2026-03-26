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

Addon.DefaultTrackColors = {
    Adventurer = Colors.GREEN,
    Veteran = Colors.BLUE,
    Champion = Colors.PURPLE,
    Hero = Colors.ORANGE,
    Myth = Colors.RED,
}

Addon.TrackColors = {
    Adventurer = Addon.DefaultTrackColors.Adventurer,
    Veteran = Addon.DefaultTrackColors.Veteran,
    Champion = Addon.DefaultTrackColors.Champion,
    Hero = Addon.DefaultTrackColors.Hero,
    Myth = Addon.DefaultTrackColors.Myth,
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

Addon.EditableTracks = {
    "Adventurer",
    "Veteran",
    "Champion",
    "Hero",
    "Myth",
}

local function NormalizeColorCode(colorCode)
    if type(colorCode) ~= "string" then
        return nil
    end

    local r, g, b = string.match(colorCode, "^|cff(%x%x)(%x%x)(%x%x)$")
    if not (r and g and b) then
        return nil
    end

    return "|cff" .. string.lower(r) .. string.lower(g) .. string.lower(b)
end

function Addon.ColorCodeToRGB(colorCode)
    local normalizedColorCode = NormalizeColorCode(colorCode)
    if not normalizedColorCode then
        return nil
    end

    local r, g, b = string.match(normalizedColorCode, "^|cff(%x%x)(%x%x)(%x%x)$")
    return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
end

function Addon.RGBToColorCode(red, green, blue)
    if type(red) ~= "number" or type(green) ~= "number" or type(blue) ~= "number" then
        return nil
    end

    local clampedRed = math.min(1, math.max(0, red))
    local clampedGreen = math.min(1, math.max(0, green))
    local clampedBlue = math.min(1, math.max(0, blue))
    local redByte = math.floor((clampedRed * 255) + 0.5)
    local greenByte = math.floor((clampedGreen * 255) + 0.5)
    local blueByte = math.floor((clampedBlue * 255) + 0.5)
    return string.format("|cff%02x%02x%02x", redByte, greenByte, blueByte)
end

local function EnsureSavedVariables()
    local db = rawget(GlobalEnv, "GearRecolorDB")
    if type(db) ~= "table" then
        db = {}
        rawset(GlobalEnv, "GearRecolorDB", db)
    end

    Addon.DB = db
    return db
end

function Addon.SetTrackColor(track, colorCode, shouldPersist)
    if type(track) ~= "string" or not Addon.TrackColors[track] then
        return false
    end

    local normalizedColorCode = NormalizeColorCode(colorCode)
    if not normalizedColorCode then
        return false
    end

    Addon.TrackColors[track] = normalizedColorCode

    if shouldPersist then
        local db = EnsureSavedVariables()
        db[track .. "Color"] = normalizedColorCode
    end

    return true
end

function Addon.ResetTrackColor(track)
    if type(track) ~= "string" then
        return false
    end

    local defaultColor = Addon.DefaultTrackColors[track]
    if not defaultColor then
        return false
    end

    return Addon.SetTrackColor(track, defaultColor, true)
end

function Addon.SetAdventurerColor(colorCode, shouldPersist)
    return Addon.SetTrackColor("Adventurer", colorCode, shouldPersist)
end

function Addon.ResetAdventurerColor()
    return Addon.ResetTrackColor("Adventurer")
end

local function ApplySavedTrackColors()
    local db = EnsureSavedVariables()
    for _, track in ipairs(Addon.EditableTracks) do
        local key = track .. "Color"
        local savedColor = NormalizeColorCode(db[key])
        if savedColor then
            Addon.TrackColors[track] = savedColor
        else
            Addon.TrackColors[track] = Addon.DefaultTrackColors[track]
            db[key] = Addon.DefaultTrackColors[track]
        end
    end
end

ApplySavedTrackColors()

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
