GlobalState.Oleo = Config.Oleo

local randomDeliveryOil

Citizen.CreateThread(function()
    for _, v in pairs(Config.Oleo) do
        v.taken = false
    end
end)

function OleoCooldown(loc)
    CreateThread(function()
        Wait(Config.respawnTime * 1000)
        Config.Oleo[loc].taken = false
        GlobalState.Oleo = Config.Oleo
        Wait(1000)
        TriggerClientEvent('oil:respawnCane', -1, loc)
    end)
end
    
RegisterNetEvent("oil:pickupCane")
AddEventHandler("oil:pickupCane", function(loc)
    local src = source
    if not Config.Oleo[loc].taken then
        Config.Oleo[loc].taken = true
        GlobalState.Oleo = Config.Oleo
        TriggerClientEvent("oil:removeCane", -1, loc)
        OleoCooldown(loc)
    end
end)



RegisterServerEvent('infinity-oil-delivery:server:selloil')
AddEventHandler('infinity-oil-delivery:server:selloil', function(amount)
    local src = source
    local PlayerDatas = exports.infinity_core:GetPlayerSession(src)
    local oilCount = exports.infinity_needs:CheckPlayerInventory(src, "oil")
    amount = tonumber(amount) or 0

    if oilCount and tonumber(oilCount) >= amount and amount > 0 then
        local price = Config.PriceOil * amount
        exports.infinity_needs:RemoveInventoryItem(src, "oil", amount, PlayerDatas._Inventory, false)
        exports.infinity_core:AddCash(src, price)
        exports.infinity_core:notification(src, 'Oil Sale', 'You sold <b>'..amount..'x oil</b> and received <b>$'..price..'</b>', 'center_right', 'infinitycore', 3000)
    else
        exports.infinity_core:notification(src, 'Oil Sale', 'You do not have that amount of oil to sell!', 'center_right', 'infinitycore', 3000)
    end
end)

-- give delivery reward
RegisterNetEvent('infinity-oil-delivery:server:givereward', function(cashreward)
    local src = source
    exports.infinity_core:AddCash(src, cashreward)
end)


RegisterServerEvent('infinity-oil-delivery:server:giveOilReward')
AddEventHandler('infinity-oil-delivery:server:giveOilReward', function()
    local _InfinitySource = source
    local itemdb = "oil"
    local quantity = exports.infinity_core:RandomInt(2) + 1
    local PlayerDatas = exports.infinity_core:GetPlayerSession(_InfinitySource)
    if not PlayerDatas then
        TriggerClientEvent('chat:addMessage', _InfinitySource, { args = { '^1ERROR', 'Player not found.' } })
        return
    end
    exports.infinity_needs:AddInventoryItem(_InfinitySource, itemdb, quantity, PlayerDatas._Inventory, false)
    exports.infinity_core:notification(_InfinitySource, "Oil", '<b class="text-success">+ '..quantity..'x '..itemdb..'</b>', 'center_right', 'infinitycore', 3000)
end)
