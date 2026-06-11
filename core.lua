local addonFrame = CreateFrame("Frame", "ForgedMangosbotMainPanel", UIParent)
addonFrame:Hide()
addonFrame:SetWidth(420)
addonFrame:SetHeight(300)
addonFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
addonFrame:SetMovable(true)
addonFrame:EnableMouse(true)
addonFrame:RegisterForDrag("LeftButton")
addonFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
addonFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

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
title:SetPoint("TOP", addonFrame, "TOP", 0, -14)
title:SetText("Companion Controls")

local subtitle = addonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
subtitle:SetPoint("TOP", title, "BOTTOM", 0, -12)
subtitle:SetText("Forged replacement for Mangosbot main panel")

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
        if BotRoster and BotRoster.Hide then
            BotRoster:Hide()
        end
    end
end)
