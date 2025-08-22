local shops = Config.Shops
local isShopOpen = false
local currentShop = nil

local function openShop(shop)
    if isShopOpen then return end

    currentShop = shop
    isShopOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openShop",
        items = shop.items
    })
end

RegisterNUICallback('buyItem', function(data, cb)
    local itemName = data.itemName
    local itemQuantity = data.itemQuantity

    if not isShopOpen or not currentShop then
        cb('error')
        return
    end

    if itemName and itemQuantity and type(itemQuantity) == "number" and itemQuantity > 0 then
        TriggerServerEvent('sharky_mta_shop:buyItem', itemName, itemQuantity, currentShop.coords)
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
    isShopOpen = false
    currentShop = nil
    cb('ok')
end)

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
        local nearShop = false

        for _, shop in pairs(shops) do
            local distance = #(playerCoords - shop.coords)
            if distance < 2.0 then
                nearShop = true
                DrawText3D(shop.coords + vec3(0, 0, 2.0), shop.ped.text)
                if IsControlJustReleased(0, 38) then
                    openShop(shop)
                end
                break
            end
        end

        if not nearShop and isShopOpen then
            SendNUIMessage({ type = "closeShop" })
            SetNuiFocus(false, false)
            isShopOpen = false
            currentShop = nil
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
