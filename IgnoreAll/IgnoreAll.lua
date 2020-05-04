SLASH_IGNOREALL1 = "/ia"
SLASH_IGNOREALL2 = '/ignoreall'
SLASH_REMOVEIGNORE1 = "/iarm"
SLASH_REMOVEIGNORE2 = '/removeignore'
s_addonTitle = "IgnoreAll"
s_helpString = "To use 'IgnoreAll' use the chat command '/ia <name>, <name>, ...' or '/ignoreall <name>, <name>' to ignore multiple users at once. \n To remove users from your ignore list use the chat command '/iarm <name>, <name>, ...' or '/removeignore <name>, ...'\n Thanks for using 'IgnoreAll'!"

-- TODO: Add chat parsing immediately following command to tell if the user has used the addon erroneously
-- e.g. Selecting an NPC and using the command.

f_parseInputString = function(s_inputString)
     -- Split input string:
    local t_playerUsernames = {};
    local n_wordIndex = 1;
    for s_word in string.gmatch(s_inputString, '([^,]+)') do
        if not ( s_word == '' ) then
            t_playerUsernames[n_wordIndex] = s_word:gsub("%s+", "");
        end
        n_wordIndex = n_wordIndex + 1;
    end
    return t_playerUsernames;
end

f_addOrRemoveIgnore = function(s_userName, b_addOrIgnore)
    if ( b_addOrIgnore ) then
        -- Add to ignore list.
        if ( C_FriendList.IsIgnored(s_userName) ) then
            print(s_userName .. " is already on your ignore list!");
        else
            C_FriendList.AddIgnore(s_userName);
            -- No need to check ignore list here, client does this for us!
        end

    else
        -- Remove from ignore list
        if ( C_FriendList.IsIgnored(s_userName) ) then
            C_FriendList.DelIgnore(s_userName);
            if ( C_FriendList.IsIgnored(s_userName) ) then
                -- Add print outs as client does not do this.
                print(s_userName .. " was removed from your ignore list!");
            end
        else
            print(s_userName .. " is not on your ignore list!");
        end
   end
end

f_IgnoreAll = function(s_inputString, b_addOrIgnore)
    if ( s_inputString:lower() == 'help' ) then
        print(s_helpString);
        return nil
    end

    local t_playerUsernames = f_parseInputString(s_inputString);

    if ( #t_playerUsernames < 1 ) then
        local s_targetPlayer = UnitName("target");
        if ( s_targetPlayer ) then 
            f_addOrRemoveIgnore(s_targetPlayer, b_addOrIgnore);
        else
            print("Target a player or enter a comma-seperated list of players");
        end
    end
    
    local i;
    local s_targetPlayer;

    for i=1, #t_playerUsernames do
        s_targetPlayer = t_playerUsernames[i];
        if ( s_targetPlayer ) then
            f_addOrRemoveIgnore(s_targetPlayer, b_addOrIgnore);
        end
    end
end

---- 

SlashCmdList["REMOVEIGNORE"] = function(s_inputString)
    f_IgnoreAll(s_inputString, false);
end

SlashCmdList["IGNOREALL"] = function(s_inputString)
    f_IgnoreAll(s_inputString, true);
end

local f_welcomePlayer = function()
    -- Check addon is loaded correctly, inform the user.
    local s_playerTitle = UnitName("player");
    local b_returnValue = false;
    if ( IsAddOnLoaded(s_addonTitle) ) then
        print("Welcome " .. s_playerTitle .. ", " .. s_addonTitle .. " is loaded!")
        print("Type '/ia help' if you're unsure how to use " .. s_addonTitle);
        b_returnValue = true;
    else
        print("Attention, " .. s_playerTitle .. "! " .. s_addonTitle .. " failed to load")
    end
    return b_returnValue; -- Incase we need to check this in future.
end

b_addonLoaded = f_welcomePlayer();
