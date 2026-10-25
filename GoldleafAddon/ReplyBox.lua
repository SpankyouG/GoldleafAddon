-- GoldleafAddon Dynamic Reply Box
GoldleafAddon = GoldleafAddon or {}
local GA = GoldleafAddon

local frame
local buttons = {}

local function CreateReplyFrame()
    if frame then return frame end

    frame = CreateFrame("Frame", "GoldleafReplyBox", UIParent, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:Hide()

    -- ⭐ Make the reply box movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -14)
    title:SetText("|cff7CFC00Goldleaf Reply|r")
    frame.title = title

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() frame:Hide() end)

    -- Escape closes
    frame:EnableKeyboard(true)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then self:Hide() end
    end)

    return frame
end

function GA:ShowReplyBox()
    if not self.activeCharacter or not self.activeTables then return end
    if not self.activeTables.Replies then return end

    local f = CreateReplyFrame()

    -- Clear old buttons
    for _, btn in ipairs(buttons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    buttons = {}

    -- Get dynamic categories
    local categories = {}
    for catName, _ in pairs(self.activeTables.Replies) do
        table.insert(categories, catName)
    end
    table.sort(categories)

    -- Resize frame based on number of categories
    local height = 60 + (#categories * 28)
    frame:SetSize(280, height)

    -- Create dynamic buttons
    for i, cat in ipairs(categories) do
        local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        btn:SetSize(240, 24)
        btn:SetPoint("TOP", 0, -30 - (i-1)*28)
        btn.category = cat

        -- Preview text
        local preview = GA:GetNextLine(cat)
        local short = preview:sub(1, 28) .. (preview:len() > 28 and "…" or "")
        btn:SetText(cat .. " – " .. short)

        -- Put preview back into shuffle bag
        local bagKey = (self.activeCharacter or "None") .. "_" .. cat
        if GA.shuffleBags[bagKey] then
            table.insert(GA.shuffleBags[bagKey], 1, preview)
        end

        btn:SetScript("OnClick", function(self)
            local line = GA:GetNextLine(self.category)
            local editBox = ChatEdit_ChooseBoxForSend()
            if editBox then
                ChatEdit_ActivateChat(editBox)
                editBox:SetText(line)
                ChatEdit_OnEnterPressed(editBox)
            end
            frame:Hide()
        end)

        table.insert(buttons, btn)
    end

    -- Position at cursor
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/scale, y/scale)
    f:Show()
end
