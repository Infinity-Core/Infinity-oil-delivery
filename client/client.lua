local options = {}
local TimerUI = {}
local json = require 'json' -- se já não estiver disponível, use o nativo de seu framework
local carthash, cargohash, lighthash, distance = nil, nil, nil, nil
local wagonSpawned = false
local spawnedVehicle, blip, returnBlip = nil, nil, nil
local playerMissions = {}
local wagonDelivered = false

-- prompts and blips
function createBlipOil()
    for _, v in pairs(Config.Oleo) do
        if v.showblip == true then
            local MiningBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.location)
            SetBlipSprite(MiningBlip, joaat("blip_ambient_tracking"), true)
            SetBlipScale(MiningBlip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, MiningBlip, v.name)
        end
    end    
    for _, v in pairs(Config.OilLocations) do
        if v.showblip == true then
            local DeliveryBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(DeliveryBlip, joaat(v.blipSprite), true)
            SetBlipScale(DeliveryBlip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, DeliveryBlip, v.name)
        end
    end
end

createBlipOil()

---------------------- SELL
RegisterNetEvent('infinity-oil-delivery:client:selloil')
AddEventHandler('infinity-oil-delivery:client:selloil', function()
    local _InfinitySource = GetPlayerServerId(PlayerId())
    local SPlayerDatas = exports.infinity_core:GetPlayerSession(_InfinitySource)
    local inventory = SPlayerDatas and SPlayerDatas._Inventory
    local oilCount = 0
    if type(inventory) == "string" then
        inventory = json.decode(inventory)
    end
    local itemImage = nil
    if inventory and type(inventory) == "table" then
        for _, item in pairs(inventory) do
            if item.name == "oil" then
                if item.img and item.img ~= "" then
                    itemImage = item.img
                else
                    itemImage = "nui://infinity_needs/inventory/items/generic_bottle.png" -- default/fallback path
                end
                break
            end
        end
    end
    print("itemImage:", itemImage)

    if inventory and type(inventory) == "table" then
        for _, item in pairs(inventory) do
            if item.name == "oil" and item.amount and item.amount > 0 then
                oilCount = item.amount
                break
            end
        end
    end
    if oilCount == 0 then
        exports.infinity_core:notification(-1, '<b>Warning</b>', 'You have no oil to sell!', 'bottom_large', 'infinitycore', 4000)
        return
    end
    exports['infinity-oil-delivery']:sellitemPrompt({
        item = "oil",
        itemLabel = "Oil",
        itemImage = itemImage,
        max = oilCount
    }, function(amount, img)
        local usedImage = img or itemImage
        if amount and amount > 0 then
            exports['infinity-oil-delivery']:progressbar('Selling oil...', Config.SellTime, function(success)
                if success then
                    TriggerServerEvent('infinity-oil-delivery:server:selloil', amount)
                end
            end, usedImage)
        end
    end)
end)


------------- --------- -------------
-------------   TIMER   -------------
------------- --------- -------------

local function formatTime(seconds) -- 01:00 format
    local minutes = math.floor(seconds / 60) 
    seconds = seconds - minutes * 60
    return string.format("%02d:%02d",minutes,seconds)
end
 
 
function TimerUI:init() -- Timer function
    TimerUI.data = {}
    TimerUI.data.uiFlowblock = Citizen.InvokeNative(0xC0081B34E395CE48, -119209833) 
 
    local temp = 0
    while not UiflowblockIsLoaded(TimerUI.data.uiFlowblock) do 
        temp = temp + 1
        if temp > 10000 then 
            print('Failed To Load Flowblock')
            return 
        end
        Wait(1) 
    end
 
    if not Citizen.InvokeNative(0x10A93C057B6BD944, TimerUI.data.uiFlowblock) --[[ UIFLOWBLOCK_IS_LOADED ]] then
        print("uiflowblock failed to load")
        return
    end
 
    TimerUI.data.container = DatabindingAddDataContainerFromPath("", "centralInfoDatastore")
 
    -- Must be set empty else a default "Message" text will overlap the time
    DatabindingAddDataString(TimerUI.data.container, "timerMessageString", "")
 
    TimerUI.data.timer = DatabindingAddDataString(TimerUI.data.container, "timerString", "") 
    TimerUI.data.show = DatabindingAddDataBool(TimerUI.data.container, "isVisible", false)
 
    UiflowblockEnter(TimerUI.data.uiFlowblock, `cTimer`)
 
    -- maybe add in while loop to make sure machine is created
    if UiStateMachineExists(1546991729) == 0 then
        TimerUI.data.stateMachine = UiStateMachineCreate(1546991729, TimerUI.data.uiFlowblock)
    end 
 
    -- Time Variable
    TimerUI.data.time = 0
 
    return TimerUI.data.stateMachine
end
 
-- To stop earlier
function TimerUI:stopTimer() 
    self.data.time = 0
    DatabindingWriteDataBool(self.data.show, false)
end
 
---@param time integer -- in seconds
---@param low? integer -- seconds at which timer color will turn to red
function TimerUI:startTimer(time, low) -- in seconds
    if _G.missionactive then            
        if self.data == nil or UiStateMachineExists(1546991729) == 0 then return end
        DatabindingWriteDataBool(self.data.show, true)
        self.data.time = time or 60
    
        while self.data.time >= 1 do
            DatabindingWriteDataString(self.data.timer, formatTime(self.data.time))
            self.data.time = self.data.time - 1
            Wait(1000)
            if low and self.data.time <= low then
                DatabindingAddDataBool(self.data.container, "isTimerLow", true) -- Makes Timer Color as Red
            end
            if self.data.time <= 0 then
                TimerUI:finishTimer()
                if _G.missionactive then
                    CancelMission()
                    return
                end
            end
        end
    end
end
 
function TimerUI:finishTimer()
    UiStateMachineDestroy(154691729)
    if DatabindingIsEntryValid(self.data.container) then
        -- print('Removed Container')
        DatabindingRemoveDataEntry(self.data.container)
    end
    if DatabindingIsEntryValid(self.data.timer) then
        -- print('Removed Timer String')
        DatabindingRemoveDataEntry(self.data.timer)
    end
    if DatabindingIsEntryValid(self.data.show) then
        -- print('Removed Show Bool')
        DatabindingRemoveDataEntry(self.data.show)
    end
end

RegisterNetEvent('oil:timer')
AddEventHandler('oil:timer', function()
    TimerUI:init()
    TimerUI:startTimer(90*60, 30)
end)

RegisterNetEvent('TimerUI:stopTimer')
AddEventHandler('TimerUI:stopTimer', function()
    TimerUI:stopTimer() 
end)

------------- --------- -------------
------------- END TIMER -------------
------------- --------- -------------

local function GetRandomDelivery()
    local randomIndex = math.random(1, #Config.DeliveryOilLocations)
    return Config.DeliveryOilLocations[randomIndex]
end

local function ResetMissionVariables()
    ClearGpsMultiRoute()
    if blip then RemoveBlip(blip) end
    if returnBlip then RemoveBlip(returnBlip) end
    wagonSpawned = false
    _G.missionactive = false
    wagonDelivered = false
    local playerPed = PlayerPedId()
    playerMissions[playerPed] = nil
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        DeleteVehicle(spawnedVehicle)
        spawnedVehicle = nil
        RemoveBlip(blip)  
        
    end
    TimerUI:stopTimer()
end

local function CancelMission()
    ResetMissionVariables()
    exports.infinity_core:notification(-1, '<b>Warning</b>', 'Mission canceled!', 'bottom_large', 'infinitycore', 5000)
end

local function IsVehicleNearby(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        if #(coords - GetEntityCoords(vehicle)) < radius then
            return true
        end
    end
    return false
end

function ApplyPropsetToWagon(wagon, propset)
    if wagon ~= 0 and propset then
        local propsetHash = GetHashKey(propset)
        Wait(1000)
        Citizen.InvokeNative(0x75F90E4051CC084C, wagon, propsetHash)
    end
end

local function SpawnVehicle(deliveryid, cart, cartspawn, cargo, light, endcoords, showgps, missionOiltime, reward)
    local playerPed = PlayerPedId()
    carthash = GetHashKey(cart)
    cargohash = GetHashKey(cargo)
    lighthash = GetHashKey(light)
    local coordsCartSpawn = vector3(cartspawn.x, cartspawn.y, cartspawn.z)
    local coordsEnd = vector3(endcoords.x, endcoords.y, endcoords.z)

    wagonDelivered = false
    
    if IsVehicleNearby(coordsCartSpawn, 5.0) then
        exports.infinity_core:notification(-1, '<b>Warning</b>', 'There is already a wagon at the spawn location!', 'bottom_large', 'infinitycore', 5000)
        return
    end

    RequestModel(carthash)
    while not HasModelLoaded(carthash) do
        RequestModel(carthash)
        Wait(0)
    end 

    spawnedVehicle = CreateVehicle(carthash, coordsCartSpawn, 150.0, true, false)
    SetVehicleOnGroundProperly(spawnedVehicle)
    SetModelAsNoLongerNeeded(carthash)
    Citizen.InvokeNative(0xD80FAF919A2E56EA, spawnedVehicle, cargohash)
    Citizen.InvokeNative(0xC0F0417A90402742, spawnedVehicle, lighthash)
    ApplyPropsetToWagon(spawnedVehicle, cargo)  -- Substitua `cargo` pelo nome do seu propset, se necessário
    
    Wait(200)
    -- Set blips
    Citizen.InvokeNative(0x283978A15512B2FE, spawnedVehicle, true)                    -- SetRandomOutfitVariation
    blip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1230993421, spawnedVehicle) -- BlipAddForEntity
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Wagon")              -- SetBlipName
    Citizen.InvokeNative(0x931B241409216C1F, playerPed, spawnedVehicle, true)

    if showgps then
        StartGpsMultiRoute(GetHashKey("COLOR_BLUE"), true, true)
        AddPointToGpsMultiRoute(endcoords.x, endcoords.y, endcoords.z)
        SetGpsMultiRouteRender(true)
    end
    
    local endBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, endcoords.x, endcoords.y, endcoords.z)
    SetBlipSprite(endBlip, joaat(Config.DeliveryBlip.blipSprite), true)
    SetBlipScale(endBlip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, endBlip, 'Delivery Point')

    wagonSpawned = true
    _G.missionactive = true
    playerMissions[playerPed] = true

    Citizen.CreateThread(function()
        local deliveryPhase = true
        while _G.missionactive do
            local sleep = 1000
            if wagonSpawned then
                local vehpos = GetEntityCoords(spawnedVehicle, true)
                if deliveryPhase then
                    if #(vehpos - coordsEnd) < 20.0 then
                        sleep = 0
                        DrawText3D(coordsEnd.x, coordsEnd.y, coordsEnd.z + 0.98, "Delivery Point")
                        if #(vehpos - coordsEnd) < 3.0 then
                            if showgps then
                                ClearGpsMultiRoute()
                            end
                            exports.infinity_core:notification(-1, '<b>Delivery Completed</b>', 'Return to the initial point and return the wagon!', 'bottom_large', 'infinitycore', 7000)

                            Citizen.InvokeNative(0x75F90E4051CC084C, spawnedVehicle, 0)
                            RemoveVehiclePropSets(spawnedVehicle,cargo)

                            RemoveBlip(endBlip)  
                            StartGpsMultiRoute(GetHashKey("COLOR_BLUE"), true, true)
                            AddPointToGpsMultiRoute(cartspawn.x, cartspawn.y, cartspawn.z)
                            SetGpsMultiRouteRender(true)
                            deliveryPhase = false
                            
                            returnBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, cartspawn.x, cartspawn.y, cartspawn.z)
                            SetBlipSprite(returnBlip, joaat(Config.DeliveryBlip.blipSprite), true)
                            SetBlipScale(returnBlip, 0.2)
                            Citizen.InvokeNative(0x9CB1A1623062F402, returnBlip, 'Delivery Point')
                        end
                    end
                else
                    if #(vehpos - coordsCartSpawn) < 20.0 then
                        sleep = 0
                        DrawText3D(coordsCartSpawn.x, coordsCartSpawn.y, coordsCartSpawn.z + 0.98, "Return Point")
                        if #(vehpos - coordsCartSpawn) < 3.0 then
                            if showgps then
                                ClearGpsMultiRoute()
                            end
                            RemoveBlip(returnBlip)
                            TaskLeaveVehicle(PlayerPedId(), spawnedVehicle, 64)
                            Wait(3500)
                            DeleteVehicle(spawnedVehicle)
                            TriggerServerEvent('infinity-oil-delivery:server:givereward', reward)
                            ResetMissionVariables()
                            
                            Citizen.InvokeNative(0x75F90E4051CC084C, spawnedVehicle, 0) -- Remove os propsets da carroça
                            RemoveVehiclePropSets(spawnedVehicle,cargo)
                            exports.infinity_core:notification(-1, '<b>Delivery Finished</b>', 'Thank you for delivering the goods, here is your payment of $' .. reward, 'bottom_large', 'infinitycore', 7000)
                            wagonDelivered = true
                            break
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

RegisterNetEvent('infinity-oil-delivery:client:startMission')
AddEventHandler('infinity-oil-delivery:client:startMission', function()
    local playerPed = PlayerPedId()
    if wagonSpawned then
        exports.infinity_core:notification(-1, '<b>Warning</b>', 'There is already a spawned wagon, finish the delivery before starting another one!', 'bottom_large', 'infinitycore', 8000)
        return
    end
    if not _G.missionactive then
        local selectedDeliveryOil = GetRandomDelivery()
        local deliveryArgs = {
            name = selectedDeliveryOil.name,
            cart = selectedDeliveryOil.cart,
            cartspawn = selectedDeliveryOil.cartspawn,
            cargo = selectedDeliveryOil.cargo,
            light = selectedDeliveryOil.light,
            endcoords = selectedDeliveryOil.endcoords,
            showgps = selectedDeliveryOil.showgps,
            missionOiltime = selectedDeliveryOil.missionOiltime,
            reward = selectedDeliveryOil.reward
        }
        exports.infinity_core:notification(-1, '<b>Delivery Started</b>', 'Go to ' .. selectedDeliveryOil.name .. ' and deliver the goods.', 10000)
        exports.infinity_core:notification(-1, '<b>The goods are behind the shed, take the wagon to the marked location!</b>', '', 10000)
        _G.missionactive = true
        Wait(3500)
        SpawnVehicle(selectedDeliveryOil.deliveryid, deliveryArgs.cart, deliveryArgs.cartspawn, deliveryArgs.cargo, deliveryArgs.light, deliveryArgs.endcoords, deliveryArgs.showgps, deliveryArgs.missionOiltime, deliveryArgs.reward)
        Wait(3500)
        TriggerEvent('oil:timer')
        playerMissions[playerPed] = true
    else
        exports.infinity_core:notification(-1, '<b>Are you crazy?</b>', 'You have not delivered the goods I gave you and already want another? Deliver it before I take a loss!', 'bottom_large', 'infinitycore', 8000)
    end
end)

RegisterNetEvent('infinity-oil-delivery:client:cancelMission')
AddEventHandler('infinity-oil-delivery:client:cancelMission', CancelMission)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if _G.missionactive and IsEntityDead(playerPed) then
            CancelMission()
            exports.infinity_core:notification(-1, '<b>Warning</b>', 'You died, the mission was canceled!', 'bottom_large', 'infinitycore', 5000)
        end
        Wait(5000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if spawnedVehicle and _G.missionactive and not wagonDelivered then
            if not DoesEntityExist(spawnedVehicle) then
                CancelMission()
                exports.infinity_core:notification(-1, '<b>Warning</b>', 'The wagon was deleted or lost, the mission was canceled!', 'bottom_large', 'infinitycore', 5000)
                break
            end
            local wagonHealth = GetEntityHealth(spawnedVehicle)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local wagonCoords = GetEntityCoords(spawnedVehicle)
            local distanceToWagon = #(playerCoords - wagonCoords)
            local isWagonUpsideDown = IsEntityUpsidedown(spawnedVehicle)
            if wagonHealth == 0 or isWagonUpsideDown or distanceToWagon > 100.0 then
                CancelMission()
                exports.infinity_core:notification(-1, '<b>Warning</b>', 'The wagon was destroyed or lost, the mission was canceled!', 'bottom_large', 'infinitycore', 5000)
                break
            end
        end
        if not _G.missionactive then
            break
        end
    end
end)

-- Centraliza a checagem de proximidade com objetos de óleo em um único loop otimizado
local Oleo = {}
local isChopping = false

function LoadModel(hash)
    hash = GetHashKey(hash)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(3000)
    end
end 

RegisterNetEvent('oil:respawnCane', function(loc)
    local v = GlobalState.Oleo[loc]
    local hash = GetHashKey(v.model)
    if not HasModelLoaded(hash) then LoadModel(hash) end
    if not Oleo[loc] then
        Oleo[loc] = CreateObject(hash, v.location.x, v.location.y, v.location.z-3.5, false, true, true)
        SetEntityAsMissionEntity(Oleo[loc], true, true)
        FreezeEntityPosition(Oleo[loc], true)
        SetEntityHeading(Oleo[loc], v.heading)
    end
end)

RegisterNetEvent('oil:removeCane', function(loc)
    if DoesEntityExist(Oleo[loc]) then DeleteEntity(Oleo[loc]) end
    Oleo[loc] = nil
end)

RegisterNetEvent("oil:init", function()
    for k, v in pairs (GlobalState.Oleo) do
        local hash = GetHashKey(v.model)
        if not HasModelLoaded(hash) then LoadModel(hash) end
        if not v.taken then
            Oleo[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z-3.5, false, true, true)
            SetEntityAsMissionEntity(Oleo[k], true, true)
            FreezeEntityPosition(Oleo[k], true)
            SetEntityHeading(Oleo[k], v.heading)
        end
    end
end)

-- Loop centralizado para interação com todos os objetos de óleo
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local foundNear = false
        for loc, obj in pairs(Oleo) do
            if obj and DoesEntityExist(obj) and #(playerCoords - GetEntityCoords(obj)) < 2.0 then
                foundNear = true
                DrawText3D(GetEntityCoords(obj).x, GetEntityCoords(obj).y, GetEntityCoords(obj).z + 1.0, "[E] Get Oil")
                if IsControlJustReleased(0, 0xCEFD9220) and not isChopping then -- E
                    isChopping = true
                    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
                    exports['infinity-oil-delivery']:progressbar('Getting Oil', 18000, function(success)
                        if success then
                            TriggerServerEvent("oil:pickupCane", loc)
                            ClearPedTasksImmediately(PlayerPedId(-1))
                            ClearPedTasks(PlayerPedId())
                            TriggerServerEvent('infinity-oil-delivery:server:giveOilReward')
                        end
                        isChopping = false
                    end)
                end
            end
        end
        if foundNear then
            Wait(0) -- só processa a cada frame se estiver perto de algum objeto
        else
            Wait(500) -- caso contrário, espera meio segundo
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        LoadModel('P_BARREL_COR01X')
        TriggerEvent('oil:init')
    end
 end)

 RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
     Wait(3000)
     LoadModel('P_BARREL_COR01X')
     TriggerEvent('oil:init')
 end)
 
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetModelAsNoLongerNeeded(GetHashKey('P_BARREL_COR01X'))        
        ClearGpsMultiRoute(endcoords)
        ClearPedTasks(playerPed)
        DeleteVehicle(vehicle)
        wagonSpawned = false
        _G.missionactive = false

        for k, v in pairs(Oleo) do
            if DoesEntityExist(v) then
                DeleteEntity(v) SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end