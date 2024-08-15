local shopItems = {}
local shops = Config.Shops

function getItems(coords)
    TriggerServerEvent('sharky_mta_shop:getItems', coords)
end

-- Event handler
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
    print("Nincs tárgy.")
end)

-- NUI Callbacks
RegisterNUICallback('buyItem', function(data, cb)
    local itemName = data.itemName
    local itemPrice = data.itemPrice
    local itemQuantity = data.itemQuantity

    if itemName and itemPrice and itemQuantity then
        -- Send a server event with item details
        TriggerServerEvent('sharky_mta_shop:buyItem', itemName, itemPrice, itemQuantity)
        cb('ok')
    else
        print("Error: Missing item details")
        cb('error')
    end
end)

RegisterNUICallback('closeShop', function(data, cb)
    SendNUIMessage({
        type = "closeShop",
    })
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Shop pedek létrehozása / Create shop peds
CreateThread(function()
    createBlip()

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
        SetBlockingOfNonTemporaryEvents(shopPed, true)
        SetEntityInvincible(shopPed, true)
        SetModelAsNoLongerNeeded(GetHashKey(ped.model))
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for _, shop in pairs(shops) do
            local distance = #(playerCoords - shop.coords)
            if distance < 2.0 then
                DrawText3D(shop.coords + vec3(0, 0, 2.0), shop.ped.text)
                if IsControlJustReleased(0, 38) then -- "E" key by default
                    getItems(shop.coords)
                end
            end
        end
    end
end)

-- DrawText3D
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

-- Blip készítése / Blip creation
function createBlip()
    for k, v in pairs(Config.Shops) do
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, 52)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Bolt')
        EndTextCommandSetBlipName(blip)
    end
end
