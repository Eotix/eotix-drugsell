ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('eotix-drugsale:addmoney')
AddEventHandler('eotix-drugsale:addmoney', function(money)
    local user = ESX.GetPlayerFromId(source)
    user.addMoney(money)
end)