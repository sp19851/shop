local keys = { 
    ['G'] = 0x760A9C6F, ['S'] = 0xD27782E3, ['W'] = 0x8FD015D8, ['H'] = 0x24978A28, ['G'] = 0x5415BE48, ["ENTER"] = 0xC7B5340A,
    ['E'] = 0xDFF812F9,["BACKSPACE"] = 0x156F7119 
}

local inUIPage = false


local OpenStores
local CloseStores

local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local PromptGroup2 = GetRandomIntInRange(0, 0xffffff)

---------------- BLIPS ---------------------
local function AddBlip(Store)
    if Config.Stores[Store].blipAllowed then
        Config.Stores[Store].BlipHandle = N_0x554d9d53f696d002(1664425300, Config.Stores[Store].x,
            Config.Stores[Store].y, Config.Stores[Store].z)
        SetBlipSprite(Config.Stores[Store].BlipHandle, Config.Stores[Store].sprite, 1)
        SetBlipScale(Config.Stores[Store].BlipHandle, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, Config.Stores[Store].BlipHandle, Config.Stores[Store].BlipName)
    end
end

---------------- NPC ---------------------
local function LoadModel(model)
    local model = GetHashKey(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
end

local function SpawnNPC(Store)
    local v = Config.Stores[Store]
    LoadModel(v.NpcModel)
    if v.NpcAllowed then
        local npc = CreatePed(v.NpcModel, v.x, v.y, v.z, v.h, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        Config.Stores[Store].NPC = npc
    end
end


------------------ PROMPTS ------------------
local function PromptSetUp()
    local str = "Нажмите"
    OpenStores = PromptRegisterBegin()
    PromptSetControlAction(OpenStores, Config.Key)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenStores, str)
    PromptSetEnabled(OpenStores, 1)
    PromptSetVisible(OpenStores, 1)
    PromptSetStandardMode(OpenStores, 1)
    PromptSetGroup(OpenStores, PromptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenStores, true)
    PromptRegisterEnd(OpenStores)
end

local function PromptSetUp2()
    local str = "Нажмите"
    CloseStores = PromptRegisterBegin()
    PromptSetControlAction(CloseStores, Config.Key)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CloseStores, str)
    PromptSetEnabled(CloseStores, 1)
    PromptSetVisible(CloseStores, 1)
    PromptSetStandardMode(CloseStores, 1)
    PromptSetGroup(CloseStores, PromptGroup2)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseStores, true)
    PromptRegisterEnd(CloseStores)

end

local function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

local function openShop(cat, items)
    print('93 items', json.encode(items))
    SendNUIMessage({
        action = 'open',
        cat = cat,
        items = items,
        type = buy
    })
    inUIPage = true
    SetNuiFocus(true, true)
end

RegisterNUICallback("close", function()
    --print('get close')
    SetNuiFocus(false, false)
    inUIPage = false
    ClearPedTasks(PlayerPedId())
end)

RegisterNUICallback("buy", function(data)
    --print('get buy')
    if data.type == 1 then
        TriggerServerEvent("shop:server:buy", data)
    else
        TriggerServerEvent("shop:server:sell", data)
    end

end)

--$.post('https://shop/buy',({item:this.currentItem_value, value:this.dialogValue}));

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if isInMenu == true then
        ClearPedTasksImmediately(PlayerPedId())
        PromptDelete(OpenStores)
        MenuData.CloseAll()
    end
    for i, v in pairs(Config.Stores) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end
        if v.NPC then
            DeleteEntity(v.NPC)
            DeletePed(v.NPC)
            SetEntityAsNoLongerNeeded(v.NPC)
        end
    end
end)


RegisterNetEvent('shop:server:getShopItems')
AddEventHandler('shop:server:getShopItems', function(data, items, buy)
   --print('37 shop data', json.encode(data))
   openShop(data,items, buy)
end)


------- STORES START ----------
Citizen.CreateThread(function()
    PromptSetUp()
    PromptSetUp2()

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if inUIPage == false and not dead then

            for storeId, storeConfig in pairs(Config.Stores) do
                    
                    if not Config.Stores[storeId].BlipHandle and storeConfig.blipAllowed then
                        AddBlip(storeId)
                    end
                    if not Config.Stores[storeId].NPC and storeConfig.NpcAllowed then
                        SpawnNPC(storeId)
                    end
                    -- ## run this before distance check  no need to run a code that is no meant for the client ## --
                    if not next(storeConfig.AllowedJobs) then -- if jobs empty then everyone can use
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsStore = vector3(storeConfig.x, storeConfig.y, storeConfig.z)
                        local distance = #(coordsDist - coordsStore)
                        --print('64 distance', distance)
                        --DrawTxt("Дистанция ".. distance .. " / " ..storeConfig.PromptName, 0.50, 0.9, 0.4, 0.4, true, 255, 255, 255, 255, true)
                        if (distance <= storeConfig.distanceOpenStore) then -- check distance

                            sleep = false
                            local label = CreateVarString(10, 'LITERAL_STRING', storeConfig.PromptName)
                            --print('PromptGroup', PromptGroup, label)
                            PromptSetActiveGroupThisFrame(PromptGroup, label)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenStores) then -- iff all pass open menu
                                TriggerServerEvent('shop:server:getShopItems', storeConfig)
                                --openShop()

                                DisplayRadar(false)
                                TaskStandStill(player, -1)
                                Wait(500)
                            end

                        end

                    else -- job only

                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsStore = vector3(storeConfig.x, storeConfig.y, storeConfig.z)
                        local distance = #(coordsDist - coordsStore)

                        if (distance <= storeConfig.distanceOpenStore) then
                            TriggerServerEvent("vorp_stores:getPlayerJob")
                            Wait(200)
                            if PlayerJob then
                                if CheckJob(storeConfig.AllowedJobs, PlayerJob) then
                                    if tonumber(storeConfig.JobGrade) <= tonumber(JobGrade) then

                                        sleep = false
                                        local label = CreateVarString(10, 'LITERAL_STRING', storeConfig.PromptName)

                                        PromptSetActiveGroupThisFrame(PromptGroup, label)
                                        if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenStores) then
                                            OpenCategory(storeId)

                                            DisplayRadar(false)
                                            TaskStandStill(player, -1)
                                        end
                                    end
                                end
                            end        
                        end



                    end
                

            end
        end
        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

