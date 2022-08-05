local attachedPropPerm
local SoldDrugs = false

CreateThread(function()
    exports['qtarget']:Ped({
        options = {
            {
                event = "eotix-drugsale:menu",
                icon = "fas fa-handshake",
                label = "Offer drugs",
            },
        },
        distance = 2
    })
end)

RegisterNetEvent('eotix-drugsale:menu', function()
    if not SoldDrugs then
        local menuTable = { { id = 1, header = 'SELL DRUGS', txt = "", }, }
        local methqtty = exports['np-inventory']:getQuantity('methlabproduct')
        local jointqtty = exports['np-inventory']:getQuantity('joint')
        local cokeqtty = exports['np-inventory']:getQuantity('1gcocaine')
        local cokeprice = cokeqtty * math.random(180, 240)
        local methprice = methqtty * math.random(80, 120)
        local jointprice = jointqtty * math.random(120, 200)
        if methqtty > 0 then    
            table.insert(menuTable, { id = 2, header = 'Sell '.. methqtty ..'x Meth Pack for ' .. methprice ..'$', txt = "", params = { event = "eotix-drugsale:sellDrugsAnim", args = { item = "methlabproduct", price = methprice }, }, })
        end
        if jointqtty > 0 then    
            table.insert(menuTable, { id = 3, header = 'Sell '.. jointqtty ..'x Joints for ' .. jointprice ..'$', txt = "", params = { event = "eotix-drugsale:sellDrugsAnim", args = { item = "joint", price = jointprice }, }, })
        end
        if cokeqtty > 0 then    
            table.insert(menuTable, { id = 4, header = 'Sell '.. cokeqtty ..'x Coke Pack for ' .. cokeprice ..'$', txt = "", params = { event = "eotix-drugsale:sellDrugsAnim", args = { item = "1gcocaine", price = cokeprice }, }, })
        end
        if methqtty < 1 and jointqtty < 1 and cokeqtty < 1 then
            table.insert(menuTable, { id = 5, header = 'You dont have any drugs!', txt = "", params = { event = "fakeevent", args = { }, }, })
        else
            table.insert(menuTable, { id = 6, header = 'Get rid of the buyer!', txt = "", params = { event = "eotix-drugsale:GetBuyertAway", args = { }, }, })
        end
        TriggerEvent('nh-context:sendMenu', menuTable)
    else
        exports['mythic_notify']:DoHudText('error', 'YOU CAN OFFER IN 2 MINUTES')
    end
end)

GetPedInFront = function()
    local player = PlayerId()
    local plyPed = GetPlayerPed(player)
    local plyPos = GetEntityCoords(plyPed, false)
    local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
    local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
    local _, _, _, _, ped = GetShapeTestResult(rayHandle)
    return ped
end

MakeEntityFaceEntity = function(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading( entity1, heading )
end

RegisterNetEvent('eotix-drugsale:sellDrugsAnim', function(data)
    local ent = GetPedInFront()
    local plyPed = PlayerPedId()
    if ent ~= 0 and ent ~= nil then
        local bone = GetPedBoneIndex(ent, 28422)
        local boneply = GetPedBoneIndex(plyPed, 28422)
	    RequestModel('prop_security_case_01')
	    while not HasModelLoaded('prop_security_case_01') do
	    	Wait(100)
	    end
        FreezeEntityPosition(ent, true)
        FreezeEntityPosition(plyPed, true)
        attachedPropPerm = CreateObject('prop_security_case_01', 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(attachedPropPerm, plyPed, boneply, 0.08, 0.0, 0.0, 315.0, 288.0, 0.0, 1, 1, 0, 0, 2, 1)
        loadAnimDict("mp_common")
        MakeEntityFaceEntity(plyPed, ent)
        MakeEntityFaceEntity(ent, plyPed)
        TaskPlayAnim(plyPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 1, false, false, false)
        TaskPlayAnim(ent, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
        Wait(1000)
        DeleteEntity(attachedPropPerm)
        attachedPropPerm = nil
        Wait(100)
        attachedPropPerm = CreateObject('prop_security_case_01', 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(attachedPropPerm, ent, bone, 0.08, 0.0, 0.0, 315.0, 288.0, 0.0, 1, 1, 0, 0, 2, 1)
        Wait(600)
        FreezeEntityPosition(ent, false)
        FreezeEntityPosition(plyPed, false)
        ClearPedTasks(plyPed)
        ClearPedTasks(ent)
        TriggerEvent('eotix-drugsale:sellDrugs', data.item, data.price)
        Wait(6000)
        DeleteEntity(attachedPropPerm)
        attachedPropPerm = nil
    end
end)

RegisterNetEvent('eotix-drugsale:sellDrugs', function(item, price)
    local qtty =  exports['np-inventory']:getQuantity(item)
    TriggerEvent("inventory:removeItem", item, qtty)
    TriggerServerEvent('eotix-drugsale:addmoney', price)
    exports['mythic_notify']:DoHudText('inform', 'YOU RECEIVED ' .. price .. '$')
    TriggerEvent('gambinos:stres:levelset',false, true, 5) -- Stress Event
    exports['mythic_notify']:DoHudText('inform', 'YOUR STRESS IS UP')
    SoldDrugs = true
    Wait(120000)
    SoldDrugs = false
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

RegisterNetEvent('eotix-drugsale:GetBuyertAway', function()
    SoldDrugs = true
    Wait(120000)
    SoldDrugs = false
end)
