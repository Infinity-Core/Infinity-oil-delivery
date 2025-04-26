local entities = {}
local npcs = {}
local options = {}
local zonename = nil
local inBankZone = false
local isBusy = false

local missionPrompt, sellPrompt, promptGroup

function CreateOilPrompts()
    Citizen.CreateThread(function()
        promptGroup = Citizen.InvokeNative(0x04F97DE45A519419)
        -- Prompt E (start/cancel mission)
        missionPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(missionPrompt, 0xCEFD9220) -- E
        PromptSetText(missionPrompt, CreateVarString(10, 'LITERAL_STRING', 'Start Mission'))
        PromptSetEnabled(missionPrompt, true)
        PromptSetVisible(missionPrompt, true)
        PromptSetHoldMode(missionPrompt, true)
        PromptSetGroup(missionPrompt, promptGroup)
        PromptRegisterEnd(missionPrompt)
        -- Prompt G (sell oil)
        sellPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(sellPrompt, 0x760A9C6F) -- G
        PromptSetText(sellPrompt, CreateVarString(10, 'LITERAL_STRING', 'Sell Oil'))
        PromptSetEnabled(sellPrompt, true)
        PromptSetVisible(sellPrompt, true)
        PromptSetHoldMode(sellPrompt, true)
        PromptSetGroup(sellPrompt, promptGroup)
        PromptRegisterEnd(sellPrompt)
    end)
end

if not Config.Dialogs then
    CreateOilPrompts()
end

function SpawnOilNpcs()
    for k, v in pairs(Config.OilLocations) do
        if not npcs[k] or not DoesEntityExist(npcs[k]) then
            while not HasModelLoaded(v.model) do
                RequestModel(v.model)
                Wait(1)
            end
            local ped = CreatePed(v.model, v.coords, false, false, 0, 0)
            while not DoesEntityExist(ped) do
                Wait(1)
            end
            Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
            SetEntityCanBeDamaged(ped, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            npcs[k] = ped
            SetModelAsNoLongerNeeded(v.model)
        end
    end
end

-- Spawna todos os NPCs ao iniciar
Citizen.CreateThread(function()
    SpawnOilNpcs()
end)

-- Thread leve: só verifica proximidade dos NPCs criados
Citizen.CreateThread(function()
    local promptActive = false
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local foundNearNpc = false
        local nearNpcKey = nil
        for k, ped in pairs(npcs) do
            if DoesEntityExist(ped) and #(playerCoords - GetEntityCoords(ped)) < 5.0 then
                foundNearNpc = true
                nearNpcKey = k
                break
            end
        end
        if foundNearNpc and not promptActive then
            promptActive = true
            -- Ativa thread rápida
            Citizen.CreateThread(function()
                while promptActive do
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    for k, ped in pairs(npcs) do
                        if DoesEntityExist(ped) and #(playerCoords - GetEntityCoords(ped)) < 5.0 then
                            if Config.Dialogs then
                                DrawText3D(GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z + 1.0, "[E] Orders Center")
                                if IsControlJustReleased(0, 0xCEFD9220) then -- E
                                    TriggerEvent('infinity-oil-delivery:iniciar', k)
                                end
                            else
                                -- PROMPTS NATIVOS
                                local promptLabel = _G.missionactive and 'Cancel Mission' or 'Start Mission'
                                PromptSetText(missionPrompt, CreateVarString(10, 'LITERAL_STRING', promptLabel))
                                local groupName = CreateVarString(10, 'LITERAL_STRING', Config.OilLocations[k].name or 'Oil Center')
                                PromptSetActiveGroupThisFrame(promptGroup, groupName)
                                PromptSetEnabled(missionPrompt, true)
                                PromptSetVisible(missionPrompt, true)
                                PromptSetEnabled(sellPrompt, true)
                                PromptSetVisible(sellPrompt, true)
                                if PromptHasHoldModeCompleted(missionPrompt) or PromptHasStandardModeCompleted(missionPrompt) then
                                    if _G.missionactive then
                                        TriggerEvent('infinity-oil-delivery:client:cancelMission')
                                    else
                                        TriggerEvent('infinity-oil-delivery:client:startMission')
                                    end
                                    Wait(500) -- debounce
                                end
                                if PromptHasHoldModeCompleted(sellPrompt) or PromptHasStandardModeCompleted(sellPrompt) then
                                    TriggerEvent('infinity-oil-delivery:client:selloil')
                                    Wait(500)
                                end
                            end
                        else
                            if not Config.Dialogs then
                                PromptSetEnabled(missionPrompt, false)
                                PromptSetVisible(missionPrompt, false)
                                PromptSetEnabled(sellPrompt, false)
                                PromptSetVisible(sellPrompt, false)
                            end
                        end
                    end
                    -- Se afastou de todos os NPCs criados, desativa prompts e thread
                    local stillNear = false
                    for k, ped in pairs(npcs) do
                        if DoesEntityExist(ped) and #(playerCoords - GetEntityCoords(ped)) < 5.0 then
                            stillNear = true
                            break
                        end
                    end
                    if not stillNear then
                        promptActive = false
                        if not Config.Dialogs then
                            PromptSetEnabled(missionPrompt, false)
                            PromptSetVisible(missionPrompt, false)
                            PromptSetEnabled(sellPrompt, false)
                            PromptSetVisible(sellPrompt, false)
                        end
                        break
                    end
                    Wait(0)
                end
            end)
        end
        Wait(1000)
    end
end)

-- Atualize o evento 'infinity-oil-delivery:iniciar' para receber o índice do NPC correto
AddEventHandler("infinity-oil-delivery:iniciar", function(npcIndex)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestBank = nil
    local minDistance = math.huge
    -- Use apenas Config.OilLocations para encontrar o NPC correto
    for k, v in pairs(Config.OilLocations) do
        local distance = #(playerCoords - v.coords.xyz)
        if distance < minDistance then
            minDistance = distance
            nearestBank = v
        end
    end
    if nearestBank and minDistance <= 5.0 then
        local data = {
            name = "Aqui é a central de ",
            name2 = nearestBank.name,
            dialog = "Sou um mercador e tenho varias entregas, vc pode me ajudar a entrega-las?",
            options = {
                { "Pegar entregas", "infinity-oil-delivery:client:startMission", "client" },
                { "Cancelar entregas", "infinity-oil-delivery:client:cancelMission", "client" },
                { "Vender Óleo", "infinity-oil-delivery:client:selloil", "client" },
                { "Sair da Conversa", "", "close" },
            },
            camCoords = nearestBank.coords.xyz + vector3(0.0, 0.0, 0.5),
            camRotation = vector3(0.0, 0.0, nearestBank.coords.w or nearestBank.heading or 0.0),
        }
        exports["infinity-dialogs"].DisplayDialog(data)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(npcs) do
            if DoesEntityExist(v) then
                DeletePed(v)
                SetEntityAsNoLongerNeeded(v)
            end
        end
        for k, v in pairs(entities) do
            if DoesEntityExist(v) then
                DeletePed(v)
                SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)

