local K9Model = `a_c_shepherd`
local snek = false

RegisterCommand("iamsnek", function() snek = true end)

local clientShit = nil
local shitting = false

RegisterCommand("shit", function()
    if shitting then return end
    if GetEntityModel(PlayerPedId()) ~= K9Model then return end

    shitting = true

    local dict = "creatures@rottweiler@amb@world_dog_sitting@enter"
    local anim = "enter"

    RequestAnimDict(dict)
    repeat
        Citizen.Wait(0)
    until HasAnimDictLoaded(dict)

    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    Citizen.Wait(GetAnimDuration(dict, anim) * 1000)

    dict = "creatures@rottweiler@amb@world_dog_sitting@idle_a"
    anim = "idle_b"

    RequestAnimDict(dict)
    repeat
        Citizen.Wait(0)
    until HasAnimDictLoaded(dict)

    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)

    TriggerServerEvent("SAMPLE_K9::SHIT", GetEntityCoords(PlayerPedId()))

    while clientShit == nil do
        Citizen.Wait(0)
    end
    clientShit = nil

    dict = "creatures@rottweiler@amb@world_dog_sitting@exit"
    anim = "exit"

    RequestAnimDict(dict)
    repeat
        Citizen.Wait(0)
    until HasAnimDictLoaded(dict)

    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
    Citizen.Wait(GetAnimDuration(dict, anim) * 1000)
    ClearPedTasksImmediately(PlayerPedId())

    shitting = false
end)

local shits = {}
RegisterNetEvent("SAMPLE_K9::DOG_SHIT")
AddEventHandler("SAMPLE_K9::DOG_SHIT", function(i, shit)
    shit = NetworkGetEntityFromNetworkId(shit)

    shits[i] = shit
    clientShit = shit

    PlaceObjectOnGroundProperly(shit)
end)

RegisterNetEvent("SAMPLE_K9::SHIT_DELETED")
AddEventHandler("SAMPLE_K9::SHIT_DELETED", function(shit)
    shits[shit] = nil
end)

RegisterNetEvent("SAMPLE_K9::INCREMENT_SHIT_PICKUP_COUNTER")
AddEventHandler("SAMPLE_K9::INCREMENT_SHIT_PICKUP_COUNTER", function()
    SetResourceKvpInt("SAMPLE_K9_SHIT_PICKUP_COUNTER", GetResourceKvpInt("SAMPLE_K9_SHIT_PICKUP_COUNTER") + 1)

    SetNotificationTextEntry "STRING"
    AddTextComponentSubstringPlayerName("You have picked up "..GetResourceKvpInt("SAMPLE_K9_SHIT_PICKUP_COUNTER").." shits.")
    DrawNotification(false, true)
end)

Citizen.CreateThread(function()
    AddTextEntry("PROMPT_PICK_UP_DOG_SHIT", "Press ~INPUT_CONTEXT~ to pick up the dog shit.")

    repeat
        for k, shit in pairs(shits) do
            if GetEntityModel(PlayerPedId()) ~= K9Model and DoesEntityExist(shit) then
                local pc = GetEntityCoords(PlayerPedId())
                local sc = GetEntityCoords(shit)

                if #(pc - sc) <= 2.0 then
                    DisplayHelpTextThisFrame("PROMPT_PICK_UP_DOG_SHIT", false)

                    if IsControlJustPressed(1, 51) then
                        TriggerServerEvent("SAMPLE_K9::DELETE_SHIT", NetworkGetNetworkIdFromEntity(shit))
                    end
                end
            end
        end

        Citizen.Wait(0)
    until false
end)

RegisterNetEvent("SAMPLE_K9::SHIT_REMOVAL")
AddEventHandler("SAMPLE_K9::SHIT_REMOVAL", function(shit)
    DeleteObject(NetworkGetEntityFromNetworkId(shit))
end)

function CheckK9()
    local p = PlayerPedId()

    if GetEntityModel(p) == K9Model then
        GiveWeaponToPed(p, GetHashKey "WEAPON_ANIMAL", 200, true, true)

        if GetInteriorFromEntity(p) ~= 0 then
            SetPedMoveRateOverride(p, 10.0)
        else
            SetPedMoveRateOverride(p, 2.25)
        end
    else
        SetPedMoveRateOverride(p, 1.0)
    end
end

Citizen.CreateThread(function()
    repeat
        CheckK9()
        Citizen.Wait(100)
    until false
end)

Citizen.CreateThread(function()
    local vehicle = nil

    repeat 
        local p = PlayerPedId()
        local av = IsPedInAnyVehicle(p)

        if GetEntityModel(p) == K9Model then
            if vehicle and not av then
                SetPedCanRagdoll(p, false)

                Citizen.Wait(5000)

                SetPedCanRagdoll(p, true)

                vehicle = nil
            elseif av then
                vehicle = GetVehiclePedIsIn(p, false)
            end
        elseif vehicle ~= nil then
            vehicle = nil
        end

        Citizen.Wait(0)
    until false
end)

-- TODO: Make /pet command to pet chop
-- USe for player: creatures@rottweiler@tricks@petting_franklin
-- USe for dog: creatures@rottweiler@tricks@petting_chop
-- Can also use creatures@rottweiler@melee@melee for dog hug

Citizen.CreateThread(function()
    local _menuPool = NativeUI.CreatePool()
    local mainMenu = NativeUI.CreateMenu("K9", "bork bork")
    _menuPool:Add(mainMenu)

    local animations2 = {
        {
            name = "Lay Down",
            loop = {
                dictionary = "creatures@rottweiler@amb@sleep_in_kennel@",
                animation = "sleep_in_kennel",
            },
            exit = {
                dictionary = "creatures@rottweiler@amb@sleep_in_kennel@",
                animation = "exit_kennel",
            }
        },
        {
            name = "Bark",
            enter = {
                dictionary = "creatures@rottweiler@amb@world_dog_barking@enter",
                animation = "enter",
            },
            loop = {
                dictionary = "creatures@rottweiler@amb@world_dog_barking@idle_a",
                animation = "idle_a"
            },
            exit = {
                dictionary = "creatures@rottweiler@amb@world_dog_barking@exit",
                animation = "exit",
            }
        },
        {
            name = "Sit",
            enter = {
                dictionary = "creatures@rottweiler@amb@world_dog_sitting@enter",
                animation = "enter",
            },
            loop = {
                dictionary = "creatures@rottweiler@amb@world_dog_sitting@idle_a",
                animation = "idle_b",
            },
            exit = {
                dictionary = "creatures@rottweiler@amb@world_dog_sitting@exit",
                animation = "exit",
            }
        },
        {
            name = "Indicate Ahead",
            loop = {
                dictionary = "creatures@rottweiler@indication@", 
                animation = "indicate_ahead"
            }
        },
        {
            name = "Indicate High",
            loop = {
                dictionary = "creatures@rottweiler@indication@", 
                animation = "indicate_high"
            }
        },
        {
            name = "Indicate Low",
            loop = {
                dictionary = "creatures@rottweiler@indication@", 
                animation = "indicate_low"
            }
        },
        {
            name = "Taunt",
            loop = {
                dictionary = "creatures@rottweiler@melee@streamed_taunts@",
                 animation = {"taunt_01", "taunt_02" }
            }
        },
        {
            name = "Lift Paw",
            enter = {
                dictionary = "creatures@rottweiler@tricks@",
                animation = "paw_right_enter"
            },
            loop = {
                dictionary = "creatures@rottweiler@tricks@",
                animation = "paw_right_loop"
            },
            exit = {
                dictionary = "creatures@rottweiler@tricks@",
                animation = "paw_right_exit"
            },
        },
        {
            name = "Stand / Beg",
            enter = {
                dictionary = "creatures@rottweiler@tricks@",
                animation = "beg_enter"
            },
            loop = {
                dictionary = "creatures@rottweiler@tricks@",
                animation = "beg_loop"
            },
            exit = {
                dictionary = "creatures@rottweiler@tricks@",
                animation = "beg_exit"
            },
        }
    }

    function FindAnimWithName(name)
        for k, v in pairs(animations2) do
            if v.name == name then
                return v
            end
        end
    end

    local emotePlaying = false

    local function CancelCurrentEmote(i)
        local anim = FindAnimWithName(emotePlaying)
        if anim and anim.exit then
            local v = anim.exit

            RequestAnimDict(v.dictionary)
            repeat
                Citizen.Wait(0)
            until HasAnimDictLoaded(v.dictionary)

            --ClearPedTasksImmediately(PlayerPedId())
            TaskPlayAnim(PlayerPedId(), v.dictionary, v.animation, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
            Citizen.Wait(GetAnimDuration(v.dictionary, v.animation) * 1000)

            ClearPedTasksImmediately(PlayerPedId())
        else
            ClearPedTasksImmediately(PlayerPedId())
        end
        
        emotePlaying = false
    end

    local animationmenu = _menuPool:AddSubMenu(mainMenu, "Animations")
    local doormenu = _menuPool:AddSubMenu(mainMenu, "Door Popper")

    local setVehicle = NativeUI.CreateItem("Set Vehicle", "Set the vehicle that the door popper will use")
    doormenu:AddItem(setVehicle)

    local openDoor = NativeUI.CreateItem("Open Door", "Opens the door that has your K9 inside.")
    doormenu:AddItem(openDoor)

    local closeDoor = NativeUI.CreateItem("Close Door", "Close both rear doors on your vehicle.")
    doormenu:AddItem(closeDoor)
    
    local doorPopperVehicle = nil
    doormenu.OnItemSelect = function(sender, item, index)
        if item == setVehicle then
            if IsPedInAnyVehicle(PlayerPedId()) then
                doorPopperVehicle = GetVehiclePedIsIn(PlayerPedId(), true)
            end
        elseif item == openDoor then
            if doorPopperVehicle then
                local door = DoesEntityExist(GetPedInVehicleSeat(doorPopperVehicle, 2)) and 3 or 2

                SetVehicleDoorOpen(doorPopperVehicle, door, false, false)
                TriggerServerEvent("SAMPLE_K9::PLAY_DOOR_SOUND", VehToNet(doorPopperVehicle))
            end
        elseif item == closeDoor then
            SetVehicleDoorShut(doorPopperVehicle, 2, false)
            SetVehicleDoorShut(doorPopperVehicle, 3, false)
            TriggerServerEvent("SAMPLE_K9::PLAY_DOOR_SOUND", VehToNet(doorPopperVehicle))
        end
    end

    local animItems = {}
    for k, v in pairs(animations2) do
        local item = NativeUI.CreateItem(v.name, "MAKE YOUR DOG "..v.name:upper()..".")
        animationmenu:AddItem(item)

        table.insert(animItems, { item = item, animation = animations2[k] })
    end

    local cancelEmote = NativeUI.CreateItem("Cancel Emote", "Cancel your current emote.")
    local cancelNow = NativeUI.CreateItem("Cancel Emote Immediately", "Cancel your current emote right away.")
    animationmenu:AddItem(cancelEmote)
    animationmenu:AddItem(cancelNow)

    animationmenu.OnItemSelect = function(sender, item, index)
        for k, v in pairs(animItems) do
            if v.item == item then
                if emotePlaying then
                    CancelCurrentEmote()
                end

                emotePlaying = v.animation.name

                if v.animation.enter then
                    RequestAnimDict(v.animation.enter.dictionary)
                    repeat
                        Citizen.Wait(0)
                    until HasAnimDictLoaded(v.animation.enter.dictionary)

                    TaskPlayAnim(PlayerPedId(), v.animation.enter.dictionary, v.animation.enter.animation, 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                    Citizen.Wait(GetAnimDuration(v.animation.enter.dictionary, v.animation.enter.animation) * 1000)
                end

                RequestAnimDict(v.animation.loop.dictionary)
                repeat
                    Citizen.Wait(0)
                until HasAnimDictLoaded(v.animation.loop.dictionary)

                local anim = v.animation.loop.animation

                if type(anim) == "table" then
                    anim = anim[math.random(1, #anim)]
                end
    
                TaskPlayAnim(PlayerPedId(), v.animation.loop.dictionary, anim, 8.0, 0.0, -1, 1, 0, 0, 0, 0)

                return
            end
        end

        if item == cancelEmote then
            CancelCurrentEmote(true)
            emotePlaying = false
        elseif item == cancelNow then
            ClearPedTasksImmediately(PlayerPedId())
            emotePlaying = false
        end
    end

    local fixk9 = NativeUI.CreateItem("Fix K9", "Fix your K9 ped if you are unable to bite.")
    local cancelEmote = NativeUI.CreateItem("Cancel Emote", "Cancel your current emote.")
    local cancelNow = NativeUI.CreateItem("Cancel Emote Immediately", "Cancel your current emote right away.")
    local shit = NativeUI.CreateItem("Shit", "Take a shit.")
    mainMenu:AddItem(fixk9)
    mainMenu:AddItem(cancelEmote)
    mainMenu:AddItem(cancelNow)
    mainMenu:AddItem(shit)

    mainMenu.OnItemSelect = function(sender, item, index)
        if item == fixk9 then
            ExecuteCommand("fixk9")
        elseif item == cancelEmote then
            CancelCurrentEmote(true)
        elseif item == cancelNow then
            ClearPedTasksImmediately(PlayerPedId())
            emotePlaying = false
        elseif item == shit then
            ExecuteCommand("shit")
        end
    end

    _menuPool:RefreshIndex()

    RegisterCommand("+openk9menu", function()
        --if GetEntityModel(PlayerPedId()) ~= K9Model then return end
        mainMenu:Visible(not mainMenu:Visible())
    end)
    RegisterCommand("-openk9menu", function() end)
    RegisterKeyMapping("+openk9menu", "(Menu) Open K9 Menu", "keyboard", "F4")

    repeat
        _menuPool:ProcessMenus()

        if IsControlJustPressed(1, 73) and emotePlaying then 
            CancelCurrentEmote()
        end

        Citizen.Wait(0)
    until false
end)

Citizen.CreateThread(function()
    local SEAT_DRIVER = -1;
    local SEAT_PASSENGER = 0;
    local SEAT_LEFT_BACK = 1;
    local SEAT_RIGHT_BACK = 2;
    local SEAT_OUTSIDE_LEFT = 3;
    local SEAT_OUTSIDE_RIGHT = 4;

    local DOOR_LEFT_BACK = 2;
    local DOOR_RIGHT_BACK = 3;

    local iVehicle; -- iLocal_78
    local sVehicleSeat;
    local sAnimDict; -- sLocal_371
    local iDoor; -- iLocal_94
    local iSeat;
    local iScene; -- iLocal_67
    local bInVehicle;

    function func_125(entity)
        return DoesEntityExist(entity) and IsEntityDead(entity)
    end

    function func_79()
        if func_125(iVehicle) then
            local hLayoutHash = GetVehicleLayoutHash(iVehicle)

            if hLayoutHash == 1939145032 then
                sAnimDict = "creatures@rottweiler@in_vehicle@van"
            elseif hLayoutHash == 2033852426 then
                sAnimDict = "creatures@rottweiler@in_vehicle@low_car"
            elseif hLayoutHash == 1663892749 then
                sAnimDict = "creatures@rottweiler@in_vehicle@4x4"
            else
                sAnimDict = "creatures@rottweiler@in_vehicle@std_car"
            end
            if GetEntityModel(iVehicle) == GetHashKey("BRAWLER") then
                sAnimDict = "creatures@rottweiler@in_vehicle@4x4"
            end
        end
    end

    function IsK9()
        return GetEntityModel(PlayerPedId()) == K9Model
    end

    function SetCorrectDoorAndSeat()
        local seat = GetSeatPedIsTryingToEnter()

        if seat == -3 then
            seat = SEAT_DRIVER
        end

        if seat == SEAT_DRIVER then
            iDoor = DOOR_LEFT_BACK
            iSeat = SEAT_LEFT_BACK
        elseif seat == SEAT_PASSENGER then
            iDoor = DOOR_RIGHT_BACK
            iSeat = SEAT_RIGHT_BACK
        elseif seat == SEAT_LEFT_BACK then
            iDoor = DOOR_LEFT_BACK
        elseif seat == SEAT_RIGHT_BACK then
            iDoor = DOOR_RIGHT_BACK
        elseif seat == SEAT_OUTSIDE_LEFT then
            iDoor = DOOR_LEFT_BACK
            iSeat = SEAT_LEFT_BACK
        elseif seat == SEAT_OUTSIDE_RIGHT then
            iDoor = DOOR_RIGHT_BACK
            iSeat = SEAT_RIGHT_BACK
        end

        if iSeat == SEAT_LEFT_BACK then
            sVehicleSeat = "seat_dside_r"
        elseif iSeat == SEAT_RIGHT_BACK then
            sVehicleSeat = "seat_pside_r"
        end
    end

    function __EntryFunction__()
        sAnimDict = "creatures@rottweiler@in_vehicle@std_car"

        while true do
            if IsK9() then
                if not bInVehicle then
                    iVehicle = GetVehiclePedIsTryingToEnter(PlayerPedId())

                    if DoesEntityExist(iVehicle) then
                        SetCorrectDoorAndSeat()

                        func_79()
                        RequestAnimDict(sAnimDict)
                        repeat Citizen.Wait(0) until HasAnimDictLoaded(sAnimDict)

                        if not IsVehicleDoorDamaged(iVehicle, iDoor) and GetVehicleDoorAngleRatio(iVehicle, iDoor) < 0.95 then
                            TriggerServerEvent("SAMPLE_K9::PLAY_DOOR_SOUND", VehToNet(iVehicle))
                            SetVehicleDoorOpen(iVehicle, iDoor, false, false)
                        end

                        local iCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                        AttachCamToVehicleBone(iCam, iVehicle, sVehicleSeat, true, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true)
                        SetCamActive(iCam, true)

                        ClearPedTasksImmediately(PlayerPedId())

                        -- AttachEntityToEntity()

                        -- For some reason this isn't synced across clients, fuck rockstar
                        -- iScene = CreateSynchronizedScene(0.0, 0.0, 0.0, 0.0, 0.0, iDoor == DOOR_LEFT_BACK and -180.0 or 0.0, 2)
                        -- AttachSynchronizedSceneToEntity(iScene, iVehicle, GetEntityBoneIndexByName(iVehicle, sVehicleSeat))
                        -- TaskSynchronizedScene(PlayerPedId(), iScene, sAnimDict, "get_in", 1000.0, -8.0, 4, 0, 1148846080, 0)
                        --Citizen.InvokeNative(0x2208438012482A1A, PlayerPedId(), 0, 0)

                        if not snek then
                            local sceneCoords = vector3(0, -1.0, 0)
                            local sceneRot = vector3(0, 0, iDoor == DOOR_LEFT_BACK and -180.0 or 0.0)

                            local sceneId = NetworkCreateSynchronisedScene(
                                sceneCoords,
                                sceneRot,
                                2, true, false, 1065353216, 0, 1065353216
                            )

                            NetworkAttachSynchronisedSceneToEntity(
                                sceneId, 
                                iVehicle, 
                                GetEntityBoneIndexByName(iVehicle, sAnimDict)
                            )

                            NetworkAddPedToSynchronisedScene(PlayerPedId(), sceneId,
                                sAnimDict, "get_in",
                                1.5, -1.5, 262, 0, 1148846080, 0
                            )

                            NetworkStartSynchronisedScene(sceneId)

                            Citizen.Wait(GetAnimDuration(sAnimDict, "get_in") * 1000)

                            NetworkStopSynchronisedScene(sceneId)
                            NetworkUnlinkNetworkedSynchronisedScene(sceneId)
                        end

                        SetCamActive(iCam, false)
                        DestroyCam(iCam, true)


                        SetVehicleDoorShut(iVehicle, iDoor, false)
                        TriggerServerEvent("SAMPLE_K9::PLAY_DOOR_SOUND", VehToNet(iVehicle), false)
                        SetPedIntoVehicle(PlayerPedId(), iVehicle, iSeat)

                        bInVehicle = true
                    end
                else
                    if IsControlJustPressed(1, 75) or IsDisabledControlJustPressed(1, 75) then
                        if DoesEntityExist(iVehicle) then    
                            func_79()
                            RequestAnimDict(sAnimDict)
                            repeat Citizen.Wait(0) until HasAnimDictLoaded(sAnimDict)
    
                            if not IsVehicleDoorDamaged(iVehicle, iDoor) and GetVehicleDoorAngleRatio(iVehicle, iDoor) < 0.95 then
                                TriggerServerEvent("SAMPLE_K9::PLAY_DOOR_SOUND", VehToNet(iVehicle), true)
                                SetVehicleDoorOpen(iVehicle, iDoor, false, false)
                            end
    
                            local iCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                            AttachCamToVehicleBone(iCam, iVehicle, sVehicleSeat, true, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true)
                            SetCamActive(iCam, true)

                            ClearPedTasksImmediately(PlayerPedId())

                            -- For some reason this isn't synced across clients, fuck rockstar
                            -- iScene = CreateSynchronizedScene(0.0, 0.25, -0.25, 0.0, 0.0, iDoor == DOOR_LEFT_BACK and -180.0 or 0.0, 2)
                            -- AttachSynchronizedSceneToEntity(iScene, iVehicle, GetEntityBoneIndexByName(iVehicle, sVehicleSeat))
                            -- TaskSynchronizedScene(PlayerPedId(), iScene, sAnimDict, "get_out", 1000.0, -8.0, 4, 0, 1148846080, 0)
                            -- Citizen.InvokeNative(0x2208438012482A1A, PlayerPedId(), 0, 0)

                            if not snek then
                                local sceneCoords = vector3(-0.50, -0.75, -0.25)
                                local sceneRot = vector3(0, 0, iDoor == DOOR_LEFT_BACK and -180.0 or 0.0)

                                local sceneId = NetworkCreateSynchronisedScene(
                                    sceneCoords,
                                    sceneRot,
                                    2, true, false, 1065353216, 0, 1065353216
                                )

                                NetworkAttachSynchronisedSceneToEntity(
                                    sceneId, 
                                    iVehicle, 
                                    GetEntityBoneIndexByName(iVehicle, sAnimDict)
                                )

                                NetworkAddPedToSynchronisedScene(PlayerPedId(), sceneId,
                                    sAnimDict, "get_out",
                                    1.5, -1.5, 262, 0, 1148846080, 0
                                )

                                NetworkStartSynchronisedScene(sceneId)

                                Citizen.Wait(GetAnimDuration(sAnimDict, "get_out") * 1000)
        
                                SetVehicleDoorShut(iVehicle, iDoor, false)

                                ClearPedTasksImmediately(PlayerPedId())

                                NetworkStopSynchronisedScene(sceneId)
                                NetworkUnlinkNetworkedSynchronisedScene(sceneId)
                            end

                            SetCamActive(iCam, false)
                            DestroyCam(iCam, true)

                            bInVehicle = false
                        end
                    end
                end
            end

            Citizen.Wait(0)
        end
    end

    __EntryFunction__()
end)

RegisterNetEvent("SAMPLE_K9::PLAY_DOOR_SOUND_CLIENT")
AddEventHandler("SAMPLE_K9::PLAY_DOOR_SOUND_CLIENT", function(veh, leaving)
    veh = NetToVeh(veh)
    if DoesEntityExist(veh) then
        PlaySoundFromEntity(-1, "Remote_Control_Fob", veh, "PI_Menu_Sounds", false, 0)

        if leaving then
            Citizen.Wait(100)
            PlaySoundFromEntity(-1, "Remote_Control_Fob", veh, "PI_Menu_Sounds", false, 0)
        end
    end
end)

Citizen.CreateThread(function()
    local replacementModel = `mp_m_freemode_01`

    RegisterCommand("fixk9", function()
        local variations = {}

        for i = 0, 11 do
            if GetNumberOfPedDrawableVariations(PlayerPedId(), i) > 0 then
                variations[i] = {}
                variations[i].drawable = GetPedDrawableVariation(PlayerPedId(), i)
                variations[i].texture = GetPedTextureVariation(PlayerPedId(), i, variations[i].drawable) or 0
            end
        end

        RequestModel(replacementModel)
        repeat
            Citizen.Wait(0)
        until HasModelLoaded(replacementModel)

        SetPlayerModel(PlayerId(), replacementModel)

        RequestModel(K9Model)
        repeat
            Citizen.Wait(0)
        until HasModelLoaded(K9Model)

        SetPlayerModel(PlayerId(), K9Model)

        Citizen.Wait(100)

        for k, v in pairs(variations) do
            SetPedComponentVariation(PlayerPedId(), k, v.drawable, v.texture, 0)
        end
    end)
end)