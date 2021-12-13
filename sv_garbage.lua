local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('cad-garbage:pay')
AddEventHandler('cad-garbage:pay', function(jobStatus)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    if xPlayer ~= nil then
        local randomMoney = math.random(25,40)
        xPlayer.Functions.AddMoney("cash", randomMoney, "garbage-pay")    
        TriggerClientEvent("QBCore:Notify", _source, "You got $"..randomMoney)        
    end
end)

RegisterNetEvent('cad-garbage:addremmoney')
AddEventHandler('cad-garbage:addremmoney', function(value, amount)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    if value == "add" then
        xPlayer.Functions.AddMoney("cash", amount)            
    elseif value == "remove" then
        xPlayer.Functions.RemoveMoney("cash", amount)    
    end
end)

RegisterNetEvent('cad-garbage:reward')
AddEventHandler('cad-garbage:reward', function(item)    
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local getItem = math.random(2, 4)
    local chance = math.random(1, 100)
    if xPlayer ~= nil then                        
        xPlayer.Functions.AddItem(item, getItem)
        TriggerClientEvent("inventory:client:ItemBox", _source, QBCore.Shared.Items[item], "add")                      
        if chance >= 49 and chance <= 51 then
            xPlayer.Functions.AddItem("lockpick", 1)
            TriggerClientEvent("inventory:client:ItemBox", _source, QBCore.Shared.Items["lockpick"], "add") 
        elseif chance == 1 then
            xPlayer.Functions.AddItem("cokebaggy", 1)
            TriggerClientEvent("inventory:client:ItemBox", _source, QBCore.Shared.Items["cokebaggy"], "add") 
        end
    end
end)