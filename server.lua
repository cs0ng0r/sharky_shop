local ESX = exports.es_extended:getSharedObject()

local MAX_DISTANCE = 3.0

local function isPlayerNearShop(playerId, shopCoords)
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return false end

    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - shopCoords)
    return distance <= MAX_DISTANCE
end

local function getShopByCoords(coords)
    for _, shop in pairs(Config.Shops) do
        local distance = #(shop.coords - coords)
        if distance < 1.0 then
            return shop
        end
    end
    return nil
end

local function validateItemInShop(itemName, shop)
    for _, shopItem in pairs(shop.items) do
        if shopItem.name == itemName then
            return shopItem
        end
    end
    return nil
end

RegisterServerEvent('sharky_mta_shop:buyItem')
AddEventHandler('sharky_mta_shop:buyItem', function(itemName, quantity, shopCoords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if not xPlayer then return end

    if not isPlayerNearShop(_source, shopCoords) then
        TriggerClientEvent('chatMessage', _source, "[SHOP]", { 255, 0, 0 }, "Túl messze vagy a bolttól!")
        return
    end

    local shop = getShopByCoords(shopCoords)
    if not shop then
        TriggerClientEvent('chatMessage', _source, "[SHOP]", { 255, 0, 0 }, "Érvénytelen bolt!")
        return
    end

    local shopItem = validateItemInShop(itemName, shop)
    if not shopItem then
        TriggerClientEvent('chatMessage', _source, "[SHOP]", { 255, 0, 0 }, "Ez a termék nem elérhető ebben a boltban!")
        return
    end

    if type(quantity) ~= "number" or quantity <= 0 or quantity > 100 then
        TriggerClientEvent('chatMessage', _source, "[SHOP]", { 255, 0, 0 }, "Érvénytelen mennyiség!")
        return
    end

    quantity = math.floor(quantity)
    local totalPrice = shopItem.price * quantity

    if xPlayer.getMoney() >= totalPrice then
        xPlayer.removeMoney(totalPrice)
        xPlayer.addInventoryItem(itemName, quantity)
        TriggerClientEvent('chatMessage', _source, "[SHOP]", { 0, 255, 0 },
            string.format("Megvásároltál %dx %s-t $%d-ért!", quantity, shopItem.label or itemName, totalPrice))
    else
        TriggerClientEvent('chatMessage', _source, "[SHOP]", { 255, 0, 0 }, "Nincs elég pénzed!")
    end
end)
