-- Create the main addon table with flags for debugging.
AltNames = {
    isPolling = false,
    isInitialized = false
};
-- DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[AltNames-Debug]|r [Step 1] Addon file loaded.");

--------------------------------------------------------------------------------
-- 1. THE DEBUG FUNCTION (/run AltNamesD())
--------------------------------------------------------------------------------
function AltNamesD()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700---------- AltNames Debug Report ----------");
    DEFAULT_CHAT_FRAME:AddMessage("Is Polling for UI: " .. tostring(AltNames.isPolling));
    DEFAULT_CHAT_FRAME:AddMessage("Addon Initialized: " .. tostring(AltNames.isInitialized));
    if (DropDownList1) then
        DEFAULT_CHAT_FRAME:AddMessage("Status of 'DropDownList1': |cff00ff00Exists");
    else
        DEFAULT_CHAT_FRAME:AddMessage("Status of 'DropDownList1': |cffff0000NIL");
    end
    if (AltNamesDB and next(AltNamesDB)) then
        DEFAULT_CHAT_FRAME:AddMessage("Database Contents:");
        for k, v in pairs(AltNamesDB) do
            DEFAULT_CHAT_FRAME:AddMessage("- " .. k .. " -> " .. v);
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Database Contents: Empty");
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd700------------------------------------------");
end

---
-- A string.match() implementation for Lua 5.0 that handles captures.
-- This is necessary because string.match was officially introduced in Lua 5.1.
---
function getChannelName(inputString)
  local pattern = "%d+%.%s*(.*)"
  local _, _, capturedText = string.find(inputString, pattern)
  if capturedText then
    return string.lower(capturedText)
  else
    return nil
  end
end

--------------------------------------------------------------------------------
-- 2. ADDON INITIALIZATION
--------------------------------------------------------------------------------
function AltNames:Initialize()
    -- DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[AltNames-Debug]|r [Step 4] Initialize() function called.");
    if (not AltNamesDB) then AltNamesDB = {}; end
    
    AltNames:HookChatSystem();
    AltNames:HookHyperlink();
    AltNames:CreatePopupDialog();
    AltNames:ScanGuildRoster();

    local eventHandler = CreateFrame("Frame");
    eventHandler:RegisterEvent("GUILD_ROSTER_UPDATE");
    eventHandler:SetScript("OnEvent", function(event)
        if (event == "GUILD_ROSTER_UPDATE") then AltNames:ScanGuildRoster(); end
    end);

    AltNames.isInitialized = true;
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AltNames:|r Addon loaded successfully.");
end

--------------------------------------------------------------------------------
-- 3. ROBUST LOADING MECHANISM
--------------------------------------------------------------------------------
local initializerFrame = CreateFrame("Frame");
-- DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[AltNames-Debug]|r [Step 2] Initializer frame created. Starting polling...");

initializerFrame:SetScript("OnUpdate", function()
    AltNames.isPolling = true;
    if (DropDownList1) then
        -- DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[AltNames-Debug]|r [Step 3] Polling successful! 'DropDownList1' found.");
        AltNames.isPolling = false;
        initializerFrame:SetScript("OnUpdate", nil);
        AltNames:Initialize();
    end
end);

--------------------------------------------------------------------------------
-- 4. CORE ADDON FEATURES
--------------------------------------------------------------------------------
function AltNames:HookHyperlink()
    -- DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[AltNames-Debug]|r [Step 5] HookHyperlink() called.");
    local originalHyperlinkShow = ChatFrame_OnHyperlinkShow;
    
    ChatFrame_OnHyperlinkShow = function(linkContainer, link, text, button)
        originalHyperlinkShow(linkContainer, link, text, button);

        if (text == "RightButton" and string.find(linkContainer, "^player:")) then
            local playerName = string.sub(linkContainer, 8);
            
            local info = {};
            info.text = "Set Main Name";
            info.value = playerName;
            info.notCheckable = true;
            info.func = function() AltNames:ShowSetMainPopup(info.value); end;
            
            UIDropDownMenu_AddButton(info, 1);
        end
    end
end

function AltNames:HookChatSystem()
    -- DEFAULT_CHAT_FRAME:AddMessage("|cffffa500[AltNames-Debug]|r [Step 6] HookChatSystem() called.");
    local Original_ChatFrame_OnEvent = ChatFrame_OnEvent;
    ChatFrame_OnEvent = function()

        local eventsToHook = { 
            ["CHAT_MSG_GUILD"] = true, 
            ["CHAT_MSG_PARTY"] = true, 
            ["CHAT_MSG_RAID"] = true,
            ["CHAT_MSG_BATTLEGROUND"] = true,
            ["CHAT_MSG_OFFICER"] = true,
            ["CHAT_MSG_SAY"] = true, 
            ["CHAT_MSG_YELL"] = true, 
            ["CHAT_MSG_WHISPER"] = true
        };

        local channelsToMatch = {
            ["world"] = true,
            ["general"] = true,
            ["trade"] = true
        }

        if event == "CHAT_MSG_GUILD" then
            AltNames:ScanGuildRoster();
        end
        
        if (eventsToHook[event] and arg1 and arg2) or (arg4 and getChannelName(arg4) and (channelsToMatch[getChannelName(arg4)] and arg1 and arg2)) then
            local mainName = AltNamesDB[string.lower(arg2)];
            if (mainName) then
                arg1 = "|cffdabfff" .. mainName .. "|r: " .. arg1;
            end
        end
        
        Original_ChatFrame_OnEvent(event);
    end
end

function AltNames:ScanGuildRoster()
    for i = 1, GetNumGuildMembers() do
        local name, _, _, _, _, _, pnote = GetGuildRosterInfo(i);
        if (name) then
            local lowerName = string.lower(name);
            if (not AltNamesDB[lowerName]) then
                if (pnote and pnote ~= "") then
                    -- Match the last "word" (non-space characters) before "alt" or "Alt" 
                    local mainNameCandidate = string.match(pnote, "(%S+)%s*[aA]lt");
                    if (mainNameCandidate) then
                        -- Clean up the name, for example, removing a trailing "'s"
                        local mainName = string.gsub(mainNameCandidate, "'s$", "");
                        AltNamesDB[lowerName] = mainName;
                    end
                end
            end
        end
    end
end

function AltNames:SetMainName(altName, mainName)
    if (altName and mainName and mainName ~= "") then
        AltNamesDB[string.lower(altName)] = mainName;
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AltNames:|r Saved |cffeda55f"..mainName.."|r as the main for "..altName..".");
    elseif (altName) then
        AltNamesDB[string.lower(altName)] = nil;
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AltNames:|r Removed main for "..altName..".");
    end
end

function AltNames:ShowSetMainPopup(name)
    AltNames.clickedName = name;
    StaticPopup_Show("ALTNAMES_SET_MAIN", name);
end

function AltNames:CreatePopupDialog()
    StaticPopupDialogs["ALTNAMES_SET_MAIN"] = {
        text = "Enter the main character's name for\n|cFFFFFFFF%s|r",
        button1 = "Accept",
        button2 = "Cancel",
        hasEditBox = 1,
        maxLetters = 32,
        timeout = 0,
        OnAccept = function() AltNames:SetMainName(AltNames.clickedName, StaticPopup1EditBox:GetText()); end,
        OnShow = function()
            local currentMain = AltNamesDB[string.lower(AltNames.clickedName)];
            StaticPopup1EditBox:SetText(currentMain or "");
            StaticPopup1EditBox:HighlightText();
        end,
        EditBoxOnEnterAccept = 1,
        hideOnEscape = 1,
    };
end

