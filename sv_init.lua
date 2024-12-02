RegisterNetEvent("SAMPLE_K9::PLAY_DOOR_SOUND")
AddEventHandler("SAMPLE_K9::PLAY_DOOR_SOUND", function(veh, leaving)
    local player = source 

    for k, v in pairs(GetPlayers()) do
        if #(GetEntityCoords(GetPlayerPed(v)) - GetEntityCoords(GetPlayerPed(player))) < 500  then
            TriggerClientEvent("SAMPLE_K9::PLAY_DOOR_SOUND_CLIENT", v, veh, leaving)
        end
    end
end)

local i = 0
local shits = {}
RegisterNetEvent("SAMPLE_K9::SHIT")
AddEventHandler("SAMPLE_K9::SHIT", function(coords)
    local player = source

    local prop = `prop_big_shit_01`
    local obj = CreateObjectNoOffset(prop, coords, true, true, false)

    while not DoesEntityExist(obj) do
        Citizen.Wait(500)
    end

    i = i + 1
    shits[i] = { obj = NetworkGetNetworkIdFromEntity(obj), deleted = false }

    print(GetPlayerPed(player), obj, NetworkGetNetworkIdFromEntity(obj), NetworkGetNetworkIdFromEntity(GetPlayerPed(player)))

    TriggerClientEvent("SAMPLE_K9::DOG_SHIT", -1, i, NetworkGetNetworkIdFromEntity(obj))
end)

RegisterNetEvent("SAMPLE_K9::DELETE_SHIT")
AddEventHandler("SAMPLE_K9::DELETE_SHIT", function(obj)
    local ent = NetworkGetEntityFromNetworkId(obj)

    if DoesEntityExist(ent) then
        local shitnum = nil
        for k, v in pairs(shits) do
            if v.obj == obj then
                if v.deleted == true then
                    return 
                end

                shitnum = k
                break
            end
        end

        print(NetworkGetEntityOwner(ent))

        TriggerClientEvent("SAMPLE_K9::SHIT_REMOVAL", NetworkGetEntityOwner(ent), obj)

        TriggerClientEvent("SAMPLE_K9::SHIT_DELETED", -1, obj)
        TriggerClientEvent("SAMPLE_K9::INCREMENT_SHIT_PICKUP_COUNTER", source)

        shits[shitnum].deleted = true
    end
end)