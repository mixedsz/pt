-- Server-side script for physical therapy with ESX

-- Get ESX
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Register server event to check and remove money
RegisterNetEvent('physical:checkMoney')
AddEventHandler('physical:checkMoney', function(cost)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        TriggerClientEvent('physical:moneyResult', src, false, 'Error: Player not found')
        return
    end

    -- Check if player has enough money (cash or bank)
    local playerCash = xPlayer.getMoney()
    local playerBank = xPlayer.getAccount('bank').money

    if playerCash >= cost then
        -- Remove cash
        xPlayer.removeMoney(cost)
        TriggerClientEvent('physical:moneyResult', src, true, 'Payment of $' .. cost .. ' processed from cash')
    elseif playerBank >= cost then
        -- Remove from bank
        xPlayer.removeAccountMoney('bank', cost)
        TriggerClientEvent('physical:moneyResult', src, true, 'Payment of $' .. cost .. ' processed from bank')
    else
        -- Not enough money
        TriggerClientEvent('physical:moneyResult', src, false, 'You don\'t have enough money for therapy')
    end
end)
