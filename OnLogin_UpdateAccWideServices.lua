
local ENABLED = true -- Set to false to disable this script

local AccountSettings = require("AccountSettings")
local PLAYER_EVENT_ON_LOGIN = 3

-- Function to update account-wide services on player login
local function OnLogin_UpdateAccWideServices(event, player)
    if not ENABLED then return end

    local accountId = player:GetAccountId()
    local source = "store"

    for index = 0, 9 do
        local value = player:GetPlayerSettingValue(source, index)
        if value then
            AccountSettings.Set(accountId, source, index, value)
        end
    end
end

print ("Eluna: Loaded 'OnLogin_UpdateAccWideServices.lua'. Script enabled: " .. (ENABLED and "true" or "false") .. ".")

RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, OnLogin_UpdateAccWideServices)
