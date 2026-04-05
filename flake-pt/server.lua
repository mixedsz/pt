-- Simple Peacetime Script by Floh
-- Server-side component

-- Initialize peacetime state (default: disabled)
GlobalState.peacetime = false

-- Register command for toggling peacetime
RegisterCommand('pt', function(source, args, rawCommand)
    -- Check if the player has permission to use this command
    -- You can implement your own permission system here
    if source > 0 then
        -- Get the player's name for logging
        local playerName = GetPlayerName(source)
        
        -- Toggle the peacetime state
        if GlobalState.peacetime then
            -- Disable peacetime
            GlobalState.peacetime = false
            print("^1Peacetime DISABLED by " .. playerName .. "^7")
            TriggerClientEvent('pt:disabled', -1)
        else
            -- Enable peacetime
            GlobalState.peacetime = true
            print("^2Peacetime ENABLED by " .. playerName .. "^7")
            TriggerClientEvent('pt:enabled', -1)
        end
    else
        -- Command was executed from server console
        if GlobalState.peacetime then
            -- Disable peacetime
            GlobalState.peacetime = false
            print("^1Peacetime DISABLED by console^7")
            TriggerClientEvent('pt:disabled', -1)
        else
            -- Enable peacetime
            GlobalState.peacetime = true
            print("^2Peacetime ENABLED by console^7")
            TriggerClientEvent('pt:enabled', -1)
        end
    end
end, true) -- Set this to false if you want to restrict the command

-- Event handler for when a player connects
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    -- Inform the server that a player is connecting
    print("^3Player " .. name .. " is connecting^7")
end)

-- Event handler for when a player spawns
RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
    -- Send the current peacetime state to the newly spawned player
    if GlobalState.peacetime then
        TriggerClientEvent('pt:enabled', source)
    else
        TriggerClientEvent('pt:disabled', source)
    end
end)

-- Print a message when the resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print("^2Simple Peacetime script started^7")
end)
