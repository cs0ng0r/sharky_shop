local shopItems = {}
local shops = Config.Shops

function openShop(coords)
    TriggerServerEvent('sharky_mta_shop:getItems', coords)
end

RegisterNetEvent('sharky_mta_shop:sendItems')
AddEventHandler('sharky_mta_shop:sendItems', function(items)
    shopItems = items
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openShop",
        items = shopItems
    })
end)

RegisterNetEvent('sharky_mta_shop:noItemsFound')
AddEventHandler('sharky_mta_shop:noItemsFound', function()
    print("No items found for this shop.")
end)

RegisterNUICallback('buyItem', function(data, cb)
    local itemName = data.itemName
    local itemPrice = data.itemPrice
    TriggerServerEvent('sharky_mta_shop:buyItem', itemName, itemPrice)
    cb('ok')
end)

RegisterNUICallback('closeShop', function(data, cb)
    SendNUIMessage({
        type = "closeShop",
    })
    SetNuiFocus(false, false)

    cb('ok')
end)


CreateThread(function()
    for k, v in pairs(Config.Shops) do
        local ped = v.ped
        RequestModel(GetHashKey(ped.model))
        while not HasModelLoaded(GetHashKey(ped.model)) do
            Wait(1)
        end

        local shopPed = CreatePed(4, GetHashKey(ped.model), v.coords.x, v.coords.y, v.coords.z, 3374176, false, true)
        SetEntityHeading(shopPed, v.heading)
        FreezeEntityPosition(shopPed, true)
        SetEntityAsMissionEntity(shopPed, true, true)
    end
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for _, shop in pairs(shops) do
            local distance = Vdist(playerCoords, shop.coords.x, shop.coords.y, shop.coords.z)
            if distance < 2.0 then
                DrawText3D(shop.coords + vec3(0, 0, 2.0), shop.ped.text)
                if IsControlJustReleased(0, 38) then -- "E" key by default
                    openShop(shop.coords)
                end
            end
        end
    end
end)


function DrawText3D(coords, text)
    SetDrawOrigin(coords)
    SetTextScale(0.0, 0.4)
    SetTextFont(4)
    SetTextCentre(1)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0, 0)
    ClearDrawOrigin()
end
