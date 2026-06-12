local addonFrame = CreateFrame("Frame", "ForgedMangosbotMainPanel", UIParent)
local panelStorageKey = "mainPanel"

local function EnsureCharacterDB()
    if not ForgedMangosbotCharDB then
        ForgedMangosbotCharDB = {}
    end

    if not ForgedMangosbotCharDB[panelStorageKey] then
        ForgedMangosbotCharDB[panelStorageKey] = {}
    end

    return ForgedMangosbotCharDB[panelStorageKey]
end

local function RestorePanelPosition()
    local position = EnsureCharacterDB()

    addonFrame:ClearAllPoints()

    if position.anchorFrom and position.anchorTo then
        addonFrame:SetPoint(position.anchorFrom, UIParent, position.anchorTo, position.offsetX or 0, position.offsetY or 0)
        return
    end

    addonFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function SavePanelPosition()
    local position = EnsureCharacterDB()
    local anchorFrom, _, anchorTo, offsetX, offsetY = addonFrame:GetPoint()

    position.anchorFrom = anchorFrom
    position.anchorTo = anchorTo
    position.offsetX = offsetX
    position.offsetY = offsetY
end

addonFrame:Hide()
addonFrame:SetWidth(420)
addonFrame:SetHeight(300)
addonFrame:SetMovable(true)
addonFrame:EnableMouse(true)
addonFrame:RegisterForDrag("LeftButton")
addonFrame:SetScript("OnDragStart", function()
    local frame = this or addonFrame
    frame:StartMoving()
end)
addonFrame:SetScript("OnDragStop", function()
    local frame = this or addonFrame
    frame:StopMovingOrSizing()
    SavePanelPosition()
end)
addonFrame:SetScript("OnShow", RestorePanelPosition)

RestorePanelPosition()

addonFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5,
    },
})
addonFrame:SetBackdropColor(0, 0, 0, 0.90)

local title = addonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", addonFrame, "TOPLEFT", 14, -14)
title:SetText("Companion Controls")

-- local subtitle = addonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- subtitle:SetPoint("TOP", title, "BOTTOM", 0, -12)
-- subtitle:SetText("Forged replacement for Mangosbot main panel")

local function ToggleMainPanel()
    if addonFrame:IsVisible() then
        addonFrame:Hide()
        return
    end

    addonFrame:Show()

    -- Keep Mangosbot backend state fresh when the roster opens.
    if SendBotCommand then
        SendBotCommand(".bot list", "SAY")
    end
    if QueryBotParty then
        QueryBotParty()
    end
end

local originalMangosbotSlashHandler = SlashCmdList and SlashCmdList.MANGOSBOT
if SlashCmdList then
    SlashCmdList.MANGOSBOT = function(msg, editbox)
        msg = msg or ""

        if msg == "" or msg == "roster" then
            ToggleMainPanel()
            return
        end

        if originalMangosbotSlashHandler then
            originalMangosbotSlashHandler(msg, editbox)
        end
    end
end

-- Keep Mangosbot's real BotRoster object alive for its internal update logic,
-- but hide its original UI so the forged panel is what users interact with.
local replacementEventFrame = CreateFrame("Frame")
replacementEventFrame:RegisterEvent("VARIABLES_LOADED")
replacementEventFrame:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        RestorePanelPosition()

        if BotRoster and BotRoster.Hide then
            BotRoster:Hide()
        end
    end
end)
