local truckplate = false
local truckcoords
local inTruck
local missionBlip = nil
local binCoords = false
local maxruns = 0
local runs = 0
local arrived 
local jobBlip
local submitBlip
local QBCore = exports['qb-core']:GetCoreObject()
local submitCoords = vector3(878.93, -2175.58, 30.51)
local clockRoom = vector3(892.36, -2171.8, 32.28)
local doingGarbage = false
local garbageHQBlip = 0
local truckTaken = false

local JobCoords = {
    {x = 114.83280181885, y = -1462.3127441406, z = 29.295083999634},
    {x = -6.0481648445129, y = -1566.2338867188, z = 29.209197998047},
    {x = -1.8858588933945, y = -1729.5538330078, z = 29.300233840942},
    {x = 159.09, y = -1816.69, z = 27.9},
    {x = 358.94696044922, y = -1805.0723876953, z = 28.966590881348},
    {x = 481.36560058594, y = -1274.8297119141, z = 29.64475440979},
    {x = 254.70010375977, y = -985.32482910156, z = 29.196590423584},
    {x = 240.08079528809, y = -826.91204833984, z = 30.018426895142},
    {x = 342.78308105469, y = -1036.4720458984, z = 29.194206237793},
    {x = 462.17517089844, y = -949.51434326172, z = 27.959424972534},
    {x = 317.53698730469, y = -737.95416259766, z = 29.278547286987},
    {x = 410.22503662109, y = -795.30517578125, z = 29.20943069458},
    {x = 398.36038208008, y = -716.35577392578, z = 29.282489776611},
    {x = 443.96984863281, y = -574.33978271484, z = 28.494501113892},
    {x = -1332.53, y = -1198.49, z = 4.62},
    {x = -45.443946838379, y = -191.32261657715, z = 52.161594390869},
    {x = -31.948055267334, y = -93.437454223633, z = 57.249073028564},
    {x = 283.10873413086, y = -164.81878662109, z = 60.060565948486},
    {x = 441.89678955078, y = 125.97653198242, z = 99.887702941895},
}

local Dumpsters = {
    1437508529,
    -1426008804,
    GetHashKey("prop_dumpster_01a"),
    GetHashKey("prop_dumpster_02a"),
    GetHashKey("prop_dumpster_02b"),
    GetHashKey("prop_dumpster_3a"),
    GetHashKey("prop_dumpster_4a"),
    GetHashKey("prop_dumpster_4b"),
    GetHashKey("prop_skip_01a"),
    GetHashKey("prop_skip_02a"),
    GetHashKey("prop_skip_06a"),
    GetHashKey("prop_skip_05a"),
    GetHashKey("prop_skip_03"),
    GetHashKey("prop_skip_10a")
}

Citizen.CreateThread(function()
    garbageHQBlip = AddBlipForCoord(clockRoom)
    SetBlipSprite(garbageHQBlip, 467)
    SetBlipDisplay(garbageHQBlip, 4)
    SetBlipScale(garbageHQBlip, 0.7)
    SetBlipColour(garbageHQBlip, 25)
    SetBlipAsShortRange(garbageHQBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Garbage HQ")
    EndTextCommandSetBlipName(garbageHQBlip)
end)

Citizen.CreateThread(function()     
    while true do 
        Citizen.Wait(5)     
        local inRange = false   
        local playerPed = GetPlayerPed(-1)
        local plyCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(plyCoords, clockRoom, true)
        local vehicleCoords = {x = 876.58, y = -2189.80, z = 29.61, h = 83.85}            
        if distance < 8 then             
            inRange = true               
            if distance < 1.5 then
                ShowHelp("Press ~INPUT_CONTEXT~ to start job for a deposit of ~g~$1500", true, true, 5000)
                if IsControlJustReleased(1,46) then
                    if not truckTaken then                             
                        if not IsAnyVehicleNearPoint(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 5.0) then
                            truckTaken = true
                            local random = math.random(1, #JobCoords)
                            local coordVec = vector3(JobCoords[random].x, JobCoords[random].y, JobCoords[random].z)
                            inTruck = false
                            QBCore.Functions.SpawnVehicle("trash", function(vehicle)
                                truckplate = GetVehicleNumberPlateText(vehicle)
                                truckcoords = GetEntityCoords(vehicle)
                                TriggerEvent("vehiclekeys:client:SetOwner", truckplate) -- Just to make sure the door is unlocked
                                Citizen.CreateThread(function() 
                                    while not inTruck do 
                                        Citizen.Wait(5)
                                        DrawMarker(2, truckcoords.x, truckcoords.y, truckcoords.z + 3.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 10, 255, 10, 150, false, true, 2, false, false, false, false)
                                        if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                                            local truck = GetVehiclePedIsIn(GetPlayerPed(-1),false)
                                            if truck == vehicle then
                                                inTruck = true
                                                Citizen.Wait(1000)
                                                missionStart(coordVec,vehicle)
                                                TriggerEvent("vehiclekeys:client:SetOwner", truckplate)
                                                SetVehicleEngineOn(vehicle, true, true)               
                                                TriggerServerEvent("cad-garbage:addremmoney", "remove", 1500)
                                                QBCore.Functions.Notify("Deposit of $1500 was taken for doing job.")                                    
                                            end
                                        end
                                    end
                                end)
                            end, vehicleCoords, true)        
                        else
                            QBCore.Functions.Notify("There is a vehicle in way") 
                        end                
                    else
                        QBCore.Functions.Notify("You already taken a truck for the job")                            
                    end
                end
            end
        end
        if not inRange then
            Citizen.Wait(1000)
        end
    end
end)

function submit()
    Citizen.CreateThread(function()
        local pressed = false
        local wait = 100
        while true do
            Citizen.Wait(wait)
            local playerPed = GetPlayerPed(-1)
            local plyCoords = GetEntityCoords(playerPed)
            local distance = GetDistanceBetweenCoords(plyCoords,submitCoords, true) 
            if distance < 20 then
                wait = 5
                if IsPedInAnyVehicle(playerPed) then
                    DrawMarker(2, submitCoords+vector3(0.0,0.0,2.0), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 150, false, true, 2, false, false, false, false)
                    local truck = GetVehiclePedIsIn(playerPed, false)
                    local plate = GetVehicleNumberPlateText(truck)
                    if distance < 2.0 then
                        ShowHelp("Press ~INPUT_CONTEXT~ to drop off trash", true, true, 5000)
                        if IsControlJustReleased(1,46) and not pressed then
                            truckTaken = false
                            pressed = true
                            RemoveBlip(submitBlip)
                            if plate == truckplate then                                
                                QBCore.Functions.Progressbar("drop_trash", "Dropping off trash", 5000, false, false, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function()                                    
                                    TriggerServerEvent("cad-garbage:addremmoney", "add", 1500)
                                    QBCore.Functions.Notify("You deposit of $1500 was returned.")                                    
                                    QBCore.Functions.DeleteVehicle(truck)
                                    for i=1,200,1 do 
                                        if DoesEntityExist(truck) then
                                            QBCore.Functions.DeleteVehicle(truck)
                                        else
                                            truckplate = false
                                            truckTaken = false
                                            return
                                        end
                                    end
                                    truckplate = false
                                    Citizen.Wait(1000)
                                    pressed = false 
                                end)                                                                   
                                return
                            else
                                QBCore.Functions.Notify("This is not our vehicle")                                
                                Citizen.Wait(1000)
                                pressed = false
                            end
                            Citizen.Wait(1000)
                            pressed = false
                        end
                    end
                end
            else
                wait = 100
            end            
        end
    end)
end

function missionStart(coordVec,xtruck)
    local vehicle = xtruck
    arrived = false
    missionBlip = AddBlipForCoord(coordVec)
    SetBlipRoute(missionBlip, true)
    SetBlipRouteColour(missionBlip, 25)
    SetBlipColour(missionBlip, 25)
    Citizen.CreateThread(function()
        local wait = 100
        while not arrived do
            Citizen.Wait(wait)
            local tempdist = GetDistanceBetweenCoords(coordVec, GetEntityCoords(GetPlayerPed(-1)),true)
            if  tempdist < 50 then
                wait = 5
                DrawMarker(20, coordVec + vector3(0.0,0.0,3.5), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 120, 0, 200, false, true, 2, false, false, false, false)
                if tempdist < 2 then
                    arrived = true
                    maxruns  = math.random(10,15)
                    Citizen.Wait(1000)
                    SetBlipRoute(missionBlip, false)
                    RemoveBlip(missionBlip)
                    findtrashbins(coordVec,vehicle,0)
                end
            else
                wait = 100
            end
        end
    end)      
end

function findtrashbins(coordVec,xtruck,pickup)
    doingGarbage = true
    local location = coordVec
    local vehicle = xtruck
    local playerPed = GetPlayerPed(-1)
    local boneindex = GetPedBoneIndex(playerPed, 57005)
    runs = pickup

    if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
        RequestAnimDict("anim@heists@narcotics@trash")
    end
    while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
        Citizen.Wait(0)
    end

    if runs < maxruns then
        angle = math.random()*math.pi*2;
        r = math.sqrt(math.random());
        x = coordVec.x + r * math.cos(angle) * 100;     
        y = coordVec.y + r * math.sin(angle) * 100;
        for i = 0, #Dumpsters, 1 do 
            local NewBin = GetClosestObjectOfType(x, y, coordVec.z, 100.0, Dumpsters[i], false)
            if NewBin ~= 0 then
                local dumpCoords = GetEntityCoords(NewBin)
                jobBlip = AddBlipForCoord(dumpCoords)
                SetBlipSprite(jobBlip, 420)
                SetBlipScale (jobBlip, 0.8)
                SetBlipColour(jobBlip, 25)
                while true do
                    Wait(5) 
                    local userDist = GetDistanceBetweenCoords(dumpCoords,GetEntityCoords(GetPlayerPed(-1)),true) 
                    if userDist < 40 then
                        if IsPedInAnyVehicle(playerPed) then
                            ShowHelp("Press ~INPUT_FRONTEND_RRIGHT~ to skip dumpster", true, true, 5000)
                            if IsControlJustReleased(0, 194) then
                                RemoveBlip(jobBlip)
                                findtrashbins(location,vehicle,runs+1)
                            end
                        end
                        DrawMarker(20, dumpCoords + vector3(0.0,0.0,2.5), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 120, 0, 200, false, true, 2, false, false, false, false)
                        if userDist < 2 then
                            ShowHelp("Press ~INPUT_CONTEXT~ to collect trash", true, true, 5000)
                            if IsControlJustReleased(1,46) then
                                local geeky = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
                                AttachEntityToEntity(geeky, playerPed, boneindex, 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
                                TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,49,0,0, 0,0)
                                RemoveBlip(jobBlip)
                                collectedtrash(geeky,vehicle,location,runs)
                                return
                            end
                        end
                    end
                end
                return
            end
        end
    else
        submit()
        doingGarbage = false
        QBCore.Functions.Notify("Job done! Return to HQ")        
        submitBlip = AddBlipForCoord(submitCoords)
        SetBlipColour(submitBlip, 25)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if truckTaken then
            if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                if doingGarbage then
                    DisplayRadar(true)
                else
                    DisplayRadar(false)
                end
            end
        else
            Wait(1000)        
        end
    end
end)

function collectedtrash(geeky,vehicle,location,pickup)
    local wait = 100
    local trashbag = geeky
    local pressed = false
    while true do
        Wait(wait)
        local trunkcoord = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "platelight"))
        local tdistance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),trunkcoord)
        local runs = pickup
        if tdistance < 20 then
            wait = 5
            DrawMarker(20, trunkcoord + vector3(0.0,0.0,0.5), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 120, 0, 200, false, true, 2, false, false, false, false)
            if tdistance < 2 then
                ShowHelp("Press ~INPUT_CONTEXT~ to throw trash", true, true, 5000)
                if IsControlJustReleased(1, 46) and not pressed then
                    pressed = true
                    local dropChance = math.random(1,4)
                    if dropChance > 1 then
                        local randomChance = math.random(1,100)
                        local item = 'metalscrap'
                        if randomChance < 10 then
                            item = 'sandwich'
                        elseif randomChance >= 10 and randomChance <= 20 then
                            item = 'water_bottle'
                        elseif randomChance > 20 and randomChance <= 35 then
                            item = 'iron'
                        elseif randomChance > 35 and randomChance <= 50 then
                            item = 'steel'
                        elseif randomChance > 50 and randomChance < 80 then
                            item = 'aluminum'
                        elseif randomChance == 80 then  
                            item = 'electronickit'
                        elseif randomChance > 80 and randomChance <= 90 then
                            item = 'wire'
                        elseif randomChance > 90 and randomChance <= 95 then
                            item = 'thermite'
                        elseif randomChance > 95 and randomChance < 100 then
                            item = 'trojan_usb'
                        else
                            item = 'plastic'
                        end                        
                        TriggerServerEvent('cad-garbage:reward', item)
                        TriggerServerEvent('cad-garbage:pay')
                    end
                    ClearPedTasksImmediately(GetPlayerPed(-1))
					TaskPlayAnim(GetPlayerPed(-1), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
                    Citizen.Wait(100)
                    DeleteObject(trashbag)
                    Citizen.Wait(1000)
                    ClearPedTasksImmediately(GetPlayerPed(-1))
                    findtrashbins(location,vehicle,runs+1)
                    pressed = false
                    return
                end
            end
        end
    end
end

function ShowHelp(msg)
    BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end

local peds = {
	{type = 4, hash= GetHashKey("s_m_y_garbage"), x = 892.36,  y = -2171.8,  z = 31.28, h = 173.08},
}
Citizen.CreateThread(function()
	for _, item in pairs(peds) do
		RequestModel(item.hash)
		while not HasModelLoaded(item.hash) do
			Wait(1)
		end
		ped =  CreatePed(item.type, item.hash, item.x, item.y, item.z, item.a, false, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		SetPedDiesWhenInjured(ped, false)
		SetEntityHeading(ped, item.h)
		SetPedCanPlayAmbientAnims(ped, true)
		SetPedCanRagdollFromPlayerImpact(ped, false)
		SetEntityInvincible(ped, true)
		FreezeEntityPosition(ped, true)
	end
end)