local ESX = exports['es_extended']:getSharedObject()

local function hasJobPerms(playerJob)
    print(playerJob)
    for i=1, #Config.jobs do
        if playerJob.name == Config.jobs[i].job and playerJob.grade >= Config.jobs[i].minGrade then
            return true
        end
    end
    return false
end

local function hasExpired(startTime)
    local timeElapsed = os.time() - startTime
    if timeElapsed > Config.expireTime * 60 * 60 then
        return true
    end
end

ESX.RegisterUsableItem("prescriptionpad", function(source, item, info)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
	--if not Player.Functions.GetItemBySlot(item.slot) then return end
    
    if not hasJobPerms(Player.job) then
        TriggerClientEvent("eth-prescription_cl:Notify", src, "You don't have the right job or high enough grade to do this", "error")
        return
    end
    local playerName = Config.namePrefix .. Player.getName()
    TriggerClientEvent("eth-prescription_cl:usePad", src, playerName, "123456789", os.time())
end)

ESX.RegisterUsableItem("prescription", function(source, item, info)
    local Player = ESX.GetPlayerFromId(source)
	--if not Player.Functions.GetItemBySlot(item.slot) then return end
    if not info.metadata then return end
    
    if hasExpired(info.metadata.unixTime) then
        TriggerClientEvent("eth-prescription_cl:Notify", source, "This prescription is expired and has been removed", "error")
        exports.ox_inventory:RemoveItem(src, 'prescriptionpad', 1)
        return
    end

    for i=1, #Config.medList do
        if info.metadata.medication == Config.medList[i].item then
            info.metadata.medication = Config.medList[i].label
            break
        end
    end

    TriggerClientEvent("eth-prescription_cl:usePrescription", source, info.metadata)
end)

-- for i=1, #Config.medList do
--     ESX.RegisterUsableItem(Config.medList[i].item, function(source, item)
--         local Player = ESX.GetPlayerFromId(source)
--         if not Player.Functions.GetItemBySlot(item.slot) or not item.info.quantity then return end
--         local playerInventory = ESX.GetPlayerFromId(source).PlayerData.items

--         if item.info.quantity <= 1 then
--             Player.Functions.RemoveItem(Config.medList[i].item, 1, item.slot)
--             TriggerClientEvent("eth-prescription_cl:Notify", source, "You take the last dose of your medication", "success")
--         else
--             local newDosage = item.info.quantity - 1
--             playerInventory[item.slot].info.quantity = newDosage 
--             Player.Functions.SetInventory(playerInventory)
--             TriggerClientEvent("eth-prescription_cl:Notify", source, "You take your medication and have " .. newDosage .. " dose(s) left", "success")
--         end
--     end)
-- end

ESX.RegisterServerCallback("eth-prescription_sv:createPrescription", function(source, cb, data)
    local src = source
    local Player = ESX.GetPlayerFromId(source)

    if not hasJobPerms(Player.job) then
        TriggerClientEvent("eth-prescription_cl:Notify", source, "You don't have the right job to do this", "error")
        cb(false)
        return
    end

    for k, v in pairs(data) do
        if v == "" and k ~= "notes" then
            TriggerClientEvent("eth-prescription_cl:Notify", source, "Missing form data", "error")
            cb(false)
            return
        end
    end

    if tonumber(data.quantity) < 1 or tonumber(data.quantity) > Config.maxQuantity then
        TriggerClientEvent("eth-prescription_cl:Notify", source, "Invalid quantity. Number must be greater than zero and less than "..Config.maxQuantity, "error")
        cb(false)
        return
    end

    data.quantity = math.floor(tonumber(data.quantity))

    exports.ox_inventory:RemoveItem(src, 'prescriptionpad', 1)
    local docName = Config.namePrefix .. Player.getName()
    local itemName = nil
    for i=1, #Config.medList do
        if data.medication == Config.medList[i].item then
            itemName = Config.medList[i].label
            break
        end
    end
    local info = {
        patient = data.patient,
        medication = itemName,
        quantity = data.quantity,
        invitem = data.medication,
        doctor = data.signature,
        notes = data.notes,
        unixTime = os.time()
    }
	exports.ox_inventory:AddItem(src, 'prescription', 1, info)
    cb(true)
end)


RegisterNetEvent("eth-prescription_sv:getMeds", function()
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local prescriptions = Player.Functions.GetItemsByName("prescription")
    local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
   
    if #prescriptions == 0 then 
        TriggerClientEvent("eth-prescription_cl:Notify", src, "You don't have any prescriptions", "error")
        return
    end

    local invalidPrescript = false
    local expiredPrescript = false

    for i=1, #prescriptions do
        local metadata = prescriptions[i].info.formInfo

        if hasExpired(prescriptions[i].info.unixTime) then
            Player.Functions.RemoveItem("prescription", 1, prescriptions[i].slot)
            expiredPrescript = true
        elseif metadata.patient ~= playerName then
            invalidPrescript = true
        else
            if Player.Functions.RemoveItem("prescription", 1, prescriptions[i].slot) then
                if Player.Functions.AddItem(metadata.medication, 1, nil, {quantity = tonumber(metadata.quantity)}) then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[metadata.medication], "add")
                end
            end 
        end
    end

    if invalidPrescript then
        TriggerClientEvent("eth-prescription_cl:Notify", src, "One or more of these prescriptions don't have your name on it", "error")
    end

    if expiredPrescript then
        TriggerClientEvent("eth-prescription_cl:Notify", src, "Removed one or more expired prescriptions", "error")
    end
end)