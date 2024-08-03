local ESX = exports.es_extended:getSharedObject()

RegisterServerEvent('sharky_mta_shop:getItems')
AddEventHandler('sharky_mta_shop:getItems', function(coords)
    local source = source
    for _, shop in pairs(Config.Shops) do
        if shop.coords == coords then
            TriggerClientEvent('sharky_mta_shop:sendItems', source, shop.items)
            return
        end
    end
    TriggerClientEvent('sharky_mta_shop:noItemsFound', source)
end)


RegisterServerEvent('sharky_mta_shop:buyItem')
AddEventHandler('sharky_mta_shop:buyItem', function(item)
    if not xPlayer then return end

    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = 0
    for _, shop in pairs(Config.Shops) do
        for _, shopItem in pairs(shop.items) do
            if shopItem.name == item then
                price = shopItem.price
                break
            end
        end
    end
    if price == 0 then
        print("Item not found in any shop.")
        return
    end
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem(item)
    else
        print("Player does not have enough money.")
    end
end)
